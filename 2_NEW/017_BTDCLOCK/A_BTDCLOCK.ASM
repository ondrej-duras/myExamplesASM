;------------------------------------------------------------------------------
;Program: BTDClock
;Version: 1.1.0
;Author: Yeoh HS
;Date: Jan-Mar 2009, updated in Dec 2017
;Purpose: Big Text Display digital clock.
;Required file: btdclock.res (resources for this program)
;FASM: version 1.73.01
;------------------------------------------------------------------------------

format PE GUI 4.0
entry start

include 'win32axp.inc'
include '\macro\if.inc'

;------------------------------------------------------------------------------
struct MYSYSTEMTIME
   wYear         dw ?
   wMonth        dw ?
   wDayOfWeek    dw ?
   wDay          dw ?
   wHour         dw ?
   wMinute       dw ?
   wSecond       dw ?
   wMilliseconds dw ?
ends

;------------------------------------------------------------------------------
TRIAL = 0   ;0 = full version 1 = trial version
ERROR_ALREADY_EXISTS = 183
FONTSCALE            = 120
CSIDL_APPDATA        = 26
MAXPATH              = 260

ES_CONTINUOUS        = 0x80000000
ES_DISPLAY_REQUIRED  = 0x00000002
ES_SYSTEM_REQUIRED   = 0x00000001

SND_SYNC      = 0
SND_ASYNC     = 1
SND_RESOURCE  = 0x00040004

IDI_ICON      = 1
IDT_SPLASH    = 2
IDT_TICKER    = 3

IDD_PREFS     = 1001
IDD_ABOUT     = 1002
IDD_SPLASH    = 1003

IDM_MENU      = 2001
IDM_EXIT      = 2002
IDM_PREF      = 2003
IDM_ABOUT     = 2004
IDM_FONT      = 2005
IDM_TXCLR     = 2006
IDM_BKCLR     = 2007
IDM_CONT      = 2008

IDA_MAIN      = 3001

IDS_TICK      = 8001
IDS_HOURLY    = 8002
IDS_QTRLY     = 8003
IDS_ALARM1    = 8004

IDC_SPLASHON  = 4001
IDC_DISTDISP  = 4034
IDC_MP3AUTOP  = 4002
IDC_MP3LOOPP  = 4003
IDC_MP3FILEP  = 4022
IDC_MP3LOADF  = 4023
IDC_TRANSPAW  = 4024
IDC_TRANSPWV  = 4004
IDC_TODAYDAT  = 4026
IDC_TODAYFMT  = 4006
IDC_TICKINGC  = 4007
IDC_TICKFILE  = 4011
IDC_TICKBTNS  = 4027
IDC_HOURCHIM  = 4008
IDC_CHIMEFIL  = 4028
IDC_CHIMEBTN  = 4029
IDC_QTRCHIME  = 4009
IDC_QTRCFILE  = 4030
IDC_QTRCHBTN  = 4031
IDC_SETALARM  = 4010
IDC_ALARMTIM  = 4013
IDC_ALARMFIL  = 4032
IDC_ALARMBTN  = 4033
IDC_TIMEFMT0  = 4016
IDC_TIMEFMT1  = 4037
IDC_TIMEFMT2  = 4038
IDC_APPLYBTN  = 4005

IDC_ICON      = 1004
IDC_WEBSITE   = 4001

;-------------------------------------------------------------------------------
section '.data' data readable writeable
winclass         db 'BTDClock',0
wintitle         db 'BTDClock',0
ExWinTitle       db "BTDClock, Today is ",0
MyAppFolder      db 'btdclock',0
NoFileSelected   db 'No file selected',0
DateFmt          db '%s, %.2d-%.2d-%.4d',0
TimeFmt0         db '%.2d:%.2d:%.2d',0
TimeFmt1         db '%d:%.2d:%.2d',0
TimeFmt2PM       db '%d:%.2d:%.2d PM',0
TimeFmt2AM       db '%d:%.2d:%.2d AM',0
DefaultFontName  db 'Arial',0
lpOperation      db 'open',0
lpHelpFile       db 'http://flatassembler.net',0  ;deleted obsolete file
lpWebsite        db 'http://flatassembler.net',0  ;deleted obsolete link
lpParameters     dd NULL
lpDirectory      db '',0
wc               WNDCLASS 0,WindowProc,0,0,NULL,NULL,NULL,COLOR_BTNFACE+1,IDM_MENU,winclass
msg              MSG
ghwnd            dd ?
ginst            dd ?
hacc             dd ?
htimer           dd ?
desktoprc        RECT
hTimeDisplay     dd ?
hFont            dd ?
hTickSound       dd ?
TickSoundWav     rb MAXPATH
hHourlySound     dd ?
HourlySoundWav   rb MAXPATH
hQtrSound        dd ?
QtrSoundWav      rb MAXPATH
hAlarm1Sound     dd ?
Alarm1SoundWav   rb MAXPATH
htCounter        dd ?
WinTitleBuffer   rb MAXPATH
DateBuffer       rb 16
DayofWeek        rb 9
strtimedisplay   rb 16
DDMMYY           dd ?
tickinterval     dd 1000
hbrush           dd ?
yCounter         dd ?
TimeDisplayHeight dd 300
fheight          dd ?
fweight          dd ?
fitalic          dd ?
FontName         rb 32
hcolorbk         dd ?
hcolortx         dd ?
ssActive         dd ?
TimeFmt          dd ?
ChimeStyle       dd ?
Ticking          dd ?
HourlyChime      dd ?
QtrChime         dd ?
Alarm1Set        dd ?
Alarm1HH         dd ?
Alarm1MM         dd ?
Alarm1SS         dd ?
DisplayDate      dd ?
Transparent      dd ?
Transparentval   dd ?
mp3_autoplay     dd ?
mp3_repeaton     dd ?
mp3_open         rb 512
mp3_openfmt      db 'open "%s" type MPEGVideo Alias MP3',0
mp3_file         rb MAXPATH
mp3_playrepeat   db 'play MP3 repeat',0
mp3_playonce     db 'play MP3',0
mp3_close        db 'close MP3',0
mp3_nullstring   db '',0
lpmp3Filter      db 'MP3 Files',0,'*.mp3',0
lpmp3File        rb MAXPATH
lpwavFilter      db 'WAV Files',0,'*.wav',0
lgfont           LOGFONT
COLORREF         dd 16 dup 0
SplashOn         dd ?
cfgfp            dd 0
cfgwritemode     db 'wb',0
cfgreadmode      db 'rb',0
cfgstr           db '%s',0Ah,0
cfgnum           db '%d',0Ah,0
CfgFolderPath    rb MAXPATH
CfgFile          db '/btdclock.cfg',0
txtline          rb MAXPATH
txtlen           dd ?
dtAlarm1         dd ?
systime          SYSTEMTIME
prefsbuffer      rb MAXPATH
prefsfmt         db 'Maximum exceeded! Value set to %d',0
Alarm1SetFmt     db ', Alarm set: %.2d:%.2d:%.2d',0
Alarm1SetBuf     rb MAXPATH

