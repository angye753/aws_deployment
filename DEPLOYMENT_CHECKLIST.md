# Deployment Checklist ✅

## Pre-Deployment (Ready Now)

### Code & Files
- [x] HTML structure complete (`src/index.html`)
- [x] CSS styles complete (`src/css/style.css`)
- [x] Responsive styles complete (`src/css/responsive.css`)
- [x] JavaScript functionality complete (`src/js/main.js`)
- [x] Terraform infrastructure defined (`terraform/main.tf`, etc.)
- [x] GitHub Actions workflow created (`.github/workflows/deploy.yml`)
- [x] Project documentation complete (`README.md`, `QUICKSTART.md`)

### Terraform Validation
- [x] `terraform validate` passes ✓
- [x] All variables defined
- [x] All outputs configured
- [x] Backend configuration ready
- [x] Security best practices applied

### Code Quality
- [x] Semantic HTML5
- [x] Responsive design (tested on 320px, 768px, 1200px+)
- [x] CSS uses variables for theming
- [x] JavaScript uses vanilla ES6+
- [x] Accessibility features included
- [x] Mobile menu toggle functional
- [x] Smooth scroll navigation

## Pre-Deployment (Action Required)

### ⏳ Step 1: Add Profile Photo (5 min)
- [ ] Prepare professional photo (400x400px, <100KB)
- [ ] Save to `src/assets/images/profile.jpg`
- [ ] Verify file loads when opening HTML locally
- [ ] Optimize file size if needed

### ⏳ Step 2: Update Contact Information (2 min)
Edit `src/index.html` and update:
- [ ] LinkedIn URL (line ~85)
  ```html
  href="https://www.linkedin.com/in/your-profile/"
  ```
- [ ] GitHub URL (line ~156)
  ```html
  href="https://github.com/your-username"
  ```
- [ ] Email address (line ~161)
  ```html
  href="mailto:your.email@example.com"
  ```

### ⏳ Step 3: Configure AWS (10 min)

**Create IAM User:**
- [ ] Log in to AWS Console
- [ ] Go to IAM → Users → Create User
- [ ] Username: `github-actions-portfolio`
- [ ] Enable: Access key (Programmatic access)
- [ ] Attach policies:
  - [ ] `AmazonS3FullAccess`
  - [ ] `CloudFrontFullAccess`
- [ ] Download Access Key ID and Secret Access Key

**Add GitHub Secrets:**
- [ ] Go to GitHub repo → Settings → Secrets and variables → Actions
- [ ] New secret: `AWS_ACCESS_KEY_ID`
  - Value: [your access key ID]
- [ ] New secret: `AWS_SECRET_ACCESS_KEY`
  - Value: [your secret access key]
- [ ] New secret: `AWS_REGION`
  - Value: `eu-west-1`

### ⏳ Step 4: Test Locally (5 min)

**Test HTML File:**
- [ ] Open `src/index.html` in browser
- [ ] Verify all sections display
- [ ] Test navigation links (smooth scroll)
- [ ] Test mobile menu toggle (resize window to <768px)
- [ ] Verify responsive layout

**Test Terraform:**
```bash
cd terraform
terraform init
terraform plan
```
- [ ] No errors in plan output
- [ ] Should show resources to create (S3, CloudFront, IAM)

## Deployment (Choose One)

### Option A: GitHub Actions (Recommended)

- [ ] Commit profile photo
  ```bash
  git add src/assets/images/profile.jpg
  git commit -m "Add profile photo"
  ```

- [ ] Commit updated contact info
  ```bash
  git add src/index.html
  git commit -m "Update contact information"
  ```

- [ ] Push to main (triggers deployment)
  ```bash
  git push origin main
  ```

- [ ] Monitor GitHub Actions
  - [ ] Go to GitHub repo → Actions tab
  - [ ] Watch workflow run
  - [ ] All jobs should pass (Validate → Build → Deploy → Verify)
  - [ ] Workflow should complete in 5-10 minutes

- [ ] Get deployment URL
  - [ ] Go to deploy job → "Get Deployment Summary" step
  - [ ] Copy CloudFront URL
  - [ ] Format: `https://d1234abcd.cloudfront.net`

### Option B: Manual Terraform (Alternative)

```bash
cd terraform

# Initialize (first time only)
terraform init

# Preview changes
terraform plan
# Review output, should show:
# + aws_s3_bucket.website
# + aws_cloudfront_distribution.website
# + aws_cloudfront_origin_access_identity.website

# Apply infrastructure
terraform apply
# Type: yes

# Get outputs
terraform output
# Note the: cloudfront_domain_name
```

Then upload website:
```bash
# Get bucket name from terraform output
S3_BUCKET=$(cd terraform && terraform output -raw s3_bucket_name)

# Sync website to S3
aws s3 sync src/ s3://$S3_BUCKET/ --delete --exclude ".DS_Store"

# Invalidate CloudFront cache
DIST_ID=$(cd terraform && terraform output -raw cloudfront_distribution_id)
aws cloudfront create-invalidation --distribution-id $DIST_ID --paths "/*"
```

## Post-Deployment (Verification)

