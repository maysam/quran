#!/usr/bin/env ruby
# Arabic text processing utilities

# Reduce Arabic text to the roots (جذر) of its words.
#
# An Arabic word is a root (usually three radicals) poured into a weight (وزن) such as فَاعِل,
# مَفْعُول or اِسْتَفْعَلَ, with prefixes in front (وَ فَ بِ لِ كَ سَ ال …) and postfixes behind
# (pronouns, plural/dual and verb endings). The vowels of the Uthmani text show which letters are
# prefixes, which belong to the weight and which are radicals, so every word is analysed with its
# vowels before they are dropped (see analyze_arabic_word).
#
#   remove_arabic_diacritics("بِأَحۡكَمِ ٱلۡحَـٰكِمِینَ")              # => "حكم حكم"
#   remove_arabic_diacritics("بِأَحۡكَمِ ٱلۡحَـٰكِمِینَ", root: false) # => "أحكم حاكم"
#
# With root: false only the prefixes and postfixes are stripped and the weight is kept.
# Particles and pronouns have no root; they come back without their prefixes (وَبِمَا → ما).
def remove_arabic_diacritics(text, root: true)
  text
    .gsub(/[\u0020\u200A]\u0670/, "\u0640\u0670") # a superscript alef split off by a space still belongs to its word
    .split(/\s+/)
    .map { |word| root ? arabic_word_root(word) : arabic_word_stem(word) }
    .reject(&:empty?)
    .join(' ')
end

# Remove only the diacritics, keeping every letter of the text (no prefix, postfix or root analysis)
def strip_arabic_diacritics(text)
  # Main Arabic diacritics (tashkeel) + tatweel + superscript alef
  # Comprehensive Arabic diacritics collection
  text
    .gsub(/[\u06E2\u08F0-\u08F2]\u0627/, '')                              # Uthmani tanwin marks + alef → remove (e.g. یقینَۢا → یقین, نصیبࣰا → نصیب)
    .gsub(/\u064B\u0627/, '')                                             # fathatan + alef → remove (standard tanwin, e.g. نصیرًا → نصیر)
    .gsub(/\u0671\u0644/, "\u0627\u0644")                                 # alef wasla + lam → ال (normalize ٱل to standard ال, covers both sukun and non-sukun variants)
    .gsub(/\u0640\u0670/, "\u0627")                                       # tatweel + superscript alef → long alef (e.g. رحمـٰن → رحمان)
    .gsub(/[\u0020\u200A]\u0670/, "\u0627")                               # space/hair-space + superscript alef → long alef (e.g. سِرَ ٰج → سراج)
    .gsub(/\u2060/, '')                                                   # word joiner (U+2060) → remove
    .gsub(/[\u0610-\u061A\u064B-\u065F\u0670\u0671\u06D6-\u06ED\u08D3-\u08FF]/, '') # Arabic diacritics, Quranic marks, alef wasla, Extended Arabic
    .gsub(/\u0640/, '')                                                   # tatweel (kashida)
    .gsub(/[\u0300-\u036F\u1AB0-\u1AFF\u1DC0-\u1DFF\u20D0-\u20FF\uFE20-\uFE2F]/, '') # combining diacritics
    .gsub(/(^|\s)ال(\S{3,})/) { "#{$1}#{$2}" }                          # strip definite article ال from words ≥5 letters
    .gsub(/(^|\s)فإ(\S{3,})/) { "#{$1}ا#{$2}" }                          # strip definite article ال from words ≥5 letters
end

# Root of a single vowelized word: بِأَحۡكَمِ → حكم
def arabic_word_root(word)
  analyze_arabic_word(word)[:root]
end

# A single vowelized word without its prefixes and postfixes: بِأَحۡكَمِ → أحكم, ٱلۡحَـٰكِمِینَ → حاكم
def arabic_word_stem(word)
  analyze_arabic_word(word)[:stem]
end

# ---------------------------------------------------------------------------
# Word analysis: prefixes + stem (a weight holding the root's radicals) + postfix
# ---------------------------------------------------------------------------

# A letter of a parsed word: its vowel (:fatha, :damma, :kasra, :sukun or nil), whether it carries
# shadda, whether it is silent (small zero ۟), and whether it is the synthetic first half of a
# doubled (shadda) letter
ArabicLetterUnit = Struct.new(:letter, :vowel, :shadda, :silent, :from_shadda)

ARABIC_VOWEL_MARKS = {
  "\u064E" => :fatha, "\u064F" => :damma, "\u0650" => :kasra,
  "\u0652" => :sukun, "\u06E1" => :sukun # Quranic sukun ۡ
}.freeze
ARABIC_SHADDA = "\u0651"
ARABIC_SILENT_MARKS = ["\u06DF", "\u06E0"].freeze  # small high zeros: letter is written but not pronounced
ARABIC_COMBINING_HAMZA = ["\u0654", "\u0655"].freeze
ARABIC_SUPERSCRIPT_ALEF = "\u0670"
ARABIC_DISJOINTED_LETTER_MADDA = "\u06E4"        # the madda over disjointed letters (الۤمۤ)
ARABIC_ALEF_MAQSURA = "\u0649"
ARABIC_HAMZA_FORMS = %w[ء أ إ ؤ ئ].freeze
ARABIC_WEAK_LETTERS = (%w[ا و ی] + [ARABIC_ALEF_MAQSURA]).freeze
ARABIC_LONG_VOWEL_LETTERS = { fatha: ['ا', ARABIC_ALEF_MAQSURA], kasra: %w[ی], damma: %w[و] }.freeze
ARABIC_ROOT_HAMZA = 'أ' # roots are written with أ for any hamza radical (أمن, سأل, بدأ)
ARABIC_ROOT_YA = 'ی'    # the corpus writes ya as Persian ی; keep roots consistent with it

# --- particles, pronouns and words no weight can explain --------------------

