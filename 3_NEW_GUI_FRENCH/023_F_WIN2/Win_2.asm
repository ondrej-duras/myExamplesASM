;===========================================================================================
; Win_2.asm  Fasm Flat assembler
; Centrer une fenêtre
; Programmé par AsmGges France
;===========================================================================================

format PE GUI 4.0
entry start

; Inclusion des macros/équates/structures nécessaires au programme
; ----------------------------------------------------------------
  include 'win32a.inc'
  include 'macro\if.inc'

;===========================================================================================
; Début du code programme
; -----------------------
section '.code' code readable executable

start:
    ; Obtenir le handle du programme
    ; ------------------------------
    invoke GetModuleHandle,0
    mov [wc.hInstance],eax

    ; Chargement d'une icône
    ; ----------------------
    invoke LoadIcon,[wc.hInstance],IDI_FRANCE
    mov [wc.hIcon],eax

    ; Chargement d'un curseur
    ; -----------------------
    invoke LoadCursor,0,IDC_ARROW
    mov [wc.hCursor],eax

    ; Obtenir la largeur en pixels de l'écran
    ; ---------------------------------------
    invoke GetSystemMetrics,SM_CXSCREEN
    sub eax,[WinW]
    shr eax,1
    mov [WinX],eax

    ; Obtenir la hauteur en pixels de l'écran
    ; ---------------------------------------
    invoke GetSystemMetrics,SM_CYSCREEN
    sub eax,[WinH]
    shr eax,1
    mov [WinY],eax

    ; Valider le choix de la structure WNDCLASS
    ; -----------------------------------------
    invoke RegisterClass,wc

    ; Création de la fenêtre de l'application
    ; ---------------------------------------
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ClassName,Title,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
                          [WinX],[WinY],[WinW],[WinH],0,0,[wc.hInstance],0
    mov [hWnd],eax

    ; Affichage de la fenêtre
    ; -----------------------
    invoke ShowWindow,[hWnd],SW_SHOWDEFAULT

    ; Rafraichissement de la fenêtre
    ; ------------------------------
    invoke UpdateWindow,[hWnd]

 ;----------------------------------
 ; Boucle de traitement des messages
 ;----------------------------------
 MessageLoop:
    ; Réceptionne les messages
    ; ------------------------
    invoke GetMessage,msg,0,0,0
    or eax,eax
    jz ExitProgram

    ; Traduit les touches d'entrée clavier en messages
    ; ------------------------------------------------
    invoke TranslateMessage,msg

    ; Expédition des messages à la procédure Windows
    ; ---------------------------------------------
    invoke DispatchMessage,msg

    jmp MessageLoop

 ExitProgram:
    ; Fermeture de l'application
    ; --------------------------
    invoke ExitProcess,[msg.wParam]

;===========================================================================================
; Procédure principale Windows
;-------------------------------------------------------------------------------------------
proc WindowProc uses ebx esi edi, @hWnd, @uMsg, @wParam, @lParam

    .if [@uMsg] = WM_CLOSE
        ; Boite à message fin d'application
        ; ---------------------------------
        invoke MessageBox,[@hWnd],MsgEnd,ClassName,MB_OK+MB_ICONINFORMATION

        ; Demande la fin de l'application
        ; ------------------------------
        invoke PostQuitMessage,0

    .else
        ; Traitement par défaut des autres messages Windows
        ; ------------------------------------------------
        invoke DefWindowProc,[@hWnd],[@uMsg],[@wParam],[@lParam]
        ret

    .endif

    mov eax,0

    ret
endp

;===========================================================================================
; Définitions des datas chaines / variables initialisées ou non initialisées / structures
; ---------------------------------------------------------------------------------------
section '.data' data readable writeable

  Title     db ' Fenêtre centrée ',0
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
; Inclusion des fichiers .dll contenant les fonctions Windows utilisées
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
; Inclusion des icônes / curseurs / bitmap
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
