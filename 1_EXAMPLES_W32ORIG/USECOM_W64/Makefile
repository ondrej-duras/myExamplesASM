

export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: EXAMPLE_USECOM64.EXE

EXAMPLE_USECOM64.EXE: USECOM64.ASM
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} USECOM64.ASM EXAMPLE_USECOM64.EXE
	dir EXAMPLE_USECOM64.EXE

clean:
	rm EXAMPLE_USECOM64.EXE

ldd:
	ntldd EXAMPLE_USECOM64.EXE

# --- end ---

