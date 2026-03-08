# Quran Verses Website

A beautiful static website displaying all 6236 verses of the Holy Quran with comprehensive word indexing, built with Jekyll and Decap CMS.

## Features

- **Individual Verse Pages**: Each verse has its own dedicated page with full navigation
- **Word Index**: Browse 21,106+ unique Quran words alphabetically
- **Individual Word Pages**: Each word shows all its occurrences across the Quran
- **Arabic RTL Support**: Proper right-to-left text rendering with Amiri font
- **Diacritic-Free Indexing**: Words indexed without diacritical marks for better searching
- **Responsive Design**: Works beautifully on desktop and mobile devices
- **Decap CMS**: Content management interface at `/admin/`
- **Fast Static Site**: Built with Jekyll for optimal performance

## Setup

### Prerequisites
- Ruby (v2.7 or higher)
- Bundler gem (`gem install bundler`)

### Installation

1. Install dependencies:
```bash
bundle install
```

2. Generate verse and word files from quran-uthmani.txt:
```bash
ruby scripts/generate-verses.rb
```

3. Build the site:
```bash
bundle exec jekyll build
```

4. Or serve locally for development:
```bash
bundle exec jekyll serve
```

The site will be available at `http://localhost:4000`

## Project Structure

```
├── _layouts/            # Jekyll layouts
│   ├── default.html     # Base layout
│   ├── verse.html       # Verse page template
│   └── word.html        # Word page template
├── _verses/             # Generated verse markdown files (6236 files)
├── _words/              # Generated word markdown files (21106+ files)
├── admin/               # Decap CMS admin interface
│   ├── config.yml       # CMS configuration
│   └── index.html       # CMS entry point
├── assets/
│   └── css/
│       └── style.css    # Main styles
├── _data/
│   └── words.json       # Word index data
├── scripts/
│   └── generate-verses.rb  # Script to generate verse and word files
├── quran-uthmani.txt    # Source Quran text (Uthmani script)
├── _config.yml          # Jekyll configuration
└── Gemfile              # Ruby dependencies
```

## Generating Content

The `generate-verses.rb` script processes the Quran text and creates:
- **6,236 verse pages** in `_verses/`
- **21,106+ word pages** in `_words/`
- **Word index page** at `/words/`
- **Word occurrence data** in `_data/words.json`

To regenerate all content:
```bash
ruby scripts/generate-verses.rb
```

## Word Indexing

The word index feature:
- Removes Arabic diacritical marks (tashkeel) for better word matching
- Creates individual pages for each unique word
- Shows all verses containing each word
- Organizes words alphabetically by Arabic letters

Access the word index at: `/words/`

## Decap CMS

The Decap CMS loads directly from CDN and works out of the box.

To use Decap CMS locally with authentication:

1. Run Jekyll server:
```bash
bundle exec jekyll serve
```

2. Access the admin at `http://localhost:4000/admin/`

For production deployment with Netlify, configure Git Gateway in Netlify Identity settings.

## Deployment

This site can be deployed to any static hosting service that supports Jekyll.

### Netlify
1. Connect your repository
2. Build command: `ruby scripts/generate-verses.rb && bundle exec jekyll build`
3. Publish directory: `_site`

### GitHub Pages
GitHub Pages supports Jekyll natively. Just push to your repository and enable GitHub Pages in settings.

## Development

Common commands:
```bash
# Install dependencies
bundle install

# Generate verse and word content
ruby scripts/generate-verses.rb

# Build the site
bundle exec jekyll build

# Serve locally with live reload
bundle exec jekyll serve

# Serve with drafts
bundle exec jekyll serve --drafts
```
