require 'action_view'
require 'active_record'
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

  def print(tweet)
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
    
    get_images_from(tweet).each do |url|
      @imageprinter.print_image(url, true, 0, 5)
    end

    @printer.feed_and_cut

  end
end
