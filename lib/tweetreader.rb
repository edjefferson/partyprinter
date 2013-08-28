require 'twitter'
require 'tweetstream'
require 'fastimage'
require 'pg'
require 'active_record'
require './lib/formats/tubestatus'
require './lib/formats/bardscene'
require './lib/formats/tweet'


class TweetReader

  def initialize
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
  end
#connect to twitter  

  def twitter_authorisation(twitter_instance)
      twitter_instance.configure do |config|
        config.consumer_key = ENV['YOUR_CONSUMER_KEY']
        config.consumer_secret = ENV['YOUR_CONSUMER_SECRET']
        config.oauth_token = ENV['YOUR_OAUTH_TOKEN']
        config.oauth_token_secret = ENV['YOUR_OAUTH_TOKEN_SECRET']
      end
      return twitter_instance
    
  end
#get tweets


  def get_recent_x_replies(x)
    puts "checking last #{x} tweets"
    @tweeter = twitter_authorisation(Twitter)
    return @tweeter.mentions_timeline[0..(x-1)].reverse
  end

#check if already posted

  def check_if_reply_and_not_already_read(tweet)

    puts tweet.text
    if tweet.text.match(/^@partyprinter.*/) && tweet.user.id != 1678701920 && Tweet.exists?(tweet.id.to_i) == nil
      puts "new"
      return true
    end

  end

#determine type of tweet  

  def format(tweet)
    if tweet.text.match(/@partyprinter tubestatus/)
      Tubestatus
    elsif tweet.text.match(/@partyprinter bardscene.*/)
      Bardscene
    else
      Tweet
    end
    
  end

#get needed info from tweet

  def write_to_database(tweettype,tweet)
    Tweet.create(:id => tweet.id.to_s, :text => tweet.text.gsub(/^@partyprinter /,""), :name => tweet.user.name, :screen_name => tweet.user.screen_name, :created_at => tweet.created_at, :images => get_images_from(tweet), :printed => "0")
    if tweettype != Tweet
      tweettype.create(:id => tweet.id.to_s)
      tweettype.find(tweet.id.to_s).process
    end
    tweettype.find(tweet.id.to_s).print
  end

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
  


  def check_and_store(tweet)
    if check_if_reply_and_not_already_read(tweet)
      puts format(tweet)
      write_to_database(format(tweet),tweet)

    end
  end

  def fetch_tweets
    get_recent_x_replies(1).each do |tweet|
      check_and_store(tweet)
    end
  end

  def stream_tweets
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

    client.userstream do |tweet|
      puts tweet.text
      check_and_store(tweet)
      puts "checking stream"
    end
  end


end

