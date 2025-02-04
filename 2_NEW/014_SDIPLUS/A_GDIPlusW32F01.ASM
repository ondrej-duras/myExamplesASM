; ----------------------------------------------------------------------------
; -       TITULO  : Loading GIFs with GDI+ W-FASM                            -
; -----                                                                  -----
; -       AUTOR   : Alfonso Víctor Caballero Hurtado                         -
; -----                                                                  -----
; -       VERSION : 1.0                                                      -
; -----                                                                  -----
; -      (c) 2016. Abre los Ojos a Win32                                     -
; ----------------------------------------------------------------------------

format PE GUI 4.0
entry start

include 'win32a.inc'

cdXPos                 EQU  128
cdYPos                 EQU  128
cdXSize                EQU  200
cdYSize                EQU  100
cdColFondo             EQU  0;COLOR_BTNFACE + 1
cdMainIcon             EQU  100 ;IDI_APPLICATION
cdVCursor              EQU  IDC_ARROW
cdVBarTipo             EQU  NULL
cdVBtnTipo             EQU  WS_VISIBLE+WS_OVERLAPPEDWINDOW
cdIdTimer              EQU  1
PropertyTagFrameDelay  EQU 5100h

struct GdiplusStartupInput
    GdiplusVersion            dd ?
    DebugEventCallback        dd ?
    SuppressBackgroundThread  dd ?
    SuppressExternalCodecs    dd ?
ends

struct GUID
    Data1   dd ?
    Data2   dw ?
    Data3   dw ?
    Data4   db 8 dup ?
ends

