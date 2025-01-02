
export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ..... prepare binary"
	@echo "  make clean ... delete binary"
	@echo "  make ldd ..... for dependecies"

all: EXAMPLE_DDRAW.EXE

EXAMPLE_DDRAW.EXE: DDRAW.ASM
	@echo "ASM=${ASM}"
	@echo "INCLUDE=${INCLUDE}"
	${ASM} DDRAW.ASM EXAMPLE_DDRAW.EXE
	dir EXAMPLE_DDRAW.EXE

clean:
	rm EXAMPLE_DDRAW.EXE

ldd:
	ls -l
	ntldd EXAMPLE_DDRAW.EXE

# --- end ---

