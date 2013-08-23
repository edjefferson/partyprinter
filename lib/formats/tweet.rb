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

    puts tweet.created_at
    @printer.print_line "#{tweet.created_at}"
    @printer.print_line ""

    @printer.set_underline_on
    @printer.set_font_weight_bold

    puts "@#{tweet.user.screen_name} (#{tweet.user.name}) says:"
    @printer.print_line "@#{tweet.user.screen_name} (#{tweet.user.name}) says:"
    @printer.print_line ""

    @printer.set_underline_off
    @printer.set_font_weight_normal
    
    puts tweet.text
    @printer.print_line word_wrap(tweet.text, line_width: 46)
    @printer.print_line ""
    
    tweet.image_urls.each do |url|
      @imageprinter.print_image(url, true, 0, 5)
    end

    @printer.feed_and_cut

  end
end
