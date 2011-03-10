module GlHelpers
  COLOURS = %w[red blue green white black magenta cyan yellow brown dark_green 
               pink]
  def blue;       glColor  0.0,  0.0,  1.0; end
  def black;      glColor  0.0,  0.0,  0.0; end
  def white;      glColor  1.0,  1.0,  1.0; end
  def red;        glColor  1.0,  0.0,  0.0; end
  def green;      glColor  0.0,  1.0,  0.0; end
  def yellow;     glColor  1.0,  1.0,  0.0; end
  def cyan;       glColor  0.0,  1.0,  1.0; end
  def magenta;    glColor  1.0,  0.0,  1.0; end
  def brown;      glColor 0.37, 0.15, 0.07; end
  def dark_green; glColor  0.0,  0.2,  0.0; end
  def pink;       glColor  1.0,  0.5,  0.5; end

  # Just a list of short-names for some of the the openGl calls
  def ident; glLoadIdentity; end
  def swap; glutSwapBuffers; end
  def projection; glMatrixMode GL_PROJECTION; end
  def model_view; glMatrixMode GL_MODELVIEW; end

  def rectangle x, y, w, h
    glVertex x, y, 0.0
    glVertex x + w, y, 0.0
    glVertex x + w, y + h, 0.0
    glVertex x, y + h, 0.0
  end

  RED        = [1.0, 0.0, 0.0]
  BLUE       = [0.0, 0.0, 1.0]
  GREEN      = [0.0, 1.0, 0.0]
  WHITE      = [1.0, 1.0, 1.0]
  BLACK      = [0.0, 0.0, 0.0]
  CYAN       = [0.0, 1.0, 1.0]
  YELLOW     = [1.0, 1.0, 0.0]
  MAGENTA    = [1.0, 0.0, 1.0]
  LIGHT_GRAY = [0.8, 0.8, 0.8]
end
