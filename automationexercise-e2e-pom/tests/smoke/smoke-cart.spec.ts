import { test, expect } from '@playwright/test';
import { PageFactory, PageType } from '../../helper/page-factory';
import { CartPage } from '../../pages/cart-page/cart.page';

test.describe('Cart Smoke Tests', () => {
  let cartPage: CartPage;

  test.beforeEach(async ({ page }) => {
    PageFactory.initialize(page);
    cartPage = PageFactory.get<CartPage>(PageType.CART);
  });

  test.afterEach(() => {
    PageFactory.clear();
  });

  test('should display cart page correctly', async () => {
    await test.step('Navigate to cart page', async () => {
      await cartPage.goto('/view_cart');
    });

    await test.step('Verify cart page structure', async () => {
      await cartPage.verifyCartPageLoaded();
    });
  });

  test('should allow navigation to products from cart', async () => {
    await test.step('Navigate to cart page', async () => {
      await cartPage.goto('/view_cart');
    });

    await test.step('Navigate to products page', async () => {
      await cartPage.header.navigateToProducts();
    });

    await test.step('Verify products page is loaded', async () => {
      await expect(cartPage.currentPage).toHaveURL(/.*products/);
    });
  });

  test('should allow newsletter subscription from cart page', async () => {
    await test.step('Navigate to cart page', async () => {
      await cartPage.goto('/view_cart');
    });

    await test.step('Subscribe to newsletter', async () => {
      await cartPage.subscribeToNewsletter('test@cart.com');
    });

    await test.step('Verify subscription success', async () => {
      await cartPage.verifySubscriptionSuccess();
    });
  });
});
