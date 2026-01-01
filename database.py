import os
import mysql.connector
from mysql.connector import Error
from fastapi import HTTPException

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "127.0.0.1"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "user": os.getenv("DB_USER", "clinic_user"),
    "password": os.getenv("DB_PASSWORD", "clinic_password"),
    "database": os.getenv("DB_NAME", "medical_clinic")
}


def get_db_connection():
    """Create and return a database connection."""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        return connection
    except Error as e:
        raise HTTPException(status_code=500, detail=f"Database connection failed: {str(e)}")
