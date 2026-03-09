#!/usr/bin/env ruby
# Arabic text processing utilities

# Remove Arabic diacritical marks from text
def remove_arabic_diacritics(text)
  # Main Arabic diacritics (tashkeel) + tatweel + superscript alef
  # Comprehensive Arabic diacritics collection
  text
    .gsub(/[\u06E2\u08F0-\u08F2]\u0627/, '')                              # Uthmani tanwin marks + alef → remove (e.g. یقینَۢا → یقین, نصیبࣰا → نصیب)
    .gsub(/\u064B\u0627/, '')                                             # fathatan + alef → remove (standard tanwin, e.g. نصیرًا → نصیر)
    .gsub(/\u0671\u0644/, "\u0627\u0644")                                 # alef wasla + lam → ال (normalize ٱل to standard ال, covers both sukun and non-sukun variants)
    .gsub(/\u0640\u0670/, "\u0627")                                       # tatweel + superscript alef → long alef (e.g. رحمـٰن → رحمان)
    .gsub(/[\u0610-\u061A\u064B-\u065F\u0670\u0671\u06D6-\u06ED\u08D3-\u08FF]/, '') # Arabic diacritics, Quranic marks, alef wasla, Extended Arabic
    .gsub(/\u0640/, '')                                                   # tatweel (kashida)
    .gsub(/[\u0300-\u036F\u1AB0-\u1AFF\u1DC0-\u1DFF\u20D0-\u20FF\uFE20-\uFE2F]/, '') # combining diacritics
    .gsub(/(^|\s)ال(\S{3,})/) { "#{$1}#{$2}" }                          # strip definite article ال from words ≥5 letters
end
