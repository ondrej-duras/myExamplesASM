


export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: EXAMPLE_OPENGL64.EXE

EXAMPLE_OPENGL64.EXE: OPENGL64.ASM OPENGL.INC
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} OPENGL64.ASM EXAMPLE_OPENGL64.EXE
	dir EXAMPLE_OPENGL64.EXE

clean:
	rm EXAMPLE_OPENGL64.EXE

ldd:
	ntldd EXAMPLE_OPENGL64.EXE

# --- end ---

