;===========================================================================================
; Win_1.asm  Fasm Flat assembler
; Programm par AsmGges France
; Priklady prevzate od francuzov
;===========================================================================================
;===========================================================================================

format PE GUI 4.0
entry start

; hlavickove subory
  include 'win32a.inc'
  include 'macro\if.inc'

;===========================================================================================
; Segment kodu programu
section '.code' code readable executable

start:
    ; zisti handler instacie programu
    invoke GetModuleHandle,0
    mov [wc.hInstance],eax

    ; zmeni ikonu programu na francuzku ikonu (prikompilovanu)
    invoke LoadIcon,[wc.hInstance],IDI_FRANCE
    mov [wc.hIcon],eax

    ; Zmeni kurzor mysi na IDC_ARROW
    invoke LoadCursor,0,IDC_ARROW
    mov [wc.hCursor],eax

    ; registracia tredy okna
    invoke RegisterClass,wc

    ; vytvorenie hlavneho okna programu ako instancie prave zaregistrovanej triedy
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ClassName,Title,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
                          60,60,512,352,0,0,[wc.hInstance],0
    mov [hWnd],eax

    ; zobrazenie vytvoreneho okna na obrazovke
    invoke ShowWindow,[hWnd],SW_SHOWDEFAULT

    ; (na zaklade udalosti) aktualizujeme obsah okna
    ; cim zrejme len vyprazdnime frontu udalosti okna
    invoke UpdateWindow,[hWnd]

 ;----------------------------------
 ; Hlavna slucka programu
 ;----------------------------------
 MessageLoop:
    ; prevezmeme od systemu "udalost" okna / "udalost", posielanu systemom do programu
    invoke GetMessage,msg,0,0,0
    or eax,eax      ; v pripade, ze nieje uz k dispozicii ziadna udalost, tak koncime program
    jz ExitProgram

    ; realizuje preklad ... spracovanie spravy
    invoke TranslateMessage,msg

    ; odstranuje spravu z fronty sprav programu
    invoke DispatchMessage,msg

    ; realizuje nekonecnu slucku - zakoncuje hlavnu slucku programu    
    jmp MessageLoop

 ExitProgram:
    ; miesto kde program konci
    invoke ExitProcess,[msg.wParam]

;===========================================================================================
; Obsluzna procedura hlavneho okna programu
proc WindowProc uses ebx esi edi, @hWnd, @uMsg, @wParam, @lParam

    .if [@uMsg] = WM_CLOSE
        ; ak okno dostane spravu WM_CLOSE, tak sa este zobrazi informativny MessageBox
        invoke MessageBox,[@hWnd],MsgEnd,ClassName,MB_OK+MB_ICONINFORMATION

        ; a odstrani sa instancia okna zo systemu
        invoke PostQuitMessage,0

    .else
        ; vsetky ostatne spravy sa osetruju defaultnou procedurou/defaultnou obsluhou
        invoke DefWindowProc,[@hWnd],[@uMsg],[@wParam],[@lParam]
        ; tu sa zrejme v EAX vracia identifikator spravy ktoru nasledne treba dispatchnut
        ; .... ale je to len moj dohad .... treba dostudovat
        ret

    .endif

    ; haluz, preco je to napisane prave takto, ale tu
    ; davame info hlavnej slucke programu, ze treba skoncit.
    ; ....hlavna slucka sa toci dokola, kym nieje v EAX nula
    mov eax,0

    ret
endp

;===========================================================================================
; Définitions des datas chaines / variables initialisées ou non initialisées / structures
; ---------------------------------------------------------------------------------------
section '.data' data readable writeable

  Title     db ' Jednoduche okno',0
  ClassName db ' Nazov okna v MessageBox-e',0
  MsgEnd    db ' Prevzate z prikladov AsmGges Win32 France (C) 2006  ',0
  align 4

  hWnd      dd ?
  wc        WNDCLASS  0,WindowProc,0,0,NULL,NULL,NULL,COLOR_WINDOW+1,NULL,ClassName
  msg       MSG

;===========================================================================================
; Inclusion des fichiers .dll contenant les fonctions Windows utilisées
;-------------------------------------------------------------------------------------------
section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\
            user32,'USER32.DLL'

  ; Apis Windows dans fichiers dlls
  ; -------------------------------
  include 'API\KERNEL32.INC'
  include 'API\USER32.INC'

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

  icon main_icon,icon_data,'B_FRANCE.ICO'

;===========================================================================================
