# Teams Notification Fix Summary

## Date: October 16, 2025

## Problem
Teams notification was failing in the GitHub Actions workflow with error:
```
Action 'Send_each_adaptive_card' failed: The execution of template action 'Send_each_adaptive_card' 
failed: the result of the evaluation of 'foreach' expression '@triggerOutputs()?['body']?['attachments']' 
is of type 'Null'. The result must be a valid array.
```

## Analysis
The Power Automate flow receiving the webhook was configured to:
1. Receive Teams webhook requests
2. Send adaptive cards with attachments
3. The flow expected an `attachments` array in the payload body

The original script was sending a simple JSON payload:
```json
{
    "title": "E2E Test Automation",
    "text": "MESSAGE",
    "timestamp": "...",
    "source": "Automation Framework"
}
```

This didn't match the expected format, causing the flow to fail.

## Solution Implemented

### 1. Updated Teams Notification Script
**File**: `automationexercise-e2e-pom/scripts/send-teams-notification.sh`

Changed payload format to Microsoft Teams Adaptive Card structure:
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
                        "text": "$MESSAGE",
                        "wrap": true
                    },
                    {
                        "type": "FactSet",
                        "facts": [
                            {
                                "title": "Timestamp:",
                                "value": "$TIMESTAMP"
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

### 2. Updated Slack Notification Script
**File**: `automationexercise-e2e-pom/scripts/send-slack-notification.sh`

Created a complete Slack notification script with proper error handling and formatting:
- Uses Slack Block Kit format
- Includes header, message section, and context
- Proper error handling and response checking

### 3. Fixed GitHub Actions Workflow
**File**: `.github/workflows/e2e-automation.yml`

- Removed invalid secret checks in `if` conditions
- Changed from `if: ${{ always() && secrets.TEAMS_WEBHOOK_URL != '' }}` 
- To: `if: always()` with `continue-on-error: true`
- This allows the workflow to continue even if webhook URLs are not configured

### 4. Created Test Scripts
**File**: `automationexercise-e2e-pom/scripts/test-teams-payload.sh`

Test script to verify the JSON payload format without actually sending it.

### 5. Documentation
**File**: `automationexercise-e2e-pom/documents/TEAMS-NOTIFICATION-FIX.md`

Complete documentation of the issue, solution, and testing steps.

## Files Changed
1. `.github/workflows/e2e-automation.yml` - Fixed secret checks in conditions
2. `automationexercise-e2e-pom/scripts/send-teams-notification.sh` - Updated to adaptive card format
3. `automationexercise-e2e-pom/scripts/send-slack-notification.sh` - Created complete implementation
4. `automationexercise-e2e-pom/scripts/test-teams-payload.sh` - Created test script
5. `automationexercise-e2e-pom/documents/TEAMS-NOTIFICATION-FIX.md` - Added documentation

## Testing Steps

### Local Testing (without sending)
```bash
cd automationexercise-e2e-pom
./scripts/test-teams-payload.sh
```

### Test with Real Webhook
```bash
cd automationexercise-e2e-pom
export TEAMS_WEBHOOK_URL="your-webhook-url"
npm run teams:notify "Test message from local"
```

### GitHub Actions Testing
1. Commit and push changes
2. Trigger workflow manually with workflow_dispatch
3. Monitor the "Send Teams Notification" step
4. Verify adaptive card appears in Teams channel

## Expected Results
- ✅ GitHub Actions workflow passes validation
- ✅ Teams notification step runs without errors
- ✅ Adaptive card displays correctly in Teams with:
  - Bold header "E2E Test Automation"
  - Message content with word wrap
  - Timestamp and source information
- ✅ Workflow continues even if webhook is not configured

## Key Technical Details

### Why Adaptive Cards?
- Power Automate flows expect structured data
- Adaptive cards provide rich, interactive UI
- Better formatting and readability in Teams
- Consistent with Microsoft's recommended approach

### Schema Escaping
Used `\$schema` in the bash script to prevent variable expansion while maintaining valid JSON.

### Error Handling
Both notification scripts now:
- Check for webhook URL environment variable
- Provide helpful error messages
- Return appropriate exit codes
- Include response code checking

## Next Actions
1. ✅ Update notification scripts with adaptive card format
2. ✅ Fix GitHub Actions workflow YAML errors
3. ✅ Create test scripts
4. ✅ Document the fix
5. ⏳ Commit and push changes
6. ⏳ Test in GitHub Actions
7. ⏳ Verify Teams channel receives formatted notifications

## References
- [Microsoft Adaptive Cards Schema](https://adaptivecards.io/explorer/)
- [Teams Incoming Webhooks](https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook)
- [Power Automate Teams Actions](https://learn.microsoft.com/en-us/power-automate/teams/overview)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

---
**Status**: Ready for testing ✅  
**Impact**: High - Fixes critical notification failure  
**Risk**: Low - Changes are backward compatible  
