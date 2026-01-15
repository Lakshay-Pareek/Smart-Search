# 📦 GitHub Setup Guide

Follow these steps to push your project to GitHub, then deploy it!

## Step 1: Initialize Git Repository

Open PowerShell/Terminal in your project folder (`C:\New folder`) and run:

```powershell
# Initialize git repository
git init

# Add all files
git add .

# Create first commit
git commit -m "Initial commit: Smart Document Search Engine"
```

---

## Step 2: Create GitHub Repository

1. **Go to GitHub:**

   - Visit https://github.com
   - Sign in (or create account if needed)

2. **Create new repository:**

   - Click the **"+"** icon (top right) → **"New repository"**
   - Repository name: `smart-document-search` (or any name you like)
   - Description: `Smart Document Search Engine - Flutter + FastAPI`
   - Choose: **Public** (required for free hosting)
   - **DO NOT** check "Initialize with README" (we already have files)
   - Click **"Create repository"**

3. **Copy the repository URL:**
   - GitHub will show you commands, but copy the URL
   - Example: `https://github.com/yourusername/smart-document-search.git`

---

## Step 3: Connect and Push to GitHub

Back in your PowerShell/Terminal, run:

```powershell
# Add GitHub as remote (replace with YOUR repository URL)
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git

# Pull remote changes first (in case GitHub created a README)
git pull origin main --allow-unrelated-histories

# Push to GitHub
git branch -M main
git push -u origin main
```

**Note:** If you get an error saying "refusing to merge unrelated histories", use:

```powershell
git pull origin main --allow-unrelated-histories
```

This merges any files GitHub created (like README.md) with your local files.

**Note:** If you get an authentication error:

- GitHub no longer accepts passwords
- Use a **Personal Access Token** instead:
  1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
  2. Generate new token → Select `repo` scope
  3. Copy the token
  4. When prompted for password, paste the token instead

---

## Step 4: Verify Upload

1. Refresh your GitHub repository page
2. You should see all your files:
   - `lib/` folder
   - `backend/` folder
   - `pubspec.yaml`
   - `README.md`
   - etc.

✅ **Your code is now on GitHub!**

---

## Step 5: Deploy (Now You Can!)

Now follow **[QUICK_DEPLOY.md](QUICK_DEPLOY.md)** to deploy:

1. **Deploy Backend (Railway):**

   - Go to https://railway.app
   - New Project → Deploy from GitHub repo
   - Select your repository
   - Deploy!

2. **Deploy Frontend (Vercel):**
   - Go to https://vercel.com
   - Add New Project → Import GitHub repo
   - Select your repository
   - Configure and deploy!

---

## 🎯 Quick Commands Summary

```powershell
# 1. Initialize Git
git init
git add .
git commit -m "Initial commit"

# 2. Connect to GitHub (replace URL with yours)
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO.git

# 3. Push to GitHub
git branch -M main
git push -u origin main
```

---

## 🔐 GitHub Authentication

If you get authentication errors:

### Option 1: Personal Access Token (Recommended)

1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token → Select `repo` scope
3. Copy token → Use as password when pushing

### Option 2: GitHub CLI

```powershell
# Install GitHub CLI
winget install GitHub.cli

# Login
gh auth login

# Then push normally
git push -u origin main
```

### Option 3: SSH Key

1. Generate SSH key: `ssh-keygen -t ed25519 -C "your_email@example.com"`
2. Add to GitHub: Settings → SSH and GPG keys → New SSH key
3. Use SSH URL: `git@github.com:YOUR-USERNAME/YOUR-REPO.git`

---

## ✅ Checklist

- [ ] Git repository initialized
- [ ] Files committed
- [ ] GitHub repository created
- [ ] Code pushed to GitHub
- [ ] Verified files are on GitHub
- [ ] Ready to deploy!

---

## 🚀 Next Steps

Once your code is on GitHub:

1. Follow **[QUICK_DEPLOY.md](QUICK_DEPLOY.md)** to deploy
2. Your app will be live in ~5 minutes!

---

**Need help?** Make sure:

- ✅ You have a GitHub account
- ✅ Repository is **Public** (for free hosting)
- ✅ All files are committed (`git status` should show "nothing to commit")
