;===========================================================================================
; Win_2.asm  Fasm Flat assembler
; Centrer une fenêtre
; Programmé par AsmGges France
;===========================================================================================

format PE GUI 4.0
entry start

; hlavickove subory
  include 'WIN32A.INC'
  include 'MACRO\IF.INC'

;===========================================================================================
; segment kodu prog
section '.code' code readable executable

start:
    ; zistenie handlera programu
    invoke GetModuleHandle,0
    mov [wc.hInstance],eax

    ; zmena ikony v triede okna programu
    invoke LoadIcon,[wc.hInstance],IDI_FRANCE
    mov [wc.hIcon],eax

    ; zmena kurzora nad oknom programu 
    invoke LoadCursor,0,IDC_ARROW
    mov [wc.hCursor],eax

    ; sirka obrazovky kvoli umiestneniu okna priblizne uprostred
    invoke GetSystemMetrics,SM_CXSCREEN
    sub eax,[WinW]
    shr eax,1
    mov [WinX],eax

    ; vyska obrazovky kvoli umiestneniu okna priblizne uprostred
    invoke GetSystemMetrics,SM_CYSCREEN
    sub eax,[WinH]
    shr eax,1
    mov [WinY],eax

    ; registracia triedy okna
    invoke RegisterClass,wc

    ; vytvorenie instancie triedy - vytvorenie hlavneho okna programu
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ClassName,Title,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
                          [WinX],[WinY],[WinW],[WinH],0,0,[wc.hInstance],0
    mov [hWnd],eax

    ; zobrazenie vytvoreneho okna programu
    invoke ShowWindow,[hWnd],SW_SHOWDEFAULT
    ; aktualizacia okna ... vyhodenie sprav z fronty
    invoke UpdateWindow,[hWnd]

; hlavna slucka programu 
; bez nechutnych makier .if .then .else
MessageLoop:
    ; precitame spravu z fronty sprav, ktichadzajucich programu
    invoke GetMessage,msg,0,0,0
    or eax,eax
    jz ExitProgram ; v pripade, ze obsluzna procedura posle nulu, tak to zabalime (dostala MW_CLOSE)

    ; prekladame spravu .... obsluzi ju procedura okna, definovana v triede okna
    invoke TranslateMessage,msg

    ; vyhadzujeme spravu z fronty programu
    invoke DispatchMessage,msg

    ; a koname tento cyklus donekonecna ... teda dokial okno nedostane MW_CLOSE
    jmp MessageLoop

 ExitProgram:
    ; ukoncenie programu
    invoke ExitProcess,[msg.wParam]

;===========================================================================================
; obsluzna procedura hlavneho okna programu
proc WindowProc uses ebx esi edi, @hWnd, @uMsg, @wParam, @lParam

    .if [@uMsg] = WM_CLOSE
        ; ak udalost okna je WM_CLOSE, tak este demonstrativne dame MessageBox s nejakymi pindami
        invoke MessageBox,[@hWnd],MsgEnd,ClassName,MB_OK+MB_ICONINFORMATION

        ; a poupratujeme instanciu
        invoke PostQuitMessage,0

    .else
        ; v opacnom pripade udalost, prislu do okna, obsluzime standartnym/vychodzim sposobom
        invoke DefWindowProc,[@hWnd],[@uMsg],[@wParam],[@lParam]
        ret

    .endif

    ; sem sa dostaneme len v pripade WM_QUIT
    ; cudne napisane, skusit zmenit....
    mov eax,0

    ret
endp

;===========================================================================================
; segment udajov programu
section '.data' data readable writeable

  Title     db ' Nazov hlavneho okna',0
  ClassName db ' Nazov Triedy okna',0
  MsgEnd    db ' Priklad prevzany z AsmGges Win32 France @2006  ',0
  align 4

  WinX      dd 0
  WinY      dd 0
  WinW      dd 512
  WinH      dd 352

  hWnd      dd ?
  wc        WNDCLASS  0,WindowProc,0,0,NULL,NULL,NULL,COLOR_WINDOW+1,NULL,ClassName
  msg       MSG

;===========================================================================================
; sekcia, kde definujeme "import" .DLL kniznice a objekty, ktore z nich importujeme
section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\
            user32,'USER32.DLL',\
             gdi32,'GDI32.DLL'

  ; Apis Windows dans fichiers dlls
  ; -------------------------------
  include 'API\KERNEL32.INC'
  include 'API\USER32.INC'
  include 'API\GDI32.INC'

;===========================================================================================
; resources .... ikony, menu a tak podobne
section '.rsrc' resource data readable

  directory RT_ICON,icons,\
            RT_GROUP_ICON,group_icons

  IDI_FRANCE = 17

  resource icons,\
           1,LANG_NEUTRAL,icon_data

  resource group_icons,\
           IDI_FRANCE,LANG_NEUTRAL,main_icon

  icon main_icon,icon_data,'B_F_FRANCE.ICO'

;===========================================================================================
; --- koniec ----
