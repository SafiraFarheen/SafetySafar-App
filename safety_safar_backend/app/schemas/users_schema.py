from pydantic import BaseModel, EmailStr
from typing import Optional

class UserCreate(BaseModel):
    first_name: str
    last_name: Optional[str] = None
    email: EmailStr
    phone: str
    password: str
    nationality: str
    dob: Optional[str] = None
    gender: Optional[str] = None
    document_type: str  # aadhaar or passport
    document_number: str
    
    arrival_date: Optional[str] = None
    departure_date: Optional[str] = None
    accommodation_details: Optional[str] = None
    itinerary_json: Optional[str] = None
    
    emergency_name: Optional[str] = None
    emergency_phone: Optional[str] = None
    emergency_relation: Optional[str] = None

class UserUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    nationality: Optional[str] = None
    dob: Optional[str] = None
    gender: Optional[str] = None
    arrival_date: Optional[str] = None
    departure_date: Optional[str] = None
    accommodation: Optional[str] = None
    emergency_name: Optional[str] = None
    emergency_phone: Optional[str] = None
    emergency_relation: Optional[str] = None
    
    # Backwards compatibility fields
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
