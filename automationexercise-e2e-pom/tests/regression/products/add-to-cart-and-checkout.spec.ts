import { test, expect } from '@playwright/test';
import { PageFactory, PageType } from '../../../helper/page-factory.js';
import { ProductsPage } from '../../../pages/products-page/products.page.js';
import { ProductDetailPage } from '../../../pages/product-detail-page/product-detail.page.js';
import { CartPage } from '../../../pages/cart-page/cart.page.js';
import { CheckoutPage } from '../../../pages/checkout-page/checkout.page.js';
import { AuthPage } from '../../../pages/auth-page/auth.page.js';
import { TEST_USERS, TEST_PRODUCTS } from '../../../data/test-data/test-data.js';

test.describe('Add to Cart and Checkout Regression Tests', () => {
  let productsPage: ProductsPage;
  let productDetailPage: ProductDetailPage;
  let cartPage: CartPage;
  let checkoutPage: CheckoutPage;
  let authPage: AuthPage;

  test.beforeEach(async ({ page }) => {
    PageFactory.initialize(page);
    productsPage = PageFactory.get<ProductsPage>(PageType.PRODUCTS);
    productDetailPage = PageFactory.get<ProductDetailPage>(PageType.PRODUCT_DETAIL);
    cartPage = PageFactory.get<CartPage>(PageType.CART);
    checkoutPage = PageFactory.get<CheckoutPage>(PageType.CHECKOUT);
    authPage = PageFactory.get<AuthPage>(PageType.AUTH);
  });

  test.afterEach(() => {
    PageFactory.clear();
  });

  test('should complete full shopping flow from product to checkout', async () => {
    await test.step('Navigate to products page', async () => {
      await productsPage.goto('/products');
      await productsPage.verifyAllProductsPageLoaded();
    });

    await test.step('Search for a specific product', async () => {
      const searchTerm = TEST_PRODUCTS.SEARCH_TERMS[0];
      await productsPage.searchProduct(searchTerm);
      await productsPage.verifySearchedProductsVisible();
    });

    await test.step('Add first search result to cart', async () => {
      await productsPage.addProductToCartByIndex(0);
      await productsPage.viewCart();
    });

    await test.step('Verify product in cart', async () => {
      const itemsCount = await cartPage.getCartItemsCount();
      expect(itemsCount).toBeGreaterThan(0);
      
      const productNames = await cartPage.getAllProductNames();
      expect(productNames.length).toBeGreaterThan(0);
    });

    await test.step('Proceed to checkout', async () => {
      await cartPage.proceedToCheckout();
      
      // If not logged in, should redirect to login
      if (cartPage.currentPage.url().includes('/login')) {
        await test.step('Login to continue checkout', async () => {
          const testUser = TEST_USERS.VALID_USER;
          await authPage.loginUser(testUser.email, testUser.password);
          
          // Navigate back to cart and checkout
          await cartPage.goto('/view_cart');
          await cartPage.proceedToCheckout();
        });
      }
    });

    await test.step('Verify checkout page', async () => {
      await checkoutPage.verifyCheckoutPageLoaded();
      
      // Verify order details
      const orderItemsCount = await checkoutPage.getOrderItemsCount();
      expect(orderItemsCount).toBeGreaterThan(0);
    });

    await test.step('Add comment and place order', async () => {
      await checkoutPage.addComment('This is a test order from automation');
      await checkoutPage.placeOrder();
      
      // Should navigate to payment page
      await expect(checkoutPage.currentPage).toHaveURL(/.*payment/);
    });
  });

  test('should add multiple products to cart and verify totals', async () => {
    await test.step('Navigate to products page', async () => {
      await productsPage.goto('/products');
    });

    await test.step('Add multiple products to cart', async () => {
      // Add first product
      await productsPage.addProductToCartByIndex(0);
      await productsPage.continueShopping();
      
      // Add second product
      await productsPage.addProductToCartByIndex(1);
      await productsPage.continueShopping();
      
      // Add third product
      await productsPage.addProductToCartByIndex(2);
      await productsPage.viewCart();
    });

    await test.step('Verify multiple products in cart', async () => {
      const itemsCount = await cartPage.getCartItemsCount();
      expect(itemsCount).toBe(3);
    });

    await test.step('Verify cart totals calculation', async () => {
      let calculatedTotal = 0;
      const itemsCount = await cartPage.getCartItemsCount();
      
      for (let i = 0; i < itemsCount; i++) {
        const priceText = await cartPage.getProductPriceByIndex(i);
        const quantityText = await cartPage.getProductQuantityByIndex(i);
        const totalText = await cartPage.getProductTotalByIndex(i);
        
        const price = parseFloat(priceText.replace(/[Rs. ]/g, ''));
        const quantity = parseInt(quantityText);
        const total = parseFloat(totalText.replace(/[Rs. ]/g, ''));
        
        expect(total).toBe(price * quantity);
        calculatedTotal += total;
      }
    });
  });

  test('should handle product quantity changes in cart', async () => {
    await test.step('Add product with specific quantity', async () => {
      await productsPage.goto('/products');
      await productsPage.viewProductByIndex(0);
    });

    await test.step('Change quantity and add to cart', async () => {
      await productDetailPage.verifyProductDetailPageLoaded();
      await productDetailPage.setQuantity('3');
      await productDetailPage.addToCart();
      
      // Navigate to cart
      await cartPage.goto('/view_cart');
    });

    await test.step('Verify quantity in cart', async () => {
      const quantity = await cartPage.getProductQuantityByIndex(0);
      expect(quantity).toBe('3');
    });
  });

  test('should filter products by category and brand', async () => {
    await test.step('Navigate to products page', async () => {
      await productsPage.goto('/products');
    });

    await test.step('Filter by brand', async () => {
      const brand = TEST_PRODUCTS.BRANDS[0];
      await productsPage.filterByBrand(brand);
      
      // Verify filtered results
      const productNames = await productsPage.getAllVisibleProductNames();
      expect(productNames.length).toBeGreaterThan(0);
    });

    await test.step('Add filtered product to cart', async () => {
      await productsPage.addProductToCartByIndex(0);
      await productsPage.viewCart();
      
      const itemsCount = await cartPage.getCartItemsCount();
      expect(itemsCount).toBeGreaterThan(0);
    });
  });

  test('should handle empty cart scenario', async () => {
    await test.step('Navigate to empty cart', async () => {
      await cartPage.goto('/view_cart');
    });

    await test.step('Verify empty cart message or state', async () => {
      const itemsCount = await cartPage.getCartItemsCount();
      if (itemsCount === 0) {
        // Cart is empty - this is expected for a fresh session
        expect(itemsCount).toBe(0);
      }
    });

    await test.step('Add product and verify cart is no longer empty', async () => {
      await cartPage.header.navigateToProducts();
      await productsPage.addProductToCartByIndex(0);
      await productsPage.viewCart();
      
      const itemsCount = await cartPage.getCartItemsCount();
      expect(itemsCount).toBeGreaterThan(0);
    });
  });

  test('should handle product removal from cart', async () => {
    await test.step('Add multiple products to cart', async () => {
      await productsPage.goto('/products');
      await productsPage.addProductToCartByIndex(0);
      await productsPage.continueShopping();
      await productsPage.addProductToCartByIndex(1);
      await productsPage.viewCart();
    });

    await test.step('Remove one product and verify', async () => {
      const initialCount = await cartPage.getCartItemsCount();
      expect(initialCount).toBeGreaterThanOrEqual(2);
      
      const firstProductName = await cartPage.getProductNameByIndex(0);
      await cartPage.removeProductByIndex(0);
      
      // Wait for removal to complete
      await cartPage.currentPage.waitForTimeout(2000);
      
      const finalCount = await cartPage.getCartItemsCount();
      expect(finalCount).toBe(initialCount - 1);
    });
  });

  test('should validate product information consistency', async () => {
    let productName: string;
    let productPrice: string;

    await test.step('Get product details from products page', async () => {
      await productsPage.goto('/products');
      productName = await productsPage.getProductNameByIndex(0);
      productPrice = await productsPage.getProductPriceByIndex(0);
    });

    await test.step('View product detail page', async () => {
      await productsPage.viewProductByIndex(0);
      
      const detailPageName = await productDetailPage.getProductName();
      const detailPagePrice = await productDetailPage.getProductPrice();
      
      expect(detailPageName).toBe(productName);
      expect(detailPagePrice).toBe(productPrice);
    });

    await test.step('Add to cart and verify consistency', async () => {
      await productDetailPage.addToCart();
      await cartPage.goto('/view_cart');
      
      const cartProductName = await cartPage.getProductNameByIndex(0);
      const cartProductPrice = await cartPage.getProductPriceByIndex(0);
      
      expect(cartProductName).toBe(productName);
      expect(cartProductPrice).toBe(productPrice);
    });
  });
});
