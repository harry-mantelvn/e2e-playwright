import { test, expect } from '@playwright/test';
import { PageFactory, PageType } from '../../../helper/page-factory';
import { AuthPage } from '../../../pages/auth-page/auth.page';

test.describe('Authentication Regression Tests', () => {
  let authPage: AuthPage;

  test.beforeEach(async ({ page }) => {
    PageFactory.initialize(page);
    authPage = PageFactory.get<AuthPage>(PageType.AUTH);
  });

  test.afterEach(() => {
    PageFactory.clear();
  });

  test('should display login and signup forms correctly', async () => {
    await test.step('Navigate to login page', async () => {
      await authPage.goto('/login');
    });

    await test.step('Verify login form is visible', async () => {
      await authPage.verifyLoginFormVisible();
    });

    await test.step('Verify signup form is visible', async () => {
      await authPage.verifySignupFormVisible();
    });
  });

  test('should handle invalid login attempt', async () => {
    await test.step('Navigate to login page', async () => {
      await authPage.goto('/login');
    });

    await test.step('Attempt login with invalid credentials', async () => {
      await authPage.loginUser('invalid@email.com', 'wrongpassword');
    });

    await test.step('Verify error message is displayed', async () => {
      await authPage.verifyVisible('p:has-text("Your email or password is incorrect!")');
    });
  });

  test('should allow navigation between login and other pages', async () => {
    await test.step('Navigate to login page', async () => {
      await authPage.goto('/login');
    });

    await test.step('Navigate to home page', async () => {
      await authPage.header.navigateToHome();
      await expect(authPage.currentPage).toHaveURL(/.*automationexercise.com\/?$/);
    });

    await test.step('Navigate back to login page', async () => {
      await authPage.goto('/login');
      await expect(authPage.currentPage).toHaveURL(/.*login/);
    });
  });
});
