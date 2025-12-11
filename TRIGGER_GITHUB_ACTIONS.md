# ✅ Triggering GitHub Actions Deployment

**Time**: December 10, 2025  
**Status**: Secrets configured ✅  
**Next Action**: Trigger GitHub Actions workflow

## How to Test GitHub Actions (Choose One Option)

### Option 1: Manual Trigger (Recommended for Testing)

1. Go to your GitHub repository
2. Click **Actions** tab (top menu)
3. Select **"Deploy Portfolio Website"** workflow (left sidebar)
4. Click **"Run workflow"** button
5. Select **Branch**: `main`
6. Click **"Run workflow"** (green button)

**This will immediately start the workflow without needing to push code.**

### Option 2: Trigger via Code Push

```bash
cd /Users/angye/Documents/projecto\ personal/aws_deploy_with_tf

# Make a small change
echo "# Deployment test at $(date)" >> README.md

# Commit and push
git add .
git commit -m "Trigger GitHub Actions deployment"
git push origin main
```

**This automatically triggers the workflow when you push to main branch.**

---

## 📊 What GitHub Actions Will Do

When the workflow runs (with your secrets configured):

```
1️⃣  Validate Job
   ├─ Checkout code
   ├─ Setup Terraform
   ├─ Validate Terraform syntax
   ├─ Run terraform plan
   └─ ✅ Should PASS

2️⃣  Build Job (Depends on Validate)
   ├─ Check HTML/CSS/JS files exist
   ├─ Verify basic HTML structure
   └─ ✅ Should PASS

3️⃣  Deploy Job (Depends on Validate + Build) ⭐ THIS IS WHERE S3 UPLOAD HAPPENS
   ├─ Checkout code
   ├─ Configure AWS Credentials (using GitHub Secrets!)
   ├─ Setup Terraform
   ├─ Terraform Apply (creates S3 + CloudFront)
   ├─ Upload website to S3 ← HTML/CSS/JS uploaded here!
   ├─ Invalidate CloudFront cache
   └─ ✅ Should PASS

4️⃣  Verify Job (Depends on Deploy)
   ├─ Check website is accessible
   ├─ Verify CloudFront responding
   └─ ✅ Should PASS
```

---

## 🔍 Monitor the Workflow

After triggering, watch it run:

1. Go to **Actions** tab in GitHub
2. See your workflow at the top (most recent run)
3. Click on it to see detailed view
4. Watch each job execute in real-time
5. Check "Deploy" job step: "Upload Website to S3"

---

## ⏱️ Expected Timeline

```
Validate Job    ~30 seconds
Build Job       ~20 seconds (waits for Validate)
Deploy Job      ~2-3 minutes (waits for Build, includes Terraform)
Verify Job      ~30 seconds (waits for Deploy)
─────────────────────────────
TOTAL           ~4 minutes
```

---

## ✅ Signs of Success

When everything works:

- ✅ All 4 jobs show green checkmarks
- ✅ Deploy job shows "Upload Website to S3" step completed
- ✅ No red error messages
- ✅ Workflow completes in ~4 minutes

---

## ⚠️ If Something Fails

**Common Issues**:

1. **Validate job fails**
   - Check Terraform syntax errors
   - Run locally: `cd terraform && terraform validate`

2. **Deploy job fails with "InvalidAccessKeyId"**
   - Secrets not configured correctly
   - Check GitHub Settings → Secrets → Actions
   - Verify all 3 secrets exist

3. **Deploy job fails with "Access Denied"**
   - IAM user missing permissions
   - Add: AmazonS3FullAccess + CloudFrontFullAccess

4. **CloudFront URL shows 403 error**
   - Infrastructure just deployed (takes 5-15 min)
   - Wait 15 minutes and refresh

---

## 🌐 After Deployment Succeeds

Website should be live at:
```
https://d3c51wrd8l12oc.cloudfront.net
```

**What will you see?**
- Empty page (no HTML files uploaded yet)
- OR your portfolio website (if this is a re-deployment)

**Why might it be empty?**
- HTML files were just uploaded for first time
- CloudFront needs 5-15 min to distribute
- Hard refresh might be needed (Cmd+Shift+R)

---

## 📝 Next Steps After Deployment

Once GitHub Actions succeeds:

1. ✅ T025: Deploy job completed
2. ⏳ T019: Run Lighthouse audit on `https://d3c51wrd8l12oc.cloudfront.net`
3. ⏳ T020: Test responsive design on deployed site
4. ⏳ T018: Validate HTML/accessibility
5. ⏳ T016: Add profile photo (still pending)

---

**Ready to trigger?** Go to GitHub Actions → "Deploy Portfolio Website" → "Run workflow" 🚀

