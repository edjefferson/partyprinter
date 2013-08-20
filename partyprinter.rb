require './microprinter'
require './imagemicroprinter'
require 'open-uri'
require 'twitter'
require 'tweetstream'
require 'fastimage'
require 'pg'
require 'active_record'
require 'action_view'
require 'net/http'
require 'uri'

include ActionView::Helpers::TextHelper

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

class Tweet < ActiveRecord::Base
end

def twitter_authorisation(twitter_instance)
  twitter_instance.configure do |config|
    config.consumer_key = ENV['YOUR_CONSUMER_KEY']
    config.consumer_secret = ENV['YOUR_CONSUMER_SECRET']
    config.oauth_token = ENV['YOUR_OAUTH_TOKEN']
    config.oauth_token_secret = ENV['YOUR_OAUTH_TOKEN_SECRET']
  end
  return twitter_instance
end

def image_check(image_url)
  if FastImage.type(image_url) != nil
    return true
  end
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


def read_tweet(status)
  if status.text.match(/^@partyprinter.*/) && status.user.id != 1678701920 && Tweet.exists?(status.id.to_i) == false
    image_urls = []
    status.media.each do |media|
      if image_check(media.media_url)
        image_urls << media.media_url
      end
    end

    status.urls.each do |url|
      if image_check(url.expanded_url)
        image_urls << url.expanded_url
      end
    end
    Tweet.create(:id => status.id.to_s, :text => status.text.gsub(/^@partyprinter /,""), :name => status.user.name, :screen_name => status.user.screen_name, :created_at => status.created_at, :images => image_urls, :printed => "0")
    
    tweet = Tweet.find("#{status.id}")
  
    print_tweet(tweet.text,tweet.screen_name,tweet.name,tweet.created_at,tweet.images)

    tweet.printed = 1
    tweet.save
    
    begin
      @tweeter.follow(status.user.screen_name)
      #@tweeter.retweet(status.id)
    rescue
      puts $!, $@
      puts "mo rate limit mo problems, not followed or retweeted :("

    end
  end
  
end

def get_recent_x_replies(x)
  @tweeter = twitter_authorisation(Twitter)
  @tweeter.mentions_timeline[0..x].reverse.each do |tweet|
    read_tweet(tweet)
  end
end


puts "checking for recent replies that happened while I was asleep"

get_recent_x_replies(5)

puts "checking stream"

twitter_authorisation(TweetStream)
client = TweetStream::Client.new

client.on_error do |message|
  # Log your error message somewhere
  puts "ERROR: #{message}"
end

client.on_limit do |skip_count|
  # do something
  puts "RATE LIMITED LOL"
end

client.userstream do |status|
  puts status.text
  read_tweet(status)
end

