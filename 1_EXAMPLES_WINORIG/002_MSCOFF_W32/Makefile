

export INCLUDE=../../INCLUDE/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make w32 ...... to compile 32-bit only"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: w32

w32: 1_MSCOFF_W32.OBJ

1_MSCOFF_W32.OBJ: A_MSCOFF_W32.ASM
	${ASM} A_MSCOFF_W32.ASM 1_MSCOFF_W32.OBJ
	dir 1_MSCOFF_W32.OBJ

clean:
	CMD.EXE /C DEL 1_MSCOFF_W32.OBJ
	@echo "---"
	dir

ldd:
	ls -l
	@echo "---"
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	@echo "---"
	file  1_MSCOFF_W32.OBJ
	ntldd 1_MSCOFF_W32.OBJ

# --- end ---

