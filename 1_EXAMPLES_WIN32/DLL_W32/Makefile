

export INCLUDE=../../INCLUDE_WIN/
export ASM=../../fasm.exe

help:
	@echo "use one of following parameters:"
	@echo "  make all  ..... prapares all binaries"
	@echo "  make clean .... deletes all binaries"
	@echo "  make ldd ...... check dependencies"

all: X_ERRORMSG.DLL Y_LASTERR.EXE

X_ERRORMSG.DLL: ERRORMSG.ASM
	@echo "ASM=${ASM}"
	@echo "INCLUDE=${INCLUDE}"
	${ASM} ERRORMSG.ASM X_ERRORMSG.DLL
	@dir X_ERRORMSG.DLL

Y_LASTERR.EXE: LASTERR.ASM X_ERRORMSG.DLL
	@echo "ASM=${ASM}"
	@echo "INCLUDE=${INCLUDE}"
	${ASM} LASTERR.ASM Y_LASTERR.EXE
	@dir Y_LASTERR.EXE

clean:
	rm Y_LASTERR.EXE
	rm X_ERRORMSG.DLL

ldd:
	ls -l
	ntldd X_ERRORMSG.DLL
	ntldd Y_LASTERR.EXE

# --- end ---