# Particles, pronouns and demonstratives have no root. They are matched letter by letter with their
# shadda (and their vowels, where an entry gives them); "spelling=canonical" maps an Uthmani spelling
# to the form returned for it.
ARABIC_PARTICLE_ENTRIES = %w[
  من فِی عَن مَع لَدُن مَا لَا لَم لَن لَمّا لَو لَولا لَوما إِلّا أَلّا أَمَا
  إِن إِنّ أَن أَنّ إِنّما أَنّما كَأَنّ كَأَن كَأَنّما لَكِن لَكِنّ لَاكِن=لكن لَاكِنّ=لكنّ لَعَلّ لَیت
  أَو أَم إِمّا أَمّا ثُمّ ثَمّ قَد هَل بَل إِذ إِذَا كَی كَیلا ءِن=إن ءِنّ=إنّ م=ما كَم كَلّا كَأَیّن یَا ممّا ممّن عَمّا فِیما كُلّما أَینما حَیثما مَاذا أَین أَیّان
  الّذی الّتی الّذین الّذان الّتان الّاتی=اللاتی الّاءی=اللائی
  هاذا=هذا هاذه=هذه هاذان=هذان هاذین=هذین هاؤلاء=هؤلاء ذالك=ذلك ذالكم=ذلكم ذالكما=ذلكما تلك تلكم تلكما
  ألاءك=أولئك ألاء=أولاء ألوا=أولو ألی=أولی ألات=أولات ذا ذو ذی ذات ذوا
  هو هی هم هما هنّ أنا نحن أنت أنتم أنتما أنتنّ
].freeze
# particles ending in alef maqsura, kept apart from ی (أَنَّىٰ is not إِنِّی)
ARABIC_ALEF_MAQSURA_PARTICLE_STARTS = %w[عل إل حتّ لد مت أنّ بل].freeze
# Particles that take attached pronouns (عَلَیۡهِمۡ, إِلَیۡكَ, إِنَّهُۥ), matched without shadda
ARABIC_PRONOUN_BEARING_PARTICLES = {
  'علی' => 'على', 'إلی' => 'إلى', 'لدی' => 'لدى', 'فی' => 'فی', 'من' => 'من', 'عن' => 'عن', 'مع' => 'مع',
  'إن' => 'إن', 'ءن' => 'إن', 'أن' => 'أن', 'لكن' => 'لكن', 'لاكن' => 'لكن', 'لعل' => 'لعلّ', 'إیا' => 'إیّا',
  'لدن' => 'لدن', 'كأن' => 'كأنّ', 'لیت' => 'لیت'
}.freeze
# A preposition prefix on a bare attached pronoun (لَهُۥ, بِهِمۡ, لَكُمۡ): the stem is the pronoun
ARABIC_ATTACHED_PRONOUNS = {
  'ه' => 'هو', 'ها' => 'هی', 'هم' => 'هم', 'هما' => 'هما', 'هن' => 'هنّ', 'ك' => 'أنت', 'كم' => 'أنتم',
  'كما' => 'أنتما', 'كن' => 'أنتنّ', 'ی' => 'أنا', 'نا' => 'نحن'
}.freeze
# Words whose root no weight can reveal (letters dropped beyond the regular weak-letter rules),
# matched letter by letter with their shadda (and vowels, where given) before any postfix
ARABIC_IRREGULAR_ROOTS = {
  'ناس' => 'أنس', 'ماء' => 'موه', 'نساء' => 'نسو', 'مدینة' => 'مدن', 'أیها' => 'أیی', 'أیتها' => 'أیی', 'ءالاء' => 'ألو',
  'یَد' => 'یدی', 'یَدَا' => 'یدی', 'یَدَی' => 'یدی', 'أَیۡدِی' => 'یدی', 'كُل' => 'أكل', 'خُذ' => 'أخذ', 'أوت' => 'أتی', 'أوتی' => 'أتی',
  'تر' => 'رأی', 'یر' => 'رأی', 'نر' => 'رأی', 'أر' => 'رأی', 'تری' => 'رأی', 'یری' => 'رأی', 'نری' => 'رأی', 'أری' => 'رأی',
  'رءی' => 'رأی', 'رءا' => 'رأی', 'بِءسما' => 'بأس', 'یَك' => 'كون', 'تَك' => 'كون', 'نَك' => 'كون', 'أَك' => 'كون',
  'بَن' => 'بنی', 'ابن' => 'بنی', 'ذَرۡ' => 'وذر', 'أَبَت' => 'أبو', 'نَبِیّ' => 'نبأ', 'أنبیاء' => 'نبأ', 'أَیَّام' => 'یوم',
  'اثن' => 'ثنی', 'سَنَة' => 'سنو', 'هَبۡ' => 'وهب', 'ٱمۡرِئ' => 'مرأ'
}.freeze

# --- weights ------------------------------------------------------------------

# Weight templates (أوزان): ف ع ل are radicals 1-3 and a second literal ل is radical 4.
# Vowels are optional per letter; where both the weight and the word carry one they must agree.
# The final letter is left unvowelled because its vowel is the grammatical case ending.
ARABIC_IMPERFECT_PREFIXES = %w[ی ت ن أ].freeze
ARABIC_WEIGHT_TEMPLATES = [
  # bare Form I (active and passive) and the derived verb forms in the perfect
  'فعل', 'فَعَل', 'فُعِل', 'فَعْل', 'فِعْل', 'فُعْل', 'فَعَّل', 'فُعِّل', 'فَعِّل', 'فَاعَل', 'أَفْعَل', 'تَفَعَّل', 'تَفَاعَل',
  'اِنْفَعَل', 'اِفْتَعَل', 'اِسْتَفْعَل', 'اِفْعَلّ',
  # Form V/VI with the ت assimilated into the first radical (ٱطَّهَّرُوا, ٱدَّارَكُوا)
  'اِفَّعَّل', 'اِفَّاعَل', 'مُفَّعِّل', 'مُفَّعَّل',
  # participles
  'فَاعِل', 'مَفْعُول', 'مُفَعِّل', 'مُفَعَّل', 'مُفَاعِل', 'مُفَاعَل', 'مُفْعِل', 'مُفْعَل', 'مُتَفَعِّل', 'مُتَفَعَّل',
  'مُتَفَاعِل', 'مُنْفَعِل', 'مُفْتَعِل', 'مُفْتَعَل', 'مُسْتَفْعِل', 'مُسْتَفْعَل',
  # verbal nouns, broken plurals and common noun weights
  'فِعَال', 'فَعَال', 'فُعَال', 'فُعُول', 'فَعُول', 'فَعِیل', 'فُعَیْل', 'فَعْلَان', 'فُعْلَان', 'فِعْلَان', 'فَعْلَى', 'فُعْلَى',
  'أَفْعَال', 'أَفْعِلَة', 'أَفْعُل', 'فَوَاعِل', 'فَعَائِل', 'مَفَاعِل', 'مَفَاعِیل', 'تَفْعِیل', 'تَفْعِلَة', 'مَفْعِل', 'مَفْعَل',
  'مِفْعَال', 'مِفْعَل', 'إِفْعَال', 'اِفْتِعَال', 'اِسْتِفْعَال', 'اِنْفِعَال', 'تَفَعُّل', 'تَفَاعُل', 'فُعَلَاء', 'أَفْعِلَاء',
  'فُعَّال', 'فَعَّال', 'فِعِّیل', 'فَعْلَاء', 'فَیْعَال', 'فِعْلَى', 'أَفَاعِیل', 'أَفَاعِل', 'تَفَاعِیل', 'فَیَاعِیل', 'فُعَّل', 'فَعَالَى', 'فُعَالَى', 'فُعِّیل', 'اُسْتُفْعِل', 'فِعَل', 'فُعُل', 'فُعَل', 'فَعِل', 'فَعُل', 'فَیْعِل', 'فَیْعَل'
].freeze
ARABIC_QUADRILITERAL_WEIGHT_TEMPLATES = ['فَعْلَل', 'مُفَعْلِل', 'فِعْلَال', 'فَعْلَال', 'تَفَعْلَل'].freeze
# imperatives: only when the word ends in sukun (ٱعۡبُدۡ) or carries an ending (ٱعۡبُدُوا۟)
ARABIC_IMPERATIVE_WEIGHT_TEMPLATES = ['اُفْعُل', 'اِفْعِل', 'اِفْعَل', 'أَفْعِل', 'اِفْتَعِل', 'اِسْتَفْعِل', 'اِنْفَعِل'].freeze
# imperfect verbs: each prefix ی/ت/ن/أ combined with the Form I-X stems
ARABIC_IMPERFECT_WEIGHT_TEMPLATES = ARABIC_IMPERFECT_PREFIXES.flat_map do |imperfect_prefix|
  ['فْعل', 'فَعِّل', 'فَعَّل', 'فَاعِل', 'فَاعَل', 'تَفَعَّل', 'تَفَاعَل', 'نْفَعِل', 'فْتَعِل', 'فْتَعَل', 'سْتَفْعِل', 'سْتَفْعَل', 'فَعْلِل',
   'فَّعَّل', 'فَّاعَل'] # یَذَّكَّرُونَ: assimilated Form V/VI
    .map { |stem_template| imperfect_prefix + stem_template }
end.freeze

