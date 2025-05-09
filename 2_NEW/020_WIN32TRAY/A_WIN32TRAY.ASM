;===============================================================================
; Program Name  : win32tray.asm
; Purpose       : simple Win32 tray-based program template.
; Date          : July 2008, edited December 2017
; Author        : Yeoh HS
; flat assembler: 1.73.01
; resources     : win32tray.res
; reference     : Thanks to Mateusz Tymek for the example from fasm's website.
;===============================================================================

format PE GUI 4.0
entry start

include "win32axp.inc"
include '\macro\if.inc'

;-------------------------------------------------------------------------------
WM_SHELLNOTIFY = WM_USER+5
IDI_TRAY       = 0
IDI_ICON       = 1
IDM_SHOWHIDE   = 100
IDM_EXIT       = 101

;-------------------------------------------------------------------------------
section '.data' data readable writeable

szClass           db "Win32TrayClass", 0
szTaskBarCreated  db "TaskbarCreated", 0
szTitle           db "Win32 Tray Program Template", 0
szShowHide        db "&Show/Hide", 0
szExit            db "&Exit", 0

hInstance         dd ?
hTrayMenu         dd ?
hMainWnd          dd ?
wm_taskbarcreated dd ?
msg               MSG
wc                WNDCLASSEX
node              NOTIFYICONDATA
showflag          dd ?   ; 1 if main window is visible

;-------------------------------------------------------------------------------
section '.code' code readable executable

start:
        invoke  RegisterWindowMessageA, szTaskBarCreated
        mov     [wm_taskbarcreated], eax

        invoke  GetModuleHandle,0
        mov     [hInstance],eax

     ; initialise main window
        mov     [wc.hInstance],eax
        xor     eax,eax
        mov     [wc.cbSize],sizeof.WNDCLASSEX
        mov     [wc.style],eax
        mov     [wc.cbClsExtra],eax
        mov     [wc.cbWndExtra],eax
        mov     [wc.lpszMenuName],eax
        mov     [wc.hIconSm],eax
        mov     [wc.hbrBackground],COLOR_BTNFACE+1
        mov     [wc.lpszClassName],szClass
        mov     [wc.lpfnWndProc],MainWindowProc
        invoke  LoadIcon, [hInstance],IDI_ICON
        mov     [wc.hIcon],eax
        invoke  LoadCursor, NULL,IDC_ARROW
        mov     [wc.hCursor],eax
        invoke  RegisterClassEx, wc
        or      eax,eax
        jz      finish
        invoke  CreateWindowEx, 0,szClass,szTitle,WS_VISIBLE+WS_OVERLAPPEDWINDOW++WS_MAXIMIZE,\
                                CW_USEDEFAULT,CW_USEDEFAULT,640,480,HWND_DESKTOP,0,[hInstance],0
        or      eax,eax
        jz      finish
        mov     [hMainWnd],eax
        mov     [showflag],1

message_loop:
        invoke  GetMessage, msg,NULL,0,0
        or      eax,eax
        jz      finish
        invoke  TranslateMessage, msg
        invoke  DispatchMessage, msg
        jmp     message_loop
finish:
        invoke  ExitProcess, [msg.wParam]