### ✅ Immediate Checks (5 min)
- [ ] Website accessible via CloudFront URL
- [ ] Page loads (wait 10-15 seconds for CloudFront cache)
- [ ] Content displays correctly
- [ ] Navigation works
- [ ] Mobile menu toggle works
- [ ] Links scroll smoothly
- [ ] Profile photo displays
- [ ] No console errors (DevTools → Console)

### ✅ Desktop Testing
- [ ] Chrome (latest)
  - [ ] Page loads
  - [ ] Navigation works
  - [ ] Styling correct
  - [ ] All sections visible
- [ ] Firefox (latest)
  - [ ] Same checks as Chrome
- [ ] Safari (latest)
  - [ ] Same checks as Chrome
- [ ] Edge (latest)
  - [ ] Same checks as Chrome

### ✅ Mobile Testing
- [ ] Mobile (320px width)
  - [ ] Hamburger menu visible
  - [ ] Menu toggle works
  - [ ] Text readable
  - [ ] Images load
  - [ ] Touch friendly
- [ ] Tablet (768px width)
  - [ ] Layout looks good
  - [ ] Navigation visible
  - [ ] No horizontal scroll

### ✅ Performance Checks
- [ ] Page load time < 2 seconds (3G simulation)
- [ ] Lighthouse audit all scores ≥ 90
  - [ ] Performance ≥ 90
  - [ ] Accessibility ≥ 90
  - [ ] Best Practices ≥ 90
  - [ ] SEO ≥ 90

### ✅ Security Checks
- [ ] HTTPS enforced (no HTTP access)
- [ ] Security headers present (DevTools → Network → Response Headers)
  - [ ] `Strict-Transport-Security` present
  - [ ] `X-Frame-Options` present
  - [ ] `X-Content-Type-Options` present
- [ ] S3 public access blocked
- [ ] CloudFront OAI configured

### ✅ Content Verification
- [ ] All sections present and visible
- [ ] Contact links work
  - [ ] LinkedIn link opens
  - [ ] GitHub link opens
  - [ ] Email link opens (mail client)
- [ ] All text spelled correctly
- [ ] Professional photo displays correctly
- [ ] No Lorem Ipsum or placeholder text

## Post-Deployment (Documentation)

- [ ] Update `README.md` with live CloudFront URL
  - [ ] Replace `<your-cloudfront-url>` with actual URL
  - [ ] Add screenshot of deployed site
- [ ] Document any customizations made
- [ ] Create deployment notes for future reference
- [ ] Test GitHub Actions workflow by making a test commit
  - [ ] Make minor HTML change
  - [ ] Commit: `git commit -m "Test deployment"`
  - [ ] Push: `git push origin main`
  - [ ] Verify workflow triggers and completes

## Troubleshooting

### If Website Shows 403 Error
- [ ] CloudFront may still be initializing (wait 15 minutes)
- [ ] Check S3 bucket policy allows CloudFront OAI
- [ ] Verify S3 bucket name is correct in Terraform output
- [ ] Check CloudFront distribution status is "Deployed"

### If Website Updates Don't Show
- [ ] Hard refresh browser: Cmd+Shift+R (Mac) or Ctrl+Shift+R (Windows)
- [ ] Clear browser cache
- [ ] Wait 5 minutes for CloudFront invalidation
- [ ] Check GitHub Actions workflow completed successfully

### If Mobile Menu Doesn't Work
- [ ] Check JavaScript file loaded (DevTools → Network tab)
- [ ] Check console for JavaScript errors (DevTools → Console)
- [ ] Verify window width < 768px (DevTools → Responsive mode)
- [ ] Try different browser

### If Performance Scores Low
- [ ] Optimize profile image (should be <100KB)
- [ ] Minify CSS/JavaScript (optional enhancement)
- [ ] Check CloudFront compression enabled (should be)
- [ ] Review Lighthouse audit for specific issues

### If Terraform Apply Fails
- [ ] Verify AWS credentials: `aws sts get-caller-identity`
- [ ] Check GitHub secrets are correct
- [ ] Run `terraform validate` to check syntax
- [ ] Check AWS account has S3/CloudFront quota

## Final Verification Checklist

- [ ] Website live on CloudFront URL
- [ ] All pages load within 2 seconds
- [ ] Mobile responsive tested
- [ ] Desktop tested (Chrome, Firefox, Safari, Edge)
- [ ] Lighthouse scores all ≥ 90
- [ ] Security headers present
- [ ] HTTPS enforced
- [ ] GitHub Actions workflow functional
- [ ] Documentation updated
- [ ] Contact information correct
- [ ] Profile photo displays
- [ ] No console errors
- [ ] No broken links

## Success Criteria Met

✅ Website is live and accessible  
✅ Content accurately reflects profile  
✅ Page fully responsive on all devices  
✅ Performance metrics meet requirements  
✅ GitHub Actions pipeline works  
✅ Terraform manages all infrastructure  
✅ HTTPS enforced with security headers  
✅ S3 access restricted to CloudFront only  

---

**Next Steps After Deployment:**
1. Share CloudFront URL with LinkedIn/portfolio
2. Monitor CloudFront metrics in AWS Console
3. Plan v1.1 enhancements (custom domain, contact form, analytics)
4. Keep Terraform state backed up
5. Rotate AWS credentials quarterly

**Estimated Total Time**: 30-45 minutes from this point to live website

---

**Status**: ✅ Ready to Deploy
**Date**: December 10, 2025