# Hollow weights: the middle radical surfaces as a long vowel (ا/و/ی), e.g. قَال, قِیل, یَقُول, یُقِیم, مُسْتَقِیم
ARABIC_HOLLOW_WEIGHT_TEMPLATES = [
  'فَعل', 'فِعل', 'فُعل', 'أَفَعل', 'مُفِعل', 'اِسْتَفَعل', 'مُسْتَفِعل', 'اِفْتَعل', 'مُفْتَعل', 'اِنْفَعل', 'إِفَعلَة',
  'اِسْتِفَعلَة', 'مَفَعل', 'مَفِعل', 'مَفُعل'
].freeze
ARABIC_HOLLOW_IMPERFECT_WEIGHT_TEMPLATES = ARABIC_IMPERFECT_PREFIXES.flat_map do |imperfect_prefix|
  ['فُعل', 'فِعل', 'فَعل', 'سْتَفِعل', 'سْتَفَعل', 'فْتَعل', 'نْفَعل'].map { |stem_template| imperfect_prefix + stem_template }
end.freeze

# Geminate weights: the 2nd and 3rd radicals are one doubled letter whose vowel moved forward,
# e.g. یُحِبُّ (حبب), أَشَدُّ (شدد), مُضِلّ (ضلل). Written like hollow weights, matched with ع = ل.
ARABIC_GEMINATE_WEIGHT_TEMPLATES = ['أَفَعل', 'مُفِعل', 'مُسْتَفِعل', 'اِفْتَعل', 'مُفْتَعل'].freeze
ARABIC_GEMINATE_IMPERFECT_WEIGHT_TEMPLATES = ARABIC_IMPERFECT_PREFIXES.flat_map do |imperfect_prefix|
  ['فُعل', 'فِعل', 'فَعل'].map { |stem_template| imperfect_prefix + stem_template }
end.freeze

# Weights that lost weak radicals entirely: [template, { missing radical index => implied letter }],
# e.g. قُلۡ (قول), یَكُنۡ (كون), ٱهۡدِ (هدی), یَدۡعُ (دعو), ٱتَّقُوا۟ / مُتَّقِینَ (وقی)
ARABIC_DEFECTIVE_WEIGHT_TEMPLATES = [
  ['فُل', { 1 => 'و' }], ['فِل', { 1 => 'ی' }], ['اِفْعِ', { 2 => 'ی' }], ['اُفْعُ', { 2 => 'و' }],
  ['اِفْتَع', { 2 => 'ی' }], ['مُفْتَع', { 2 => 'ی' }], ['اِسْتَفْع', { 2 => 'ی' }], ['مُسْتَفْع', { 2 => 'ی' }],
  ['اِتَّع', { 0 => 'و', 2 => 'ی' }], ['مُتَّع', { 0 => 'و', 2 => 'ی' }], ['اِتَّعَل', { 0 => 'و' }], ['مُتَّعِل', { 0 => 'و' }],
  ['أْعِ', { 0 => 'أ', 2 => 'ی' }], ['أْعُ', { 0 => 'أ', 2 => 'و' }] # imperatives after وَ/فَ that lost the wasla: فَأۡتُوا۟ (أتی)
].freeze
# Form IV perfect of hamza-initial roots (ءَامَنَ ← أمن, ءَاتَىٰ ← أتی): verbs only
ARABIC_HAMZA_INITIAL_FORM_IV_WEIGHT_TEMPLATES = [['ءَاعَل', { 0 => 'أ' }], ['ءَاع', { 0 => 'أ', 2 => 'ی' }]].freeze
# Perfect verbs whose final weak radical dropped before an ending (تَوَلَّوۡا۟, خَلَتۡ, نَسُوا۟, ٱتَّقَوۡا۟);
# only tried before one of ARABIC_DEFECTIVE_PERFECT_ENDINGS
ARABIC_DEFECTIVE_PERFECT_WEIGHT_TEMPLATES = [
  'فَعَ', 'فَعِ', 'فَعُ', 'فَعَّ', 'فَاعَ', 'أَفْعَ', 'تَفَعَّ', 'تَفَاعَ', 'اِفْتَعَ', 'اِسْتَفْعَ', 'اِنْفَعَ'
].map { |template| [template, { 2 => 'ی' }] }.push(['اِتَّعَ', { 0 => 'و', 2 => 'ی' }]).freeze
ARABIC_DEFECTIVE_IMPERFECT_WEIGHT_TEMPLATES = ARABIC_IMPERFECT_PREFIXES.flat_map do |imperfect_prefix|
  [[imperfect_prefix + 'فُل', { 1 => 'و' }], [imperfect_prefix + 'فِل', { 1 => 'ی' }], [imperfect_prefix + 'فَل', { 1 => 'و' }],
   [imperfect_prefix + 'فْعِ', { 2 => 'ی' }], [imperfect_prefix + 'فْعُ', { 2 => 'و' }], [imperfect_prefix + 'فْعَ', { 2 => 'ی' }],
   [imperfect_prefix + 'عِل', { 0 => 'و' }], [imperfect_prefix + 'عَل', { 0 => 'و' }], # یَعِدُ (وعد), یَضَعُ (وضع)
   [imperfect_prefix + 'فْتَع', { 2 => 'ی' }], [imperfect_prefix + 'سْتَفْع', { 2 => 'ی' }], [imperfect_prefix + 'فَعّ', { 2 => 'ی' }],
   [imperfect_prefix + 'تَّع', { 0 => 'و', 2 => 'ی' }], [imperfect_prefix + 'تَفَعَّ', { 2 => 'ی' }]] # یَتَوَلَّ
end.freeze

# Frequent Quranic roots, used like a stemmer's root dictionary to break ties between readings that
# fit equally well (وَكَانَ: و + كان rather than a وكن noun; جَاۤءَ: جیأ rather than جوأ)
ARABIC_COMMON_ROOTS = %w[
  أبد أبو أبی أتی أثر أثم أجر أجل أحد أخذ أخر أخو أدم أدی أذن أذی أرض أسر أسف أصل أفق أفك أكل ألف
  ألم أله ألو أمد أمر أمم أمن أمو أنث أنس أنف أهل أوب أول أین أیی بأس بتر بحث بحر بخل بدأ بدل بدو
  برأ برر برق برك بسط بشر بصر بطن بعث بعد بعض بغی بقر بقی بكر بكی بلد بلغ بلو بنو بنی بهت بوأ بور
  بیت بیع بین تبع ترب ترك تقی تلو تمم توب ثبت ثقل ثمر ثمن ثوب جبر جبل جدل جرم جری جزی جسد جعل جلد
  جلس جمع جمل جنب جند جنن جهد جهل جهنم جوع جیأ جیب حبب حبس حبط حجب حجج حجر حدث حذر حرب حرث حرج حرر
  حرص حرف حرق حرك حرم حزب حزن حسب حسد حسر حسن حشر حصد حصن حضر حطم حفظ حقق حكم حكی حلف حلل حلم حمل
  حمی حوت حور حوط حول حیق حین حیی خبث خبر ختم خدع خذل خرب خرج خزن خزی خسر خشع خشی خصم خطأ خطب خفف
  خفی خلد خلص خلط خلف خلق خلو خمر خوض خوف خون خیر دبر دخل درج درس درك دعو دفع دلل دمر دمو دنو دهر
  دور دون دین ذبح ذرأ ذرر ذری ذكر ذلل ذنب ذهب ذوق رأس رأف رأی ربب ربح ربص ربو رجز رجع رجل رجم رجو
  رحم ردد رزق رسخ رسل رسو رشد رضع رضی رعد رفع رقب رقی ركب ركع رمی رهب رهق روح رود روغ ریب زرع زعم
  زكو زلل زوج زید زین سأل سبح سبق سبل ستر سجد سجن سحب سحر سخر سرر سرع سرف سرق سطر سعد سعی سفر سفن
  سفه سقط سقی سكت سكن سلح سلط سلف سلك سلم سمع سمو سنن سنو سهل سوأ سود سور سوق سوی سیر شجر شدد شرب
  شرح شرع شرك شری شطن شعر شفع شفق شقق شقی شكر شكو شمس شهد شهر شهو شیأ شیب شیع صبح صبر صحب صخر صدد
  صدر صدق صدی صرف صعد صغر صفو صلح صلو صمم صنع صوب صور صوم صیر ضحك ضحی ضرب ضرر ضعف ضلل ضیف ضیق طبع
  طرف طعم طغی طفل طلب طلق طمع طهر طوع طوف طول طیب طیر ظلل ظلم ظنن ظهر عبث عبد عبر عتد عجب عجز عجل
  عدد عدل عدو عذب عذر عرب عرش عرض عرف عزز عزم عسر عشر عصم عصو عصی عطو عظم عفو عقب عقد عقل علق علم
  علن علو عمد عمر عمل عمی عنت عهد عود عوذ عون عیش عین غرب غرر غرق غشی غضب غفر غفل غلب غلظ غلل غلو
  غنم غنی غوی غیب غیر فتح فتن فتی فجر فحش فرح فرد فرض فرق فری فسد فسق فصل فضل فطر فعل فقد فقر فقه
  فكر فكه فلح فلك فوز فوق قبح قبر قبل قتل قدر قدم قرأ قرب قرض قرن قری قسط قسم قصد قصر قصص قضی قطع
  قعد قلب قلل قمر قنت قهر قوت قول قوم قوی كبر كتب كتم كثر كذب كرم كره كسب كشف كظم كفر كفف كفل كفی
  كلب كلل كلم كمل كنز كون كید لبث لبس لحق لحم لدن لزم لسن لطف لعب لعن لغو لفظ لقی لمس لهو لوم لیل
  متع مثل مجد مدد مدن مرأ مرج مرد مرر مرض مری مسح مسك مشی مصر مطر مكث مكر ملأ ملك منع منن منی مهد
  مهل موت موج نبأ نبت نجس نجم نجو نحل نذر نزع نزل نسخ نسو نسی نشأ نشر نصب نصح نصر نطق نظر نعم نفخ
  نفر نفس نفع نفق نقص نقم نكح نكر نهر نهی نوح نور نوم هبط هجر هدی هلك همم هود هون هوی وتر وثق وجب
  وجد وجه وحد وحی ودد ورث ورد وزر وسع وصف وصل وصی وضع وعد وعظ وفی وقت وقع وقی وكل ولد ولی وهب یأس
  یتم یدی یسر یقن یمن یوم
].to_h { |root| [root, true] }.freeze

