



export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... compile"
	@echo "  make clean .... delete"
	@echo "  make ldd ...... check"

all: 1_WIN32EXEDOC.EXE 

1_WIN32EXEDOC.EXE: A_WIN32EXEDOC.ASM B_WIN32EXEDOC.RES
	${ASM} A_WIN32EXEDOC.ASM 1_WIN32EXEDOC.EXE
	dir 1_WIN32EXEDOC.EXE

clean:
	CMD.EXE /C DEL 1_WIN32EXEDOC.EXE

ldd:
	file  1_WIN32EXEDOC.EXE
	ntldd 1_WIN32EXEDOC.EXE

# --- end ---

