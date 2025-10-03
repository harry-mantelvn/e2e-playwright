import { test, expect } from '@playwright/test';
import { PageFactory, PageType } from '../../helper/page-factory';
import { HomePage } from '../../pages/home-page/home.page';
import { TEST_CONSTANTS } from '../../data/constants/test-constants';
import { NEWSLETTER_EMAILS } from '../../data/test-data/test-data';

test.describe('Home Page Smoke Tests', () => {
  let homePage: HomePage;

  test.beforeEach(async ({ page }) => {
    PageFactory.initialize(page);
    homePage = PageFactory.get<HomePage>(PageType.HOME);
    await homePage.goto();
  });

  test.afterEach(() => {
    PageFactory.clear();
  });

  test('should load home page successfully', async () => {
    await test.step('Verify home page elements are visible', async () => {
      await homePage.verifyHomePageLoaded();
    });

    await test.step('Verify navigation header is present', async () => {
      await homePage.header.verifyVisible('a[href="/"]');
      await homePage.header.verifyVisible('a[href="/products"]');
      await homePage.header.verifyVisible('a[href="/login"]');
    });
  });

  test('should display featured products', async () => {
    await test.step('Scroll to featured items section', async () => {
      await homePage.scrollToFeaturedItems();
    });

    await test.step('Verify products are displayed', async () => {
      const productsCount = await homePage.getProductsCount();
      expect(productsCount).toBeGreaterThan(0);
    });
  });

  test('should allow newsletter subscription', async () => {
    const testEmail = NEWSLETTER_EMAILS[0];

    await test.step('Subscribe to newsletter', async () => {
      await homePage.subscribeToNewsletter(testEmail);
    });

    await test.step('Verify subscription success', async () => {
      await homePage.verifySubscriptionSuccess();
    });
  });

  test('should navigate to products page', async () => {
    await test.step('Click on Products link', async () => {
      await homePage.header.navigateToProducts();
    });

    await test.step('Verify products page is loaded', async () => {
      await expect(homePage.currentPage).toHaveURL(/.*products/);
    });
  });

  test('should navigate to login page', async () => {
    await test.step('Click on Signup/Login link', async () => {
      await homePage.header.navigateToSignupLogin();
    });

    await test.step('Verify login page is loaded', async () => {
      await expect(homePage.currentPage).toHaveURL(/.*login/);
    });
  });

  test('should navigate to contact page', async () => {
    await test.step('Click on Contact Us link', async () => {
      await homePage.header.navigateToContactUs();
    });

    await test.step('Verify contact page is loaded', async () => {
      await expect(homePage.currentPage).toHaveURL(/.*contact_us/);
    });
  });

  test('should display brand and category filters', async () => {
    await test.step('Verify category menu is visible', async () => {
      await homePage.verifyVisible('.left-sidebar .panel-group');
    });

    await test.step('Verify brands section is visible', async () => {
      await homePage.verifyVisible('.brands_products');
    });
  });
});
