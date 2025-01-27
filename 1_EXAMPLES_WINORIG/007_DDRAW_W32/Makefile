
export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ..... prepare binary"
	@echo "  make w32 ..... prepare binary"
	@echo "  make clean ... delete binary"
	@echo "  make ldd ..... to check"

all: w32

w32: 1_DDRAW_W32.EXE

1_DDRAW_W32.EXE: A_DDRAW_W32.ASM B_DDRAW.INC C_GIF87A.INC D_DDRAW.GIF
	${ASM} A_DDRAW_W32.ASM 1_DDRAW_W32.EXE
	dir 1_DDRAW_W32.EXE

clean:
	CMD.EXE /C DEL 1_DDRAW_W32.EXE
	@echo "---"
	dir 

ldd:
	ls -l
	@echo "---"
	@echo "ASM=${ASM}"
	@echo "INCLUDE=${INCLUDE}"
	@echo "---"
	file  1_DDRAW_W32.EXE
	ntldd 1_DDRAW_W32.EXE

# --- end ---

