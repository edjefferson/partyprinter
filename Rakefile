require './lib/tweetreader'
require './lib/microprinter'
require './lib/microprintersequence'
require './lib/imagemicroprinter'


task :fetch_tweets do |t|
  TweetReader.new.fetch_tweets
end

task :stream_tweets do |t|
  TweetReader.new.fetch_tweets
  TweetReader.new.stream_tweets
end

task :print do |t|
  b = Microprinter.new
  b.check_buffer
end
