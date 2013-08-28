require 'serialport'

port_str = "/dev/ttyACM0"
    @port_str = port_str 
    baud_rate = 9600
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE
    @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    @sp.flow_control = 2
    @sp.sync = true
    sleep(2)





while true
  i = gets.chomp
  if i == "cmd"
    @sp.putc 0x1B
  elsif i == "img"
    @sp.putc 0x2A
  elsif i == "feed"
    @sp.putc 0x0A
  elsif i == "feedrate"
    @sp.putc 0x33
  elsif i == "cut"
    @sp.putc 0x1B
    @sp.putc 0x69
  else
    @sp.putc i
  end
end
