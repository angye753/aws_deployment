# S3 Upload Timeline - When HTML Files Get Deployed

## 📋 Task Mapping

### **T025: Deploy Job (GitHub Actions Workflow)**

This is where HTML files are uploaded to S3. It happens in the **Deploy Job** of your GitHub Actions workflow (`.github/workflows/deploy.yml`)

---

## 🔄 Deployment Flow

```
GITHUB PUSH (main branch)
    ↓
VALIDATE JOB (checks Terraform syntax)
    ↓
BUILD JOB (verifies HTML/CSS/JS files exist)
    ↓
DEPLOY JOB (T025 - THIS IS WHERE S3 UPLOAD HAPPENS!)
    ├─ Step 1: Terraform Apply (creates S3 + CloudFront)
    ├─ Step 2: Download Website Files (HTML, CSS, JS)
    ├─ Step 3: ⭐ UPLOAD TO S3 ⭐
    └─ Step 4: Invalidate CloudFront Cache
    ↓
VERIFY JOB (tests website is accessible)
    ↓
✅ DONE - Website is live!
```

---

## 📝 Detailed: S3 Upload Step (T025)

**Workflow File**: `.github/workflows/deploy.yml`  
**Job**: `deploy`  
**Step**: `Upload Website to S3`  
**Lines**: 153-169 (approximately)

### What Happens:

```yaml
- name: Upload Website to S3
  env:
    S3_BUCKET: ${{ steps.deploy-info.outputs.s3_bucket }}
  run: |
    # Get S3 bucket name from Terraform output
    cd terraform
    S3_BUCKET=$(terraform output -raw s3_bucket_name)
    cd ..
    
    echo "Uploading website to S3 bucket: $S3_BUCKET"
    aws s3 sync website-build/ s3://$S3_BUCKET/ \
      --delete \
      --cache-control "public, max-age=3600" \
      --exclude ".DS_Store" \
      --exclude "*.git*"
    
    echo "✓ Website uploaded to S3"
```

### Files Uploaded:
- `src/index.html` → S3 bucket root
- `src/css/style.css` → S3 bucket `css/` folder
- `src/css/responsive.css` → S3 bucket `css/` folder
- `src/js/main.js` → S3 bucket `js/` folder
- `src/assets/images/profile.jpg` → S3 bucket `assets/images/` folder

### S3 Bucket Target:
```
Bucket: angelica-portfolio-production-345594607466
Bucket URL: s3://angelica-portfolio-production-345594607466/
```

### Cache Control:
```
--cache-control "public, max-age=3600"
```
This sets HTML/CSS/JS to cache for **1 hour (3600 seconds)**

---

## 🔐 How T025 Gets Triggered

**Automatic Trigger (Recommended)**:
```bash
git push origin main
```
This automatically triggers:
1. Validate job
2. Build job  
3. Deploy job (T025 runs here)
4. Verify job

**Manual Trigger (For Testing)**:
1. GitHub repo → Actions tab
2. Select "Deploy Portfolio Website"
3. Click "Run workflow"
4. Watch T025 execute in the Deploy job

---

## ⚠️ What's Blocking T025 Right Now?

**GitHub Secrets Not Configured**

T025 cannot run until these are added to GitHub Secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

**How to fix** (10 minutes):

1. **Create IAM User in AWS**:
   ```
   AWS Console → IAM → Users → Create User
   Username: github-actions-portfolio
   Enable: Programmatic access
   Attach policies: AmazonS3FullAccess + CloudFrontFullAccess
   ```

2. **Get Access Keys**:
   - Copy: Access Key ID
   - Copy: Secret Access Key (only shown once!)

3. **Add GitHub Secrets**:
   ```
   GitHub repo → Settings → Secrets and variables → Actions
   
   New secret:
   Name: AWS_ACCESS_KEY_ID
   Value: (paste your key ID)
   
   New secret:
   Name: AWS_SECRET_ACCESS_KEY
   Value: (paste your secret key)
   
   New secret:
   Name: AWS_REGION
   Value: eu-west-1
   ```

4. **Then T025 will work**:
   ```bash
   git push origin main
   # GitHub Actions will now:
   # 1. Run validate
   # 2. Run build
   # 3. Run deploy ← T025 uploads HTML here!
   # 4. Run verify
   ```

---

## 🎯 Alternative: Manual S3 Upload (Without GitHub Actions)

If you want to upload files WITHOUT using GitHub Actions, you can do it manually:

```bash
cd /Users/angye/Documents/projecto\ personal/aws_deploy_with_tf

# Configure AWS credentials (one time)
aws configure

# Upload website files to S3
aws s3 sync src/ s3://angelica-portfolio-production-345594607466/ \
  --delete \
  --cache-control "max-age=3600" \
  --exclude ".DS_Store" \
  --exclude "*.psd"

# Invalidate CloudFront cache (so new files appear)
aws cloudfront create-invalidation \
  --distribution-id E28O24O650JRRY \
  --paths "/*"
```

**This does the same thing T025 does, but manually**

---

## 📊 Summary

| When | How | Where | Status |
|------|-----|-------|--------|
| **T025** | GitHub Actions workflow | Deploy job step 3 | ⛔ Blocked (no credentials) |
| **Manual** | AWS CLI command | Your terminal | ✅ Ready (after credentials) |
| **Result** | Both do the same thing | S3 bucket | Files uploaded to CloudFront |

---

## 🚀 Next Steps

**Choose one option**:

### Option A: Configure Credentials & Use GitHub Actions (Recommended)
1. Create IAM user in AWS
2. Add GitHub Secrets (10 minutes)
3. `git push origin main`
4. GitHub Actions runs → T025 uploads files automatically ✅

### Option B: Configure Credentials & Upload Manually
1. Create IAM user in AWS
2. Run `aws configure`
3. Run `aws s3 sync src/ s3://bucket/`
4. Files uploaded manually ✅

Both approaches upload the same files to the same S3 bucket. Option A is better because GitHub Actions automates it for future updates.

---

**Blockers Remaining**:
- ⛔ AWS credentials not configured
- ⏳ Profile photo not added (but this doesn't block T025)

**After credentials are added**, T025 can run immediately!

