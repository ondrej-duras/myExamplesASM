


export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ........... to compile"
	@echo "  make clean ......... to delete"
	@echo "  make ldd ........... to check"

all: EXAMPLE_OPENGL.EXE

EXAMPLE_OPENGL.EXE: OPENGL.ASM OPENGL.INC 
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} OPENGL.ASM EXAMPLE_OPENGL.EXE 
	dir EXAMPLE_OPENGL.EXE

clean:
	rm EXAMPLE_OPENGL.EXE

ldd:
	ntldd EXAMPLE_OPENGL.EXE

# --- end ---	
