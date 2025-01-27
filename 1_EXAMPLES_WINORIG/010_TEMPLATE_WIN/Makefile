
export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make w32 ...... to compile 32-bit only"
	@echo "  make w64 ...... to compile 64-bit only"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: w32 w64

w32: 1_TEMPLATE32.EXE

w64: 2_TEMPLATE64.EXE

1_TEMPLATE32.EXE: A_TEMPLATE32.ASM
	${ASM} A_TEMPLATE32.ASM 1_TEMPLATE32.EXE
	dir 1_TEMPLATE32.EXE

2_TEMPLATE64.EXE: B_TEMPLATE64.ASM
	${ASM} B_TEMPLATE64.ASM 2_TEMPLATE64.EXE
	dir 2_TEMPLATE64.EXE

clean:
	CMD.EXE /C DEL 1_TEMPLATE32.EXE
	CMD.EXE /C DEL 2_TEMPLATE64.EXE
	@echo "---"
	dir

ldd:
	ls -l
	@echo "---"
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	@echo "---"
	file  1_TEMPLATE32.EXE
	ntldd 1_TEMPLATE32.EXE
	file  2_TEMPLATE64.EXE
	ntldd 2_TEMPLATE64.EXE

# --- end ---

