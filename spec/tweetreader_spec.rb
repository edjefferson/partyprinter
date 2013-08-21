require_relative '../tweetreader.rb'
require 'spec_helper'



describe TweetReader do
  before(:each) do
    @tweetreader = TweetReader.new

   
    @example_tweet = Twitter::Tweet.new(:created_at=>"Wed Aug 21 08:38:52 +0000 2013", :id=>123456789, :id_str=>"123456789", :text=>"@partyprinter some text http://testurl", :source=>"web", :truncated=>false, :in_reply_to_status_id=>nil, :in_reply_to_status_id_str=>nil, :in_reply_to_user_id=>1678701920, :in_reply_to_user_id_str=>"1678701920", :in_reply_to_screen_name=>"partyprinter", :user=>{:id=>1234, :id_str=>"1234", :name=>"Test User", :screen_name=>"testuser"}, :entities=>{:hashtags=>[], :symbols=>[], :urls=>[{:expanded_url=>"http://lh4.googleusercontent.com/-LqwxKEVmxIk/AAAAAAAAAAI/AAAAAAAACdo/_Dy3_-4RgCA/s512-c/photo.jpg"}], :media=>[{:id=>370102691629760513, :media_url=>"http://testurl", :type=>"photo"}]})


  
  end

  it "should convert tweet time to local time"


  end

  it "should check the last 5 tweets" do
    allow_message_expectations_on_nil
    @tweetreader.stub(:twitter_authorisation)
    @tweeter.stub(:mentions_timeline) {[1,2,3,4,5,6,7,8,9]}
    expect(@tweetreader.get_recent_x_replies(5)).to eq([5,4,3,2,1])
  end

  it "should check each tweet is a reply and that it hasn't posted it" do
    Tweet.stub(:exists?) { true }
    expect(@tweetreader.check_if_reply_and_not_already_read(@example_tweet)).to be_false
    Tweet.stub(:exists?) { nil }
    expect(@tweetreader.check_if_reply_and_not_already_read(@example_tweet)).to be_true

    @example_tweet.user.update(:id => 1678701920)
    expect(@tweetreader.check_if_reply_and_not_already_read(@example_tweet)).to be_false

    @example_tweet.user.update(:id => 1234)
    expect(@tweetreader.check_if_reply_and_not_already_read(@example_tweet)).to be_true

    @example_tweet.update(:text => "@someotherprinter hullo")
    expect(@tweetreader.check_if_reply_and_not_already_read(@example_tweet)).to be_false

    @example_tweet.update(:text => "hullo @partyprinter")
    expect(@tweetreader.check_if_reply_and_not_already_read(@example_tweet)).to be_false
  end

  it "should check the type of tweet and choose processing accordingly" do

    Tubestatus.any_instance.stub(:process) { "tubestatus" }
    Bardscene.any_instance.stub(:process) { "bardscene" }

    @example_tweet.update(:text => "@partyprinter some text")
    expect(@tweetreader.check_tweet_type(@example_tweet)).to be_nil

    @example_tweet.update(:text => "@partyprinter bardscene")
    expect(@tweetreader.check_tweet_type(@example_tweet)).to eq("bardscene")

    @example_tweet.update(:text => "@partyprinter tubestatus")
    expect(@tweetreader.check_tweet_type(@example_tweet)).to eq("tubestatus")
  end

  it "should fetch images from tweet" do
    expect(@tweetreader.get_images_from(@example_tweet)).to eq(["http://lh4.googleusercontent.com/-LqwxKEVmxIk/AAAAAAAAAAI/AAAAAAAACdo/_Dy3_-4RgCA/s512-c/photo.jpg"])

    @example_tweet.urls[0].update(:expanded_url => "http://www.google.com")
    expect(@tweetreader.get_images_from(@example_tweet)).to eq([])

  end

  it "should write to database" do
    @tweetreader.write_to_database(@example_tweet)

    expect(Tweet.find(@example_tweet.id).text).to eq("some text http://testurl")

    Tweet.destroy(@example_tweet.id.to_i)
  end

  it "should write tweet to database when it reads a standard tweet" do
    allow_message_expectations_on_nil
    @tweetreader.stub(:twitter_authorisation)
    @tweeter.stub(:mentions_timeline) {[@example_tweet]}

    @tweetreader.fetch_tweets

    expect(Tweet.find(@example_tweet.id).text).to eq("some text http://testurl")

    Tweet.destroy(@example_tweet.id.to_i)
  end
end