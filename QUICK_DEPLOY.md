# 🚀 Quick Deployment Guide (5 Minutes)

Deploy your app for free in 5 minutes!

## Step 1: Deploy Backend (Railway) - 2 minutes

1. Go to https://railway.app and sign up with GitHub
2. Click **"New Project"** → **"Deploy from GitHub repo"**
3. Select your repository
4. Railway auto-detects Python - click **"Deploy"**
5. Wait ~2 minutes for deployment
6. **Copy the public URL** (e.g., `https://smart-search-backend.railway.app`)

✅ Backend is live! Test it: `https://your-backend.railway.app/docs`

---

## Step 2: Deploy Frontend (Vercel) - 3 minutes

### Option A: Via Vercel Dashboard (Easiest)

1. Go to https://vercel.com and sign up with GitHub
2. Click **"Add New Project"**
3. Import your GitHub repository
4. Configure:
   - **Framework Preset**: Other
   - **Build Command**:
     ```
     flutter pub get && flutter build web --release --dart-define=API_BASE_URL=https://YOUR-BACKEND-URL.railway.app
     ```
     (Replace `YOUR-BACKEND-URL` with your Railway URL from Step 1)
   - **Output Directory**: `build/web`
   - **Install Command**: `flutter pub get`
5. Click **"Deploy"**
6. Wait ~3 minutes

✅ Frontend is live! Your app URL: `https://your-app.vercel.app`

### Option B: Via Command Line

```bash
# Install Vercel CLI
npm install -g vercel

# Build Flutter app (replace with your Railway backend URL)
flutter build web --release --dart-define=API_BASE_URL=https://your-backend.railway.app

# Deploy
cd build/web
vercel --prod
```

---

## Step 3: Update Environment Variables (If needed)

If you need to change the backend URL later:

1. Go to Vercel Dashboard → Your Project → Settings → Environment Variables
2. Add: `API_BASE_URL` = `https://your-backend.railway.app`
3. Redeploy

---

## ✅ Done!

Your app is now live:

- **Frontend**: `https://your-app.vercel.app` ← Share this with interviewer!
- **Backend API**: `https://your-backend.railway.app`
- **API Docs**: `https://your-backend.railway.app/docs`

---

## 🎯 What to Test

1. ✅ Open frontend URL in browser
2. ✅ Try login/signup (Firebase auth)
3. ✅ Search for documents
4. ✅ Check profile shows your name
5. ✅ Test local storage (cache documents)

---

## 💡 Pro Tips

- **Railway** gives $5 free credit/month (plenty for demo)
- **Vercel** is free forever for personal projects
- Both auto-deploy on git push (after initial setup)
- Custom domains available (optional)

---

## 🆘 Troubleshooting

**Backend not working?**

- Check Railway logs: Dashboard → Your Service → Logs
- Verify URL is accessible: Open `https://your-backend.railway.app/docs`

**Frontend can't connect to backend?**

- Verify `API_BASE_URL` in build command matches Railway URL
- Check browser console for CORS errors (shouldn't happen - backend has CORS enabled)

**Build fails?**

- Make sure Flutter is installed: `flutter doctor`
- Try: `flutter clean && flutter pub get`

---

Need help? Check `DEPLOYMENT.md` for detailed instructions!
