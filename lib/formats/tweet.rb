require './microprintersequence.rb'
require 'action_view'
include ActionView::Helpers::TextHelper

class Tweet < ActiveRecord::Base

  def get_images_from(tweet)

    image_urls = []

    tweet.media.each do |m|
      if FastImage.type(m.media_url)
        image_urls << m.media_url
      end
    end

    tweet.urls.each do |u|
      if FastImage.type(u.expanded_url)
        image_urls << u.expanded_url
      end
    end

    return image_urls

  end

  def print
    @printer = Microprinter.new
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
    @printer.print_line ""
    
    self.images.each do |url|
      @imageprinter.print_image(url, true, 0, 5)
    end

    @printer.feed_and_cut

  end
end