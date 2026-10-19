#!/usr/bin/env ruby
# Test suite for strip_arabic_diacritics (diacritics only) and remove_arabic_diacritics
# (prefixes and postfixes stripped, root found from the word's weight)
# Run with: ruby test_remove_arabic_diacritics.rb

require 'test/unit'
require_relative '../lib/arabic_utils'

class TestRemoveArabicDiacritics < Test::Unit::TestCase

  def test_remove_basic_diacritics
    # Test basic diacritical marks removal
    input = "بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ"
    expected = "بسم الله رحمان رحيم"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove basic diacritics from Bismillah")
  end

  def test_remove_fathatan
    input = "مَنْ"
    expected = "من"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove fathatan (ً)")
  end

  def test_remove_dammatan
    input = "مٌنْ"
    expected = "من"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove dammatan (ٌ)")
  end

  def test_remove_kasratan
    input = "مٍنْ"
    expected = "من"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove kasratan (ٍ)")
  end

  def test_remove_fatha
    input = "بَبْ"
    expected = "بب"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove fatha (َ)")
  end

  def test_remove_damma
    input = "بُبْ"
    expected = "بب"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove damma (ُ)")
  end

  def test_remove_kasra
    input = "بِبْ"
    expected = "بب"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove kasra (ِ)")
  end

  def test_remove_shadda
    input = "مُتَّعَلِّمْ"
    expected = "متعلم"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove shadda (ّ)")
  end

  def test_remove_sukun
    input = "مَنْ"
    expected = "من"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove sukun (ْ)")
  end

  def test_remove_tatweel
    input = "مـــدِينَةْ"
    expected = "مدينة"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove tatweel/kashida (ـ)")
  end

  def test_remove_superscript_alef
    input = "لِلّٰهِ"
    expected = "لله"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove superscript alef (ٰ)")
  end

  def test_remove_multiple_diacritics
    input = "بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ"
    expected = "بسم الله رحمان رحيم"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should handle multiple diacritics in complex text")
  end

  def test_preserve_arabic_characters
    input = "مرحبا"
    expected = "مرحبا"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should preserve Arabic characters without diacritics")
  end

  def test_empty_string
    input = ""
    expected = ""
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should handle empty string")
  end

  def test_no_diacritics
    input = "الله"
    expected = "الله"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should not modify text without diacritics")
  end

  def test_mixed_text_with_diacritics
    input = "السَّلامُ عَلَيْكُمْ"
    expected = "سلام عليكم"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should handle mixed text with spaces and diacritics")
  end

  def test_quranic_verse_example
    input = "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ"
    expected = "حمد لله رب عالمين"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should handle Quranic verse with various diacritics")
  end

  def test_complex_quranic_text
    input = "وَٱللَّهُ خَلَقَ كُلَّ دَابَّةٍ مِّن مَّاءٍ ۖ فَمِنْهُم مَّن يَمْشِي عَلَىٰ بَطْنِهِۦ وَمِنْهُم مَّن يَمْشِي عَلَىٰ رِجْلَيْنِ وَمِنْهُم مَّن يَمْشِي عَلَىٰ أَرْبَعٍ ۚ يَخْلُقُ ٱللَّهُ مَا يَشَاءُ ۚ إِنَّ ٱللَّهَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ"
    expected = "والله خلق كل دابة من ماء  فمنهم من يمشي على بطنه ومنهم من يمشي على رجلين ومنهم من يمشي على أربع  يخلق الله ما يشاء  إن الله على كل شيء قدير"
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should handle complex Quranic verse with extensive diacritics")
  end

  def test_only_diacritics
    input = "َُِّْٰـًٌٍ"
    expected = ""
    result = strip_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove all diacritics leaving empty string")
  end

  def test_unicode_ranges_covered
    # Test some characters from the unicode ranges in the method
    input = "ت\u0615\u0653"  # maddah above + maddah below (rare)
    result = strip_arabic_diacritics(input)
    assert_equal("ت", result, "Should handle characters from unicode ranges")
  end

  def test_combining_diacritics
    # Test combining diacritical marks (unicode ranges 0300-036F, etc.)
    input = "ت\u0301\u0302\u0303"  # Combining acute, circumflex, tilde
    result = strip_arabic_diacritics(input)
    assert_equal("ت", result, "Should remove combining diacritical marks")
  end

  def test_rahman_tatweel_superscript_alef
    # ـٰ (tatweel + superscript alef) should become ا to preserve the long vowel
    # ٱل (alef wasla + lam) → ال (normalized to standard alef + lam), then ال stripped from ≥5-letter words
    input = "ٱلرَّحۡمَـٰنِ"
    result = strip_arabic_diacritics(input)
    assert_equal("رحمان", result, "ٱلرَّحۡمَـٰنِ should become رحمان (ٱل normalized to ال then stripped, ـٰ → ا)")
  end

  def test_strip_al_prefix_long_word
    # ال prefix stripped from words ≥5 letters
    assert_equal("رحمان", strip_arabic_diacritics("الرَّحْمَـٰنِ"), "الرحمن → رحمان")
    assert_equal("رحيم", strip_arabic_diacritics("الرَّحِيمِ"), "الرحيم → رحيم")
    assert_equal("سلام", strip_arabic_diacritics("السَّلَامُ"), "السلام → سلام")
    # ٱل (alef wasla + lam without sukun) should also normalize and strip
    assert_equal("طین", strip_arabic_diacritics("ٱلطِّینِ"), "ٱلطِّینِ should become طین")
  end

  def test_preserve_al_prefix_short_word
    # ال prefix kept on words <5 letters (الله = 4 chars)
    assert_equal("الله", strip_arabic_diacritics("الله"), "الله should be preserved (4 letters)")
  end

  def test_tanwin_alef_yaqeena
    # ۢا (small high noon + alef) is Uthmani tanwin marker, not a root letter
    input = "یَقِینَۢا"
    result = strip_arabic_diacritics(input)
    assert_equal("یقین", result, "یَقِینَۢا should become یقین")
  end

  def test_tanwin_alef_naseeba
    # ࣰا (open fathatan U+08F0 + alef) is Extended Arabic tanwin marker, not a root letter
    # ࣱ (open dammatan U+08F1) is stripped with no trailing alef
    assert_equal("نصیب", strip_arabic_diacritics("نَصِیبࣰا"), "نَصِیبࣰا should become نصیب")
    assert_equal("نصیب", strip_arabic_diacritics("نَصِیبࣱ"),  "نَصِیبࣱ should become نصیب")
  end

  def test_uthmani_alef_lam_sukun
    # ٱلۡ (alef wasla + lam + Quranic sukun) is the Uthmani definite article → strip from words ≥5 letters
    assert_equal("مجیبون", strip_arabic_diacritics("ٱلۡمُجِیبُونَ"), "ٱلۡمُجِیبُونَ should become مجیبون")
    assert_equal("حمد", strip_arabic_diacritics("ٱلْحَمْدُ"), "ٱلْحَمْدُ should become حمد")
    assert_equal("عالمين", strip_arabic_diacritics("ٱلْعَـٰلَمِينَ"), "ٱلْعَـٰلَمِينَ should become عالمين")
    assert_equal("باب", strip_arabic_diacritics("ٱلۡبَابِۚ"), "ٱلۡبَابِۚ should become باب")
    assert_equal("اطعام", strip_arabic_diacritics("فَإِطۡعَامُ"), "فَإِطۡعَامُ should become فإطعام (no ال prefix)")
    assert_equal("سراج", strip_arabic_diacritics("سِرَ ٰ⁠جࣰا"), "سِرَ ٰ⁠جࣰا should become سراج")
    assert_equal("واحد", strip_arabic_diacritics("وَ ٰ⁠حِدࣲ"), "وَ ٰ⁠حِدࣲ should become وحِد")
  end

  # --- remove_arabic_diacritics: prefixes and postfixes stripped, root found from the weight (وزن) ---

  def test_prefix_is_stripped_before_finding_the_root
    assert_equal("حكم", remove_arabic_diacritics("بِأَحۡكَمِ"), "بِ + أَفْعَل → حكم")
    assert_equal("أحكم", remove_arabic_diacritics("بِأَحۡكَمِ", root: false), "root: false drops the prefix but keeps the weight")
    assert_equal("لیس أله حكم حكم", remove_arabic_diacritics("أَلَیۡسَ ٱللَّهُ بِأَحۡكَمِ ٱلۡحَـٰكِمِینَ"))
    assert_equal("لیس الله أحكم حاكم", remove_arabic_diacritics("أَلَیۡسَ ٱللَّهُ بِأَحۡكَمِ ٱلۡحَـٰكِمِینَ", root: false))
    assert_equal("حمد أله ربب علم", remove_arabic_diacritics("ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَـٰلَمِینَ"))
  end

  def test_prefixes
    {
      "بِمَا" => "ما",              # بِ + ما
      "كَمَا" => "ما",              # كَ + ما
      "لِمَ" => "ما",               # لِ + ما shortened
      "لِلَّهِ" => "أله",            # لِ + the divine name
      "تَٱللَّهِ" => "أله",          # oath تَ
      "وَلَقَدۡ" => "قد",            # وَ + emphatic لَ + قد
      "لِلنَّاسِ" => "أنس",          # لِ + article + ناس
      "وَٱلَّیۡلِ" => "لیل",         # the article merged into a lam-initial stem
      "فَلۡیَتَوَكَّلِ" => "وكل",     # فَ + lam of command + imperfect
      "سَیَقُولُ" => "قول",          # future سَ
      "وَیَـٰقَوۡمِ" => "قوم",        # وَ + vocative یَـٰ
      "ءَأَنذَرۡتَهُمۡ" => "نذر",      # interrogative ءَ
      "وَبِٱلۡـَٔاخِرَةِ" => "أخر"    # وَ + بِ + ال
    }.each { |word, root| assert_equal(root, remove_arabic_diacritics(word), word) }
    assert_equal("لم", remove_arabic_diacritics("لَمۡ"), "لَمۡ is a particle, not لِ + م")
  end

  def test_postfixes
    {
      "رَزَقۡنَـٰهُمۡ" => "رزق",      # نا + هم
      "كَفَرُوا۟" => "كفر",          # وا (the silent alef is never a radical)
      "ٱلۡمُفۡلِحُونَ" => "فلح",      # ون
      "جَاۤءَكَ" => "جیأ",           # كَ after a hollow verb
      "قَالَتِ" => "قول",            # feminine تِ
      "لَیَقُولُنَّ" => "قول",        # emphatic لَ + energetic نّ
      "كُنَّا" => "كون",             # نا merged into the stem by shadda
      "یَدَیۡهِ" => "یدی",           # dual + pronoun
      "صَلَاتِهِمۡ" => "صلو",        # ة written ت before a pronoun
      "مِنۡهَا" => "من",             # particle + pronoun
      "إِنَّا" => "إن",
      "عَلَیۡهِمۡ" => "على"
    }.each { |word, root| assert_equal(root, remove_arabic_diacritics(word), word) }
  end

  def test_stems_without_prefixes_and_postfixes
    {
      "ٱلۡحَـٰكِمِینَ" => "حاكم", "بِـَٔایَـٰتِنَا" => "آیة", "ٱلۡمُؤۡمِنَـٰتِ" => "مؤمنة", "صَلَاتِهِمۡ" => "صلاة",
      "وَبِٱلۡـَٔاخِرَةِ" => "آخرة", "سَیَقُولُ" => "یقول", "لَهُمۡ" => "هم", "وَٱللَّهُ" => "الله"
    }.each { |word, stem| assert_equal(stem, arabic_word_stem(word), word) }
  end

  def test_vowels_decide_between_readings
    assert_equal("أهل", remove_arabic_diacritics("أَهۡلِ"), "not the interrogative أَ + هَلۡ: هَلۡ has a fatha on ه")
    assert_equal("لیس", remove_arabic_diacritics("لَیۡسَ"), "ی with sukun is a diphthong, not the long vowel of a hollow weight")
    assert_equal("یسر", remove_arabic_diacritics("یَسِیرࣱ"), "tanwin marks a noun (فَعِیل), never an imperfect verb")
    assert_equal("ربب", remove_arabic_diacritics("رَبَّكَ"), "a doubled letter before a pronoun is a geminate root")
  end

  def test_roots_of_weights
    {
      "ٱلۡكِتَـٰبُ" => "كتب", "ٱلۡمَغۡضُوبِ" => "غضب", "نَعۡبُدُ" => "عبد", "أَنۡعَمۡتَ" => "نعم",
      "ٱلۡمُسۡتَقِیمَ" => "قوم", "یَقُولُ" => "قول", "وَكَانَ" => "كون", "ٱلضَّاۤلِّینَ" => "ضلل", "یُحِبُّ" => "حبب",
      "ٱلصَّلَوٰةَ" => "صلو", "لِّلۡمُتَّقِینَ" => "وقی", "یَهۡتَدُونَ" => "هدی", "ءَامَنُوا۟" => "أمن",
      "إِیمَـٰنࣰا" => "أمن", "تَوَلَّوۡا۟" => "ولی", "یَذَّكَّرُونَ" => "ذكر", "ٱتَّبِعُوا۟" => "تبع"
    }.each { |word, root| assert_equal(root, arabic_word_root(word), word) }
  end

  def test_particles_and_special_words
    assert_equal("على", remove_arabic_diacritics("عَلَىٰ"), "particles have no root")
    assert_equal("الذین", remove_arabic_diacritics("وَٱلَّذِینَ"))
    assert_equal("الم", remove_arabic_diacritics("الۤمۤ"), "disjointed letters are kept")
    assert_equal("أنس", remove_arabic_diacritics("ٱلنَّاسِ"), "irregular ناس")
    assert_equal("", remove_arabic_diacritics(""))
  end

  def test_analyze_arabic_word_reports_prefixes_stem_and_postfix
    analysis = analyze_arabic_word("بِـَٔایَـٰتِنَا")
    assert_equal(%w[ب], analysis[:proclitics])
    assert_equal("اتنا", analysis[:suffix])
    assert_equal("آیة", analysis[:stem])
    assert_equal("أیی", analysis[:root])
  end

  def test_fathatan_alef_naseera
    # Standard fathatan (ً U+064B) + alef is a tanwin marker, not a root letter
    input = "نَصِیرًا"
    result = strip_arabic_diacritics(input)
    assert_equal("نصیر", result, "نَصِیرًا should become نصیر")
  end

end
