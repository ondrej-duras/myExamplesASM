

#export INCLUDE=C:\mingw64\include\c++\14.2.0
#export CPP=C:\mingw64\usr\bin\cpp.exe
#export CPP=C:/mingw64/usr/bin/cpp.exe
export CPP=c:/Strawberry/c/bin/cpp.exe

help:
	@echo "Apply of of following:"
	@echo "  make all ..... to compile all tools"	
	@echo "  make rc  ..... to compile rc.exe only"
	@echo "  make resdump   to compile resdump.exe only"
	@echo "  make resobjdump to compile resobjdump.exe only"
	@echo "  make clean ... to delete .EXEs"
	@echo "  make ldd ..... to check binaries"


all: rc.exe resdump.exe resobjdump.exe

rc.exe: rc.cc
	${CPP} -std=c++14 -o rc.exe rc.cc -Wall -Wno-c++11-narrowing

resdump.exe: resdump.c
	gcc resdump.c -o resdump.exe
	strip resdump.exe
	dir resdump.exe

resobjdump.exe: resobjdump.c
	gcc resobjdump.c -o resobjdump.exe
	strip resobjdump.exe
	dir resobjdump.exe

clean:
	CMD.EXE /C DEL rc.exe
	CMD.EXE /C DEL resdump.exe
	CMD.EXE /C DEL resobjdump.exe


ldd:
	file  rc.exe
	ntldd rc.exe
	file  resdump.exe
	ntldd resdump.exe
	file  resobjdump.exe
	ntldd resobjdump.exe

# --- end ---

