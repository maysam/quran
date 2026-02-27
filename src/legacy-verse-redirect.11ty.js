module.exports = class LegacyVerseRedirect {
  data() {
    return {
      pagination: {
        data: "legacyVerseNumbers",
        size: 1,
        alias: "verseNumber",
      },
      legacyVerseNumbers: Array.from({ length: 6236 }, (_, i) => i + 1),
      permalink: (data) => `/verse/${data.verseNumber}/`,
      eleventyExcludeFromCollections: true,
    };
  }

  render(data) {
    const surahVerseStarts = [1,8,294,494,670,790,955,1161,1236,1365,1474,1597,1708,1751,1803,1902,2030,2141,2251,2349,2484,2596,2674,2792,2856,2933,3160,3253,3341,3410,3470,3504,3534,3607,3661,3706,3789,3971,4059,4134,4219,4273,4326,4415,4474,4511,4546,4584,4613,4631,4676,4736,4785,4847,4902,4980,5076,5105,5127,5151,5164,5178,5189,5200,5218,5230,5242,5272,5324,5376,5420,5448,5476,5496,5552,5592,5623,5673,5713,5759,5801,5830,5849,5885,5910,5932,5949,5968,5994,6024,6044,6059,6080,6091,6099,6107,6126,6131,6139,6147,6158,6169,6177,6180,6189,6194,6198,6205,6208,6214,6217,6222,6226,6231];

    const verseNumber = Number(data.verseNumber);

    let surahNum = 1;
    for (let i = 0; i < surahVerseStarts.length; i++) {
      if (verseNumber >= surahVerseStarts[i]) {
        surahNum = i + 1;
      } else {
        break;
      }
    }

    const verseInSurah = verseNumber - surahVerseStarts[surahNum - 1] + 1;
    const targetUrl = `/surah/${surahNum}/${verseInSurah}/`;

    return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="refresh" content="0; url=${targetUrl}">
    <link rel="canonical" href="${targetUrl}">
    <title>Redirecting...</title>
  </head>
  <body>
    <script>
      window.location.replace(${JSON.stringify(targetUrl)});
    </script>
  </body>
</html>`;
  }
};
