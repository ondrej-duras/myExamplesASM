


export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make w64 ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: w64 

w64: 1_MANDEL_W64.EXE

1_MANDEL_W64.EXE: A_MANDEL_W64.ASM B_DDRAW64.INC
	${ASM} A_MANDEL_W64.ASM 1_MANDEL_W64.EXE
	dir 1_MANDEL_W64.EXE

clean:
	CMD.EXE /C DEL 1_MANDEL_W64.EXE
	@echo "---"
	dir

ldd:
	ls -l	
	@echo "---"
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	@echo "---"
	file  1_MANDEL_W64.EXE
	ntldd 1_MANDEL_W64.EXE

# --- end ---