# --- prefixes and postfixes ------------------------------------------------------

# Prefix layers in the order they attach, each prefix with the vowels it may carry (nil = any)
ARABIC_PROCLITIC_LAYERS = [
  [['أ', [:fatha]], ['ء', [:fatha]], ['ت', [:fatha]]],               # interrogative ءَ, oath تَ
  [['و', [:fatha]], ['ف', [:fatha]]],                               # conjunctions
  [['یا', nil]],                                                    # vocative یَـٰ (وَیَـٰقَوۡمِ)
  [['ب', [:kasra]], ['ل', [:kasra, :fatha, :sukun]], ['ك', [:fatha]], ['س', [:fatha]]], # prepositions, لَ, لۡ, future سَ
  [['ال', nil], ['ل', nil]]                                         # article (ل alone: the article after لِ, لِلنَّاسِ)
].freeze
# How readily each prefix is stripped once its vowel fits: conjunctions almost always are prefixes,
# while كَ and سَ begin many roots (كَتَبَ, سَمِعَ) and the interrogative أَ begins even more
ARABIC_PROCLITIC_SCORES = {
  'و' => 1, 'ف' => 1, 'یا' => 1, 'ب' => 0, 'ل' => 0, 'ال' => 0, 'ت' => 0, 'ك' => -1, 'س' => -1, 'أ' => -2, 'ء' => -2
}.freeze
ARABIC_PRONOUN_SUFFIXES = %w[ه ها هم هما هن ك كم كما كن نی نا ی].freeze
ARABIC_INFLECTION_SUFFIXES = %w[ون ین ان ات وا و ة ت تم تما تن تا ن ا نا ءذ].freeze # ءذ: یَوۡمَىِٕذ, حِینَىِٕذ
ARABIC_SUFFIX_CANDIDATES = (
  [''] + ARABIC_PRONOUN_SUFFIXES + ARABIC_INFLECTION_SUFFIXES +
  (ARABIC_INFLECTION_SUFFIXES + ['ی']).product(ARABIC_PRONOUN_SUFFIXES).map(&:join) + # ی: dual/plural construct, یَدَیۡهِ
  %w[تمو تموه تموها تموهم تموهن تمونا]
).uniq.freeze

# endings of perfect verbs before which a final weak radical drops: رَمَوۡا, خَلَتۡ (but رَمَیۡنَا keeps it)
ARABIC_DEFECTIVE_PERFECT_ENDINGS = %w[وا و ت تا].freeze

ARABIC_WORD_ANALYSIS_CACHE = {}

# --- parsing ----------------------------------------------------------------------

# Normalize a letter for comparison: Persian/Arabic ya, kaf, alef wasla
def normalize_arabic_letter(letter)
  case letter
  when 'ي', 'ی' then 'ی'
  when 'ک' then 'ك'
  when 'ٱ' then 'ا'
  else letter
  end
end

def arabic_hamza?(letter)
  ARABIC_HAMZA_FORMS.include?(letter)
end

# Split a vowelized word into letter units carrying vowel/shadda/silent flags
def parse_arabic_letter_units(word, keep_silent: false)
  letter_units = []
  prepared_word = word
    .gsub(/[\u06E2\u08F0-\u08F2]\u0627/, "\u064B")                       # Uthmani tanwin + alef → plain tanwin
    .gsub(/\u064B\u0627/, "\u064B")                                      # fathatan + alef → tanwin only
    .gsub(/[\u0020\u200A\u0640]\u0670/, "\u0627")                         # tatweel/space + superscript alef → long alef
    .gsub(/\u0622/, "\u0621\u0627")                                      # آ → hamza + alef
    .gsub(/\u0640([\u064B-\u0652]*)[\u0654\u0655]/) { "\u0621#{$1}" }   # tatweel + (vowel) + hamza → seatless hamza
  prepared_word.each_char do |character|
    last_unit = letter_units.last
    if ARABIC_VOWEL_MARKS.key?(character)
      last_unit.vowel = ARABIC_VOWEL_MARKS[character] if last_unit
    elsif character == ARABIC_SHADDA
      last_unit.shadda = true if last_unit
    elsif ARABIC_SILENT_MARKS.include?(character)
      last_unit.silent = true if last_unit
    elsif ARABIC_COMBINING_HAMZA.include?(character)
      # combining hamza turns its carrier (ى/و/ا) into hamza, otherwise it is a hamza of its own
      if last_unit && (%w[ی و ا] + [ARABIC_ALEF_MAQSURA]).include?(last_unit.letter)
        last_unit.letter = 'ء'
      else
        letter_units << ArabicLetterUnit.new('ء')
      end
    elsif character == ARABIC_SUPERSCRIPT_ALEF
      next if last_unit.nil? || ['ا', ARABIC_ALEF_MAQSURA].include?(last_unit.letter) # on alef maqsura it only marks the long a
      if last_unit.letter == 'و' && last_unit.vowel.nil?
        last_unit.letter = 'ا' # Uthmani وٰ is an alef written as waw (ٱلصَّلَوٰةَ, ٱلزَّكَوٰةَ)
      else
        letter_units << ArabicLetterUnit.new('ا')
      end
    elsif character.match?(/[\u0621-\u063A\u0641-\u064A\u0671\u06A9\u06CC]/)
      letter_units << ArabicLetterUnit.new(normalize_arabic_letter(character))
    end
    # everything else (tatweel, pause marks, small waw/ya, word joiner) is ignored
  end
  return letter_units if keep_silent

  # drop silent letters, except the plural alef after a final waw (keeps the وا suffix recognisable)
  letter_units.each_with_index.reject do |letter_unit, unit_index|
    letter_unit.silent && !(letter_unit.letter == 'ا' && unit_index == letter_units.length - 1)
  end.map(&:first)
