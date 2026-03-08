# Changelog

## [2.1.6] - 2026-03-08

### Fixed
- `remove_arabic_diacritics` now strips standard fathatan + alef (ًا, U+064B + U+0627), the classic tanwin marker: `نَصِیرًا` → `نصیر`

## [2.1.5] - 2026-03-08

### Fixed
- `remove_arabic_diacritics` now handles Extended Arabic tanwin marks (U+08F0–08F2, open fathatan/dammatan/kasratan): `ࣰا` is stripped, so `نَصِیبࣰا` → `نصیب`
- Added Extended Arabic block (U+08D3–08FF) to general diacritic stripping range

## [2.1.4] - 2026-03-08

### Fixed
- `remove_arabic_diacritics` now strips the Uthmani tanwin alef: `ۢا` (U+06E2 small high noon + alef) is removed, so `یَقِینَۢا` → `یقین` instead of `یقینا`

## [2.1.3] - 2026-03-08

### Changed
- `remove_arabic_diacritics` now strips the definite article `ال` from words ≥5 letters (e.g. `الرحيم` → `رحيم`, `الله` kept unchanged at 4 letters)
- `ـٰ` (tatweel + superscript alef) is now preserved as `ا` instead of being deleted, restoring long vowels (e.g. `الرَّحْمَـٰنِ` → `رحمان` instead of `رحمن`)

## [2.1.2] - 2026-03-08

### Fixed
- Removed 70,737 stale `word-*.md` (hash-named) files from `_words/` that conflicted with current Arabic-named word files, causing Jekyll build conflicts on shared permalink destinations
- Cleaned up dead code in `word_to_slug` in `scripts/generate-verses.rb` — the MD5 hash was computed but ignored (function was returning the word directly)

## [2.1.1] - 2026-03-08

### Fixed
- `remove_arabic_diacritics` in `lib/arabic_utils.rb`: removed accidental inclusion of `\u062D` (Arabic letter Ha ح) in the diacritics list, which was stripping a real letter from words
- Simplified diacritics removal to a clean 3-step regex chain covering all Arabic tashkeel, Quranic marks, alef wasla, tatweel, and combining diacritics
- All 21 tests now pass (was 4 failures)

## [2.1.0] - 2026-03-04

### Added
- **Word Index System**: Complete word indexing for all Quran words
  - Main alphabet index page at `/words/` showing all 34 Arabic letters
  - Individual letter pages with paginated word lists (24 words per page)
  - 18,857 unique word pages (after removing diacritical marks)
  - 806 paginated letter pages for easy browsing
  - Each word page shows all occurrences across the Quran with verse links
- **Diacritic Removal**: Words indexed without tashkeel marks for better word matching and grouping
- **Hash-based URLs**: MD5-based slugs for word pages to avoid URL encoding issues with Arabic characters
- Beautiful card-based grid layouts for alphabet and word displays
- Responsive pagination system with Previous/Next navigation
- "Back to Alphabet" navigation on letter pages

### Changed
- **Converted generate-verses.js to Ruby**: Complete migration from Node.js to Ruby
  - Removed all Node.js dependencies (no more package.json needed)
  - Script now generates verses, words, alphabet index, and paginated letter pages
  - Added `remove_arabic_diacritics()` function for word normalization
  - Added `word_to_slug()` function for consistent URL generation
- Updated CSS with new styles for alphabet index, letter pages, and pagination
- Updated navigation to include "Words" link in main menu
- Updated Jekyll configuration to support `_words` collection

### Removed
- Node.js dependencies (package.json is now optional, only for Decap CMS)
- Old `scripts/generate-verses.js` (replaced with Ruby version)

## [2.0.0] - 2026-02-27

### Changed
- **Breaking:** Migrated entire project from Eleventy (11ty) to Jekyll
- Converted all Nunjucks templates (`.njk`) to Liquid templates (`.html`)
- Updated directory structure to Jekyll conventions:
  - `src/_includes/` → `_layouts/`
  - `src/verses/` → `_verses/` (Jekyll collection)
  - `src/css/` → `assets/css/`
  - `src/admin/` → `admin/`
