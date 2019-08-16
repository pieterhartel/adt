# adt
Simple Algebraic Data Types for C
  
To compile the ADT tool unpack the tarball and type make.
There are a few warnings about missing previous declarations but
these can be ignored.

The last step of the compilation runs `adt` on its own specification
and compares the output to that provided in the tar ball. There should
not be any differences for the test.

`adt` has been tested under Linux and cygwin. For MacOS change `-lfl` to `-ll` in the Makefile.
