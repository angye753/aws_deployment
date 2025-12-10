# Quick Reference Guide

## Project Status
✅ **Infrastructure Ready**: Terraform configured and validated  
✅ **Frontend Complete**: HTML, CSS, JavaScript responsive website  
✅ **CI/CD Pipeline**: GitHub Actions workflow ready  
⏳ **Deployment**: Awaiting AWS credentials  

## File Checklist

### Terraform Infrastructure
✅ `terraform/main.tf` - S3, CloudFront, IAM resources  
✅ `terraform/variables.tf` - Input variables  
✅ `terraform/outputs.tf` - Deployment outputs  
✅ `terraform/locals.tf` - Computed values  
✅ `terraform/backend.tf` - State management (optional)  
✅ `terraform/terraform.tfvars` - Configuration  

### Website Files
✅ `src/index.html` - Complete HTML structure (330 lines)  
✅ `src/css/style.css` - Base styles (700 lines)  
✅ `src/css/responsive.css` - Mobile/tablet styles (600 lines)  
✅ `src/js/main.js` - JavaScript functionality (380 lines)  
⏳ `src/assets/images/profile.jpg` - Profile photo (pending)  

### Configuration & Documentation
✅ `.gitignore` - Git exclusions  
✅ `README.md` - Comprehensive documentation  
✅ `.github/workflows/deploy.yml` - CI/CD pipeline  
✅ `IMPLEMENTATION_PROGRESS.md` - This progress report  

## Next Steps

### Step 1: Add Profile Photo (5 minutes)
```bash
# 1. Prepare your professional photo
# 2. Resize to 400x400px
# 3. Optimize to <100KB (use ImageOptim or similar)
# 4. Place at: src/assets/images/profile.jpg
# 5. Update contact links in src/index.html:
#    - Replace "https://github.com" with your GitHub
#    - Replace "mailto:your.email@example.com" with your email
```

### Step 2: Configure AWS (10 minutes)
```bash
# 1. Create AWS IAM User:
#    - Go to AWS Console → IAM → Users → Create User
#    - Enable "Access key - Programmatic access"
#    - Attach policy: AmazonS3FullAccess + CloudFrontFullAccess
#    - Copy Access Key ID and Secret Access Key

# 2. Add GitHub Secrets:
#    - Go to GitHub repo → Settings → Secrets and variables → Actions
#    - Add: AWS_ACCESS_KEY_ID
#    - Add: AWS_SECRET_ACCESS_KEY
#    - Add: AWS_REGION = eu-west-1
```

### Step 3: Test Terraform Locally (5 minutes)
```bash
cd terraform
terraform init
terraform plan
# Review plan output - should show:
# - S3 bucket creation
# - CloudFront distribution
# - IAM role (optional)
```

### Step 4: Deploy (varies)
**Option A: GitHub Actions (Recommended)**
```bash
git add .
git commit -m "Initial portfolio deployment"
git push origin main
# GitHub Actions will:
# 1. Validate Terraform
# 2. Apply infrastructure
# 3. Upload website to S3
# 4. Invalidate CloudFront cache
# Wait ~5-10 minutes for deployment to complete
```

**Option B: Manual Deployment**
```bash
cd terraform
terraform apply
# Output will show CloudFront URL
# Then manually upload website to S3:
aws s3 sync ../src/ s3://angelica-portfolio-<timestamp>/
```

### Step 5: Verify Deployment (5 minutes)
```bash
# Get CloudFront URL from Terraform output:
terraform output cloudfront_domain_name
# Visit: https://<your-cloudfront-url>
# Check:
# - Page loads
# - Mobile responsive (test in DevTools)
# - Navigation works
# - Images load
```

## Key Commands

### Terraform
```bash
cd terraform

# Initialize (first time only)
terraform init

# Check syntax
terraform validate

# Preview changes
terraform plan

# Apply infrastructure
terraform apply

# View outputs
terraform output

# Destroy infrastructure (WARNING: deletes everything)
terraform destroy
```

