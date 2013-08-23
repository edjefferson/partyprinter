require 'serialport'
require 'pg'

class Microprinter

  def initialize(port_str = "/dev/ttyACM0")
    #@pg.conn = (ENV['DATABASE'])
    @port_str = port_str 
    baud_rate = 9600
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE
    @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    @sp.sync = true
  end
  =begin
  def check_buffer
    unprinted_sequences = pg.query "select * from buffer"

    unprinted_sequences.each do |sequence|
      print(sequence)
      pg.query "delete from buffer"
    end
  end
  =end
  def print(sequence)
    @sp.print "big balls are"
    @sp.flush
    sequence.each do |instruction|
      if instruction == "BS"
        sleep 0.01
      elsif instruction == "LS"
        sleep 0.002
      else
        @sp.putc instruction
        @sp.print "big balls are"
        @sp.flush
      end
    end
  end

end
