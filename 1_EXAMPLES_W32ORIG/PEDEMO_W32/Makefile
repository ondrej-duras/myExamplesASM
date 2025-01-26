


export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: EXAMPLE_PEDEMO.EXE

EXAMPLE_PEDEMO.EXE: PEDEMO.ASM
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} PEDEMO.ASM EXAMPLE_PEDEMO.EXE
	dir EXAMPLE_PEDEMO.EXE

clean:
	rm EXAMPLE_PEDEMO.EXE

ldd:
	ntldd EXAMPLE_PEDEMO.EXE

# --- end ---

