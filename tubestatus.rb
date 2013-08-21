require 'tube/status'
require './queue.rb'

class Tubestatus < ActiveRecord::Base

  def extend_line_name(name)
    while name.length < 15
      name = " " + name
    end
    return name
  end

  def process(item)
    statuses = []
    tubestatus = Tube::Status.new
    tubestatus.lines.each {|line| statuses << [extend_line_name(line.name), line.status]}
    Tubestatus.create(:id => item.id.to_s, :statuses => statuses)
  end

  def print

    @printer.set_underline_on
    @printer.print_line "Tube status at #{self.created_at}"
    @printer.set_underline_off

    self.statuses.each do |linestatus|
      @printer.set_font_weight_bold
      @printer.print "#{linestatus[0]}:"
      @printer.set_font_weight_normal
      @printer.print " #{linestatus[1]}\n"
    end

    @printer.feed_and_cut
    Tubestatus.destroy(tweet_id)
  end

end