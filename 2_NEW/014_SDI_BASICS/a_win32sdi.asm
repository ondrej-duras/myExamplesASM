;===============================================================================
;Program       : Win32SDI
;Version       : 0.0.1
;Author        : Yeoh HS
;Date          : Nov 2008, edited in December 2017
;Purpose       : a simple Win32 Single Document Interface-based template program.
;Flat Assembler: 1.73.01
;Resources     : Win32SDI.res (created with Pelles C)
;===============================================================================
format PE GUI 4.0
entry start

include 'win32axp.inc'
include 'macro\if.inc'

 IDI_ICON    =   1
 IDT_TIMER   =   3

 IDD_SDLG    =   1000

 IDM_MENU    =   2001
 IDM_EXIT    =   2002
 IDM_ABOUT   =   2003
 IDM_CONTENTS=   2004
 IDM_SETTINGS=   2005

 IDA_MAIN    =   3001

 IDD_SPLASH  =   8000
 IDC_SPLASH  =   8001

 IDD_ABOUT   =   8800

 IDB_SPLASH  =   9001

;-------------------------------------------------------------------------------
section '.code' code readable executable

start:
      invoke  GetModuleHandle,0
      mov     [wc.hInstance],eax
      mov     [ginst], eax
      invoke  LoadIcon,[ginst],IDI_ICON
      mov     [wc.hIcon],eax
      invoke  LoadCursor,0,IDC_ARROW
      mov     [wc.hCursor],eax
      invoke  RegisterClass,wc
      test    eax,eax
      jz      error

      invoke  LoadAccelerators,[ginst],IDA_MAIN
      mov     [hacc],eax

      invoke  CreateWindowEx,0,winclass,wintitle,\
              WS_OVERLAPPEDWINDOW,\
              10,10,640,480,NULL,NULL,[wc.hInstance],NULL
      test    eax,eax
      jz      error
      mov     [ghwnd],eax

      mov   [intccex.dwICC],ICC_COOL_CLASSES+ICC_BAR_CLASSES
      invoke InitCommonControlsEx,intccex
      invoke WSAStartup, 0002h, wsadata

      invoke ShowWindow, [ghwnd], SW_SHOW
      invoke UpdateWindow, [ghwnd]

msg_loop:
      invoke  GetMessage,msg,NULL,0,0
      or      eax,eax
      jz      end_loop
      invoke  TranslateAccelerator,[ghwnd],[hacc],msg
      or      eax,eax
      jnz     msg_loop
      cmp     [msg.message],WM_KEYDOWN
      je      msg_dispatch
      invoke  TranslateMessage,msg
msg_dispatch:
      invoke  DispatchMessage,msg
      jmp     msg_loop

error:
      invoke  MessageBox,NULL,winerror,NULL,MB_ICONERROR+MB_OK

end_loop:
      invoke  WSACleanup
      invoke  ExitProcess,[msg.wParam]

;-------------------------------------------------------------------------------
proc WindowProc hwnd,wmsg,wparam,lparam
local hdc:DWORD, ps:PAINTSTRUCT, rect:RECT
     push    ebx esi edi
     cmp     [wmsg],WM_CREATE
     je      .wmcreate
     cmp     [wmsg],WM_COMMAND
     je      .wmcommand
     cmp     [wmsg],WM_PAINT
     je      .wmpaint
     cmp     [wmsg],WM_SIZE
     je      .wmsize
     cmp     [wmsg],WM_DESTROY
     je      .wmdestroy
     jmp     .defwndproc
.wmcreate:
     ;invoke PlaySound, Ding, NULL, SND_SYNC
     invoke DialogBoxParam,[ginst],IDD_SPLASH,NULL,splashproc,NULL
     invoke CreateStatusWindow,WS_CHILD+WS_VISIBLE+SBS_SIZEGRIP,NULL,[hwnd],0
     mov    [hstatusbar], eax
     invoke SendMessage,[hstatusbar],SB_SETTEXT,0,'Ready'
     ; TODO
     invoke GetMenu,[hwnd]
     mov    [hmenu],eax
     invoke LoadBitmap,[ginst],9002
     mov    [hbm],eax
     invoke SetMenuItemBitmaps,[hmenu],IDM_EXIT,MF_BYCOMMAND,[hbm],[hbm]
     stdcall center,[hwnd]
     jmp    .finish
