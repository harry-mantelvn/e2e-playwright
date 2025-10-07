const fs = require('fs');
const path = require('path');

function cleanDirectory(dirPath) {
  if (fs.existsSync(dirPath)) {
    fs.rmSync(dirPath, { recursive: true, force: true });
    console.log(`Cleaned: ${dirPath}`);
  }
}

console.log('🧹 Cleaning test reports...');

// Clean all report directories
const dirsToClean = [
  'test-reports',
  'test-results',
  'single-file-reports', 
  'playwright-report'
];

dirsToClean.forEach(cleanDirectory);

console.log('All reports cleaned successfully');
