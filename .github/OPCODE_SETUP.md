# OpenCode PR Review Setup Guide

This guide explains how to set up the OpenCode API key for automatic PR reviews via GitHub Actions.

## How It Works

The workflow (`.github/workflows/pr-review.yml`) triggers on PR events and uses OpenCode to:
1. Analyze the PR diff
2. Generate a code review with feedback
3. Post the review as a PR comment

## Step 1: Get an OpenCode API Key

### Option A: OpenAI API Key (Recommended)

1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Sign up or log in to your account
3. Navigate to **API Keys** in the left sidebar
4. Click **"Create new secret key"**
5. Give it a name (e.g., "GitHub Actions PR Review")
6. Copy the key immediately (you won't see it again)

### Option B: Anthropic API Key

1. Go to [Anthropic Console](https://console.anthropic.com/)
2. Sign up or log in
3. Navigate to **API Keys**
4. Create a new key and copy it

### Option C: OpenCode Cloud (if available)

1. Go to [OpenCode](https://opencode.ai/)
2. Sign up for an account
3. Generate an API key from your account settings

## Step 2: Add the API Key to GitHub Secrets

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Set the name to: `OPENCODE_API_KEY`
5. Paste your API key as the value
6. Click **"Add secret"**

## Step 3: Verify the Setup

1. Create a test PR or push to an existing PR
2. The workflow will automatically trigger
3. Check the **Actions** tab to see the workflow run
4. Once complete, the review will be posted as a comment on the PR

## Troubleshooting

### Workflow fails with "authentication error"
- Verify the API key is correct in GitHub Secrets
- Check that the key has not expired
- Ensure the key has sufficient credits/quota

### Workflow doesn't trigger
- Check that the workflow file is in `.github/workflows/pr-review.yml`
- Verify the workflow syntax is valid
- Check repository settings to ensure Actions are enabled

### Review comment not posted
- Check the workflow logs for errors
- Verify the `GITHUB_TOKEN` has permission to post comments
- Ensure the PR is not a draft (if your repo requires this)

## Updating the Workflow

To customize the review prompt or model, edit `.github/workflows/pr-review.yml`:

```yaml
# Change the model
opencode run "$PROMPT" --model gpt-4o > /tmp/review-output.txt

# Change the prompt
PROMPT="Your custom review prompt here..."
```

## Security Notes

- Never commit API keys to the repository
- Use GitHub Secrets for all sensitive values
- Rotate API keys regularly
- Use separate keys for different purposes/environments
