# Automation Exercise E2E Testing Framework

A comprehensive Playwright + TypeScript automation framework for testing [AutomationExercise.com](https://www.automationexercise.com) with enterprise-ready structure and best practices.

## Tech Stack

- **Language**: TypeScript
- **Test Runner**: @playwright/test
- **Node Version**: 18+
- **Design Pattern**: Page Object Model (POM) + Page Factory
- **Reports**: Allure + HTML reports
- **Environment Management**: dotenv + cross-env
- **Authentication**: Persistent storage state

## Project Structure

```
automationexercise-e2e/
├── data/
│   ├── constants/          # Test constants and enums
│   ├── models/            # TypeScript interfaces and types
│   ├── schemas/           # API response schemas
│   └── test-data/         # Test data and fixtures
├── environments/
│   ├── .env.test          # Test environment configuration
│   └── .env.prerelease    # Prerelease environment configuration
├── helper/
│   ├── api-helper.ts      # API testing utilities
│   ├── authentication-setup.ts  # Auth setup for tests
│   ├── env-config.ts      # Environment configuration
│   ├── global-setup.ts    # Global test setup
│   ├── page-factory.ts    # Page object factory pattern
│   ├── storage-helper.ts  # Storage state management
│   └── utilities.ts       # Common utility functions
├── pages/
│   ├── base-page.ts       # Base page class
│   ├── common/
│   │   └── header.component.ts  # Shared header component
│   ├── home-page/
│   │   └── home.page.ts   # Home page object
│   ├── auth-page/
│   │   └── auth.page.ts   # Authentication page object
│   ├── products-page/
│   │   └── products.page.ts  # Products listing page
│   ├── product-detail-page/
│   │   └── product-detail.page.ts  # Product detail page
│   ├── cart-page/
│   │   └── cart.page.ts   # Shopping cart page
│   ├── checkout-page/
│   │   └── checkout.page.ts  # Checkout process page
│   └── contact-page/
│       └── contact.page.ts  # Contact form page
├── tests/
│   ├── smoke/             # Smoke test suites
│   │   ├── smoke-home.spec.ts
│   │   ├── smoke-auth.spec.ts
│   │   └── smoke-cart.spec.ts
│   └── regression/        # Regression test suites
│       ├── auth/
│       │   └── register-login-logout.spec.ts
│       ├── products/
│       │   └── add-to-cart-and-checkout.spec.ts
│       └── contact/
│           └── submit-contact-form.spec.ts
├── storage-state/
│   └── storageState.json  # Persisted authentication state
├── test-reports/
│   ├── allure-results/    # Allure test results
│   └── html/             # HTML test reports
├── single-file-reports/   # Single-file Allure reports
├── playwright.config.ts   # Playwright configuration
├── package.json          # Project dependencies and scripts
└── tsconfig.json         # TypeScript configuration
```

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Install Playwright Browsers

```bash
npm run install:browsers
```

### 3. Set Up Authentication (Optional)

```bash
npm run auth:setup
```

## Running Tests

### Smoke Tests
```bash
# Run smoke tests in test environment
npm run test:smoke
```

### Regression Tests
```bash
# Run regression tests in prerelease environment
npm run test:regression
```

### Headed Mode (with browser UI)
```bash
npm run test:headed
```

### Generate and View Reports

```bash
# View HTML report
npm run report:html

# Generate Allure single-file report
npm run allure:generate

# Serve Allure report
npm run allure:serve

# Clean report directories
npm run allure:clean
```

## Configuration

### Environment Variables

The framework supports multiple environments via `.env` files:

- `environments/.env.test` - Test environment settings
- `environments/.env.prerelease` - Prerelease environment settings

### Playwright Configuration

Key configuration options in `playwright.config.ts`:

- **Timeouts**: Test timeout (60s), expect timeout (10s)
- **Retries**: 0 (for faster feedback)
- **Browsers**: Chrome and Firefox
- **Reports**: HTML, Line, and Allure
- **Screenshots**: Only on failure
- **Videos**: Retain on failure
- **Traces**: On first retry

## Test Strategy

### Smoke Tests
Quick validation of core functionality:
- Home page loading and navigation
- Authentication forms and basic login
- Cart operations and product addition

### Regression Tests
Comprehensive testing of user journeys:
- Full registration and authentication flow
- Complete shopping cart to checkout process
- Contact form submission with validation

## Authentication Strategy

The framework uses Playwright's storage state to persist authentication:

1. Run `npm run auth:setup` to create authenticated session
2. Session stored in `storage-state/storageState.json`
3. Tests automatically use stored authentication
4. No need to login for each test execution

## Architecture Highlights

### Page Object Model + Factory Pattern
- **Base Page**: Common functionality for all pages
- **Page Factory**: Centralized page object creation with caching
- **Component Reuse**: Shared components like header navigation

### Type Safety
- TypeScript interfaces for all data models
- Strongly typed page objects and test data
- Compile-time error detection

### Test Data Management
- Centralized test constants and configuration
- Dynamic test data generation utilities
- Environment-specific test data

### Error Handling
- Comprehensive error messaging
- Screenshot and video capture on failures
- Detailed Allure reporting with steps

## Best Practices Implemented

1. **No Magic Waits**: All waits are explicit and purposeful
2. **Small Cohesive Methods**: Each method has a single responsibility
3. **Consistent Naming**: Clear, descriptive method and variable names
4. **Environment Separation**: Clean separation of test environments
5. **Session Management**: Efficient authentication state handling
6. **Comprehensive Reporting**: Multiple reporting formats for different needs

## CI/CD Ready

The framework is designed for CI/CD integration:

- Headless execution by default
- Environment variable configuration
- Multiple output formats
- Parallel execution support
- Docker-friendly setup

## Debugging

For debugging failed tests:

1. Check HTML reports: `npm run report:html`
2. View screenshots in `test-results/`
3. Review video recordings for failed tests
4. Use headed mode for live debugging: `npm run test:headed`

## Adding New Tests

1. Create page objects in appropriate `pages/` directory
2. Add test data to `data/test-data/`
3. Write tests following existing patterns
4. Use Page Factory for page object creation
5. Include appropriate test steps and assertions

## Contributing

1. Follow TypeScript and ESLint guidelines
2. Maintain page object pattern consistency
3. Add appropriate test documentation
4. Update this README for significant changes

---

**Built with care using Playwright + TypeScript**
