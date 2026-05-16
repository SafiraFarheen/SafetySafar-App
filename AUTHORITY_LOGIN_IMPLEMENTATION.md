# Authority/Admin Login System Implementation Guide

## 🎯 Overview

A dedicated Authority/Admin Login system has been successfully implemented for the Safety Safar application. This system maintains clean separation between tourist and authority workflows, with authorities requiring only essential credentials (email and password) and approval-based access management.

## 📋 What Was Implemented

### 1. **Backend Database Schema Updates**

#### User Model Enhancements (`app/models/users.py`)
Added authority-specific fields to the `User` model:
- `is_approved` (Boolean, default=False) - Controls whether an authority can login
- `department` (String, nullable) - Stores department/authority name (e.g., "Police", "Tourism Board")
- `approved_at` (DateTime, nullable) - Timestamp when authority was approved
- `approved_by` (UUID, nullable) - ID of the admin who approved this authority

#### Database Migrations (`app/database.py`)
Updated `ensure_user_columns()` to automatically create these new columns in Supabase:
- Added all four new authority fields to the migration logic
- Ensures backward compatibility with existing tourist accounts

### 2. **Backend API Endpoints**

#### Authority Authentication (`app/auth/auth_routes.py`)

**Endpoint: `POST /authority/login`**
- **Purpose**: Login for approved authority/admin accounts only
- **Credentials**: Email & Password (simplified vs. tourist registration)
- **Restrictions**:
  - User must have `role` of "authority" or "admin"
  - User must have `is_approved == True`
  - Password verification required
- **Response**: JWT token, role, user_id, department info
- **Error Responses**:
  - 400: Invalid email/password
  - 403: Account not approved or not an authority

**Endpoint: `POST /authority/register`** (Admin-only)
- **Purpose**: Register new authority accounts
- **Authorization**: Only existing admins can register authorities
- **Input**: first_name, last_name, email, phone, password, department
- **Process**:
  1. Admin submits authority details
  2. Account created with `is_approved = False`
  3. Account awaits admin approval
- **Response**: User ID, email, approval status

**Endpoint: `POST /authority/approve/{user_id}`** (Admin-only)
- **Purpose**: Approve authority accounts for login access
- **Authorization**: Only existing admins can approve authorities
- **Input**: department (required), role ("authority" or "admin")
- **Updates**:
  - Sets `is_approved = True`
  - Records `approved_at` timestamp
  - Records `approved_by` admin ID
  - Updates user `role` and `department`
- **Response**: Confirmation with updated authority details

**Endpoint: `GET /authority/pending`** (Admin-only)
- **Purpose**: View pending authority approval requests
- **Authorization**: Only admins can access
- **Response**: List of all unapproved authorities with their details

### 3. **Pydantic Schemas** (`app/schemas/auth_schema.py`)

Added new request schemas:
```python
class AuthorityRegisterRequest(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    phone: str
    password: str
    department: str

class AuthorityApprovalRequest(BaseModel):
    user_id: str
    department: str
    role: str  # "authority" or "admin"
```

### 4. **Flutter Frontend Implementation**

#### New Screen: Login Role Selector (`lib/login_role_selector_screen.dart`)
Beautiful UI that asks users to choose between two login types:
- **Option 1**: "I am a Tourist" → Tourist registration/login flow
- **Option 2**: "I am an Authority" → Authority login screen

Features:
- Gradient background with branded design
- Two card-based role selection options
- Security information display
- Smooth navigation to respective flows

#### New Screen: Authority Login (`lib/screens/authority_login_screen.dart`)
Simplified login screen for government officials:

**Fields**:
- Email address
- Password
- Show/hide password toggle

**Features**:
- Email and password validation
- Clear error messages
- Approval status information
- Back button to role selector
- Automatic routing to AuthorityDashboard on successful login
- Specific error handling for:
  - Unapproved accounts (403)
  - Invalid credentials (400)
  - Network errors

#### Navigation Updates (`lib/main.dart`)
- Import LoginRoleSelectorScreen
- Set it as the initial route (/)
- Added /login route for backward compatibility
- Maintains existing dashboard navigation patterns

### 5. **API Configuration Updates** (`lib/utils/api_config.dart`)
Added new authority endpoints:
```dart
static const String authorityLogin = '$baseUrl/authority/login';
static const String authorityRegister = '$baseUrl/authority/register';
static String authorityApprove(String userId) => '$baseUrl/authority/approve/$userId';
static const String pendingAuthorities = '$baseUrl/authority/pending';
```

