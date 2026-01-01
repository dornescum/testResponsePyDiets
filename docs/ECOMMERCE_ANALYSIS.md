# E-Commerce Integration Analysis

## Overview

Analysis of the viability of building an in-house e-commerce system vs using existing platforms (WooCommerce, Shopify) for selling diet-related products to patients.

**Date**: December 2024
**Status**: Analysis / Planning

---

## Current Flow (Affiliate Model)

```
Doctor assigns diet → Email with product list → Patient clicks affiliate link
                                               → External platform (Kiros)
                                               → Uses doctor discount code
                                               → Clinic gets commission
```

**Revenue**: Commission per sale (likely 10-20%)
**Effort**: Minimal
**Control**: Low

---

## Proposed Flow (In-House E-commerce)

```
Doctor assigns diet → Email with diet + shop link → Patient registers/logs in
                                                   → Clinic's own shop
                                                   → Add to cart, checkout (Stripe)
                                                   → Dropship from supplier
                                                   → Clinic keeps margin
```

**Assumptions**:
- Payment service: Stripe (to be integrated)
- Mail service: Active
- Shipping: External provider (dropship, no local inventory)
- Patients: Already registered in clinic system

---

## Option Comparison

| Aspect | Build In-House | WooCommerce | Shopify |
|--------|---------------|-------------|---------|
| **Setup Time** | 4-8 weeks | 1-2 weeks | 2-3 days |
| **Monthly Cost** | ~€20 (hosting) | ~€30 (hosting + plugins) | €29-299 |
| **Transaction Fees** | Stripe 1.4%+€0.25 | Stripe + some plugins | Stripe + 0.5-2% |
| **Integration** | Native (same DB) | API/webhooks | API/webhooks |
| **Patient UX** | Single account | Separate account | Separate account |
| **Data Ownership** | 100% yours | Yours (self-hosted) | Shopify's servers |
| **Maintenance** | High (you) | Medium (updates) | Low (managed) |
| **Scalability** | Depends on code | Good with caching | Excellent |
| **Security** | Your responsibility | Plugin-dependent | PCI Level 1 |

---

## Build In-House: Detailed Analysis

### What You'd Need to Build

```
database/
├── shop_products.sql           # Product catalog (can link to product_links)
├── shop_orders.sql             # Orders, order_items
├── shop_cart.sql               # Cart sessions
└── shop_shipping.sql           # Shipping zones, rates

src/
├── controllers/
│   ├── ShopController.js       # Product listing, cart, checkout
│   └── OrderController.js      # Order management, tracking
├── models/
│   └── database.js             # +ShopProduct, Order, Cart, ShippingRate
├── routes/
│   └── shop.js                 # /shop/* routes
└── views/
    └── shop/
        ├── catalog.ejs         # Product grid
        ├── product.ejs         # Product detail
        ├── cart.ejs            # Shopping cart
        ├── checkout.ejs        # Checkout form
        ├── confirmation.ejs    # Order confirmation
        └── orders.ejs          # Patient order history
```

### Database Schema (Minimum)

