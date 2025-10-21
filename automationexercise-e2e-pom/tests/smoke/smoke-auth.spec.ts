import { test, expect } from '@playwright/test';
import { PageFactory, PageType } from '../../helper/page-factory';
import { AuthPage } from '../../pages/auth-page/auth.page';
import { TEST_USERS } from '../../data/test-data/test-data';

test.describe('Authentication Smoke Tests', () => {
  let authPage: AuthPage;

  test.beforeEach(async ({ page }) => {
    PageFactory.initialize(page);
    authPage = PageFactory.get<AuthPage>(PageType.AUTH);
    await authPage.goto('/login');
  });

  test.afterEach(() => {
    PageFactory.clear();
  });

  test('should display login and signup forms', async () => {
    await test.step('Verify login form is visible', async () => {
      await authPage.verifyLoginFormVisible();
    });

    await test.step('Verify signup form is visible', async () => {
      await authPage.verifySignupFormVisible();
    });
  });

  test('should show error for invalid login credentials', async () => {
    await test.step('Attempt login with invalid credentials', async () => {
      await authPage.loginUser(TEST_USERS.INVALID_USER.email, TEST_USERS.INVALID_USER.password);
    });

    await test.step('Verify error message is displayed', async () => {
      await authPage.verifyLoginError();
    });
  });

  test('should navigate to account information page after signup', async () => {
    const randomUser = TEST_USERS.generateRandomUser();

    await test.step('Enter signup details', async () => {
      await authPage.signupUser(randomUser.name, randomUser.email);
    });

    await test.step('Verify navigation to account information page', async () => {
      await expect(authPage.currentPage).toHaveURL(/.*signuppp/);
      await authPage.verifyVisible('[data-qa="password"]');
    });
  });

  test('should show error for existing email signup', async () => {
    await test.step('Attempt signup with existing email', async () => {
      await authPage.signupUser(TEST_USERS.VALID_USER.name, TEST_USERS.VALID_USER.email);
    });

    await test.step('Verify error message for existing email', async () => {
      await authPage.verifyEmailExistsError();
    });
  });

  test('should display all required form fields', async () => {
    const randomUser = TEST_USERS.generateRandomUser();

    await test.step('Navigate to account information page', async () => {
      await authPage.signupUser(randomUser.name, randomUser.email);
    });

    await test.step('Verify all form fields are present', async () => {
      // Gender fields
      await authPage.verifyVisible('#id_gender1');
      await authPage.verifyVisible('#id_gender2');
      
      // Account information fields
      await authPage.verifyVisible('[data-qa="password"]');
      await authPage.verifyVisible('[data-qa="days"]');
      await authPage.verifyVisible('[data-qa="months"]');
      await authPage.verifyVisible('[data-qa="years"]');
      
      // Address information fields
      await authPage.verifyVisible('[data-qa="first_name"]');
      await authPage.verifyVisible('[data-qa="last_name"]');
      await authPage.verifyVisible('[data-qa="company1"]');
      await authPage.verifyVisible('[data-qa="address1"]');
      await authPage.verifyVisible('[data-qa="country1"]');
      await authPage.verifyVisible('[data-qa="state1"]');
      await authPage.verifyVisible('[data-qa="city1"]');
      await authPage.verifyVisible('[data-qa="zipcode1"]');
      await authPage.verifyVisible('[data-qa="mobile_number1"]');

      // Submit button
      await authPage.verifyVisible('[data-qa="create-account"]');
    });
  });

  test('should validate required fields in forms', async () => {
    await test.step('Test empty login form submission', async () => {
      await authPage.loginUser('', '');
      // Browser validation should prevent submission
    });

    await test.step('Test empty signup form submission', async () => {
      await authPage.signupUser('', '');
      // Browser validation should prevent submission
    });
  });
});