end

def arabic_units_text(letter_units)
  letter_units.map(&:letter).join
end

# Expand shadda into two units (sukun + vowel); shadda on the first unit is assimilation, not doubling
def expand_arabic_shadda(letter_units)
  letter_units.each_with_index.flat_map do |letter_unit, unit_index|
    if letter_unit.shadda && unit_index > 0
      [ArabicLetterUnit.new(letter_unit.letter, :sukun, false, letter_unit.silent, true),
       ArabicLetterUnit.new(letter_unit.letter, letter_unit.vowel, false, letter_unit.silent)]
    else
      [ArabicLetterUnit.new(letter_unit.letter, letter_unit.vowel, false, letter_unit.silent)]
    end
  end
end

# Letters with their shadda (a shadda on the first letter only marks assimilation with the previous
# word). Hamza seats and alef maqsura are kept: they tell particles apart (إِنَّ/أَنَّ, إِنِّی/أَنَّىٰ).
def arabic_particle_key(letter_units)
  letter_units.each_with_index.map do |letter_unit, unit_index|
    letter_unit.letter + (letter_unit.shadda && unit_index > 0 ? ARABIC_SHADDA : '')
  end.join
end

# Letters only, hamza seats and ya forms unified (for the divine name and the five nouns)
def normalize_arabic_for_lookup(text)
  text.tr("أإآٱئؤ#{ARABIC_ALEF_MAQSURA}ي", 'ااااءءیی')
end

# Entries are looked up by letters + shadda; the vowels an entry spells out must not clash with the word's
def build_arabic_entry_lookup(entries)
  entries.each_with_object(Hash.new { |lookup, key| lookup[key] = [] }) do |(spelling, value), lookup|
    entry_units = parse_arabic_letter_units(spelling)
    lookup[arabic_particle_key(entry_units)] << [entry_units.map(&:vowel), value]
  end
end

def find_arabic_entry(lookup, letter_units)
  return nil unless lookup.key?(arabic_particle_key(letter_units))

  lookup[arabic_particle_key(letter_units)].each do |entry_vowels, value|
    vowels_agree = entry_vowels.zip(letter_units).all? do |entry_vowel, letter_unit|
      entry_vowel.nil? || letter_unit.vowel.nil? || entry_vowel == letter_unit.vowel
    end
    return value if vowels_agree
  end
  nil
end

ARABIC_PARTICLE_LOOKUP = build_arabic_entry_lookup(
  ARABIC_PARTICLE_ENTRIES.map { |entry| entry.split('=') }.map do |spelling, canonical|
    [spelling, (canonical || spelling).gsub(/[^\p{Arabic}]|[\u064B-\u065F\u0670]/, '')]
  end +
  ARABIC_ALEF_MAQSURA_PARTICLE_STARTS.map do |particle_start|
    [particle_start + ARABIC_ALEF_MAQSURA, (particle_start + ARABIC_ALEF_MAQSURA).delete(ARABIC_SHADDA)]
  end
)
ARABIC_IRREGULAR_ROOT_LOOKUP = build_arabic_entry_lookup(ARABIC_IRREGULAR_ROOTS)
ARABIC_IMPERATIVE_IRREGULARS = %w[كل خذ].freeze # never preceded by the interrogative أَ

# --- weight matching ----------------------------------------------------------------

# Compile a weight template into slots: { radical: index } or { fixed: letter }, each with a vowel.
# Radicals are numbered on the unexpanded template so a shadda doubles the same radical.
def compile_arabic_weight_template(template, weak_middle: false, imperfect: false)
  literal_lam_count = 0
  template_slots = parse_arabic_letter_units(template).each_with_index.map do |template_unit, unit_index|
    slot = case template_unit.letter
           when 'ف' then { radical: 0 }
           when 'ع' then weak_middle ? { radical: 1, weak_only: true } : { radical: 1 }
           when 'ل'
             literal_lam_count += 1
             { radical: literal_lam_count == 1 ? 2 : 3 }
           else { fixed: template_unit.letter, imperfect_prefix: imperfect && unit_index == 0 }
           end
    slot.merge(vowel: template_unit.vowel, shadda: template_unit.shadda)
  end
  template_slots.each_with_index.flat_map do |slot, slot_index|
    slot[:shadda] && slot_index > 0 ? [slot.merge(vowel: nil, doubled: true), slot] : [slot]
  end
end

COMPILED_ARABIC_WEIGHT_TEMPLATES = (
  ARABIC_WEIGHT_TEMPLATES.map { |template| { template: template } } +
  ARABIC_IMPERFECT_WEIGHT_TEMPLATES.map { |template| { template: template, imperfect: true, verbal: true } } +
  ARABIC_QUADRILITERAL_WEIGHT_TEMPLATES.map { |template| { template: template } } +
  ARABIC_IMPERATIVE_WEIGHT_TEMPLATES.map { |template| { template: template, imperative: true, verbal: true } } +
  ARABIC_HOLLOW_WEIGHT_TEMPLATES.map { |template| { template: template, weak_middle: true } } +
  ARABIC_HOLLOW_IMPERFECT_WEIGHT_TEMPLATES.map { |template| { template: template, weak_middle: true, imperfect: true, verbal: true } } +
  ARABIC_GEMINATE_WEIGHT_TEMPLATES.map { |template| { template: template, geminate: true } } +
  ARABIC_GEMINATE_IMPERFECT_WEIGHT_TEMPLATES.map { |template| { template: template, geminate: true, imperfect: true, verbal: true } } +
  ARABIC_DEFECTIVE_WEIGHT_TEMPLATES.map do |template, implied_radicals|
    { template: template, implied_radicals: implied_radicals }
  end +
  ARABIC_DEFECTIVE_IMPERFECT_WEIGHT_TEMPLATES.map do |template, implied_radicals|
    { template: template, implied_radicals: implied_radicals, imperfect: true, verbal: true }
  end +
  ARABIC_HAMZA_INITIAL_FORM_IV_WEIGHT_TEMPLATES.map do |template, implied_radicals|
    { template: template, implied_radicals: implied_radicals, verbal: true }
  end +
  ARABIC_DEFECTIVE_PERFECT_WEIGHT_TEMPLATES.map do |template, implied_radicals|
    { template: template, implied_radicals: implied_radicals, requires_suffix: true, verbal: true }
  end
).map do |weight_definition|
  weight_definition.merge(
    slots: compile_arabic_weight_template(weight_definition[:template],
                                          weak_middle: weight_definition[:weak_middle] || false,
                                          imperfect: weight_definition[:imperfect] || false)
  )
end.freeze

def arabic_letters_equivalent?(template_letter, word_letter)
  return true if template_letter == word_letter
  return true if arabic_hamza?(template_letter) && arabic_hamza?(word_letter)
  ya_forms = ['ی', ARABIC_ALEF_MAQSURA]
  ya_forms.include?(template_letter) && ya_forms.include?(word_letter)
end

# Turn the letter found in a radical slot into the radical it stands for:
# hamza seats → أ, a long alef → و (hollow/defective), alef maqsura → ی
def arabic_radical_letter(letter)
  return ARABIC_ROOT_HAMZA if arabic_hamza?(letter)
  return 'و' if letter == 'ا'
  return ARABIC_ROOT_YA if letter == ARABIC_ALEF_MAQSURA
  letter
end

