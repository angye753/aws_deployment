# Angélica Muñoz - Developer Portfolio Website

A modern, responsive single-page portfolio website showcasing professional experience, skills, and background. Deployed on AWS S3 with CloudFront CDN using Terraform infrastructure-as-code and GitHub Actions CI/CD.

## 🚀 Features

- **Responsive Design**: Mobile-first design works perfectly on all devices (320px to 1920px+)
- **Fast Loading**: < 2 seconds page load time, Lighthouse scores ≥ 90
- **Infrastructure as Code**: 100% Terraform management, no manual AWS changes
- **Automated Deployment**: Push to main branch → automatic deployment via GitHub Actions
- **Secure**: HTTPS enforced, S3 public access blocked, minimal IAM permissions
- **Professional Profile**: Comprehensive sections for about, skills, experience, and contact

## 📋 Project Structure

```
aws_deploy_with_tf/
├── terraform/                  # Infrastructure as Code
│   ├── main.tf                # S3, CloudFront, IAM resources
│   ├── variables.tf           # Input variable definitions
│   ├── outputs.tf             # Output values
│   ├── locals.tf              # Local computed values
│   ├── backend.tf             # State management (S3 + DynamoDB)
│   └── terraform.tfvars       # Configuration values (non-sensitive)
│
├── src/                        # Website source files
│   ├── index.html             # Main portfolio page
│   ├── css/
│   │   ├── style.css          # Base styles
│   │   └── responsive.css     # Mobile/tablet responsive styles
│   ├── js/
│   │   └── main.js            # Interactive functionality
│   └── assets/
│       └── images/
│           └── profile.jpg    # Professional profile photo
│
├── .github/
│   └── workflows/
│       └── deploy.yml         # GitHub Actions CI/CD pipeline
│
├── .specify/
│   └── memory/
│       ├── constitution.md    # Project constitution
│       ├── specification.md   # Feature specification
│       ├── plan.md            # Implementation plan
│       └── tasks.md           # Task breakdown
│
├── README.md                  # This file
├── .gitignore                 # Git ignore rules
└── LICENSE                    # Project license (optional)
```

## 📦 Tech Stack

- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Infrastructure**: Terraform 1.0+, AWS (S3, CloudFront, IAM)
- **CI/CD**: GitHub Actions
- **Target**: AWS eu-west-1 (Ireland) region

## 🏃 Quick Start

### Prerequisites

- AWS Account with appropriate IAM permissions
- AWS CLI configured with credentials
- Terraform 1.0+ installed
- Git installed
- GitHub account with repository access

### Local Development (No Build Step Required)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd aws_deploy_with_tf
   ```

2. **View the website locally** (no build needed - open directly)
   ```bash
   # Simply open src/index.html in your browser
   open src/index.html
   ```

3. **Edit content** as needed in `src/index.html`, `src/css/`, `src/js/`

4. **Test changes locally** before pushing to main

### AWS Setup

1. **Create AWS IAM User for GitHub Actions**
   ```bash
   # Create a new IAM user with programmatic access
   # Attach inline policy with S3 and CloudFront permissions (see terraform/main.tf for exact policy)
   ```

2. **Configure GitHub Secrets** (in repository settings)
   ```
   AWS_ACCESS_KEY_ID: <your-access-key>
   AWS_SECRET_ACCESS_KEY: <your-secret-key>
   AWS_REGION: eu-west-1
   ```

3. **Create S3 bucket for Terraform state** (optional but recommended)
   ```bash
   # See terraform/backend.tf for state bucket configuration
   # Enable versioning and encryption
   ```

## 🚀 Deployment

### Option 1: Automatic Deployment (Recommended)

Simply push code to the `main` branch:

```bash
git add .
git commit -m "Update portfolio content"
git push origin main
```

GitHub Actions will automatically:
1. Validate Terraform configuration
2. Apply infrastructure changes
3. Upload website files to S3
4. Invalidate CloudFront cache
5. Website goes live

**Status**: Check `.github/workflows` for workflow runs and logs

### Option 2: Manual Deployment (Development Only)

```bash
cd terraform
terraform plan
terraform apply
```

Then manually upload files to S3:
```bash
aws s3 sync src/ s3://angelica-portfolio-<timestamp>/ --exclude "*/.gitkeep"
aws cloudfront create-invalidation --distribution-id <DISTRIBUTION-ID> --paths "/*"
```

## 🔧 Terraform Configuration

### Variables

Configure in `terraform/terraform.tfvars`:

```hcl
project_name = "angelica-portfolio"
environment  = "production"
aws_region   = "eu-west-1"
enable_versioning = true
```

### Terraform Commands

```bash
cd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan

