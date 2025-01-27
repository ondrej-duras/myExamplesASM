

export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make w64 ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: w64

w64: 1_WIN64AVX.EXE

1_WIN64AVX.EXE: A_WIN64AVX.ASM
	${ASM} A_WIN64AVX.ASM 1_WIN64AVX.EXE
	dir 1_WIN64AVX.EXE

clean:
	CMD.EXE /C DEL 1_WIN64AVX.EXE
	@echo "---"
	dir

ldd:
	ls -l
	@echo "---"
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	@echo "---"
	file  1_WIN64AVX.EXE
	ntldd 1_WIN64AVX.EXE


# --- end ---