### AWS CLI
```bash
# View S3 bucket
aws s3 ls s3://angelica-portfolio-<timestamp>/

# Upload files to S3
aws s3 sync src/ s3://angelica-portfolio-<timestamp>/

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id <DISTRIBUTION-ID> \
  --paths "/*"

# Get CloudFront info
aws cloudfront list-distributions
```

### Git
```bash
# Stage changes
git add .

# Commit
git commit -m "Your message"

# Push to main (triggers GitHub Actions)
git push origin main

# View workflow status
gh run list
gh run view <RUN-ID>
```

## Troubleshooting

### Website not updating after push?
1. Check GitHub Actions workflow status
2. Verify CloudFront cache invalidation completed
3. Hard refresh: Cmd+Shift+R (Mac) or Ctrl+Shift+R (Windows)
4. Check S3 bucket: `aws s3 ls s3://angelica-portfolio-<timestamp>/`

### Terraform errors?
1. Run `terraform validate` to check syntax
2. Verify AWS credentials: `aws sts get-caller-identity`
3. Check GitHub secrets are set correctly
4. Review Terraform logs: `terraform plan` output

### CloudFront not serving content?
1. Verify S3 bucket policy allows CloudFront OAI
2. Check CloudFront distribution status (enabled?)
3. Verify default root object is set to `index.html`
4. Check CloudFront cache settings

### Mobile menu not working?
1. Open DevTools (F12)
2. Check Console for JavaScript errors
3. Verify JavaScript file loaded
4. Test in different browser

## Performance Targets

- ✅ Page load: < 2 seconds
- ✅ Lighthouse Performance: ≥ 90
- ✅ Lighthouse Accessibility: ≥ 90
- ✅ Lighthouse Best Practices: ≥ 90
- ✅ Lighthouse SEO: ≥ 90

**Check Performance**:
```bash
# Chrome DevTools:
# 1. Open website
# 2. F12 → Lighthouse tab
# 3. Click "Analyze page load"

# Or use CLI:
npm install -g lighthouse
lighthouse https://<your-cloudfront-url>
```

## File Sizes

| File | Size | Status |
|------|------|--------|
| index.html | ~8 KB | ✅ Optimal |
| style.css | ~28 KB | ✅ Good |
| responsive.css | ~24 KB | ✅ Good |
| main.js | ~12 KB | ✅ Good |
| profile.jpg | <100 KB | ⏳ Pending |
| **Total** | **~72 KB** | ✅ Fast |

## Deployment Timeline

| Step | Duration | Status |
|------|----------|--------|
| Add profile photo | 5 min | ⏳ Pending |
| Configure AWS | 10 min | ⏳ Pending |
| Test Terraform | 5 min | ⏳ Pending |
| Deploy via GitHub | 5-10 min | ⏳ Pending |
| Verify site | 5 min | ⏳ Pending |
| **Total** | **30-35 min** | ✅ Ready |

## Resources

- 📖 [README.md](./README.md) - Full documentation
- 📋 [IMPLEMENTATION_PROGRESS.md](./IMPLEMENTATION_PROGRESS.md) - Detailed progress
- 📝 [.specify/memory/specification.md](./.specify/memory/specification.md) - Feature spec
- 📊 [.specify/memory/plan.md](./.specify/memory/plan.md) - Implementation plan
- ✅ [.specify/memory/tasks.md](./.specify/memory/tasks.md) - Task list

## Support

### Local Testing
```bash
# Test HTML locally (no build needed)
open src/index.html

# Or run simple server
cd src
python3 -m http.server 8000
# Visit http://localhost:8000
```

### Check Syntax
```bash
# Validate HTML
# Use: https://validator.w3.org/

# Validate CSS
# Use: https://jigsaw.w3.org/css-validator/

# JavaScript
# Open DevTools → Console → look for errors
```

## Contact Info to Update

**In `src/index.html`**:
- LinkedIn: `https://www.linkedin.com/in/angélica-muñoz-59530850/`
- GitHub: `https://github.com/yourusername`
- Email: `mailto:your.email@example.com`

---

**Last Updated**: December 10, 2025  
**Status**: Ready for Final Steps (AWS Credentials + Deployment)
