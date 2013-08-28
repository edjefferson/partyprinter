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
      arrays = sequence["sequence"].split(";").map{|x| x.split(",")}
      arrays.each do |x|
        x.map! { |y| y.to_i.chr}
      end
      arrays.map! { |z| z.join }

      arrays.each {|x| print x}
      @con.query "UPDATE sequences SET printed = 1 WHERE id = #{sequence['id']}"
    end
  end


  
  def print(sequence)
      if sequence[0].ord == 25 && sequence [1].ord == 42
      @sp.print 25.chr + 42.chr
      sequence.split(//)[2..-1].each do |x|
        @sp.putc x
        sleep 0.002
      end
      sleep 0.002
    else
      @sp.print sequence
      sleep 0.002
    end
    
  end

end