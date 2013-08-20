
require './microprinter'
require './imagemicroprinter'
require 'open-uri'
require 'pg'
require 'active_record'
require 'action_view'
include ActionView::Helpers::TextHelper

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

@printer = Microprinter.new
@imageprinter = ImageMicroprinter.new

class Tweet < ActiveRecord::Base
end

class Tubestatus < ActiveRecord::Base
end

class Bardscene < ActiveRecord::Base
end

def print_tweet(text, screen_name, name, created_at, images)
  

  puts "printing tweet"

  @printer.set_underline_off
  @printer.set_font_weight_normal

  puts created_at
  @printer.print_line "#{created_at}"
  @printer.print_line ""

  @printer.set_underline_on
  @printer.set_font_weight_bold

  puts "@#{screen_name} (#{name}) says:"
  @printer.print_line "@#{screen_name} (#{name}) says:"
  @printer.print_line ""

  @printer.set_underline_off
  @printer.set_font_weight_normal
  
  puts text
  @printer.print_line word_wrap(text, line_width: 46)
  @printer.print_line ""
  
  images.each do |url|
    @imageprinter.print_image(url, true, 0, 5)
  end

  @printer.feed_and_cut
end

def print_tube_status(tweet_id, statuses, created_at)

  puts created_at
  @printer.print_line "Tube status at #{created_at}"
  @printer.set_underline_on

  statuses.each do |linestatus|
    @printer.set_font_weight_bold
    @printer.print "#{linestatus[0]}:\n"
    @printer.set_font_weight_normal
    @printer.print " #{linestatus[1]}\n"
  end

  @printer.feed_and_cut
  Tubestatus.destroy(tweet_id)

end

def print_bard_scene(scene)
  puts scene.title
  scene.contents.each do |line|
    puts line
  end
end

while true
  puts "checking queue"
  unprinted_items = Tweet.where("printed = 0").order("created_at ASC")
  if unprinted_items.size > 0
    unprinted_items.each do |tweet|
      if tweet.text == "tubestatus"
        print_tube_status(tweet.id,Tubestatus.find(tweet.id.to_i).statuses,tweet.created_at)
        
      elsif tweet.text.match(/^bardscene.*/)
        puts "bardy"
        print_bard_scene(Bardscene.find(status.text.split[1].join))

      else
        
        print_tweet(tweet.text,tweet.screen_name,tweet.name,tweet.created_at,tweet.images)
        
      end
        tweet.printed = 1
        tweet.save
    end
  else
    sleep 5
  end
end