;------------------------------------------------------------------------------
section '.code' code readable executable
start:

      invoke GetModuleHandleA,0
      mov    [wc.hInstance],eax
      mov    [ginst], eax
      invoke CreateMutexA,NULL,TRUE,'BTDClockInstanceIsRunning'
      invoke GetLastError
      .if eax = ERROR_ALREADY_EXISTS
          invoke MessageBoxA,0,'An instance of this program is already running.',\
                             'Attention',\
                             MB_ICONINFORMATION+MB_OK+MB_SYSTEMMODAL
          invoke FindWindowA,winclass,NULL
          invoke SetForegroundWindow,eax
          jmp end_loop
      .endif
      invoke LoadIconA,[ginst],IDI_ICON
      mov    [wc.hIcon],eax
      invoke LoadCursorA,0,IDC_ARROW
      mov    [wc.hCursor],eax
      invoke RegisterClassA,wc
      test   eax,eax
      jz     error
      invoke LoadAcceleratorsA,[ginst],IDA_MAIN
      mov    [hacc],eax
      invoke SystemParametersInfoA,SPI_GETWORKAREA,0,desktoprc,0
      invoke CreateWindowExA,0,winclass,wintitle,\
                            WS_CAPTION+WS_MINIMIZEBOX+WS_SYSMENU,\
                            0,0,[desktoprc.right],[desktoprc.bottom],NULL,NULL,[wc.hInstance],NULL
      test   eax,eax
      jz     error
      mov    [ghwnd],eax
      invoke ShowWindow,[ghwnd],SW_SHOW
      invoke UpdateWindow,[ghwnd]
msg_loop:
      invoke GetMessageA,msg,NULL,0,0
      or     eax,eax
      jz     end_loop
      invoke TranslateAccelerator,[ghwnd],[hacc],msg
      or     eax,eax
      jnz    msg_loop
      cmp    [msg.message],WM_KEYDOWN
      je     msg_dispatch
      invoke TranslateMessage,msg
msg_dispatch:
      invoke DispatchMessageA,msg
      jmp    msg_loop
error:
      invoke MessageBoxA,NULL,'Unable to start BTDClock!',\
                             'Program Initialization Error!',MB_ICONERROR+MB_OK
end_loop:
      invoke ExitProcess,[msg.wParam]

;------------------------------------------------------------------------------
proc WindowProc hwnd,wmsg,wparam,lparam
     push   ebx esi edi
     cmp    [wmsg],WM_CREATE
     je     .wmcreate
     cmp    [wmsg],WM_TIMER
     je     .wmtimer
     cmp    [wmsg],WM_COMMAND
     je     .wmcommand
     cmp    [wmsg],WM_CTLCOLORSTATIC
     je     .wmctlcolorstatic
     cmp    [wmsg],WM_ACTIVATE
     je     .wmactivate
     cmp    [wmsg],WM_DESTROY
     je     .wmdestroy
     jmp    .defwndproc
.wmcreate:
     ; set program's config path and file
     invoke SHGetSpecialFolderPathA,[ghwnd],CfgFolderPath,CSIDL_APPDATA,0
     invoke PathAppendA,CfgFolderPath,MyAppFolder
     invoke CreateDirectoryA,CfgFolderPath,NULL
     cinvoke strcat,CfgFolderPath,CfgFile
     stdcall readcfgfile
     ; control display of startup screen
     .if [SplashOn] = TRUE
         invoke DialogBoxParamA,[ginst],IDD_SPLASH,NULL,splashproc,NULL
     .endif
     ; conditional compilation, only if TRIAL = 1
     if TRIAL
        invoke MessageBoxA,0,'Thank you for trying out this program.','Trial Version Notice',MB_ICONINFORMATION+MB_OK
     end if
     ; turn off screensave if active
     invoke SystemParametersInfoA,SPI_GETSCREENSAVEACTIVE,0,ssActive,0
     .if [ssActive] = TRUE
         invoke SystemParametersInfoA,SPI_SETSCREENSAVEACTIVE,FALSE,0,0
     .else
         mov [ssActive], FALSE
     .endif
     ; Disable power save/off mode
     invoke SetThreadExecutionState, ES_CONTINUOUS+ES_DISPLAY_REQUIRED+ES_SYSTEM_REQUIRED
     ; Repaints window background color
     stdcall SetWinColor,[hwnd],[hcolorbk]
     invoke InvalidateRect,[hwnd],NULL,TRUE
     ; load pointers to default wav files that are in resource section.
     mov    [hTickSound],  IDS_TICK
     mov    [hHourlySound],IDS_HOURLY
     mov    [hQtrSound],   IDS_QTRLY
     mov    [hAlarm1Sound],IDS_ALARM1
     ; create an edit control for the time display.
     invoke CreateWindowExA,0,'edit',NULL,WS_CHILD+WS_VISIBLE+ES_READONLY+ES_CENTER,\
                           0,[yCounter],[desktoprc.right],[TimeDisplayHeight],[hwnd],-1,[ginst],NULL
     mov    [hTimeDisplay],eax
     ; create font and set it to the time display.
     invoke CreateFontA,[fheight],0,0,0,[fweight],[fitalic],0,0,ANSI_CHARSET,\
                        OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\
                        DEFAULT_QUALITY,DEFAULT_PITCH or FF_DONTCARE,\
                        FontName
     mov    [hFont],eax
     invoke SendMessageA,[hTimeDisplay],WM_SETFONT,[hFont],FALSE
     ;
     invoke SetTimer,[hwnd],IDT_TICKER,[tickinterval],0
     mov    [htCounter],eax
     ;
     stdcall GetTime,strtimedisplay,[TimeFmt]
     invoke SetWindowTextA,[hTimeDisplay],strtimedisplay
     ;
     stdcall SetPreferences,[hwnd]
     jmp .finish
