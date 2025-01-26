


export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: EXAMPLE_MINIPAD.EXE

EXAMPLE_MINIPAD.EXE: MINIPAD.ASM MINIPAD.ICO
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} MINIPAD.ASM EXAMPLE_MINIPAD.EXE
	dir EXAMPLE_MINIPAD.EXE

clean:
	rm EXAMPLE_MINIPAD.EXE

ldd:
	ntldd EXAMPLE_MINIPAD.EXE

# --- end ---

