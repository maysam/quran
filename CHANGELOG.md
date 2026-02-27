# Changelog

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
