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

task :print_buffer do |t|
  b = Microprinter.new
  while true
    b.check_buffer
  end
end

task :print_test do |t|
  b = Microprinter.new(1)
  while true
    b.check_buffer
  end
end
