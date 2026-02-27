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

## Project Structure
```
/Users/maysam/Workspace/aralel/indented/
├── src/
│   ├── _includes/       # Templates
│   ├── admin/           # Decap CMS
│   ├── css/             # Styles
│   ├── verses/          # 6236 verse files
│   └── index.njk        # Home page
├── scripts/
│   └── generate-verses.js
├── .eleventy.js
├── package.json
└── quran-uthmani.txt
```

## Commands
- `npm install` - Install dependencies
- `npm run generate-verses` - Generate verse files from quran-uthmani.txt
- `npm run serve` - Run dev server at http://localhost:8080
- `npm run build` - Build static site to _site/
