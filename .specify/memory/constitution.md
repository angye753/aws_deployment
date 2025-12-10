# AWS Static Web App Deployment with Terraform Constitution# [PROJECT_NAME] Constitution

<!-- Example: Spec Constitution, TaskFlow Constitution, etc. -->

## Core Principles

## Core Principles

### I. Infrastructure as Code (IaC)

All AWS infrastructure must be defined in Terraform. Manual AWS console changes are prohibited. Version control is the single source of truth for all infrastructure.### [PRINCIPLE_1_NAME]

<!-- Example: I. Library-First -->

### II. Minimal & Secure by Default[PRINCIPLE_1_DESCRIPTION]

Deploy only essential resources required for static web hosting. Apply principle of least privilege to all IAM policies. Encrypt data at rest and in transit.<!-- Example: Every feature starts as a standalone library; Libraries must be self-contained, independently testable, documented; Clear purpose required - no organizational-only libraries -->



### III. State Management### [PRINCIPLE_2_NAME]

Terraform state must be stored in an S3 backend with versioning and encryption enabled. Lock files required to prevent concurrent modifications.<!-- Example: II. CLI Interface -->

[PRINCIPLE_2_DESCRIPTION]

### IV. Reproducibility<!-- Example: Every library exposes functionality via CLI; Text in/out protocol: stdin/args → stdout, errors → stderr; Support JSON + human-readable formats -->

Infrastructure must be reproducible across environments (dev, staging, production). Use variables and locals for environment-specific configurations. No hardcoded values.

### [PRINCIPLE_3_NAME]

## Technology Stack<!-- Example: III. Test-First (NON-NEGOTIABLE) -->

[PRINCIPLE_3_DESCRIPTION]

- **IaC Tool**: Terraform (HCL)<!-- Example: TDD mandatory: Tests written → User approved → Tests fail → Then implement; Red-Green-Refactor cycle strictly enforced -->

- **Cloud Provider**: AWS

- **Static Hosting**: S3 + CloudFront CDN### [PRINCIPLE_4_NAME]

- **State Backend**: S3 

- **DNS**: Route 53 (optional)[PRINCIPLE_4_DESCRIPTION]

<!-- Example: Focus areas requiring integration tests: New library contract tests, Contract changes, Inter-service communication, Shared schemas -->

## Minimal Resource Requirements

### [PRINCIPLE_5_NAME]

1. **S3 Bucket** - Static website hosting<!-- Example: V. Observability, VI. Versioning & Breaking Changes, VII. Simplicity -->

2. **CloudFront Distribution** - CDN for content delivery[PRINCIPLE_5_DESCRIPTION]

3. **IAM Role & Policy** - Minimal permissions for deployment<!-- Example: Text I/O ensures debuggability; Structured logging required; Or: MAJOR.MINOR.BUILD format; Or: Start simple, YAGNI principles -->

4. **Bucket Policy** - Restrict access to CloudFront OAI only

## [SECTION_2_NAME]

## Required Terraform Files<!-- Example: Additional Constraints, Security Requirements, Performance Standards, etc. -->



- `main.tf` - Primary resource definitions[SECTION_2_CONTENT]

- `variables.tf` - Input variables<!-- Example: Technology stack requirements, compliance standards, deployment policies, etc. -->

- `outputs.tf` - Output values

- `terraform.tfvars` - Variable assignments## [SECTION_3_NAME]

- `backend.tf` - State management configuration (optional for local dev)<!-- Example: Development Workflow, Review Process, Quality Gates, etc. -->



## Development Workflow[SECTION_3_CONTENT]

<!-- Example: Code review requirements, testing gates, deployment approval process, etc. -->

1. Create/modify Terraform files

2. Run `terraform plan` to review changes## Governance

3. Get approval for changes<!-- Example: Constitution supersedes all other practices; Amendments require documentation, approval, migration plan -->

4. Run `terraform apply` to deploy

5. Validate deployment via CloudFront URL[GOVERNANCE_RULES]

<!-- Example: All PRs/reviews must verify compliance; Complexity must be justified; Use [GUIDANCE_FILE] for runtime development guidance -->

## Governance

**Version**: [CONSTITUTION_VERSION] | **Ratified**: [RATIFICATION_DATE] | **Last Amended**: [LAST_AMENDED_DATE]

This constitution supersedes all other practices. All infrastructure changes must comply with these principles. Deviations require explicit documentation and approval.<!-- Example: Version: 2.1.1 | Ratified: 2025-06-13 | Last Amended: 2025-07-16 -->


**Version**: 1.0.0 | **Ratified**: 2025-12-10 | **Last Amended**: 2025-12-10
