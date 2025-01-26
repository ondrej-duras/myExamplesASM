

export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: EXAMPLE_PE64DEMO.EXE

EXAMPLE_PE64DEMO.EXE: PE64DEMO.ASM
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} PE64DEMO.ASM EXAMPLE_PE64DEMO.EXE
	dir EXAMPLE_PE64DEMO.EXE

clean:
	rm EXAMPLE_PE64DEMO.EXE

ldd:
	ntldd EXAMPLE_PE64DEMO.EXE

# --- end ---

