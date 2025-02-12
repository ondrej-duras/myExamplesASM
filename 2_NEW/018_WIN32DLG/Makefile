



export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... compile"
	@echo "  make clean .... delete"
	@echo "  make ldd ...... check"

all: 1_WIN32DLG.EXE 

1_WIN32DLG.EXE: A_WIN32DLG.ASM B_WIN32DLG.RES
	${ASM} A_WIN32DLG.ASM 1_WIN32DLG.EXE
	dir 1_WIN32DLG.EXE

clean:
	CMD.EXE /C DEL 1_WIN32DLG.EXE

ldd:
	file  1_WIN32DLG.EXE
	ntldd 1_WIN32DLG.EXE

# --- end ---