.wmcommand:
     mov eax,[wparam]
     mov ebx,eax
     and eax,0FFFFh
     shr ebx,16
     .if eax = IDM_EXIT
         invoke SendMessageA,[hwnd],WM_CLOSE,0,0
     .elseif eax = IDM_FONT
         stdcall SelectFont
         invoke DeleteObject,[hFont]  ; to avoid memory leak
         invoke CreateFontA,[fheight],0,0,0,[fweight],[fitalic],0,0,ANSI_CHARSET,\
                           OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\
                           DEFAULT_QUALITY,DEFAULT_PITCH or FF_DONTCARE,\
                           FontName
         mov [hFont],eax
         invoke SendMessageA,[hTimeDisplay],WM_SETFONT,[hFont],FALSE
         stdcall writecfgfile
         stdcall readcfgfile
     .elseif eax = IDM_TXCLR
         stdcall SelectTextColor
         stdcall writecfgfile
         stdcall readcfgfile
     .elseif eax = IDM_BKCLR
         stdcall SelectBackColor
         stdcall writecfgfile
         stdcall readcfgfile
         stdcall SetWinColor,[ghwnd],[hcolorbk]
         invoke InvalidateRect,[hwnd],NULL,TRUE
     .elseif eax = IDM_PREF
         invoke DialogBoxParamA,[ginst],IDD_PREFS,[hwnd],prefsproc,NULL
     .elseif eax = IDM_CONT
         invoke ShellExecuteA,[hwnd],lpOperation,lpHelpFile,lpParameters,lpDirectory,SW_SHOWMAXIMIZED
         .if eax <= 32
             invoke MessageBoxA,0,"Unable to open the program's help file",'Error!',MB_ICONERROR+MB_OK
         .endif
     .elseif eax = IDM_ABOUT
         invoke DialogBoxParamA,[ginst],IDD_ABOUT,[hwnd],aboutproc,NULL
     .elseif ebx = EN_SETFOCUS   ;if user clicks on edit control
         invoke SetFocus,[hwnd]  ;avoid focus in edit control
     .endif
     jmp .finish
.wmtimer:
     stdcall GetTime,strtimedisplay,[TimeFmt]
     invoke SetWindowTextA,[hTimeDisplay],strtimedisplay
     .if [Ticking] = TRUE
         stdcall SoundOut,[hTickSound],TickSoundWav
     .endif
     stdcall SetChime,[ChimeStyle]
     .if [Alarm1Set] = TRUE
         stdcall CheckAlarm,[Alarm1HH],[Alarm1MM],[Alarm1SS],[hAlarm1Sound],Alarm1SoundWav
     .endif
     jmp .finish
.wmctlcolorstatic:
     mov ebx,[lparam]
     .if ebx = [hTimeDisplay]
         invoke SetBkColor,[wparam],[hcolorbk]
         invoke SetTextColor,[wparam],[hcolortx]  ; set edit control's text color
         invoke DeleteObject,[hbrush] ; to avoid memory leak
         invoke CreateSolidBrush,[hcolorbk]; set edit control's background color
         mov    [hbrush],eax ; store object so that it can be deleted later to avoid memory leak
     .endif
     jmp .finish
.wmactivate:
     stdcall SetWinColor,[hwnd],[hcolorbk]
     invoke InvalidateRect,[hwnd],NULL,TRUE
     jmp .finish
.defwndproc:
     invoke  DefWindowProcA,[hwnd],[wmsg],[wparam],[lparam]
     jmp .finish
.wmdestroy:
     .if [ssActive] = TRUE
         invoke SystemParametersInfoA,SPI_SETSCREENSAVEACTIVE,TRUE,0,0
     .endif
     invoke DeleteObject,[hbrush] ; to avoid memory leak
     invoke DeleteObject,[hFont]  ; to avoid memory leak
     invoke KillTimer,[hwnd],[htCounter]
     if TRIAL
        invoke MessageBoxA,0,'Thank you for trying out this program.','Trial Version Notice',MB_ICONINFORMATION+MB_OK
     end if
     invoke PostQuitMessage,0
     xor eax,eax
.finish:
     pop edi esi ebx
     ret
endp

;------------------------------------------------------------------------------
proc prefsproc,hwnd,umsg,wparam,lparam
     push edi esi ebx
     mov  eax,[umsg]
     cmp  eax,WM_INITDIALOG
     je   .wminitdlg
     cmp  eax,WM_COMMAND
     je   .wmcommand
     cmp  eax,WM_CLOSE
     je   .wmclose
     xor  eax,eax
     jmp  .finish
.wminitdlg:
     stdcall GetPreferences,[hwnd]
     jmp .processed
.wmcommand:
     mov eax,[wparam]
     cmp eax,IDC_MP3LOADF
     je  .onbnMP3File
     cmp eax,IDC_TICKBTNS
     je  .onbnTickWav
     cmp eax,IDC_CHIMEBTN
     je  .onbnHourlyWav
     cmp eax,IDC_QTRCHBTN
     je  .onbnQtrlyWav
     cmp eax,IDC_ALARMBTN
     je  .onbnAlarmWav
     cmp eax,IDC_APPLYBTN
     je  .onbnApply
     cmp eax,IDOK
     je  .onIDOK
     xor eax,eax
     jmp .finish
.onbnMP3File:
     stdcall SelectFile,lpmp3Filter,lpmp3File
     .if eax = 1
         invoke SetDlgItemTextA,[hwnd],IDC_MP3FILEP,lpmp3File
     .else
         invoke SetDlgItemTextA,[hwnd],IDC_MP3FILEP,NoFileSelected
     .endif
     jmp .finish
.onbnTickWav:
     stdcall SelectFile,lpwavFilter,TickSoundWav
     .if eax = 1
         invoke SetDlgItemTextA,[hwnd],IDC_TICKFILE,TickSoundWav
     .else
         invoke SetDlgItemTextA,[hwnd],IDC_TICKFILE,NoFileSelected
     .endif
     jmp .finish
.onbnHourlyWav:
     stdcall SelectFile,lpwavFilter,HourlySoundWav
     .if eax = 1
         invoke SetDlgItemTextA,[hwnd],IDC_CHIMEFIL,HourlySoundWav
     .else
         invoke SetDlgItemTextA,[hwnd],IDC_CHIMEFIL,NoFileSelected
     .endif
     jmp .finish
.onbnQtrlyWav:
     stdcall SelectFile,lpwavFilter,QtrSoundWav
     .if eax = 1
         invoke SetDlgItemTextA,[hwnd],IDC_QTRCFILE,QtrSoundWav
     .else
         invoke SetDlgItemTextA,[hwnd],IDC_QTRCFILE,NoFileSelected
     .endif
     jmp .finish
.onbnAlarmWav:
     stdcall SelectFile,lpwavFilter,Alarm1SoundWav
     .if eax = 1
         invoke SetDlgItemTextA,[hwnd],IDC_ALARMFIL,Alarm1SoundWav
     .else
         invoke SetDlgItemTextA,[hwnd],IDC_ALARMFIL,NoFileSelected
     .endif
     jmp .finish
