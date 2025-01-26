

export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: EXAMPLE_TEMPLATE64.EXE

EXAMPLE_TEMPLATE64.EXE: TEMPLATE64.ASM
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} TEMPLATE64.ASM EXAMPLE_TEMPLATE64.EXE
	dir EXAMPLE_TEMPLATE64.EXE

clean:
	rm EXAMPLE_TEMPLATE64.EXE

ldd:
	ntldd EXAMPLE_TEMPLATE64.EXE

# --- end ---


