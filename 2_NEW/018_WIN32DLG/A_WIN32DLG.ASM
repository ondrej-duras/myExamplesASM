;===============================================================================
;Program        : Win32Dlg
;Version        : 0.0.1
;Author         : Yeoh HS
;Date           : Nov 2008, edited in December 2017
;Purpose        : a basic Win32 Dialog-based template program.
;Flat Assembler : 1.73.01
;Resources      : Win32Dlg.res
;===============================================================================

format PE GUI 4.0
entry start

include 'win32axp.inc'
include 'macro\if.inc'

;-------------------------------------------------------------------------------
IDI_ICON    =   1
IDT_TIMER   =   3

IDD_MDLG    =   1000

IDC_BTNOK   =   1001
IDC_EDIT1   =   1002
IDC_BTNSET  =   1003
IDC_BTNGET  =   1004

IDC_SICON   =   1005
IDC_SBITMAP =   1006
IDC_SLABEL  =   1007
IDC_SBAR    =   1008

IDM_MENU    =   2001
IDM_EXIT    =   2002
IDM_ABOUT   =   2003
IDM_CONT    =   2004

IDD_SPLASH  =   8000
IDC_SPLASH  =   8001

IDD_ABOUT   =   8800

IDB_BITMAP  =   9000
IDB_SPLASH  =   9001

;-------------------------------------------------------------------------------
section '.data' data readable writeable

abouttitle  db    'About this program',0
progtitle   db    'Win32Dlg Copyright (c) 2008 by Yeoh HS',0
about_lpout rb    1024
about_lpfmt db    '%s',0
hello       db    'Hello',0
mbtitle     db    'Report',0
ginst       dd    0
gwnd        dd    0
dlgtext     rb    2048
dlgtextlen  dd    2048
svar_lpout  rb    2048
svar_lpfmt  db    'Value = %lu, Text = %s.',0

sreg_lpout  rb    1024
sreg_lpfmt  db    'EAX = %0xh, %lu',0
hicon       dd    0
hsicon      dd    0
hbitmap     dd    0
hsbitmap    dd    0
hslabel     dd    0
hbarstat    dd    0
sbtext      db    'Ready',0
shellexcmd  db    'open',0
webpage     db    'http://www.google.com',0 ; obsolete link removed
htimer      dd    0
timeout     dd    1000
intccex     INITCOMMONCONTROLSEX
wsadata     WSADATA

;-------------------------------------------------------------------------------
section '.code' code readable executable
start:  invoke GetModuleHandle,NULL
        mov   [ginst],eax
        mov   [intccex.dwICC],ICC_ANIMATE_CLASS or ICC_BAR_CLASSES or ICC_COOL_CLASSES or \
                           ICC_DATE_CLASSES or ICC_HOTKEY_CLASS or ICC_INTERNET_CLASSES or \
                           ICC_LISTVIEW_CLASSES or \
                           ICC_PAGESCROLLER_CLASS or ICC_PROGRESS_CLASS or \
                           ICC_TAB_CLASSES or ICC_TREEVIEW_CLASSES or ICC_UPDOWN_CLASS or \
                           ICC_USEREX_CLASSES
        invoke InitCommonControlsEx,intccex
        invoke WSAStartup, 0002h, wsadata
        invoke DialogBoxParam,[ginst],IDD_MDLG,NULL,dlgproc,NULL
        invoke WSACleanup
        invoke ExitProcess,0

;-------------------------------------------------------------------------------
proc dlgproc,hwnd,umsg,wparam,lparam
     push  edi esi ebx
     mov   eax,[umsg]
     cmp   eax,WM_COMMAND
     je    .on_wm_command
     cmp   eax,WM_INITDIALOG
     je    .on_initdialog
     cmp   eax,WM_CLOSE
     je    .on_wm_close
     xor   eax,eax
     jmp   .finish

.on_initdialog:
     mov   eax,[hwnd]
     mov   [gwnd],eax
     invoke DialogBoxParam,[ginst],IDD_SPLASH,NULL,splashproc,NULL

     invoke CreateStatusWindow,WS_CHILD+WS_VISIBLE,NULL,[gwnd],IDC_SBAR
     mov    [hbarstat],eax
     invoke SendMessage,[hbarstat],SB_SETTEXT,0,sbtext

     invoke LoadIcon,[ginst],IDI_ICON
     mov   [hicon],eax
     invoke SendMessage,[gwnd],WM_SETICON,ICON_SMALL,[hicon]
     invoke SendMessage,[gwnd],WM_SETICON,ICON_BIG,[hicon]
            
     invoke GetDlgItem,[gwnd],IDC_SICON
     mov   [hsicon],eax
     invoke SendMessage,[hsicon],STM_SETICON,[hicon],0
            
     invoke LoadImage,[ginst],IDB_BITMAP,IMAGE_BITMAP,0,0,LR_DEFAULTCOLOR
     mov   [hbitmap],eax
     invoke GetDlgItem,[gwnd],IDC_SBITMAP
     mov   [hsbitmap],eax
     invoke SendMessage,[hsbitmap],STM_SETIMAGE,IMAGE_BITMAP,[hbitmap]
            
     invoke GetDlgItem,[gwnd],IDC_SLABEL
     mov   [hslabel],eax
     invoke SetWindowText,[hslabel],mbtitle

     invoke SetWindowText,[gwnd],progtitle

     jmp   .processed

