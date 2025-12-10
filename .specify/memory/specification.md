# AWS Static Web App Specification

## Project Overview

**Project Name**: Angélica Muñoz - Developer Portfolio

**Purpose**: Create a modern, single-page professional portfolio website that showcases Angélica Muñoz's developer experience, skills, and professional background.

**Deployment Target**: AWS S3 with CloudFront CDN

**Infrastructure**: Terraform-managed AWS infrastructure with GitHub Actions CI/CD pipeline

## User Stories

### US-001: View Professional Profile
**As a** visitor to the portfolio website
**I want to** see a comprehensive summary of Angélica's professional profile
**So that** I can understand her background, experience, and expertise

**Acceptance Criteria:**
- Page loads within 2 seconds
- Profile information is clearly visible on initial viewport
- All content is responsive across mobile, tablet, and desktop devices

### US-002: Deploy via Pipeline
**As a** developer maintaining this portfolio
**I want to** deploy changes automatically via GitHub Actions
**So that** new content updates are published without manual AWS console access

**Acceptance Criteria:**
- GitHub Actions workflow triggers on push to main branch
- Terraform automatically validates and applies infrastructure changes
- Deployment completes within 5 minutes

## Technical Requirements

### Frontend Requirements
- **Technology Stack**: HTML5, CSS3, JavaScript (ES6+)
- **Framework**: Vanilla JavaScript (no heavy framework required for single page)
- **Styling**: Modern CSS with responsive design (mobile-first approach)
- **Bundling**: Optional minification and optimization
- **Accessibility**: WCAG 2.1 Level AA compliance

### AWS Infrastructure
- **S3 Bucket**: Static website hosting with versioning
- **CloudFront**: CDN distribution for global content delivery
- **IAM**: Minimal permissions policy for GitHub Actions deployment
- **Bucket Policy**: Restrict access to CloudFront OAI only

### CI/CD Pipeline
- **Trigger**: Push events to main branch
- **Validation**: Terraform plan approval (linting and syntax validation)
- **Deployment**: Terraform apply with state locking
- **Notification**: Success/failure status in GitHub Actions

## Clarifications & Assumptions

### Regional & Deployment Assumptions
- **AWS Region**: `eu-west-1` (Ireland) - Based on LinkedIn profile location context; can be overridden via `terraform.tfvars`
- **Environment**: Single production environment (dev/staging can be added later via workspace strategy)
- **Domain Name**: Not required for initial deployment (CloudFront URL will be used; Route 53 optional future enhancement)

### Frontend Assumptions
- **No Build Tool Required**: Vanilla HTML/CSS/JS (no webpack/rollup needed initially)
- **Minification**: Handled by CloudFront compression (optional manual minification for future optimization)
- **Profile Photo**: Will be committed to repo as `src/assets/images/profile.jpg` (resize to <100KB)
- **Data Management**: Profile data embedded in HTML (no JSON API required for single page)

### GitHub Actions Assumptions
- **Manual Approval**: Not required for main branch (auto-deploy on push)
- **Multiple Environments**: Workflows use same credentials; future enhancement: separate dev/prod
- **Artifact Storage**: None required (S3 serves as final artifact storage)

### Optional Future Enhancements (Out of Scope for v1.0)
- Route 53 custom domain configuration
- Email contact form with Lambda/SES
- Dark mode toggle
- Blog or projects section
- Internationalization (i18n)
- Analytics (Google Analytics or CloudWatch)

## Content Structure

### Page Layout (Single Page)
1. **Header**: Navigation and branding
2. **Hero Section**: Professional photo and headline
3. **About Section**: Professional summary and career overview
4. **Skills Section**: Technical skills and competencies
5. **Experience Section**: Work history and major projects
6. **Contact Section**: Links to LinkedIn, GitHub, Email

### Content Data Points (from LinkedIn Profile)
- Professional headline/title
- About/summary text
- Work experience entries (company, role, duration, achievements)
- Technical skills list
- Education background
- Professional certifications (if any)

## Terraform Configuration

### Required Files
```
terraform/
├── main.tf              # S3, CloudFront, IAM resources
├── variables.tf         # Input variables
├── outputs.tf           # CloudFront URL, S3 bucket name
├── terraform.tfvars     # Variable values (non-sensitive)
├── backend.tf          # S3 backend configuration
└── locals.tf           # Local values for consistency
```

