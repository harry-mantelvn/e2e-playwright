import { Page } from '@playwright/test';
import { BasePage } from '../base-page';

export class HeaderComponent extends BasePage {
  private readonly selectors = {
    logo: '[alt="Website for automation practice"]',
    homeLink: 'a[href="/"]',
    productsLink: 'a[href="/products"]',
    cartLink: 'a[href="/view_cart"]',
    signupLoginLink: 'a[href="/login"]',
    contactUsLink: 'a[href="/contact_us"]',
    loggedInUser: '.navbar-nav li:has-text("Logged in as")',
    logoutLink: 'a[href="/logout"]',
    deleteAccountLink: 'a[href="/delete_account"]'
  };

  constructor(page: Page) {
    super(page);
  }

  async clickLogo() {
    await this.waitAndClick(this.selectors.logo);
  }

  async navigateToHome() {
    await this.waitAndClick(this.selectors.homeLink);
  }

  async navigateToProducts() {
    await this.waitAndClick(this.selectors.productsLink);
  }

  async navigateToCart() {
    await this.waitAndClick(this.selectors.cartLink);
  }

  async navigateToSignupLogin() {
    await this.waitAndClick(this.selectors.signupLoginLink);
  }

  async navigateToContactUs() {
    await this.waitAndClick(this.selectors.contactUsLink);
  }

  async logout() {
    await this.waitAndClick(this.selectors.logoutLink);
  }

  async deleteAccount() {
    await this.waitAndClick(this.selectors.deleteAccountLink);
  }

  async verifyUserLoggedIn(username: string) {
    await this.verifyVisible(`${this.selectors.loggedInUser}:has-text("${username}")`);
  }

  async isUserLoggedIn(): Promise<boolean> {
    try {
      await this.page.locator(this.selectors.loggedInUser).waitFor({ timeout: 5000 });
      return true;
    } catch {
      return false;
    }
  }
}