section '.text' code readable executable
  proc fnTestForAnimatedGIF
    invoke      GdipImageGetFrameDimensionsCount, [gImage], nFrames
    cmp         dword [nFrames], 0
    jz          .Err_SinFrames
    mov         eax, sizeof.GUID
    mul         dword [nFrames]
    ; Obtenemos la lista de dimensiones de cada frame
    invoke      GdipAlloc, eax
    mov         [pDimIDs], eax   ; Puntero a GUID
    ; Get the list of frame dimensions from the Image object
    invoke      GdipImageGetFrameDimensionsList, [gImage], eax, [nFrames]
    or          eax, eax
    jnz         .Err_SinFrameDim
    ; Get the number of frames in the first dimension
    invoke      GdipImageGetFrameCount, [gImage], [pDimIDs], nFrames
    or          eax, eax
    jnz         .Err_SinFrames
    ; Obtenemos tamaño del item PropertyItemEquipMake
    invoke      GdipGetPropertyItemSize, [gImage], PropertyTagFrameDelay, nSize
    or          eax, eax
    jnz         .Err_ItemSize
    ; Reservamos búfer para recibir ese item
    mov         eax, 4   ;sizeof PROPID
    mul         dword [nSize]
    invoke      GdipAlloc, eax
    mov         [pPropertyItem], eax    ; puntero a 
    ; Obtenemos ese item
    invoke      GdipGetPropertyItem, [gImage], PropertyTagFrameDelay, [nSize], [pPropertyItem]
    or          eax, eax
    jnz         .Err_ItemProp
    ; Liberamos memoria
    invoke      GdipFree, [pDimIDs]
    xor         eax, eax
    jmp         .Fin
    .Err_SinFrames:
      invoke      MessageBox, NULL, szErrSinFrames, NULL, MB_ICONERROR
      mov         eax, 1
      jmp         .Fin
    .Err_SinFrameDim:
      invoke      MessageBox, NULL, szErrSinFrameDim, NULL, MB_ICONERROR
      mov         eax, 1
      jmp         .Fin
    .Err_ItemSize:
      invoke      MessageBox, NULL, szErrItemSize, NULL, MB_ICONERROR
      mov         eax, 2
      jmp         .Fin
    .Err_ItemProp:
      invoke      MessageBox, NULL, szErrItemProp, NULL, MB_ICONERROR
      mov         eax, 3
    .Fin:
    ret
  endp
  
  proc prLoadAnimGif
    invoke      GdipLoadImageFromFile, szAnimGif, gImage
    or          eax, eax
    jnz         .ErrorLeyendo
    stdcall     fnTestForAnimatedGIF
    or          eax, eax
    jnz         .ErrorFrames
    jmp         .lag_Fin
    
    .ErrorLeyendo:
      invoke    MessageBox, NULL, szErrLectura, NULL, MB_ICONERROR
      jmp       .lag_Fin
    .ErrorFrames:
      invoke    MessageBox, NULL, szErrFrames, NULL, MB_ICONERROR
    .lag_Fin:
    ret
  endp

  proc prDrawFrameGif, hdc
    stdcall   prGetGifSize
    or        eax, eax
    jnz       .dfg_Fin
    invoke    GdipCreateFromHDC, [hdc], graphics
    invoke    GdipDrawImageRectI, [graphics], [gImage], 0, 0, [vdxClient], [vdyClient]
    invoke    GdipDeleteGraphics, [graphics]
    ;
    mov       eax, dword [nFramePosition]
    inc       eax
    cmp       eax, [nFrames]
    jng       .dfg_Next
      mov       eax, 0
    .dfg_Next:
    mov       dword [nFramePosition], eax
    invoke    GdipImageSelectActiveFrame, [gImage], FrameDimensionTime, [nFramePosition]
    .dfg_Fin:
    ret
  endp

  proc prGetGifSize
    invoke    GdipGetImageWidth, [gImage], nWidth
    cmp       dword [nWidth], 0
    jz        .Err_Width
    invoke    GdipGetImageHeight, [gImage], nHeight
    cmp       dword [nHeight], 0
    jz        .Err_Width
    mov       eax, 0   ; Todo fue bien
    jmp       .ggs_Fin
    
    .Err_Width:
      invoke    MessageBox, NULL, szErrWidth, NULL, MB_ICONERROR
      mov       eax, 1
      jmp       .ggs_Fin
    .Err_Height:
      invoke    MessageBox, NULL, szErrHeight, NULL, MB_ICONERROR
      mov       eax, 2
    .ggs_Fin:
    ret
  endp

  proc WndProc uses ebx esi edi, hWnd, wMsg, wParam, lParam
      ;  Propósito: Procesa los mensajes provenientes de las ventanas
      ;  Entrada  : hwnd,wmsg,wparam,lparam
      ;  Salida   : Ninguna
      ;  Destruye : Ninguna
      local     clrold:DWORD

      mov       eax, [wMsg]
      cmp       eax, WM_DESTROY
      je        .wmdestroy
      cmp       eax, WM_SIZE
      je        .wmSize
      cmp       eax, WM_CHAR
      je        .wmChar
      cmp       eax, WM_PAINT
      je        .wmPaint
      cmp       eax, WM_CREATE
      je        .wmCreate
      cmp       eax, WM_TIMER
      je        .wmTimer

      .defwndproc:
        invoke    DefWindowProc, [hWnd], [wMsg], [wParam], [lParam]
        jmp       .finish2
      .wmPaint:
        invoke    BeginPaint, [hWnd], ps
        stdcall   prDrawFrameGif, eax
        invoke    EndPaint,[hWnd], ps
        jmp       .finish
      .wmTimer:
        invoke    InvalidateRect, [hWnd], NULL, TRUE
        jmp       .finish
      .wmSize:
        mov       eax, [lParam]
        and       eax, 0FFFFh
        mov       [vdxClient], eax
        mov       eax, [lParam]
        shr       eax, 10h
        mov       [vdyClient], eax
        jmp       .finish
      .wmCreate:
        mov       dword [nFramePosition], 0
        invoke    SetTimer, [hWnd], cdIdTimer, 100, NULL
        jmp       .finish
      .wmdestroy:
        invoke    KillTimer, [hWnd], cdIdTimer
        invoke    DestroyWindow, [hWnd]
        invoke    PostQuitMessage,0
        jmp       .finish
      .wmChar:
        cmp       [wParam], VK_ESCAPE
        jz        .wmdestroy
      .finish:
      xor       eax,eax
      .finish2:
      ret
  endp

  proc WinMain uses ebx esi edi, hInst, hPrevInst, CmdLine, CmdShow
      ;  Propósito: Inicializamos la ventana principal de la aplicación y captura errores, si los hubiere
      ;  Entrada  : hInst, hPrevInst, CmdLine, CmdShow
      ;  Salida   : Ninguna
      ;  Destruye : Ninguna
      mov       dword [gsi.GdiplusVersion], 1
      mov       dword [gsi.DebugEventCallback], 0
      mov       dword [gsi.SuppressBackgroundThread], 0
      mov       dword [gsi.SuppressExternalCodecs], 0
      invoke    GdiplusStartup, gtkn, gsi, 0
      stdcall   prLoadAnimGif
      or        eax, eax
      jnz       ErrorLeyendo
      stdcall   prGetGifSize
      or        eax, eax
      jnz       end_loop

      ; invoke    GetStockObject, LTGRAY_BRUSH
      ; mov       [wc.hbrBackground], eax
      invoke    LoadIcon, [hInst], cdMainIcon
      mov       [wc.hIcon], eax
      invoke    LoadCursor, 0, cdVCursor
      mov       [wc.hCursor], eax
      invoke    RegisterClass, wc
      test      eax, eax
      jz        error

      invoke    CreateWindowEx, cdVBarTipo, szClaseName, szTitulo,\
                cdVBtnTipo, cdXPos, cdYPos, cdXSize, cdYSize,\
                NULL, NULL, [wc.hInstance], NULL
      mov       [hMainWnd], eax
      test      eax, eax
      jz        error

      invoke    GetClientRect, [hMainWnd], rctClient
      invoke    GetWindowRect, [hMainWnd], rctWnd
      mov       eax, [rctWnd.right]
      sub       eax, [rctWnd.left]
      sub       eax, [rctClient.right]
      mov       dword [ptDiff.x], eax
      mov       eax, [rctWnd.bottom]
      sub       eax, [rctWnd.top]
      sub       eax, [rctClient.bottom]
      mov       dword [ptDiff.y], eax
      mov       eax, dword [nWidth]
      add       eax, [ptDiff.x]
      mov       ebx, dword [nHeight]
      add       ebx, [ptDiff.y]
      invoke    MoveWindow, [hMainWnd], cdXPos, cdYPos, eax, ebx, TRUE

      invoke    ShowWindow, [hMainWnd], SW_SHOWNORMAL
      invoke    UpdateWindow, [hMainWnd]

      msg_loop:
        invoke    GetMessage, msg, NULL, 0, 0
        cmp       eax,1
        jb        end_loop
        jne       msg_loop
        invoke    TranslateMessage, msg
        invoke    DispatchMessage, msg
      jmp       msg_loop

    ErrorLeyendo:
      invoke    MessageBox, NULL, szErrLectura, NULL, MB_ICONERROR
      jmp       end_loop
    error:
      invoke    MessageBox, NULL, MsgError, NULL, MB_ICONERROR + MB_OK

    end_loop:
      invoke    GdiplusShutdown, [gtkn]
      mov       eax, [msg.wParam]
      ret
  endp

  start:
    invoke    GetModuleHandle, 0
    mov       [wc.hInstance], eax
    invoke    GetCommandLine
    mov       [CommandLine], EAX
    stdcall   WinMain, [wc.hInstance], NULL, [CommandLine], SW_SHOWDEFAULT
    invoke    ExitProcess,[msg.wParam]