### Resources to Create
1. **S3 Bucket**
   - Static website hosting enabled
   - Versioning enabled
   - Encryption at rest (SSE-S3)
   - Block public access enabled

2. **CloudFront Distribution**
   - Origin: S3 bucket
   - Origin Access Identity (OAI)
   - Cache behaviors optimized for static files
   - HTTPS only (redirect HTTP to HTTPS)

3. **IAM Resources**
   - GitHub Actions deployment role
   - Policy with S3 and CloudFront permissions
   - Policy with Terraform state management permissions

4. **S3 Bucket Policy**
   - Allow CloudFront OAI access only
   - Deny all public access

### Variables
- `project_name`: "angelica-portfolio"
- `environment`: "production"
- `aws_region`: "eu-west-1"
- `domain_name`: (optional for Route 53)
- `enable_versioning`: true

## GitHub Actions Pipeline

### Workflow File: `.github/workflows/deploy.yml`

**Trigger Events**:
- Push to `main` branch
- Manual workflow dispatch

**Jobs**:
1. **Validate**
   - Checkout code
   - Setup Terraform
   - Terraform validate
   - Terraform plan (no changes applied)

2. **Build** (if applicable)
   - Minify CSS/JS (optional)
   - Optimize images
   - Generate build artifacts

3. **Deploy**
   - Configure AWS credentials
   - Terraform apply
   - Invalidate CloudFront cache
   - Report deployment status

