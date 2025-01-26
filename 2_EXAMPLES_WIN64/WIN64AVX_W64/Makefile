

export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: EXAMPLE_WIN64AVX.EXE

EXAMPLE_WIN64AVX.EXE: WIN64AVX.ASM
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} WIN64AVX.ASM EXAMPLE_WIN64AVX.EXE
	dir EXAMPLE_WIN64AVX.EXE

clean:
	rm EXAMPLE_WIN64AVX.EXE

ldd:
	ntldd EXAMPLE_WIN64AVX.EXE

# --- end ---

