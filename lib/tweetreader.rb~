require 'twitter'
require 'tweetstream'
require 'fastimage'
require 'pg'
require 'active_record'
require './tubestatus'
require './tweet'





class Bardscene < ActiveRecord::Base
  def process(tweet)
  end
end


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
    recent_tweets = []
    @tweeter = twitter_authorisation(Twitter)
    @tweeter.mentions_timeline[0..(x-1)].reverse
  end

#check if already posted

  def check_if_reply_and_not_already_read(tweet)
    if tweet.text.match(/^@partyprinter.*/) && tweet.user.id != 1678701920 && Tweet.exists?(tweet.id.to_i) == nil
      return true
    end

  end

#determine type of tweet  

  def format_and_queue(tweet)
   if tweet.text.match(/@partyprinter tubestatus/)
      Tubestatus.new(tweet)
    elsif tweet.text.match(/@partyprinter bardscene.*/)
      Bardscene.new(tweet)
    else
      Tweet.new(tweet)
    end
  end

#get needed info from tweet


  


  def check_and_store(tweet)
    if check_if_reply_and_not_already_read(tweet)
      format_and_queue(tweet)
    end
  end

  def fetch_tweets
    get_recent_x_replies(5).each do |tweet|
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

