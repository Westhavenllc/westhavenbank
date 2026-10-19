// Helper functions
const Helpers = {
    // Generate random string
    generateRandomString(length = 32) {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let result = '';
        for (let i = 0; i < length; i++) {
            result += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return result;
    },

    // Generate recovery phrase (8 random words)
    generateRecoveryPhrase() {
        const words = [
            'abandon', 'ability', 'able', 'about', 'above', 'absent', 'absorb', 'abstract',
            'absurd', 'abuse', 'access', 'accident', 'account', 'accuse', 'achieve', 'acid',
            'acoustic', 'acquire', 'across', 'act', 'action', 'actor', 'actress', 'actual',
            'adapt', 'add', 'addict', 'address', 'adjust', 'admit', 'adult', 'advance',
            'advice', 'aerobic', 'affair', 'afford', 'afraid', 'again', 'age', 'agent',
            'agree', 'ahead', 'aim', 'air', 'airport', 'aisle', 'alarm', 'album'
        ];
        
        const phrase = [];
        for (let i = 0; i < 8; i++) {
            const randomIndex = Math.floor(Math.random() * words.length);
            phrase.push(words[randomIndex]);
        }
        return phrase.join(' ');
    },

    // Generate transaction PIN (4 digits)
    generateTransactionPIN() {
        return Math.floor(1000 + Math.random() * 9000).toString();
    },

    // Hash password (simplified for demo)
    async hashPassword(password) {
        const encoder = new TextEncoder();
        const data = encoder.encode(password);
        const hash = await crypto.subtle.digest('SHA-256', data);
        const hashArray = Array.from(new Uint8Array(hash));
        const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
        return hashHex;
    },

    // Get currency code from country name
    getCurrencyFromCountry(country) {
        if (!country) return 'USD';
        const c = country.toLowerCase().trim();
        if (c.includes('south africa')) return 'ZAR';
        if (c.includes('botswana')) return 'BWP';
        if (c.includes('mexico')) return 'MXN';
        if (c.includes('argentina')) return 'ARS';
        if (c.includes('colombia')) return 'COP';
        if (c.includes('chile')) return 'CLP';
        if (c.includes('philippines')) return 'PHP';
        if (c.includes('nigeria')) return 'NGN';
        if (c.includes('kenya')) return 'KES';
        if (c.includes('ghana')) return 'GHS';
        if (c.includes('uganda')) return 'UGX';
        if (c.includes('tanzania')) return 'TZS';
        if (c.includes('united kingdom') || c.includes('uk')) return 'GBP';
        if (c.includes('europe') || c.includes('germany') || c.includes('france') || c.includes('spain') || c.includes('italy')) return 'EUR';
        return 'USD';
    },

    // Format currency
    formatCurrency(amount, currencyCode, isConverted) {
        let currency = currencyCode || 'USD';
        if (!currencyCode && window.currentUser && window.currentUser.country) {
            currency = this.getCurrencyFromCountry(window.currentUser.country);
        } else if (!currencyCode && window.currentAccountCurrency) {
            currency = window.currentAccountCurrency;
        }

        let displayVal = parseFloat(amount) || 0;
        if (!isConverted && currency !== 'USD') {
            const rates = (window.CurrencyConverter && window.CurrencyConverter.cache.rates) 
                ? window.CurrencyConverter.cache.rates 
                : {
                    'ZAR': 18.80, 'BWP': 13.50, 'MXN': 17.00, 'ARS': 850.00,
                    'COP': 3900.00, 'CLP': 950.00, 'PHP': 56.00, 'USD': 1.0
                  };
            const rate = rates[currency] || 1.0;
            displayVal = displayVal * rate;
        }

        try {
            return new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: currency,
                minimumFractionDigits: 2
            }).format(displayVal);
        } catch (e) {
            return new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD',
                minimumFractionDigits: 2
            }).format(displayVal);
        }
    },

    formatUSDToLocal(amount) {
        return this.formatCurrency(amount, null, false);
    },

    // Format date
    formatDate(date) {
        return new Date(date).toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    },

    // Generate transaction ID
    generateTransactionId() {
        const timestamp = Date.now().toString(36);
        const random = Math.random().toString(36).substring(2, 8);
        return `MTX-${timestamp}-${random}`.toUpperCase();
    },

    // Generate account number
    generateAccountNumber() {
        const prefix = 'WH';
        const timestamp = Date.now().toString().slice(-8);
        const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
        return `${prefix}${timestamp}${random}`;
    },

    // Validate email
    validateEmail(email) {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    },

    // Validate password strength
    validatePassword(password) {
        return password.length >= 8;
    },

    // Get current language
    getCurrentLanguage() {
        return localStorage.getItem('West Haven Bank_language') || 'en';
    },

    // Get theme
    getCurrentTheme() {
        return localStorage.getItem('West Haven Bank_theme') || 'light';
    },

    // Set theme
    setTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('West Haven Bank_theme', theme);
    },

    // Show notification
    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `alert alert-${type}`;
        notification.innerHTML = `
            <i class="fas fa-${type === 'success' ? 'check-circle' : 
                                 type === 'error' ? 'exclamation-circle' : 
                                 type === 'warning' ? 'exclamation-triangle' : 'info-circle'}"></i>
            <span>${message}</span>
        `;
        
        notification.style.position = 'fixed';
        notification.style.top = '20px';
        notification.style.right = '20px';
        notification.style.zIndex = '9999';
        notification.style.minWidth = '300px';
        notification.style.boxShadow = 'var(--shadow)';
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.remove();
        }, 5000);
    },

    // Translate text
    t(key) {
        const lang = this.getCurrentLanguage();
        return TRANSLATIONS[lang]?.[key] || TRANSLATIONS.en[key] || key;
    }
};

console.log('Helpers loaded successfully');