/* ============================================================================
   Angélica Muñoz Portfolio - Main JavaScript
   ============================================================================ */

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    initMobileMenu();
    initSmoothScroll();
});

/* ============================================================================
   Mobile Menu Toggle
   ============================================================================ */

function initMobileMenu() {
    const mobileMenuToggle = document.getElementById('mobileMenuToggle');
    const navMenu = document.getElementById('navMenu');

    if (!mobileMenuToggle || !navMenu) return;

    // Toggle menu on button click
    mobileMenuToggle.addEventListener('click', () => {
        mobileMenuToggle.classList.toggle('active');
        navMenu.classList.toggle('active');
    });

    // Close menu when a link is clicked
    const navLinks = navMenu.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            mobileMenuToggle.classList.remove('active');
            navMenu.classList.remove('active');
        });
    });

    // Close menu when clicking outside
    document.addEventListener('click', (e) => {
        if (!e.target.closest('.navbar')) {
            mobileMenuToggle.classList.remove('active');
            navMenu.classList.remove('active');
        }
    });

    // Close menu on window resize if menu is open
    window.addEventListener('resize', () => {
        if (window.innerWidth > 768) {
            mobileMenuToggle.classList.remove('active');
            navMenu.classList.remove('active');
        }
    });
}

/* ============================================================================
   Smooth Scroll for Navigation Links
   ============================================================================ */

function initSmoothScroll() {
    const links = document.querySelectorAll('a[href^="#"]');

    links.forEach(link => {
        link.addEventListener('click', (e) => {
            const href = link.getAttribute('href');

            // Skip if it's just "#"
            if (href === '#' || href === '') return;

            const target = document.querySelector(href);
            if (!target) return;

            e.preventDefault();

            // Calculate offset for fixed header
            const headerHeight = document.querySelector('.header') ? .offsetHeight || 0;
            const targetPosition = target.getBoundingClientRect().top + window.scrollY - headerHeight;

            // Use smooth scroll behavior
            window.scrollTo({
                top: targetPosition,
                behavior: 'smooth'
            });

            // Update active nav link
            updateActiveNavLink(href);
        });
    });
}

/* ============================================================================
   Update Active Navigation Link
   ============================================================================ */

function updateActiveNavLink(currentId) {
    const navLinks = document.querySelectorAll('.nav-link');

    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === currentId) {
            link.classList.add('active');
        }
    });
}

/* ============================================================================
   Intersection Observer for Scroll Effects (Optional)
   ============================================================================ */

function initScrollObserver() {
    // Create intersection observer for fade-in animations on scroll
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -100px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    // Observe all sections
    const sections = document.querySelectorAll('section');
    sections.forEach(section => {
        observer.observe(section);
    });
}

// Call this if you add fade-in styles to CSS
// initScrollObserver();

/* ============================================================================
   Scroll to Top Button (Optional Future Enhancement)
   ============================================================================ */

function initScrollToTop() {
    const scrollTopBtn = document.getElementById('scrollTopBtn');

    if (!scrollTopBtn) return;

    // Show/hide button based on scroll position
    window.addEventListener('scroll', () => {
        if (window.scrollY > 500) {
            scrollTopBtn.style.display = 'block';
        } else {
            scrollTopBtn.style.display = 'none';
        }
    });

    // Scroll to top when button is clicked
    scrollTopBtn.addEventListener('click', () => {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
}

// Uncomment when scroll-to-top button is added to HTML
// document.addEventListener('DOMContentLoaded', initScrollToTop);

/* ============================================================================
   Performance Monitoring (Optional)
   ============================================================================ */

function logPerformanceMetrics() {
    if (window.performance && window.performance.timing) {
        window.addEventListener('load', () => {
            const timing = window.performance.timing;
            const navigation = window.performance.navigation;

            const pageLoadTime = timing.loadEventEnd - timing.navigationStart;
            const connectTime = timing.responseEnd - timing.requestStart;
            const renderTime = timing.domComplete - timing.domLoading;

            console.log('=== Page Performance Metrics ===');
            console.log(`Total Load Time: ${pageLoadTime}ms`);
            console.log(`Connect Time: ${connectTime}ms`);
            console.log(`Render Time: ${renderTime}ms`);
            console.log(`Navigation Type: ${navigation.type}`);
        });
    }
}

// Uncomment for performance debugging
// logPerformanceMetrics();

/* ============================================================================
   Accessibility Enhancements
   ============================================================================ */

function improveAccessibility() {
    // Add keyboard focus styles
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Tab') {
            document.body.classList.add('keyboard-nav');
        }
    });

    // Remove keyboard nav class when clicking mouse
    document.addEventListener('mousedown', () => {
        document.body.classList.remove('keyboard-nav');
    });

    // Announce navigation changes to screen readers
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
        link.addEventListener('click', () => {
            const sectionName = link.textContent.trim();
            announceToScreenReader(`Navigated to ${sectionName} section`);
        });
    });
}

function announceToScreenReader(message) {
    const announcement = document.createElement('div');
    announcement.setAttribute('role', 'status');
    announcement.setAttribute('aria-live', 'polite');
    announcement.className = 'sr-only';
    announcement.textContent = message;
    document.body.appendChild(announcement);

    setTimeout(() => {
        announcement.remove();
    }, 1000);
}

// Uncomment for enhanced accessibility
// improveAccessibility();

/* ============================================================================
   Theme Toggle (Optional Future Enhancement)
   ============================================================================ */

function initThemeToggle() {
    const themeToggleBtn = document.getElementById('themeToggle');

    if (!themeToggleBtn) return;

    // Get saved theme from localStorage or system preference
    const savedTheme = localStorage.getItem('theme');
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const currentTheme = savedTheme || (prefersDark ? 'dark' : 'light');

    setTheme(currentTheme);

    // Toggle theme on button click
    themeToggleBtn.addEventListener('click', () => {
        const newTheme = document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark';
        setTheme(newTheme);
        localStorage.setItem('theme', newTheme);
    });

    // Listen for system theme changes
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
        if (!localStorage.getItem('theme')) {
            setTheme(e.matches ? 'dark' : 'light');
        }
    });
}

function setTheme(theme) {
    document.documentElement.dataset.theme = theme;
    // Update button text/icon if needed
    const themeToggleBtn = document.getElementById('themeToggle');
    if (themeToggleBtn) {
        themeToggleBtn.setAttribute('aria-label', `Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`);
    }
}

// Uncomment when theme toggle is implemented
// document.addEventListener('DOMContentLoaded', initThemeToggle);

/* ============================================================================
   Analytics Tracking (Optional - Implement with Google Analytics)
   ============================================================================ */

function trackEvent(category, action, label = '', value = '') {
    // Placeholder for analytics integration
    if (window.gtag) {
        gtag('event', action, {
            'event_category': category,
            'event_label': label,
            'value': value
        });
    }

    // Log locally for debugging
    console.log(`📊 Event: ${category} - ${action}`, { label, value });
}

// Example usage: trackEvent('engagement', 'section_viewed', 'about');

/* ============================================================================
   Export functions for testing
   ============================================================================ */

// Make functions available globally if needed for testing
window.portfolioApp = {
    initMobileMenu,
    initSmoothScroll,
    updateActiveNavLink,
    trackEvent
};

console.log('✅ Portfolio website loaded successfully!');