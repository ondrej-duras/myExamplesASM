
export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: EXAMPLE_TEMPLATE.EXE

EXAMPLE_TEMPLATE.EXE: TEMPLATE.ASM
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} TEMPLATE.ASM EXAMPLE_TEMPLATE.EXE
	dir EXAMPLE_TEMPLATE.EXE

clean:
	rm EXAMPLE_TEMPLATE.EXE

ldd:
	ntldd EXAMPLE_TEMPLATE.EXE

# --- end ---

