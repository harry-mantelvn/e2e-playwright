#!/usr/bin/env node

/**
 * CLI tool to send Slack notifications using the helper
 * Usage: node slack-cli.js "Your message here"
 */

const { slackHelper, sendSlackTestReport } = require('./helper/slack-helper');

// Get command line arguments
const args = process.argv.slice(2);

if (args.length === 0) {
  console.log(`
📱 Slack Notification CLI

Usage:
  node slack-cli.js "Your message"
  
  Or with NPM:
  npm run slack:cli "Your message"

Environment Variables Required:
  SLACK_WEBHOOK_URL - Your Slack Incoming Webhook URL

Examples:
  export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..."
  node slack-cli.js "Tests completed successfully! ✅"
  
  # Send test report
  node slack-cli.js --report
  `);
  process.exit(1);
}

// Main function
async function main() {
  if (!slackHelper.isConfigured()) {
    console.error('❌ Error: SLACK_WEBHOOK_URL environment variable is not set');
    console.error('');
    console.error('Set it with:');
    console.error('  export SLACK_WEBHOOK_URL="your-webhook-url"');
    console.error('');
    console.error('For help, see: documents/SLACK-INTEGRATION-GUIDE-VI.md');
    process.exit(1);
  }

  // Check if --report flag is provided
  if (args[0] === '--report') {
    console.log('📊 Sending test report...');
    
    // Try to read metrics from file
    const fs = require('fs');
    const path = require('path');
    const metricsPath = path.join(__dirname, 'test-summary', 'metrics.json');
    
    if (!fs.existsSync(metricsPath)) {
      console.error('❌ Metrics file not found. Run tests first.');
      process.exit(1);
    }
    
    const metrics = JSON.parse(fs.readFileSync(metricsPath, 'utf-8'));
    
    const success = await sendSlackTestReport({
      totalTests: metrics.total_test_cases || 0,
      passedTests: metrics.passed_tests || 0,
      failedTests: metrics.failed_tests || 0,
      passRate: metrics.pass_rate || 0,
      duration: metrics.duration || 'N/A',
      environment: process.env.ENVIRONMENT || 'test',
      testScope: process.env.TEST_SCOPE || 'all'
    }, process.env.PIPELINE_URL);
    
    if (success) {
      console.log('✅ Test report sent to Slack');
      process.exit(0);
    } else {
      console.error('❌ Failed to send test report');
      process.exit(1);
    }
  } else {
    // Send simple message
    const message = args.join(' ');
    console.log(`📤 Sending message to Slack: "${message}"`);
    
    const success = await slackHelper.sendSimpleMessage(message);
    
    if (success) {
      console.log('✅ Message sent successfully');
      process.exit(0);
    } else {
      console.error('❌ Failed to send message');
      process.exit(1);
    }
  }
}

// Run
main().catch(error => {
  console.error('❌ Error:', error.message);
  process.exit(1);
});
