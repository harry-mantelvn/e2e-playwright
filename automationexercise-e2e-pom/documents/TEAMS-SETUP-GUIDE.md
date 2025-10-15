# Teams Setup Guide

## Prerequisites
- Microsoft Teams account
- Power Automate access
- Permission to create flows

## Setup Steps

### 1. Create Power Automate Flow

1. Go to: https://powerautomate.microsoft.com
2. Click "Create" → "Instant cloud flow"
3. Name: "E2E Test Notifications"
4. Trigger: "When a HTTP request is received"
5. Click "Create"

### 2. Configure HTTP Trigger

1. In the HTTP trigger, click "Generate from sample"
2. Use this sample JSON:
```json
{
  "title": "E2E Test Automation",
  "text": "Sample notification message",
  "timestamp": "2024-01-01 12:00:00",
  "source": "Automation Framework"
}
```
3. Click "Done"

### 3. Add Teams Action

1. Click "New step"
2. Search for "Microsoft Teams"
3. Choose "Post message in a chat or channel"
4. Configure:
   - **Post as**: Flow bot
   - **Post in**: Channel
   - **Team**: Select your team
   - **Channel**: Select channel (e.g., #qa-automation)
   - **Message**: Use dynamic content from HTTP trigger

### 4. Save and Get Webhook URL

1. Click "Save"
2. Copy the "HTTP POST URL" from the trigger
3. This is your webhook URL

## Configuration

### Information Needed

Please provide:

1. **Teams Webhook URL** (Required):
   ```
   https://your-tenant.powerplatform.com/powerautomate/automations/direct/workflows/YOUR_WORKFLOW_ID/triggers/manual/paths/invoke
   ```

2. **Channel Name** (Optional, default: General):
   ```
   General
   QA Automation
   Test Results
   ```

## Environment Setup

Add to your environment:

```bash
export TEAMS_WEBHOOK_URL='https://your-tenant.powerplatform.com/powerautomate/automations/direct/workflows/YOUR_WORKFLOW_ID/triggers/manual/paths/invoke'
```

## Test Integration

```bash
# Test with mock data
npm run teams:test

# Test with real webhook (after setting TEAMS_WEBHOOK_URL)
npm run teams:notify "Test message"
```

## Advanced Configuration

### Enhanced Notifications

For rich formatting, modify your Power Automate flow to support:
- Adaptive Cards
- Action buttons
- Status indicators
- Report attachments

### Message Template

Example adaptive card template:
```json
{
  "type": "AdaptiveCard",
  "version": "1.3",
  "body": [
    {
      "type": "TextBlock",
      "text": "E2E Test Results",
      "weight": "Bolder",
      "size": "Medium"
    },
    {
      "type": "FactSet",
      "facts": [
        {
          "title": "Environment:",
          "value": "${environment}"
        },
        {
          "title": "Status:",
          "value": "${status}"
        }
      ]
    }
  ]
}
```

## Troubleshooting

### Common Issues

1. **Webhook not working**: Check if flow is turned on
2. **Message not appearing**: Verify channel permissions
3. **Flow fails**: Check Power Automate run history
4. **Authentication errors**: Ensure proper permissions

### Validation

Test your webhook manually:
```bash
curl -X POST YOUR_WEBHOOK_URL \
  -H 'Content-Type: application/json' \
  -d '{"title":"Test","text":"Test from curl","timestamp":"2024-01-01 12:00:00"}'
```

## Security Notes

- Keep webhook URLs secure and private
- Use environment variables, not hardcoded values
- Review Power Automate flow permissions regularly
- Monitor flow usage and errors
