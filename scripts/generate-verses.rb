require 'fileutils'
require 'json'
require_relative '../lib/arabic_utils'

# Generate a URL-safe slug for a word (use word directly as slug)
def word_to_slug(word)
  word
end

# Highlight occurrences of target_slug word within verse text HTML
# Wraps matching anchor tags (same root) with a highlight span; with target_form, only the words of
# that form (the word without prefixes/postfixes, e.g. أحكم under حكم) are highlighted
def highlight_word_in_verse(verse_html, target_slug, target_form = nil)
  verse_html.gsub(/<a href='([^']*)'>(.*?)<\/a>/) do
    href = $1
    original_word = $2
    cleaned = remove_arabic_diacritics(original_word)
    if cleaned == target_slug && (target_form.nil? || arabic_word_stem(original_word) == target_form)
      "<a href='#{href}'><span class=\"word-highlight\">#{original_word}</span></a>"
    else
      "<a href='#{href}'>#{original_word}</a>"
    end
  end
end


# The word forms of a root as filter links: "All" leads back to the root page and each form to the
# list of its own occurrences (/words/<root>/<form>/); the list being shown is marked active
def word_forms_filter_html(root_slug, word_forms, total_occurrences, active_form)
  if word_forms.length < 2
    only_form, only_form_count = word_forms.first
    return "<p class=\"word-forms\" lang=\"ar\"><span class=\"word-form active\">#{only_form} <small>#{only_form_count}</small></span></p>"
  end

  all_forms_link = "<a href=\"/words/#{root_slug}/\" class=\"word-form all#{' active' if active_form.nil?}\">All <small>#{total_occurrences}</small></a>"
  form_links = word_forms.map do |form, form_count|
    "<a href=\"/words/#{root_slug}/#{form}/\" class=\"word-form#{' active' if form == active_form}\">#{form} <small>#{form_count}</small></a>"
  end
  "<p class=\"word-forms\" lang=\"ar\">#{([all_forms_link] + form_links).join(' ')}</p>"
end

OCCURRENCES_PER_PAGE = 20

# Write occurrences as paginated word pages: page 1 at /words/<url_slug>/ (file _words/<url_slug>.md),
# later pages at /words/<url_slug>/page/N/ (file _words/<url_slug>/page/N/index.md).
# Verses highlight the words of highlight_slug (only those of highlight_form, when given).
# Returns the number of pages written.
def write_occurrence_pages(words_dir, url_slug, occurrences, title:, word:, root:, form:, header:, highlight_slug:, highlight_form: nil)
  total_pages = (occurrences.length.to_f / OCCURRENCES_PER_PAGE).ceil

  (1..total_pages).each do |page_num|
    page_occurrences = occurrences.slice((page_num - 1) * OCCURRENCES_PER_PAGE, OCCURRENCES_PER_PAGE)

    occurrences_html = "<ul>\n" + page_occurrences.map do |occ|
      highlighted_verse = highlight_word_in_verse(occ[:word_text], highlight_slug, highlight_form)
      surah_label = "#{occ[:surah_name]} #{occ[:surah_number]}:#{occ[:verse_in_surah]}"
      "  <li>#{highlighted_verse}\n    <a href=\"#{occ[:path]}\" class=\"surah-caption\">#{surah_label}</a>\n  </li>"
    end.join("\n") + "\n</ul>"

    # Build pagination HTML
    pagination_html = if total_pages > 1
      prev_url = page_num > 1 ? (page_num == 2 ? "/words/#{url_slug}/" : "/words/#{url_slug}/page/#{page_num - 1}/") : nil
      next_url = page_num < total_pages ? "/words/#{url_slug}/page/#{page_num + 1}/" : nil
      prev_link = prev_url ? "<a href=\"#{prev_url}\" class=\"page-link prev\">← Previous</a>" : '<span class="page-link disabled">← Previous</span>'
      next_link = next_url ? "<a href=\"#{next_url}\" class=\"page-link next\">Next →</a>" : '<span class="page-link disabled">Next →</span>'
      "<div class=\"pagination\">#{prev_link}<span class=\"page-info\">Page #{page_num} of #{total_pages}</span>#{next_link}</div>"
    else
      ''
    end

    permalink = page_num == 1 ? "/words/#{url_slug}/" : "/words/#{url_slug}/page/#{page_num}/"

    markdown = <<~MARKDOWN
      ---
      title: "#{title.gsub('"', '\\"')}"
      word: "#{word.gsub('"', '\\"')}"
      root: "#{root.gsub('"', '\\"')}"
      form: "#{form.gsub('"', '\\"')}"
      occurrences: #{occurrences.length}
      layout: word
      permalink: #{permalink}
      pagination_html: "#{pagination_html.gsub('"', '\\"')}"
      ---

      #{header}

      #{pagination_html}

      ## Occurrences

      #{occurrences_html}

      #{pagination_html}
    MARKDOWN

    file_path = if page_num == 1
      File.join(words_dir, "#{url_slug}.md")
    else
      File.join(words_dir, url_slug, 'page', page_num.to_s, 'index.md')
    end
    FileUtils.mkdir_p(File.dirname(file_path))
    File.write(file_path, markdown, encoding: 'utf-8')
  end

  total_pages
