
require './microprinter'
require './imagemicroprinter'
require 'open-uri'
require 'pg'
require 'active_record'
require 'action_view'
include ActionView::Helpers::TextHelper

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

class Tweet < ActiveRecord::Base
end

def print_tweet(text, screen_name, name, created_at, images)
  printer = Microprinter.new
  imageprinter = ImageMicroprinter.new

  puts "printing tweet"

  printer.set_underline_off
  printer.set_font_weight_normal

  puts created_at
  printer.print_line "#{created_at}"
  printer.print_line ""

  printer.set_underline_on
  printer.set_font_weight_bold

  puts "@#{screen_name} (#{name}) says:"
  printer.print_line "@#{screen_name} (#{name}) says:"
  printer.print_line ""

  printer.set_underline_off
  printer.set_font_weight_normal
  
  puts text
  printer.print_line word_wrap(text, line_width: 46)
  printer.print_line ""
  
  images.each do |url|
    imageprinter.print_image(url, true, 0, 5)
  end

  printer.feed_and_cut
end

while true
  puts "checking queue"
  unprinted_items = Tweet.where("printed = 0").order("created_at ASC")
  if unprinted_items.size > 0
    unprinted_items.each do |tweet|
      print_tweet(tweet.text,tweet.screen_name,tweet.name,tweet.created_at,tweet.images)
      tweet.printed = 1
      tweet.save
    end
  else
    sleep 5
  end
end
