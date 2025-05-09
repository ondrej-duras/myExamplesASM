;===========================================================================================
; MsgBox_1.asm  Fasm Flat assembler
; Programm par AsmGges France
; Prevzate od francuzov
;===========================================================================================
;===========================================================================================

format PE GUI 4.0
entry start

; Hlavickove subory
include 'win32a.inc'

;===========================================================================================
; segment kodu programu
; -----------------------
section '.code' code readable executable

start:
    ; Len zavolanie standartnej funkcie, zobrazujucej MessageBox
    invoke MessageBox,0,Message,Titre,MB_OK+MB_SYSTEMMODAL

    ; ------------------------------
    ; Ukoncenie programu
    invoke ExitProcess,0

;===========================================================================================
; sedment s datami programu - inicializacne hodnoty a alokacie miesta v pamati
;-------------------------------------------------------------------------------------------
section '.data' data readable writeable

  Titre   db ' ASM Tarinig',0
  Message db ' 1. lekcia. Cely cyklus prikladov je prevzaty od francuzov',0

;===========================================================================================
; referencie na pouzite .DLL subory, teda na dynamicke kniznice
;-------------------------------------------------------------------------------------------
section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\
            user32,'USER32.DLL'

  ; subory s deklaraciami funkcii, volatelnych z pouzitych .DLL
  ; Tieto subory sa daju vygenerovat priamo z .DLL suborov ... neskor navod ako.
  ; -------------------------------
  ;include 'apia\kernel32.inc'
  ;include 'apia\user32.inc'
  include 'API\KERNEL32.INC'
  include 'API\USER32.INC'

;===========================================================================================
; --- koniec ---
