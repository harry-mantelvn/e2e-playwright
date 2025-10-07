// Quick validation script to count test files and test cases
const fs = require('fs');
const path = require('path');

function countTestsInFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const testMatches = content.match(/test\('/g) || [];
    return testMatches.length;
  } catch (error) {
    console.error(`Error reading ${filePath}:`, error.message);
    return 0;
  }
}

function scanDirectory(dir) {
  let totalTests = 0;
  let fileCount = 0;
  
  function scanRecursive(currentDir) {
    const items = fs.readdirSync(currentDir);
    
    for (const item of items) {
      const fullPath = path.join(currentDir, item);
      const stat = fs.statSync(fullPath);
      
      if (stat.isDirectory() && !item.startsWith('.') && item !== 'node_modules') {
        scanRecursive(fullPath);
      } else if (item.endsWith('.spec.ts')) {
        const testCount = countTestsInFile(fullPath);
        console.log(`${fullPath}: ${testCount} tests`);
        totalTests += testCount;
        fileCount++;
      }
    }
  }
  
  scanRecursive(dir);
  console.log(`\nTotal: ${fileCount} test files, ${totalTests} test cases`);
}

console.log('Scanning test files...\n');
scanDirectory('./tests');