# Match stem units against a compiled weight. Returns nil, or
#   [score, root, ambiguous weak radical indexes, written weak radical indexes, hamza carrier read?]
# Fixed letters of the weight explain the word and earn points; clashing vowels rule the weight out.
def match_arabic_weight(stem_units, weight_definition)
  template_slots = weight_definition[:slots]
  return nil unless stem_units.length == template_slots.length
  return nil if weight_definition[:imperative] && ARABIC_WEAK_LETTERS.include?(stem_units.last.letter)

  radicals = []
  hamza_carrier_read = false
  weak_radical_indexes = []    # read from a long alef, alef maqsura, hamza or implied: may be any weak letter
  written_weak_indexes = []    # a written و/ی: may only be its twin (ٱلۡقِیَـٰمَة ← قوم, ٱلرِّیَـٰح ← روح)
  match_score = 0
  template_slots.each_with_index do |slot, slot_index|
    stem_unit = stem_units[slot_index]
    if slot[:fixed]
      return nil unless arabic_letters_equivalent?(slot[:fixed], stem_unit.letter)
      # ت/ن/أ also begin many roots, so as imperfect prefixes they prove less than the very common ی
      match_score += slot[:imperfect_prefix] && stem_unit.letter != 'ی' ? 1 : 2
    else
      radical_index = slot[:radical]
      return nil if stem_unit.silent || stem_unit.letter == 'ة' # unpronounced letters and taa marbuta are never radicals
      # a long vowel right after a hamza at the start is the root's own hamza: ءَامَنَ (أَأۡمَنَ), إِیمَـٰن, أُوتُوا۟
      root_hamza_carrier = radical_index == 0 && slot_index > 0 && stem_unit.vowel.nil? && %w[ا ی و].include?(stem_unit.letter) &&
                           arabic_hamza?(stem_units[slot_index - 1].letter)
      return nil if stem_unit.letter == 'ا' && radical_index == 0 && !root_hamza_carrier # a root never starts with a long alef
      if slot[:weak_only]
        # a long vowel letter carries no vowel of its own and echoes the vowel before it:
        # fatha + ا (قَالَ), kasra + ی (قِیلَ), damma + و (یَقُولُ); لَیۡسَ has a diphthong, not a long vowel
        return nil unless ARABIC_WEAK_LETTERS.include?(stem_unit.letter) && stem_unit.vowel.nil?
        preceding_vowel = slot_index > 0 ? stem_units[slot_index - 1].vowel : nil
        return nil unless preceding_vowel.nil? || ARABIC_LONG_VOWEL_LETTERS.fetch(preceding_vowel, []).include?(stem_unit.letter)
        match_score += 2 # the long vowel of a hollow weight is as telling as a fixed letter
      elsif stem_unit.letter == 'ا' && !root_hamza_carrier
        match_score -= 1 # weak radical surfaced as a long vowel outside a hollow weight
      end
      # a doubled letter belongs in a doubled slot of the weight, or spans two radicals of a geminate root (ربّ)
      if stem_unit.from_shadda
        next_slot = template_slots[slot_index + 1]
        match_score += 1 if slot[:doubled]
        match_score -= 1 if !slot[:doubled] && !(next_slot && next_slot[:radical])
      end
      hamza_carrier_read ||= root_hamza_carrier
      radical_letter = root_hamza_carrier ? ARABIC_ROOT_HAMZA : arabic_radical_letter(stem_unit.letter)
      # alef, alef maqsura and hamza hide which weak radical they stand for (so does the long vowel of a
      # hollow weight); a written و/ی after the first radical may still stand for its twin
      if ['ا', ARABIC_ALEF_MAQSURA].include?(stem_unit.letter) || slot[:weak_only] ||
         (radical_letter == ARABIC_ROOT_HAMZA && radical_index >= 1) # a hamza inside the root may stand for و/ی (سَمَاۤء)
        weak_radical_indexes << radical_index unless root_hamza_carrier
      elsif radical_index >= 1 && %w[و ی].include?(stem_unit.letter)
        written_weak_indexes << radical_index
      end
      if radicals[radical_index]
        return nil unless radicals[radical_index] == radical_letter
      else
        radicals[radical_index] = radical_letter
      end
    end
    # the vowels are what tell one weight from another; the synthetic sukun of a doubled letter is skipped
    if slot[:vowel] && stem_unit.vowel && !stem_unit.from_shadda
      return nil unless slot[:vowel] == stem_unit.vowel
      match_score += 1
    end
  end
  (weight_definition[:implied_radicals] || {}).each do |missing_radical_index, implied_letter|
    return nil if radicals[missing_radical_index]
    radicals[missing_radical_index] = implied_letter
    weak_radical_indexes << missing_radical_index
    match_score -= 1
  end
  if weight_definition[:geminate]
    # the doubled letter must fill both the 2nd and 3rd radical slots (ع = ل)
    return nil unless stem_units[-2].from_shadda && radicals[1] == radicals[2]
    match_score += 2
  end
  return nil if radicals.compact.length != radicals.length
  return nil if radicals[0] == radicals[1] # the first two radicals of a root are never identical
  if radicals.length == 4
    return nil if radicals.each_cons(2).any? { |left_radical, right_radical| left_radical == right_radical }
    match_score -= 4 # prefer triliteral roots
  end
  [match_score, radicals.join, weak_radical_indexes.uniq, written_weak_indexes.uniq, hamza_carrier_read]
end

# Weak radicals are ambiguous on the surface (قَالَ ← قول, بَاعَ ← بیع; سَمَاۤء ← سمو), so each one
# may also be read as its weak alternatives; the lexicon of common roots decides between them.
ARABIC_WEAK_RADICAL_ALTERNATIVES = { 'و' => %w[ی أ], 'ی' => %w[و أ], 'أ' => %w[و ی] }.freeze

# Bonus for a known root (one of the common Quranic roots)
def arabic_root_bonus(root)
  ARABIC_COMMON_ROOTS[root] ? ARABIC_COMMON_ROOT_BONUS : 0
end
ARABIC_COMMON_ROOT_BONUS = 3

# The best-known reading among a root and its weak-letter variants (the root as written wins ties).
# A written و/ی is only read as its twin when the written root is unknown and the twin is a common root.
def arabic_best_root_reading(root, weak_radical_indexes, written_weak_indexes = [])
  root_readings = arabic_root_variants(root, weak_radical_indexes)
  if root_readings.none? { |root_reading| arabic_root_bonus(root_reading).positive? }
    root_readings += root_readings.flat_map do |root_reading|
      arabic_root_variants(root_reading, written_weak_indexes, ARABIC_WRITTEN_WEAK_TWINS)
        .select { |twin_reading| ARABIC_COMMON_ROOTS[twin_reading] }
    end
  end
  root_readings.each_with_index.max_by do |root_reading, reading_index|
    [arabic_root_bonus(root_reading), -reading_index]
  end.first
end
ARABIC_WRITTEN_WEAK_TWINS = { 'و' => %w[ی], 'ی' => %w[و] }.freeze

def arabic_root_variants(root, weak_radical_indexes, alternatives_by_letter = ARABIC_WEAK_RADICAL_ALTERNATIVES)
  weak_radical_indexes.reduce([root]) do |root_variants, radical_index|
    root_variants.flat_map do |root_variant|
      alternatives = alternatives_by_letter[root_variant[radical_index]] || []
      [root_variant] + alternatives.map do |alternative_letter|
        root_variant.dup.tap { |variant| variant[radical_index] = alternative_letter }
      end
    end
  end
end

# --- prefix and postfix splitting -------------------------------------------------------

