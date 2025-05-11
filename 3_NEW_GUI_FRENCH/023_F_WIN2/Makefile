



export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... compile"
	@echo "  make clean .... delete"
	@echo "  make ldd ...... check"

all: 1_F_WIN2.EXE 

1_F_WIN2.EXE: A_F_WIN2.ASM B_F_FRANCE.ICO 
	${ASM} A_F_WIN2.ASM 1_F_WIN2.EXE
	dir 1_F_WIN2.EXE

clean:
	CMD.EXE /C DEL 1_F_WIN2.EXE

ldd:
	file  1_F_WIN2.EXE
	ntldd 1_F_WIN2.EXE

# --- end ---

