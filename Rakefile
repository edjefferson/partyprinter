require './tweetreader'

task :fetch_tweets do |t|
  TweetReader.new.fetch_tweets
end

task :stream_tweets do |t|
  TweetReader.new.fetch_tweets
  TweetReader.new.stream_tweets
end