.onbnApply:
     stdcall SavePreferences,[hwnd]
     stdcall SetWinColor,[ghwnd],[hcolorbk]
     invoke InvalidateRect,[ghwnd],NULL,TRUE
     jmp .finish
.onIDOK:
     stdcall SavePreferences,[hwnd]
     invoke EndDialog,[hwnd],0
.wmclose:
     invoke EndDialog,[hwnd],0
.processed:
     mov eax,1
.finish:
     pop ebx esi edi
     ret
endp

;------------------------------------------------------------------------------
; Load preferences from config file into dialog controls.
proc GetPreferences,hwnd
     invoke SendDlgItemMessageA,[hwnd],IDC_SPLASHON,BM_SETCHECK,[SplashOn],0
     invoke SetDlgItemInt,[hwnd],IDC_DISTDISP,[yCounter],FALSE
     invoke SendDlgItemMessageA,[hwnd],IDC_MP3AUTOP,BM_SETCHECK,[mp3_autoplay],0
     invoke SendDlgItemMessageA,[hwnd],IDC_MP3LOOPP,BM_SETCHECK,[mp3_repeaton],0
     invoke SetDlgItemTextA,[hwnd],IDC_MP3FILEP,lpmp3File
     invoke SendDlgItemMessageA,[hwnd],IDC_TRANSPAW,BM_SETCHECK,[Transparent],0
     invoke SetDlgItemInt,[hwnd],IDC_TRANSPWV,[Transparentval],FALSE
     invoke SendDlgItemMessageA,[hwnd],IDC_TODAYDAT,BM_SETCHECK,[DisplayDate],0
     invoke SendDlgItemMessageA,[hwnd],IDC_TODAYFMT,BM_SETCHECK,[DDMMYY],0
     invoke SendDlgItemMessageA,[hwnd],IDC_TICKINGC,BM_SETCHECK,[Ticking],0
     invoke SendDlgItemMessageA,[hwnd],IDC_HOURCHIM,BM_SETCHECK,[HourlyChime],0
     invoke SendDlgItemMessageA,[hwnd],IDC_QTRCHIME,BM_SETCHECK,[QtrChime],0
     invoke SendDlgItemMessageA,[hwnd],IDC_SETALARM,BM_SETCHECK,[Alarm1Set],0
     invoke SetDlgItemTextA,[hwnd],IDC_TICKFILE,TickSoundWav
     invoke SetDlgItemTextA,[hwnd],IDC_CHIMEFIL,HourlySoundWav
     invoke SetDlgItemTextA,[hwnd],IDC_QTRCFILE,QtrSoundWav
     invoke SetDlgItemTextA,[hwnd],IDC_ALARMFIL,Alarm1SoundWav
     invoke GetDlgItem,[hwnd],IDC_ALARMTIM
     mov    [dtAlarm1],eax
     invoke GetLocalTime, systime
     mov    ebx,[Alarm1HH]
     mov    word[systime.wHour],bx
     mov    ebx,[Alarm1MM]
     mov    word[systime.wMinute],bx
     mov    ebx,[Alarm1SS]
     mov    word[systime.wSecond],bx
     invoke SendMessageA,[dtAlarm1],DTM_SETSYSTEMTIME,0,systime
     .if [TimeFmt] = 0
         invoke SendDlgItemMessageA,[hwnd], IDC_TIMEFMT0,BM_SETCHECK,1,0
     .elseif [TimeFmt] = 1
         invoke SendDlgItemMessageA,[hwnd], IDC_TIMEFMT1,BM_SETCHECK,1,0
     .elseif [TimeFmt] = 2
         invoke SendDlgItemMessageA,[hwnd], IDC_TIMEFMT2,BM_SETCHECK,1,0
     .endif
     ret
endp

;------------------------------------------------------------------------------
; Get preferences from dialog controls into config variables.
proc SavePreferences,hwnd
     invoke SendDlgItemMessageA,[hwnd],IDC_SPLASHON,BM_GETCHECK,0,0
     mov    [SplashOn],eax
     invoke GetDlgItemInt, [hwnd],IDC_DISTDISP,NULL,FALSE
     mov    [yCounter],eax
     mov    ebx,[desktoprc.bottom]
     sub    ebx,[TimeDisplayHeight]
     .if    [yCounter] > ebx
            mov [yCounter],ebx
            cinvoke wsprintfA,prefsbuffer,prefsfmt,[yCounter]
            invoke MessageBoxA,0,prefsbuffer,'Time display distance from top',MB_ICONINFORMATION+MB_OK
     .endif
     invoke MoveWindow,[hTimeDisplay],0,[yCounter],[desktoprc.right],[TimeDisplayHeight],TRUE
     stdcall SetWinColor,[ghwnd], [hcolorbk]
     invoke InvalidateRect,[hwnd],NULL,TRUE
     invoke SendDlgItemMessageA,[hwnd],IDC_MP3AUTOP,BM_GETCHECK,0,0
     mov    [mp3_autoplay],eax
     invoke SendDlgItemMessageA,[hwnd],IDC_MP3LOOPP,BM_GETCHECK,0,0
     mov    [mp3_repeaton],eax
     invoke GetDlgItemTextA,[hwnd],IDC_MP3FILEP,lpmp3File,MAXPATH
     invoke SendDlgItemMessageA,[hwnd],IDC_TRANSPAW,BM_GETCHECK,0,0
     mov    [Transparent],eax
     invoke GetDlgItemInt, [hwnd],IDC_TRANSPWV,NULL,FALSE
     mov    [Transparentval],eax
     .if [Transparentval] > 255
         mov [Transparentval],255
         invoke MessageBoxA,0,'Transparent value maximum is 255.','Maximum Value',MB_ICONWARNING+MB_OK
     .endif
     invoke SendDlgItemMessageA,[hwnd],IDC_TODAYDAT,BM_GETCHECK,0,0
     mov    [DisplayDate],eax
     invoke SendDlgItemMessageA,[hwnd],IDC_TODAYFMT,BM_GETCHECK,0,0
     mov    [DDMMYY],eax
     invoke SendDlgItemMessageA,[hwnd],IDC_TICKINGC,BM_GETCHECK,0,0
     mov    [Ticking],eax
     invoke GetDlgItemTextA,[hwnd],IDC_TICKFILE,TickSoundWav,MAXPATH
     invoke SendDlgItemMessageA,[hwnd],IDC_HOURCHIM,BM_GETCHECK,0,0
     mov    [HourlyChime],eax
     invoke GetDlgItemTextA,[hwnd],IDC_CHIMEFIL,HourlySoundWav,MAXPATH
     invoke SendDlgItemMessageA,[hwnd],IDC_QTRCHIME,BM_GETCHECK,0,0
     mov    [QtrChime],eax
     invoke GetDlgItemTextA,[hwnd],IDC_QTRCFILE,QtrSoundWav,MAXPATH
     invoke SendDlgItemMessageA,[hwnd],IDC_SETALARM,BM_GETCHECK,0,0
     mov    [Alarm1Set],eax
     invoke GetDlgItemTextA,[hwnd],IDC_ALARMFIL,Alarm1SoundWav,MAXPATH
     invoke SendMessageA,[dtAlarm1],DTM_GETSYSTEMTIME,0,systime
     mov bx,word[systime.wHour]
     mov [Alarm1HH],ebx
     mov bx,word[systime.wMinute]
     mov [Alarm1MM],ebx
     mov bx,word[systime.wSecond]
     mov [Alarm1SS],ebx
     invoke SendDlgItemMessageA,[hwnd],IDC_TIMEFMT0,BM_GETCHECK,0,0
     .if eax = 1
         mov [TimeFmt],0
     .endif
     invoke SendDlgItemMessageA,[hwnd],IDC_TIMEFMT1,BM_GETCHECK,0,0
     .if eax = 1
         mov [TimeFmt],1
     .endif
     invoke SendDlgItemMessageA,[hwnd],IDC_TIMEFMT2,BM_GETCHECK,0,0
     .if eax = 1
         mov [TimeFmt],2
     .endif
     if TRIAL
         invoke MessageBoxA,0,'Saving of Preferences disabled!','Trial Version Limitation',MB_ICONINFORMATION+MB_OK
         stdcall SetPreferences,[ghwnd]
     else
         stdcall writecfgfile
         stdcall readcfgfile
         stdcall SetPreferences,[ghwnd]
     end if
     ret
