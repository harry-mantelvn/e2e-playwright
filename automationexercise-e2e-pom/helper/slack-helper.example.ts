/**
 * Example usage of Slack Helper
 * Demonstrates how to send notifications to Slack
 */

import { slackHelper, sendSlackTestReport, TestMetrics } from './slack-helper';

// Example 1: Send simple message
async function example1() {
  const success = await slackHelper.sendSimpleMessage('Hello from E2E Test Automation!');
  console.log('Simple message sent:', success);
}

// Example 2: Send test report
async function example2() {
  const metrics: TestMetrics = {
    totalTests: 10,
    passedTests: 9,
    failedTests: 1,
    passRate: 90,
    duration: '5m 30s',
    environment: 'test',
    testScope: 'smoke'
  };

  const pipelineUrl = 'https://github.com/user/repo/actions/runs/123456';
  
  const success = await sendSlackTestReport(metrics, pipelineUrl);
  console.log('Test report sent:', success);
}

// Example 3: Send error notification
async function example3() {
  const success = await slackHelper.sendErrorNotification(
    'Failed to connect to database',
    'Environment: test, Test: smoke-auth.spec.ts'
  );
  console.log('Error notification sent:', success);
}

// Example 4: Send custom message with blocks
async function example4() {
  const customMessage = {
    text: 'Deployment Notification',
    blocks: [
      {
        type: 'header',
        text: {
          type: 'plain_text',
          text: '🚀 Deployment Complete',
          emoji: true
        }
      },
      {
        type: 'section',
        fields: [
          {
            type: 'mrkdwn',
            text: '*Environment:*\nProduction'
          },
          {
            type: 'mrkdwn',
            text: '*Version:*\nv1.2.3'
          }
        ]
      }
    ]
  };

  const success = await slackHelper.sendCustomMessage(customMessage);
  console.log('Custom message sent:', success);
}

// Run examples (uncomment to test)
// example1();
// example2();
// example3();
// example4();