end

# Surah data: [name, verseCount]
surah_data = [
  ["Al-Fatihah", 7], ["Al-Baqarah", 286], ["Aal-E-Imran", 200], ["An-Nisa", 176], ["Al-Ma'idah", 120],
  ["Al-An'am", 165], ["Al-A'raf", 206], ["Al-Anfal", 75], ["At-Tawbah", 129], ["Yunus", 109],
  ["Hud", 123], ["Yusuf", 111], ["Ar-Ra'd", 43], ["Ibrahim", 52], ["Al-Hijr", 99],
  ["An-Nahl", 128], ["Al-Isra", 111], ["Al-Kahf", 110], ["Maryam", 98], ["Ta-Ha", 135],
  ["Al-Anbiya", 112], ["Al-Hajj", 78], ["Al-Mu'minun", 118], ["An-Nur", 64], ["Al-Furqan", 77],
  ["Ash-Shu'ara", 227], ["An-Naml", 93], ["Al-Qasas", 88], ["Al-Ankabut", 69], ["Ar-Rum", 60],
  ["Luqman", 34], ["As-Sajdah", 30], ["Al-Ahzab", 73], ["Saba", 54], ["Fatir", 45],
  ["Ya-Sin", 83], ["As-Saffat", 182], ["Sad", 88], ["Az-Zumar", 75], ["Ghafir", 85],
  ["Fussilat", 54], ["Ash-Shura", 53], ["Az-Zukhruf", 89], ["Ad-Dukhan", 59], ["Al-Jathiyah", 37],
  ["Al-Ahqaf", 35], ["Muhammad", 38], ["Al-Fath", 29], ["Al-Hujurat", 18], ["Qaf", 45],
  ["Adh-Dhariyat", 60], ["At-Tur", 49], ["An-Najm", 62], ["Al-Qamar", 55], ["Ar-Rahman", 78],
  ["Al-Waqi'ah", 96], ["Al-Hadid", 29], ["Al-Mujadila", 22], ["Al-Hashr", 24], ["Al-Mumtahanah", 13],
  ["As-Saff", 14], ["Al-Jumu'ah", 11], ["Al-Munafiqun", 11], ["At-Taghabun", 18], ["At-Talaq", 12],
  ["At-Tahrim", 12], ["Al-Mulk", 30], ["Al-Qalam", 52], ["Al-Haqqah", 52], ["Al-Ma'arij", 44],
  ["Nuh", 28], ["Al-Jinn", 28], ["Al-Muzzammil", 20], ["Al-Muddaththir", 56], ["Al-Qiyamah", 40],
  ["Al-Insan", 31], ["Al-Mursalat", 50], ["An-Naba", 40], ["An-Nazi'at", 46], ["Abasa", 42],
  ["At-Takwir", 29], ["Al-Infitar", 19], ["Al-Mutafficin", 36], ["Al-Inshiqaq", 25], ["Al-Buruj", 22],
  ["At-Tariq", 17], ["Al-A'la", 19], ["Al-Ghashiyah", 26], ["Al-Fajr", 30], ["Al-Balad", 20],
  ["Ash-Shams", 15], ["Al-Layl", 21], ["Ad-Dhuha", 11], ["Ash-Sharh", 8], ["At-Tin", 8],
  ["Al-Alaq", 19], ["Al-Qadr", 5], ["Al-Bayyinah", 8], ["Az-Zalzalah", 8], ["Al-Adiyat", 11],
  ["Al-Qari'ah", 11], ["At-Takathur", 8], ["Al-Asr", 3], ["Al-Humazah", 9], ["Al-Fil", 5],
  ["Quraysh", 4], ["Al-Ma'un", 7], ["Al-Kawthar", 3], ["Al-Kafirun", 6], ["An-Nasr", 3],
  ["Al-Masad", 5], ["Al-Ikhlas", 4], ["Al-Falaq", 5], ["An-Nas", 6]
]