# Every way of peeling prefixes off the front, respecting the vowel each prefix carries.
# Returns [stripped prefixes, units consumed, prefix score, weights allowed?]: when the word
# certainly carries the article, readings that keep it are left to particles (ٱلَّذِینَ) only.
def arabic_proclitic_splits(letter_units)
  splits = [[[], 0, 0]]
  ARABIC_PROCLITIC_LAYERS.each do |clitic_layer|
    splits += splits.flat_map do |stripped_clitics, consumed_count, split_score|
      clitic_layer.filter_map do |clitic_text, expected_vowels|
        clitic_units = letter_units[consumed_count, clitic_text.length]
        next unless clitic_units && clitic_units.length == clitic_text.length && arabic_units_text(clitic_units) == clitic_text

        clitic_vowel = clitic_units.last.vowel
        next if expected_vowels && clitic_vowel && !expected_vowels.include?(clitic_vowel)

        following_unit = letter_units[consumed_count + clitic_text.length]
        next unless following_unit

        consumed_length = clitic_text.length
        clitic_score = ARABIC_PROCLITIC_SCORES.fetch(clitic_text, 0)
        case clitic_text
        when 'أ', 'ء'
          next unless consumed_count == 0
          clitic_score = 0 if arabic_hamza?(following_unit.letter) # ءَأَنذَرۡتَهُمۡ
        when 'یا'
          next unless clitic_units.first.vowel == :fatha && !(consumed_count > 0 && clitic_units.first.shadda) # أَیَّام is no vocative
        when 'ت'
          next unless consumed_count == 0 && arabic_units_text(letter_units[1..]) == 'الله' # تَٱللَّهِ
        when 'س'
          # future سَ only comes before an imperfect verb, whose prefix has fatha or damma
          next unless ARABIC_IMPERFECT_PREFIXES.include?(following_unit.letter) && [:fatha, :damma].include?(following_unit.vowel)
        when 'ال'
          if clitic_units.last.shadda
            consumed_length = 1 # ٱلَّیۡل: the article's lam merged into a lam-initial stem
          elsif [:fatha, :kasra, :damma].include?(clitic_vowel)
            next # the article lam is silent or has sukun
          end
        when 'ل'
          if expected_vowels.nil? # the article's lam after the preposition لِ (لِلنَّاسِ)
            next unless stripped_clitics.last == 'ل'
            next if [:fatha, :kasra, :damma].include?(clitic_vowel)
          elsif clitic_vowel == :sukun # lam of command (فَلۡیَتَوَكَّلِ) only precedes an imperfect verb
            next unless ARABIC_IMPERFECT_PREFIXES.include?(following_unit.letter)
          end
        end
        [stripped_clitics + [clitic_text], consumed_count + consumed_length, split_score + clitic_score]
      end
    end
  end
  splits.uniq!

  # a lam with sukun, or a silent lam before a doubled (sun) letter, is certainly the article
  confirmed_article_split = lambda do |stripped_clitics, consumed_count|
    next false unless stripped_clitics.last == 'ال' || stripped_clitics.last(2) == %w[ل ل]
    article_unit = letter_units[consumed_count - 1]
    following_unit = letter_units[consumed_count]
    next false unless following_unit
    next true if article_unit.letter == 'ا' && following_unit.letter == 'ل' && following_unit.shadda
    article_unit.vowel == :sukun || (article_unit.vowel.nil? && following_unit.shadda)
  end
  article_certain = splits.any? { |stripped_clitics, consumed_count, _| confirmed_article_split.call(stripped_clitics, consumed_count) }
  splits.map do |stripped_clitics, consumed_count, split_score|
    weights_allowed = !article_certain || confirmed_article_split.call(stripped_clitics, consumed_count)
    [stripped_clitics, consumed_count, split_score, weights_allowed]
  end
end

# Stripping a postfix must be justified by the weight; single-letter inflections are the most ambiguous
def arabic_suffix_penalty(suffix_text, stem_units, suffix_units)
  return 0 if suffix_text.empty?
  return 0 if suffix_text.start_with?('ات') # the feminine plural is the most reliable ending: ءَایَـٰتِنَا = ءای + ات + نا
  return 0 if suffix_text == 'ن' && suffix_units.first&.shadda # energetic nun: لَیَقُولُنَّ, تَكُونَنَّ
  # perfect-tense subject endings (فَعَلۡتُ, فَعَلۡنَا, فَعَلۡتُمۡ) follow a stem ending in sukun
  # (an unmarked consonant before them is a hidden sukun: كُنتَ)
  last_stem_unit = stem_units.last
  if %w[ت ن].include?(suffix_text[0]) && last_stem_unit &&
     !ARABIC_WEAK_LETTERS.include?(last_stem_unit.letter) && [:sukun, nil].include?(last_stem_unit.vowel)
    return 0
  end
  return 0 if suffix_text == 'ت' && suffix_units.last&.vowel == :sukun # feminine perfect فَعَلَتۡ
  # the feminine ت after fatha or a long ا: نِعۡمَتَ, قَالَتِ, صَلَاتِهِمۡ
  return 0 if suffix_text.start_with?('ت') && (last_stem_unit&.vowel == :fatha || last_stem_unit&.letter == 'ا')
  return 2 if suffix_text.length == 1 && ARABIC_INFLECTION_SUFFIXES.include?(suffix_text) && suffix_text != 'ة'
  1
end

# Cut a postfix off the remaining units. When the postfix's first letter carries shadda it has merged
# with the stem's last letter (كُنَّا = كُنۡ + نَا), so the stem keeps a plain copy of that letter.
def split_arabic_suffix(remaining_units, suffix_text)
  return [remaining_units, ''] if suffix_text.empty?
  return nil unless remaining_units.length > suffix_text.length
  return nil unless arabic_units_text(remaining_units.last(suffix_text.length)) == suffix_text

  stem_units = remaining_units[0, remaining_units.length - suffix_text.length]
  first_suffix_unit = remaining_units[-suffix_text.length]
  if first_suffix_unit.shadda && (suffix_text.length > 1 || suffix_text == 'ی') &&
     (stem_units.last&.letter != first_suffix_unit.letter || suffix_text == 'ی')
    stem_units += [ArabicLetterUnit.new(first_suffix_unit.letter, :sukun)]
  end
  [stem_units, suffix_text]
end

# The stem as text: Uthmani ءا is written آ, and a feminine ending cut off with the postfix comes back
# (ات → ة; ة written ت before a pronoun: صَلَاتِهِمۡ → صلاة, نِعۡمَتِهِۦ → نعمة)
def arabic_stem_text(stem_units, suffix_text)
  stem_text = arabic_units_text(stem_units).sub(/\Aءا/, 'آ')
  feminine_ta_before_pronoun = suffix_text.start_with?('ت') && ARABIC_PRONOUN_SUFFIXES.include?(suffix_text[1..]) &&
                               (stem_units.last&.vowel == :fatha || stem_units.last&.letter == 'ا')
  stem_text += 'ة' if suffix_text.start_with?('ة') || suffix_text.start_with?('ات') || feminine_ta_before_pronoun
  stem_text
end

