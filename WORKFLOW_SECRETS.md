# Workflow Secrets Configuration

This document describes the secrets required for the Athens GitHub Actions workflows to function properly.

## Required Secrets for Release Workflow

### Vercel Deployment (release-web job)

The following secrets are required for automatic Vercel deployment:

- **VERCEL_TOKEN**: Your Vercel API token
  - Obtain from: https://vercel.com/account/tokens
  - Permissions: Deploy and manage your projects

- **VERCEL_ORG_ID**: Your Vercel organization ID  
  - Find in: Vercel Dashboard → Settings → General
  - Usually starts with `team_` or `prj_`

- **VERCEL_PROJECT_ID**: Your specific Athens project ID
  - Find in: Project Settings → General in Vercel Dashboard
  - Unique identifier for your Athens deployment project

### Other Release Secrets

- **GITHUB_TOKEN**: Automatically provided by GitHub Actions
- **AWS_ACCESS_KEY_ID**: For Electron app distribution (if needed)
- **AWS_SECRET_ACCESS_KEY**: For Electron app distribution (if needed)
- **mac_certs**: macOS code signing certificate (for macOS builds)
- **mac_certs_password**: Password for macOS certificate
- **api_key**: Apple API key for notarization  
- **api_key_id**: Apple API key ID
- **api_key_issuer_id**: Apple API key issuer ID

## Setting Up Secrets

1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions  
3. Click "New repository secret"
4. Add each required secret with the exact name listed above

## Graceful Degradation

The workflow has been updated to handle missing Vercel secrets gracefully:

- If Vercel secrets are missing, deployment will be skipped with a warning
- Build artifacts will still be created and available for manual deployment
- The workflow will not fail due to missing Vercel credentials

## Testing Locally

To test the deployment setup locally:

```bash
# Install and build components
yarn install
yarn components

# Test server compilation
clojure -M -e "(compile 'athens.self-hosted.core)"

# Build for production
yarn prod
```

## Troubleshooting

### Common Issues

1. **"Input required and not supplied: vercel-token"**
   - Ensure VERCEL_TOKEN secret is set in repository settings
   - Check that the secret name matches exactly (case-sensitive)

2. **Server compilation fails**  
   - Ensure all Clojure dependencies are properly configured
   - Check that network access to Clojars is available in your environment

3. **Build artifacts missing**
   - Verify that the build-app job completed successfully
   - Check that all required dependencies are installed

For more help, see:
- [VERCEL_SETUP.md](VERCEL_SETUP.md)
- [BUILD_TROUBLESHOOTING.md](BUILD_TROUBLESHOOTING.md) 
- [ERROR_RESOLUTION_GUIDE.md](ERROR_RESOLUTION_GUIDE.md)