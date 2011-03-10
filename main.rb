require "opengl"
require "turtle"
require "lsystem"
require "camera"
require "gl_helpers"

include Gl, Glu, Glut, GlHelpers

$width = 500
$height = 500
$lights = true
$offset_x, $offset_y = 0.0, 0.0

LSYSTEM_LIST = 1
ADJUST = 0.2

def init
  glClearColor 0.0, 0.0, 0.0, 0.0
  glClearDepth 1.0
  glDepthFunc GL_LEQUAL
  glEnable GL_DEPTH_TEST
  glShadeModel GL_SMOOTH
  $turtle = Turtle.new
  $turtle.width = 0.2
  $lsystem = LSystem.new ARGV[0]
  $lsystem.turtle = $turtle
  $camera = Camera.new

  # set up the light
  glLight GL_LIGHT1, GL_AMBIENT, BLACK
  glLight GL_LIGHT1, GL_DIFFUSE, LIGHT_GRAY
  glLight GL_LIGHT1, GL_SPECULAR, WHITE
  glLight GL_LIGHT1, GL_POSITION, [0.0, 5.0, 5.0, 1.0]
  glEnable GL_LIGHT1
  glEnable GL_LIGHTING
  glColorMaterial GL_FRONT_AND_BACK, GL_EMISSION
  glEnable GL_COLOR_MATERIAL

  build_list
end

def build_list
  glNewList LSYSTEM_LIST, GL_COMPILE
  $lsystem.reset
  $lsystem.execute
  glEndList
end

reshape = lambda do |w, h|
  $width, $height = w, h

  glViewport 0, 0, $width, $height

  projection
  ident
  gluPerspective 60.0, $width.to_f / $height.to_f, 1.0, 100.0

  model_view
  ident
end

display = lambda do
  glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
  ident
  glTranslate $offset_x, $offset_y, 0.0
  $camera.set
  glCallList LSYSTEM_LIST
  
  swap
end

keyboard = lambda do |key, x, y|
  case key
  when ?\e
    exit
  when ?l
    $lights = !$lights
    if $lights
      glEnable GL_LIGHTING
    else
      glDisable GL_LIGHTING
    end
  when ?z
    $camera.zoom -ADJUST
  when ?Z
    $camera.zoom ADJUST
  when ?8
    $offset_y -= ADJUST
    glutPostRedisplay
  when ?4
    $offset_x += ADJUST
    glutPostRedisplay
  when ?6
    $offset_x -= ADJUST
    glutPostRedisplay
  when ?2
    $offset_y += ADJUST
    glutPostRedisplay
  end
end

special = lambda do |key, x, y|
  case key
  when GLUT_KEY_LEFT
    $camera.spin 5.0
  when GLUT_KEY_RIGHT
    $camera.spin -5.0
  when GLUT_KEY_UP
    $camera.pitch 5.0
  when GLUT_KEY_DOWN
    $camera.pitch -5.0
  end
end

glutInit
glutInitDisplayMode GLUT_DOUBLE | GLUT_RGB
glutInitWindowSize $width, $height
glutInitWindowPosition 100, 100
glutCreateWindow "3D L-Systems"

init

glutDisplayFunc display
glutKeyboardFunc keyboard
glutSpecialFunc special
glutReshapeFunc reshape
glutMainLoop
