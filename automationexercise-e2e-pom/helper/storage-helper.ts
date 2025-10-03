import { Page, BrowserContext } from '@playwright/test';
import * as fs from 'fs';
import path from 'path';

export class StorageHelper {
  private static readonly STORAGE_STATE_PATH = 'storage-state/storageState.json';

  static async saveStorageState(context: BrowserContext): Promise<void> {
    const storageStatePath = path.resolve(this.STORAGE_STATE_PATH);
    const storageStateDir = path.dirname(storageStatePath);
    
    // Ensure directory exists
    if (!fs.existsSync(storageStateDir)) {
      fs.mkdirSync(storageStateDir, { recursive: true });
    }

    await context.storageState({ path: storageStatePath });
    console.log(`Storage state saved to: ${storageStatePath}`);
  }

  static async loadStorageState(): Promise<string | undefined> {
    const storageStatePath = path.resolve(this.STORAGE_STATE_PATH);
    
    if (fs.existsSync(storageStatePath)) {
      console.log(`Loading storage state from: ${storageStatePath}`);
      return storageStatePath;
    }
    
    console.log('No storage state file found, starting fresh session');
    return undefined;
  }

  static async clearStorageState(): Promise<void> {
    const storageStatePath = path.resolve(this.STORAGE_STATE_PATH);
    
    if (fs.existsSync(storageStatePath)) {
      fs.unlinkSync(storageStatePath);
      console.log('Storage state cleared');
    }
  }

  static async isUserLoggedIn(): Promise<boolean> {
    const storageStatePath = path.resolve(this.STORAGE_STATE_PATH);
    
    if (!fs.existsSync(storageStatePath)) {
      return false;
    }

    try {
      const storageStateContent = fs.readFileSync(storageStatePath, 'utf-8');
      const storageState = JSON.parse(storageStateContent);
      
      // Check if there are any cookies (basic check for login state)
      return storageState.cookies && storageState.cookies.length > 0;
    } catch (error) {
      console.log('Error reading storage state:', error);
      return false;
    }
  }

  static async setLocalStorage(page: Page, key: string, value: string): Promise<void> {
    await page.evaluate(({ key, value }) => {
      localStorage.setItem(key, value);
    }, { key, value });
  }

  static async getLocalStorage(page: Page, key: string): Promise<string | null> {
    return await page.evaluate((key) => {
      return localStorage.getItem(key);
    }, key);
  }

  static async clearLocalStorage(page: Page): Promise<void> {
    await page.evaluate(() => {
      localStorage.clear();
    });
  }

  static async setSessionStorage(page: Page, key: string, value: string): Promise<void> {
    await page.evaluate(({ key, value }) => {
      sessionStorage.setItem(key, value);
    }, { key, value });
  }

  static async getSessionStorage(page: Page, key: string): Promise<string | null> {
    return await page.evaluate((key) => {
      return sessionStorage.getItem(key);
    }, key);
  }

  static async clearSessionStorage(page: Page): Promise<void> {
    await page.evaluate(() => {
      sessionStorage.clear();
    });
  }
}