section '.bss' data readable writeable
  msg             MSG
  ps              PAINTSTRUCT
  rct             RECT
  rctWnd          RECT
  rctClient       RECT
  gsi             GdiplusStartupInput
  ptDiff          POINT
  CommandLine     rd       1
  hClientDC       rd       1
  hMainWnd        rd       1
  hBufDC          rd       1
  hdc             rd       1
  vdxClient       rd       1
  vdyClient       rd       1
  gImage          rd       1
  pDimIDs         rd       1
  pPropertyItem   rd       1
  nWidth          rd       1
  nHeight         rd       1
  nFrames         rd       1
  nFramePosition  rd       1
  gtkn            rd       1
  graphics        rd       1
  nSize           rd       1

section '.data' data readable writeable

  szClaseName         TCHAR    'ClaseGIFs',0
  szTitulo            TCHAR    'Loading GIFs - FASM',0
  MsgError            TCHAR    'Carga inicial fallida.',0
  szErrLectura        TCHAR 'Error leyendo gif',0
  szErrFrames         TCHAR 'Error en frames gif',0
  szAnimGif           du    "../Res/movingwizard.gif", 0  ; UNICODE string
  szErrSinFrames      TCHAR 'gif sin frames',0
  szErrItemSize       TCHAR 'error item size',0
  szErrItemProp       TCHAR 'error en la obtención de la propiedad del item',0
  szErrSinFrameDim    TCHAR 'sin frames en la primera dimensión',0
  szErrWidth          TCHAR 'error en ancho del frame del gif',0
  szErrHeight         TCHAR 'error en alto del frame del gif',0
  FrameDimensionTime  dd 6AEDBD6Dh, 418A3FB5h, 457FA683h, 72C89D22h
  wc                  WNDCLASS 0,WndProc,0,0,NULL,NULL,NULL,cdColFondo,NULL,szClaseName

