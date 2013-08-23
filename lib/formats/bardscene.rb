require './microprintersequence.rb'

class Bardscene < ActiveRecord::Base

  def print_bard_scene
    @printer = Microprinter.new
    @imageprinter = ImageMicroprinter.new

    @printer.set_underline_on
    @printer.print_line self.title
    @printer.set_underline_off

    @printer.print_line self.scene_name
    self.contents.each do |line|
      if line.match(/^  [^a-z]*.\..*/)
        words = line.gsub(/^  [^a-z]*.\./,"")
        name = line.gsub(words,"")
        @printer.set_font_weight_bold
        @printer.print name
        @printer.set_font_weight_normal
        @printer.print words

      else
        @printer.print line
      end
    end
    @printer.feed_and_cut
  end

end