# Teams Notification Fix - Adaptive Card Support

## Issue
The Teams notification was failing with error:
```
Action 'Send_each_adaptive_card' failed: The execution of template action 'Send_each_adaptive_card' 
failed: the result of the evaluation of 'foreach' expression '@triggerOutputs()?['body']?['attachments']' 
is of type 'Null'. The result must be a valid array.
```

## Root Cause
The Power Automate flow was configured to expect adaptive cards with an `attachments` array, but the script was sending a simple JSON payload without the proper structure.

## Solution
Updated `scripts/send-teams-notification.sh` to send messages in the Microsoft Teams adaptive card format that Power Automate expects.

### New Payload Structure
```json
{
    "type": "message",
    "attachments": [
        {
            "contentType": "application/vnd.microsoft.card.adaptive",
            "content": {
                "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                "type": "AdaptiveCard",
                "version": "1.4",
                "body": [
                    {
                        "type": "TextBlock",
                        "text": "E2E Test Automation",
                        "size": "Large",
                        "weight": "Bolder"
                    },
                    {
                        "type": "TextBlock",
                        "text": "MESSAGE_CONTENT",
                        "wrap": true
                    },
                    {
                        "type": "FactSet",
                        "facts": [
                            {
                                "title": "Timestamp:",
                                "value": "2025-10-16 12:00:00"
                            },
                            {
                                "title": "Source:",
                                "value": "GitHub Actions"
                            }
                        ]
                    }
                ]
            }
        }
    ]
}
```

## Key Changes
1. **Added `attachments` array**: Power Automate flow expects this structure
2. **Adaptive card format**: Uses Microsoft's adaptive card schema
3. **Proper content structure**: Includes TextBlock and FactSet elements
4. **Escaped schema**: Used `\$schema` to prevent bash variable expansion

## Testing
To test the payload format without sending:
```bash
cd automationexercise-e2e-pom
./scripts/test-teams-payload.sh
```

To test actual sending (requires TEAMS_WEBHOOK_URL):
```bash
export TEAMS_WEBHOOK_URL="your-webhook-url"
npm run teams:notify "Test message"
```

## Power Automate Flow Requirements
Your Power Automate flow should:
1. Accept webhook requests with `attachments` array
2. Use "Apply to each" action to iterate over attachments
3. Post adaptive cards to Teams channel

## References
- [Microsoft Adaptive Cards](https://adaptivecards.io/)
- [Teams Webhook Documentation](https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/what-are-webhooks-and-connectors)
- [Power Automate Teams Integration](https://learn.microsoft.com/en-us/power-automate/teams/overview)

## Next Steps
1. Commit and push the updated script
2. Trigger a GitHub Actions workflow to test the notification
3. Verify the adaptive card appears correctly in Teams
4. Adjust formatting if needed

## Date
October 16, 2025
