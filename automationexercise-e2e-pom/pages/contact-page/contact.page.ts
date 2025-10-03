import { Page } from '@playwright/test';
import { BasePage } from '../base-page.js';
import { HeaderComponent } from '../common/header.component.js';

export class ContactPage extends BasePage {
  public readonly header: HeaderComponent;

  private readonly selectors = {
    contactForm: '.contact-form',
    getInTouchHeading: '.contact-form h2',
    nameInput: '[data-qa="name"]',
    emailInput: '[data-qa="email"]',
    subjectInput: '[data-qa="subject"]',
    messageTextarea: '[data-qa="message"]',
    fileUpload: 'input[name="upload_file"]',
    submitButton: '[data-qa="submit-button"]',
    successMessage: '.status.alert.alert-success',
    homeButton: '.btn.btn-success'
  };

  constructor(page: Page) {
    super(page);
    this.header = new HeaderComponent(page);
  }

  async verifyContactPageLoaded() {
    await this.verifyVisible(this.selectors.contactForm);
    await this.verifyVisible(this.selectors.getInTouchHeading);
  }

  async fillContactForm(contactDetails: {
    name: string;
    email: string;
    subject: string;
    message: string;
    filePath?: string;
  }) {
    await this.waitAndFill(this.selectors.nameInput, contactDetails.name);
    await this.waitAndFill(this.selectors.emailInput, contactDetails.email);
    await this.waitAndFill(this.selectors.subjectInput, contactDetails.subject);
    await this.waitAndFill(this.selectors.messageTextarea, contactDetails.message);
    
    if (contactDetails.filePath) {
      await this.page.locator(this.selectors.fileUpload).setInputFiles(contactDetails.filePath);
    }
  }

  async submitForm() {
    // Handle the alert dialog that appears when submitting
    this.page.on('dialog', async dialog => {
      await dialog.accept();
    });
    
    await this.waitAndClick(this.selectors.submitButton);
  }

  async verifySuccessMessage() {
    await this.verifyVisible(this.selectors.successMessage);
  }

  async clickHomeButton() {
    await this.waitAndClick(this.selectors.homeButton);
  }

  async getSuccessMessageText(): Promise<string> {
    return await this.getText(this.selectors.successMessage);
  }

  async verifyFormFields() {
    await this.verifyVisible(this.selectors.nameInput);
    await this.verifyVisible(this.selectors.emailInput);
    await this.verifyVisible(this.selectors.subjectInput);
    await this.verifyVisible(this.selectors.messageTextarea);
    await this.verifyVisible(this.selectors.fileUpload);
    await this.verifyVisible(this.selectors.submitButton);
  }
}
