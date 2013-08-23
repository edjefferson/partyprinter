#require './lib/tweetreader'
#require './lib/queue'
require './lib/microprinter'
require './lib/microprintersequence'
require './lib/microprintertest'

=begin

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
=end
task :testprint do |t|
  b = Microprinter.new
  b.check_buffer
end



task :testsequence do |t|
  a = MicroprinterSequence.new
  a.build_test_sequence
end
  
