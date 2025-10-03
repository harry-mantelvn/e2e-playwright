import { test, expect } from '@playwright/test';
import { PageFactory, PageType } from '../../helper/page-factory.js';
import { HomePage } from '../../pages/home-page/home.page.js';
import { ProductsPage } from '../../pages/products-page/products.page.js';
import { CartPage } from '../../pages/cart-page/cart.page.js';

test.describe('Cart Smoke Tests', () => {
  let homePage: HomePage;
  let productsPage: ProductsPage;
  let cartPage: CartPage;

  test.beforeEach(async ({ page }) => {
    PageFactory.initialize(page);
    homePage = PageFactory.get<HomePage>(PageType.HOME);
    productsPage = PageFactory.get<ProductsPage>(PageType.PRODUCTS);
    cartPage = PageFactory.get<CartPage>(PageType.CART);
  });

  test.afterEach(() => {
    PageFactory.clear();
  });

  test('should add product to cart from home page', async () => {
    await test.step('Navigate to home page', async () => {
      await homePage.goto();
    });

    await test.step('Add first product to cart', async () => {
      await homePage.scrollToFeaturedItems();
      await homePage.addProductToCartByIndex(0);
    });

    await test.step('Continue shopping', async () => {
      await productsPage.continueShopping();
    });

    await test.step('Navigate to cart and verify product', async () => {
      await homePage.header.navigateToCart();
      const itemsCount = await cartPage.getCartItemsCount();
      expect(itemsCount).toBeGreaterThan(0);
    });
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

  test('should add multiple products to cart', async () => {
    await test.step('Navigate to products page', async () => {
      await productsPage.goto('/products');
    });

    await test.step('Add first product to cart', async () => {
      await productsPage.addProductToCartByIndex(0);
      await productsPage.continueShopping();
    });

    await test.step('Add second product to cart', async () => {
      await productsPage.addProductToCartByIndex(1);
      await productsPage.viewCart();
    });

    await test.step('Verify multiple products in cart', async () => {
      const itemsCount = await cartPage.getCartItemsCount();
      expect(itemsCount).toBe(2);
    });
  });

  test('should allow removing products from cart', async () => {
    await test.step('Add product to cart', async () => {
      await productsPage.goto('/products');
      await productsPage.addProductToCartByIndex(0);
      await productsPage.viewCart();
    });

    await test.step('Remove product from cart', async () => {
      const initialCount = await cartPage.getCartItemsCount();
      if (initialCount > 0) {
        await cartPage.removeProductByIndex(0);
        
        // Wait for the product to be removed
        await cartPage.currentPage.waitForTimeout(2000);
        
        const finalCount = await cartPage.getCartItemsCount();
        expect(finalCount).toBeLessThan(initialCount);
      }
    });
  });

  test('should display proceed to checkout button when cart has items', async () => {
    await test.step('Add product to cart', async () => {
      await productsPage.goto('/products');
      await productsPage.addProductToCartByIndex(0);
      await productsPage.viewCart();
    });

    await test.step('Verify checkout button is visible', async () => {
      const itemsCount = await cartPage.getCartItemsCount();
      if (itemsCount > 0) {
        await cartPage.verifyVisible('.btn-default.check_out');
      }
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
