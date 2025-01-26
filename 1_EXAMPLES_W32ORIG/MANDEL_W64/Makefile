


export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: EXAMPLE_MANDEL.EXE

EXAMPLE_MANDEL.EXE: MANDEL.ASM DDRAW64.INC
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} MANDEL.ASM EXAMPLE_MANDEL.EXE
	dir EXAMPLE_MANDEL.EXE

clean:
	rm EXAMPLE_MANDEL.EXE

ldd:
	ntldd EXAMPLE_MANDEL.EXE

# --- end ---

