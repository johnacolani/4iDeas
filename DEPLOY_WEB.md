# Deploy 4iDeas Web App

This guide explains how to deploy your Flutter web app to various hosting platforms.

## Prerequisites

1. Build the production web app:
   ```bash
   flutter build web --release
   ```

   This creates optimized production files in `build/web/` directory.

## Deployment Options

### Option 1: Firebase Hosting (Recommended)

Firebase Hosting provides free SSL, CDN, and easy deployment.

#### Setup:

1. **Install Firebase CLI** (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase Hosting** (if not already done):
   ```bash
   firebase init hosting
   ```
   - Select your Firebase project: `my-web-page-ef286`
   - What do you want to use as your public directory? `build/web`
   - Configure as a single-page app? `Yes`
   - Set up automatic builds and deploys with GitHub? `No` (or Yes if you want CI/CD)

4. **Update `firebase.json`** (if needed):
   ```json
   {
     "hosting": {
       "public": "build/web",
       "ignore": [
         "firebase.json",
         "**/.*",
         "**/node_modules/**"
       ],
       "rewrites": [
         {
           "source": "**",
           "destination": "/index.html"
         }
       ],
       "headers": [
         {
           "source": "**/*.@(jpg|jpeg|gif|png|svg|webp|js|css|eot|otf|ttf|ttc|woff|woff2|font.css)",
           "headers": [
             {
               "key": "Cache-Control",
               "value": "max-age=604800"
             }
           ]
         }
       ]
     }
   }
   ```

5. **Deploy**:
   ```bash
   flutter build web --release
   firebase deploy --only hosting
   ```

6. **Your app will be live at**:
   ```
   https://your-project-id.web.app
   https://your-project-id.firebaseapp.com
   ```

#### Custom Domain:

1. Go to Firebase Console > Hosting
2. Click "Add custom domain"
3. Follow the instructions to add your domain (e.g., `4ideas.com`)
4. Update DNS records as instructed

---

### Option 2: GitHub Pages

Free hosting directly from your GitHub repository.

#### Setup:

1. **Build with base href**:
   ```bash
   flutter build web --release --base-href "/MyWebSite/"
   ```
   (Replace `MyWebSite` with your repository name if different)

2. **Create GitHub Actions workflow** (`.github/workflows/deploy.yml`):
   ```yaml
   name: Deploy to GitHub Pages

   on:
     push:
       branches: [ master ]

   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - uses: subosito/flutter-action@v2
           with:
             flutter-version: '3.24.0'
         - run: flutter pub get
         - run: flutter build web --release --base-href "/MyWebSite/"
         - uses: peaceiris/actions-gh-pages@v3
           with:
             github_token: ${{ secrets.GITHUB_TOKEN }}
             publish_dir: ./build/web
   ```

3. **Enable GitHub Pages**:
   - Go to repository Settings > Pages
   - Source: `GitHub Actions`

4. **Your app will be live at**:
   ```
   https://username.github.io/MyWebSite/
   ```

---

### Option 3: Netlify

Free hosting with automatic deployments from Git.

#### Setup:

1. **Build the app**:
   ```bash
   flutter build web --release
   ```

2. **Create `netlify.toml`** in project root:
   ```toml
   [build]
   publish = "build/web"
   command = "flutter build web --release"

   [[redirects]]
   from = "/*"
   to = "/index.html"
   status = 200
   ```

3. **Deploy via Netlify**:
   - Go to [netlify.com](https://netlify.com)
   - Drag and drop the `build/web` folder, OR
   - Connect your GitHub repository for automatic deployments

4. **Your app will be live at**:
   ```
   https://your-app-name.netlify.app
   ```

---

### Option 4: Vercel

Modern hosting platform with excellent performance.

#### Setup:

1. **Build the app**:
   ```bash
   flutter build web --release
   ```

2. **Create `vercel.json`** in project root:
   ```json
   {
     "rewrites": [
       { "source": "/(.*)", "destination": "/index.html" }
     ]
   }
   ```

3. **Deploy via Vercel**:
   - Install Vercel CLI: `npm i -g vercel`
   - Run: `vercel --prod` in the project root
   - Or connect GitHub repository via Vercel dashboard

---

### Option 5: Traditional Web Hosting (cPanel, FTP, etc.)

1. **Build the app**:
   ```bash
   flutter build web --release
   ```

2. **Upload contents**:
   - Upload all files from `build/web/` to your web server's `public_html` or `www` directory
   - Make sure `index.html` is in the root directory

3. **Configure server** (Apache `.htaccess`):
   ```apache
   RewriteEngine On
   RewriteCond %{REQUEST_FILENAME} !-f
   RewriteCond %{REQUEST_FILENAME} !-d
   RewriteRule ^(.*)$ /index.html [L]
   ```

   (Nginx configuration):
   ```nginx
   location / {
     try_files $uri $uri/ /index.html;
   }
   ```

---

## Post-Deployment Checklist

- [ ] Test all pages and navigation
- [ ] Verify authentication works
- [ ] Test form submissions
- [ ] Check mobile responsiveness
- [ ] Verify all images and assets load
- [ ] Test on different browsers
- [ ] Set up analytics (optional)
- [ ] Configure custom domain (if applicable)
- [ ] Set up SSL certificate (usually automatic on modern platforms)

## Building for Production

Always use the release build for production:

```bash
flutter build web --release
```

This creates optimized, minified code that loads faster and uses less bandwidth.

## Environment Variables

If you need different configurations for production:
- Create separate Firebase projects for dev/staging/prod
- Use environment variables or build configurations
- Update `firebase_options.dart` if needed

## Troubleshooting

### Routing Issues (404 errors)
- Ensure your hosting provider supports SPA (Single Page Application) routing
- Configure redirects to `index.html` for all routes

### Firebase Authentication Not Working
- Verify Firebase project is correctly configured
- Check Firebase Hosting domain is added to authorized domains in Firebase Console
- Ensure `firebase_options.dart` has correct web configuration

### Assets Not Loading
- Check that all assets are included in `pubspec.yaml`
- Verify asset paths in code match the deployed structure
- Clear browser cache






