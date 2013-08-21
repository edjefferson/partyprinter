require_relative '../queue.rb'
require 'spec_helper'



describe Queue do
  before(:each) do
    @queue = Queue.new
    @testitem = Tweet.new
  end

  it "should convert tweet time to local time" do

    expect(@queue.localtime("2013-08-21 16:53:53 UTC").to eq("bardscene")
  end



  end

  it "should detect the print format of the item" do
    Tubestatus.stub(:find) { "tubestatus" }
    Bardscene.stub(:find) { "bardscene" }

    @testitem.stub(:text) {"test 1234"}
    expect(@queue.get_format(@testitem)).to eq(@testitem)
    @testitem.stub(:text) {"tubestatus"}
    expect(@queue.get_format(@testitem)).to eq("tubestatus")
    @testitem.stub(:text) {"bardscene"}
    expect(@queue.get_format(@testitem)).to eq("bardscene")

  end

end

describe Tweet do
  it "should print a tweet" do
    @queue = Queue.new
    @tweet = Tweet.new


    expect(@tweet.print).to eq("bardscene")
  end
end