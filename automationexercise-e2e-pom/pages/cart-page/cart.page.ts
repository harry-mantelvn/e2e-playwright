import { Page } from '@playwright/test';
import { BasePage } from '../base-page.js';
import { HeaderComponent } from '../common/header.component.js';

export class CartPage extends BasePage {
  public readonly header: HeaderComponent;

  private readonly selectors = {
    cartInfo: '.cart_info',
    cartItems: '#cart_info_table tbody tr',
    productImage: '.cart_product img',
    productDescription: '.cart_description a',
    productPrice: '.cart_price p',
    productQuantity: '.cart_quantity button',
    productTotal: '.cart_total p',
    removeButton: '.cart_quantity_delete',
    proceedToCheckoutButton: '.btn-default.check_out',
    emptyCartMessage: 'p:has-text("Cart is empty")',
    registerLoginLink: 'a[href="/login"]',
    subscriptionText: '.single-widget h2',
    subscriptionEmail: '#susbscribe_email',
    subscribeButton: '#subscribe',
    successMessage: '.alert-success'
  };

  constructor(page: Page) {
    super(page);
    this.header = new HeaderComponent(page);
  }

  async verifyCartPageLoaded() {
    await this.verifyVisible(this.selectors.cartInfo);
  }

  async getCartItemsCount(): Promise<number> {
    try {
      return await this.page.locator(this.selectors.cartItems).count();
    } catch {
      return 0;
    }
  }

  async getProductNameByIndex(index: number): Promise<string> {
    return await this.page.locator(this.selectors.cartItems).nth(index).locator(this.selectors.productDescription).innerText();
  }

  async getProductPriceByIndex(index: number): Promise<string> {
    return await this.page.locator(this.selectors.cartItems).nth(index).locator(this.selectors.productPrice).innerText();
  }

  async getProductQuantityByIndex(index: number): Promise<string> {
    return await this.page.locator(this.selectors.cartItems).nth(index).locator(this.selectors.productQuantity).innerText();
  }

  async getProductTotalByIndex(index: number): Promise<string> {
    return await this.page.locator(this.selectors.cartItems).nth(index).locator(this.selectors.productTotal).innerText();
  }

  async removeProductByIndex(index: number) {
    await this.page.locator(this.selectors.cartItems).nth(index).locator(this.selectors.removeButton).click();
  }

  async removeProductByName(productName: string) {
    const productRow = this.page.locator(this.selectors.cartItems).filter({ hasText: productName });
    await productRow.locator(this.selectors.removeButton).click();
  }

  async proceedToCheckout() {
    await this.waitAndClick(this.selectors.proceedToCheckoutButton);
  }

  async verifyEmptyCart() {
    await this.verifyVisible(this.selectors.emptyCartMessage);
  }

  async clickRegisterLogin() {
    await this.waitAndClick(this.selectors.registerLoginLink);
  }

  async subscribeToNewsletter(email: string) {
    await this.page.locator(this.selectors.subscriptionEmail).scrollIntoViewIfNeeded();
    await this.waitAndFill(this.selectors.subscriptionEmail, email);
    await this.waitAndClick(this.selectors.subscribeButton);
  }

  async verifySubscriptionSuccess() {
    await this.verifyVisible(this.selectors.successMessage);
  }

  async verifyProductInCart(productName: string) {
    await this.verifyVisible(`${this.selectors.cartItems}:has-text("${productName}")`);
  }

  async getAllProductNames(): Promise<string[]> {
    const productElements = await this.page.locator(`${this.selectors.cartItems} ${this.selectors.productDescription}`).allInnerTexts();
    return productElements;
  }

  async getTotalPrice(): Promise<string> {
    const totalElements = await this.page.locator(`${this.selectors.cartItems} ${this.selectors.productTotal}`).allInnerTexts();
    let total = 0;
    for (const priceText of totalElements) {
      const price = parseFloat(priceText.replace(/[Rs. ]/g, ''));
      total += price;
    }
    return `Rs. ${total}`;
  }
}
