
require 'open-uri'
require 'pg'
require 'active_record'
require 'action_view'
include ActionView::Helpers::TextHelper

require './microprinter'
require './imagemicroprinter'
require './tubestatus'

class Tweet < ActiveRecord::Base
  def print
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
end



class Bardscene < ActiveRecord::Base

  def print_bard_scene(scene)
    @printer.set_underline_on
    @printer.print_line scene.title
    @printer.set_underline_off

    @printer.print_line scene.scene_name
    scene.contents.each do |line|
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

class Queue

  def initialize
    
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
  end

  def unprinted_items
    Tweet.where("printed = 0").order("created_at ASC")
  end

  def get_format(item)
    if item.text == "tubestatus"
      Tubestatus.find(item.id)
    elsif item.text.match(/^bardscene.*/)
      Bardscene.find(Bardscene.find(tweet.text.split[1]))
    else
      item
    end
  end


  def check_for_new
    @printer = Microprinter.new
    @imageprinter = ImageMicroprinter.new
    unprinted_items.each do |item|
      get_format(item).print
    end
  end
end