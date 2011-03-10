require "rubygems"
require 'andand'

# This class is the meat of everything.
class LSystem
  attr_accessor :delta, :size, :turtle, :iterations, :base, :width, :width_inc,
                :initial_colour, :show_code
  attr_reader :current

  # Allow for American spelling
  def initial_color= col; initial_colour = col; end
  def initial_color; initial_colour; end

  def initialize rules_file
    seed = Time.now.to_i
    puts "Seeded with #{seed}."
    srand seed

    @delta = 90.0   # the angle for each turn
    @size = 1.0     # the size of each step
    @width = 0.5    # the radius of the cylinder
    @iterations = 1 # how many times to iterate
    @rules = {}     # rules
    @stochs = {}    # stochastic rules
    @colours = {}   # how to colour various rules
    @initial_colour = "white"
    @show_code = false

    File.open rules_file, "r" do |file|
      file.each do |line|
        next if line =~ /^\s*#/

        if line =~ /^\s*(\w)\s*(0\.\d+)?\s*->\s*(.+)\s*$/
          # rules have the form
          #  c -> expansion
          # or for stochastic rules:
          #  c 0.5 -> expansion
          if $2 != nil
            # stochastic rule
            if @stochs.key?($1)
              @stochs[$1] << [$2.to_f, $3.split(//)]
            else
              @stochs[$1] = [
                [$2.to_f, $3.split(//)]
              ]
            end
          else
            # deterministic rule
            @rules[$1] = $3.split(//)
          end
        elsif line =~ /^\s*(\w+)\s*=\s*(.+)\s*$/
          # parameters use the form
          #  param = value
          if self.respond_to?($1 + "=")
            self.send $1 + "=", $2
          end
        elsif line =~ /^colou?r\s+(\w)\s+(\w+)/i
          # setting a colour for a rule
          # colours have the form:
          #  colour X red
          @colours[$1] = $2.downcase
        end
      end
    end

    # convert the types of the parameters
    @iterations = @iterations.to_i
    @delta = @delta.to_f
    @width = @width.to_f
    @width_inc = @width_inc.to_f
    @size = @size.to_f
    @show_code = (@show_code =~ /^(true|yes)$/i)
    @current = @base
  end

  def reset
    @current = @base
    if @turtle
      @turtle.reset
      @turtle.width = @width
    end
  end

  def iterate
    # Run through the L-system once, expanding each
    # rule
    #
    @current = @current.split(//).map { |c|
      if @stochs.key?(c)
        # This is a stochastic rule
        which = rand
        @stochs[c].select do |(prob, rule)|
          if which < prob
            rule
          else
            which -= prob
            false
          end
        end.andand[1] || @stochs[c].last[1]
      elsif @rules.key?(c)
        # deterministic rule
        @rules[c]
      else
        # literals are just mapped to themselves
        c
      end
    }.flatten.join
  end

  def execute turtle = nil
    # Execute and draw the L-system
    puts "generating image..."
    @iterations.times { iterate }
    puts @current if @show_code

    turtle ||= @turtle
    turtle.colour @initial_colour

    puts "rendering..."

    @current.split(//).each do |c|
      case c
      when "+"
        turtle.yaw @delta
      when "-"
        turtle.yaw -@delta
      when "&"
        turtle.pitch -@delta
      when "^"
        turtle.pitch @delta
      when "\\"
        turtle.roll @delta
      when "/"
        turtle.roll -@delta
      when "|"
        turtle.yaw 180.0
      when "F"
        turtle.forward @size
      when "f"
        turtle.forward @size, false
      when "["
        turtle.push
      when "]"
        turtle.pop
      when "{"
        turtle.start_polygon
      when "}"
        turtle.end_polygon
      when "!"
        turtle.dec_width @width_inc
      else
        if @colours.key?(c)
          turtle.colour @colours[c]
        end
      end
    end
  end
end
