# Manual Deployment Guide - Rapyd Sentinel PoC

## Current Situation
You have the code in `/Users/vadimsohin/rapyd_sentinel_task` but git is not initialized here.

## Step 1: Create GitHub Repository
1. Go to [github.com](https://github.com)
2. Click "New repository"
3. Name: `rapyd-sentinel-poc`
4. **DO NOT** check any initialization options
5. Click "Create repository"

## Step 2: Upload Files to GitHub
1. Go to your new GitHub repository
2. Click "Add file" → "Upload files"
3. Open Finder and go to `/Users/vadimsohin/rapyd_sentinel_task`
4. Select ALL files and folders:
   - `.github/` folder
   - `kubernetes/` folder
   - `terraform/` folder
   - `README.md`
5. Drag and drop them into the GitHub upload area
6. Add commit message: "Initial commit: Rapyd Sentinel PoC"
7. Click "Commit changes"

## Step 3: Configure AWS Credentials
1. In your GitHub repository, click **"Settings"** tab
2. Click **"Secrets and variables"** → **"Actions"**
3. Click **"New repository secret"**
4. Add these two secrets:

   **First secret:**
   - Name: `AWS_ACCESS_KEY_ID`
   - Value: ``

   **Second secret:**
   - Name: `AWS_SECRET_ACCESS_KEY`
   - Value: ``

## Step 4: Deploy
1. Click **"Actions"** tab in your GitHub repository
2. Click on **"Deploy Rapyd Sentinel"** workflow
3. Click **"Run workflow"**
4. Select branch `main`
5. Click **"Run workflow"**

## Step 5: Monitor
- Watch the Actions tab for deployment progress
- It will take 15-20 minutes to complete
- Check the final step for the LoadBalancer URL

## Files to Upload:
Make sure to upload these files/folders from `/Users/vadimsohin/rapyd_sentinel_task`:

```
.github/
├── workflows/
│   └── deploy.yml
kubernetes/
├── backend/
│   ├── deployment.yaml
│   └── service.yaml
└── gateway/
    ├── deployment.yaml
    └── service.yaml
terraform/
├── main.tf
├── outputs.tf
├── variables.tf
└── modules/
    ├── eks/
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── vpc/
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
README.md
```

That's it! The GitHub Actions will handle everything automatically. 🚀
