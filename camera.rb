class Camera
  def initialize
    @zoom = 6.0
    @theta = 0.0  # angle from (0, 0, 1) within the xz plane
    @phi   = 0.0  # angle from xz plane
  end

  # Rotate around the z-axis
  def spin angle
    @theta += angle
    @theta -= 360.0 while @theta >=  360.0
    @theta += 360.0 while @theta <= -360.0
    glutPostRedisplay
  end

  # Rotate relative to the xz plane
  def pitch angle
    @phi += angle
    @phi = 89.0  if @phi >=  89.0
    @phi = -89.0 if @phi <= -89.0
    glutPostRedisplay
  end

  # Zoom away from the origin
  def zoom amount
    @zoom += amount

    @zoom = 1.0 if @zoom < 1.0
    glutPostRedisplay
  end

  # Recalculate the look-at
  def set
    x = Math.sin @theta * Math::PI / 180.0
    y = Math.sin @phi * Math::PI / 180.0
    z = Math.cos @theta * Math::PI / 180.0

    scale = @zoom / Math.sqrt(x * x + y * y + z * z)

    gluLookAt x * scale, y * scale, z * scale,
      0.0, 0.0, 0.0, 0.0, 1.0, 0.0
  end
end
