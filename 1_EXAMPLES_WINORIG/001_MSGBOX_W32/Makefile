


export INCLUDE=../../INCLUDE_WIN/
export ASM=../../fasm.exe

help:
	@echo "apply one of following:"
	@echo "  make all ...... to compile"
	@echo "  make w32 ...... to compile 32-bit only"
	@echo "  make w64 ...... to compile 64-bit only"
	@echo "  make w32ax .... to compile 32-bit "
	@echo "  make w32wx .... to compile 32-bit "
	@echo "  make w64ax .... to compile 64-bit "
	@echo "  make w64wx .... to compile 64-bit "
	@echo "  make clean .... to delete"
	@echo "  make ldd ...... to check"

all: w32 w64

w32: w32ax w32wx

w64: w64ax w64wx

w32ax: 1_HELLO_W32_AX.EXE

w32wx: 2_HELLO_W32_WX.EXE

w64ax: 3_HELLO_W64_AX.EXE

w64wx: 4_HELLO_W64_WX.EXE

1_HELLO_W32_AX.EXE: A_HELLO_W32_AX.ASM
	${ASM} A_HELLO_W32_AX.ASM 1_HELLO_W32_AX.EXE
	dir 1_HELLO_W32_AX.EXE

2_HELLO_W32_WX.EXE: B_HELLO_W32_WX.ASM
	${ASM} B_HELLO_W32_WX.ASM 2_HELLO_W32_WX.EXE
	dir 2_HELLO_W32_WX.EXE

3_HELLO_W64_AX.EXE: C_HELLO_W64_AX.ASM
	${ASM} C_HELLO_W64_AX.ASM 3_HELLO_W64_AX.EXE
	dir 3_HELLO_W64_AX.EXE

4_HELLO_W64_WX.EXE: D_HELLO_W64_WX.ASM
	${ASM} D_HELLO_W64_WX.ASM 4_HELLO_W64_WX.EXE
	dir 4_HELLO_W64_WX.EXE

clean:
	CMD.EXE /C DEL  1_HELLO_W32_AX.EXE
	CMD.EXE /C DEL  2_HELLO_W32_WX.EXE
	CMD.EXE /C DEL  3_HELLO_W64_AX.EXE
	CMD.EXE /C DEL  4_HELLO_W64_WX.EXE
	@echo "---"
	dir

ldd:
	ls -l
	@echo "---"
	@echo "ASM=${ASM}"
	@echo "INCLUDE=${INCLUDE}"
	@echo "---"
	file  1_HELLO_W32_AX.EXE
	ntldd 1_HELLO_W32_AX.EXE
	@echo "---"
	file  2_HELLO_W32_WX.EXE
	ntldd 2_HELLO_W32_WX.EXE
	@echo "---"
	file  3_HELLO_W64_AX.EXE
	ntldd 3_HELLO_W64_AX.EXE
	@echo "---"
	file  4_HELLO_W64_WX.EXE
	ntldd 4_HELLO_W64_WX.EXE

# --- end ---

