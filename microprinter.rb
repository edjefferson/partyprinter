require 'serialport'
require 'pg'

class Microprinter

  def initialize(port_str = "/dev/ttyACM0")
    @pg.conn #connection details go here
    @port_str = port_str 
    baud_rate = 9600
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE
    @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    @sp.sync = true
    sleep(2)  # give arduino a chance to restart
  end

  def check_buffer
    print_sequence = pg.query "select * from buffer"

    print_sequence.each do |instruction|

      if instruction == "BS"
        sleep 0.01
      elsif instruction == "LS"
        sleep 0.001
      elsif instruction == "FL"
        sp.flush
      else
        sp.putc instruction
      end
      
    end

    pg.query "delete from buffer"
  end

end