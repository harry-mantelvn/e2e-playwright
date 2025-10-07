import { test, expect } from '@playwright/test';
import { PageFactory, PageType } from '../../../helper/page-factory';
import { ProductsPage } from '../../../pages/products-page/products.page';
import { TEST_PRODUCTS } from '../../../data/test-data/test-data';

test.describe('Products Regression Tests', () => {
  let productsPage: ProductsPage;

  test.beforeEach(async ({ page }) => {
    PageFactory.initialize(page);
    productsPage = PageFactory.get<ProductsPage>(PageType.PRODUCTS);
  });

  test.afterEach(() => {
    PageFactory.clear();
  });

  test('should display all products correctly', async () => {
    await test.step('Navigate to products page', async () => {
      await productsPage.goto('/products');
      await productsPage.verifyAllProductsPageLoaded();
    });

    await test.step('Verify products are visible', async () => {
      const productsCount = await productsPage.getProductsCount();
      expect(productsCount).toBeGreaterThan(0);
    });
  });

  test('should be able to search for products', async () => {
    await test.step('Navigate to products page', async () => {
      await productsPage.goto('/products');
      await productsPage.verifyAllProductsPageLoaded();
    });

    await test.step('Search for a specific product', async () => {
      const searchTerm = TEST_PRODUCTS.SEARCH_TERMS[0];
      await productsPage.searchProduct(searchTerm);
      await productsPage.verifySearchedProductsVisible();
    });

    await test.step('Verify search results', async () => {
      const searchResultsCount = await productsPage.getProductsCount();
      expect(searchResultsCount).toBeGreaterThan(0);
    });
  });
});