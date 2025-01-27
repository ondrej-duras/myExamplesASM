
export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ....... to compile"
	@echo "  make w32 ....... to compile 32-bit only"
	@echo "  make clean ..... to delete"
	@echo "  make ldd ....... to check"

all: w32

w32: 1_DIALOG_W32.EXE

1_DIALOG_W32.EXE: A_DIALOG_W32.ASM
	${ASM} A_DIALOG_W32.ASM 1_DIALOG_W32.EXE
	dir 1_DIALOG_W32.EXE

clean:
	CMD.EXE /C DEL 1_DIALOG_W32.EXE
	@echo "---"
	dir

ldd:
	ls -l
	@echo "---"
	@echo "ASM=${ASM}"
	@echo "INCLUDE=${INCLUDE}"
	@echo "---"
	file  1_DIALOG_W32.EXE
	ntldd 1_DIALOG_W32.EXE

# --- end ---
 
