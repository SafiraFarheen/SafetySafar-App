from fastapi import APIRouter, Depends, HTTPException, Form, File, UploadFile
from sqlalchemy.orm import Session
from app.database import SessionLocal
from app.models.users import User
from app.schemas.users_schema import UserCreate
from app.schemas.login_schema import UserLogin
from app.schemas.auth_schema import (
    ForgotPasswordRequest, ResetPasswordRequest, 
    SendOTPRequest, VerifyOTPRequest,
    AuthorityRegisterRequest, AuthorityApprovalRequest
)
from app.auth.auth_utils import (
    hash_password, verify_password, hash_identity, 
    send_reset_email, send_otp_sms, generate_otp
)
from app.auth.jwt_utils import create_access_token
from app.auth.dependencies import get_db, get_current_user
import os
import shutil
import uuid
from datetime import date, datetime
from typing import List

router = APIRouter()

UPLOAD_DIR = "uploads"
if not os.path.exists(UPLOAD_DIR):
    os.makedirs(UPLOAD_DIR)

@router.post("/register")
async def register(
    first_name: str = Form(...),
    last_name: str = Form(...),
    email: str = Form(...),
    phone: str = Form(...),
    password: str = Form(...),
    nationality: str = Form(...),
    dob: str | None = Form(None),
    gender: str = Form(...),
    document_type: str = Form(...),
    document_number: str = Form(...),
    arrival_date: str | None = Form(None),
    departure_date: str | None = Form(None),
    accommodation_details: str = Form(...),
    itinerary_json: str = Form(...),
    emergency_name: str = Form(...),
    emergency_phone: str = Form(...),
    emergency_relation: str = Form(...),
    profile_photo: UploadFile = File(...),
    id_document: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    try:
        existing_user = db.query(User).filter(User.email == email).first()
        if existing_user:
            raise HTTPException(status_code=400, detail="Email already registered")

        # Validate identity type
        if nationality.lower() == "indian":
            if document_type.lower() not in ["aadhaar", "driving lic."]:
                raise HTTPException(status_code=400, detail="Indian users must use Aadhaar or Driving Lic.")
        elif nationality.lower() == "foreign":
            if document_type.lower() != "passport":
                raise HTTPException(status_code=400, detail="Foreign users must use Passport")

        hashed_pw = hash_password(password)
        identity_hash = hash_identity(document_number)

        # Save files
        profile_filename = f"{email}_profile_{profile_photo.filename}"
        doc_filename = f"{email}_doc_{id_document.filename}"

        with open(os.path.join(UPLOAD_DIR, profile_filename), "wb") as buffer:
            shutil.copyfileobj(profile_photo.file, buffer)

        with open(os.path.join(UPLOAD_DIR, doc_filename), "wb") as buffer:
            shutil.copyfileobj(id_document.file, buffer)

        new_user = User(
            first_name=first_name,
            last_name=last_name,
            email=email,
            phone=phone,
            hashed_password=hashed_pw,
            nationality=nationality,
            dob=dob,
            gender=gender,
            document_type=document_type,
            document_number=document_number,
            identity_hash=identity_hash,
            arrival_date=arrival_date,
            departure_date=departure_date,
            accommodation_details=accommodation_details,
            itinerary_json=itinerary_json,
            emergency_name=emergency_name,
            emergency_phone=emergency_phone,
            emergency_relation=emergency_relation
        )

        db.add(new_user)
        db.commit()
        db.refresh(new_user)

        return {"message": "User registered successfully. Files uploaded. Digital ID will be issued after KYC verification."}

    except HTTPException:
        raise
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

from fastapi import Request

from fastapi import Request

@router.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    try:
        print("Received login request:", user.email)

        db_user = db.query(User).filter(User.email == user.email).first()

        if not db_user:
            raise HTTPException(status_code=400, detail="Invalid email or password")

        if not verify_password(user.password, db_user.hashed_password):
            raise HTTPException(status_code=400, detail="Invalid email or password")

        token = create_access_token({
            "sub": str(db_user.id),
            "role": db_user.role
        })

        return {
            "access_token": token,
            "token_type": "bearer",
            "role": db_user.role,
            "user_id": str(db_user.id)
        }

    except HTTPException:
        raise
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/forgot-password")
async def forgot_password(req: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == req.email).first()
    if not user:
        # Don't reveal if user exists for security, but we'll show success
        return {"message": "If this email is registered, a reset link has been sent."}

    reset_token = str(uuid.uuid4())
    user.reset_token = reset_token
    db.commit()

    try:
        await send_reset_email(user.email, reset_token)
    except Exception as e:
        print(f"Email Error: {e}")
        raise HTTPException(status_code=500, detail="Failed to send email. Please check your SMTP settings.")

    return {"message": "If this email is registered, a reset link has been sent."}

@router.post("/reset-password")
def reset_password(req: ResetPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.reset_token == req.token).first()
    if not user:
        raise HTTPException(status_code=400, detail="Invalid or expired reset token")

    user.hashed_password = hash_password(req.new_password)
    user.reset_token = None
    db.commit()

    return {"message": "Password updated successfully"}

@router.post("/send-otp")
def send_otp(req: SendOTPRequest, db: Session = Depends(get_db)):
    # Check if user exists with this phone
    user = db.query(User).filter(User.phone == req.phone).first()
    
    otp = generate_otp()
    
    if not user:
        # Create a new temporary user record if they don't exist
        # This allows OTP to be stored and verified later
        identity_hash = hash_identity(req.phone)  # Use phone as temporary identity
        user = User(
            phone=req.phone,
            first_name="Phone",
            last_name="User",
            email=f"{req.phone}@safetysafar.in",
            hashed_password="temp_otp",  # Temporary, will be set on registration
            role="tourist",
            nationality="Unknown",
            document_type="Unknown",
            document_number=req.phone,
            identity_hash=identity_hash,
            otp_code=otp  # Store OTP immediately
        )
        db.add(user)
        db.commit()
        print(f"DEBUG: Created new user for phone {req.phone}")
    else:
        # Update existing user's OTP
        user.otp_code = otp
        db.commit()
    
    # Actually send the SMS
    sid = send_otp_sms(req.phone, otp)
    if not sid:
        # If SMS service fails (e.g. no Twilio credentials), we'll log it and let it pass for dev
        print(f"DEBUG: OTP for {req.phone} is {otp}")
        return {"message": "OTP sent (Simulation Mode)", "otp": otp} # Returning OTP for dev testing

    return {"message": "OTP sent successfully", "otp": otp}

@router.post("/verify-otp")
def verify_otp(req: VerifyOTPRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.phone == req.phone).first()
    
    # If using Firebase, we trust the 'firebase_verified' flag from the trusted mobile app
    if req.otp == "firebase_verified":
        if not user:
             # Create a new tourist user if they don't exist yet
             identity_hash = hash_identity(req.phone)
             user = User(
                 phone=req.phone,
                 first_name="New",
                 last_name="User",
                 email=f"{req.phone}@safetysafar.in",
                 hashed_password="firebase_auth",
                 role="tourist",
                 nationality="Indian",
                 document_type="Aadhaar",
                 document_number=req.phone,
                 identity_hash=identity_hash
             )
             db.add(user)
             db.commit()
             db.refresh(user)
    else:
        # Standard OTP verification
        if not user:
            raise HTTPException(status_code=400, detail="No OTP sent for this phone number. Request OTP first.")
        
        if user.otp_code != req.otp:
            raise HTTPException(status_code=400, detail="Invalid OTP")
        
        # Clear OTP after successful verification
        user.otp_code = None
        db.commit()
        print(f"DEBUG: OTP verified successfully for {req.phone}")

    token = create_access_token({
        "sub": str(user.id),
        "role": user.role
    })

    return {
        "access_token": token, 
        "token_type": "bearer",
        "role": user.role,
        "user_id": str(user.id)
    }

# 🧪 TEST ENDPOINT - Get OTP for testing (development only)
@router.get("/test-get-otp/{phone}")
def test_get_otp(phone: str, db: Session = Depends(get_db)):
    """
    TEST ENDPOINT: Get the current OTP for a phone number (for development/testing only)
    Usage: http://backend:8000/test-get-otp/7013456834
    
    WARNING: This endpoint should be removed before deploying to production!
    """
    user = db.query(User).filter(User.phone == phone).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="No OTP request found for this phone number")
    
    if not user.otp_code:
        raise HTTPException(status_code=400, detail="No active OTP for this phone number")
    
    return {
        "phone": phone,
        "otp": user.otp_code,
        "message": "Use this OTP to complete verification",
        "warning": "This endpoint is for testing only - remove before production!"
    }


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# AUTHORITY / ADMIN ENDPOINTS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@router.post("/authority/login")
def authority_login(user: UserLogin, db: Session = Depends(get_db)):
    """
    Login endpoint for authority/admin users.
    Authorities can only login if they are approved (is_approved=True).
    """
    try:
        print(f"Authority login attempt for email: {user.email}")
        
        db_user = db.query(User).filter(User.email == user.email).first()
        
        if not db_user:
            raise HTTPException(status_code=400, detail="Invalid email or password")
        
        # Check if user has authority or admin role
        if db_user.role not in ["authority", "admin"]:
            raise HTTPException(status_code=403, detail="This account is not registered as an authority")
        
        # Check if authority is approved
        if not db_user.is_approved:
            raise HTTPException(
                status_code=403, 
                detail="Your authority account has not been approved yet. Please contact the administrator."
            )
        
        # Verify password
        if not verify_password(user.password, db_user.hashed_password):
            raise HTTPException(status_code=400, detail="Invalid email or password")
        
        token = create_access_token({
            "sub": str(db_user.id),
            "role": db_user.role
        })
        
        return {
            "access_token": token,
            "token_type": "bearer",
            "role": db_user.role,
            "user_id": str(db_user.id),
            "first_name": db_user.first_name,
            "last_name": db_user.last_name,
            "department": db_user.department
        }
    
    except HTTPException:
        raise
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/authority/register")
async def authority_register(
    req: AuthorityRegisterRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Register a new authority account.
    This endpoint is admin-only. Only existing admins can register new authorities.
    
    Process:
    1. Admin submits authority details
    2. Authority account is created with is_approved=False
    3. Admin must manually approve the account via /authority/approve endpoint
    4. Only after approval can the authority login
    """
    try:
        # Check if current user is an admin
        if current_user.role != "admin":
            raise HTTPException(status_code=403, detail="Only admins can register new authorities")
        
        # Check if email already exists
        existing_user = db.query(User).filter(User.email == req.email).first()
        if existing_user:
            raise HTTPException(status_code=400, detail="Email already registered")
        
        # Check if phone already exists
        existing_phone = db.query(User).filter(User.phone == req.phone).first()
        if existing_phone:
            raise HTTPException(status_code=400, detail="Phone number already registered")
        
        # Hash password
        hashed_pw = hash_password(req.password)
        
        # Create identity hash (using email for authorities)
        identity_hash = hash_identity(req.email)
        
        # Create new authority user
        new_authority = User(
            first_name=req.first_name,
            last_name=req.last_name,
            email=req.email,
            phone=req.phone,
            hashed_password=hashed_pw,
            role="authority",  # Default role, can be updated to "admin" during approval
            nationality="India",  # Authorities are from India
            document_type="Government ID",
            document_number=req.email,  # Use email as identifier
            identity_hash=identity_hash,
            department=req.department,
            is_approved=False,  # Must be approved by admin before login
            kyc_verified=True  # Authorities don't need KYC since they're government officials
        )
        
        db.add(new_authority)
        db.commit()
        db.refresh(new_authority)
        
        return {
            "message": "Authority account created successfully. Pending admin approval.",
            "user_id": str(new_authority.id),
            "email": new_authority.email,
            "is_approved": new_authority.is_approved,
            "department": new_authority.department
        }
    
    except HTTPException:
        raise
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/authority/approve/{user_id}")
async def approve_authority(
    user_id: str,
    req: AuthorityApprovalRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Approve an authority account.
    This endpoint is admin-only. Only existing admins can approve authority accounts.
    
    Once approved:
    - Authority can login with their email and password
    - Authority gets access to the authority dashboard
    """
    try:
        # Check if current user is an admin
        if current_user.role != "admin":
            raise HTTPException(status_code=403, detail="Only admins can approve authorities")
        
        # Get the authority user
        authority_user = db.query(User).filter(User.id == user_id).first()
        if not authority_user:
            raise HTTPException(status_code=404, detail="Authority user not found")
        
        # Check if user is authority or admin role
        if authority_user.role not in ["authority", "admin"]:
            raise HTTPException(status_code=400, detail="This user is not registered as an authority")
        
        # Update approval status
        authority_user.is_approved = True
        authority_user.approved_at = datetime.utcnow()
        authority_user.approved_by = current_user.id
        authority_user.role = req.role  # Update role (can be "authority" or "admin")
        authority_user.department = req.department
        
        db.commit()
        db.refresh(authority_user)
        
        return {
            "message": f"Authority {authority_user.email} approved successfully",
            "user_id": str(authority_user.id),
            "email": authority_user.email,
            "role": authority_user.role,
            "department": authority_user.department,
            "is_approved": authority_user.is_approved,
            "approved_at": authority_user.approved_at.isoformat() if authority_user.approved_at else None
        }
    
    except HTTPException:
        raise
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/authority/pending")
async def get_pending_authorities(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Get list of pending authority approvals.
    This endpoint is admin-only.
    """
    try:
        if current_user.role != "admin":
            raise HTTPException(status_code=403, detail="Only admins can view pending authorities")
        
        pending = db.query(User).filter(
            User.role.in_(["authority", "admin"]),
            User.is_approved == False
        ).all()
        
        return [
            {
                "id": str(auth.id),
                "first_name": auth.first_name,
                "last_name": auth.last_name,
                "email": auth.email,
                "phone": auth.phone,
                "department": auth.department,
                "created_at": auth.created_at.isoformat() if auth.created_at else None
            }
            for auth in pending
        ]
    
    except HTTPException:
        raise
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))