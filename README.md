# myExamplesASM

Collection of short Examples of source code written in Assembler (FASM x86 Windows for now only)

The Core is taken from FASM https://flatassembler.net/ .
Basically there they are none my sources yet.
I would like to learn assembly language again, so it work as a sendbox for me.
Here is a colletion of source codes I have recognized them as simple and yousefull for learning. 

## Dependencies
  1. the Flat Assembler binary FASM.EXE is included. It is taken from https://flatassembler.net/fasmw17332.zip
  2. to work more comfortable I preffer to help myself by "make" utility to compile everything here,
  3. so each example is in separate subdirectory
  4. each example has its own Makefile
  5. except the FASM.EXE you need ntldd.exe and make.exe utility
  6. very fine is to have a git toolkit as well.
  7. NTLDD is taken from https://github.com/LRN/ntldd.git 
  8. NTLDD.EXE is compiled by mingw-w64
  9. for now the "make" utility is taken from https://gnuwin32.sourceforge.net/packages/make.htm
 10. a Git is taken by comman winget install Git.Git --location c:\<Prefferd_DIR>

## Structure
  Both Linux and Windows sources are going to be included winth one directory structure.
  May be, if possible of course, I will add other platform, such as ARM here also.
  Why ? ... because this is one collection of examples with the one common keyword ...the "Assembler"
  So ... if you copy them on Windows ... then you can compile and try windows related sources.
  And others are for reading only.
  Vice versa, if you copy them on Linux, of course, you can compile and try Linux related sources only.
  In a future, the Makefile will become resposible to warn you, wheter the example is applicable
  on your platform or not.

