import { Page } from '@playwright/test';
import { BasePage } from '../pages/base-page';
import { HomePage } from '../pages/home-page/home.page';
import { AuthPage } from '../pages/auth-page/auth.page';
import { ProductsPage } from '../pages/products-page/products.page';
import { ProductDetailPage } from '../pages/product-detail-page/product-detail.page';
import { CartPage } from '../pages/cart-page/cart.page';
import { CheckoutPage } from '../pages/checkout-page/checkout.page';
import { ContactPage } from '../pages/contact-page/contact.page';

export enum PageType {
  HOME = 'home',
  AUTH = 'auth',
  PRODUCTS = 'products',
  PRODUCT_DETAIL = 'product_detail',
  CART = 'cart',
  CHECKOUT = 'checkout',
  CONTACT = 'contact'
}

export class PageFactory {
  private static page: Page;
  private static cache = new Map<string, BasePage>();

  static initialize(page: Page) { 
    this.page = page; 
  }

  static get<T extends BasePage>(type: PageType): T {
    if (this.cache.has(type)) return this.cache.get(type) as T;
    
    let instance: BasePage;
    switch (type) {
      case PageType.HOME: 
        instance = new HomePage(this.page); 
        break;
      case PageType.AUTH: 
        instance = new AuthPage(this.page); 
        break;
      case PageType.PRODUCTS: 
        instance = new ProductsPage(this.page); 
        break;
      case PageType.PRODUCT_DETAIL:
        instance = new ProductDetailPage(this.page);
        break;
      case PageType.CART: 
        instance = new CartPage(this.page); 
        break;
      case PageType.CHECKOUT: 
        instance = new CheckoutPage(this.page); 
        break;
      case PageType.CONTACT: 
        instance = new ContactPage(this.page); 
        break;
      default: 
        throw new Error(`PageType not supported: ${type}`);
    }
    
    this.cache.set(type, instance);
    return instance as T;
  }

  static clear() { 
    this.cache.clear(); 
  }
}