# Build surah lookup with start/end verses
surahs = []
current_verse = 1
surah_data.each_with_index do |(name, verse_count), i|
  surahs << {
    number: i + 1,
    name: name,
    start_verse: current_verse,
    end_verse: current_verse + verse_count - 1,
    verse_count: verse_count
  }
  current_verse += verse_count
end

puts "Total verses calculated: #{current_verse - 1}"

# Ensure verses directory exists
verses_dir = "_verses"
FileUtils.mkdir_p(verses_dir)

# Read the Quran file
quran_file = "quran-uthmani.txt"
content = File.read(quran_file, encoding: 'utf-8')
lines = content.split("\n").map(&:strip).reject(&:empty?)

puts "Processing #{lines.length} verses..."

# Get surah info for a verse number (1-indexed)
def get_surah_info(verse_number, surahs)
  surahs.each do |surah|
    if verse_number >= surah[:start_verse] && verse_number <= surah[:end_verse]
      return {
        surah_number: surah[:number],
        surah_name: surah[:name],
        verse_in_surah: verse_number - surah[:start_verse] + 1,
        surah_start_verse: surah[:start_verse],
        surah_end_verse: surah[:end_verse],
        surah_verse_count: surah[:verse_count]
      }
    end
  end
  nil
end

# Bismillah is the first verse of Al-Fatihah - use it as the pattern
bismillah = lines[0].strip
puts "Bismillah detected: #{bismillah[0..29]}..."

word_index = {}
created = 0

lines.each_with_index do |line, index|
  verse_number = index + 1
  verse_text = line.strip

  next if verse_text.empty?

  surah_info = get_surah_info(verse_number, surahs)
  unless surah_info
    puts "Could not find surah info for verse #{verse_number}"
    next
  end

  # For first verse of surahs (except Al-Fatihah), split Bismillah from verse content
  # Al-Fatihah (surah 1) verse 1 IS the Bismillah itself
  # At-Tawbah (surah 9) has no Bismillah
  has_bismillah = false
  if surah_info[:verse_in_surah] == 1 && surah_info[:surah_number] != 1 && surah_info[:surah_number] != 9
    if verse_text.start_with?(bismillah)
      has_bismillah = true
      verse_text = verse_text[bismillah.length..-1].strip
    end
  end

  # Calculate next surah start verse
  next_surah_start = surah_info[:surah_number] < 114 ? surahs[surah_info[:surah_number]][:start_verse] : nil

  # Escape special characters for YAML
  escaped_text = verse_text.gsub('"', '\\"').gsub("\n", ' ')


  words = line.split(' ')

  # Build word links first (needed for both verse page and word index);
  # remove_arabic_diacritics strips prefixes/postfixes and gives the word's root, so pages are per root
  word_links = words.map do |original_word|
    word = remove_arabic_diacritics(original_word)
    next if word.strip.empty?
    url = "/words/#{word_to_slug(word)}/"
    [word, "<a href='#{url}'>#{original_word}</a>", original_word]
  end.compact

  word_text = word_links.map { |_, link, _| link }.join(" ")

  # Collect all words for index
  word_links.each do |cleaned_word, _link, original_word|
    word_index[cleaned_word] ||= []
    word_index[cleaned_word] << {
      original_word: original_word,
      stem: arabic_word_stem(original_word),
      verse_number: verse_number,
      escaped_text: escaped_text,
      word_text: word_text,
      verse_in_surah: surah_info[:verse_in_surah],
      surah_number: surah_info[:surah_number],
      surah_name: surah_info[:surah_name],
      path: "/surah/#{surah_info[:surah_number]}/#{surah_info[:verse_in_surah]}/"
    }
  end

  # Create markdown file with frontmatter
  slug = "verse-#{verse_number.to_s.rjust(4, '0')}"
  markdown = <<~MARKDOWN
    ---
    title: "Surah #{surah_info[:surah_name]} - Verse #{surah_info[:verse_in_surah]}"
    verseNumber: #{verse_number}
    surahNumber: #{surah_info[:surah_number]}
    surahName: "#{surah_info[:surah_name]}"
    verseInSurah: #{surah_info[:verse_in_surah]}
    surahStartVerse: #{surah_info[:surah_start_verse]}
    surahEndVerse: #{surah_info[:surah_end_verse]}
    surahVerseCount: #{surah_info[:surah_verse_count]}
    nextSurahStart: #{next_surah_start || 'null'}
    hasBismillah: #{has_bismillah}
    verseText: "#{escaped_text}"
    word_text: "#{word_text}"
    layout: verse
    permalink: /surah/#{surah_info[:surah_number]}/#{surah_info[:verse_in_surah]}/
    ---

    #{word_text}
  MARKDOWN

  file_path = File.join(verses_dir, "#{slug}.md")
  File.write(file_path, markdown, encoding: 'utf-8')
  created += 1

  puts "Verse #{verse_number}: #{words.length} words"
