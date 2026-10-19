# Quran Verses Website

A beautiful static website displaying all 6236 verses of the Holy Quran with comprehensive word indexing, built with Jekyll and Decap CMS.

## Features

- **Individual Verse Pages**: Each verse has its own dedicated page with full navigation
- **Root Index**: Browse the ~2,400 roots and particles of the Quran alphabetically
- **Root Pages**: Each root lists its word forms and all their occurrences across the Quran
- **Arabic RTL Support**: Proper right-to-left text rendering with Amiri font
- **Root-Based Indexing**: Prefixes and postfixes stripped and every word reduced to its root using its vowels and weight (وزن)
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
├── _words/              # Generated root/particle pages (~2,400 files)
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
- **~2,400 root and particle pages** in `_words/`
- **Word index page** at `/words/`
- **Word occurrence data** in `_data/words.json`

To regenerate all content:
```bash
ruby scripts/generate-verses.rb
```

## Word Indexing

The word index is organised by root (جذر), like a Quran concordance (المعجم المفهرس):
- Every word is stripped of its prefixes (وَ فَ بِ لِ كَ سَ ال …) and postfixes (pronouns, plural/dual and
  verb endings) and reduced to its root, e.g. `بِأَحۡكَمِ` and `ٱلۡحَـٰكِمِینَ` both go to the page of `ح ك م`
- Each root page lists the word forms built on it (أحكم، حاكم، حكیم، حكمة … with counts) and every verse
  where they occur, with those words highlighted
- The word forms are filters: clicking one (e.g. أحكم) shows only its occurrences at `/words/<root>/<form>/`,
  and "All" returns to the whole root
- Particles and pronouns (من، على، الذین، هم …) have no root and keep their own pages
- Roots and particles are organised alphabetically by their first letter

### Root extraction

`lib/arabic_utils.rb` analyses each vowelized Uthmani word as prefixes + a weight (وزن) + postfixes.
The word is split into letters with their vowels; prefixes are peeled off only when their vowel fits
(بِ with kasra, وَ/فَ with fatha, the article with a silent or sukun lam …); the stem is matched
against vowelized weights built on ف ع ل (فَاعِل, مَفْعُول, أَفْعَل, اِسْتَفْعَلَ, یَفْعُلُ, hollow, defective,
geminate and assimilated variants). A weight whose vowels clash with the word is ruled out, a long
vowel must match the vowel before it, an imperfect prefix never takes kasra, tanwin or the article rule
out verb weights, and the ت of اِفْتَعَلَ may appear as ط or د (اِصۡطَفَى ← ص ف و). A list of
frequent Quranic roots breaks ties between equally good readings (قال → قول, not قیل).

```ruby
remove_arabic_diacritics("بِأَحۡكَمِ ٱلۡحَـٰكِمِینَ")              # => "حكم حكم"   (roots)
remove_arabic_diacritics("بِأَحۡكَمِ ٱلۡحَـٰكِمِینَ", root: false) # => "أحكم حاكم" (prefixes/postfixes stripped only)
strip_arabic_diacritics("بِأَحۡكَمِ ٱلۡحَـٰكِمِینَ")               # => "بأحكم حاكمین" (diacritics only, as before)
analyze_arabic_word("بِـَٔایَـٰتِنَا")
# => { root: "أیی", stem: "آیة", kind: :root, weight: "فَعل", proclitics: ["ب"], suffix: "اتنا" }
```

Measured against the Quranic Arabic Corpus segmentation: prefixes are stripped correctly for 99.5% of
words, postfixes for 96.9%, and 95.3% of root-bearing words get the corpus root.

Run the tests with `ruby scripts/test_remove_arabic_diacritics.rb`.

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