endp

;------------------------------------------------------------------------------
proc aboutproc,hwnd,umsg,wparam,lparam
     push edi esi ebx
     mov  eax,[umsg]
     cmp  eax,WM_INITDIALOG
     je   .wminitdlg
     cmp  eax,WM_COMMAND
     je   .wmcommand
     cmp  eax,WM_CLOSE
     je   .wmclose
     xor  eax,eax
     jmp  .finish
.wminitdlg:
     invoke GetDlgItem,[hwnd],IDC_ICON
     invoke SendMessageA,eax,STM_SETICON,[wc.hIcon],0
     jmp  .processed
.wmcommand:
     mov  eax,[wparam]
     cmp  eax,IDC_WEBSITE
     je   .onwebsite
     cmp  eax,IDOK
     je   .wmclose
     xor  eax,eax
     jmp  .finish
.onwebsite:
     invoke ShellExecuteA,[hwnd],lpOperation,lpWebsite,lpParameters,lpDirectory,SW_SHOWMAXIMIZED
     .if eax <= 32
         invoke MessageBoxA,0,"Are you online now?",'Unable to connect to website!',MB_ICONERROR+MB_OK
     .endif
     jmp  .processed
.wmclose:
     invoke EndDialog,[hwnd],0
.processed:
     mov eax,1
.finish:
     pop ebx esi edi
     ret
endp

;------------------------------------------------------------------------------
proc splashproc,hwnd,umsg,wparam,lparam
local SplashDelay:DWORD
     push edi esi ebx
     mov  eax,[umsg]
     cmp  eax,WM_INITDIALOG
     je   .wminitdlg
     cmp  eax,WM_COMMAND
     je   .wmcommand
     cmp  eax,WM_TIMER
     je   .wmtimer
     cmp  eax,WM_CLOSE
     je   .wmclose
     xor  eax,eax
     jmp  .finish
.wminitdlg:
     mov [SplashDelay],1500
     invoke GetDlgItem,[hwnd],IDC_ICON
     invoke SendMessageA,eax,STM_SETICON,[wc.hIcon],0
     invoke SetTimer,[hwnd],IDT_SPLASH,[SplashDelay],0
     mov    [htimer],eax
     jmp   .processed
.wmcommand:
     mov eax,[wparam]
     xor eax,eax
     jmp .finish
.wmtimer:
     invoke SendMessageA,[hwnd],WM_CLOSE,0,0
     jmp .processed
.wmclose:
     invoke KillTimer,[hwnd],[htimer]
     invoke EndDialog,[hwnd],0
.processed:
     mov eax,1
.finish:
     pop ebx esi edi
     ret
endp

;------------------------------------------------------------------------------
proc GetDate,DateBuffer,DDMMYY
local mst:MYSYSTEMTIME,\
      dYear:DWORD,dMonth:DWORD,dDay:DWORD,\
      dWeekDay:DWORD

     invoke GetLocalTime, addr mst
     xor eax,eax
     mov ax,word[mst.wYear]
     mov [dYear],eax
     xor eax,eax
     mov ax,word[mst.wMonth]
     mov [dMonth],eax
     xor eax,eax
     mov ax,word[mst.wDay]
     mov [dDay],eax
     xor eax, eax
     mov ax, word[mst.wDayOfWeek]
     mov [dWeekDay],eax
     .if [dWeekDay] = 0
         cinvoke strcpy,DayofWeek,'Sunday'
     .elseif [dWeekDay] = 1
         cinvoke strcpy,DayofWeek,'Monday'
     .elseif [dWeekDay] = 2
         cinvoke strcpy,DayofWeek,'Tueday'
     .elseif [dWeekDay] = 3
         cinvoke strcpy,DayofWeek,'Wednesday'
     .elseif [dWeekDay] = 4
         cinvoke strcpy,DayofWeek,'Thursday'
     .elseif [dWeekDay] = 5
         cinvoke strcpy,DayofWeek,'Friday'
     .elseif [dWeekDay] = 6
         cinvoke strcpy,DayofWeek,'Saturday'
     .endif
     .if [DDMMYY] = 0
         cinvoke wsprintfA,[DateBuffer],DateFmt,DayofWeek,[dMonth],[dDay],[dYear]
     .else
         cinvoke wsprintfA,[DateBuffer],DateFmt,DayofWeek,[dDay],[dMonth],[dYear]
     .endif
     ret
endp

