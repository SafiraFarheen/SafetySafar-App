# Environment Setup Guide

## Backend Setup

### Step 1: Install Dependencies
First, create and activate a virtual environment, then install Python dependencies:

```bash
cd safety_safar_backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### Step 2: Create `.env` File
Copy `.env.example` to `.env` in the `safety_safar_backend` folder:

```bash
cp .env.example .env
```

### Step 3: Update Environment Variables
Edit `.env` and fill in the actual values:

```
# Frontend URL where your Flutter app will run
FRONTEND_URL=http://localhost:3000

# Gmail SMTP Credentials
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_specific_password (get from Gmail App Passwords)
MAIL_FROM=your_email@gmail.com
MAIL_PORT=587
MAIL_SERVER=smtp.gmail.com
MAIL_STARTTLS=True
MAIL_SSL_TLS=False
MAIL_FROM_NAME=SafetySafar Support
```

### Step 4: Gmail App Passwords Setup
To get `MAIL_PASSWORD`, follow these steps:

1. Enable 2-factor authentication on your Gmail account
2. Go to https://myaccount.google.com/apppasswords
3. Select "Mail" and "Windows Computer" (or your device)
4. Google will generate a 16-character password
5. Paste that into `MAIL_PASSWORD` in your `.env` file

### Step 5: Run the Backend Server
```bash
# Make sure you're in safety_safar_backend folder with activated venv
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The backend will be available at: `http://localhost:8000`
- Docs: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

⚠️ **Never commit the `.env` file to GitHub!** It's already in `.gitignore`.

## Frontend Setup (Flutter)

For detailed Flutter setup instructions, see [FLUTTER_SETUP.md](FLUTTER_SETUP.md)

Quick start:
### Step 1: Install Flutter
Follow https://flutter.dev/docs/get-started/install

### Step 2: Get Dependencies
```bash
cd safety_safar_app
flutter pub get
```

### Step 3: Configure Firebase
- Android: Place `google-services.json` in `safety_safar_app/android/app/`
- iOS: Place `GoogleService-Info.plist` in `safety_safar_app/ios/Runner/`

### Step 4: Run the App
```bash
flutter run
```

## ⚠️ Important Security Notes

- **Never commit `.env` files** - They contain sensitive credentials
- **Never share API keys or passwords** in issues/PRs
- Use `.env.example` to document what variables are needed
- Always use `.gitignore` to exclude sensitive files
