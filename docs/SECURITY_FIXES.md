# Security Fixes Required

This document outlines security vulnerabilities found in the Medical Clinic application and how to fix them.

---
## CRITICAL Priority

### 1. Missing Crypto Import

**File:** `index.js:47`

**Problem:** `crypto.randomBytes()` used without importing the module - causes runtime crash.

**Fix:**
```javascript
// Add at the top of index.js
const crypto = require('crypto');
```

---

### 2. SQL Injection in LIMIT/OFFSET

**File:** `src/models/database.js:76,188`

**Problem:** LIMIT and OFFSET values concatenated directly into SQL queries.

**Current Code (line 76):**
```javascript
query += ` LIMIT ${Number(limit)} OFFSET ${Number(offset)}`;
```

**Fix:**
```javascript
// In Patient.getAll() around line 76
if (limit !== undefined && offset !== undefined) {
    query += ` LIMIT ? OFFSET ?`;
    params.push(Number(limit), Number(offset));
}
```

```javascript
// In MedicalRecord.getLatest() around line 188
const query = `
    SELECT mr.*, p.name as patient_name, p.surname as patient_surname,
           u.name as doctor_name
    FROM medical_records mr
    JOIN patients p ON mr.patient_id = p.id
    JOIN users u ON mr.doctor_id = u.id
    ORDER BY mr.created_at DESC
    LIMIT ?
`;
return await executeQuery(query, [Number(limit)]);
```

---

## HIGH Priority

### 3. Session Cookie Security

**File:** `index.js:49-52`

**Problem:** httpOnly and sameSite flags disabled, secure flag off.

**Current Code:**
```javascript
cookie: {
    secure: false,
    // httpOnly: true,
    maxAge: 86400000,
    // sameSite: 'lax'
}
```

**Fix:**
```javascript
cookie: {
    secure: process.env.NODE_ENV === 'production',
    httpOnly: true,
    maxAge: 86400000,
    sameSite: 'lax'
}
```

---

### 4. Unrestricted CORS

**File:** `index.js:36`

**Problem:** `cors()` allows requests from any origin.

**Current Code:**
```javascript
app.use(cors());
```

**Fix:**
```javascript
app.use(cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type']
}));
```

Add to `.env`:
```
ALLOWED_ORIGINS=http://localhost:3000
```

---

### 5. Path Traversal in File Uploads

**File:** `index.js:60-78`

**Problem:** File serving endpoint vulnerable to path traversal attacks.

**Fix:** Replace the entire `/uploads` handler:
```javascript
app.use('/uploads', requireAuth, (req, res, next) => {
    const pathParts = req.path.split('/').filter(Boolean);

    if (pathParts.length !== 2) {
        return res.status(400).send('Invalid file path');
    }

    const [patientId, filename] = pathParts;

    // Validate patientId is numeric
    if (!/^\d+$/.test(patientId)) {
        return res.status(400).send('Invalid patient ID');
    }

    // Validate filename has no path traversal
    if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
        return res.status(400).send('Invalid filename');
    }

    const uploadsDir = path.join(__dirname, 'public', 'uploads');
    const filePath = path.join(uploadsDir, patientId, filename);
    const resolvedPath = path.resolve(filePath);

    // Verify resolved path is within uploads directory
    if (!resolvedPath.startsWith(path.resolve(uploadsDir))) {
        return res.status(403).send('Access denied');
    }

    res.sendFile(resolvedPath, (err) => {
        if (err) {
            res.status(404).send('File not found');
        }
    });
});
```

---

### 6. Wrong File Path in View Template

**File:** `src/views/patients/view.ejs:101`

**Problem:** Uses `uploaded_by` instead of patient ID for file path.

**Current Code:**
```html
<a href="/uploads/<%= file.uploaded_by %>/<%= file.filename %>">
```

**Fix:**
```html
<a href="/uploads/<%= patient.id %>/<%= file.filename %>">
```

---

### 7. Unsafe-inline in CSP

**File:** `index.js:29-30`

**Problem:** `'unsafe-inline'` in script-src and style-src defeats XSS protection.

**Fix:** Remove `'unsafe-inline'` and move inline scripts/styles to external files:
```javascript
contentSecurityPolicy: {
    directives: {
        defaultSrc: ["'self'"],
        scriptSrc: ["'self'", "https://cdn.jsdelivr.net"],
        styleSrc: ["'self'", "https://cdn.jsdelivr.net", "https://cdnjs.cloudflare.com"],
        imgSrc: ["'self'", "data:", "https:"],
        fontSrc: ["'self'", "https://cdnjs.cloudflare.com"],
    },
},
```

Note: This requires refactoring inline scripts in EJS templates to external JS files.

---

## MEDIUM Priority

### 8. Sensitive Data in Logs

**File:** `src/models/database.js:33-34`

**Problem:** Query parameters (may contain passwords) logged to console.

