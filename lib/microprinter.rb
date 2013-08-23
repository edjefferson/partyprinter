require 'serialport'
require 'pg'

class Microprinter

  def initialize(port_str = "/dev/ttyACM0")
    @con = PG.connect ENV['HOST'],"5432","","",ENV['DB'],ENV['USER'],ENV['PASSWORD']
    @port_str = port_str 
    baud_rate = 9600
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE
    @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    @sp.sync = true
    sleep(2)
  end

  def check_buffer
    unprinted_sequences = @con.query "SELECT * FROM sequences WHERE printed = 0"

    unprinted_sequences.each do |sequence|
      print(sequence["sequence"])
      @con.query "UPDATE sequences SET printed = 1 WHERE id = {#sequence["id"]}"
    end
  end

  
  def print(sequence)
    sequence.each do |instruction|
      if instruction == "BS"
        sleep 0.01
      elsif instruction == "LS"
        sleep 0.002
      elsif instruction.class == String
        @sp.print instruction
      else
        @sp.putc instruction
      end
    end
  end

end
