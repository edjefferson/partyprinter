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


@tweeter = twitter_authorisation(Twitter)

@tweeter.mentions_timeline[0..3].each do |tweet|

  if tweet.text.match(/^@partyprinter.*/)
      puts tweet.text
  end


end