## 🔐 Security Features

### Account Approval Workflow
1. **Admin Registration**: Only existing admins can register new authorities
2. **Pending Status**: New authority accounts start as unapproved
3. **Explicit Approval**: Admin must explicitly approve each account
4. **Access Control**: Unapproved authorities cannot login (401 error)
5. **Audit Trail**: System records who approved which authority and when

### Data Protection
- Authority credentials separate from tourist credentials
- No need for authorities to provide tourist-specific data
- Password hashing required for all accounts
- JWT-based authentication with role verification

### Role-Based Access Control
- "tourist" role → Tourist features only
- "authority" role → Authority features only
- "admin" role → Can manage authorities + authority features
- Endpoints check role before allowing access

## 📱 User Flows

### Authority Login Flow
```
1. User opens app
2. LoginRoleSelectorScreen shown
3. User selects "I am an Authority"
4. AuthorityLoginScreen shown
5. User enters email & password
6. System checks:
   - Email exists?
   - Password correct?
   - User has authority/admin role?
   - User is_approved == True?
7. If all checks pass → Generate JWT → Navigate to AuthorityDashboard
8. If unapproved → Show "Contact administrator" message
```

### Admin Approval Flow
```
1. Admin logs in with admin account
2. Admin navigates to authority management
3. Admin views GET /authority/pending endpoint
4. Admin selects authority to approve
5. Admin calls POST /authority/approve/{user_id} with role and department
6. Authority account becomes active
7. Authority can now login
```

### New Authority Registration Flow (Admin-only)
```
1. Admin has access to authority registration form
2. Admin enters: first_name, last_name, email, phone, password, department
3. Admin calls POST /authority/register endpoint
4. Account created with is_approved = False
5. Account appears in pending approvals list
6. Admin can approve using POST /authority/approve/{user_id}
```

## 🔄 Key Differences: Tourist vs Authority

| Aspect | Tourist | Authority |
|--------|---------|-----------|
| **Registration** | Public self-registration | Admin-only creation |
| **Credentials** | Email + OTP/Password | Email + Password only |
| **Required Data** | Full itinerary & emergency details | Minimal (name, department) |
| **Initial Access** | Immediate after registration | Only after admin approval |
| **Documents** | Must upload ID & profile photo | Not required |
| **Role** | "tourist" | "authority" or "admin" |
| **Login Screen** | OTP or password | Password only |
| **Dashboard** | TouristDashboard | AuthorityDashboard |

## 🛠️ API Testing Guide

### Test Authority Login
```bash
POST /authority/login
Content-Type: application/json

{
  "email": "officer@police.gov",
  "password": "securepassword123"
}

# Success Response (200):
{
  "access_token": "eyJhbGc...",
  "token_type": "bearer",
  "role": "authority",
  "user_id": "uuid",
  "first_name": "John",
  "last_name": "Doe",
  "department": "Police"
}

# Unapproved Response (403):
{
  "detail": "Your authority account has not been approved yet. Please contact the administrator."
}
```

### Test Authority Registration (Admin-only)
```bash
POST /authority/register
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "first_name": "Jane",
  "last_name": "Smith",
  "email": "jane@tourism.gov",
  "phone": "+919876543210",
  "password": "SecurePass123!",
  "department": "Tourism Board"
}

# Response (200):
{
  "message": "Authority account created successfully. Pending admin approval.",
  "user_id": "uuid",
  "email": "jane@tourism.gov",
  "is_approved": false,
  "department": "Tourism Board"
}
```

### Get Pending Approvals (Admin-only)
```bash
GET /authority/pending
Authorization: Bearer {admin_token}

# Response (200):
{
  "total_pending": 2,
  "authorities": [
    {
      "user_id": "uuid1",
      "first_name": "Jane",
      "last_name": "Smith",
      "email": "jane@tourism.gov",
      "phone": "+919876543210",
      "department": "Tourism Board",
      "created_at": "2026-05-16T10:30:00Z"
    },
    ...
  ]
}
```

### Approve Authority (Admin-only)
```bash
POST /authority/approve/uuid1
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "department": "Tourism Board",
  "role": "authority"
}

# Response (200):
{
  "message": "Authority jane@tourism.gov approved successfully",
  "user_id": "uuid1",
  "email": "jane@tourism.gov",
  "role": "authority",
  "department": "Tourism Board",
  "is_approved": true,
  "approved_at": "2026-05-16T10:35:00Z"
}
```

