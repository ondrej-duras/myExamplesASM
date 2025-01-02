

export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ..... to compile"
	@echo "  make clean ... to delete"
	@echo "  make ldd   ... to check"


all: DLL2INC.EXE

DLL2INC.EXE:
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} DLL2INC.ASM DLL2INC.EXE
	dir DLL2INC.EXE

clean:
	rm DLL2INC.EXE

ldd:
	NTLDD DLL2INC.EXE