;------------------------------------------------------------------------------
proc GetTime,TimeBuffer,TimeFormat
local mst:MYSYSTEMTIME,\
      dHour:DWORD,dMinute:DWORD,dSecond:DWORD

     invoke GetLocalTime, addr mst
     xor eax, eax
     mov ax,word[mst.wHour]
     mov [dHour],eax
     ;mov [dHour],0
     xor eax, eax
     mov ax,word[mst.wMinute]
     mov [dMinute],eax
     ;mov [dMinute],0
     xor eax, eax
     mov ax,word[mst.wSecond]
     mov [dSecond],eax
     ;mov [dSecond],0
     .if [TimeFormat] = 0
         cinvoke wsprintfA,[TimeBuffer],TimeFmt0,[dHour],[dMinute],[dSecond]
     .elseif [TimeFormat] = 1
         cinvoke wsprintfA,[TimeBuffer],TimeFmt1,[dHour],[dMinute],[dSecond]
     .elseif [TimeFormat] = 2
         .if [dHour] > 12
             sub [dHour],12
             cinvoke wsprintfA,[TimeBuffer],TimeFmt2PM,[dHour],[dMinute],[dSecond]
         .elseif [dHour] = 12
             cinvoke wsprintfA,[TimeBuffer],TimeFmt2PM,[dHour],[dMinute],[dSecond]
         .elseif [dHour] = 0
             add [dHour],12
             cinvoke wsprintfA,[TimeBuffer],TimeFmt2AM,[dHour],[dMinute],[dSecond]
         .else
             cinvoke wsprintfA,[TimeBuffer],TimeFmt2AM,[dHour],[dMinute],[dSecond]
         .endif
     .endif
     ret
endp

;------------------------------------------------------------------------------
proc SetChime,ChimeStyle
local mst:MYSYSTEMTIME,\
      dHour:DWORD,dMinute:DWORD,dSecond:DWORD

     invoke GetLocalTime, addr mst
     xor eax, eax
     mov ax,word[mst.wHour]
     mov [dHour],eax
     xor eax, eax
     mov ax,word[mst.wMinute]
     mov [dMinute],eax
     xor eax, eax
     mov ax,word[mst.wSecond]
     mov [dSecond],eax
     .if [ChimeStyle] = 1
         .if [dMinute] = 0
             .if [dSecond] = 0
                 stdcall SoundOut,[hHourlySound],HourlySoundWav
             .endif
         .endif
     .endif
     .if [ChimeStyle] = 2
         .if [dMinute] = 0
             .if [dSecond] = 0
                 stdcall SoundOut,[hHourlySound],HourlySoundWav
             .endif
         .endif
         .if [dMinute] = 15
             .if [dSecond] = 0
                 stdcall SoundOut,[hQtrSound],QtrSoundWav
             .endif
         .endif
         .if [dMinute] = 30
             .if [dSecond] = 0
                 stdcall SoundOut,[hQtrSound],QtrSoundWav
                 stdcall SoundOut,[hQtrSound],QtrSoundWav
             .endif
         .endif
         .if [dMinute] = 45
             .if [dSecond] = 0
                 stdcall SoundOut,[hQtrSound],QtrSoundWav
                 stdcall SoundOut,[hQtrSound],QtrSoundWav
                 stdcall SoundOut,[hQtrSound],QtrSoundWav
             .endif
         .endif
     .endif
     ret
endp

;------------------------------------------------------------------------------
proc CheckAlarm,AlarmHH,AlarmMM,AlarmSS,AlarmSound,AlarmSoundWav
local mst:MYSYSTEMTIME,\
      dHour:DWORD,dMinute:DWORD,dSecond:DWORD

     invoke GetLocalTime, addr mst
     xor eax, eax
     mov ax,word[mst.wHour]
     mov [dHour],eax
     xor eax, eax
     mov ax,word[mst.wMinute]
     mov [dMinute],eax
     xor eax, eax
     mov ax,word[mst.wSecond]
     mov [dSecond],eax
     mov ebx,[AlarmHH]
     .if [dHour] = ebx
         mov ebx,[AlarmMM]
         .if [dMinute] = ebx
             mov ebx,[AlarmSS]
             .if [dSecond] = ebx
                 stdcall SoundOut,[AlarmSound],[AlarmSoundWav]
                 invoke ShowWindow,[ghwnd],SW_RESTORE
             .endif
         .endif
     .endif
     ret
endp

;------------------------------------------------------------------------------
proc SoundOut,hSoundType,SoundFile
     cinvoke strcmp,[SoundFile],NoFileSelected
     .if eax <> 0
         invoke PlaySound,[SoundFile],NULL,SND_SYNC
     .else
         invoke PlaySound,[hSoundType],[ginst],SND_SYNC+SND_RESOURCE
     .endif
     ret
endp

;------------------------------------------------------------------------------
proc SetWinColor,hWnd,Kolor
     invoke DeleteObject,[hbrush]
     invoke CreateSolidBrush,[Kolor]
     mov    [hbrush],eax
     invoke SetClassLongA,[hWnd],GCL_HBRBACKGROUND,[hbrush]
     invoke DeleteObject,eax
     invoke RedrawWindow,[hWnd],0,0,0
     ret
endp

;------------------------------------------------------------------------------
proc IsGEWin2K
local v:OSVERSIONINFO
     mov [v.dwOSVersionInfoSize], sizeof.OSVERSIONINFO
     invoke GetVersionExA, addr v
     .if [v.dwMajorVersion] >= 5
         mov eax,TRUE
     .else
         mov eax,FALSE
     .endif
     ret
endp

;------------------------------------------------------------------------------
proc SelectFile,FileFilter,FileSelected
local ofn:OPENFILENAME
     cinvoke memset,addr ofn,0,sizeof.OPENFILENAME
     mov [ofn.lStructSize],sizeof.OPENFILENAME
     mov ebx, [ghwnd]
     mov [ofn.hwndOwner], ebx
     mov ebx, [FileFilter]
     mov [ofn.lpstrFilter], ebx
     mov [ofn.nFilterIndex], 1
     mov ebx,[FileSelected]
     mov [ofn.lpstrFile],ebx
     mov [ofn.nMaxFile],MAXPATH
     mov [ofn.lpstrFileTitle],NULL
     mov [ofn.nMaxFileTitle],0
     mov [ofn.lpstrInitialDir],NULL
     mov [ofn.Flags],OFN_FILEMUSTEXIST+OFN_PATHMUSTEXIST+\
                     OFN_LONGNAMES+OFN_EXPLORER+OFN_HIDEREADONLY
     invoke GetOpenFileNameA, addr ofn
     .if eax <> 0
          mov eax,1
     .else
          mov eax,0
     .endif
     ret
endp