# Particles, pronouns, the divine name and irregular words: stems that need no weight
def arabic_special_stem_analysis(stem_units, stripped_clitics, suffix_text)
  stem_letters = arabic_units_text(stem_units)
  lookup_letters = normalize_arabic_for_lookup(stem_letters)
  pronoun_suffix = ARABIC_PRONOUN_SUFFIXES.include?(suffix_text)

  # the divine name keeps its own ال; after لِ it is written لِلَّه
  if suffix_text.empty? &&
     (%w[الله اللهم].include?(lookup_letters) || (stripped_clitics.last == 'ل' && %w[له لهم].include?(lookup_letters) && stem_units.first.shadda))
    return { score: 10, root: 'أله', stem: 'الله', kind: :root }
  end
  if suffix_text.empty?
    # a preposition prefix on a bare attached pronoun: لَهُۥ = لَ + هو
    attached_pronoun = ARABIC_ATTACHED_PRONOUNS[stem_letters]
    if attached_pronoun && (stripped_clitics & %w[ب ل ك]).any? && stem_units.none?(&:shadda)
      return { score: 8, root: attached_pronoun, stem: attached_pronoun, kind: :particle }
    end
    canonical_particle = find_arabic_entry(ARABIC_PARTICLE_LOOKUP, stem_units)
    canonical_particle = nil if stem_letters == 'م' && (stripped_clitics & %w[ل ب]).empty? # مَا shortens only after لِ/بِ: لِمَ
    return { score: 8, root: canonical_particle, stem: canonical_particle, kind: :particle } if canonical_particle
  elsif pronoun_suffix && (stripped_clitics - %w[و ف أ ء]).empty? # these particles never follow بِ/لِ/كَ
    canonical_particle = ARABIC_PRONOUN_BEARING_PARTICLES[stem_letters.tr(ARABIC_ALEF_MAQSURA, 'ی')]
    return { score: 9, root: canonical_particle, stem: canonical_particle, kind: :particle } if canonical_particle
  end
  irregular_units = suffix_text.start_with?('ة') ? stem_units + [ArabicLetterUnit.new('ة')] : stem_units
  irregular_root = find_arabic_entry(ARABIC_IRREGULAR_ROOT_LOOKUP, irregular_units)
  if irregular_root && !(stripped_clitics.include?('أ') && ARABIC_IMPERATIVE_IRREGULARS.include?(stem_letters))
    irregular_score = stem_units.length <= 2 && pronoun_suffix ? 4 : 10
    return { score: irregular_score, root: irregular_root, stem: arabic_stem_text(stem_units, suffix_text), kind: :root }
  end
  return nil unless suffix_text.empty? || pronoun_suffix

  # أب / أخ lengthen before pronouns (أَبِیهِ, أَخُوهُ, أَبَانَا)
  if (five_noun = lookup_letters.match(/\A(اب|اخ)[یوا]?\z/))
    return { score: 6, root: five_noun[1] == 'اب' ? 'أبو' : 'أخو', stem: stem_letters[0, 2], kind: :root }
  end
  nil
end

# --- analysis -----------------------------------------------------------------------------

# Analyse a vowelized word into prefixes + stem + postfix and find its root. Returns
#   { root:, stem:, kind:, weight:, proclitics:, suffix: }
# where kind is :root (a derived word whose radicals were found), :particle (no root),
# :letters (disjointed letters such as الۤمۤ) or :unknown (no weight fits; root is the stem itself).
def analyze_arabic_word(word)
  ARABIC_WORD_ANALYSIS_CACHE[word] ||= compute_arabic_word_analysis(word).freeze
end

def compute_arabic_word_analysis(word)
  letter_units = parse_arabic_letter_units(word)
  return { root: '', stem: '', kind: :unknown, weight: nil, proclitics: [], suffix: '' } if letter_units.empty?

  # the final short vowel is the case ending, not part of the weight; a final sukun (verbs) is kept
  ends_without_case_vowel = [:sukun, nil].include?(letter_units.last.vowel)
  letter_units.last.vowel = nil unless letter_units.last.vowel == :sukun
  # disjointed letters (الۤمۤ, كۤهیعۤصۤ) carry maddas but no vowels and are not derived words
  if word.include?(ARABIC_DISJOINTED_LETTER_MADDA) && letter_units.none?(&:vowel) && letter_units.none?(&:shadda)
    bare_letters = arabic_units_text(letter_units)
    return { root: bare_letters, stem: bare_letters, kind: :letters, weight: nil, proclitics: [], suffix: '' }
  end

  word_has_tanwin = word.match?(/[\u064B-\u064D\u08F0-\u08F2]/)
  best_analysis = nil
  consider_analysis = lambda do |candidate_analysis|
    best_analysis = candidate_analysis if best_analysis.nil? || candidate_analysis[:score] > best_analysis[:score]
  end
  proclitic_splits = arabic_proclitic_splits(letter_units)

  proclitic_splits.each do |stripped_clitics, consumed_count, proclitic_score, weights_allowed|
    remaining_units = letter_units[consumed_count..]
    ARABIC_SUFFIX_CANDIDATES.each do |suffix_text|
      stem_units, = split_arabic_suffix(remaining_units, suffix_text)
      next unless stem_units

      affixes = { proclitics: stripped_clitics, suffix: suffix_text }
      suffix_units = remaining_units.last(suffix_text.length)
      affix_score = proclitic_score - arabic_suffix_penalty(suffix_text, stem_units, suffix_units)
      # a doubled letter right before a pronoun, plural or verb ending is a geminate root far more often
      # than a Form II weight (رَبِّكَ, جَنَّـٰت, حَقَّتۡ)
      if (ARABIC_PRONOUN_SUFFIXES + %w[ات ون ین ان وا ت]).include?(suffix_text) && stem_units.length > 1 && stem_units.last.shadda
        affix_score += 5
      end
      special_analysis = arabic_special_stem_analysis(stem_units, stripped_clitics, suffix_text)
      if special_analysis
        consider_analysis.call(special_analysis.merge(affixes, weight: nil, score: special_analysis[:score] + affix_score))
      end
      next unless weights_allowed

      defective_perfect_ending = ARABIC_DEFECTIVE_PERFECT_ENDINGS.any? { |ending| suffix_text.start_with?(ending) } &&
                                 !(suffix_text.start_with?('ت') && suffix_units.first.vowel != :sukun)
      # tanwin, the article and the prepositions بِ/كَ only come with nouns, never with verbs
      noun_context = word_has_tanwin || (stripped_clitics & %w[ال ب ك]).any? || stripped_clitics.last(2) == %w[ل ل]
      expanded_stem_units = expand_arabic_shadda(stem_units)
      COMPILED_ARABIC_WEIGHT_TEMPLATES.each do |weight_definition|
        next if weight_definition[:requires_suffix] && !defective_perfect_ending
        next if weight_definition[:verbal] && noun_context
        next if weight_definition[:imperative] && suffix_text.empty? && !ends_without_case_vowel

        match_result = match_arabic_weight(expanded_stem_units, weight_definition)
        next unless match_result

        weight_score, radicals, weak_radical_indexes, written_weak_indexes, hamza_carrier_read = match_result
        root_reading = arabic_best_root_reading(radicals, weak_radical_indexes, written_weak_indexes)
        # ءَا read as أَأۡ (ءَامَنَ ← أمن) only for known roots; ءَایَـٰت is a plural in ات, not أَفْعَال
        weight_score -= 3 if hamza_carrier_read && !ARABIC_COMMON_ROOTS[root_reading]
        consider_analysis.call(
          score: weight_score + affix_score + arabic_root_bonus(root_reading),
          root: root_reading, stem: arabic_stem_text(stem_units, suffix_text),
          kind: :root, weight: weight_definition[:template], **affixes
        )
      end
    end
  end

  best_analysis ||= arabic_unknown_word_analysis(letter_units, proclitic_splits)
  best_analysis.except(:score)
end

# No weight fits: strip the most certain prefixes and use the remaining letters as the root
def arabic_unknown_word_analysis(letter_units, proclitic_splits)
  stripped_clitics, consumed_count, = proclitic_splits
    .select { |_, consumed_count_candidate, _, weights_allowed| weights_allowed && letter_units.length - consumed_count_candidate >= 2 }
    .max_by { |_, _, proclitic_score, _| proclitic_score } || [[], 0]
  stem_text = arabic_stem_text(letter_units[consumed_count..], '')
  { score: 0, root: stem_text, stem: stem_text, kind: :unknown, weight: nil, proclitics: stripped_clitics, suffix: '' }
end