.on_wm_command:
     mov   eax,[wparam]
     cmp   eax,IDC_BTNOK
     je    .on_btn_ok_clicked
     cmp   eax,IDM_EXIT
     je    .on_btn_ok_clicked
     cmp   eax,IDM_ABOUT
     je    .on_about_menu_clicked
     cmp   eax,IDM_CONT
     je    .on_contents_menu_clicked
     cmp   eax,IDC_BTNSET
     je    .on_btn_set_clicked
     cmp   eax,IDC_BTNGET
     je    .on_btn_get_clicked
     cmp   eax,IDC_SICON
     je    .on_icon_clicked
     cmp   eax,IDC_SBITMAP
     je    .on_bitmap_clicked
     xor   eax,eax
     jmp   .finish

.on_btn_ok_clicked:
     invoke SendMessage,[hwnd],WM_CLOSE,0,0
     jmp   .processed

.on_about_menu_clicked:
     invoke DialogBoxParam,[ginst],IDD_ABOUT,NULL,aboutproc,NULL
     jmp   .processed

.on_contents_menu_clicked:
     invoke ShellExecute,[hwnd],shellexcmd,webpage,0,0,SW_SHOW
     jmp   .processed

.on_btn_set_clicked:
     stdcall btnset,[hwnd]
     jmp   .processed

.on_btn_get_clicked:
     stdcall btnget,[hwnd]
     jmp   .processed

.on_icon_clicked:
     stdcall btnset,[hwnd]
     jmp   .processed

.on_bitmap_clicked:
     stdcall btnget,[hwnd]
     mov   eax,1
     jmp   .processed

.on_wm_close:
     invoke EndDialog,[hwnd],0

.processed:
     mov   eax,1

.finish:
     pop   ebx esi edi
     ret
endp

;------------------------------------------------------------------------------
proc btnset,hWnd
     invoke SetDlgItemText,[hWnd],IDC_EDIT1,hello
     mov   eax,255
     stdcall showeax
     ret
endp

;-------------------------------------------------------------------------------
proc btnget,hWnd
     invoke GetDlgItemText,[hWnd],IDC_EDIT1,dlgtext,[dlgtextlen]
     stdcall showvar,[dlgtextlen],dlgtext
     ret
endp

;-------------------------------------------------------------------------------
proc showvar,lu_num,msg
     cinvoke wsprintf,svar_lpout,svar_lpfmt,[lu_num],[msg]
     invoke MessageBox,0,svar_lpout,mbtitle,MB_ICONINFORMATION+MB_OK
     ret
endp

;-------------------------------------------------------------------------------
proc showeax
     cinvoke wsprintf,sreg_lpout,sreg_lpfmt,eax,eax
     invoke MessageBox,0,sreg_lpout,mbtitle,MB_ICONINFORMATION+MB_OK
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
     invoke SetTimer,[hwnd],IDT_TIMER,[timeout],0
     mov   [htimer],eax

     invoke LoadImage,[ginst],IDB_SPLASH,IMAGE_BITMAP,0,0,LR_DEFAULTCOLOR
     mov   [hbitmap],eax
     invoke GetDlgItem,[hwnd],IDC_SPLASH
     mov   [hsbitmap],eax
     invoke SendMessage,[hsbitmap],STM_SETIMAGE,IMAGE_BITMAP,[hbitmap]

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
     mov eax,1
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

     jmp   .processed
.on_wm_command:
     mov   eax,[wparam]
     cmp   eax,1       ; IDOK is 1
     je    .on_wm_close
     xor   eax,eax
     jmp   .finish
.on_wm_close:
     invoke EndDialog,[hwnd],0
.processed:
     mov eax,1
.finish:
     pop   ebx esi edi
     ret
endp

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
        msvcrt,   'MSVCRT.DLL'

include 'api\kernel32.inc'
include 'api\user32.inc'
include 'api\comctl32.inc'
include 'api\shell32.inc'
include 'api\advapi32.inc'
include 'api\comdlg32.inc'
include 'api\gdi32.inc'
include 'api\wsock32.inc'
 
import  msvcrt,\
        fprintf,   'fprintf',\
        fgets,     'fgets'

;-------------------------------------------------------------------------------
section '.rsrc' resource from 'B_WIN32DLG.RES' data readable

; end of file ==================================================================
