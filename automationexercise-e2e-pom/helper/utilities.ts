export class Utilities {
  static generateRandomString(length: number = 8): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }

  static generateRandomEmail(domain: string = 'test.com'): string {
    const randomString = this.generateRandomString(8);
    return `testuser_${randomString}@${domain}`;
  }

  static generateRandomPhoneNumber(): string {
    const area = Math.floor(Math.random() * 900) + 100; // 3 digits
    const exchange = Math.floor(Math.random() * 900) + 100; // 3 digits
    const number = Math.floor(Math.random() * 9000) + 1000; // 4 digits
    return `${area}${exchange}${number}`;
  }

  static generateRandomZipCode(): string {
    return Math.floor(Math.random() * 90000 + 10000).toString();
  }

  static waitForTime(milliseconds: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
  }

  static formatPrice(price: string): number {
    return parseFloat(price.replace(/[Rs. ]/g, ''));
  }

  static getCurrentDate(): string {
    return new Date().toISOString().split('T')[0];
  }

  static getCurrentDateTime(): string {
    return new Date().toISOString();
  }

  static getRandomArrayElement<T>(array: T[]): T {
    return array[Math.floor(Math.random() * array.length)];
  }

  static capitalizeFirstLetter(text: string): string {
    return text.charAt(0).toUpperCase() + text.slice(1).toLowerCase();
  }

  static generateUniqueId(): string {
    return Date.now().toString() + Math.random().toString(36).substr(2, 9);
  }

  static delay(milliseconds: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
  }

  static isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  static sanitizeFileName(fileName: string): string {
    return fileName.replace(/[^a-z0-9]/gi, '_').toLowerCase();
  }

  static getRandomNumber(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }
}