end

puts "Generated #{created} verse files in #{verses_dir}"


# Merge words starting with "ال" with their base forms
word_index.each do |word, occurrences|
  if word.start_with?('ال')
    base_word = word[2..-1] # Remove "ال" prefix
    if word_index.key?(base_word)
      # Merge occurrences
      word_index[base_word].concat(occurrences)
      # Remove the "ال" prefixed word
      word_index.delete(word)
    end
  end
end



# Save word index to JSON file
word_index_path = File.join(__dir__, '..', '_data', 'words.json')
FileUtils.mkdir_p(File.dirname(word_index_path))
File.write(word_index_path, JSON.pretty_generate(word_index), encoding: 'utf-8')

# Create word pages
words_dir = File.join(__dir__, '..', '_words')
FileUtils.mkdir_p(words_dir)
# remove pages left by earlier runs, so a word no longer in the index (e.g. بأحكم, now under حكم) disappears
FileUtils.rm_rf(Dir.glob(File.join(words_dir, '*')))

puts "\nGenerating word pages..."
word_count = 0
form_list_count = 0

word_index.each do |word, occurrences|
  slug = word_to_slug(word)
  total_occurrences = occurrences.length
  original_word = occurrences.first[:original_word]
  # a root page (ح ك م) lists the word forms built on the root; particles keep their own page
  root_page = analyze_arabic_word(original_word)[:kind] == :root
  page_heading = root_page ? word.chars.join(' ') : word
  page_title = "#{root_page ? 'Root' : 'Word'}: #{page_heading}"
  word_forms = occurrences.map { |occurrence| occurrence[:stem] }.tally.sort_by { |stem, count| [-count, stem] }

  root_header = <<~MARKDOWN
    # #{page_heading}

    #{root_page ? word_forms_filter_html(slug, word_forms, total_occurrences, nil) : ''}

    This #{root_page ? 'root' : 'word'} appears **#{total_occurrences} time#{'s' if total_occurrences != 1}** in the Quran.
  MARKDOWN
  write_occurrence_pages(words_dir, slug, occurrences,
                         title: page_title, word: word, root: root_page ? word : '', form: '',
                         header: root_header, highlight_slug: word)

  # clicking a form filters the root's occurrences: each form gets its own list at /words/<root>/<form>/
  if root_page && word_forms.length > 1
    occurrences.group_by { |occurrence| occurrence[:stem] }.each do |form, form_occurrences|
      form_header = <<~MARKDOWN
        # #{page_heading}

        #{word_forms_filter_html(slug, word_forms, total_occurrences, form)}

        The form <strong><bdi lang="ar" class="word-form-name">#{form}</bdi></strong> appears **#{form_occurrences.length} time#{'s' if form_occurrences.length != 1}** in the Quran.
      MARKDOWN
      write_occurrence_pages(words_dir, "#{slug}/#{form}", form_occurrences,
                             title: "#{page_title} · #{form}", word: word, root: word, form: form,
                             header: form_header, highlight_slug: word, highlight_form: form)
      form_list_count += 1
    end
  end

  word_count += 1
end

puts "Generated #{word_count} word pages and #{form_list_count} word-form lists in #{words_dir}"

# Create alphabet index
puts "\nGenerating alphabet index..."

# Group words by first letter
alphabet_groups = {}
word_index.keys.sort.each do |word|
  first_letter = word[0]
  alphabet_groups[first_letter] ||= []
  alphabet_groups[first_letter] << word
end

# Create main index page (just alphabet)
index_content = <<~MARKDOWN
  ---
  title: "Word Index"
  layout: default
  permalink: /words/
  ---

  <div class="alphabet-index">

  # Word Index

  Browse all #{word_count} roots and particles of the Quran by letter.

  <div class="alphabet-grid">

MARKDOWN

