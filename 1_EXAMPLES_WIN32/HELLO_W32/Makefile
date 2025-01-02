


export INCLUDE=../../INCLUDE_WIN/
export ASM=../../fasm.exe

help:
	@echo "apply one of following:"
	@echo "  make all   ... to prepare the binary"
	@echo "  make clean ... to clear the binary"
	@echo "  make ldd ..... show library dependencies"

all: HELLO.ASM
	@echo "ASM=${ASM}"
	@echo "INCLUDE=${INCLUDE}"
	${ASM} HELLO.ASM HELLO.EXE
	@dir HELLO.EXE	

clean:
	rm HELLO.EXE

ldd:
	ntldd HELLO.EXE

# --- end ---

