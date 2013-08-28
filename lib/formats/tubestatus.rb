require 'tube/status'


class Tubestatus < ActiveRecord::Base
  def extend_line_name(name)
    while name.length < 15
      name = " " + name
    end
    return name
  end

  def process
    tubestatuses = []
    tubestatus = Tube::Status.new
    tubestatus.lines.each {|line| tubestatuses << [line.name, line.status]}
    self.update(:statuses => tubestatuses)
  end

  def print


    @printer = MicroprinterSequence.new
    @imageprinter = ImageMicroprinter.new

    @printer.set_underline_on
    @printer.print_line "Tube status at #{Tweet.find(self.id).created_at}"
    @printer.set_underline_off

    self.statuses.each do |linestatus|
      @printer.set_font_weight_bold
      @printer.print "#{extend_line_name(linestatus[0])}:"
      @printer.set_font_weight_normal
      @printer.print " #{linestatus[1]}\n"
    end

    @printer.feed_and_cut
    @printer.write_sequence_to_database
    Tubestatus.destroy(self.id)
  end
end
