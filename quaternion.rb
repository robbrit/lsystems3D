class Quaternion
  attr_reader :a, :b, :c, :d

  # Create a quaternion for rotating by angle
  # around (x, y, z)
  def self.rotation angle, x, y, z
    sina = Math.sin(angle / 2.0)
    Quaternion.new(Math.cos(angle / 2.0),
                   x * sina,
                   y * sina,
                   z * sina)
  end
 
  def initialize a, b, c, d
    @a, @b, @c, @d = a, b, c, d
  end
 
  def norm
    Math.sqrt(@a * @a + @b * @b + @c * @c + @d * @d)
  end
 
  def -@
    Quaternion.new(-@a, -@b, -@c, -@d)
  end
 
  def conj
    Quaternion.new(@a, -@b, -@c, -@d)
  end

  def inv
    conj * (1.0 / (@a * @a + @b * @b + @c * @c + @b * @b))
  end
 
  def + q
    if q.is_a? Quaternion
      Quaternion.new(@a + q.a, @b + q.b, @c + q.c, @d + q.d)
    elsif q.is_a? Numeric
      Quaternion.new(@a + q, @b, @c, @d)
    else
      q + self
    end
  end
 
  def - q
    self + -q
  end
 
  def * q
    if q.is_a? Quaternion
      Quaternion.new(
        @a * q.a - @b * q.b - @c * q.c - @d * q.d,
        @a * q.b + @b * q.a + @c * q.d - @d * q.c,
        @a * q.c - @b * q.d + @c * q.a + @d * q.b,
        @a * q.d + @b * q.c - @c * q.b + @d * q.a)
    elsif q.is_a? Numeric
      Quaternion.new(@a * q, @b * q, @c * q, @d * q)
    elsif q.is_a? Array and q.length == 3
      # vector
      self * Quaternion.new(0, *q)
    else
      q * self
    end
  end
 
  def == q
    @a == q.a and @b == q.b and @c == q.c and @d == q.d
  end
 
  def to_s
    "(#{@a}, #{@b}, #{@c}, #{@d})"
  end

  def to_vector3
    [@b, @c, @d]
  end
 
  # this is Ruby's way of handling commutativity
  def coerce other
    return self, other
  end
end
