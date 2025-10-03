import { test } from '@playwright/test';

test('basic test', async ({ page }) => {
  await page.goto('https://www.automationexercise.com');
  console.log('Basic test passed - site loads successfully');
});
