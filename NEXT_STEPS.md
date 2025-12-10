# Next Steps - Implementation Roadmap

**Status**: Infrastructure deployed ✅ | Website created ✅ | CI/CD ready ✅  
**Current Phase**: Testing & Validation (T016-T029)  
**Last Updated**: December 10, 2025

---

## 📋 Immediate Tasks (Next 1 Hour)

### 1️⃣ **T016: Add Profile Photo** ⏳ PENDING
**Status**: Blocked - Waiting for image  
**Time**: 5 minutes

Your website has a placeholder for a profile photo. To add it:

1. **Prepare the image**:
   - Size: 400x400 pixels (square)
   - File size: < 100KB (optimize using ImageOptim, TinyPNG, or Preview on Mac)
   - Format: JPEG or WebP
   - Name it: `profile.jpg`

2. **Place the file**:
   ```bash
   cp ~/path/to/profile.jpg /Users/angye/Documents/projecto\ personal/aws_deploy_with_tf/src/assets/images/profile.jpg
   ```

3. **Verify** it loads at: `http://localhost:8000` (should show in hero section)

4. **Test locally** before uploading to AWS

---

### 2️⃣ **T018: Validate HTML & Accessibility** 
**Status**: Ready to run  
**Time**: 10 minutes

Run these validators:

#### HTML Validation (W3C)
```bash
# Option 1: Online validator
# Visit: https://validator.w3.org/ and upload src/index.html

# Option 2: Using nu-html-checker (if installed)
java -jar ~/nu-html-checker/vnu.jar src/index.html
```

#### Accessibility Audit
- **Tool**: WAVE Browser Extension or axe DevTools
- **Steps**:
  1. Open `http://localhost:8000` in Chrome
  2. Install WAVE extension: https://wave.webaim.org/extension/
  3. Run audit and check for errors
  4. Fix any critical issues

