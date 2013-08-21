
require 'open-uri'
require 'pg'
require 'active_record'
require 'action_view'
include ActionView::Helpers::TextHelper

require './microprinter'
require './imagemicroprinter'
require './tubestatus'
require 'time'


class Tweet < ActiveRecord::Base
  def localtime(time)
    Time.parse(time).getlocal.to_s
  end

  def print
    @printer = Microprinter.new
    @imageprinter = ImageMicroprinter.new

    puts "printing tweet"

    @printer.set_underline_off
    @printer.set_font_weight_normal

    puts created_at
    @printer.print_line "#{localtime(created_at)}"
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

class Tubestatus < ActiveRecord::Base

  def extend_line_name(name)
    while name.length < 15
      name = " " + name
    end
    return name
  end

  def process(item)
    statuses = []
    tubestatus = Tube::Status.new
    tubestatus.lines.each {|line| statuses << [extend_line_name(line.name), line.status]}
    Tubestatus.create(:id => item.id.to_s, :statuses => statuses)
  end

  def print
    puts self
    puts self.inspect

    @printer = Microprinter.new
    @imageprinter = ImageMicroprinter.new

    @printer.set_underline_on
    @printer.print_line "Tube status at #{self.created_at}"
    @printer.set_underline_off

    self.statuses.each do |linestatus|
      @printer.set_font_weight_bold
      @printer.print "#{linestatus[0]}:"
      @printer.set_font_weight_normal
      @printer.print " #{linestatus[1]}\n"
    end

    @printer.feed_and_cut
    Tubestatus.destroy(tweet_id)
  end

end



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
    unprinted_items.each do |item|
      get_format(item).print
    end
  end
end