# Implementation Plan: Angélica Muñoz - Developer Portfolio Website

**Branch**: `portfolio-static-website` | **Date**: 2025-12-10 | **Spec**: `/specification.md`

**Input**: Feature specification from `.specify/memory/specification.md`

## Summary

Build a modern, single-page professional portfolio website for Angélica Muñoz as a responsive HTML file deployed to AWS S3 via Terraform. The site will feature a professional profile summary with sections for about, skills, experience, and contact information. Infrastructure will be managed entirely through Terraform with GitHub Actions CI/CD pipeline for automated deployments.

**Technical Approach**:
1. Create responsive single-page HTML portfolio with mobile-first CSS
2. Implement Terraform infrastructure for S3 + CloudFront distribution
3. Set up GitHub Actions workflow for automated deployment on git push
4. Validate performance and accessibility metrics

## Technical Context

**Language/Version**: HTML5, CSS3, JavaScript (ES6+) | Modern browsers (no build step required)

**Primary Dependencies**: 
- AWS S3 (static hosting)
- AWS CloudFront (CDN)
- Terraform 1.0+ (infrastructure)
- GitHub Actions (CI/CD)

**Storage**: AWS S3 bucket with versioning enabled

**Testing**: Lighthouse for performance/accessibility, cross-browser manual testing

**Target Platform**: Web (responsive - mobile 320px to desktop 1920px+)

**Project Type**: Single-page website (static assets only)

**Performance Goals**: 
- Page load < 2 seconds (3G connection)
- Lighthouse Performance ≥ 90
- First Contentful Paint < 1.5s

**Constraints**: 
- No backend services required
- HTTPS enforced via CloudFront
- S3 bucket public access blocked
- Minimal IAM permissions for GitHub Actions

**Scale/Scope**: 
- Single page with 6 sections (header, hero, about, skills, experience, contact)
- ~5-10 KB HTML, ~15-20 KB CSS, ~5-10 KB JavaScript
- 1 profile photo (optimized < 100KB)
- Mobile-first responsive design

## Constitution Check

✅ **All constitution principles passed**:

1. **Infrastructure as Code (IaC)** ✓
   - 100% Terraform management
   - No manual AWS console changes
   - Version control as source of truth

2. **Minimal & Secure by Default** ✓
   - Only S3 + CloudFront required
   - Least privilege IAM
   - S3 public access blocked
   - CloudFront Origin Access Identity (OAI) enforced

3. **State Management** ✓
   - S3 backend with encryption and versioning
   - DynamoDB lock table for concurrency
   - No local state in git

4. **Reproducibility** ✓
   - Environment variables via `terraform.tfvars`
   - No hardcoded values
   - Replicable across environments

## Project Structure

### Documentation (this feature)

```text
.specify/memory/
├── constitution.md          # Project constitution
├── specification.md         # Feature specification
└── plan.md                  # This file (implementation plan)
```

### Source Code (repository root)

```text
aws_deploy_with_tf/
├── .github/
│   ├── workflows/
│   │   └── deploy.yml                    # GitHub Actions CI/CD pipeline
│   └── prompts/
│
├── terraform/
│   ├── main.tf                           # S3, CloudFront, IAM resources
│   ├── variables.tf                      # Input variable definitions
│   ├── outputs.tf                        # Output values (CloudFront URL, S3 bucket)
│   ├── locals.tf                         # Local values for consistency
│   ├── backend.tf                        # S3 backend configuration (optional)
│   └── terraform.tfvars                  # Variable assignments (non-sensitive)
│
├── src/
│   ├── index.html                        # Main portfolio page
│   ├── css/
│   │   ├── style.css                     # Main stylesheet (base, typography, layout)
│   │   └── responsive.css                # Mobile/tablet responsive styles
│   ├── js/
│   │   └── main.js                       # JavaScript for interactions (smooth scroll, mobile menu)
│   └── assets/
│       ├── images/
│       │   └── profile.jpg               # Professional profile photo (optimized)
│       └── fonts/                        # Optional custom fonts
│
├── .specify/
│   └── memory/
│       ├── constitution.md
│       ├── specification.md
│       └── plan.md                       # This file
│
├── README.md                              # Project documentation and setup instructions
└── .gitignore                             # Git ignore rules (exclude terraform state, secrets)
```

