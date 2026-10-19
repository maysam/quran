# Project Plan

## Completed Tasks

### Create Quran Verses Website with Decap CMS
- [x] Analyze quran-uthmani.txt structure (6236 verses, one per line)
- [x] Set up Eleventy static site generator
- [x] Configure Decap CMS admin interface
- [x] Create verse generation script
- [x] Generate 6236 verse markdown files
- [x] Create templates (base.njk, verse.njk)
- [x] Add CSS styling with RTL Arabic support
- [x] Create home page with search and navigation
- [x] Test and verify site builds successfully

### Add Chapter Detection and English UI
- [x] Detect chapter boundaries using Bismillah pattern (111 found)
- [x] Add English Surah names for all 114 chapters
- [x] Update verse generation to include surah number, name, and verse-in-surah
- [x] Change all UI text from Arabic to English
- [x] Update fonts: Inter for English, Amiri for Arabic verses
- [x] Regenerate all 6236 verse files with chapter data

### Add Surahs Page and Random Verse
- [x] Create /surahs/ page with grid of all 114 surahs
- [x] Add Random Verse button to navigation
- [x] Add action buttons on home page for surahs and random verse
- [x] Add CSS styles for surah grid and action buttons

### Fix Surah Detection and Add Surah Navigation
- [x] Replace Bismillah-based detection with exact verse counts for all 114 surahs
- [x] Regenerate all 6236 verse files with correct surah assignments
- [x] Add surah navigation data to frontmatter (surahStartVerse, surahEndVerse, nextSurahStart)
- [x] Add "Start of Surah" and "Next Surah" navigation buttons on verse pages
- [x] Update surahs.njk with correct starting verse numbers

### Fix Bismillah Concatenation
- [x] Separate Bismillah from first verse content for surahs 2-114 (except At-Tawbah)
- [x] Add hasBismillah field to verse frontmatter
- [x] Display Bismillah above verse content with dedicated styling
- [x] Keep Al-Fatihah verse 1 unchanged (Bismillah IS the verse)

### Update Verse Routing and GitHub Pages Compatibility
- [x] Change URL structure from `/verse/:globalVerseNumber/` to `/surah/:surahNumber/:verseInSurah/`
- [x] Update generate-verses.js script with new permalink format
- [x] Update verse.njk template with new navigation links
- [x] Update surahs.njk with new surah links
- [x] Update index.njk quick links and search functionality
- [x] Update random.njk with new URL conversion logic
- [x] Add .nojekyll file for GitHub Pages compatibility
- [x] Add 404.html error page
- [x] Regenerate all 6236 verse files with new permalinks

### Restore Legacy Global Verse URLs
- [x] Add backwards-compatible redirect pages for legacy `/verse/:globalVerseNumber/` URLs

### Migrate from Eleventy to Jekyll
- [x] Migrate entire project from Eleventy (11ty) to Jekyll
- [x] Convert all Nunjucks templates to Liquid templates (.html)
- [x] Update directory structure to Jekyll conventions (_layouts/, _verses/, assets/)
- [x] Create Gemfile and _config.yml for Jekyll
- [x] Update Decap CMS configuration for Jekyll structure
- [x] Regenerate all verse files with Jekyll permalinks

### Add Comprehensive Word Index System
- [x] Convert generate-verses.js from Node.js to Ruby (generate-verses.rb)
- [x] Implement diacritic removal for word normalization
- [x] Generate 18,857 unique word pages (one for each word without diacritics)
- [x] Create main alphabet index page at /words/ with 34 Arabic letters
- [x] Generate 806 paginated letter pages (24 words per page)
- [x] Implement hash-based URL slugs for word pages (MD5)
- [x] Add pagination system with Previous/Next navigation
- [x] Create word page layout showing all occurrences
- [x] Add CSS styling for alphabet grid, letter pages, and pagination
- [x] Update navigation to include "Words" link

