


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

w32: 1_PE32DEMO.EXE

w64: 2_PE64DEMO.EXE

1_PE32DEMO.EXE: A_PE32DEMO.ASM
	${ASM} A_PE32DEMO.ASM 1_PE32DEMO.EXE
	dir 1_PE32DEMO.EXE

2_PE64DEMO.EXE: B_PE64DEMO.ASM
	${ASM} B_PE64DEMO.ASM 2_PE64DEMO.EXE
	dir 2_PE64DEMO.EXE

clean:
	CMD.EXE /C DEL 1_PE32DEMO.EXE
	CMD.EXE /C DEL 2_PE64DEMO.EXE
	@echo "---"
	dir

ldd:
	ls -l
	@echo "---"
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	@echo "---"
	file  1_PE32DEMO.EXE
	ntldd 1_PE32DEMO.EXE
	file  2_PE64DEMO.EXE
	ntldd 2_PE64DEMO.EXE

# --- end ---

