import { Page } from '@playwright/test';
import { BasePage } from '../base-page';
import { HeaderComponent } from '../common/header.component';

export class HomePage extends BasePage {
  public readonly header: HeaderComponent;

  private readonly selectors = {
    homeBanner: '#slider-carousel',
    featuresItems: '.features_items',
    productItem: '.single-products',
    categoryMenu: '.left-sidebar .panel-group',
    brandsList: '.brands_products',
    subscriptionEmail: '#susbscribe_email',
    subscribeButton: '#subscribe',
    successMessage: '.alert-success'
  };

  constructor(page: Page) {
    super(page);
    this.header = new HeaderComponent(page);
  }

  async verifyHomePageLoaded() {
    await this.verifyVisible(this.selectors.homeBanner);
    await this.verifyVisible(this.selectors.featuresItems);
  }

  async scrollToFeaturedItems() {
    await this.page.locator(this.selectors.featuresItems).scrollIntoViewIfNeeded();
  }

  async getProductsCount(): Promise<number> {
    return await this.page.locator(this.selectors.productItem).count();
  }

  async clickProductByIndex(index: number) {
    await this.waitAndClick(`${this.selectors.productItem} .choose a`, index);
  }

  async addProductToCartByIndex(index: number) {
    const addToCartButton = this.page.locator(`${this.selectors.productItem}`).nth(index).locator('.add-to-cart').first();
    await addToCartButton.click();
  }

  async subscribeToNewsletter(email: string) {
    await this.page.locator(this.selectors.subscriptionEmail).scrollIntoViewIfNeeded();
    await this.waitAndFill(this.selectors.subscriptionEmail, email);
    await this.waitAndClick(this.selectors.subscribeButton);
  }

  async verifySubscriptionSuccess() {
    await this.verifyVisible(this.selectors.successMessage);
  }

  async clickCategoryByName(categoryName: string) {
    await this.waitAndClick(`${this.selectors.categoryMenu} a:has-text("${categoryName}")`);
  }

  async clickBrandByName(brandName: string) {
    await this.waitAndClick(`${this.selectors.brandsList} a:has-text("${brandName}")`);
  }
}
