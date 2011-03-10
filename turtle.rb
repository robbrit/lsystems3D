require "opengl"
require "ruby-debug"
require "quaternion"

include Gl, Glu, Glut

TINY_BIT = 2.0**-16
RESOLUTION = 16

class Turtle
  attr_accessor :width

  def initialize
    reset
    @last_width = @width = 1.0
    @quad = gluNewQuadric
    gluQuadricNormals @quad, GLU_SMOOTH
  end

  def width= width
    @last_width = @width = width
  end

  def reset
    @polygon_mode = false
    @last_heading = nil
    @stack = []
    @x, @y, @z = 0, 0, 0
    @up = [-1.0, 0.0, 0.0]
    @heading = [0.0, 1.0, 0.0]
    @left = [0.0, 0.0, -1.0]
    calc_angle
  end

  def forward size, line = true
    if @polygon_mode
      glVertex @x, @y, @z
    else
      if line
        glPushMatrix
        glTranslate @x, @y, @z

        # Rotate around the cross product of the
        # z-axis and the current orientation, by
        # the angle between the two vectors
        glRotate @angle, -@heading[1], @heading[0], 0.0
        gluCylinder @quad, @last_width, @width, size, RESOLUTION, RESOLUTION
        glPopMatrix
      end
    end

    @x += @heading[0] * size
    @y += @heading[1] * size
    @z += @heading[2] * size
  end

  def calc_angle
    @angle = Math.acos(@heading[2] /
                       Math.sqrt(@heading[0] * @heading[0] + @heading[1] * @heading[1] + @heading[2] * @heading[2])) / Math::PI * 180.0
  end

  def push
    @stack.push [@x, @y, @z, @heading, @up, @left, @width, @last_width, @colour]
  end

  def pop
    @x, @y, @z, @heading, @up, @left, @width, @last_width, @colour = @stack.pop
    colour @colour
    calc_angle
  end

  def yaw angle; rot angle, *@up; end
  def roll angle; rot angle, *@heading; end
  def pitch angle; rot angle, *@left; end

  def rot angle, ax, ay, az
    # simple quaternion rotation
    quat = Quaternion.rotation(angle * Math::PI / 180.0, ax, ay, az)
    quati = quat.conj

    @heading, @up, @left =
      (quat * @heading * quati).to_vector3,
      (quat * @up * quati).to_vector3,
      (quat * @left * quati).to_vector3

    normalize
    calc_angle
  end

  def normalize
    [@heading, @up, @left].each do |v|
      mv = Math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2])
      (0..2).each do |i|
        v[i] /= mv
        #v[i] = 0.0 if v[i] < TINY_BIT
      end
    end
  end

  def colour what
    if COLOURS.index(what)
      @colour = what
      self.send what
    end
  end

  def dec_width width_inc = 0.1
    @last_width = @width
    @width -= width_inc if @width > width_inc
  end

  def start_polygon
    @polygon_mode = true
    glBegin GL_POLYGON
  end

  def end_polygon
    glEnd
    @polygon_mode = false
  end
end
