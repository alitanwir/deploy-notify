# Deploy Notify


Deploy Notify is a modular Bash script for deployment notifications. It provides an interactive menu to select deployment targets, collects relevant metadata (timestamp, user, git info), and sends notifications via webhook or logs locally. Easily integrates into any deployment workflow and works on macOS and Linux with minimal dependencies.

## Interactive Menu Options

The script supports three interactive menu modes for selecting deployment targets:

1. **gum** (recommended): Modern, beautiful UI. If installed, it will be used automatically.
2. **fzf**: If gum is not available, fzf will be used for multi-select.
3. **Text-based fallback**: If neither gum nor fzf is installed, a simple text-based menu will be used.

### Install gum (recommended)

macOS (Homebrew):
   brew install gum
Linux (Homebrew):
   brew install gum
Or see: https://github.com/charmbracelet/gum#installation

### Install fzf (optional fallback)

macOS (Homebrew):
   brew install fzf
Linux (Homebrew):
   brew install fzf
Or see: https://github.com/junegunn/fzf#installation

If neither is installed, the script will fall back to a text-based menu.

# Setup Instructions

## Environment Variable

You can set the webhook endpoint using the `DEPLOY_NOTIFY_WEBHOOK_URL` environment variable. If not set, the script uses the value defined in the script.

Example:

```
export DEPLOY_NOTIFY_WEBHOOK_URL="https://your-webhook-endpoint"
```

## Bash Script

1. Save the script as `deploy-notify.sh` and make it executable:

```
chmod +x deploy-notify.sh
```

2. (Optional) Set SCRIPT_WEBHOOK_URL at the top of the script to your endpoint.
3. Integrate into your deployment workflow (e.g., call after deploy).

## Google Apps Script Backend

1. Go to Google Apps Script.
2. Create a new project, paste the code above.
3. Replace `YOUR_SHEET_ID` with your Google Sheet’s ID.
   - Get it from the URL: `https://docs.google.com/spreadsheets/d/<SHEET_ID>/edit`
4. Replace `YOUR_EMAIL@example.com` with your notification email.
5. Save and deploy as a web app:
   - Click **Deploy > New deployment**
   - Select **Web app**
   - Set "Who has access" to "Anyone" (or as needed)
   - Copy the web app URL.
6. Set `SCRIPT_WEBHOOK_URL` in your Bash script to this URL or, set `DEPLOY_NOTIFY_WEBHOOK_URL` environment variable.