**Required Secrets** (GitHub):
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`

## File Structure

```
aws_deploy_with_tf/
├── .github/
│   ├── workflows/
│   │   └── deploy.yml              # CI/CD pipeline
│   └── prompts/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── backend.tf
│   └── locals.tf
├── src/
│   ├── index.html                  # Main page
│   ├── css/
│   │   ├── style.css               # Main stylesheet
│   │   └── responsive.css          # Mobile/tablet styles
│   ├── js/
│   │   └── main.js                 # JavaScript functionality
│   ├── assets/
│   │   ├── images/
│   │   │   └── profile.jpg         # Professional photo
│   │   └── fonts/                  # Custom fonts (if needed)
│   └── data.json                   # Profile data (optional)
├── .specify/
│   └── memory/
│       └── constitution.md
└── README.md
```

## Performance Requirements

- **Page Load Time**: < 2 seconds (3G connection)
- **Lighthouse Scores**: 
  - Performance: ≥ 90
  - Accessibility: ≥ 90
  - Best Practices: ≥ 90
  - SEO: ≥ 90

## Security Requirements

- **HTTPS**: Enforced via CloudFront
- **Headers**: Security headers configured (CSP, X-Frame-Options, etc.)
- **State Management**: S3 backend encrypted with versioning
- **Least Privilege**: Minimal IAM permissions for deployment
- **CORS**: Configured appropriately

## Deployment Checklist

### Pre-Deployment Setup
- [ ] AWS Account created with appropriate IAM permissions
- [ ] AWS CLI configured locally with credentials
- [ ] Terraform installed (v1.0+) and working
- [ ] GitHub repository configured with secrets:
  - [ ] `AWS_ACCESS_KEY_ID` added
  - [ ] `AWS_SECRET_ACCESS_KEY` added
  - [ ] `AWS_REGION` set to `eu-west-1`

### Infrastructure Validation
- [ ] Terraform files created and validated locally
  - [ ] `terraform validate` passes without errors
  - [ ] `terraform plan` shows expected resources (S3, CloudFront, IAM)
  - [ ] No "to be destroyed" resources in plan
- [ ] S3 backend bucket prepared (for state management)
  - [ ] Versioning enabled
  - [ ] Encryption enabled
  - [ ] DynamoDB table created for lock management
- [ ] IAM deployment role created with minimal permissions
  - [ ] S3 bucket access only
  - [ ] CloudFront invalidation permissions
  - [ ] Terraform state read/write permissions

### Frontend Build & Content
- [ ] HTML page created (`src/index.html`)
  - [ ] All sections present (header, hero, about, skills, experience, contact)
  - [ ] Professional photo added and optimized (<100KB)
  - [ ] Content reflects LinkedIn profile accurately
- [ ] CSS stylesheets created and tested
  - [ ] `src/css/style.css` - Main styles
  - [ ] `src/css/responsive.css` - Mobile responsiveness
  - [ ] All sections styled professionally
- [ ] JavaScript added (`src/js/main.js`)
  - [ ] Smooth scrolling functionality (if navigation links present)
  - [ ] Mobile menu toggle (if applicable)
  - [ ] Form handling (if contact form present)
- [ ] Assets optimized
  - [ ] All images compressed and properly sized
  - [ ] No unused CSS or JavaScript
  - [ ] Fonts loaded efficiently

### Performance & Accessibility Validation
- [ ] Lighthouse audit run locally
  - [ ] Performance score ≥ 90
  - [ ] Accessibility score ≥ 90
  - [ ] Best Practices score ≥ 90
  - [ ] SEO score ≥ 90
- [ ] Cross-browser testing completed
  - [ ] Chrome/Edge (latest)
  - [ ] Firefox (latest)
  - [ ] Safari (latest)
- [ ] Responsive design tested
  - [ ] Mobile (320px width)
  - [ ] Tablet (768px width)
  - [ ] Desktop (1920px width)
- [ ] Page load time verified
  - [ ] Initial page load < 2 seconds on 3G
  - [ ] All images lazy-loaded where applicable

### GitHub Actions Pipeline Testing
- [ ] Workflow file created (`.github/workflows/deploy.yml`)
- [ ] Workflow triggers correctly on:
  - [ ] Push to `main` branch
  - [ ] Manual `workflow_dispatch` trigger
- [ ] Validate job executes successfully
  - [ ] Code checks out
  - [ ] Terraform initializes
  - [ ] `terraform plan` runs without errors
- [ ] Deploy job executes successfully
  - [ ] AWS credentials authenticated
  - [ ] `terraform apply` completes without errors
  - [ ] CloudFront cache invalidated
- [ ] Deployment notifications working
  - [ ] Success/failure status visible in GitHub Actions
  - [ ] Commit shows workflow status badge

### Post-Deployment Validation
- [ ] Website accessible via CloudFront URL
  - [ ] HTTPS enforced (no HTTP access)
  - [ ] Page loads and renders correctly
  - [ ] All content visible and properly formatted
- [ ] Security headers validated
  - [ ] X-Frame-Options set
  - [ ] Content-Security-Policy configured
  - [ ] X-Content-Type-Options set to nosniff
- [ ] S3 bucket security verified
  - [ ] Public access blocked
  - [ ] CloudFront OAI has access
  - [ ] Bucket versioning enabled
  - [ ] Encryption enabled
- [ ] CloudFront distribution configured correctly
  - [ ] Default root object set to `index.html`
  - [ ] 404 handling configured (redirect to index.html for SPA)
  - [ ] Cache policies optimized
  - [ ] Origin Access Identity (OAI) restricts S3 access
- [ ] Terraform state secured
  - [ ] State file stored in S3 backend
  - [ ] State versioning enabled
  - [ ] Lock file mechanism working
  - [ ] No state file in git repository

### Final Acceptance & Sign-Off
- [ ] All checklist items completed
- [ ] Website meets all success criteria (see below)
- [ ] Documentation complete (README.md with deployment instructions)
- [ ] Team sign-off obtained
- [ ] Monitoring/alerting configured (CloudWatch alarms optional)
- [ ] Post-deployment testing approved

## Success Criteria

1. ✅ Website is live and accessible via CloudFront URL
2. ✅ Content accurately reflects professional profile from LinkedIn
3. ✅ Page is fully responsive on all devices (mobile, tablet, desktop)
4. ✅ Performance metrics meet requirements (Lighthouse 90+, <2s load time)
5. ✅ GitHub Actions pipeline runs successfully on every code push
6. ✅ Terraform manages 100% of infrastructure (no manual AWS console changes)
7. ✅ Zero manual AWS console access required for future deployments
8. ✅ HTTPS enforced and security headers configured
9. ✅ S3 bucket access restricted to CloudFront only
10. ✅ State management secure with S3 backend and locking

**Version**: 1.1.0 | **Created**: 2025-12-10 | **Last Updated**: 2025-12-10 | **Status**: Ready for Implementation
