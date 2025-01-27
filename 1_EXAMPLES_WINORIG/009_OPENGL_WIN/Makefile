


export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ........... to compile"
	@echo "  make w32 ........... to compile 32-bit only"
	@echo "  make w64 ........... to compile 64-bit only"
	@echo "  make clean ......... to delete"
	@echo "  make ldd ........... to check"

all: w32 w64

w32: 1_OPENGL32.EXE

w64: 2_OPENGL64.EXE

1_OPENGL32.EXE: A_OPENGL32.ASM C_OPENGL.INC
	${ASM} A_OPENGL32.ASM 1_OPENGL32.EXE
	dir 1_OPENGL32.EXE

2_OPENGL64.EXE: B_OPENGL64.ASM C_OPENGL.INC
	${ASM} B_OPENGL64.ASM 2_OPENGL64.EXE
	dir 2_OPENGL64.EXE

clean:
	CMD.EXE /C DEL 1_OPENGL32.EXE
	CMD.EXE /C DEL 2_OPENGL64.EXE
	@echo "---"
	dir

ldd:
	ls -l
	@echo "---"
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	@echo "---"
	file  1_OPENGL32.EXE
	ntldd 1_OPENGL32.EXE
	file  2_OPENGL64.EXE
	ntldd 2_OPENGL64.EXE

# --- end ---	
