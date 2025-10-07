import { chromium, FullConfig } from '@playwright/test';
import { StorageHelper } from './storage-helper.js';
import ENV from './env-config.js';

async function globalSetup(config: FullConfig) {
  // Create browser and context for setup
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();
  
  try {
    // Navigate to base URL to ensure site is accessible
    await page.goto(ENV.BASE_URL);
    
    // Clear any existing storage state
    await StorageHelper.clearStorageState();
    
    // Perform any other global setup tasks here
    // For example: database seeding, API setup, etc.
    
  } catch (error) {
    console.error('Global setup failed:', error);
    throw error;
  } finally {
    await browser.close();
  }
}

export default globalSetup;
