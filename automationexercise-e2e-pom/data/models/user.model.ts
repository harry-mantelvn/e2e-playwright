export interface User {
  name: string;
  email: string;
  password: string;
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
}

export interface AccountDetails {
  gender: 'Mr' | 'Mrs';
  password: string;
  day: string;
  month: string;
  year: string;
  newsletter?: boolean;
  offers?: boolean;
}

export interface AddressDetails {
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
}

export interface Product {
  name: string;
  price: string;
  category: string;
  brand?: string;
  availability?: string;
  condition?: string;
}

export interface CartItem {
  productName: string;
  price: string;
  quantity: number;
  total: string;
}

export interface ContactForm {
  name: string;
  email: string;
  subject: string;
  message: string;
  filePath?: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface SignupData {
  name: string;
  email: string;
}
