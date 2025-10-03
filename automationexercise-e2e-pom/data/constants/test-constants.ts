export const TEST_CONSTANTS = {
  TIMEOUTS: {
    SHORT: 5000,
    MEDIUM: 10000,
    LONG: 30000,
    EXTRA_LONG: 60000
  },
  
  URLS: {
    HOME: '/',
    LOGIN: '/login',
    PRODUCTS: '/products',
    CART: '/view_cart',
    CONTACT: '/contact_us',
    CHECKOUT: '/checkout'
  },
  
  USER_ROLES: {
    GUEST: 'guest',
    REGISTERED: 'registered',
    ADMIN: 'admin'
  },
  
  PRODUCT_CATEGORIES: {
    WOMEN: 'Women',
    MEN: 'Men',
    KIDS: 'Kids'
  },
  
  BRANDS: {
    POLO: 'Polo',
    HM: 'H&M',
    MADAME: 'Madame',
    MAST_HARBOUR: 'Mast & Harbour',
    BABYHUG: 'Babyhug',
    ALLEN_SOLLY_JUNIOR: 'Allen Solly Junior',
    KOOKIE_KIDS: 'Kookie Kids',
    BIBA: 'Biba'
  },
  
  COUNTRIES: {
    INDIA: 'India',
    UNITED_STATES: 'United States',
    CANADA: 'Canada',
    AUSTRALIA: 'Australia',
    ISRAEL: 'Israel',
    NEW_ZEALAND: 'New Zealand',
    SINGAPORE: 'Singapore'
  },
  
  MESSAGES: {
    ACCOUNT_CREATED: 'Account Created!',
    ACCOUNT_DELETED: 'Account Deleted!',
    LOGIN_SUCCESS: 'Logged in as',
    SUBSCRIPTION_SUCCESS: 'You have been successfully subscribed!',
    CONTACT_SUCCESS: 'Success! Your details have been submitted successfully.'
  },
  
  ERROR_MESSAGES: {
    INVALID_LOGIN: 'Your email or password is incorrect!',
    EMAIL_EXISTS: 'Email Address already exist!'
  }
};

export const REGEX_PATTERNS = {
  EMAIL: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  PHONE: /^\d{10}$/,
  ZIPCODE: /^\d{5}$/,
  PRICE: /Rs\. \d+/
};
