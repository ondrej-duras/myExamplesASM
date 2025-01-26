


export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: EXAMPLE_USECOM.EXE

EXAMPLE_USECOM.EXE: USECOM.ASM
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} USECOM.ASM EXAMPLE_USECOM.EXE
	dir EXAMPLE_USECOM.EXE

clean:
	rm EXAMPLE_USECOM.EXE

ldd:
	ntldd EXAMPLE_USECOM.EXE

# --- end ---

