const fs = require('fs');
const path = require('path');

function cleanDirectory(dirPath) {
  if (fs.existsSync(dirPath)) {
    fs.rmSync(dirPath, { recursive: true, force: true });
  }
}

// Clean all report directories
const dirsToClean = [
  'test-reports',
  'test-results',
  'single-file-reports', 
  'allure-report',
  'playwright-report'
];

dirsToClean.forEach(cleanDirectory);
