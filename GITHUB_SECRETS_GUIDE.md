# How to Add GitHub Secrets (Step-by-Step Guide)

## 📋 What You Need Before Starting

Before you add secrets to GitHub, you need AWS credentials:

1. **AWS Access Key ID** - looks like: `AKIAIOSFODNN7EXAMPLE`
2. **AWS Secret Access Key** - looks like: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`
3. **AWS Region** - value: `eu-west-1`

If you don't have these yet, see **"Getting AWS Credentials"** section below.

---

## 🚀 Step-by-Step: Add Secrets to GitHub

### Step 1: Go to Your GitHub Repository

1. Open GitHub in your browser
2. Go to your repository
3. Click **Settings** (tab at the top)

```
https://github.com/YOUR_USERNAME/YOUR_REPO/settings
```

---

### Step 2: Navigate to Secrets

1. In the left sidebar, find **Security** section
2. Click **Secrets and variables**
3. Click **Actions**

**Path**: Settings → Security → Secrets and variables → Actions

---

### Step 3: Add First Secret (AWS_ACCESS_KEY_ID)

1. Click **"New repository secret"** button (green button)
2. **Name**: `AWS_ACCESS_KEY_ID` (exactly as written, including underscores)
3. **Secret**: Paste your AWS Access Key ID
4. Click **"Add secret"**

**Example**:
```
Name:   AWS_ACCESS_KEY_ID
Value:  AKIAIOSFODNN7EXAMPLE
```

---

### Step 4: Add Second Secret (AWS_SECRET_ACCESS_KEY)

1. Click **"New repository secret"** button again
2. **Name**: `AWS_SECRET_ACCESS_KEY` (exactly as written)
3. **Secret**: Paste your AWS Secret Access Key
4. Click **"Add secret"**

**Example**:
```
Name:   AWS_SECRET_ACCESS_KEY
Value:  wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

---

### Step 5: Add Third Secret (AWS_REGION)

1. Click **"New repository secret"** button one more time
2. **Name**: `AWS_REGION` (exactly as written)
3. **Secret**: `eu-west-1`
4. Click **"Add secret"**

**Example**:
```
Name:   AWS_REGION
Value:  eu-west-1
```

---

## ✅ Verify Secrets Were Added

After adding all 3 secrets, you should see:

```
Actions secrets
├── AWS_ACCESS_KEY_ID      (1 day ago)
├── AWS_SECRET_ACCESS_KEY  (a few seconds ago)
└── AWS_REGION             (a few seconds ago)
```

All three secrets should appear in the list with timestamps.

---

## 🔐 Getting AWS Credentials (If You Don't Have Them Yet)

### Create IAM User in AWS Console

1. **Log in to AWS Console**: https://console.aws.amazon.com

2. **Go to IAM**:
   - Search for "IAM" in the search bar
   - Click on **IAM** service

3. **Create New User**:
   - Left sidebar → Click **Users**
   - Click **Create user** button
   - **User name**: `github-actions-portfolio`
   - Click **Next**

4. **Set Permissions**:
   - Select **Attach policies directly**
   - Search for and select these policies:
     - ☑️ `AmazonS3FullAccess`
     - ☑️ `CloudFrontFullAccess`
   - Click **Next**

5. **Review**:
   - Click **Create user**

6. **Get Access Keys**:
   - Click on the user you just created
   - Go to **Security credentials** tab
   - Scroll down to **Access keys** section
   - Click **Create access key**
   - Select **Command Line Interface (CLI)**
   - Check ☑️ "I understand..."
   - Click **Next**

7. **Save Your Keys**:
   - You'll see:
     - **Access Key ID**: `AKIA...` (copy this)
     - **Secret Access Key**: `wJal...` (copy this)
   - ⚠️ **IMPORTANT**: Copy both keys NOW - you won't see the secret key again!
   - Click **Done**

---

## 💾 Optional: Save Keys Locally (Safe Way)

Create a text file to store temporarily (delete after adding to GitHub):

```bash
# DO NOT commit this to Git!
cat > ~/aws_credentials_temp.txt << 'EOF'
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=wJal...
AWS_REGION=eu-west-1
EOF

# After adding to GitHub Secrets, delete this file:
rm ~/aws_credentials_temp.txt
```

---

## 🔍 Verify Secrets Work (After Adding)

Once secrets are added, GitHub Actions can use them automatically. To test:

1. Make a small change to your code:
   ```bash
   echo "# Test" >> README.md
   ```

2. Commit and push:
   ```bash
   git add .
   git commit -m "Test GitHub Actions"
   git push origin main
   ```

3. Watch GitHub Actions run:
   - Go to your repo → **Actions** tab
   - Click on the workflow run
   - Should see:
     - ✅ Validate job passes
     - ✅ Build job passes
     - ✅ Deploy job runs (this uses your secrets!)

If Deploy job fails, check error messages - usually means:
- Secrets not configured correctly
- Access Key ID/Secret Key are wrong
- User doesn't have S3/CloudFront permissions

---

## ⚠️ Security Best Practices

✅ **DO**:
- Store secrets in GitHub Secrets (encrypted)
- Use minimal IAM permissions
- Rotate keys periodically
- Delete local copies of credentials after adding to GitHub

❌ **DON'T**:
- Commit credentials to Git
- Share credentials via email/chat
- Use root AWS account
- Store plaintext secrets in files

---

## 🆘 Troubleshooting

### Problem: "Secret not found" error in GitHub Actions

**Solution**: 
- Check spelling exactly matches: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`
- Make sure you're in the correct repo (Settings → Secrets)
- Refresh the page and try again

### Problem: "Access Denied" when deploying

**Possible causes**:
1. IAM user doesn't have S3FullAccess permission
2. IAM user doesn't have CloudFrontFullAccess permission
3. Access Key or Secret Key is wrong
4. Secret Key was pasted with extra spaces

**Solution**:
- Delete the secret and re-add it
- Double-check AWS IAM user has correct permissions
- Create a new Access Key and use that instead

### Problem: Secret appears blank or shows only asterisks

**This is normal!** GitHub hides secret values for security. The asterisks mean it's stored correctly.

---

## 📝 Quick Reference Checklist

After completing all steps, you should have:

- [ ] AWS Access Key ID (from IAM user)
- [ ] AWS Secret Access Key (from IAM user)
- [ ] GitHub Secrets added:
  - [ ] `AWS_ACCESS_KEY_ID` = `AKIA...`
  - [ ] `AWS_SECRET_ACCESS_KEY` = `wJal...`
  - [ ] `AWS_REGION` = `eu-west-1`
- [ ] All 3 secrets visible in Settings → Secrets
- [ ] Local credential files deleted
- [ ] Ready to deploy! 🚀

---

## 🎯 What Happens After Secrets Are Added

Once secrets are configured, GitHub Actions can:

1. ✅ Access your AWS account securely
2. ✅ Run Terraform to manage infrastructure
3. ✅ Upload website files to S3 bucket
4. ✅ Invalidate CloudFront cache
5. ✅ Deploy updates automatically on every `git push`

**No more manual AWS CLI commands needed!** 🎉

---

## 📞 Next Steps

After adding all 3 secrets:

1. **Test deployment**:
   ```bash
   git push origin main
   ```

2. **Watch GitHub Actions**:
   - Go to Actions tab
   - See workflow run in progress
   - Wait for Deploy job to complete

3. **Visit your website**:
   - CloudFront URL: `https://d3c51wrd8l12oc.cloudfront.net`
   - Should see your portfolio website!

---

**Questions?** Check the troubleshooting section or refer to NEXT_STEPS.md

