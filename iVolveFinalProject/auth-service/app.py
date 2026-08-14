import os
import time
import bcrypt
import mysql.connector
from flask import Flask, jsonify, request

app = Flask(__name__)

DB_CONFIG = {
    "host": os.environ.get("DB_HOST"),
    "port": int(os.environ.get("DB_PORT", "3306")),
    "user": os.environ.get("DB_USER"),
    "password": os.environ.get("DB_PASSWORD"),
    "database": os.environ.get("DB_NAME"),
}

def validate_config():
    required = ["DB_HOST", "DB_PORT", "DB_USER", "DB_PASSWORD", "DB_NAME"]
    missing = [key for key in required if not os.environ.get(key)]
    if missing:
        raise RuntimeError(f"Missing database environment variables: {', '.join(missing)}")

def get_connection():
    validate_config()
    return mysql.connector.connect(**DB_CONFIG, connection_timeout=5)

def ensure_database_ready():
    conn = None
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT DATABASE()")
        db = cursor.fetchone()[0]
        if db != DB_CONFIG["database"]:
            raise RuntimeError("Configured database was not selected")
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                username VARCHAR(100) NOT NULL UNIQUE,
                password_hash VARCHAR(255) NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        conn.commit()
    finally:
        if conn:
            conn.close()

def db_error():
    return jsonify({
        "message": "There is an issue with the MySQL connection or the ivolve database."
    }), 503

@app.get("/health")
def health():
    try:
        ensure_database_ready()
        return jsonify({"status": "UP", "database": "connected"})
    except Exception as exc:
        app.logger.error("Database health check failed: %s", exc)
        return jsonify({"status": "DOWN", "database": "unavailable"}), 503

@app.post("/api/auth/signup")
def signup():
    data = request.get_json(silent=True) or {}
    username = (data.get("username") or "").strip()
    password = data.get("password") or ""

    if len(username) < 3:
        return jsonify({"message": "Username must be at least 3 characters."}), 400
    if len(password) < 8:
        return jsonify({"message": "Password must be at least 8 characters."}), 400

    try:
        ensure_database_ready()
        password_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO users (username, password_hash) VALUES (%s, %s)",
            (username, password_hash),
        )
        conn.commit()
        return jsonify({"message": "User created successfully."}), 201
    except mysql.connector.IntegrityError:
        return jsonify({"message": "Username already exists."}), 409
    except Exception as exc:
        app.logger.error("Signup database error: %s", exc)
        return db_error()
    finally:
        try:
            cursor.close()
            conn.close()
        except Exception:
            pass

@app.post("/api/auth/login")
def login():
    data = request.get_json(silent=True) or {}
    username = (data.get("username") or "").strip()
    password = data.get("password") or ""

    try:
        ensure_database_ready()
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute(
            "SELECT id, username, password_hash FROM users WHERE username = %s",
            (username,),
        )
        user = cursor.fetchone()

        if not user or not bcrypt.checkpw(
            password.encode(), user["password_hash"].encode()
        ):
            return jsonify({"message": "Invalid username or password."}), 401

        return jsonify({
            "message": "Login successful.",
            "user": {"id": user["id"], "username": user["username"]}
        })
    except Exception as exc:
        app.logger.error("Login database error: %s", exc)
        return db_error()
    finally:
        try:
            cursor.close()
            conn.close()
        except Exception:
            pass

if __name__ == "__main__":
    for attempt in range(30):
        try:
            ensure_database_ready()
            print("MySQL database is ready.")
            break
        except Exception as exc:
            print(f"Waiting for MySQL ({attempt + 1}/30): {exc}")
            time.sleep(2)
    else:
        print("MySQL is not available. The service will start and return DB errors.")

    app.run(host="0.0.0.0", port="5000")