# Apply changes
terraform apply

# View outputs (CloudFront URL)
terraform output

# Destroy infrastructure (use with caution!)
terraform destroy
```

### Outputs

After applying Terraform, you'll get:
- `s3_bucket_name`: Name of your S3 bucket
- `cloudfront_domain_name`: Your website URL
- `cloudfront_distribution_id`: For cache invalidation

### Remote Backend Configuration (S3 + DynamoDB)

For production deployments, use a remote backend to enable:
- **Team Collaboration**: Shared state file across team members
- **State Locking**: DynamoDB prevents concurrent modifications
- **Encryption**: Sensitive data encrypted at rest
- **Versioning**: S3 versioning allows rollback to previous states

#### Setup Remote Backend

1. **Run bootstrap script** (creates S3 bucket + DynamoDB table)
   ```bash
   chmod +x bootstrap.sh
   ./bootstrap.sh
   ```

2. **Initialize Terraform with remote backend**
   ```bash
   cd terraform
   terraform init
   # Answer 'yes' when prompted to copy local state to S3
   ```

3. **Verify remote state is active**
   ```bash
   terraform state list  # Should work (pulling from S3)
   ```

**Reference Documentation**:
- 📖 Full Guide: `BACKEND_SETUP_GUIDE.md`
- ⚡ Quick Start: `BACKEND_QUICK_REFERENCE.md`

**Backend Resources Created**:
- S3 Bucket: `terraform-state-angelica-portfolio-production-{account-id}`
  - Versioning enabled
  - Encryption enabled (AES256)
  - Public access blocked
- DynamoDB Table: `terraform-state-angelica-portfolio-production-locks`
  - Manages state locks during terraform operations

## 📊 Performance & Security

### Performance Targets
- ✅ Page load time: < 2 seconds
- ✅ Lighthouse Performance: ≥ 90
- ✅ Lighthouse Accessibility: ≥ 90
- ✅ Lighthouse Best Practices: ≥ 90
- ✅ Lighthouse SEO: ≥ 90

**Check Performance**: 
```bash
# Run Lighthouse locally
# Chrome DevTools → Lighthouse → Generate report

# Or use lighthouse CLI
npm install -g lighthouse
lighthouse https://<your-cloudfront-url>
```

### Security Features
- ✅ HTTPS enforced (CloudFront)
- ✅ S3 public access blocked
- ✅ CloudFront Origin Access Identity (OAI)
- ✅ Security headers configured
- ✅ Terraform state encrypted in S3
- ✅ Minimal IAM permissions

**Security Audit**:
```bash
# Run security headers check
curl -I https://<your-cloudfront-url>

# Verify S3 bucket security
aws s3api get-bucket-public-access-block --bucket <bucket-name>

# Verify encryption
aws s3api get-bucket-encryption --bucket <bucket-name>
```

## 🛠️ Troubleshooting

### Website not updating after push?
1. Check GitHub Actions workflow status
2. Verify CloudFront cache invalidation completed
3. Hard refresh browser (Cmd+Shift+R on Mac, Ctrl+Shift+R on Windows)
4. Check S3 bucket for updated files: `aws s3 ls s3://<bucket-name>/`

