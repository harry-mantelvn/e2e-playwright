import { Page } from '@playwright/test';
import { BasePage } from '../base-page.js';
import { HeaderComponent } from '../common/header.component.js';

export class ProductDetailPage extends BasePage {
  public readonly header: HeaderComponent;

  private readonly selectors = {
    productInfo: '.product-information',
    productName: '.product-information h2',
    productCategory: '.product-information p:nth-child(3)',
    productPrice: '.product-information span span',
    productAvailability: '.product-information p:has-text("Availability")',
    productCondition: '.product-information p:has-text("Condition")',
    productBrand: '.product-information p:has-text("Brand")',
    quantityInput: '#quantity',
    addToCartButton: '.btn.btn-default.cart',
    productImages: '.view-product img',
    reviewName: '#name',
    reviewEmail: '#email',
    reviewText: '#review',
    submitReviewButton: '#button-review',
    reviewSuccessMessage: '.alert-success span',
    writeReviewHeading: 'a[href="#reviews"]'
  };

  constructor(page: Page) {
    super(page);
    this.header = new HeaderComponent(page);
  }

  async verifyProductDetailPageLoaded() {
    await this.verifyVisible(this.selectors.productInfo);
    await this.verifyVisible(this.selectors.productName);
  }

  async getProductName(): Promise<string> {
    return await this.getText(this.selectors.productName);
  }

  async getProductPrice(): Promise<string> {
    return await this.getText(this.selectors.productPrice);
  }

  async getProductCategory(): Promise<string> {
    return await this.getText(this.selectors.productCategory);
  }

  async getProductAvailability(): Promise<string> {
    return await this.getText(this.selectors.productAvailability);
  }

  async getProductCondition(): Promise<string> {
    return await this.getText(this.selectors.productCondition);
  }

  async getProductBrand(): Promise<string> {
    return await this.getText(this.selectors.productBrand);
  }

  async setQuantity(quantity: string) {
    await this.page.locator(this.selectors.quantityInput).clear();
    await this.waitAndFill(this.selectors.quantityInput, quantity);
  }

  async addToCart() {
    await this.waitAndClick(this.selectors.addToCartButton);
  }

  async verifyProductImagesVisible() {
    await this.verifyVisible(this.selectors.productImages);
  }

  async writeReview(name: string, email: string, review: string) {
    await this.page.locator(this.selectors.writeReviewHeading).scrollIntoViewIfNeeded();
    await this.waitAndFill(this.selectors.reviewName, name);
    await this.waitAndFill(this.selectors.reviewEmail, email);
    await this.waitAndFill(this.selectors.reviewText, review);
    await this.waitAndClick(this.selectors.submitReviewButton);
  }

  async verifyReviewSubmitted() {
    await this.verifyVisible(this.selectors.reviewSuccessMessage);
  }

  async getProductImageCount(): Promise<number> {
    return await this.page.locator(this.selectors.productImages).count();
  }
}