### Root Extraction Using Weights (أوزان)
- [x] Parse vowelized words into letter units (letter, vowel, shadda, silent)
- [x] Vowel-aware proclitic/suffix stripping
- [x] Match stems against vowelized ف ع ل weight templates (sound, hollow, defective, geminate, assimilated, quadriliteral)
- [x] Common-roots lexicon tie-breaker for weak radicals; particles and irregular words
- [x] `remove_arabic_diacritics(text, root: true)`, `arabic_word_root`, `analyze_arabic_word`
- [x] Show root on word pages; tests added; ~91% vs Quranic Arabic Corpus gold roots
- [x] Regenerate content (`ruby scripts/generate-verses.rb`) so word pages include roots
- [x] Root index pages grouping all words of a root

### Strip Prefixes/Postfixes and Return Roots by Default
- [x] `remove_arabic_diacritics` returns roots by default; `root: false` returns stems; old behaviour kept as `strip_arabic_diacritics`
- [x] One analysis path for every word (particles, pronouns, divine name, irregular words included) so prefixes are always stripped
- [x] Vowel-driven rules: long-vowel agreement, tanwin/article ⇒ noun, imperative endings, vowelized particle entries
- [x] Evaluated against Quranic Arabic Corpus segmentation: prefixes 99.4%, postfixes 96.8%, roots 95.1%
- [x] Word index keyed by root with word-form lists; generator clears stale pages; content regenerated; Jekyll build verified

### Filter Root Pages by Word Form
- [x] Word-form chips link to `/words/<root>/<form>/` (paginated, only that form highlighted); "All" chip back to the root
- [x] Shared `write_occurrence_pages` for root and form lists; `form:` front matter
- [x] Fixed invisible "Next →" label on word pages; verified in the browser (desktop and mobile)

### Corrections: Form VIII Assimilation (اصطفیتك)
- [x] `ٱصۡطَفَیۡتُكَ` → `اصطفی` + `تك`, root ص ف و (ط is the assimilated ت of اِفْتَعَلَ, not a root letter)
- [x] ت → ط after ص ض ط ظ, ت → د after د ذ ز; passive اُفْتُعِلَ; ذ + ت → دّ read as ذ (مُدَّكِر)
- [x] Imperfect prefixes never take kasra (نِصۡف stays نصف)

### Corrections: فخور
- [x] `فَخُورٌ` → فخر (فَعُول), not فَ + خور → خیر
- [x] Hollow long vowel: و after damma is always و; ا/ی may be و or ی, never a hamza (وَسِیلَة → وسل); alternatives kept per radical position
- [x] سَوۡفَ added as a particle; فخر added to the common roots

## Current Prompt
**Task**: correction — the root for فَخُورٌ is فخر
- `فَخُورٌ` was split as فَ + خُور and its و swapped to ی (خیر); now it is the weight فَعُول of فخر
- A long و after damma is never swapped, and a hollow long vowel never stands for a hamza (also fixed وَسِیلَة → وسل); سَوۡفَ is a particle

## Project Structure
```
/Users/maysam/Workspace/aralel/indented/
├── _layouts/            # Jekyll layouts (default, verse, word)
├── _verses/             # 6,236 verse markdown files (Jekyll collection)
├── _words/              # ~2,400 root/particle pages (Jekyll collection)
├── words/               # Paginated letter pages
│   ├── 1569/           # Letter ء pages
│   │   ├── index.html  # Page 1
│   │   └── page/       # Pages 2-9
│   ├── 1571/           # Letter أ pages
│   └── ...             # 34 letters total
├── admin/               # Decap CMS admin interface
├── assets/
│   └── css/
│       └── style.css    # Main styles
├── scripts/
│   └── generate-verses.rb  # Ruby script for generation
├── _config.yml          # Jekyll configuration
├── Gemfile              # Ruby dependencies
├── words.html           # Main alphabet index
└── quran-uthmani.txt    # Source Quran text
```

## Commands
- `bundle install` - Install Ruby dependencies
- `ruby scripts/generate-verses.rb` - Generate all content (verses, words, alphabet, letter pages)
- `bundle exec jekyll serve` - Run dev server at http://localhost:4000
- `bundle exec jekyll build` - Build static site to _site/