## 📝 Database Schema Changes

### New Columns in `users` Table
```sql
ALTER TABLE users ADD COLUMN is_approved BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN department VARCHAR;
ALTER TABLE users ADD COLUMN approved_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN approved_by UUID;
```

These columns are automatically created by the migration logic in `database.py` on first startup.

## 🚀 Deployment Checklist

- [x] Backend models updated
- [x] Database migrations configured
- [x] Authority API endpoints implemented
- [x] Admin-only authorization added
- [x] Flutter UI screens created
- [x] API configuration updated
- [x] Navigation routing set up
- [x] Error handling implemented
- [x] Security measures applied
- [ ] Create first admin account (needs manual SQL or API call)
- [ ] Train admins on authority management
- [ ] Test full flow in staging environment
- [ ] Deploy backend (API endpoints ready)
- [ ] Deploy frontend (UI ready)

## 🎓 Usage Instructions for Admins

### Creating First Admin Account
Since only admins can register authorities, the first admin must be created manually:

```sql
-- SSH into Supabase or use SQL editor
INSERT INTO users (
  id, email, phone, first_name, last_name, 
  hashed_password, role, nationality, document_type, 
  document_number, identity_hash, kyc_verified, is_approved
) VALUES (
  gen_random_uuid(),
  'admin@government.in',
  '+919999999999',
  'System',
  'Administrator',
  -- Use bcrypt hash of password
  '$2b$12$...',
  'admin',
  'India',
  'Government ID',
  'ADMIN001',
  -- Use hash_identity('ADMIN001')
  'hash_value',
  TRUE,
  TRUE
);
```

### Daily Admin Tasks
1. **Check Pending Approvals**: GET /authority/pending (via dashboard UI)
2. **Review Authority Details**: Check department, contact info, created_at timestamp
3. **Approve Authorities**: POST /authority/approve/{user_id} with role and department
4. **Monitor Active Authorities**: Track who is logged in and when

## 📚 Files Modified/Created

### Backend Files
- ✅ `app/models/users.py` - Added authority fields
- ✅ `app/database.py` - Added migration for authority columns
- ✅ `app/schemas/auth_schema.py` - Added authority schemas
- ✅ `app/auth/auth_routes.py` - Added 4 new endpoints

### Frontend Files
- ✅ `lib/login_role_selector_screen.dart` - NEW: Role selection UI
- ✅ `lib/screens/authority_login_screen.dart` - NEW: Authority login UI
- ✅ `lib/main.dart` - Updated initial route and imports
- ✅ `lib/utils/api_config.dart` - Added authority endpoints

## 🔗 Related Features

This authority system integrates with:
- **AuthorityDashboard** - Pre-existing dashboard for authorities
- **JWT Authentication** - Existing token generation system
- **Role-Based Middleware** - Existing `get_current_user` dependency
- **Supabase** - Cloud database for authority accounts

## ⚠️ Important Notes

1. **Backward Compatibility**: Existing tourist accounts work unchanged
2. **No Data Migration**: Tourists don't need to provide new fields
3. **Separate Flows**: Tourist and authority flows are completely independent
4. **Manual Admin Creation**: First admin must be created via direct database access
5. **Approval Required**: All authorities must be explicitly approved before first login
6. **Audit Trail**: All approvals are logged with timestamp and approver ID

## 🧪 Testing the Implementation

### Manual Frontend Testing
```
1. Build & run Flutter app: flutter run
2. Initial screen shows role selector
3. Click "I am a Tourist" → Tourist login screen
4. Click back → Role selector shown again
5. Click "I am an Authority" → Authority login screen
6. Enter test credentials (after creating test authority via API)
7. Verify successful navigation to AuthorityDashboard
```

### Manual Backend Testing
Use Postman or curl to test endpoints:
- Test /authority/login with approved authority
- Test /authority/login with unapproved authority (should fail)
- Test /authority/register as admin (should succeed)
- Test /authority/approve as admin (should succeed)
- Test all endpoints as non-admin (should fail with 403)

## 🎉 Success Indicators

✅ App shows role selector on startup
✅ Can navigate between tourist and authority login
✅ Authority login only accepts email + password
✅ Unapproved authorities get helpful error message
✅ Approved authorities can login successfully
✅ Admin endpoints check authorization correctly
✅ Database automatically creates new columns

---

**Implementation Date**: May 16, 2026
**Status**: ✅ Complete and Ready for Testing
