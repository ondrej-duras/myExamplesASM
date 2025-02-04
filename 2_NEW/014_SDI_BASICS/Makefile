
export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: 1_win32sdi.exe

1_win32sdi.exe: a_win32sdi.asm
	${ASM} a_win32sdi.asm 1_win32sdi.exe
	dir 1_win32sdi.exe

clean:
	CMD.EXE /C DEL 1_win32sdi.exe

ldd:
	ntldd 1_win32sdi.exe

# --- end ---

