import { test, expect } from '@playwright/test';
import { PageFactory, PageType } from '../../../helper/page-factory.js';
import { AuthPage } from '../../../pages/auth-page/auth.page.js';
import { HomePage } from '../../../pages/home-page/home.page.js';
import { TEST_USERS } from '../../../data/test-data/test-data.js';
import { TEST_CONSTANTS } from '../../../data/constants/test-constants.js';

test.describe('Authentication Regression Tests', () => {
  let authPage: AuthPage;
  let homePage: HomePage;

  test.beforeEach(async ({ page }) => {
    PageFactory.initialize(page);
    authPage = PageFactory.get<AuthPage>(PageType.AUTH);
    homePage = PageFactory.get<HomePage>(PageType.HOME);
  });

  test.afterEach(() => {
    PageFactory.clear();
  });

  test('should complete full user registration flow', async () => {
    const randomUser = TEST_USERS.generateRandomUser();

    await test.step('Navigate to login page', async () => {
      await authPage.goto('/login');
      await authPage.verifyLoginFormVisible();
      await authPage.verifySignupFormVisible();
    });

    await test.step('Enter signup information', async () => {
      await authPage.signupUser(randomUser.name, randomUser.email);
    });

    await test.step('Fill account information form', async () => {
      await authPage.fillAccountInformation({
        gender: 'Mr',
        password: randomUser.password,
        day: '15',
        month: 'January',
        year: '1990',
        newsletter: true,
        offers: true
      });
    });

    await test.step('Fill address information form', async () => {
      await authPage.fillAddressInformation({
        firstName: randomUser.firstName,
        lastName: randomUser.lastName,
        company: randomUser.company,
        address1: randomUser.address1,
        address2: randomUser.address2,
        country: randomUser.country,
        state: randomUser.state,
        city: randomUser.city,
        zipcode: randomUser.zipcode,
        mobileNumber: randomUser.mobileNumber
      });
    });

    await test.step('Create account', async () => {
      await authPage.createAccount();
    });

    await test.step('Verify account creation success', async () => {
      await authPage.verifyAccountCreated();
      await authPage.clickContinue();
    });

    await test.step('Verify user is logged in', async () => {
      await authPage.header.verifyUserLoggedIn(randomUser.name);
    });

    await test.step('Logout user', async () => {
      await authPage.header.logout();
      await expect(authPage.currentPage).toHaveURL(/.*login/);
    });
  });

  test('should handle user login and logout flow', async () => {
    const testUser = TEST_USERS.VALID_USER;

    await test.step('Navigate to login page', async () => {
      await authPage.goto('/login');
    });

    await test.step('Login with valid credentials', async () => {
      await authPage.loginUser(testUser.email, testUser.password);
    });

    await test.step('Verify successful login', async () => {
      // Check if we're redirected away from login page
      await authPage.currentPage.waitForURL('**/', { timeout: 10000 });
      await authPage.header.verifyUserLoggedIn(testUser.name);
    });

    await test.step('Navigate around the site while logged in', async () => {
      await authPage.header.navigateToProducts();
      await expect(authPage.currentPage).toHaveURL(/.*products/);
      
      await authPage.header.navigateToHome();
      await expect(authPage.currentPage).toHaveURL(/^.*\/$/);
    });

    await test.step('Logout and verify', async () => {
      await authPage.header.logout();
      await expect(authPage.currentPage).toHaveURL(/.*login/);
    });
  });

  test('should handle account deletion flow', async () => {
    const randomUser = TEST_USERS.generateRandomUser();

    await test.step('Create a new account', async () => {
      await authPage.goto('/login');
      await authPage.signupUser(randomUser.name, randomUser.email);
      
      await authPage.fillAccountInformation({
        gender: 'Mrs',
        password: randomUser.password,
        day: '10',
        month: 'February',
        year: '1985',
        newsletter: false,
        offers: false
      });
      
      await authPage.fillAddressInformation({
        firstName: randomUser.firstName,
        lastName: randomUser.lastName,
        company: randomUser.company,
        address1: randomUser.address1,
        country: randomUser.country,
        state: randomUser.state,
        city: randomUser.city,
        zipcode: randomUser.zipcode,
        mobileNumber: randomUser.mobileNumber
      });
      
      await authPage.createAccount();
      await authPage.verifyAccountCreated();
      await authPage.clickContinue();
    });

    await test.step('Verify user is logged in', async () => {
      await authPage.header.verifyUserLoggedIn(randomUser.name);
    });

    await test.step('Delete account', async () => {
      await authPage.header.deleteAccount();
    });

    await test.step('Verify account deletion', async () => {
      await authPage.verifyVisible('[data-qa="account-deleted"]');
      await authPage.clickContinue();
    });
  });

  test('should validate input field requirements', async () => {
    await test.step('Navigate to login page', async () => {
      await authPage.goto('/login');
    });

    await test.step('Test invalid email format in signup', async () => {
      await authPage.signupUser('Test User', 'invalid-email');
      // Should show HTML5 validation error for invalid email
    });

    await test.step('Test empty fields in login', async () => {
      await authPage.loginUser('', '');
      // Should show HTML5 validation errors
    });
  });

  test('should handle password field security', async () => {
    const randomUser = TEST_USERS.generateRandomUser();

    await test.step('Navigate to signup flow', async () => {
      await authPage.goto('/login');
      await authPage.signupUser(randomUser.name, randomUser.email);
    });

    await test.step('Verify password field is masked', async () => {
      const passwordField = authPage.currentPage.locator('[data-qa="password"]');
      await expect(passwordField).toHaveAttribute('type', 'password');
    });

    await test.step('Test password strength requirements', async () => {
      // Test weak password
      await authPage.waitAndFill('[data-qa="password"]', '123');
      // Add assertions for password validation if implemented
      
      // Test strong password
      await authPage.waitAndFill('[data-qa="password"]', 'StrongPassword123!');
    });
  });
});
