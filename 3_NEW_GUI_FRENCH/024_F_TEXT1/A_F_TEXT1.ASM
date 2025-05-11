;===========================================================================================
; Text_1.asm  Fasm Flat assembler
; Ligne de texte
; prevzate od francuzov
;===========================================================================================

format PE GUI 4.0
entry start

; hlavickove subory jazyka
  include 'win32a.inc'
  include 'macro\if.inc'

; makro, ktore prepocita 8-bit R,G,B hodnoty ne jednu 32-bitovu v registri EAX
macro RGB red,green,blue
{   mov eax,0
    mov ah,byte blue
    shl eax,8
    mov ah,byte green
    mov al,byte red   }

;===========================================================================================
; segment kodu programu
section '.code' code readable executable

start:
    ; tu si zistime handler programu
    invoke GetModuleHandle,0
    mov [wc.hInstance],eax

    ; zmena ikonky
    invoke LoadIcon,[wc.hInstance],IDI_FRANCE
    mov [wc.hIcon],eax

    ; zmena kurzora nad oknom programu
    invoke LoadCursor,0,IDC_ARROW
    mov [wc.hCursor],eax

    ; umietnenie okna do stredu obrazovky
    ; X-ova os
    invoke GetSystemMetrics,SM_CXSCREEN
    sub eax,[WinW]
    shr eax,1
    mov [WinX],eax

    ; Y-ova os
    invoke GetSystemMetrics,SM_CYSCREEN
    sub eax,[WinH]
    shr eax,1
    mov [WinY],eax

    ; zaregistrovanie triedy okna
    invoke RegisterClass,wc

    ; vytvorenie hlavneho okna programu
    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ClassName,Title,WS_OVERLAPPEDWINDOW+WS_VISIBLE,\
                          [WinX],[WinY],[WinW],[WinH],0,0,[wc.hInstance],0
    mov [hWnd],eax

    ; zobrazenie okna programu na obrazovke
    invoke ShowWindow,[hWnd],SW_SHOWDEFAULT

    invoke UpdateWindow,[hWnd]

 ;hlavna slucka programu
 MessageLoop:
    invoke GetMessage,msg,0,0,0
    or eax,eax
    jz ExitProgram

    ; prelozenie spravy - zariadi, aby sa sprava dostala spravnej obsluznej procedure
    ; v tomto pripade obsluznej procedure hlavneho okna ... do WinProc
    invoke TranslateMessage,msg

    ; odstranenie udalosti z fronty sprav programu
    invoke DispatchMessage,msg

    ; koniec hlavnej slucky programu
    jmp MessageLoop

 ExitProgram:
    ; ukoncenie programu po vystupeni z nekonecnej hlavnej slucky programu
    invoke ExitProcess,[msg.wParam]

;===========================================================================================
; obsluzna procedura hlavneho okna programu
proc WindowProc uses ebx esi edi, @hWnd, @uMsg, @wParam, @lParam

    .if [@uMsg] = WM_CLOSE
        ; pri prevzati spravy MW_CLOSE, pre este pred zrusenim okna dame jeden MessageBox
        invoke MessageBox,[@hWnd],MsgEnd,ClassName,MB_OK+MB_ICONINFORMATION

        ; rusime instanciu hlavneho okna programu
        invoke PostQuitMessage,0

    .elseif [@uMsg] = WM_PAINT
        ; a tu sa v procedure okna bude pri udalosti WM_PAINT,
        ; teda pri prekreslovani okna kreslit.
        invoke BeginPaint,[@hWnd],ps

        ; toto zisti rozmery a umiestnenie obdlznika pracovnej plochy okna programu
        invoke GetClientRect,[@hWnd],rect

        ; toto do okna vmaluje textovy retazec
        invoke DrawText,[ps.hdc],TxtString,-1,rect,DT_SINGLELINE+DT_CENTER+DT_VCENTER

        ; a toto ukonci rasterizaciu krezby a zabezpeci, aby sa pripravena krezba
        ; umiestnila v obdlzniku okna programu
        invoke EndPaint,[@hWnd],ps

    .else
        ; standartna obsluha okna
        invoke DefWindowProc,[@hWnd],[@uMsg],[@wParam],[@lParam]
        ret

    .endif

    mov eax,0
    ret
endp

;===========================================================================================
; segment udajov programu
section '.data' data readable writeable

  Title     db ' Nazov hlavneho okna',0
  ClassName db ' Nazov Triedy',0
  MsgEnd    db ' Priklad, prevzaty z francuzskeho AsmGges Win32 France @2006  ',0
  TxtString db ' jeden riadok textu vo Win32 ! ',0
  align 4

  WinX      dd 0
  WinY      dd 0
  WinW      dd 512
  WinH      dd 352

  hWnd      dd ?
  wc        WNDCLASS  0,WindowProc,0,0,NULL,NULL,NULL,COLOR_WINDOW+1,NULL,ClassName
  ps        PAINTSTRUCT
  msg       MSG
  rect      RECT

;===========================================================================================
; .DLL subory, z ktorych importujeme nejaky ten obsah.
section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\
            user32,'USER32.DLL',\
             gdi32,'GDI32.DLL'

  ; referencie na objekty prevzate z kniznic vyssie
  include 'API\KERNEL32.INC'
  include 'API\USER32.INC'
  include 'API\GDI32.INC'

;===========================================================================================
; resources of program, icons/menus/dialogs ....
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
