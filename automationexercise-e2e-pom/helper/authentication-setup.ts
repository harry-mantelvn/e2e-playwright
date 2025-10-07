import { test as setup } from '@playwright/test';
import { PageFactory, PageType } from './page-factory.js';
import { AuthPage } from '../pages/auth-page/auth.page.js';
import { StorageHelper } from './storage-helper.js';
import { Utilities } from './utilities.js';
import ENV from './env-config.js';

const TEST_USER = {
  name: 'Test User',
  email: 'testuser@automation.com',
  password: 'password123',
  firstName: 'Test',
  lastName: 'User',
  company: 'Test Company',
  address1: '123 Test Street',
  address2: 'Apt 4B',
  country: 'United States',
  state: 'California',
  city: 'San Francisco',
  zipcode: '94105',
  mobileNumber: '5551234567'
};

setup('authenticate and save storage state', async ({ page, context }) => {
  // Initialize page factory
  PageFactory.initialize(page);
  
  // Navigate to the auth page
  await page.goto(`${ENV.BASE_URL}/login`);
  
  const authPage = PageFactory.get<AuthPage>(PageType.AUTH);
  
  // Check if login form is visible, if not we might need to register first
  try {
    await authPage.verifyLoginFormVisible();
    
    // Try to login with existing credentials
    await authPage.loginUser(TEST_USER.email, TEST_USER.password);
    
    // Check if login was successful by looking for user name in header
    await page.waitForTimeout(2000);
    
    // If we're still on login page, user doesn't exist - register first
    if (page.url().includes('/login')) {
      await registerNewUser(authPage);
    }
  } catch (error) {
    await registerNewUser(authPage);
  }
  
  // Verify user is logged in
  await authPage.header.verifyUserLoggedIn(TEST_USER.name);
  
  // Save the authentication state
  await StorageHelper.saveStorageState(context);
});

async function registerNewUser(authPage: AuthPage) {
  // Fill signup form
  await authPage.signupUser(TEST_USER.name, TEST_USER.email);
  
  // Fill account information
  await authPage.fillAccountInformation({
    gender: 'Mr',
    password: TEST_USER.password,
    day: '15',
    month: 'January',
    year: '1990',
    newsletter: true,
    offers: true
  });
  
  // Fill address information
  await authPage.fillAddressInformation({
    firstName: TEST_USER.firstName,
    lastName: TEST_USER.lastName,
    company: TEST_USER.company,
    address1: TEST_USER.address1,
    address2: TEST_USER.address2,
    country: TEST_USER.country,
    state: TEST_USER.state,
    city: TEST_USER.city,
    zipcode: TEST_USER.zipcode,
    mobileNumber: TEST_USER.mobileNumber
  });
  
  // Create account
  await authPage.createAccount();
  
  // Verify account created and continue
  await authPage.verifyAccountCreated();
  await authPage.clickContinue();
}