**Structure Decision**: Single-page website structure selected because:
- Single HTML file serves all content
- Terraform manages infrastructure independently in `/terraform` directory
- Frontend assets in `/src` directory
- Clean separation between IaC and content
- Simple, maintainable structure for portfolio site

## Implementation Phases

### Phase 1: Frontend Development (Weeks 1-2)
**Deliverables**: Responsive HTML/CSS/JS portfolio page

**Tasks**:
- Create `src/index.html` with semantic HTML5 structure
- Implement base styles in `src/css/style.css` (typography, colors, layout)
- Add responsive styles in `src/css/responsive.css` (mobile breakpoints: 320px, 768px, 1200px)
- Create `src/js/main.js` for smooth scrolling and mobile menu toggle
- Optimize and add profile photo to `src/assets/images/profile.jpg`
- Run Lighthouse audit locally, target scores ≥ 90
- Cross-browser testing (Chrome, Firefox, Safari, Edge)

**Success Criteria**:
- HTML valid (W3C validator)
- CSS passes linting
- Responsive on mobile (320px), tablet (768px), desktop (1920px)
- Lighthouse Performance ≥ 90
- Page load < 2 seconds

### Phase 2: Terraform Infrastructure (Weeks 1-2, parallel)
**Deliverables**: Complete Terraform configuration for AWS deployment

**Tasks**:
- Create `terraform/variables.tf` with required variables (project_name, environment, region, etc.)
- Create `terraform/locals.tf` for computed values (bucket naming, tags, etc.)
- Create `terraform/main.tf` with:
  - S3 bucket (static hosting, versioning, encryption)
  - CloudFront distribution (with OAI, cache policies)
  - IAM role for GitHub Actions
  - IAM policy for S3 and CloudFront access
  - S3 bucket policy (CloudFront OAI only)
- Create `terraform/outputs.tf` with CloudFront URL and S3 bucket name
- Create `terraform/backend.tf` for S3 state backend
- Create `terraform/terraform.tfvars` with project-specific values
- Run `terraform validate` and `terraform plan` locally
- Document all variables and outputs

**Success Criteria**:
- `terraform validate` passes without errors
- `terraform plan` shows correct resources (no destructive changes)
- State stored in S3 backend with encryption
- Lock management via DynamoDB

### Phase 3: CI/CD Pipeline (Week 2)
**Deliverables**: GitHub Actions workflow for automated deployment

**Tasks**:
- Create `.github/workflows/deploy.yml` with three jobs:
  - **Validate**: Terraform validate + plan
  - **Build**: Minify CSS/JS (optional), optimize images
  - **Deploy**: Terraform apply, CloudFront cache invalidation
