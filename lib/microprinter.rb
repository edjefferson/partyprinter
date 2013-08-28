require 'serialport'
require 'pg'

class SerialPortTest
  def putc x
     $stdout.putc x
  end

  def print x
     $stdout.print x
  end

  def flush
     $stdout.flush
  end

  def close
  end
end

class Microprinter

  def initialize(test = 0, port_str = "/dev/ttyAMA0")
    @con = PG.connect ENV['HOST'],"5432","","",ENV['DB'],ENV['USER'],ENV['PASSWORD']
    if test == 0
      @port_str = port_str 
      baud_rate = 9600
      data_bits = 8
      stop_bits = 1
      parity = SerialPort::NONE
      @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
      @sp.flow_control = 2
      @sp.sync = true
      sleep(2)
    else
      @sp = SerialPortTest.new
    end
  end

  def close
    @sp.flush
    @sp.close
  end 

  def check_buffer
    unprinted_sequences = @con.query "SELECT * FROM sequences WHERE printed = 0"

    unprinted_sequences.each do |sequence|
      puts sequence
      print(sequence["sequence"])
      @con.query "UPDATE sequences SET printed = 1 WHERE id = #{sequence['id']}"
    end
  end


  
  def print(sequence)
    sequence[1..-2].split(",").each_with_index do |instruction, index|
      step = instruction.to_i
      if step == 27
        @sp.putc step
        sleep 1
      elsif step == 45 && step[index - 1] == 27
        @sp.putc step
        sleep 1
      else
        @sp.putc step
        @sp.flush
        sleep 1
      end
    end
  end

end