```sql
-- ============================================
-- SHOP PRODUCTS
-- ============================================
-- Extends or links to existing product_links table

CREATE TABLE shop_products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_link_id INT NULL COMMENT 'Link to existing product_links if applicable',
    sku VARCHAR(50) NOT NULL COMMENT 'Stock Keeping Unit',
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL COMMENT 'Selling price',
    compare_at_price DECIMAL(10,2) NULL COMMENT 'Original price for discount display',
    cost_price DECIMAL(10,2) NULL COMMENT 'Your cost from supplier',
    stock_quantity INT DEFAULT 0,
    track_inventory TINYINT(1) DEFAULT 1,
    weight_grams INT NULL COMMENT 'For shipping calculation',
    status ENUM('active', 'draft', 'archived') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_link_id) REFERENCES product_links(id) ON DELETE SET NULL
);

-- ============================================
-- ORDERS
-- ============================================

CREATE TABLE shop_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(20) NOT NULL UNIQUE COMMENT 'Human-readable order number',
    patient_id INT NULL COMMENT 'Registered patient (NULL for guest)',
    guest_email VARCHAR(100) NULL COMMENT 'Email for guest checkout',
    status ENUM('pending', 'paid', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded') DEFAULT 'pending',

    -- Pricing
    subtotal DECIMAL(10,2) NOT NULL COMMENT 'Sum of items before shipping/discount',
    shipping_cost DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    discount_code VARCHAR(50) NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) NOT NULL COMMENT 'Final amount charged',
    currency CHAR(3) DEFAULT 'EUR',

    -- Shipping address
    shipping_name VARCHAR(100) NOT NULL,
    shipping_address TEXT NOT NULL,
    shipping_city VARCHAR(100) NOT NULL,
    shipping_postal VARCHAR(20) NOT NULL,
    shipping_country CHAR(2) NOT NULL COMMENT 'ISO country code',
    shipping_phone VARCHAR(30),

    -- Billing (if different)
    billing_same_as_shipping TINYINT(1) DEFAULT 1,
    billing_name VARCHAR(100) NULL,
    billing_address TEXT NULL,
    billing_city VARCHAR(100) NULL,
    billing_postal VARCHAR(20) NULL,
    billing_country CHAR(2) NULL,
    billing_vat_number VARCHAR(50) NULL COMMENT 'For business customers',

    -- Payment (Stripe)
    stripe_payment_intent VARCHAR(100) NULL,
    stripe_charge_id VARCHAR(100) NULL,
    stripe_customer_id VARCHAR(100) NULL,
    paid_at TIMESTAMP NULL,

    -- Fulfillment
    tracking_number VARCHAR(100) NULL,
    tracking_url VARCHAR(255) NULL,
    carrier VARCHAR(50) NULL COMMENT 'DHL, UPS, FedEx, etc.',
    shipped_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,

    -- Metadata
    notes TEXT NULL COMMENT 'Customer notes',
    admin_notes TEXT NULL COMMENT 'Internal notes',
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(255) NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE SET NULL
);

-- Order line items
CREATE TABLE shop_order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(200) NOT NULL COMMENT 'Snapshot of product name at time of order',
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL COMMENT 'Price per unit at time of order',
    total_price DECIMAL(10,2) NOT NULL COMMENT 'quantity × unit_price',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES shop_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES shop_products(id) ON DELETE RESTRICT
);

-- ============================================
-- SHOPPING CART
-- ============================================

CREATE TABLE shop_carts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    session_id VARCHAR(100) NOT NULL COMMENT 'Express session ID or custom token',
    patient_id INT NULL COMMENT 'If logged in',
    expires_at TIMESTAMP NOT NULL COMMENT 'Auto-cleanup old carts',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY (session_id),
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
);

CREATE TABLE shop_cart_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cart_id) REFERENCES shop_carts(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES shop_products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_cart_product (cart_id, product_id)
);

-- ============================================
-- DISCOUNT CODES
-- ============================================

CREATE TABLE shop_discount_codes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE COMMENT 'e.g., DOCTOR_SMITH_10',
    type ENUM('percentage', 'fixed') NOT NULL,
    value DECIMAL(10,2) NOT NULL COMMENT 'Percentage (10 = 10%) or fixed amount',
    min_order_amount DECIMAL(10,2) NULL COMMENT 'Minimum order to apply',
    max_discount_amount DECIMAL(10,2) NULL COMMENT 'Cap for percentage discounts',
    usage_limit INT NULL COMMENT 'Total uses allowed (NULL = unlimited)',
    usage_limit_per_patient INT NULL COMMENT 'Uses per patient',
    usage_count INT DEFAULT 0,

    -- Attribution
    doctor_id INT NULL COMMENT 'Auto-generated for referring doctor',
    campaign VARCHAR(100) NULL COMMENT 'Marketing campaign name',

    -- Validity
    valid_from DATE NULL,
    valid_until DATE NULL,
    status TINYINT(1) DEFAULT 1,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (doctor_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Track discount code usage
CREATE TABLE shop_discount_usage (
    id INT AUTO_INCREMENT PRIMARY KEY,
    discount_code_id INT NOT NULL,
    order_id INT NOT NULL,
    patient_id INT NULL,
    discount_applied DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (discount_code_id) REFERENCES shop_discount_codes(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES shop_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE SET NULL
);

-- ============================================
-- SHIPPING ZONES & RATES
-- ============================================

CREATE TABLE shop_shipping_zones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT 'e.g., Italy, Europe, World',
    countries TEXT NOT NULL COMMENT 'Comma-separated ISO codes: IT,FR,DE',
    status TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE shop_shipping_rates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    zone_id INT NOT NULL,
    name VARCHAR(100) NOT NULL COMMENT 'e.g., Standard, Express',
    min_order_amount DECIMAL(10,2) NULL COMMENT 'Free shipping threshold',
    price DECIMAL(10,2) NOT NULL,
    min_weight_grams INT NULL,
    max_weight_grams INT NULL,
    estimated_days_min INT NULL,
    estimated_days_max INT NULL,
    status TINYINT(1) DEFAULT 1,
    FOREIGN KEY (zone_id) REFERENCES shop_shipping_zones(id) ON DELETE CASCADE
);
```

---

## Pros & Cons Summary

### Pros (In-House)

| Pro | Impact |
|-----|--------|
| **Single patient account** | Better UX, patient already registered |
| **Native diet integration** | Auto-populate cart from diet, track compliance |
| **Full margin** | Keep 100% profit minus supplier cost + Stripe fees |
| **Data ownership** | All purchase data stays in your DB, GDPR simpler |
| **Custom features** | Auto-reorder reminders, low stock from inventory system |
| **Doctor discount codes** | Auto-generate per doctor, track referrals |
| **No platform fees** | Only Stripe ~1.4-2.9% vs Shopify 0.5-2% extra |

