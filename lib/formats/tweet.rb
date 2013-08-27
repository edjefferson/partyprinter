require 'action_view'
require 'active_record'
include ActionView::Helpers::TextHelper

class Tweet < ActiveRecord::Base



  def print
    @printer = MicroprinterSequence.new
    @imageprinter = ImageMicroprinter.new
    
    puts "printing tweet"

    @printer.set_underline_off
    @printer.set_font_weight_normal

    puts self.created_at
    @printer.print_line "#{self.created_at}"
    @printer.print_line ""

    @printer.set_underline_on
    @printer.set_font_weight_bold

    puts "@#{self.screen_name} (#{self.name}) says:"
    @printer.print_line "@#{self.screen_name} (#{self.name}) says:"
    @printer.print_line ""

    @printer.set_underline_off
    @printer.set_font_weight_normal
    
    puts self.text
    @printer.print_line word_wrap(self.text, line_width: 46)
    @printer.print "\n"
    
    self.images.each do |url|
      puts url
      @imageprinter.print_image(url, true, 0, 5).each do |byte|
        @printer.push byte
      end
    end

    @printer.feed_and_cut

    @printer.write_sequence_to_database

  end
end
