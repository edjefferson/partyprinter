
require 'open-uri'
require 'pg'
require 'active_record'


require './lib/microprinter'
require './lib/imagemicroprinter'
require './lib/formats/tubestatus'





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

    puts "puts checking feed"
    unprinted_items.each do |item|
      get_format(item).print
      item.printed = 1
      item.save

    end

  end
end
