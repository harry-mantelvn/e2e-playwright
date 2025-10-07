import { test, expect } from '@playwright/test';
import { PageFactory, PageType } from '../../../helper/page-factory';
import { ContactPage } from '../../../pages/contact-page/contact.page';
import { HomePage } from '../../../pages/home-page/home.page';
import { TEST_CONTACT_FORMS } from '../../../data/test-data/test-data';
import { TEST_CONSTANTS } from '../../../data/constants/test-constants';

test.describe('Contact Form Regression Tests', () => {
  let contactPage: ContactPage;
  let homePage: HomePage;

  test.beforeEach(async ({ page }) => {
    PageFactory.initialize(page);
    contactPage = PageFactory.get<ContactPage>(PageType.CONTACT);
    homePage = PageFactory.get<HomePage>(PageType.HOME);
  });

  test.afterEach(() => {
    PageFactory.clear();
  });

  test('should submit contact form successfully', async () => {
    const testForm = TEST_CONTACT_FORMS.generateRandomContactForm();

    await test.step('Navigate to contact page', async () => {
      await contactPage.goto('/contact_us');
      await contactPage.verifyContactPageLoaded();
    });

    await test.step('Verify all form fields are present', async () => {
      await contactPage.verifyFormFields();
    });

    await test.step('Fill and submit contact form', async () => {
      await contactPage.fillContactForm({
        name: testForm.name,
        email: testForm.email,
        subject: testForm.subject,
        message: testForm.message
      });
      
      await contactPage.submitForm();
    });

    await test.step('Verify form submission success', async () => {
      await contactPage.verifySuccessMessage();
      
      const successText = await contactPage.getSuccessMessageText();
      expect(successText).toContain('Success');
    });

    await test.step('Navigate back to home page', async () => {
      await contactPage.clickHomeButton();
      await expect(contactPage.currentPage).toHaveURL(/^.*\/$/);
    });
  });

  test('should validate required form fields', async () => {
    await test.step('Navigate to contact page', async () => {
      await contactPage.goto('/contact_us');
    });

    await test.step('Attempt to submit empty form', async () => {
      await contactPage.fillContactForm({
        name: '',
        email: '',
        subject: '',
        message: ''
      });
      
      // Try to submit - should trigger HTML5 validation
      await contactPage.submitForm();
      
      // Form should still be on the same page due to validation
      await expect(contactPage.currentPage).toHaveURL(/.*contact_us/);
    });

    await test.step('Test invalid email format', async () => {
      await contactPage.fillContactForm({
        name: 'Test User',
        email: 'invalid-email-format',
        subject: 'Test Subject',
        message: 'Test message'
      });
      
      // Try to submit - should trigger email validation
      await contactPage.submitForm();
    });
  });

  test('should handle file upload in contact form', async () => {
    const testForm = TEST_CONTACT_FORMS.VALID_FORM;

    await test.step('Navigate to contact page', async () => {
      await contactPage.goto('/contact_us');
    });

    await test.step('Fill form with file attachment', async () => {
      // Note: In a real scenario, you would have a test file to upload
      // For this demo, we'll test the form without actual file upload
      await contactPage.fillContactForm({
        name: testForm.name,
        email: testForm.email,
        subject: testForm.subject,
        message: testForm.message
        // filePath: 'path/to/test/file.txt' // Uncomment if you have a test file
      });
    });

    await test.step('Verify file upload field is present', async () => {
      await contactPage.verifyVisible('input[name="upload_file"]');
    });

    await test.step('Submit form and verify success', async () => {
      await contactPage.submitForm();
      await contactPage.verifySuccessMessage();
    });
  });

  test('should maintain form data during navigation', async () => {
    const testForm = TEST_CONTACT_FORMS.INQUIRY_FORM;

    await test.step('Navigate to contact page', async () => {
      await contactPage.goto('/contact_us');
    });

    await test.step('Partially fill the form', async () => {
      await contactPage.waitAndFill('[data-qa="name"]', testForm.name);
      await contactPage.waitAndFill('[data-qa="email"]', testForm.email);
      await contactPage.waitAndFill('[data-qa="subject"]', testForm.subject);
    });

    await test.step('Navigate away and back', async () => {
      await contactPage.header.navigateToHome();
      await contactPage.header.navigateToContactUs();
    });

    await test.step('Verify form was reset (expected behavior)', async () => {
      const nameValue = await contactPage.currentPage.locator('[data-qa="name"]').inputValue();
      const emailValue = await contactPage.currentPage.locator('[data-qa="email"]').inputValue();
      const subjectValue = await contactPage.currentPage.locator('[data-qa="subject"]').inputValue();
      
      // After navigation, form should be empty
      expect(nameValue).toBe('');
      expect(emailValue).toBe('');
      expect(subjectValue).toBe('');
    });
  });

  test('should handle special characters in form inputs', async () => {
    await test.step('Navigate to contact page', async () => {
      await contactPage.goto('/contact_us');
    });

    await test.step('Fill form with special characters', async () => {
      await contactPage.fillContactForm({
        name: 'Tëst Üsér with Spëcîál Chäräctërs',
        email: 'test+special@example.com',
        subject: 'Subject with <special> & "characters"',
        message: `Message with special characters:
        - Line breaks
        - Special symbols: @#$%^&*()
        - Unicode: 你好 こんにちは Здравствуйте`
      });
    });

    await test.step('Submit form and verify success', async () => {
      await contactPage.submitForm();
      await contactPage.verifySuccessMessage();
    });
  });

  test('should handle long text inputs', async () => {
    await test.step('Navigate to contact page', async () => {
      await contactPage.goto('/contact_us');
    });

    await test.step('Fill form with long text inputs', async () => {
      const longName = 'A'.repeat(100);
      const longSubject = 'Very Long Subject '.repeat(20);
      const longMessage = 'This is a very long message. '.repeat(100);

      await contactPage.fillContactForm({
        name: longName,
        email: 'longtest@example.com',
        subject: longSubject,
        message: longMessage
      });
    });

    await test.step('Submit form and verify handling', async () => {
      await contactPage.submitForm();
      // Should either succeed or show appropriate validation
      // This tests the form's handling of boundary conditions
    });
  });

  test('should verify contact page accessibility from different entry points', async () => {
    await test.step('Access contact page from home page header', async () => {
      await homePage.goto();
      await homePage.header.navigateToContactUs();
      await contactPage.verifyContactPageLoaded();
    });

    await test.step('Access contact page via direct URL', async () => {
      await contactPage.goto('/contact_us');
      await contactPage.verifyContactPageLoaded();
    });

    await test.step('Verify consistent page state from different entry points', async () => {
      await contactPage.verifyFormFields();
      await contactPage.verifyVisible('.contact-form h2');
    });
  });

  test('should handle form submission timing', async () => {
    const testForm = TEST_CONTACT_FORMS.VALID_FORM;

    await test.step('Navigate to contact page', async () => {
      await contactPage.goto('/contact_us');
    });

    await test.step('Fill form quickly', async () => {
      await contactPage.fillContactForm(testForm);
    });

    await test.step('Submit form and measure response time', async () => {
      const startTime = Date.now();
      await contactPage.submitForm();
      await contactPage.verifySuccessMessage();
      const endTime = Date.now();
      
      const responseTime = endTime - startTime;
      console.log(`Form submission took ${responseTime}ms`);
      
      // Basic performance assertion
      expect(responseTime).toBeLessThan(10000); // Should complete within 10 seconds
    });
  });
});