;------------------------------------------------------------------------------
proc SelectFont
local chfont:CHOOSEFONT
     cinvoke strcpy,lgfont.lfFaceName,FontName
     cinvoke memset,addr chfont,0,sizeof.CHOOSEFONT
     mov [chfont.lStructSize],sizeof.CHOOSEFONT
     mov ebx,lgfont
     mov [chfont.lpLogFont],ebx
     mov [chfont.Flags],CF_INITTOLOGFONTSTRUCT+CF_SCREENFONTS+CF_SCALABLEONLY+\
                        CF_NOSTYLESEL+CF_NOSIZESEL+CF_NOVECTORFONTS
     invoke ChooseFontA,addr chfont
     .if eax <> 0
         cinvoke strcpy,FontName,lgfont.lfFaceName
         mov ebx,[lgfont.lfHeight]
         mov [fheight],ebx
         sub [fheight],FONTSCALE
         mov ebx,[lgfont.lfWeight]
         mov [fweight],ebx
         mov bx,word[lgfont.lfItalic]
         mov word[fitalic],bx
     .endif
     ret
endp

;------------------------------------------------------------------------------
proc SelectTextColor
local c:CHOOSECOLOR
     cinvoke memset,addr c,0,sizeof.CHOOSECOLOR
     mov [c.lStructSize],sizeof.CHOOSECOLOR
     mov ebx, [hcolortx]
     mov [c.rgbResult], ebx
     mov [c.lpCustColors], COLORREF
     mov [c.Flags], CC_RGBINIT or CC_FULLOPEN
     invoke ChooseColorA, addr c
     .if eax <> 0
         mov ebx,[c.rgbResult]
         mov [hcolortx],ebx
     .endif
     ret
endp

;------------------------------------------------------------------------------
proc SelectBackColor
local c:CHOOSECOLOR
     cinvoke memset,addr c,0,sizeof.CHOOSECOLOR
     mov [c.lStructSize],sizeof.CHOOSECOLOR
     mov ebx,[hcolorbk]
     mov [c.rgbResult], ebx
     mov [c.lpCustColors], COLORREF
     mov [c.Flags], CC_RGBINIT or CC_FULLOPEN
     invoke ChooseColorA,addr c
     .if eax <> 0
         mov ebx,[c.rgbResult]
         mov [hcolorbk],ebx
     .endif
     ret
endp

;------------------------------------------------------------------------------
proc LoadDefaultPreferences
     mov [SplashOn],TRUE       ;FALSE = 0, TRUE = 1
     mov [mp3_autoplay],FALSE  ;
     mov [mp3_repeaton],FALSE  ;checkbox
     mov [Transparent],FALSE   ;checkbox
     mov [Transparentval],155  ;spinbox 0 to 255 range
     mov [DisplayDate], TRUE   ;checkbox
     mov [DDMMYY],0            ; 1 for ddmmyy, 0 for mmddyy ;checkbox
     mov [hcolortx],0000000h   ;0BBGGRRh  default is black text
     mov [hcolorbk],0FFFFFFh   ;white background
     mov [Ticking],FALSE       ;checkbox
     mov [HourlyChime],FALSE   ;radiobutton
     mov [QtrChime],FALSE      ;radiobutton
     mov [Alarm1Set],FALSE     ;checkbox
     mov [Alarm1HH],0
     mov [Alarm1MM],0
     mov [Alarm1SS],0
     mov [yCounter],180
     mov [fheight],200
     mov [fweight],700
     mov [fitalic],FALSE
     mov [TimeFmt],2           ;radiobutton 0,1, or 2
     cinvoke strcpy,FontName,DefaultFontName
     cinvoke strcpy,TickSoundWav,NoFileSelected
     cinvoke strcpy,HourlySoundWav,NoFileSelected
     cinvoke strcpy,QtrSoundWav,NoFileSelected
     cinvoke strcpy,Alarm1SoundWav,NoFileSelected
     cinvoke strcpy,lpmp3File,NoFileSelected
     ret
endp

;------------------------------------------------------------------------------
proc writecfgfile
     cinvoke fopen,CfgFolderPath,cfgwritemode
     mov [cfgfp],eax
     .if [cfgfp] = NULL
         invoke MessageBoxA,0,'Cannot write to user preferences file!',\
                             'An unexpected error has occurred!',MB_SYSTEMMODAL+MB_OK+MB_ICONERROR
         jmp .finished
     .endif
     cinvoke fprintf, [cfgfp], cfgnum, [SplashOn]
     cinvoke fprintf, [cfgfp], cfgnum, [mp3_autoplay]
     cinvoke fprintf, [cfgfp], cfgnum, [mp3_repeaton]
     cinvoke fprintf, [cfgfp], cfgnum, [Transparent]
     cinvoke fprintf, [cfgfp], cfgnum, [Transparentval]
     cinvoke fprintf, [cfgfp], cfgnum, [DisplayDate]
     cinvoke fprintf, [cfgfp], cfgnum, [DDMMYY]
     cinvoke fprintf, [cfgfp], cfgnum, [hcolortx]
     cinvoke fprintf, [cfgfp], cfgnum, [hcolorbk]
     cinvoke fprintf, [cfgfp], cfgnum, [Ticking]
     cinvoke fprintf, [cfgfp], cfgnum, [HourlyChime]
     cinvoke fprintf, [cfgfp], cfgnum, [QtrChime]
     cinvoke fprintf, [cfgfp], cfgnum, [Alarm1Set]
     cinvoke fprintf, [cfgfp], cfgnum, [Alarm1HH]
     cinvoke fprintf, [cfgfp], cfgnum, [Alarm1MM]
     cinvoke fprintf, [cfgfp], cfgnum, [Alarm1SS]
     cinvoke fprintf, [cfgfp], cfgnum, [yCounter]
     cinvoke fprintf, [cfgfp], cfgnum, [fheight]
     cinvoke fprintf, [cfgfp], cfgnum, [fweight]
     cinvoke fprintf, [cfgfp], cfgnum, [fitalic]
     cinvoke fprintf, [cfgfp], cfgnum, [TimeFmt]
     cinvoke fprintf, [cfgfp], cfgstr, FontName
     cinvoke fprintf, [cfgfp], cfgstr, TickSoundWav
     cinvoke fprintf, [cfgfp], cfgstr, HourlySoundWav
     cinvoke fprintf, [cfgfp], cfgstr, QtrSoundWav
     cinvoke fprintf, [cfgfp], cfgstr, Alarm1SoundWav
     cinvoke fprintf, [cfgfp], cfgstr, lpmp3File
     cinvoke fclose,  [cfgfp]
.finished:
     ret
endp

