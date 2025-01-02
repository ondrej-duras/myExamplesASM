
export INCLUDE=../../INCLUDE_WIN/
export ASM=../../FASM.EXE

help:
	@echo "Apply one of following:"
	@echo "  make all ....... to prepare"
	@echo "  make clean ..... to delete"
	@echo "  make ldd ....... to check"

all: EXAMPLE_DIALOG.EXE

EXAMPLE_DIALOG.EXE: DIALOG.ASM
	@echo "ASM=${ASM}"
	@echo "INCLUDE=${INCLUDE}"
	${ASM} DIALOG.ASM EXAMPLE_DIALOG.EXE
	dir EXAMPLE_DIALOG.EXE

clean:
	rm EXAMPLE_DIALOG.EXE

ldd:
	ntldd EXAMPLE_DIALOG.EXE

# --- end ---
 
