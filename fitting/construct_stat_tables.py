#!/usr/bin/python 

import sys



def import_data( filename ):
    with open(filename) as f:
    str = f.read()
    str = re.sub("\n", " ", str )
    list = np.array(str.split( ' ', ) ).reshape( 12,-1)
    print( list )
    return list









# Define a main() function that prints a little greeting.
def main():
  # Get the name from the command line, using 'World' as a fallback.
  if len(sys.argv) >= 2:
    name = sys.argv[1]
  else:
    name = 'World'
  print 'Hello', name


# This is the standard boilerplate that calls the main() function.
if __name__ == '__main__':
  main()
