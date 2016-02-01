#!/bin/env python
import sys
from requests import post
import binascii

class _Getch:
    """Gets a single character from standard input.  Does not echo to the
screen."""
    def __init__(self):
        try:
            self.impl = _GetchWindows()
        except ImportError:
            self.impl = _GetchUnix()

    def __call__(self): return self.impl()


class _GetchUnix:
    def __init__(self):
        import tty, sys

    def __call__(self):
        import sys, tty, termios
        fd = sys.stdin.fileno()
        old_settings = termios.tcgetattr(fd)
        try:
            tty.setraw(sys.stdin.fileno())
            ch = sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
        return ch


class _GetchWindows:
    def __init__(self):
        import msvcrt

    def __call__(self):
        import msvcrt
        return msvcrt.getch()

def sendKey(key,host):
  try:
    r = post('http://{host}:8060/keypress/{key}'.format(host=host,key=key), data='')
  except Exception as e:
    print e
  if r.status_code == 200:
    print "sent {key}".format(key=key)
  else:
    print "error: {error} - {message}".format(error=r.status_code,message=r.content)

def main(host):
  getch = _Getch()
  result = getch()
  #print result
  if result == "q":
    print "Exiting..."
    sys.exit(0)
  if result == "\x1b":
    getch()
    arrow = getch()
    if arrow == "A":
      key = "up"
      sendKey(key,host)
    elif arrow == "B":
      key = "down"
      sendKey(key,host)
    elif arrow == "C":
      key = "right"
      sendKey(key,host)
    elif arrow == "D":
      key = "left"
      sendKey(key,host)
  else:
    try:
      key = binascii.b2a_uu(result).strip()
      #print key
      if key == "!(":
        key = "play"
        sendKey(key,host)
      elif key == "!#0":
        key = "select"
        sendKey(key,host)
      elif key == "!?P":
        key = "back"
        sendKey(key,host)
      elif key == "!+":
        key = "rev"
        sendKey(key,host)
      elif key == "!+@":
        key = "fwd"
        sendKey(key,host)
      elif key == "! P":
        sys.exit(0)
      elif result == "h" or result == "H":
        key = "home"
        sendKey(key,host)
      elif key == "!/P":
        print "Help:"
        print "Arrows - Up, Down, Left, Right"
        print "Enter - Select"
        print "Space - Play/Pause"
        print "Backspace - Back"
        print "h - Home"
        print ", - Rewind"
        print ". - Fast Forward"
        print "? - Help"
        print "q - Quit"
      else:
        print "Unknown key - use ? for help"
    except Exception as e:
      print e

if __name__ == '__main__':
  if len(sys.argv) < 2:
    print "usage: furoku.pl <roku ip>"
    sys.exit(1)
  host = sys.argv[1]
  print "type ? to display help"
  try:
    while True:
      main(host)
  except KeyboardInterrupt:
    pass
  finally:
    sys.exit(0)