section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\    ; Enlazamos las bibliotecas
          user32,'USER32.DLL',\
          gdi32,'GDI32.DLL',\
          gdiplus,'GDIPLUS.DLL'

  include 'api\kernel32.inc'           ; Incluímos las definiciones
  include 'api\user32.inc'
  include 'api\gdi32.inc'

  import  gdiplus,\
    GdiplusStartup,'GdiplusStartup',\
    GdiplusShutdown,'GdiplusShutdown',\
    GdipImageGetFrameDimensionsCount,'GdipImageGetFrameDimensionsCount',\
    GdipAlloc,'GdipAlloc',\
    GdipImageGetFrameDimensionsList,'GdipImageGetFrameDimensionsList',\
    GdipImageGetFrameCount,'GdipImageGetFrameCount',\
    GdipGetPropertyItemSize,'GdipGetPropertyItemSize',\
    GdipGetPropertyItem,'GdipGetPropertyItem',\
    GdipFree,'GdipFree',\
    GdipLoadImageFromFile,'GdipLoadImageFromFile',\
    GdipGetImageWidth,'GdipGetImageWidth',\
    GdipGetImageHeight,'GdipGetImageHeight',\
    GdipCreateFromHDC,'GdipCreateFromHDC',\
    GdipDrawImageRectI,'GdipDrawImageRectI',\
    GdipDeleteGraphics,'GdipDeleteGraphics',\
    GdipImageSelectActiveFrame,'GdipImageSelectActiveFrame'

section '.rsrc' resource data readable

  ; resource directory
  directory RT_ICON,icons,\
            RT_GROUP_ICON,group_icons,\
            RT_VERSION,versions

  ; resource subdirectories
  resource icons,\
       1,LANG_NEUTRAL,icon_data

  resource group_icons,\
           cdMainIcon, LANG_NEUTRAL, main_icon

  resource versions,\
       1,LANG_NEUTRAL,version

  icon main_icon, icon_data,  '../Res/a.ico'

  versioninfo version,VOS__WINDOWS32,VFT_APP,VFT2_UNKNOWN,LANG_SPANISH+SUBLANG_DEFAULT,0,\
              'FileDescription','Prog. 32 bits en Windows',\
              'InternalName', 'Win32Prog',\
              'ProductName', 'Win32Prog',\
              'LegalCopyright','All Rights Reserved',\
              'FileVersion','1.0.0',\
              'ProductVersion','1.0.0',\
              'CompanyName', '(c) abreojosensamblador.net'
