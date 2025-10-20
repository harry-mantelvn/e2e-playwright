/**
 * Slack Integration Helper
 * Provides utilities for sending notifications to Slack
 * Uses Incoming Webhooks (safer and simpler than OAuth tokens)
 */

import axios from 'axios';

export interface SlackMessageBlock {
  type: string;
  text?: {
    type: string;
    text: string;
    emoji?: boolean;
  };
  elements?: Array<{
    type: string;
    text: string;
  }>;
  fields?: Array<{
    type: string;
    text: string;
  }>;
}

export interface SlackMessage {
  text: string;
  blocks?: SlackMessageBlock[];
  username?: string;
  icon_emoji?: string;
  channel?: string;
}

export interface TestMetrics {
  totalTests: number;
  passedTests: number;
  failedTests: number;
  skippedTests?: number;
  passRate: number;
  duration?: string;
  environment: string;
  testScope: string;
}

export class SlackHelper {
  private webhookUrl: string;

  constructor(webhookUrl?: string) {
    this.webhookUrl = webhookUrl || process.env.SLACK_WEBHOOK_URL || '';
    
    if (!this.webhookUrl) {
      console.warn('⚠️ SLACK_WEBHOOK_URL not configured. Notifications will be skipped.');
    }
  }

  /**
   * Check if Slack integration is configured
   */
  isConfigured(): boolean {
    return !!this.webhookUrl;
  }

  /**
   * Send a simple text message to Slack
   */
  async sendSimpleMessage(message: string): Promise<boolean> {
    if (!this.isConfigured()) {
      console.log('Slack not configured, skipping notification');
      return false;
    }

    try {
      const payload: SlackMessage = {
        text: message
      };

      const response = await axios.post(this.webhookUrl, payload, {
        headers: {
          'Content-Type': 'application/json'
        }
      });

      console.log('✅ Slack notification sent successfully');
      return response.status === 200;
    } catch (error) {
      console.error('❌ Failed to send Slack notification:', error);
      return false;
    }
  }

  /**
   * Send a formatted test report to Slack with rich formatting
   */
  async sendTestReport(metrics: TestMetrics, pipelineUrl?: string): Promise<boolean> {
    if (!this.isConfigured()) {
      console.log('Slack not configured, skipping notification');
      return false;
    }

    try {
      // Determine status and emoji
      let status = '🚨 CRITICAL';
      let color = '#FF0000';
      
      if (metrics.passRate >= 95) {
        status = '🎯 EXCELLENT';
        color = '#00FF00';
      } else if (metrics.passRate >= 85) {
        status = '✅ GOOD';
        color = '#FFA500';
      } else if (metrics.passRate >= 70) {
        status = '⚠️ NEEDS ATTENTION';
        color = '#FFA500';
      }

      const blocks: SlackMessageBlock[] = [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: '🧪 E2E Test Automation Report',
            emoji: true
          }
        },
        {
          type: 'section',
          fields: [
            {
              type: 'mrkdwn',
              text: `*Status:*\n${status}`
            },
            {
              type: 'mrkdwn',
              text: `*Pass Rate:*\n${metrics.passRate}%`
            },
            {
              type: 'mrkdwn',
              text: `*Environment:*\n${metrics.environment}`
            },
            {
              type: 'mrkdwn',
              text: `*Test Scope:*\n${metrics.testScope}`
            },
            {
              type: 'mrkdwn',
              text: `*Total Tests:*\n${metrics.totalTests}`
            },
            {
              type: 'mrkdwn',
              text: `*Passed:*\n✅ ${metrics.passedTests}`
            },
            {
              type: 'mrkdwn',
              text: `*Failed:*\n❌ ${metrics.failedTests}`
            },
            {
              type: 'mrkdwn',
              text: `*Duration:*\n${metrics.duration || 'N/A'}`
            }
          ]
        }
      ];

      // Add pipeline link if provided
      if (pipelineUrl) {
        blocks.push({
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: `<${pipelineUrl}|📊 View Full Pipeline Details>`
          }
        });
      }

      // Add context footer
      blocks.push({
        type: 'context',
        elements: [
            {
              type: 'mrkdwn',
              text: `⏰ ${new Date().toLocaleString('en-US', { timeZone: 'UTC' })} UTC | 🤖 Automated via GitHub Actions`
            }
          ]
      });

      const payload: SlackMessage = {
        text: `E2E Test Report - ${status}`,
        blocks: blocks
      };

      const response = await axios.post(this.webhookUrl, payload, {
        headers: {
          'Content-Type': 'application/json'
        }
      });

      console.log('✅ Slack test report sent successfully');
      return response.status === 200;
    } catch (error) {
      console.error('❌ Failed to send Slack test report:', error);
      return false;
    }
  }

  /**
   * Send a custom formatted message with blocks
   */
  async sendCustomMessage(message: SlackMessage): Promise<boolean> {
    if (!this.isConfigured()) {
      console.log('Slack not configured, skipping notification');
      return false;
    }

    try {
      const response = await axios.post(this.webhookUrl, message, {
        headers: {
          'Content-Type': 'application/json'
        }
      });

      console.log('✅ Slack custom message sent successfully');
      return response.status === 200;
    } catch (error) {
      console.error('❌ Failed to send Slack custom message:', error);
      return false;
    }
  }

  /**
   * Send error notification
   */
  async sendErrorNotification(errorMessage: string, context?: string): Promise<boolean> {
    if (!this.isConfigured()) {
      console.log('Slack not configured, skipping notification');
      return false;
    }

    try {
      const blocks: SlackMessageBlock[] = [
        {
          type: 'header',
          text: {
            type: 'plain_text',
            text: '🚨 Test Automation Error',
            emoji: true
          }
        },
        {
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: `*Error:*\n\`\`\`${errorMessage}\`\`\``
          }
        }
      ];

      if (context) {
        blocks.push({
          type: 'section',
          text: {
            type: 'mrkdwn',
            text: `*Context:*\n${context}`
          }
        });
      }

      const payload: SlackMessage = {
        text: `🚨 Test Automation Error: ${errorMessage}`,
        blocks: blocks
      };

      const response = await axios.post(this.webhookUrl, payload, {
        headers: {
          'Content-Type': 'application/json'
        }
      });

      console.log('✅ Slack error notification sent successfully');
      return response.status === 200;
    } catch (error) {
      console.error('❌ Failed to send Slack error notification:', error);
      return false;
    }
  }
}

// Export singleton instance
export const slackHelper = new SlackHelper();

// Export function for easy use
export async function sendSlackNotification(message: string): Promise<boolean> {
  return slackHelper.sendSimpleMessage(message);
}

export async function sendSlackTestReport(metrics: TestMetrics, pipelineUrl?: string): Promise<boolean> {
  return slackHelper.sendTestReport(metrics, pipelineUrl);
}
