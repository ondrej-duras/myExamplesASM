

export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "use one of following parameters:"
	@echo "  make all  ..... prapares all binaries"
	@echo "  make w32 ...... complie 32-bit only"
	@echo "  make w64 ...... complie 64-bit only"
	@echo "  make clean .... deletes all binaries"
	@echo "  make ldd ...... check dependencies"

all: w32 w64

w32: 1_ERRORMSG_32.DLL 3_LASTERR_32.EXE

w64: 2_WRITEMSG_64.DLL 4_MSGDEMO_64.EXE

1_ERRORMSG_32.DLL: A_ERRORMSG_32_DLL.ASM
	${ASM} A_ERRORMSG_32_DLL.ASM 1_ERRORMSG_32.DLL
	dir 1_ERRORMSG_32.DLL
	@echo "---"

2_WRITEMSG_64.DLL: B_WRITEMSG_64_DLL.ASM
	${ASM} B_WRITEMSG_64_DLL.ASM 2_WRITEMSG_64.DLL
	dir 2_WRITEMSG_64.DLL
	@echo "---"

3_LASTERR_32.EXE: C_LASTERR_32_EXE.ASM 1_ERRORMSG_32.DLL
	${ASM} C_LASTERR_32_EXE.ASM 3_LASTERR_32.EXE
	dir 3_LASTERR_32.EXE
	@echo "---"

4_MSGDEMO_64.EXE: D_MSGDEMO_64_EXE.ASM 2_WRITEMSG_64.DLL
	${ASM} D_MSGDEMO_64_EXE.ASM 4_MSGDEMO_64.EXE
	dir 4_MSGDEMO_64.EXE
	@echo "---"

clean:
	CMD.EXE /C DEL 4_MSGDEMO_64.EXE  
	CMD.EXE /C DEL 3_LASTERR_32.EXE
	CMD.EXE /C DEL 2_WRITEMSG_64.DLL
	CMD.EXE /C DEL 1_ERRORMSG_32.DLL
	@echo "---"
	DIR

ldd:
	ls -l
	@echo "INCLUDE=${INCLUDE}"
	@echo "ASM=${ASM}"
	file  1_ERRORMSG_32.DLL
	ntldd 1_ERRORMSG_32.DLL
	file  2_WRITEMSG_64.DLL
	ntldd 2_WRITEMSG_64.DLL
	file  3_LASTERR_32.EXE
	ntldd 3_LASTERR_32.EXE
	file  4_MSGDEMO_64.EXE
	ntldd 4_MSGDEMO_64.EXE


# --- end ---

