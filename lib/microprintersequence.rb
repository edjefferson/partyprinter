require 'pg'

class MicroprinterSequence < Array

  COMMAND = 0x1B
  FULLCUT = 0x69
  PARTIALCUT = 0x6D
  PRINT_MODE = 0x21
  DOUBLEPRINT = 0x47
  UNDERLINE = 0x2D
  FEED_RATE = 0x33

  COMMAND_IMAGE = 0x2A

  COMMAND_BARCODE = 0x1D
  COMMAND_BARCODE_PRINT = 0x6B
  COMMAND_BARCODE_WIDTH = 0x77
  COMMAND_BARCODE_HEIGHT = 0x68
  COMMAND_BARCODE_TEXTPOSITION = 0x48
  COMMAND_BARCODE_FONT = 0x66

  BARCODE_WIDTH_NARROW = 0x02
  BARCODE_WIDTH_MEDIUM = 0x03
  BARCODE_WIDTH_WIDE = 0x04

  BARCODE_TEXT_NONE = 0x00
  BARCODE_TEXT_ABOVE = 0x01
  BARCODE_TEXT_BELOW = 0x02
  BARCODE_TEXT_BOTH = 0x03

  BARCODE_MODE_UPCA = 0x00
  BARCODE_MODE_UPCE = 0x01
  BARCODE_MODE_JAN13AEN = 0x02
  BARCODE_MODE_JAN8EAN = 0x03
  BARCODE_MODE_CODE39 = 0x04
  BARCODE_MODE_ITF = 0x05
  BARCODE_MODE_CODEABAR = 0x06
  BARCODE_MODE_CODE128 = 0x07

  NEW_LINE = 0x0A


  
  def initialize
    @con = PG.connect ENV['HOST'],"5432","","",ENV['DB'],ENV['USER'],ENV['PASSWORD']
  end
  
  def print(text)
    push text
  end
    


  # Standard font: 42 characters per line if using 80mm paper  
  def set_character_width_normal
    set_print_mode 0
    set_linefeed_rate 55
  end

  def set_character_width_narrow
    set_print_mode 1
    set_linefeed_rate 40
  end

  def set_print_mode(i)
    push COMMAND
    push PRINT_MODE
    push i
  end
  

  def set_font_weight_bold
    set_double_print(0x01)
  end

  def set_font_weight_normal
    set_double_print(0x00)
  end
  
  def set_double_print(i)
    push COMMAND
    push DOUBLEPRINT 
    push i
  end 

  def set_underline_on 
    set_underline(1)
  end

  def set_underline_off 
    set_underline(0)
  end

  def set_underline(i) # n = 0, 1 or 2 dot underline
    push COMMAND
    push UNDERLINE
    push i
  end

  def print_line(text)
    print("#{text}\n")
  end

  def feed_and_cut # utility method. 
    set_linefeed_rate 55
    feed
    cut
  end
  
  def print_and_cut(text) # utility method. print line (or array of lines) then feed & cut
    print_line(text)
    feed_and_cut
  end

  def feed()
    push COMMAND
    push NEW_LINE
    push COMMAND
    push NEW_LINE

  end

  def cut()
    push COMMAND
    push FULLCUT
  end

  def partial_cut()
    push COMMAND
    push PARTIALCUT
  end

  def print_barcode(barcode, barcode_mode = BARCODE_MODE_CODE39)
    push COMMAND_BARCODE
    push COMMAND_BARCODE_PRINT
    push barcode_mode 
    print barcode
    push 0x00
  end

  def set_barcode_height(height) # in dots. default = 162
    height = 0 if (height.to_i < 0)
    push COMMAND_BARCODE
    push COMMAND_BARCODE_HEIGHT
    push height.to_i
  end

  def set_barcode_width(width) 
    push COMMAND_BARCODE
    push COMMAND_BARCODE_WIDTH
    push width
  end

  def set_barcode_text_position(position) 
    position = 0 if (position.to_i < 0)
    position = 3 if (position.to_i > 3)
    push COMMAND_BARCODE 
    push COMMAND_BARCODE_TEXTPOSITION
    push position
  end
  
  def set_linefeed_rate(rate) #def = 22?
    push COMMAND 
    push FEED_RATE
    push rate 
  end

  def print_image_bytes(mode, data) # mode = 0, 1, 20, 21
    commandstring = ""
    puts "print image"
    density = 1
    density = 3 if (mode > 1) 
    datalength = data.length / density
    commandstring << COMMAND
    commandstring << COMMAND_IMAGE
    commandstring << mode 
    commandstring << datalength%256
    commandstring << datalength/256
    data.each do |x|
      commandstring << x
    end
    push commandstring
  end


  
  def write_sequence_to_database
    puts "hello"
  
    @con.query "INSERT INTO sequences (id, sequence, printed) VALUES (DEFAULT,'{#{self.join(",")}}',DEFAULT);"
  end


  def build_test_sequence
    print_and_cut("Printer is connected.")
    write_sequence_to_database
  end

end