#### Manual Checks
- [ ] All images have `alt` text
- [ ] Color contrast ratio ≥ 4.5:1 for text (use https://contrast-ratio.com/)
- [ ] Heading hierarchy: H1 → H2 → H3 (no gaps)
- [ ] Tab navigation works (press `Tab` repeatedly)

---

### 3️⃣ **T019: Lighthouse Audit** 🎯 PRIORITY
**Status**: Ready to run  
**Time**: 10 minutes

#### Steps:
1. Open `http://localhost:8000` in Chrome
2. Press `F12` to open DevTools
3. Go to **Lighthouse** tab
4. Click "Analyze page load"
5. Target scores:
   - Performance ≥ 90
   - Accessibility ≥ 90
   - Best Practices ≥ 90
   - SEO ≥ 90

#### If scores are low:
- **Performance**: Optimize images, minify CSS/JS
- **Accessibility**: Add missing alt text, fix color contrast
- **Best Practices**: Remove console errors, use HTTPS (CloudFront handles this)
- **SEO**: Verify meta tags, add structured data if needed

---

### 4️⃣ **T020: Responsive Design Testing**
**Status**: Ready to run  
**Time**: 10 minutes

#### Chrome DevTools Testing:
1. Open `http://localhost:8000`
2. Press `F12` → Click responsive mode icon (Cmd+Shift+M)
3. Test these widths:
   - **Mobile**: 375px (iPhone)
   - **Tablet**: 768px (iPad)
   - **Desktop**: 1920px (Full monitor)

#### Checklist:
- [ ] All text readable on mobile
- [ ] Images scale properly
- [ ] Mobile menu (hamburger) works
- [ ] No horizontal scrolling on mobile
- [ ] Buttons are touch-friendly (>44px tall)
- [ ] No text overflow on any device

---

### 5️⃣ **T021: Page Load Time**
**Status**: Ready to run  
**Time**: 5 minutes

#### Method 1: Lighthouse (from T019)
- Look at metrics section
- Target FCP < 1.5s, LCP < 2.5s

#### Method 2: Chrome DevTools Network Tab
1. Open DevTools → Network tab
2. Hard refresh (Cmd+Shift+R)
3. Check total load time (bottom left)
4. Target: < 2 seconds

#### If slow:
- Optimize images
- Remove unused CSS/JS
- CloudFront caching will help once deployed

---

## 🔐 AWS Credentials Setup (Required for Deployment)

**Status**: BLOCKED ⛔  
**Time**: 15 minutes

You need AWS credentials to deploy. Currently getting error:
```
InvalidAccessKeyId: The AWS Access Key Id you provided does not exist in our records
```

### T026: Configure AWS Credentials

1. **Create IAM User** (AWS Console):
   ```
   AWS Console → IAM → Users → Create User
   Username: github-actions-portfolio
   Enable: Programmatic access
   ```

2. **Attach Policies**:
   - `AmazonS3FullAccess`
   - `CloudFrontFullAccess`

3. **Get Keys**:
   - Save: **Access Key ID**
   - Save: **Secret Access Key** (only shown once!)

4. **Add to GitHub Secrets**:
   ```
   GitHub repo → Settings → Secrets and variables → Actions
   
   Create 3 secrets:
   - AWS_ACCESS_KEY_ID = (your key ID)
   - AWS_SECRET_ACCESS_KEY = (your secret key)
   - AWS_REGION = eu-west-1
   ```

⚠️ **DO NOT commit credentials to Git!** Use GitHub Secrets instead.

---

## 🚀 Deployment Steps (After Credentials)

### T023-T029: GitHub Actions Testing

Once credentials are configured:

1. **Test Manual Trigger**:
   ```
   GitHub repo → Actions tab → Deploy Workflow → Run workflow
   ```

2. **Test Auto-Trigger**:
   ```bash
   # Make a small change
   echo "# Updated" >> README.md
   git add .
   git commit -m "Test deployment"
   git push origin main
   
   # Watch GitHub Actions run automatically
   ```

3. **Verify Deployment**:
   - Website should be live at: `https://d3c51wrd8l12oc.cloudfront.net`
   - Check CloudFront takes ~3-5 min to fully deploy

---

## 📊 Testing & Validation Checklist

### Browser Compatibility (T031)
- [ ] Chrome (latest) - renders correctly
- [ ] Firefox (latest) - renders correctly
- [ ] Safari (latest) - renders correctly
- [ ] Edge (latest) - renders correctly

### Mobile Testing (T032)
- [ ] iPhone (test physically if available)
- [ ] Android (test physically if available)
- [ ] Tablet portrait mode
- [ ] Tablet landscape mode

### Performance Validation (T033)
- [ ] First Contentful Paint (FCP) < 1.5s
- [ ] Largest Contentful Paint (LCP) < 2.5s
- [ ] Page load time < 2s
- [ ] Lighthouse scores all ≥ 90

### Security Validation (T034-T037)
- [ ] Website uses HTTPS (CloudFront enforces)
- [ ] S3 bucket not publicly accessible ✅ (already configured)
- [ ] CloudFront OAI configured ✅ (already configured)
- [ ] Versioning enabled ✅ (already configured)
- [ ] Terraform state encrypted ✅ (already configured)

### Content Validation (T038)
- [ ] All sections visible (Header, About, Skills, Experience, Contact)
- [ ] Professional photo displays
- [ ] All links work (navigation, contact)
- [ ] No broken images or 404 errors

### Interactive Features (T039)
- [ ] Navigation links scroll smoothly
- [ ] Mobile menu toggle works
- [ ] Mobile menu closes on link click
- [ ] All sections accessible on mobile

---

## 📝 Documentation Tasks (T041-T043)

Already partially complete! Review these files:
- `README.md` - ✅ Complete
- `.specify/memory/specification.md` - ✅ Complete
- `.specify/memory/plan.md` - ✅ Complete
- `DEPLOYMENT_CHECKLIST.md` - ✅ Complete
- `QUICKSTART.md` - ✅ Complete

---

## 🎯 Success Criteria

By end of this phase (T016-T029), you should have:

1. ✅ Website running locally (`http://localhost:8000`)
2. ✅ All Lighthouse scores ≥ 90
3. ✅ Responsive on mobile/tablet/desktop
4. ✅ Page load < 2 seconds
5. ✅ AWS credentials configured securely
6. ✅ GitHub Actions pipeline tested
7. ✅ Website deployed to CloudFront
8. ✅ All tests passing

---

## 🚨 Common Issues & Solutions

### Issue: Website 403 Error on CloudFront
**Cause**: CloudFront still initializing (takes 5-15 min)  
**Solution**: Wait 15 minutes and try again

### Issue: Profile photo not showing
**Cause**: File not found or wrong path  
**Solution**: Check file exists at `src/assets/images/profile.jpg`

### Issue: Styles not loading
**Cause**: CSS files not uploaded to S3  
**Solution**: Run `aws s3 sync src/ s3://bucket-name/` once credentials configured

### Issue: Mobile menu not working
**Cause**: JavaScript error  
**Solution**: Open DevTools → Console → Look for red errors

### Issue: Slow page load
**Cause**: Large images or unoptimized assets  
**Solution**: Compress images to <100KB each, minify CSS/JS

---

## 📞 Quick Commands

```bash
# Start local server
cd src && python3 -m http.server 8000

# Configure AWS CLI credentials
aws configure

# Upload website to S3 (after credentials)
aws s3 sync src/ s3://angelica-portfolio-production-345594607466/

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id E28O24O650JRRY \
  --paths "/*"

# Check Terraform state
cd terraform && terraform state list

# View deployment outputs
cd terraform && terraform output
```

---

## ✅ Task Completion Checklist

- [ ] T016: Profile photo added
- [ ] T018: HTML & accessibility validated
- [ ] T019: Lighthouse audit ≥ 90 on all scores
- [ ] T020: Responsive design tested
- [ ] T021: Page load time < 2s verified
- [ ] T026: AWS credentials configured in GitHub Secrets
- [ ] T023-T029: GitHub Actions pipeline tested
- [ ] Website deployed to CloudFront
- [ ] All browsers tested
- [ ] All mobile devices tested
- [ ] Security validation complete
- [ ] Content validation complete

---

## 📅 Timeline

- **Phase 1**: Infrastructure & Setup ✅ (COMPLETE)
- **Phase 2**: Website Creation ✅ (COMPLETE)
- **Phase 3**: Testing & Validation ⏳ (IN PROGRESS - 1 hour remaining)
- **Phase 4**: Deployment ⏳ (Depends on AWS credentials)
- **Phase 5**: Post-Deployment ⏳ (5-10 minutes)

---

**Next Action**: Start with T016 (Add profile photo) or T019 (Lighthouse audit)  
**Questions?** Check DEPLOYMENT_CHECKLIST.md for more details
