require 'twitter'
require 'tweetstream'
require 'fastimage'
require 'pg'
require 'active_record'

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




def read_tweet(status)
  if status.in_reply_to_user_id.to_i == 1678701920 && status.user.id != 1678701920 && status.id > Tweet.maximum(:id)
    image_urls = []
    status.media.each do |media|
      if image_check(media.media_url)
        image_urls << media.media_url
      end
    end
    puts "reading tweet #{status.text}"
    Tweet.create(:id => status.id.to_s, :text => status.text.gsub(/^@partyprinter /,""), :name => status.user.name, :screen_name => status.user.screen_name, :created_at => status.created_at, :images => image_urls, :printed => "0")
    
    
    begin
      @tweeter.follow(status.user.screen_name)
      @tweeter.retweet(status.id)
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

client.userstream do |status|
  read_tweet(status)
end

