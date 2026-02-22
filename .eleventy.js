module.exports = function(eleventyConfig) {
  eleventyConfig.addPassthroughCopy("src/admin");
  eleventyConfig.addPassthroughCopy("src/css");
  
  eleventyConfig.addCollection("verses", function(collectionApi) {
    return collectionApi.getFilteredByGlob("src/verses/*.md").sort((a, b) => {
      return a.data.verseNumber - b.data.verseNumber;
    });
  });

  return {
    dir: {
      input: "src",
      output: "_site",
      includes: "_includes"
    },
    markdownTemplateEngine: "njk",
    htmlTemplateEngine: "njk"
  };
};
