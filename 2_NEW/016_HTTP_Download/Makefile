


export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... compile"
	@echo "  make clean .... delete"
	@echo "  make ldd ...... check"

all: 1_GETFASMG.EXE

1_GETFASMG.EXE: A_GETFASMG.ASM
	${ASM} A_GETFASMG.ASM 1_GETFASMG.EXE
	dir 1_GETFASMG.EXE

clean:
	CMD.EXE /C DEL 1_GETFASMG.EXE
	CMD.EXE /C DEL 2_fasmg.zip

ldd:
	file  1_GETFASMG.EXE
	ntldd 1_GETFASMG.EXE

# --- end ---

