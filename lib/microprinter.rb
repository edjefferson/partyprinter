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

  def initialize(test = 0, port_str = "/dev/ttyACM0")
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
    instructions = sequence[1..-2].split(",").map {|x| x.to_i}

    instructions.each_with_index do |step, index|
      if step == 27
        nextstep = instructions[index + 1]
        if nextstep == 42
          @sp.putc step
          @sp.putc nextstep
          @sp.putc instructions[index + 2]
          @sp.putc instructions[index + 3]
          @sp.putc instructions[index + 4]
        end
      elsif instructions[index - 1] == 27 || instructions[(index - 2)..(index -4)].include?(42)
        nil
      else
        @sp.putc step
        sleep 0.005
      end
    end
  end

end
p