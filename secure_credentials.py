#!/usr/bin/env python3
"""
Secure Credential Manager for BUDDY
Encrypts and stores sensitive credentials in a secure file.
"""

import os
import json
import base64
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import getpass

class SecureCredentials:
    def __init__(self, key_file=".buddy_key", cred_file=".buddy_creds"):
        self.key_file = key_file
        self.cred_file = cred_file
        self.fernet = None
        
    def _generate_key_from_password(self, password, salt=None):
        """Generate encryption key from password"""
        if salt is None:
            salt = os.urandom(16)
        
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        key = base64.urlsafe_b64encode(kdf.derive(password.encode()))
        return key, salt
    
    def _load_or_create_key(self):
        """Load existing key or create new one"""
        if os.path.exists(self.key_file):
            with open(self.key_file, 'rb') as f:
                data = f.read()
                salt = data[:16]
                encrypted_key = data[16:]
                
            print("💡 Password hint: your apple id pass")
            password = getpass.getpass("Enter your master password: ")
            key, _ = self._generate_key_from_password(password, salt)
            
            # Decrypt the stored key
            temp_fernet = Fernet(key)
            stored_key = temp_fernet.decrypt(encrypted_key)
            self.fernet = Fernet(stored_key)
        else:
            self._create_new_key()
    
    def _create_new_key(self):
        """Create new encryption key"""
        print("Creating new secure credential storage...")
        print("💡 Password hint: your apple id pass")
        password = getpass.getpass("Create a master password: ")
        confirm_password = getpass.getpass("Confirm master password: ")
        
        if password != confirm_password:
            raise ValueError("Passwords don't match!")
        
        # Generate encryption key
        key, salt = self._generate_key_from_password(password)
        self.fernet = Fernet(key)
        
        # Encrypt and store the key
        temp_fernet = Fernet(key)
        encrypted_key = temp_fernet.encrypt(key)
        
        with open(self.key_file, 'wb') as f:
            f.write(salt + encrypted_key)
        
        print("✅ Secure credential storage created!")
    
    def store_credentials(self, credentials):
        """Store encrypted credentials"""
        if self.fernet is None:
            self._load_or_create_key()
        
        encrypted_data = self.fernet.encrypt(json.dumps(credentials).encode())
        
        with open(self.cred_file, 'wb') as f:
            f.write(encrypted_data)
        
        print("✅ Credentials stored securely!")
    
    def load_credentials(self):
        """Load and decrypt credentials"""
        if not os.path.exists(self.cred_file):
            return None
        
        if self.fernet is None:
            self._load_or_create_key()
        
        with open(self.cred_file, 'rb') as f:
            encrypted_data = f.read()
        
        decrypted_data = self.fernet.decrypt(encrypted_data)
        return json.loads(decrypted_data.decode())
    
    def setup_credentials(self):
        """Interactive setup for Cloudinary credentials"""
        print("🔐 Setting up Cloudinary credentials securely...")
        print("Get these from: https://cloudinary.com/console")
        
        cloud_name = input("Cloudinary Cloud Name: ").strip()
        api_key = input("Cloudinary API Key: ").strip()
        api_secret = input("Cloudinary API Secret: ").strip()
        
        credentials = {
            "CLOUDINARY_CLOUD_NAME": cloud_name,
            "CLOUDINARY_API_KEY": api_key,
            "CLOUDINARY_API_SECRET": api_secret
        }
        
        self.store_credentials(credentials)
        return credentials

def main():
    """Main function for credential management"""
    secure_creds = SecureCredentials()
    
    # Check if credentials exist
    existing_creds = secure_creds.load_credentials()
    
    if existing_creds:
        print("✅ Found existing credentials!")
        print("Cloud Name:", existing_creds["CLOUDINARY_CLOUD_NAME"])
        print("API Key:", existing_creds["CLOUDINARY_API_KEY"][:8] + "...")
        
        choice = input("\nDo you want to update credentials? (y/N): ").strip().lower()
        if choice == 'y':
            new_creds = secure_creds.setup_credentials()
            print("✅ Credentials updated!")
        else:
            print("Using existing credentials.")
    else:
        print("No existing credentials found.")
        secure_creds.setup_credentials()

if __name__ == "__main__":
    main() 