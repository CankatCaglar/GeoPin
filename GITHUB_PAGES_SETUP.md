# GitHub Pages Setup Instructions for GeoPin

## Step 1: Create a GitHub Repository

1. Go to [GitHub](https://github.com) and sign in
2. Click the "+" icon in the top right and select "New repository"
3. Name your repository: `geopin-pages` (or any name you prefer)
4. Make it **Public**
5. Click "Create repository"

## Step 2: Upload the HTML Files

### Option A: Using GitHub Web Interface

1. In your new repository, click "Add file" → "Upload files"
2. Drag and drop these files from `GeoPin/docs/` folder:
   - `index.html`
   - `privacy-policy.html`
   - `terms-of-use.html`
   - `contact.html`
3. Click "Commit changes"

### Option B: Using Git Command Line

```bash
cd "/Users/cankatacarer/Desktop/AppStore Applications/GeoPin"
git init
git add docs/
git commit -m "Add legal pages for GeoPin"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/geopin-pages.git
git push -u origin main
```

## Step 3: Enable GitHub Pages

1. In your repository, go to **Settings**
2. Scroll down to **Pages** section (left sidebar)
3. Under "Source", select:
   - Branch: `main`
   - Folder: `/docs` (or `/root` if you uploaded to root)
4. Click **Save**
5. Wait 1-2 minutes for deployment

## Step 4: Get Your URLs

Your pages will be available at:
- **Privacy Policy**: `https://YOUR_USERNAME.github.io/geopin-pages/privacy-policy.html`
- **Terms of Use**: `https://YOUR_USERNAME.github.io/geopin-pages/terms-of-use.html`
- **Contact Us**: `https://YOUR_USERNAME.github.io/geopin-pages/contact.html`
- **Home**: `https://YOUR_USERNAME.github.io/geopin-pages/` (or `/index.html`)

Replace `YOUR_USERNAME` with your actual GitHub username.

## Step 5: Update App Links

Once you have your GitHub Pages URLs, update the following files in your Flutter app:

### In `lib/main.dart` (Settings Screen):

Find the URL launcher sections and update:

```dart
// Privacy Policy
await launchUrl(Uri.parse('https://YOUR_USERNAME.github.io/geopin-pages/privacy-policy.html'));

// Terms of Use
await launchUrl(Uri.parse('https://YOUR_USERNAME.github.io/geopin-pages/terms-of-use.html'));

// Contact Us
await launchUrl(Uri.parse('https://YOUR_USERNAME.github.io/geopin-pages/contact.html'));
```

### In `lib/paywall_screen.dart`:

Find the footer links and update:

```dart
// Privacy Policy
await launchUrl(Uri.parse('https://YOUR_USERNAME.github.io/geopin-pages/privacy-policy.html'));

// Terms of Use
await launchUrl(Uri.parse('https://YOUR_USERNAME.github.io/geopin-pages/terms-of-use.html'));
```

## Step 6: Test Your Links

1. Open the GitHub Pages URLs in your browser to verify they work
2. Run your Flutter app
3. Click on Privacy Policy, Terms of Use, and Contact Us links
4. Verify they open correctly in the browser

## Notes

- GitHub Pages is **free** for public repositories
- Changes to HTML files will automatically update on GitHub Pages (may take 1-2 minutes)
- You can use a custom domain if you want (optional)
- All pages are mobile-responsive and work on iOS/Android browsers

## Troubleshooting

If pages don't load:
1. Check that GitHub Pages is enabled in Settings → Pages
2. Verify the branch and folder are correct
3. Wait a few minutes for deployment
4. Check the repository is **Public**
5. Verify file names match exactly (case-sensitive)

## Custom Domain (Optional)

If you want to use your own domain:
1. Buy a domain (e.g., geopin.app)
2. In GitHub Settings → Pages, add your custom domain
3. Update DNS records with your domain provider
4. Update app URLs to use your custom domain
