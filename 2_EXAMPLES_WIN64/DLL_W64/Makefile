

export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: X_WRITEMSG.DLL Y_MSGDEMO.EXE

X_WRITEMSG.DLL: WRITEMSG.ASM
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} WRITEMSG.ASM X_WRITEMSG.DLL
	dir X_WRITEMSG.DLL

Y_MSGDEMO.EXE: MSGDEMO.ASM X_WRITEMSG.DLL
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	${ASM} MSGDEMO.ASM Y_MSGDEMO.EXE
	dir Y_MSGDEMO.EXE

clean:
	rm Y_MSGDEMO.EXE
	rm X_WRITEMSG.DLL

ldd:
	ls -l
	ntldd X_WRITEMSG.DLL
	ntldd Y_MSGDEMO.EXE	

# --- end ---

