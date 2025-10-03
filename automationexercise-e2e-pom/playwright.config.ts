import { PlaywrightTestConfig } from '@playwright/test';
import * as dotenv from 'dotenv';
import * as path from 'path';

const nodeEnv = process.env.NODE_ENV || 'test';
dotenv.config({ path: path.resolve(process.cwd(), `environments/.env.${nodeEnv}`) });

const config: PlaywrightTestConfig = {
  testDir: './tests',
  timeout: 60_000,
  expect: { timeout: 10_000 },
  retries: 0,
  reporter: [
    ['html', { open: 'never', outputFolder: './test-reports/html' }],
    ['line'],
    ['allure-playwright', { outputFolder: './test-reports/allure-results', detail: true }]
  ],
  use: {
    baseURL: process.env.BASE_URL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    storageState: 'storage-state/storageState.json'
  },
  projects: [
    { 
      name: 'chromium', 
      use: { 
        browserName: 'chromium',
        viewport: { width: 1280, height: 720 }
      } 
    }
  ],
};

export default config;
