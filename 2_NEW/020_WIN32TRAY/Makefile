



export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... compile"
	@echo "  make clean .... delete"
	@echo "  make ldd ...... check"

all: 1_WIN32TRAY.EXE 

1_WIN32TRAY.EXE: A_WIN32TRAY.ASM B_WIN32TRAY.RES
	${ASM} A_WIN32TRAY.ASM 1_WIN32TRAY.EXE
	dir 1_WIN32TRAY.EXE

clean:
	CMD.EXE /C DEL 1_WIN32TRAY.EXE

ldd:
	file  1_WIN32TRAY.EXE
	ntldd 1_WIN32TRAY.EXE

# --- end ---

