

export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: 1_WIN32CONSOLE.EXE

1_WIN32CONSOLE.EXE: A_WIN32CONSOLE.ASM
	fasm  A_WIN32CONSOLE.ASM 1_WIN32CONSOLE.EXE

clean:
	CMD.EXE /C DEL 1_WIN32CONSOLE.EXE

ldd:
	ntldd 1_WIN32CONSOLE.EXE

# --- end ---

