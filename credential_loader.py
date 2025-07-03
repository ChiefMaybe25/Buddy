#!/usr/bin/env python3
"""
Credential Loader for BUDDY Backend
Loads encrypted credentials and sets them as environment variables.
"""

import os
import json
import base64
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import getpass

def load_encrypted_credentials():
    """Load encrypted credentials and set as environment variables"""
    key_file = ".buddy_key"
    cred_file = ".buddy_creds"
    
    if not os.path.exists(key_file) or not os.path.exists(cred_file):
        print("⚠️  No encrypted credentials found.")
        print("Run 'python secure_credentials.py' to set up credentials.")
        return False
    
    try:
        # Load the encryption key
        with open(key_file, 'rb') as f:
            data = f.read()
            salt = data[:16]
            encrypted_key = data[16:]
        
        # Get password from user
        print("💡 Password hint: your apple id pass")
        password = getpass.getpass("Enter master password for credentials: ")
        
        # Generate key from password
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(password.encode()))
        
        # Decrypt the stored key
        temp_fernet = Fernet(key)
        stored_key = temp_fernet.decrypt(encrypted_key)
        fernet = Fernet(stored_key)
        
        # Load and decrypt credentials
        with open(cred_file, 'rb') as f:
            encrypted_data = f.read()
        
        decrypted_data = fernet.decrypt(encrypted_data)
        credentials = json.loads(decrypted_data.decode())
        
        # Set environment variables
        for key, value in credentials.items():
            os.environ[key] = value
        
        print("✅ Credentials loaded successfully!")
        return True
        
    except Exception as e:
        print(f"❌ Error loading credentials: {e}")
        return False

def check_credentials():
    """Check if credentials are available"""
    required_vars = [
        "CLOUDINARY_CLOUD_NAME",
        "CLOUDINARY_API_KEY", 
        "CLOUDINARY_API_SECRET"
    ]
    
    missing = [var for var in required_vars if not os.getenv(var)]
    
    if missing:
        print(f"⚠️  Missing environment variables: {', '.join(missing)}")
        return False
    
    return True

if __name__ == "__main__":
    if load_encrypted_credentials():
        print("Credentials loaded and environment variables set.")
    else:
        print("Failed to load credentials.") 