import { User, ContactForm, LoginCredentials } from '../models/user.model';
import { Utilities } from '../../helper/utilities';

export const TEST_USERS = {
  VALID_USER: {
    name: 'John Doe',
    email: 'john.doe@test.com',
    password: 'password123',
    firstName: 'John',
    lastName: 'Doe',
    company: 'Test Company Inc',
    address1: '123 Main Street',
    address2: 'Apartment 4B',
    country: 'United States',
    state: 'California',
    city: 'San Francisco',
    zipcode: '94105',
    mobileNumber: '5551234567'
  } as User,
  
  INVALID_USER: {
    email: 'invalid@test.com',
    password: 'wrongpassword'
  } as LoginCredentials,
  
  generateRandomUser: (): User => ({
    name: `Test User ${Utilities.generateRandomString(5)}`,
    email: Utilities.generateRandomEmail(),
    password: 'password123',
    firstName: 'Test',
    lastName: 'User',
    company: 'Test Company',
    address1: '123 Test Street',
    address2: 'Suite 100',
    country: 'United States',
    state: 'California',
    city: 'Test City',
    zipcode: Utilities.generateRandomZipCode(),
    mobileNumber: Utilities.generateRandomPhoneNumber()
  })
};

export const TEST_CONTACT_FORMS = {
  VALID_FORM: {
    name: 'Test User',
    email: 'testuser@example.com',
    subject: 'Test Subject',
    message: 'This is a test message for automation testing purposes.'
  } as ContactForm,
  
  INQUIRY_FORM: {
    name: 'Customer Service Inquiry',
    email: 'customer@example.com',
    subject: 'Product Inquiry',
    message: 'I would like to know more about your products and shipping policies.'
  } as ContactForm,
  
  generateRandomContactForm: (): ContactForm => ({
    name: `Test User ${Utilities.generateRandomString(5)}`,
    email: Utilities.generateRandomEmail(),
    subject: `Test Subject ${Utilities.generateRandomString(8)}`,
    message: `This is a test message generated on ${Utilities.getCurrentDateTime()}`
  })
};

export const TEST_PRODUCTS = {
  SEARCH_TERMS: [
    'Blue Top',
    'Men Tshirt',
    'Dress',
    'Jeans',
    'Shirt'
  ],
  
  CATEGORIES: [
    'Women',
    'Men', 
    'Kids'
  ],
  
  BRANDS: [
    'Polo',
    'H&M',
    'Madame',
    'Mast & Harbour',
    'Babyhug'
  ]
};

export const NEWSLETTER_EMAILS = [
  'newsletter1@test.com',
  'newsletter2@test.com',
  'newsletter3@test.com'
];