;-------------------------------------------------------------------------------
proc MainWindowProc hWnd,uMsg,wparam,lparam
local pt:POINT
        push    ebx esi edi
        mov     eax,[uMsg]
        cmp     eax,WM_SHELLNOTIFY
        je      .wmshellnotify
        cmp     eax,WM_COMMAND
        je      .wmcommand
        cmp     eax,WM_SYSCOMMAND
        je      .wmsyscommand
        cmp     eax,WM_CREATE
        je      .wmcreate
        cmp     eax,WM_DESTROY
        je      .wmdestroy
        cmp     eax,[wm_taskbarcreated]
        je      .wm_taskbarcreated
  .defwndproc:
        invoke  DefWindowProc, [hWnd],[uMsg],[wparam],[lparam]
        jmp     .finish
  .wmcreate:
     ; create tray icon
        ; fill NOTIFYICONDATA structure
        mov     [node.cbSize],sizeof.NOTIFYICONDATA
        mov     eax,[hWnd]
        mov     [node.hWnd],eax
        mov     [node.uID],IDI_TRAY
        mov     [node.uFlags],NIF_ICON+NIF_MESSAGE+NIF_TIP
        mov     [node.uCallbackMessage],WM_SHELLNOTIFY
        invoke  LoadIcon,[hInstance],IDI_ICON
        mov     [node.hIcon],eax
        mov     dword[node.szTip],"Win3"
        mov     dword[node.szTip+4], "2 Tr"
        mov     dword[node.szTip+8], "ay"
        invoke  Shell_NotifyIcon, NIM_ADD,node          ; show icon ton system tray
        invoke  CreatePopupMenu                                         ;
        mov     [hTrayMenu],eax                                         ; create popup menu
        invoke  AppendMenu, eax,MF_STRING,IDM_SHOWHIDE,szShowHide       ;
        invoke  AppendMenu, [hTrayMenu],MF_STRING,IDM_EXIT,szExit       ;
        xor     eax,eax
        jmp     .finish
  .wmcommand:                           ; WM_COMMAND handler - here we handle clicks on tray icon
        cmp     [lparam],0
        jne     .finish
        mov     eax,[wparam]
        cmp     eax,IDM_SHOWHIDE
        je      .showhide
        cmp     eax,IDM_EXIT
        je      .idm_exit
        jmp     .finish
  .idm_exit:
        invoke  DestroyWindow, [hWnd]
        jmp     .finish

  .wmsyscommand:                                ; when user presses "minimize" button, main window
        cmp     [wparam],SC_MINIMIZE            ; should be hidden
        jne     .defwndproc
     .sc_minimize:
        jmp     .showhide

  .wmshellnotify:                               ; WM_SHELLNOTIFY handler - here we handle actions
        cmp     [wparam],IDI_TRAY               ; like clicking on our icon
        jne     .finish
        cmp     [lparam],WM_LBUTTONDOWN
        je      .showhide
        cmp     [lparam],WM_RBUTTONDOWN
        je      .show_tray_popup
        jmp     .finish
  .showhide:
        cmp     [showflag],0
        je      .show
      .hide:
        invoke  ShowWindow, [hWnd],SW_HIDE
        mov     [showflag], 0
        jmp     .finish
      .show:
        invoke  ShowWindow, [hWnd],SW_SHOW
        mov     [showflag], 1
        jmp     .finish
  .show_tray_popup:
        lea     eax,[pt]
        invoke  GetCursorPos, eax
        invoke  SetForegroundWindow, [hWnd]
        invoke  TrackPopupMenu, [hTrayMenu],TPM_RIGHTALIGN,[pt.x],[pt.y],\
                                NULL,[hWnd],NULL
        invoke  PostMessage, [hWnd],WM_NULL,0,0
        jmp     .finish

  .wm_taskbarcreated:
        ; When Explorer crashes and restarts.
        invoke          Shell_NotifyIcon, NIM_ADD, node          ; show icon to system tray
        jmp     .finish

  .wmdestroy:
        invoke  Shell_NotifyIcon, NIM_DELETE,node
        invoke  DestroyMenu, [hTrayMenu]
        invoke  PostQuitMessage, 0
        xor     eax,eax
  .finish:
        pop     edi esi ebx
        ret
endp

;-------------------------------------------------------------------------------
section '.idata' import data readable writeable

library kernel32, "kernel32.dll",\
        user32,   "user32.dll",\
        shell32,  "shell32.dll"

include "api/kernel32.inc"
include "api/user32.inc"
include "api/shell32.inc"

;-------------------------------------------------------------------------------
;section '.rsrc' resource from 'win32tray.res' data readable
section '.rsrc' resource from 'B_WIN32TRAY.RES' data readable
; end of file ==================================================================
