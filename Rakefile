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
  a = MicroprinterSequence.new
  a.push "I am a horse"
  a << "I am a horse"
  a.feed_and_cut
  b.print(a)
end

task :testprint2 do |t|
  b = Microprinter.new
  a = MicroprinterSequence.new
  a.push 99,99,99,99,99,99
  a.feed_and_cut
  b.print(a)
end
