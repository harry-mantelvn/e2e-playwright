import { Page, expect } from '@playwright/test';

export class BasePage {
  constructor(protected readonly page: Page) {}

  get currentPage(): Page {
    return this.page;
  }

  async goto(path: string = '/') { 
    await this.page.goto(path); 
  }

  async waitAndClick(locator: string, index = 0) {
    const el = this.page.locator(locator).nth(index);
    await el.waitFor({ state: 'visible' });
    await el.click();
  }

  async waitAndFill(locator: string, value: string, index = 0) {
    const el = this.page.locator(locator).nth(index);
    await el.waitFor({ state: 'visible' });
    await el.fill(value);
  }

  async verifyVisible(locator: string) {
    await expect(this.page.locator(locator).first()).toBeVisible();
  }

  async getText(locator: string) {
    return this.page.locator(locator).innerText();
  }
}