- Configure GitHub repository secrets:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION`
- Test workflow with manual dispatch
- Add commit status checks
- Document GitHub Actions configuration

**Success Criteria**:
- Workflow triggers on push to main branch
- Validation job passes
- Deploy job applies Terraform successfully
- CloudFront cache invalidated after deploy
- Workflow completes in < 5 minutes

### Phase 4: Testing & Validation (Week 3)
**Deliverables**: Comprehensive testing and deployment validation

**Tasks**:
- Run Lighthouse audit on deployed site
- Cross-browser compatibility testing (Chrome, Firefox, Safari, Edge)
- Responsive design testing (DevTools, physical devices)
- Security validation (HTTPS, headers, CSP)
- S3 bucket security audit (public access, versioning, encryption)
- CloudFront distribution audit (OAI, cache settings)
- Performance monitoring (load times, Core Web Vitals)
- Documentation of deployment process

**Success Criteria**:
- All Lighthouse scores ≥ 90
- Page load < 2 seconds verified
- HTTPS enforced
- Security headers present
- All checklist items passed

### Phase 5: Documentation & Deployment (Week 3)
**Deliverables**: Complete project documentation and go-live

**Tasks**:
- Create comprehensive `README.md` with:
  - Project overview
  - Setup instructions (local development)
  - Deployment instructions (via GitHub Actions)
  - AWS credential configuration
  - Terraform state management
  - Troubleshooting guide
- Document all variables and outputs
- Create deployment runbook
- Add code comments where needed
- Final sign-off and deployment

**Success Criteria**:
- README covers all setup steps
- Clear deployment instructions
- Documentation complete
- Site live on CloudFront URL
- All acceptance criteria met

## File Implementation Priority

### Priority 1 (Week 1, Days 1-3)
1. `src/index.html` - HTML structure with all sections
2. `src/css/style.css` - Base desktop styles
3. `terraform/variables.tf` - Variable definitions
4. `terraform/main.tf` - Core S3 and CloudFront resources

### Priority 2 (Week 1, Days 4-5)
1. `src/css/responsive.css` - Mobile and tablet styles
2. `terraform/locals.tf` - Local values
3. `terraform/outputs.tf` - Outputs
4. Add profile photo and assets

### Priority 3 (Week 2, Days 1-3)
1. `src/js/main.js` - Functionality
2. `terraform/backend.tf` - State management
3. `.github/workflows/deploy.yml` - CI/CD
4. `terraform/terraform.tfvars` - Configuration values

### Priority 4 (Week 2-3)
1. Testing and validation
2. Performance optimization
3. Security hardening
4. `README.md` documentation

## Deployment Workflow

```mermaid
Developer commits → GitHub (main branch)
    ↓
GitHub Actions Trigger
    ↓
Validate Job: terraform validate + plan
    ↓
Auto-Deploy Job: terraform apply
    ↓
Build Job: Minify assets (optional)
    ↓
Upload: S3 put-object for HTML/CSS/JS
    ↓
Invalidate: CloudFront cache invalidation
    ↓
Status: Workflow complete, site updated
```

## Key Decisions

| Decision | Rationale |
|----------|-----------|
| Vanilla HTML/CSS/JS | No build tool needed, faster deployment, minimal dependencies |
| S3 + CloudFront | Best practice for static hosting, global CDN, HTTPS built-in |
| Terraform for IaC | Infrastructure as code, version control, repeatable deployments |
| GitHub Actions | Built into GitHub, no external service needed, easy secret management |
| eu-west-1 region | Based on user location context, can be overridden via tfvars |
| Auto-deploy on push | Simplified workflow, no manual approval step for main branch |
| Single S3 bucket | Minimal scope for v1.0, single site, easy to manage |

## Known Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Slow deployment | Users see stale content | CloudFront invalidation on deploy, short TTL |
| State file exposure | Security breach | S3 backend with encryption, DynamoDB lock, .gitignore |
| AWS credential leak | Account compromise | Use GitHub secrets, minimal IAM policy, rotate keys regularly |
| Performance regression | Poor user experience | Lighthouse monitoring, performance budget in CI |
| Browser compatibility | Broken experience for users | Cross-browser testing matrix, graceful degradation |
| Mobile responsiveness | Poor mobile UX | Mobile-first CSS, device testing, responsive framework |

## Next Steps

1. ✅ Review and approve implementation plan
2. → Start Phase 1: Frontend development (HTML/CSS/JS)
3. → Parallelize Phase 2: Terraform infrastructure
4. → Phase 3: Set up GitHub Actions workflow
5. → Phase 4: Comprehensive testing
6. → Phase 5: Deploy to production

---

**Version**: 1.0.0 | **Status**: Ready for Implementation | **Date**: 2025-12-10