### Terraform state locked?
```bash
# Check lock status
terraform force-unlock <lock-id>

# Or use DynamoDB
aws dynamodb scan --table-name terraform-locks
```

### Performance issues?
1. Run Lighthouse audit
2. Optimize images (< 100KB)
3. Minify CSS/JavaScript
4. Review CloudFront cache settings
5. Check Network tab in DevTools

### AWS credentials not working?
```bash
# Verify credentials are set in GitHub secrets
# Check IAM policy has correct permissions
# Verify AWS region is set correctly (eu-west-1)

# Test credentials locally
aws sts get-caller-identity
```

## 📝 Content Updates

### Update Profile Information

1. **Edit HTML content** in `src/index.html`
   - Update headline, about section, skills, experience
   - Add new sections as needed

2. **Change styling** in `src/css/`
   - Modify colors in CSS variables
   - Adjust responsive breakpoints
   - Add new styles

3. **Add functionality** in `src/js/main.js`
   - Smooth scrolling
   - Mobile menu toggle
   - Form handling

4. **Update profile photo**
   - Replace `src/assets/images/profile.jpg`
   - Keep file < 100KB
   - Optimize for web

### Commit and Deploy
```bash
git add .
git commit -m "Update portfolio: [describe changes]"
git push origin main
```

## 🔐 Security Best Practices

### Credential Management
- ✅ Store AWS credentials in GitHub Secrets ONLY
- ✅ Never commit credentials to repository
- ✅ Use IAM users with minimal permissions (not root account)
- ✅ Rotate credentials regularly

### Terraform State
- ✅ Always use remote state (S3 backend with encryption)
- ✅ Enable versioning on state bucket
- ✅ Use DynamoDB lock table for concurrency
- ✅ Never commit `*.tfstate` files to git

### S3 & CloudFront
- ✅ Block all public access to S3 bucket
- ✅ Use Origin Access Identity (OAI) for CloudFront
- ✅ Enable bucket versioning for rollback capability
- ✅ Enable server-side encryption (SSE-S3)

## 📚 Documentation

- **Constitution**: `.specify/memory/constitution.md` - Project principles and governance
- **Specification**: `.specify/memory/specification.md` - Detailed feature requirements
- **Implementation Plan**: `.specify/memory/plan.md` - Phase-by-phase breakdown
- **Tasks**: `.specify/memory/tasks.md` - Actionable task list with checkpoints

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Test locally: open `src/index.html` in browser
4. Commit: `git commit -m "Add your feature"`
5. Push: `git push origin feature/your-feature`
6. Submit PR to main branch

## 📋 Deployment Checklist

Before going to production, verify:

- [ ] All HTML valid (W3C validator)
- [ ] CSS passes linting
- [ ] Lighthouse scores ≥ 90
- [ ] Page load < 2 seconds
- [ ] Responsive on mobile/tablet/desktop
- [ ] All links work
- [ ] HTTPS enforced
- [ ] Security headers present
- [ ] S3 bucket public access blocked
- [ ] Terraform state in S3 backend
- [ ] GitHub Actions workflow passes

## 📞 Support & Contact

- **LinkedIn**: [Angélica Muñoz](https://www.linkedin.com/in/angélica-muñoz-59530850/)
- **GitHub**: [Your GitHub Profile]
- **Email**: [Your Email]

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 🎯 Roadmap (Future Versions)

- [ ] v1.1: Custom domain with Route 53
- [ ] v1.2: Email contact form with Lambda/SES
- [ ] v1.3: Dark mode toggle
- [ ] v1.4: Blog section
- [ ] v1.5: Analytics and monitoring
- [ ] v2.0: Multi-language support

---

**Last Updated**: December 10, 2025  
**Status**: Active & Maintained  
**Version**: 1.0.0

For more information, see the project documentation in `.specify/memory/`
