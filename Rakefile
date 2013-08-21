require './tweetreader'
require './queue'


task :fetch_tweets do |t|
  TweetReader.new.fetch_tweets
end

task :stream_tweets do |t|
  TweetReader.new.fetch_tweets
  TweetReader.new.stream_tweets
end

task :check_for_new do |t|
  while true
    Queue.new.check_for_new
  end
end