**Fix:**
```javascript
const executeQuery = async (query, params = []) => {
    if (process.env.NODE_ENV === 'development') {
        console.log('Executing query:', query);
        console.log('Parameter count:', params.length);
        // Don't log actual param values
    }
    // ... rest of function
};
```

---

### 9. Add CSRF Protection

**Install:**
```bash
npm install csurf
```

**Add to `index.js`:**
```javascript
const csrf = require('csurf');

// After session middleware
app.use(csrf());

// Make token available to all views
app.use((req, res, next) => {
    res.locals.csrfToken = req.csrfToken();
    next();
});
```

**Add to all forms in EJS templates:**
```html
<form method="POST" action="/...">
    <input type="hidden" name="_csrf" value="<%= csrfToken %>">
    <!-- rest of form -->
</form>
```

---

### 10. Add Rate Limiting

**Install:**
```bash
npm install express-rate-limit
```

**Add to `index.js`:**
```javascript
const rateLimit = require('express-rate-limit');

// General rate limit
const generalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100,
    message: 'Too many requests, please try again later'
});

// Strict limit for login
const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 5,
    message: 'Too many login attempts, please try again later'
});

app.use(generalLimiter);
app.use('/login', loginLimiter);
```

---

### 11. Remove Default Credentials from Login Page

**File:** `src/views/auth/login.ejs:45-54`

**Remove this entire block:**
```html
<small class="text-muted">
    Default credentials:<br>
    Admin: it@clinic.com<br>password<br>
    Doctor: doctor@clinic.com<br>password<br>
    Assistant: info@clinic.com<br>password
</small>
```

---

### 12. Strengthen Helmet Configuration

**File:** `index.js`

**Replace Helmet configuration:**
```javascript
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            scriptSrc: ["'self'", "https://cdn.jsdelivr.net"],
            styleSrc: ["'self'", "https://cdn.jsdelivr.net", "https://cdnjs.cloudflare.com"],
            imgSrc: ["'self'", "data:", "https:"],
            fontSrc: ["'self'", "https://cdnjs.cloudflare.com"],
        },
    },
    hsts: {
        maxAge: 31536000,
        includeSubDomains: true,
        preload: true
    },
    frameguard: { action: 'deny' },
    noSniff: true,
    referrerPolicy: { policy: 'strict-origin-when-cross-origin' }
}));
```

---

### 13. Add Input Validation to Search

**File:** `src/routes/patients.js:16-22`

**Fix:**
```javascript
const { query, validationResult } = require('express-validator');

router.get('/search', requireAuth, requireStaffOrAdmin, [
    query('term')
        .trim()
        .notEmpty().withMessage('Search term is required')
        .isLength({ max: 100 }).withMessage('Search term too long')
        .escape()
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.json({ success: false, errors: errors.array() });
    }

    const searchTerm = req.query.term;
    const result = await Patient.search(searchTerm);
    // ... rest of handler
});
```

---

## LOW Priority

### 14. Fix npm Vulnerabilities

```bash
npm audit
npm audit fix
```

---

### 15. Add Ownership Check to Appointment Delete

**File:** `src/routes/appointments.js:120-142`

**Add verification before delete:**
```javascript
router.delete('/:id', requireAuth, requireStaffOrAdmin, async (req, res) => {
    try {
        const { id } = req.params;

        // Verify appointment exists
        const appointment = await Appointment.findById(id);
        if (!appointment.success || !appointment.data) {
            return res.status(404).json({ error: 'Appointment not found' });
        }

        // Optional: Check if user owns the appointment or is admin
        // if (appointment.data.doctor_id !== req.session.userId && req.session.role !== 1) {
        //     return res.status(403).json({ error: 'Not authorized' });
        // }

        const result = await Appointment.delete(id);
        // ... rest of handler
    }
});
```

---

### 16. Use Production Session Store

**Install:**
```bash
npm install express-mysql-session
```

**Update `index.js`:**
```javascript
const MySQLStore = require('express-mysql-session')(session);

const sessionStore = new MySQLStore({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

app.use(session({
    store: sessionStore,
    // ... rest of config
}));
```

---

## Checklist

- [ ] Add crypto import
- [ ] Fix SQL injection in LIMIT/OFFSET
- [ ] Enable httpOnly, sameSite, secure cookie flags
- [ ] Configure CORS with allowed origins
- [ ] Fix path traversal vulnerability
- [ ] Fix file path in view.ejs
- [ ] Remove unsafe-inline from CSP
- [ ] Stop logging query parameters
- [ ] Install and configure csurf
- [ ] Install and configure rate limiting
- [ ] Remove default credentials from login page
- [ ] Strengthen Helmet configuration
- [ ] Add validation to search endpoint
- [ ] Run npm audit fix
- [ ] Add ownership check to appointment delete
- [ ] Configure production session store
