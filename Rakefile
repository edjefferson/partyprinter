#require './lib/tweetreader'
#require './lib/queue'
require './lib/microprinter'
require './lib/microprintersequence'

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
task :print do |t|
  a = MicroprinterSequence.new
  b = Microprinter.new
  c = ARGV[0].to_s
  a.stringprint(c)
  a.feed_and_cut(c)
  b.print(a)
end
