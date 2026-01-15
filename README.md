# Smart Document Search Engine

A full-stack intelligent document search application built with Flutter (frontend) and FastAPI (backend).

## Project Structure

- **Frontend**: Flutter app (`lib/`) with Firebase authentication
- **Backend**: FastAPI Python server (`backend/app/`) with SQLite database

## Prerequisites

### For Flutter Frontend:

- Flutter SDK (>=3.0.0)
- Dart SDK
- Firebase project configured (for authentication)
- Android Studio / Xcode (for mobile development) or Chrome (for web)

### For Python Backend:

- Python 3.8+
- pip (Python package manager)

## Setup Instructions

### 1. Backend Setup

1. Navigate to the backend directory:

   ```bash
   cd backend
   ```

2. Create a virtual environment (recommended):

   ```bash
   python -m venv venv
   ```

3. Activate the virtual environment:

   - **Windows (PowerShell)**:
     ```powershell
     .\venv\Scripts\Activate.ps1
     ```
   - **Windows (CMD)**:
     ```cmd
     venv\Scripts\activate.bat
     ```
   - **macOS/Linux**:
     ```bash
     source venv/bin/activate
     ```

4. Install dependencies:

   ```bash
   pip install -r requirements.txt
   ```

5. Run the backend server:

   ```bash
   python -m uvicorn app.main:app --reload --port 8000
   ```

   The API will be available at `http://127.0.0.1:8000`

   - API docs: `http://127.0.0.1:8000/docs` (Swagger UI)
   - Alternative docs: `http://127.0.0.1:8000/redoc`

### 2. Frontend Setup

1. Navigate to the project root (if not already there):

   ```bash
   cd ..
   ```

2. Install Flutter dependencies:

   ```bash
   flutter pub get
   ```

3. **Firebase Configuration** (Required for authentication):

   - Ensure `android/app/google-services.json` is present (already exists in project)
   - For iOS, configure Firebase in Xcode if needed
   - The app will show a warning banner if Firebase is not properly configured

4. Run the Flutter app:

   **For Web (Chrome)**:

   ```bash
   flutter run -d chrome
   ```

   **For Android**:

   ```bash
   flutter run -d android
   ```

   **For iOS** (macOS only):

   ```bash
   flutter run -d ios
   ```

   **For Windows**:

   ```bash
   flutter run -d windows
   ```

   **For a specific device**:

   ```bash
   flutter devices  # List available devices
   flutter run -d <device-id>
   ```

## Running Both Services

### Option 1: Run in Separate Terminals

**Terminal 1 - Backend:**

```bash
cd backend
python -m uvicorn app.main:app --reload --port 8000
```

**Terminal 2 - Frontend:**

```bash
flutter run -d chrome
```

### Option 2: Custom API URL

If your backend runs on a different port or URL, specify it when running Flutter:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

## Default Configuration

- **Backend Port**: 8000
- **API Base URL**: `http://127.0.0.1:8000`
- **Database**: SQLite (`backend/smart_search.db`)

## Features

- 🔍 Intelligent document search with autocomplete and spell correction
- 🔐 Firebase authentication (Google Sign-In)
- 📄 Document management (create, view, delete)
- 📊 Search history tracking
- ⚙️ User profile settings

## Troubleshooting

1. **Backend not connecting**: Ensure the backend is running on port 8000 before starting the Flutter app
2. **Firebase errors**: Check that `google-services.json` is properly configured for Android
3. **Port already in use**: Change the backend port and update the Flutter app's API_BASE_URL accordingly
4. **Flutter dependencies**: Run `flutter pub get` if you see missing package errors

## Development

- Backend auto-reloads on code changes (thanks to `--reload` flag)
- Flutter supports hot reload (press `r` in the terminal) and hot restart (press `R`)

## 🚀 Deployment

### First Time Setup

**Don't have this on GitHub yet?** Start here:
👉 **[GITHUB_SETUP.md](GITHUB_SETUP.md)** - Push your code to GitHub first!

### Deploy to Production

Once your code is on GitHub:
👉 **[QUICK_DEPLOY.md](QUICK_DEPLOY.md)** - Deploy in 5 minutes!

**Quick options:**

- **Frontend**: Deploy to [Vercel](https://vercel.com) (free)
- **Backend**: Deploy to [Railway](https://railway.app) (free tier)

For detailed deployment instructions, see **[DEPLOYMENT.md](DEPLOYMENT.md)**.
