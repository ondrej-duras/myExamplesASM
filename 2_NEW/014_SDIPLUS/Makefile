

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

w32: 1_GDIPlusW32F01.EXE

w64: 2_GDIPlusW64F01.EXE

1_GDIPlusW32F01.EXE: A_GDIPlusW32F01.ASM
	${ASM} A_GDIPlusW32F01.ASM 1_GDIPlusW32F01.EXE
	dir 1_GDIPlusW32F01.EXE

2_GDIPlusW64F01.EXE: B_GDIPlusW64F01.ASM
	${ASM} B_GDIPlusW64F01.ASM 2_GDIPlusW64F01.EXE
	dir 2_GDIPlusW64F01.EXE

clean:
	CMD.EXE /C DEL 1_GDIPlusW32F01.EXE
	CMD.EXE /C DEL 2_GDIPlusW64F01.EXE

ldd:
	file  1_GDIPlusW32F01.EXE
	ntldd 1_GDIPlusW32F01.EXE
	file  2_GDIPlusW64F01.EXE
	ntldd 2_GDIPlusW64F01.EXE

# --- end ---

