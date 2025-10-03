import { Page } from '@playwright/test';
import { BasePage } from '../base-page.js';
import { HeaderComponent } from '../common/header.component.js';

export class CheckoutPage extends BasePage {
  public readonly header: HeaderComponent;

  private readonly selectors = {
    // Address sections
    deliveryAddress: '.checkout-information .address.delivery',
    billingAddress: '.checkout-information .address.billing',
    
    // Order review
    orderReview: '#cart_info_table',
    cartItems: '#cart_info_table tbody tr',
    productDescription: '.cart_description a',
    productPrice: '.cart_price p',
    productQuantity: '.cart_quantity button',
    productTotal: '.cart_total p',
    
    // Comment section
    commentTextarea: 'textarea[name="message"]',
    
    // Payment and order
    placeOrderButton: 'a[href="/payment"]',
    
    // Address details selectors
    addressName: '.address_firstname.address_lastname',
    addressCompany: '.address_address1:nth-child(3)',
    addressLine1: '.address_address1:nth-child(4)',
    addressLine2: '.address_address1:nth-child(5)',
    addressCityStateZip: '.address_city.address_state_name.address_postcode',
    addressCountry: '.address_country_name',
    addressPhone: '.address_phone'
  };

  constructor(page: Page) {
    super(page);
    this.header = new HeaderComponent(page);
  }

  async verifyCheckoutPageLoaded() {
    await this.verifyVisible(this.selectors.deliveryAddress);
    await this.verifyVisible(this.selectors.billingAddress);
    await this.verifyVisible(this.selectors.orderReview);
  }

  async verifyDeliveryAddress(expectedAddress: {
    name?: string;
    company?: string;
    address1?: string;
    address2?: string;
    cityStateZip?: string;
    country?: string;
    phone?: string;
  }) {
    const deliverySection = this.page.locator(this.selectors.deliveryAddress);
    
    if (expectedAddress.name) {
      await deliverySection.locator(this.selectors.addressName).filter({ hasText: expectedAddress.name }).first().waitFor();
    }
    if (expectedAddress.company) {
      await deliverySection.locator(this.selectors.addressCompany).filter({ hasText: expectedAddress.company }).first().waitFor();
    }
    if (expectedAddress.address1) {
      await deliverySection.locator(this.selectors.addressLine1).filter({ hasText: expectedAddress.address1 }).first().waitFor();
    }
    if (expectedAddress.country) {
      await deliverySection.locator(this.selectors.addressCountry).filter({ hasText: expectedAddress.country }).first().waitFor();
    }
  }

  async verifyBillingAddress(expectedAddress: {
    name?: string;
    company?: string;
    address1?: string;
    address2?: string;
    cityStateZip?: string;
    country?: string;
    phone?: string;
  }) {
    const billingSection = this.page.locator(this.selectors.billingAddress);
    
    if (expectedAddress.name) {
      await billingSection.locator(this.selectors.addressName).filter({ hasText: expectedAddress.name }).first().waitFor();
    }
    if (expectedAddress.company) {
      await billingSection.locator(this.selectors.addressCompany).filter({ hasText: expectedAddress.company }).first().waitFor();
    }
    if (expectedAddress.address1) {
      await billingSection.locator(this.selectors.addressLine1).filter({ hasText: expectedAddress.address1 }).first().waitFor();
    }
    if (expectedAddress.country) {
      await billingSection.locator(this.selectors.addressCountry).filter({ hasText: expectedAddress.country }).first().waitFor();
    }
  }

  async getOrderItemsCount(): Promise<number> {
    return await this.page.locator(this.selectors.cartItems).count();
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

  async addComment(comment: string) {
    await this.waitAndFill(this.selectors.commentTextarea, comment);
  }

  async placeOrder() {
    await this.waitAndClick(this.selectors.placeOrderButton);
  }

  async verifyProductInOrder(productName: string) {
    await this.verifyVisible(`${this.selectors.cartItems}:has-text("${productName}")`);
  }

  async calculateTotalAmount(): Promise<number> {
    const totalElements = await this.page.locator(`${this.selectors.cartItems} ${this.selectors.productTotal}`).allInnerTexts();
    let total = 0;
    
    for (const priceText of totalElements) {
      const price = parseFloat(priceText.replace(/[Rs. ]/g, ''));
      total += price;
    }
    
    return total;
  }

  async getAllProductNames(): Promise<string[]> {
    return await this.page.locator(`${this.selectors.cartItems} ${this.selectors.productDescription}`).allInnerTexts();
  }
}
