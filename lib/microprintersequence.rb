require 'pg'
require 'RMagick'
include Magick

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

  def big_sleep
    push(9999)
  end

  def little_sleep
    push(999)
  end
  
  def print(text)
    text.bytes.to_a.each {|char| push char }
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
    big_sleep
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
    big_sleep
  end

  def print_line(text)
    print("#{text}\n")
    big_sleep
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
    push 10
    push 10
    push 10
    push 10
    big_sleep
  end

  def cut()
    push COMMAND
    push FULLCUT
    big_sleep
  end

  def partial_cut()
    push COMMAND
    push PARTIALCUT
    big_sleep
  end

  def print_barcode(barcode, barcode_mode = BARCODE_MODE_CODE39)
    push COMMAND_BARCODE
    push COMMAND_BARCODE_PRINT
    push barcode_mode 
    print barcode
    push 0x00
    big_sleep
  end

  def set_barcode_height(height) # in dots. default = 162
    height = 0 if (height.to_i < 0)
    push COMMAND_BARCODE
    push COMMAND_BARCODE_HEIGHT
    push height.to_i 
    big_sleep
  end

  def set_barcode_width(width) 
    push COMMAND_BARCODE
    push COMMAND_BARCODE_WIDTH
    push width
    big_sleep
  end

  def set_barcode_text_position(position) 
    position = 0 if (position.to_i < 0)
    position = 3 if (position.to_i > 3)
    push COMMAND_BARCODE 
    push COMMAND_BARCODE_TEXTPOSITION
    push position 
    big_sleep
  end
  
  def set_linefeed_rate(rate) #def = 22?
    push COMMAND 
    push FEED_RATE 
    push rate 
    big_sleep
  end

  def print_image_bytes(mode, data) # mode = 0, 1, 20, 21
    puts "print image"
    density = 1
    density = 3 if (mode > 1) 
    datalength = data.length / density
    puts self.length
    push COMMAND_BARCODE_TEXTPOSITION
    push COMMAND_IMAGE
    puts self.class
    puts self.length
    push mode 
    push datalength%256
    push datalength/256
    puts self.length
    data.each do |x|
      push x 
      little_sleep
    end
    puts self.length
    big_sleep
  end

  def print_image(image_path, dither = true, mode = 0, border = 5)

    puts "printing image(s)"
    width = 288
    width = 576 if mode == 1 or mode == 21

    self.set_linefeed_rate(1)
    
    image = ImageList.new(image_path).first
    #puts "cols = #{image.columns} rows = #{image.rows}"
=begin
    #if it's wider than max and wider than it is tall, rotate it
    if image.columns > width 
      rotated_image = image.rotate(90, ">")
      image = rotated_image if rotated_image
      puts "cols = #{image.columns} rows = #{image.rows}"
    end
=end
    # apply fudge to fix elongated printout. 
    case mode
      when 0,20 then image = image.resize(image.columns, (0.69 * image.rows).to_i)
      when 1,21 then image = image.resize(image.columns, (0.345 * image.rows).to_i)
    end
    #puts "cols = #{image.columns} rows = #{image.rows}"
    
    # enlarge canvas to width if it's smaller

    if image.columns < width 
      #puts "enlarging canvas"
      bigger_canvas = Image.new(width, image.rows)
      image = bigger_canvas.composite(image, Magick::WestGravity, OverCompositeOp)
    end
  
    if (border > 0) 
      image = image.border(border,border,"black")
    end

    #reduce to max width if it's larger
    if image.columns > width 
      puts "resizing"
      image = image.resize_to_fit(width, 2000)
      #puts "cols = #{image.columns} rows = #{image.rows}"
    end
  
    rows = image.rows
    cols = image.columns
    #puts "cols = #{cols} rows = #{rows}"
  
    if dither
      image = image.quantize(2, Magick::GRAYColorspace)
    else
      #image = image.threshold(MaxRGB*0.5) #quantize is better
      image = image.quantize(2, Magick::GRAYColorspace, Magick::NoDitherMethod)
    end

    rows = image.rows
    cols = image.columns
    #puts "cols = #{cols} rows = #{rows}"

    rowlimit = 8
    rowlimit = 24 if mode > 1
    lbuffer = Array.new
    rows.times do |y|
      cbuffer = Array.new
      cols.times do |x|
        pixel = image.pixel_color(x, y)
        #puts "#{x}\t#{y}\t#{pixel}"
        if (pixel.red.to_i == MaxRGB) 
          cbuffer.push(1)
        else
          cbuffer.push(0)
        end
      end
      lbuffer.push(cbuffer)
      if lbuffer.length == rowlimit
        #puts (lbuffer.to_s)
        print_image_row(mode, lbuffer)
        lbuffer = Array.new
      end
    end
    
    for i in (0 .. rowlimit - lbuffer.length)
      cbuffer = Array.new()
      for j in (0 .. width) 
        cbuffer.push(1)
      end
      lbuffer.push(cbuffer)
    end
    print_image_row(mode, lbuffer)
    
    self.set_linefeed_rate(22)
    self.feed
    self.feed
    # image.display # display on screen (requires X11. Useful for debugging)
    image.destroy! # tidy up after ourselves
  end

  def print_image_row(mode, data)
    bytes = Array.new
    if mode < 2
      for x in (0..data[0].length - 1)
        byte_column = data[0][x] << 7|data[1][x] << 6|data[2][x] << 5|data[3][x] << 4|data[4][x] << 3|data[5][x] << 2|data[6][x] << 1|data[7][x]
        bytes.push(byte_column ^ 255)
      end
    else 
      for x in (0..data[0].length - 1)
        byte_column = data[0][x] << 7|data[1][x] << 6|data[2][x] << 5|data[3][x] << 4|data[4][x] << 3|data[5][x] << 2|data[6][x] << 1|data[7][x]
        bytes.push(byte_column ^ 255)
        byte_column = data[8][x] << 7|data[9][x] << 6|data[10][x] << 5|data[11][x] << 4|data[12][x] << 3|data[13][x] << 2|data[14][x] << 1|data[15][x]
        bytes.push(byte_column ^ 255)
        byte_column = data[16][x] << 7|data[17][x] << 6|data[18][x] << 5|data[19][x] << 4|data[20][x] << 3|data[21][x] << 2|data[22][x] << 1|data[23][x]
        bytes.push(byte_column ^ 255)
      end
    end
    
    
    print_image_bytes(mode, bytes)
  end
  
  def write_sequence_to_database
    sequence = self.map!{|step| step.to_i}.join(",")

    puts sequence
    
    puts "hello"
  
    @con.query "INSERT INTO sequences (id, sequence, printed) VALUES (DEFAULT,'{#{sequence}}',DEFAULT);"
  end


  def build_test_sequence
    print_and_cut("Printer is connected.")
    write_sequence_to_database
  end

end

