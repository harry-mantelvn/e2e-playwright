export const USER_SCHEMA = {
  name: 'string',
  email: 'string',
  password: 'string',
  firstName: 'string',
  lastName: 'string',
  company: 'string',
  address1: 'string',
  address2: 'string',
  country: 'string',
  state: 'string',
  city: 'string',
  zipcode: 'string',
  mobileNumber: 'string'
};

export const PRODUCT_SCHEMA = {
  id: 'number',
  name: 'string',
  price: 'string',
  brand: 'string',
  category: 'object'
};

export const CART_ITEM_SCHEMA = {
  productName: 'string',
  price: 'string',
  quantity: 'number',
  total: 'string'
};

export const CONTACT_FORM_SCHEMA = {
  name: 'string',
  email: 'string',
  subject: 'string',
  message: 'string'
};

export const API_RESPONSE_SCHEMA = {
  responseCode: 'number',
  products: 'object'
};
