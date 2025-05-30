# Vercel Deployment Guide for Winal Drug Shop Frontend

This guide will help you deploy your Flutter web application to Vercel.

## Prerequisites

1. **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
2. **Git Repository**: Your code should be in a Git repository (GitHub, GitLab, or Bitbucket)
3. **Flutter SDK**: Ensure Flutter is installed locally for testing

## Deployment Steps

### Method 1: Vercel Dashboard (Recommended)

1. **Connect Repository**:
   - Go to [vercel.com](https://vercel.com) and sign in
   - Click "New Project"
   - Import your Git repository containing the Flutter project

2. **Configure Project**:
   - **Framework Preset**: Select "Other"
   - **Root Directory**: Leave as `.` (root)
   - **Build Command**: `flutter build web --release --web-renderer html`
   - **Output Directory**: `build/web`
   - **Install Command**: `flutter pub get`

3. **Environment Variables** (if needed):
   - Add any environment variables your app requires
   - For example: `FLUTTER_WEB=true`

4. **Deploy**:
   - Click "Deploy"
   - Vercel will automatically build and deploy your app
   - You'll get a live URL once deployment is complete

### Method 2: Vercel CLI

1. **Install Vercel CLI**:
   ```bash
   npm i -g vercel
   ```

2. **Login to Vercel**:
   ```bash
   vercel login
   ```

3. **Deploy from Project Root**:
   ```bash
   cd /path/to/winal_drug_shop
   vercel
   ```

4. **Follow Prompts**:
   - Select your scope/team
   - Confirm project settings
   - Deploy!

## Configuration Files

The following files have been created to configure Vercel deployment:

### `vercel.json`
- Configures build settings and routing
- Sets up HTML5 routing for Flutter web
- Includes security headers

### `.vercelignore`
- Excludes unnecessary files from deployment
- Keeps deployment size minimal
- Focuses on web build output only

### `build.sh`
- Custom build script for advanced deployments
- Handles Flutter installation and dependencies

## Important Notes

### 1. Base URL Configuration
If deploying to a subdirectory, update the base href in `web/index.html`:
```html
<base href="/your-subdirectory/">
```

### 2. Backend Integration
Update your Flutter app's API endpoints to point to your deployed backend:
- Current backend: `https://winal-backend.onrender.com`
- Ensure CORS is configured for your Vercel domain

### 3. Environment Variables
For different environments, you can set build-time variables:
```json
{
  "build": {
    "env": {
      "API_URL": "https://your-backend.com",
      "FLUTTER_WEB": "true"
    }
  }
}
```

## Post-Deployment Checklist

1. **Test Core Functionality**:
   - [ ] User authentication
   - [ ] Product browsing
   - [ ] Cart operations
   - [ ] Order placement

2. **Check Backend Integration**:
   - [ ] API calls work correctly
   - [ ] CORS headers are set
   - [ ] Authentication tokens persist

3. **Mobile Responsiveness**:
   - [ ] Test on mobile devices
   - [ ] Verify touch interactions
   - [ ] Check loading performance

4. **SEO and Metadata**:
   - [ ] Page titles are correct
   - [ ] Meta descriptions are set
   - [ ] Social media previews work

## Custom Domain (Optional)

1. **Add Domain in Vercel**:
   - Go to Project Settings → Domains
   - Add your custom domain
   - Follow DNS configuration instructions

2. **Update Configuration**:
   - Update any hardcoded URLs in your app
   - Test with the new domain

## Troubleshooting

### Common Issues:

1. **Build Fails**:
   - Check Flutter version compatibility
   - Verify all dependencies are compatible with web
   - Check build logs in Vercel dashboard

2. **Routing Issues**:
   - Ensure `vercel.json` has correct routing rules
   - Check that Flutter routes are properly configured

3. **API Connection Issues**:
   - Verify backend CORS settings
   - Check API endpoints are accessible
   - Ensure authentication tokens work cross-origin

### Performance Optimization:

1. **Enable Compression**:
   ```json
   {
     "headers": [
       {
         "source": "**/*",
         "headers": [
           {
             "key": "Content-Encoding",
             "value": "gzip"
           }
         ]
       }
     ]
   }
   ```

2. **Cache Static Assets**:
   - Vercel automatically caches static files
   - Configure cache headers in `vercel.json` if needed

## Support

- **Vercel Documentation**: [vercel.com/docs](https://vercel.com/docs)
- **Flutter Web**: [flutter.dev/web](https://flutter.dev/web)
- **Project Issues**: Create an issue in your repository

## Next Steps

After successful deployment:
1. Set up monitoring and analytics
2. Configure custom domain (if desired)
3. Set up staging/production environments
4. Implement CI/CD for automatic deployments
