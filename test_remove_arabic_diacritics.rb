#!/usr/bin/env ruby
# Test suite for remove_arabic_diacritics method
# Run with: ruby test_remove_arabic_diacritics.rb

require 'test/unit'
require_relative 'lib/arabic_utils'

class TestRemoveArabicDiacritics < Test::Unit::TestCase

  def test_remove_basic_diacritics
    # Test basic diacritical marks removal
    input = "بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ"
    expected = "بسم الله رحمان رحيم"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove basic diacritics from Bismillah")
  end

  def test_remove_fathatan
    input = "مَنْ"
    expected = "من"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove fathatan (ً)")
  end

  def test_remove_dammatan
    input = "مٌنْ"
    expected = "من"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove dammatan (ٌ)")
  end

  def test_remove_kasratan
    input = "مٍنْ"
    expected = "من"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove kasratan (ٍ)")
  end

  def test_remove_fatha
    input = "بَبْ"
    expected = "بب"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove fatha (َ)")
  end

  def test_remove_damma
    input = "بُبْ"
    expected = "بب"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove damma (ُ)")
  end

  def test_remove_kasra
    input = "بِبْ"
    expected = "بب"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove kasra (ِ)")
  end

  def test_remove_shadda
    input = "مُتَّعَلِّمْ"
    expected = "متعلم"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove shadda (ّ)")
  end

  def test_remove_sukun
    input = "مَنْ"
    expected = "من"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove sukun (ْ)")
  end

  def test_remove_tatweel
    input = "مـــدِينَةْ"
    expected = "مدينة"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove tatweel/kashida (ـ)")
  end

  def test_remove_superscript_alef
    input = "لِلّٰهِ"
    expected = "لله"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove superscript alef (ٰ)")
  end

  def test_remove_multiple_diacritics
    input = "بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ"
    expected = "بسم الله رحمان رحيم"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should handle multiple diacritics in complex text")
  end

  def test_preserve_arabic_characters
    input = "مرحبا"
    expected = "مرحبا"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should preserve Arabic characters without diacritics")
  end

  def test_empty_string
    input = ""
    expected = ""
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should handle empty string")
  end

  def test_no_diacritics
    input = "الله"
    expected = "الله"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should not modify text without diacritics")
  end

  def test_mixed_text_with_diacritics
    input = "السَّلامُ عَلَيْكُمْ"
    expected = "سلام عليكم"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should handle mixed text with spaces and diacritics")
  end

  def test_quranic_verse_example
    input = "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ"
    expected = "حمد لله رب عالمين"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should handle Quranic verse with various diacritics")
  end

  def test_complex_quranic_text
    input = "وَٱللَّهُ خَلَقَ كُلَّ دَابَّةٍ مِّن مَّاءٍ ۖ فَمِنْهُم مَّن يَمْشِي عَلَىٰ بَطْنِهِۦ وَمِنْهُم مَّن يَمْشِي عَلَىٰ رِجْلَيْنِ وَمِنْهُم مَّن يَمْشِي عَلَىٰ أَرْبَعٍ ۚ يَخْلُقُ ٱللَّهُ مَا يَشَاءُ ۚ إِنَّ ٱللَّهَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ"
    expected = "والله خلق كل دابة من ماء  فمنهم من يمشي على بطنه ومنهم من يمشي على رجلين ومنهم من يمشي على أربع  يخلق الله ما يشاء  إن الله على كل شيء قدير"
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should handle complex Quranic verse with extensive diacritics")
  end

  def test_only_diacritics
    input = "َُِّْٰـًٌٍ"
    expected = ""
    result = remove_arabic_diacritics(input)
    assert_equal(expected, result, "Should remove all diacritics leaving empty string")
  end

  def test_unicode_ranges_covered
    # Test some characters from the unicode ranges in the method
    input = "ت\u0615\u0653"  # maddah above + maddah below (rare)
    result = remove_arabic_diacritics(input)
    assert_equal("ت", result, "Should handle characters from unicode ranges")
  end

  def test_combining_diacritics
    # Test combining diacritical marks (unicode ranges 0300-036F, etc.)
    input = "ت\u0301\u0302\u0303"  # Combining acute, circumflex, tilde
    result = remove_arabic_diacritics(input)
    assert_equal("ت", result, "Should remove combining diacritical marks")
  end

  def test_rahman_tatweel_superscript_alef
    # ـٰ (tatweel + superscript alef) should become ا to preserve the long vowel
    # ٱل (alef wasla + lam) → ال (normalized to standard alef + lam), then ال stripped from ≥5-letter words
    input = "ٱلرَّحۡمَـٰنِ"
    result = remove_arabic_diacritics(input)
    assert_equal("رحمان", result, "ٱلرَّحۡمَـٰنِ should become رحمان (ٱل normalized to ال then stripped, ـٰ → ا)")
  end

  def test_strip_al_prefix_long_word
    # ال prefix stripped from words ≥5 letters
    assert_equal("رحمان", remove_arabic_diacritics("الرَّحْمَـٰنِ"), "الرحمن → رحمان")
    assert_equal("رحيم", remove_arabic_diacritics("الرَّحِيمِ"), "الرحيم → رحيم")
    assert_equal("سلام", remove_arabic_diacritics("السَّلَامُ"), "السلام → سلام")
    # ٱل (alef wasla + lam without sukun) should also normalize and strip
    assert_equal("طین", remove_arabic_diacritics("ٱلطِّینِ"), "ٱلطِّینِ should become طین")
  end

  def test_preserve_al_prefix_short_word
    # ال prefix kept on words <5 letters (الله = 4 chars)
    assert_equal("الله", remove_arabic_diacritics("الله"), "الله should be preserved (4 letters)")
  end

  def test_tanwin_alef_yaqeena
    # ۢا (small high noon + alef) is Uthmani tanwin marker, not a root letter
    input = "یَقِینَۢا"
    result = remove_arabic_diacritics(input)
    assert_equal("یقین", result, "یَقِینَۢا should become یقین")
  end

  def test_tanwin_alef_naseeba
    # ࣰا (open fathatan U+08F0 + alef) is Extended Arabic tanwin marker, not a root letter
    # ࣱ (open dammatan U+08F1) is stripped with no trailing alef
    assert_equal("نصیب", remove_arabic_diacritics("نَصِیبࣰا"), "نَصِیبࣰا should become نصیب")
    assert_equal("نصیب", remove_arabic_diacritics("نَصِیبࣱ"),  "نَصِیبࣱ should become نصیب")
  end

  def test_uthmani_alef_lam_sukun
    # ٱلۡ (alef wasla + lam + Quranic sukun) is the Uthmani definite article → strip from words ≥5 letters
    assert_equal("مجیبون", remove_arabic_diacritics("ٱلۡمُجِیبُونَ"), "ٱلۡمُجِیبُونَ should become مجیبون")
    assert_equal("حمد", remove_arabic_diacritics("ٱلْحَمْدُ"), "ٱلْحَمْدُ should become حمد")
    assert_equal("عالمين", remove_arabic_diacritics("ٱلْعَـٰلَمِينَ"), "ٱلْعَـٰلَمِينَ should become عالمين")
    assert_equal("باب", remove_arabic_diacritics("ٱلۡبَابِۚ"), "ٱلۡبَابِۚ should become باب")
  end

  def test_fathatan_alef_naseera
    # Standard fathatan (ً U+064B) + alef is a tanwin marker, not a root letter
    input = "نَصِیرًا"
    result = remove_arabic_diacritics(input)
    assert_equal("نصیر", result, "نَصِیرًا should become نصیر")
  end

end
