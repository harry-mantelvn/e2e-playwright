import { Page } from '@playwright/test';
import { BasePage } from '../base-page.js';
import { HeaderComponent } from '../common/header.component.js';

export class ProductsPage extends BasePage {
  public readonly header: HeaderComponent;

  private readonly selectors = {
    allProductsHeading: '.title',
    productsList: '.features_items',
    productItem: '.single-products',
    productImage: '.productinfo img',
    productName: '.productinfo p',
    productPrice: '.productinfo h2',
    addToCartButton: '.add-to-cart',
    viewProductButton: '.choose a',
    searchBox: '#search_product',
    searchButton: '#submit_search',
    searchedProductsHeading: '.title:has-text("Searched Products")',
    brandFilter: '.brands_products a',
    categoryFilter: '.left-sidebar .panel-group a',
    continueShoppingButton: '.btn-success',
    viewCartButton: 'a[href="/view_cart"]'
  };

  constructor(page: Page) {
    super(page);
    this.header = new HeaderComponent(page);
  }

  async verifyAllProductsPageLoaded() {
    await this.verifyVisible(this.selectors.allProductsHeading);
    await this.verifyVisible(this.selectors.productsList);
  }

  async getProductsCount(): Promise<number> {
    return await this.page.locator(this.selectors.productItem).count();
  }

  async searchProduct(productName: string) {
    await this.waitAndFill(this.selectors.searchBox, productName);
    await this.waitAndClick(this.selectors.searchButton);
  }

  async verifySearchedProductsVisible() {
    await this.verifyVisible(this.selectors.searchedProductsHeading);
  }

  async getProductNameByIndex(index: number): Promise<string> {
    return await this.page.locator(this.selectors.productItem).nth(index).locator(this.selectors.productName).innerText();
  }

  async getProductPriceByIndex(index: number): Promise<string> {
    return await this.page.locator(this.selectors.productItem).nth(index).locator(this.selectors.productPrice).innerText();
  }

  async viewProductByIndex(index: number) {
    await this.page.locator(this.selectors.productItem).nth(index).locator(this.selectors.viewProductButton).click();
  }

  async addProductToCartByIndex(index: number) {
    const productItem = this.page.locator(this.selectors.productItem).nth(index);
    await productItem.hover();
    await productItem.locator(this.selectors.addToCartButton).first().click();
  }

  async addProductToCartByName(productName: string) {
    const productItem = this.page.locator(this.selectors.productItem).filter({ hasText: productName });
    await productItem.hover();
    await productItem.locator(this.selectors.addToCartButton).click();
  }

  async continueShopping() {
    await this.waitAndClick(this.selectors.continueShoppingButton);
  }

  async viewCart() {
    await this.waitAndClick(this.selectors.viewCartButton);
  }

  async filterByBrand(brandName: string) {
    await this.waitAndClick(`${this.selectors.brandFilter}:has-text("${brandName}")`);
  }

  async filterByCategory(categoryName: string) {
    await this.waitAndClick(`${this.selectors.categoryFilter}:has-text("${categoryName}")`);
  }

  async verifyProductInSearchResults(productName: string) {
    await this.verifyVisible(`${this.selectors.productItem}:has-text("${productName}")`);
  }

  async getAllVisibleProductNames(): Promise<string[]> {
    const productNames = await this.page.locator(`${this.selectors.productItem} ${this.selectors.productName}`).allInnerTexts();
    return productNames;
  }
}
