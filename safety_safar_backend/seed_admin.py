#!/usr/bin/env python3
"""
Seed admin user for Safety Safar application.
Creates an initial admin user: safetysafarsupport@gmail.com

Usage:
    python seed_admin.py <password>
    Example: python seed_admin.py TestAdmin123
"""

import os
import sys
from datetime import datetime
import uuid
import hashlib

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.models.users import User
from app.database import SessionLocal, engine
from app.auth.auth_utils import hash_password

def create_identity_hash(text):
    """Create a hash of identity information."""
    return hashlib.sha256(text.encode()).hexdigest()

def seed_admin(db: Session, password: str):
    """Create initial admin user."""
    email = "safetysafarsupport@gmail.com"
    
    # Check if admin already exists
    existing_admin = db.query(User).filter(User.email == email).first()
    if existing_admin:
        print(f"✓ Admin user already exists: {email}")
        print(f"  - Role: {existing_admin.role}")
        print(f"  - Status: {'Approved' if existing_admin.is_approved else 'Pending'}")
        return
    
    # Validate password
    if len(password) < 6:
        print("✗ Error: Password must be at least 6 characters long")
        sys.exit(1)
    
    hashed_password = hash_password(password)
    
    # Create admin user
    admin_user = User(
        id=str(uuid.uuid4()),
        first_name="Safety",
        last_name="Safar Admin",
        email=email,
        phone="+1-800-ADMIN-01",
        hashed_password=hashed_password,
        role="admin",
        nationality="India",  # Required field
        gender="Other",  # Required field
        document_type="Other",  # Required field
        document_number="ADMIN-001",  # Required field
        identity_hash=create_identity_hash("ADMIN-001"),  # Required field
        accommodation_details="N/A",  # Required field
        itinerary_json='{"notes": "Admin Account"}',  # Required field
        emergency_name="Admin Support",  # Required field
        emergency_phone="+1-800-ADMIN-01",  # Required field
        emergency_relation="Official",  # Required field
        kyc_verified=True,  # Auto-verified for admin
        is_approved=True,  # Admin is auto-approved
        department="Administration",
        approved_at=datetime.utcnow(),
        approved_by=None,  # No one approved this, it's the seed admin
        created_at=datetime.utcnow(),
    )
    
    db.add(admin_user)
    db.commit()
    db.refresh(admin_user)
    
    print("✓ Admin user created successfully!")
    print(f"  - Email: {email}")
    print(f"  - User ID: {admin_user.id}")
    print(f"  - Role: {admin_user.role}")
    print(f"  - Department: {admin_user.department}")
    print(f"  - Status: Approved (auto-approved as seed admin)")
    print("\nYou can now login to the authority dashboard as admin.")

if __name__ == "__main__":
    try:
        print("=" * 60)
        print("Safety Safar - Admin User Seeding")
        print("=" * 60)
        
        if len(sys.argv) < 2:
            print("\n✗ Error: Password required!")
            print("Usage: python seed_admin.py <password>")
            print("Example: python seed_admin.py TestAdmin123")
            sys.exit(1)
        
        password = sys.argv[1]
        
        db = SessionLocal()
        seed_admin(db, password)
        db.close()
        
        print("\n✓ Seeding complete!")
    except Exception as e:
        print(f"\n✗ Error during seeding: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
