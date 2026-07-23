# frozen_string_literal: true

# Build-time name -> writing-system classifier. Maps a name to its Script by
# Unicode code-point range: the first non-Latin letter decides; a name with no
# non-Latin letters is :latin. Shared by tools/split_scripts.rb and the
# real-data spec so the split and its verification use one range table.
module ScriptClassifier
  RANGES = {
    arabic: [0x0600..0x06FF, 0x0750..0x077F],
    han: [0x4E00..0x9FFF, 0x3400..0x4DBF],
    hangul: [0xAC00..0xD7AF],
    kana: [0x3040..0x30FF],
    cyrillic: [0x0400..0x04FF],
    hebrew: [0x0590..0x05FF],
    greek: [0x0370..0x03FF],
    georgian: [0x10A0..0x10FF],
    khmer: [0x1780..0x17FF],
    bengali: [0x0980..0x09FF],
    devanagari: [0x0900..0x097F],
    thai: [0x0E00..0x0E7F]
  }.freeze

  module_function

  def script_of(name)
    name.to_s.each_char do |ch|
      cp = ch.ord
      RANGES.each { |script, ranges| return script if ranges.any? { |r| r.cover?(cp) } }
    end
    :latin
  end
end
