import { Page } from '@playwright/test';
import { BasePage } from '../base-page.js';
import { HeaderComponent } from '../common/header.component.js';

export class AuthPage extends BasePage {
  public readonly header: HeaderComponent;

  private readonly selectors = {
    // Login section
    loginEmail: '[data-qa="login-email"]',
    loginPassword: '[data-qa="login-password"]',
    loginButton: '[data-qa="login-button"]',
    loginForm: '.login-form',
    loginHeading: '.login-form h2',

    // Signup section
    signupName: '[data-qa="signup-name"]',
    signupEmail: '[data-qa="signup-email"]',
    signupButton: '[data-qa="signup-button"]',
    signupForm: '.signup-form',
    signupHeading: '.signup-form h2',

    // Account Information Form
    genderMr: '#id_gender1',
    genderMrs: '#id_gender2',
    password: '[data-qa="password"]',
    dayOfBirth: '[data-qa="days"]',
    monthOfBirth: '[data-qa="months"]',
    yearOfBirth: '[data-qa="years"]',
    newsletterCheckbox: '#newsletter',
    optinCheckbox: '#optin',

    // Address Information
    firstName: '[data-qa="first_name"]',
    lastName: '[data-qa="last_name"]',
    company: '[data-qa="company"]',
    address1: '[data-qa="address"]',
    address2: '[data-qa="address2"]',
    country: '[data-qa="country"]',
    state: '[data-qa="state"]',
    city: '[data-qa="city"]',
    zipcode: '[data-qa="zipcode"]',
    mobileNumber: '[data-qa="mobile_number"]',

    createAccountButton: '[data-qa="create-account"]',
    accountCreatedMessage: '[data-qa="account-created"]',
    continueButton: '[data-qa="continue-button"]',

    // Error messages
    loginErrorMessage: '.login-form p',
    emailExistsError: '.signup-form p'
  };

  constructor(page: Page) {
    super(page);
    this.header = new HeaderComponent(page);
  }

  async verifyLoginFormVisible() {
    await this.verifyVisible(this.selectors.loginForm);
    await this.verifyVisible(this.selectors.loginHeading);
  }

  async verifySignupFormVisible() {
    await this.verifyVisible(this.selectors.signupForm);
    await this.verifyVisible(this.selectors.signupHeading);
  }

  async loginUser(email: string, password: string) {
    await this.waitAndFill(this.selectors.loginEmail, email);
    await this.waitAndFill(this.selectors.loginPassword, password);
    await this.waitAndClick(this.selectors.loginButton);
  }

  async signupUser(name: string, email: string) {
    await this.waitAndFill(this.selectors.signupName, name);
    await this.waitAndFill(this.selectors.signupEmail, email);
    await this.waitAndClick(this.selectors.signupButton);
  }

  async fillAccountInformation(accountDetails: {
    gender: 'Mr' | 'Mrs';
    password: string;
    day: string;
    month: string;
    year: string;
    newsletter?: boolean;
    offers?: boolean;
  }) {
    // Select gender
    if (accountDetails.gender === 'Mr') {
      await this.waitAndClick(this.selectors.genderMr);
    } else {
      await this.waitAndClick(this.selectors.genderMrs);
    }

    // Fill password
    await this.waitAndFill(this.selectors.password, accountDetails.password);

    // Select date of birth
    await this.page.locator(this.selectors.dayOfBirth).selectOption(accountDetails.day);
    await this.page.locator(this.selectors.monthOfBirth).selectOption(accountDetails.month);
    await this.page.locator(this.selectors.yearOfBirth).selectOption(accountDetails.year);

    // Newsletter and offers
    if (accountDetails.newsletter) {
      await this.waitAndClick(this.selectors.newsletterCheckbox);
    }
    if (accountDetails.offers) {
      await this.waitAndClick(this.selectors.optinCheckbox);
    }
  }

  async fillAddressInformation(addressDetails: {
    firstName: string;
    lastName: string;
    company?: string;
    address1: string;
    address2?: string;
    country: string;
    state: string;
    city: string;
    zipcode: string;
    mobileNumber: string;
  }) {
    await this.waitAndFill(this.selectors.firstName, addressDetails.firstName);
    await this.waitAndFill(this.selectors.lastName, addressDetails.lastName);
    
    if (addressDetails.company) {
      await this.waitAndFill(this.selectors.company, addressDetails.company);
    }
    
    await this.waitAndFill(this.selectors.address1, addressDetails.address1);
    
    if (addressDetails.address2) {
      await this.waitAndFill(this.selectors.address2, addressDetails.address2);
    }
    
    await this.page.locator(this.selectors.country).selectOption(addressDetails.country);
    await this.waitAndFill(this.selectors.state, addressDetails.state);
    await this.waitAndFill(this.selectors.city, addressDetails.city);
    await this.waitAndFill(this.selectors.zipcode, addressDetails.zipcode);
    await this.waitAndFill(this.selectors.mobileNumber, addressDetails.mobileNumber);
  }

  async createAccount() {
    await this.waitAndClick(this.selectors.createAccountButton);
  }

  async verifyAccountCreated() {
    await this.verifyVisible(this.selectors.accountCreatedMessage);
  }

  async clickContinue() {
    await this.waitAndClick(this.selectors.continueButton);
  }

  async verifyLoginError() {
    await this.verifyVisible(this.selectors.loginErrorMessage);
  }

  async verifyEmailExistsError() {
    await this.verifyVisible(this.selectors.emailExistsError);
  }
}