### Cons (In-House)

| Con | Mitigation |
|-----|------------|
| **Development time** | 4-8 weeks for MVP, can phase it |
| **Payment security** | Stripe handles PCI, use Stripe Checkout/Elements |
| **Shipping complexity** | Use shipping API (SendCloud, Shippo, EasyPost) |
| **Tax handling** | Stripe Tax or simple VAT per country table |
| **Refunds/disputes** | Stripe Dashboard handles most, build simple admin |
| **Maintenance** | Part of existing app maintenance |
| **No SEO/marketplace traffic** | Patients come from clinic, not search |

---

## Revenue Model Comparison

| Model | Sale Price | Supplier Cost | Stripe Fee | Platform Fee | **Net Margin** |
|-------|-----------|---------------|------------|--------------|----------------|
| **Affiliate** | - | - | - | - | ~15% commission |
| **Shopify** | €50 | €25 | €1.70 | €1.00 | €22.30 (44%) |
| **In-House** | €50 | €25 | €1.70 | €0 | €23.30 (47%) |

*Example: €50 product, €25 supplier cost, Stripe 2.9%+€0.25, Shopify 2%*

---

## Recommendation

### For This Use Case: **Build In-House (Phased)**

**Why?**
1. Customers are **already patients** - no need for marketplace discovery
2. Patient data already exists - single account UX
3. Diet → Shop flow is **unique** to this business
4. Dropship model = no inventory management complexity
5. Existing inventory tracking can trigger "reorder" emails
6. Doctor discount codes can be auto-generated and tracked

---

## Phased Implementation Plan

### Phase 1: MVP (Week 1-2)
- [ ] Product catalog (linked to `product_links`)
- [ ] Simple cart (session-based)
- [ ] Stripe Checkout (hosted, secure, minimal code)
- [ ] Order storage
- [ ] Email confirmation

### Phase 2: Integration (Week 3-4)
- [ ] Patient login required for checkout
- [ ] Auto-populate cart from diet assignment
- [ ] Doctor discount codes with attribution
- [ ] Order history in patient profile
- [ ] Admin order list view

### Phase 3: Operations (Week 5-6)
- [ ] Admin order management (status updates, notes)
- [ ] Shipping integration (SendCloud/Shippo API)
- [ ] Tracking number updates
- [ ] Low stock reorder reminder emails
- [ ] Order export (CSV)

### Phase 4: Advanced (Future)
- [ ] Subscription / auto-reorder for recurring products
- [ ] Supplier inventory sync via API
- [ ] Analytics dashboard (sales, top products, doctor referrals)
- [ ] Invoice PDF generation
- [ ] Multi-currency support

---

## Decision Matrix

| If you want... | Choose |
|----------------|--------|
| Fastest launch | Shopify |
| Lowest ongoing cost | In-House |
| Best patient experience | In-House |
| Least maintenance | Shopify |
| Full data control | In-House |
| Diet ↔ Shop integration | In-House |
| Existing WordPress site | WooCommerce |

---

## Technical Considerations

### Stripe Integration
- Use **Stripe Checkout** for MVP (hosted payment page, minimal PCI scope)
- Later migrate to **Stripe Elements** for embedded checkout if needed
- Webhooks for payment confirmation, refunds, disputes

### Shipping Providers (API Integration)
- **SendCloud** - Popular in EU, good rates
- **Shippo** - Multi-carrier, good API
- **EasyPost** - Developer-friendly
- **Direct carrier APIs** - DHL, UPS, FedEx

### Email Notifications
- Order confirmation
- Shipping notification with tracking
- Delivery confirmation
- Low stock reminder (from inventory system)
- Abandoned cart recovery (optional)

### Security Checklist
- [ ] HTTPS everywhere
- [ ] Stripe handles card data (PCI compliance)
- [ ] CSRF protection on forms
- [ ] Rate limiting on checkout
- [ ] Input validation
- [ ] SQL injection prevention (parameterized queries)
- [ ] Session security for cart

---

## Files to Create (If Proceeding)

```
database/
└── shop_system.sql              # All shop tables

src/
├── controllers/
│   ├── ShopController.js        # Catalog, cart, checkout
│   └── ShopAdminController.js   # Order management
├── routes/
│   ├── shop.js                  # Public shop routes
│   └── shop-admin.js            # Admin routes
└── views/
    └── shop/
        ├── catalog.ejs
        ├── product.ejs
        ├── cart.ejs
        ├── checkout.ejs
        ├── confirmation.ejs
        ├── orders.ejs           # Patient order history
        └── admin/
            ├── orders.ejs       # Admin order list
            └── order-detail.ejs # Admin order detail
```

---

## Next Steps

1. **Decision**: Confirm in-house approach
2. **Supplier**: Confirm dropship arrangement and product catalog
3. **Stripe**: Set up Stripe account and get API keys
4. **Phase 1**: Begin MVP development