.wmcommand:
     mov    eax,[wparam]
     and    eax, 0FFFFh
     .if    eax = IDM_EXIT
        invoke SendMessage,[hwnd],WM_CLOSE,0,0
     .elseif eax = IDM_CONTENTS
        invoke ShellExecute,[hwnd],'open','http://flatassembler.net/',0,0,SW_SHOW ;edited
     .elseif eax = IDM_ABOUT
        invoke DialogBoxParam,[ginst],IDD_ABOUT,[hwnd],aboutproc,NULL
     .elseif eax = IDM_SETTINGS
        invoke DialogBoxParam,[ginst],IDD_SDLG,[hwnd],settingsproc,NULL
     .endif
     jmp    .finish
.wmpaint:
     ; TODO
     invoke BeginPaint,[hwnd],addr ps
     mov [hdc],eax
     invoke GetClientRect,[hwnd],addr rect
     invoke DrawText,[hdc],addr OurText,-1,addr rect, DT_SINGLELINE or DT_CENTER or DT_VCENTER
     invoke EndPaint,[hwnd],addr ps
     jmp    .finish
.wmsize:
     invoke SendMessage,[hstatusbar],WM_SIZE,0,0
     invoke UpdateWindow, [hwnd]
     jmp    .finish
.defwndproc:
     invoke  DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
     jmp     .finish
.wmdestroy:
     invoke  DeleteObject,[hbm]
     invoke  PostQuitMessage,0
     xor     eax,eax
.finish:
     pop     edi esi ebx
     ret
endp

;-------------------------------------------------------------------------------
proc settingsproc,hwnd,umsg,wparam,lparam
     push  edi esi ebx
     mov   eax,[umsg]
     cmp   eax,WM_INITDIALOG
     je    .initdlg
     cmp   eax,WM_COMMAND
     je    .on_wm_command
     cmp   eax,WM_CLOSE
     je    .on_wm_close
     xor   eax,eax
     jmp   .finish
.initdlg:
     ; TODO
     jmp   .processed
.on_wm_command:
     mov   eax,[wparam]
     cmp   eax,IDOK
     je    .on_wm_close
     xor   eax,eax
     jmp   .finish
.on_wm_close:
     invoke EndDialog,[hwnd],0
.processed:
     mov   eax,1
.finish:
     pop   ebx esi edi
     ret
endp

;-------------------------------------------------------------------------------
proc splashproc,hwnd,umsg,wparam,lparam
     push  edi esi ebx
     mov   eax,[umsg]
     cmp   eax,WM_INITDIALOG
     je    .initdlg
     cmp   eax,WM_COMMAND
     je    .on_wm_command
     cmp   eax,WM_TIMER
     je    .on_timer
     cmp   eax,WM_CLOSE
     je    .on_wm_close
     xor   eax,eax
     jmp   .finish
.initdlg:
     invoke SetTimer,[hwnd],IDT_TIMER,1500,0
     mov   [htimer],eax
     invoke LoadImage,[ginst],IDB_SPLASH,IMAGE_BITMAP,0,0,LR_DEFAULTCOLOR
     mov   [hbitmap],eax
     invoke GetDlgItem,[hwnd],IDC_SPLASH
     mov   [hsbitmap],eax
     invoke SendMessage,[hsbitmap],STM_SETIMAGE,IMAGE_BITMAP,[hbitmap]
     ; TODO
     jmp   .processed
.on_wm_command:
     mov   eax,[wparam]
     xor   eax,eax
     jmp   .finish
.on_timer:
     invoke SendMessage,[hwnd],WM_CLOSE,0,0
     jmp   .processed
.on_wm_close:
     invoke KillTimer,[hwnd],[htimer]
     invoke EndDialog,[hwnd],0
.processed:
     mov   eax,1
.finish:
     pop   ebx esi edi
     ret
endp

