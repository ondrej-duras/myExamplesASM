



export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... compile"
	@echo "  make clean .... delete"
	@echo "  make ldd ...... check"

all: 1_F_MSGBOX.EXE 

1_F_MSGBOX.EXE: A_F_MSGBOX.ASM 
	${ASM} A_F_MSGBOX.ASM 1_F_MSGBOX.EXE
	dir 1_F_MSGBOX.EXE

clean:
	CMD.EXE /C DEL 1_F_MSGBOX.EXE

ldd:
	file  1_F_MSGBOX.EXE
	ntldd 1_F_MSGBOX.EXE

# --- end ---