- Updated build system from Eleventy to Jekyll with Ruby Bundler
- Converted template syntax from Nunjucks to Liquid:
  - Variable access: `{{ variable }}` → `{{ page.variable }}`
  - Filters: `| safe` → removed (unnecessary in Liquid)
  - Logic: `{% set %}` → `{% assign %}`
- Updated package.json scripts for Jekyll workflow
- Updated generate-verses.js script to target Jekyll `_verses` collection
- Updated Decap CMS configuration for Jekyll structure

### Added
- `_config.yml` Jekyll configuration file
- `Gemfile` for Ruby gem dependencies
- Jekyll plugins: jekyll-feed, jekyll-sitemap
- Jekyll collections configuration for verses

### Removed
- `.eleventy.js` configuration file
- `@11ty/eleventy` npm dependency
- `src/` directory structure

## [1.6.2] - 2026-02-27

### Added
- Backwards-compatible redirect pages so legacy `/verse/:globalVerseNumber/` URLs continue to work

## [1.6.1] - 2026-02-27

### Changed
- Combined surah number and type emoji into single element on surahs page for cleaner layout

## [1.6.0] - 2026-02-22

### Changed
- **Breaking:** Changed verse URL structure from `/verse/:globalVerseNumber/` to `/surah/:surahNumber/:verseInSurah/`
- Updated all navigation links to use new semantic URL format
- Updated quick links, surahs page, and random verse functionality

### Added
- 404 error page for better user experience
- `.nojekyll` file for GitHub Pages compatibility
- `goToVerse()` helper function for converting global verse numbers to surah/verse format

### Fixed
- GitHub Pages compatibility issues

## [1.5.1] - 2026-02-22

### Added
- Clickable filter buttons in legend to filter surahs by Makki/Madani
- Improved emoji icon positioning (aligned to right of card)

## [1.5.0] - 2026-02-22

### Added
- 🕋/🕌 classification for all 114 surahs on /surahs page
- Visual differentiation: green border for 🕋, blue border for 🕌
- Legend showing 🕋/🕌 color coding

## [1.4.1] - 2026-02-22

### Added
- `/random` route that redirects to a random verse

## [1.4.0] - 2026-02-22

### Fixed
- Separated Bismillah from first verse content for all surahs (except Al-Fatihah where it IS verse 1)
- Bismillah now displays above verse content with proper styling

## [1.3.0] - 2026-02-22

### Fixed
- Fixed surah detection logic using exact verse counts instead of Bismillah detection
- Corrected surah start verses in surahs index page

### Added
- "Start of Surah" and "Next Surah" navigation buttons on verse pages
- Surah navigation data in verse frontmatter (surahStartVerse, surahEndVerse, nextSurahStart)

## [1.2.0] - 2026-02-22

### Added
- Surahs index page at /surahs/ with links to all 114 chapters
- Random Verse button in navigation and home page
- Action buttons on home page for quick access to surahs and random verse

## [1.1.0] - 2026-02-22

### Added
- Chapter (Surah) detection using Bismillah pattern
- English Surah names for all 114 chapters
- Surah header on verse pages showing chapter name and verse number within surah

### Changed
- Changed website language from Arabic to English
- Updated UI fonts: Inter for English text, Amiri for Arabic verses
- Improved home page with better quick links showing surah names

## [1.0.0] - 2026-02-22

### Added
- Initial project setup with Eleventy static site generator
- Decap CMS integration for content management
- Script to generate verse markdown files from quran-uthmani.txt
- Individual page for each of the 6236 Quran verses
- Arabic RTL support with Amiri font
- Responsive design with modern styling
- Navigation between verses (previous/next)
- Home page with verse search and quick links
- Admin panel at /admin/ for Decap CMS

### Fixed
- Fixed verse generation script to use line numbers as verse numbers (one verse per line format)
