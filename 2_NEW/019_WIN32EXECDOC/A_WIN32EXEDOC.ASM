;===============================================================================
;Program       : win32exedoc
;Version       : 0.0.1
;Author        : Yeoh HS
;Date          : Nov 2008, edited in December 2017
;Purpose       : One way to embed html files in an executable
;flat assembler: 1.73.02
;;Resources     : win32exedoc.res  (The html files are in this .res file.)
;Resources     : B_WIN32EXEDOC.RES  (The html files are in this .res file.)
;===============================================================================

format PE GUI 4.0
entry start

include 'win32axp.inc'
include 'macro\if.inc'

;-------------------------------------------------------------------------------
IDI_ICON     =   1
IDT_TIMER    =   1

IDD_MDLG     =   1000
IDC_SBAR     =   1008

IDM_MENU     =   2001
IDM_EXIT     =   2002
IDM_ABOUT    =   2003
IDM_CONT     =   2004
IDM_ONLINE   =   2005
IDD_SPLASH   =   8000
IDD_ABOUT    =   8800
IDC_ABOUT    =   8801
IDD_HELP     =   9000
IDC_HELP     =   9001

;-------------------------------------------------------------------------------
section '.data' data readable writeable

abouttitle  db    'About this program',0
ginst       dd    ?
gwnd        dd    ?
hicon       dd    ?
webpage     db    'http://www.flatassembler.net',0 ; removed obsolete link
htimer      dd    ?
timeout     dd    1000
lpout       rb    1024
lpfmt       db    'EAX = %0xh, %d',0

intccex         INITCOMMONCONTROLSEX
wsadata         WSADATA
szDLL           db  "ATL.DLL",0
hLib            dd  ?
szAtlAxWinInit  db  "AtlAxWinInit",0
htmfile         db  'http://www.flatassembler.net',0 ;removed obsolete link
hwebctl         dd  ?

;-------------------------------------------------------------------------------
section '.code' code readable executable

start:
        invoke LoadLibrary, szDLL
        mov [hLib],eax
        
        invoke GetProcAddress,[hLib], szAtlAxWinInit
        call eax

        invoke GetModuleHandle,NULL
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
        invoke FreeLibrary,[hLib]
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
     invoke DialogBoxParam,[ginst],IDD_SPLASH,[hwnd],splashproc,NULL
     invoke LoadIcon,[ginst],IDI_ICON
     mov   [hicon],eax
     invoke SendMessage,[gwnd],WM_SETICON,ICON_SMALL,[hicon]
     invoke SendMessage,[gwnd],WM_SETICON,ICON_BIG,[hicon]
     jmp   .processed
.on_wm_command:
     mov   eax,[wparam]
     cmp   eax,IDOK
     je    .on_btn_ok_clicked
     cmp   eax,IDM_EXIT
     je    .on_btn_ok_clicked
     cmp   eax,IDM_ABOUT
     je    .on_about_menu_clicked
     cmp   eax,IDM_CONT
     je    .on_contents_menu_clicked
     cmp   eax,IDM_ONLINE
     je    .on_online_menu_clicked
     xor   eax,eax
     jmp   .finish
.on_btn_ok_clicked:
     invoke SendMessage,[hwnd],WM_CLOSE,0,0
     jmp   .processed
.on_about_menu_clicked:
     invoke DialogBoxParam,[ginst],IDD_ABOUT,[hwnd],aboutproc,NULL
     jmp   .processed
.on_contents_menu_clicked:
     invoke ShellExecute,[hwnd],'open',webpage,0,0,SW_SHOW
     jmp   .processed
.on_online_menu_clicked:
     invoke ShellExecute,[hwnd],'open',webpage,0,0,SW_SHOW
     jmp   .processed
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
     invoke SetTimer,[hwnd],IDT_TIMER,[timeout],0
     mov   [htimer],eax
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
        fopen,     'fopen',\
        fclose,    'fclose',\
        fprintf,   'fprintf',\
        fgets,     'fgets'
;-------------------------------------------------------------------------------
section '.rsrc' resource from 'B_WIN32EXEDOC.RES' data readable
; end of file ==================================================================