;-------------------------------------------------------------------------------
proc aboutproc,hwnd,umsg,wparam,lparam
     push  edi esi ebx
     mov   eax,[umsg]
     cmp   eax,WM_INITDIALOG
     je    .initdlg
     cmp   eax,WM_COMMAND
     je    .on_wm_command
     cmp   eax,WM_CLOSE
     je    .on_wm_close
     xor   eax,eax
     jmp   .finish
.initdlg:
     ;TODO
     jmp   .processed
.on_wm_command:
     mov   eax,[wparam]
     cmp   eax,IDOK
     je    .on_wm_close
     xor   eax,eax
     jmp   .finish
.on_wm_close:
     invoke EndDialog,[hwnd],0
.processed:
     mov   eax,1
.finish:
     pop   ebx esi edi
     ret
endp

;-------------------------------------------------------------------------------
proc showeax
     cinvoke wsprintf,sreg_lpout,sreg_lpfmt,eax,eax
     invoke MessageBox,0,sreg_lpout,mbtitle,MB_ICONINFORMATION+MB_OK
     ret
endp

;------------------------------------------------------------------------------
proc center,hWnd
local Var01:DWORD, Var02:DWORD, DesktopArea:RECT, rc:RECT
    invoke SystemParametersInfo,SPI_GETWORKAREA,0,addr DesktopArea,0
    invoke GetWindowRect,[hWnd],addr rc

    mov eax, [DesktopArea.bottom]
    sub eax, [DesktopArea.top]
    sub eax, [rc.bottom]
    add eax, [rc.top]
    shr eax, 1
    add eax, [DesktopArea.top]
    mov [Var02], eax
    xor eax, eax

    mov eax, [DesktopArea.right]
    sub eax, [DesktopArea.left]
    sub eax, [rc.right]
    add eax, [rc.left]
    shr eax, 1
    add eax, [DesktopArea.left]
    mov [Var01], eax
    xor eax, eax

    invoke SetWindowPos,[hWnd],HWND_TOP,[Var01],[Var02],0,0,SWP_NOSIZE
    ret
endp

;-------------------------------------------------------------------------------
section '.data' data readable writeable

winclass    db 'WIN32SDI',0
wintitle    db 'Win32 Single Document Interface Template Program',0
winerror    db 'Program startup failed!',0
wc          WNDCLASS 0,WindowProc,0,0,NULL,NULL,NULL,COLOR_WINDOW+1,IDM_MENU,winclass
msg         MSG
intccex     INITCOMMONCONTROLSEX
wsadata     WSADATA
ghwnd       dd 0
ginst       dd 0
hacc        dd 0
htimer      dd 0
hbitmap     dd 0
hsbitmap    dd 0
hmenu       dd 0
Ding        db 'Ding.wav',0
sreg_lpout  rb 1024
sreg_lpfmt  db 'EAX = %0xh, %lu',0
mbtitle     db 'Report',0
hstatusbar  dd 0
OurText     db 'Flat Assembler is the best.',0
hbm         dd ?

;-------------------------------------------------------------------------------
section '.idata' import data readable writeable
library kernel32, 'KERNEL32.DLL',\
        user32,   'USER32.DLL',\
        comctl32, 'COMCTL32.DLL',\
        shell32,  'SHELL32.DLL',\
        advapi32, 'ADVAPI32.DLL',\
        comdlg32, 'COMDLG32.DLL',\
        gdi32,    'GDI32.DLL',\
        wsock32,  'WSOCK32.DLL',\
        msvcrt,   'MSVCRT.DLL',\
        winmm,    'WINMM.DLL'

include 'api\kernel32.inc'
include 'api\user32.inc'
include 'api\comctl32.inc'
include 'api\shell32.inc'
include 'api\advapi32.inc'
include 'api\comdlg32.inc'
include 'api\gdi32.inc'
include 'api\wsock32.inc'
 
import  msvcrt,\
        fprintf, 'fprintf',\
        fgets,   'fgets'

import  winmm,\
        PlaySound, 'PlaySound'

;-------------------------------------------------------------------------------
section '.rsrc' data readable resource from 'c_win32sdi.res'

; end of file =================================================================
