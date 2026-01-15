# Deployment Guide - Free Hosting

This guide will help you deploy both the **Flutter frontend** and **FastAPI backend** for free.

## 🎯 Quick Deploy Options

### Option 1: Vercel (Frontend) + Railway (Backend) - **RECOMMENDED**

**Frontend (Vercel):**

- ✅ Free forever
- ✅ Automatic HTTPS
- ✅ Custom domain support
- ✅ Fast CDN

**Backend (Railway):**

- ✅ Free tier: $5 credit/month
- ✅ Easy Python deployment
- ✅ Automatic HTTPS
- ✅ Environment variables

---

## 📦 Step-by-Step Deployment

### Part 1: Deploy Backend (Railway)

1. **Sign up for Railway:**

   - Go to https://railway.app
   - Sign up with GitHub (free)

2. **Create a new project:**

   - Click "New Project"
   - Select "Deploy from GitHub repo"
   - Connect your GitHub account
   - Select this repository

3. **Configure Backend:**

   - Railway will auto-detect Python
   - Set root directory: `backend`
   - Add environment variables (if needed):
     ```
     DATABASE_URL=sqlite:///./smart_search.db
     ```

4. **Deploy:**

   - Railway will automatically build and deploy
   - Note the generated URL (e.g., `https://your-app.railway.app`)

5. **Get your backend URL:**
   - Copy the public URL from Railway dashboard
   - Example: `https://smart-search-backend.railway.app`

---

### Part 2: Deploy Frontend (Vercel)

#### Method A: Deploy via Vercel CLI (Recommended)

1. **Install Vercel CLI:**

   ```bash
   npm install -g vercel
   ```

2. **Build Flutter web app:**

   ```bash
   flutter build web --release --dart-define=API_BASE_URL=https://your-backend-url.railway.app
   ```

   Replace `your-backend-url.railway.app` with your actual Railway backend URL.

3. **Deploy to Vercel:**
   ```bash
   cd build/web
   vercel --prod
   ```
   - Follow the prompts
   - First time: Login and link project
   - Your app will be live at `https://your-app.vercel.app`

#### Method B: Deploy via Vercel Dashboard

1. **Sign up for Vercel:**

   - Go to https://vercel.com
   - Sign up with GitHub (free)

2. **Import project:**

   - Click "Add New Project"
   - Import your GitHub repository
   - Configure:
     - **Framework Preset**: Other
     - **Build Command**: `flutter build web --release --dart-define=API_BASE_URL=https://your-backend-url.railway.app`
     - **Output Directory**: `build/web`
     - **Install Command**: `flutter pub get`

3. **Add Environment Variable:**

   - Go to Project Settings → Environment Variables
   - Add: `API_BASE_URL` = `https://your-backend-url.railway.app`

4. **Deploy:**
   - Click "Deploy"
   - Wait for build to complete
   - Your app is live!

---

### Part 3: Update API URL in Production

After deployment, update the API URL:

1. **In Vercel Dashboard:**

   - Go to your project → Settings → Environment Variables
   - Add/Update: `API_BASE_URL` = `https://your-backend-url.railway.app`

2. **Rebuild:**
   - Go to Deployments → Redeploy latest

---

## 🚀 Alternative Free Hosting Options

### Frontend Alternatives:

#### **Netlify** (Alternative to Vercel)

1. Sign up at https://netlify.com
2. Drag & drop `build/web` folder OR connect GitHub
3. Build command: `flutter build web --release`
4. Publish directory: `build/web`

#### **Firebase Hosting** (You already have Firebase!)

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize: `firebase init hosting`
4. Build: `flutter build web --release`
5. Deploy: `firebase deploy --only hosting`

### Backend Alternatives:

#### **Render** (Alternative to Railway)

1. Sign up at https://render.com
2. New → Web Service
3. Connect GitHub repo
4. Settings:
   - Build Command: `cd backend && pip install -r requirements.txt`
   - Start Command: `cd backend && uvicorn app.main:app --host 0.0.0.0 --port $PORT`
5. Deploy!

#### **Fly.io** (Alternative)

1. Install: `curl -L https://fly.io/install.sh | sh`
2. Sign up: `fly auth signup`
3. Launch: `fly launch` (in backend folder)
4. Deploy: `fly deploy`

---

## 🔧 Post-Deployment Checklist

- [ ] Backend is accessible (test: `https://your-backend.railway.app/docs`)
- [ ] Frontend API URL is set correctly
- [ ] Firebase authentication works
- [ ] CORS is enabled on backend (already configured ✅)
- [ ] Test search functionality
- [ ] Test login/signup flow

---

## 📝 Environment Variables Reference

### Backend (Railway):

```
DATABASE_URL=sqlite:///./smart_search.db
PORT=8000
```

### Frontend (Vercel):

```
API_BASE_URL=https://your-backend-url.railway.app
```

---

## 🐛 Troubleshooting

### Backend Issues:

- **CORS errors**: Backend already has CORS enabled for all origins
- **Database errors**: SQLite file is created automatically
- **Port issues**: Railway sets `PORT` automatically

### Frontend Issues:

- **API not connecting**: Check `API_BASE_URL` environment variable
- **Firebase errors**: Verify Firebase config in `firebase_options.dart`
- **Build fails**: Run `flutter clean` then rebuild

---

## 🎉 You're Done!

Your app should now be live at:

- **Frontend**: `https://your-app.vercel.app`
- **Backend API**: `https://your-backend.railway.app`
- **API Docs**: `https://your-backend.railway.app/docs`

Share the frontend URL with your interviewer! 🚀
