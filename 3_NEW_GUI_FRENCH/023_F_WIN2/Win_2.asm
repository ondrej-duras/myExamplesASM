;===========================================================================================
; Win_2.asm  Fasm Flat assembler
; Centrer une fen�tre
; Programm� par AsmGges France
;===========================================================================================

format PE GUI 4.0
entry start

; Inclusion des macros/�quates/structures n�cessaires au programme
; ----------------------------------------------------------------
  include 'win32a.inc'
  include 'macro\if.inc'

;===========================================================================================
; D�but du code programme
; -----------------------
section '.code' code readable executable

start:
    ; Obtenir le handle du programme
    ; ------------------------------
    invoke GetModuleHandle,0
    mov [wc.hInstance],eax

    ; Chargement d'une ic�ne
    ; ----------------------
    invoke LoadIcon,[wc.hInstance],IDI_FRANCE
    mov [wc.hIcon],eax

    ; Chargement d'un curseur
    ; -----------------------
    invoke LoadCursor,0,IDC_ARROW
    mov [wc.hCursor],eax

    ; Obtenir la largeur en pixels de l'�cran
    ; ---------------------------------------
    invoke GetSystemMetrics,SM_CXSCREEN
    sub eax,[WinW]
    shr eax,1
    mov [WinX],eax

    ; Obtenir la hauteur en pixels de l'�cran
    ; ---------------------------------------
    invoke GetSystemMetrics,SM_CYSCREEN
    sub eax,[WinH]
    shr eax,1
    mov [WinY],eax

    ; Valider le choix de la structure WNDCLASS
    ; -----------------------------------------
    invoke RegisterClass,wc

    ; Cr�ation de la fen�tre de l'application
    ; ---------------------------------------
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ClassName,Title,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
                          [WinX],[WinY],[WinW],[WinH],0,0,[wc.hInstance],0
    mov [hWnd],eax

    ; Affichage de la fen�tre
    ; -----------------------
    invoke ShowWindow,[hWnd],SW_SHOWDEFAULT

    ; Rafraichissement de la fen�tre
    ; ------------------------------
    invoke UpdateWindow,[hWnd]

 ;----------------------------------
 ; Boucle de traitement des messages
 ;----------------------------------
 MessageLoop:
    ; R�ceptionne les messages
    ; ------------------------
    invoke GetMessage,msg,0,0,0
    or eax,eax
    jz ExitProgram

    ; Traduit les touches d'entr�e clavier en messages
    ; ------------------------------------------------
    invoke TranslateMessage,msg

    ; Exp�dition des messages � la proc�dure Windows
    ; ---------------------------------------------
    invoke DispatchMessage,msg

    jmp MessageLoop

 ExitProgram:
    ; Fermeture de l'application
    ; --------------------------
    invoke ExitProcess,[msg.wParam]

;===========================================================================================
; Proc�dure principale Windows
;-------------------------------------------------------------------------------------------
proc WindowProc uses ebx esi edi, @hWnd, @uMsg, @wParam, @lParam

    .if [@uMsg] = WM_CLOSE
        ; Boite � message fin d'application
        ; ---------------------------------
        invoke MessageBox,[@hWnd],MsgEnd,ClassName,MB_OK+MB_ICONINFORMATION

        ; Demande la fin de l'application
        ; ------------------------------
        invoke PostQuitMessage,0

    .else
        ; Traitement par d�faut des autres messages Windows
        ; ------------------------------------------------
        invoke DefWindowProc,[@hWnd],[@uMsg],[@wParam],[@lParam]
        ret

    .endif

    mov eax,0

    ret
endp

;===========================================================================================
; D�finitions des datas chaines / variables initialis�es ou non initialis�es / structures
; ---------------------------------------------------------------------------------------
section '.data' data readable writeable

  Title     db ' Fen�tre centr�e ',0
  ClassName db ' AsmGges Win32',0
  MsgEnd    db ' AsmGges France @2006  ',0
  align 4

  WinX      dd 0
  WinY      dd 0
  WinW      dd 512
  WinH      dd 352

  hWnd      dd ?
  wc        WNDCLASS  0,WindowProc,0,0,NULL,NULL,NULL,COLOR_WINDOW+1,NULL,ClassName
  msg       MSG

;===========================================================================================
; Inclusion des fichiers .dll contenant les fonctions Windows utilis�es
;-------------------------------------------------------------------------------------------
section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\
            user32,'USER32.DLL',\
             gdi32,'GDI32.DLL'

  ; Apis Windows dans fichiers dlls
  ; -------------------------------
  include 'apia\kernel32.inc'
  include 'apia\user32.inc'
  include 'apia\gdi32.inc'

;===========================================================================================
; Inclusion des ic�nes / curseurs / bitmap
;-------------------------------------------------------------------------------------------
section '.rsrc' resource data readable

  directory RT_ICON,icons,\
            RT_GROUP_ICON,group_icons

  IDI_FRANCE = 17

  resource icons,\
           1,LANG_NEUTRAL,icon_data

  resource group_icons,\
           IDI_FRANCE,LANG_NEUTRAL,main_icon

  icon main_icon,icon_data,'res\france.ico'

;===========================================================================================