;------------------------------------------------------------------------------
proc readcfgfile
     cinvoke fopen, CfgFolderPath, cfgreadmode
     mov [cfgfp], eax
     .if [cfgfp] = NULL ; if there is no config file
         stdcall LoadDefaultPreferences
         stdcall writecfgfile
         jmp .finished
     .endif
     cinvoke fscanf, [cfgfp], cfgnum, SplashOn
     cinvoke fscanf, [cfgfp], cfgnum, mp3_autoplay
     cinvoke fscanf, [cfgfp], cfgnum, mp3_repeaton
     cinvoke fscanf, [cfgfp], cfgnum, Transparent
     cinvoke fscanf, [cfgfp], cfgnum, Transparentval
     cinvoke fscanf, [cfgfp], cfgnum, DisplayDate
     cinvoke fscanf, [cfgfp], cfgnum, DDMMYY
     cinvoke fscanf, [cfgfp], cfgnum, hcolortx
     cinvoke fscanf, [cfgfp], cfgnum, hcolorbk
     cinvoke fscanf, [cfgfp], cfgnum, Ticking
     cinvoke fscanf, [cfgfp], cfgnum, HourlyChime
     cinvoke fscanf, [cfgfp], cfgnum, QtrChime
     cinvoke fscanf, [cfgfp], cfgnum, Alarm1Set
     cinvoke fscanf, [cfgfp], cfgnum, Alarm1HH
     cinvoke fscanf, [cfgfp], cfgnum, Alarm1MM
     cinvoke fscanf, [cfgfp], cfgnum, Alarm1SS
     cinvoke fscanf, [cfgfp], cfgnum, yCounter
     cinvoke fscanf, [cfgfp], cfgnum, fheight
     cinvoke fscanf, [cfgfp], cfgnum, fweight
     cinvoke fscanf, [cfgfp], cfgnum, fitalic
     cinvoke fscanf, [cfgfp], cfgnum, TimeFmt

     cinvoke fgets,  txtline,MAXPATH,[cfgfp]  ; fgets adds newline char
     cinvoke strlen, txtline
     sub eax,1
     cinvoke memmove, FontName,txtline,eax  ;removes trailing newline char

     cinvoke fgets,  txtline,MAXPATH,[cfgfp]
     cinvoke strlen, txtline
     sub eax,1
     cinvoke memmove, TickSoundWav,txtline,eax

     cinvoke fgets,  txtline,MAXPATH,[cfgfp]
     cinvoke strlen, txtline
     sub eax,1
     cinvoke memmove, HourlySoundWav,txtline,eax

     cinvoke fgets,  txtline,MAXPATH,[cfgfp]
     cinvoke strlen, txtline
     sub eax,1
     cinvoke memmove, QtrSoundWav,txtline,eax

     cinvoke fgets,  txtline,MAXPATH,[cfgfp]
     cinvoke strlen, txtline
     sub eax,1
     cinvoke memmove, Alarm1SoundWav,txtline,eax

     cinvoke fgets,  txtline,MAXPATH,[cfgfp]
     cinvoke strlen, txtline
     sub eax,1
     cinvoke memmove, lpmp3File,txtline,eax

     cinvoke fclose, [cfgfp]
.finished:
     ret
endp

;------------------------------------------------------------------------------
proc SetPreferences,hwin
     ;
     .if [mp3_autoplay] = TRUE
         cinvoke strcpy,mp3_file,lpmp3File
         cinvoke sprintf,mp3_open,mp3_openfmt,mp3_file
         invoke  mciSendStringA, mp3_close, mp3_nullstring, 0, 0
         invoke  mciSendStringA, mp3_open, mp3_nullstring, 0, 0
         .if [mp3_repeaton] = TRUE
             invoke  mciSendStringA, mp3_playrepeat, mp3_nullstring, 0, 0
         .else
             invoke  mciSendStringA, mp3_playonce, mp3_nullstring, 0, 0
         .endif
     .endif
     ;
     .if [DisplayDate] = TRUE
         stdcall GetDate,DateBuffer,[DDMMYY]
         cinvoke strcpy,WinTitleBuffer,ExWinTitle
         cinvoke strcat,WinTitleBuffer,DateBuffer
     .else
         cinvoke strcpy,WinTitleBuffer,wintitle
     .endif
     .if [Alarm1Set] = TRUE
          cinvoke wsprintfA,Alarm1SetBuf,Alarm1SetFmt,[Alarm1HH],[Alarm1MM],[Alarm1SS]
          cinvoke strcat,WinTitleBuffer,Alarm1SetBuf
     .endif
     invoke SetWindowTextA,[hwin],WinTitleBuffer
     ;
     .if [QtrChime] = TRUE
         mov [ChimeStyle],2
         jmp .L9
     .elseif [HourlyChime] = TRUE
         mov [ChimeStyle],1
     .else
         mov [ChimeStyle],0
     .endif
.L9:
     stdcall SetChime,[ChimeStyle]
     ;
     .if [Alarm1Set] = TRUE
         stdcall CheckAlarm,[Alarm1HH],[Alarm1MM],[Alarm1SS],[hAlarm1Sound], Alarm1SoundWav
     .endif
     ;
     stdcall IsGEWin2K
     .if eax = TRUE
         invoke GetWindowLongA,[hwin],GWL_EXSTYLE
         or     eax, WS_EX_LAYERED
         invoke SetWindowLongA,[hwin],GWL_EXSTYLE,eax
         .if [Transparent] = TRUE
             invoke SetLayeredWindowAttributes,[hwin],0,[Transparentval],LWA_ALPHA
         .else
             invoke SetLayeredWindowAttributes,[hwin],0,255,LWA_ALPHA
         .endif
     .endif
     ret
endp

;------------------------------------------------------------------------------
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
        shlwapi,  'SHLWAPI.DLL',\
        winmm,    'WINMM.DLL'

include '\api\kernel32.inc'
include '\api\user32.inc'
include '\api\comctl32.inc'
include '\api\shell32.inc'
include '\api\advapi32.inc'
include '\api\comdlg32.inc'
include '\api\gdi32.inc'
include '\api\wsock32.inc'
 
import  msvcrt,\
        strcat,    'strcat',\
        strcpy,    'strcpy',\
        strcmp,    'strcmp',\
        strlen,    'strlen',\
        memset,    'memset',\
        memmove,   'memmove',\
        fopen,     'fopen',\
        fclose,    'fclose',\
        sprintf,   'sprintf',\
        fprintf,   'fprintf',\
        fscanf,    'fscanf',\
        fgets,     'fgets'

import  shlwapi,\
        PathAppendA, 'PathAppendA'

import  winmm,\
        mciSendStringA, 'mciSendStringA',\
        PlaySound, 'PlaySound'

;------------------------------------------------------------------------------
section '.rsrc' data readable resource from 'B_BTDCLOCK.RES'
; end of file
