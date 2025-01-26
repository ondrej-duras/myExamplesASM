

export INCLUDE=../../INCLUDE/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to prepare binaries"
	@echo "  make clean .... to delete binaries"
	@echo "  make ldd ...... to check dependencies"

all: EXAMPLE_MSCOFF.EXE

EXAMPLE_MSCOFF.EXE: MSCOFF.ASM
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} MSCOFF.ASM EXAMPLE_MSCOFF.EXE
	dir EXAMPLE_MSCOFF.EXE

clean:
	rm EXAMPLE_MSCOFF.EXE

ldd:
	ntldd EXAMPLE_MSCOFF.EXE

# --- end ---

