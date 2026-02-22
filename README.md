# Quran Verses Website

A beautiful static website displaying all 6236 verses of the Holy Quran, built with Eleventy and Decap CMS.

## Features

- **Individual Verse Pages**: Each verse has its own dedicated page
- **Arabic RTL Support**: Proper right-to-left text rendering with Amiri font
- **Responsive Design**: Works on desktop and mobile devices
- **Navigation**: Easy navigation between verses
- **Decap CMS**: Content management interface at `/admin/`
- **Fast Static Site**: Built with Eleventy for optimal performance

## Setup

### Prerequisites
- Node.js (v14 or higher)

### Installation

1. Install dependencies:
```bash
npm install
```

2. Generate verse files from quran-uthmani.txt:
```bash
npm run generate-verses
```

3. Build the site:
```bash
npm run build
```

4. Or serve locally for development:
```bash
npm run serve
```

The site will be available at `http://localhost:8080`

## Project Structure

```
├── src/
│   ├── _includes/       # Nunjucks templates
│   │   ├── base.njk     # Base layout
│   │   └── verse.njk    # Verse page template
│   ├── admin/           # Decap CMS admin interface
│   │   ├── config.yml   # CMS configuration
│   │   └── index.html   # CMS entry point
│   ├── css/             # Stylesheets
│   │   └── style.css    # Main styles
│   ├── verses/          # Generated verse markdown files
│   └── index.njk        # Home page
├── scripts/
│   └── generate-verses.js  # Script to generate verse files
├── quran-uthmani.txt    # Source Quran text
├── .eleventy.js         # Eleventy configuration
└── package.json         # Project dependencies
```

## Decap CMS

To use Decap CMS locally:

1. Install the Decap CMS proxy server:
```bash
npx decap-server
```

2. Run in a separate terminal:
```bash
npm run serve
```

3. Access the admin at `http://localhost:8080/admin/`

For production deployment with Netlify, configure Git Gateway in Netlify Identity settings.

## Deployment

This site can be deployed to any static hosting service like Netlify, Vercel, or GitHub Pages.

For Netlify:
1. Connect your repository
2. Build command: `npm run generate-verses && npm run build`
3. Publish directory: `_site`