# Add alphabet cards
alphabet_groups.keys.sort.each do |letter|
  letter_code = letter.ord
  word_count_for_letter = alphabet_groups[letter].length
  index_content += <<~HTML
    <div class="alphabet-card">
      <a href="/words/#{letter_code}/">
        <div class="alphabet-letter">#{letter}</div>
        <div class="alphabet-count">#{word_count_for_letter} root#{'s' if word_count_for_letter != 1}</div>
      </a>
    </div>

  HTML
end

index_content += "</div>\n\n</div>\n"

index_path = File.join(__dir__, '..', 'words.html')
File.write(index_path, index_content, encoding: 'utf-8')

puts "Generated main word index at #{index_path}"

# Create paginated letter pages
puts "Generating letter pages..."
words_letter_dir = File.join(__dir__, '..', 'words')
FileUtils.mkdir_p(words_letter_dir)
# remove letter pages left by earlier runs (one folder per letter code)
Dir.glob(File.join(words_letter_dir, '*')).each do |letter_page_dir|
  FileUtils.rm_rf(letter_page_dir) if File.basename(letter_page_dir).match?(/\A\d+\z/)
end

per_page = 24*4
letter_pages_created = 0

alphabet_groups.keys.sort.each do |letter|
  letter_code = letter.ord
  letter_dir = File.join(words_letter_dir, letter_code.to_s)
  FileUtils.mkdir_p(letter_dir)

  words_for_letter = alphabet_groups[letter].sort
  total_words = words_for_letter.length
  total_pages = (total_words.to_f / per_page).ceil

  # Create pages for this letter
  (1..total_pages).each do |page_num|
    start_idx = (page_num - 1) * per_page
    end_idx = [start_idx + per_page - 1, total_words - 1].min
    page_words = words_for_letter[start_idx..end_idx]

    # Build the word grid
    words_html = ""
    page_words.each do |word|
      slug = word_to_slug(word)
      occurrences_count = word_index[word].length
      words_html += <<~HTML
        <div class="word-card">
          <a href="/words/#{slug}/">
            <div class="word-arabic">#{word}</div>
            <div class="word-count">#{occurrences_count} occurrence#{'s' if occurrences_count != 1}</div>
          </a>
        </div>

      HTML
    end

    # Build pagination
    pagination_html = '<div class="pagination">'

    if page_num > 1
      prev_page = page_num - 1
      prev_url = prev_page == 1 ? "/words/#{letter_code}/" : "/words/#{letter_code}/page/#{prev_page}/"
      pagination_html += "<a href=\"#{prev_url}\" class=\"page-link prev\">← Previous</a>"
    else
      pagination_html += '<span class="page-link disabled">← Previous</span>'
    end

    pagination_html += "<span class=\"page-info\">Page #{page_num} of #{total_pages}</span>"

    if page_num < total_pages
      next_url = "/words/#{letter_code}/page/#{page_num + 1}/"
      pagination_html += "<a href=\"#{next_url}\" class=\"page-link next\">Next →</a>"
    else
      pagination_html += '<span class="page-link disabled">Next →</span>'
    end

    pagination_html += '</div>'

    # Create page content
    page_content = <<~MARKDOWN
      ---
      title: "Words Starting with #{letter}"
      layout: default
      permalink: #{page_num == 1 ? "/words/#{letter_code}/" : "/words/#{letter_code}/page/#{page_num}/"}
      ---

      <div class="letter-page">

      <div class="letter-header">
        <a href="/words/" class="back-link">← Back to Alphabet</a>
        <h1>#{letter}</h1>
        <p class="letter-info">#{total_words} root#{'s' if total_words != 1} and particles starting with this letter</p>
      </div>

      #{pagination_html}

      <div class="word-grid">

      #{words_html}
      </div>

      #{pagination_html}

      </div>
    MARKDOWN

    # Write the file
    if page_num == 1
      file_path = File.join(letter_dir, 'index.html')
    else
      page_dir = File.join(letter_dir, 'page', page_num.to_s)
      FileUtils.mkdir_p(page_dir)
      file_path = File.join(page_dir, 'index.html')
    end

    File.write(file_path, page_content, encoding: 'utf-8')
    letter_pages_created += 1
  end
end

puts "Generated #{letter_pages_created} letter pages"
puts "\nDone! Summary:"
puts "  - #{created} verse pages"
puts "  - #{word_count} unique word pages (#{form_list_count} word-form lists)"
puts "  - #{alphabet_groups.keys.length} alphabet letters"
puts "  - #{letter_pages_created} paginated letter pages (24 words per page)"
