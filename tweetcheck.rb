require 'twitter'

def twitter_authorisation(twitter_instance)
  twitter_instance.configure do |config|
    config.consumer_key = ENV['YOUR_CONSUMER_KEY']
    config.consumer_secret = ENV['YOUR_CONSUMER_SECRET']
    config.oauth_token = ENV['YOUR_OAUTH_TOKEN']
    config.oauth_token_secret = ENV['YOUR_OAUTH_TOKEN_SECRET']
  end
  return twitter_instance
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