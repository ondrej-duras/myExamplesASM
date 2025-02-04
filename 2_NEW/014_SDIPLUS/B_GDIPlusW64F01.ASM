; ----------------------------------------------------------------------------
; -       TITULO  : Loading GIFs with GDI+ W-FASM                            -
; -----                                                                  -----
; -       AUTOR   : Alfonso Víctor Caballero Hurtado                         -
; -----                                                                  -----
; -       VERSION : 1.0                                                      -
; -----                                                                  -----
; -      (c) 2016. Abre los Ojos a Win32                                     -
; ----------------------------------------------------------------------------

format PE64 GUI 5.0
entry start

include 'win64a.inc'
cdXPos                 EQU  128
cdYPos                 EQU  128
cdXSize                EQU  256
cdYSize                EQU  256
cdColFondo             EQU  0  ;COLOR_BTNFACE + 1
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
    cmp         qword [nFrames], 0
    jz          .Err_SinFrames
    mov         rax, sizeof.GUID
    mul         qword [nFrames]
    ; Obtenemos la lista de dimensiones de cada frame
    invoke      GdipAlloc, rax
    mov         [pDimIDs], rax   ; Puntero a GUID
    ; Get the list of frame dimensions from the Image object
    invoke      GdipImageGetFrameDimensionsList, [gImage], rax, [nFrames]
    or          rax, rax
    jnz         .Err_SinFrameDim
    ; Get the number of frames in the first dimension
    invoke      GdipImageGetFrameCount, [gImage], [pDimIDs], nFrames
    or          rax, rax
    jnz         .Err_SinFrames
    ; Obtenemos tamaño del item PropertyItemEquipMake
    invoke      GdipGetPropertyItemSize, [gImage], PropertyTagFrameDelay, nSize
    or          rax, rax
    jnz         .Err_ItemSize
    ; Reservamos búfer para recibir ese item
    mov         rax, 4   ;sizeof PROPID
    mul         qword [nSize]
    invoke      GdipAlloc, rax
    mov         [pPropertyItem], rax    ; puntero a 
    ; Obtenemos ese item
    invoke      GdipGetPropertyItem, [gImage], PropertyTagFrameDelay, [nSize], [pPropertyItem]
    or          rax, rax
    jnz         .Err_ItemProp
    ; Liberamos memoria
    invoke      GdipFree, [pDimIDs]
    xor         rax, rax
    jmp         .Fin
    .Err_SinFrames:
      invoke      MessageBox, NULL, szErrSinFrames, NULL, MB_ICONERROR
      mov         rax, 1
      jmp         .Fin
    .Err_SinFrameDim:
      invoke      MessageBox, NULL, szErrSinFrameDim, NULL, MB_ICONERROR
      mov         rax, 1
      jmp         .Fin
    .Err_ItemSize:
      invoke      MessageBox, NULL, szErrItemSize, NULL, MB_ICONERROR
      mov         rax, 2
      jmp         .Fin
    .Err_ItemProp:
      invoke      MessageBox, NULL, szErrItemProp, NULL, MB_ICONERROR
      mov         rax, 3
    .Fin:
    ret
  endp
  
  proc prLoadAnimGif
    invoke      GdipLoadImageFromFile, szAnimGif, gImage
    or          rax, rax
    jnz         .ErrorLeyendo
    stdcall     fnTestForAnimatedGIF
    or          rax, rax
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
  
  proc prDrawFrameGif
    stdcall   prGetGifSize
    or        rax, rax
    jnz       .dfg_Fin
    invoke    GdipCreateFromHDC, [hClientDC], graphics
    invoke    GdipDrawImageRectI, [graphics], [gImage], 0, 0, [vdxClient], [vdyClient]
    invoke    GdipDeleteGraphics, [graphics]
    ;
    mov       rax, qword [nFramePosition]
    inc       rax
    cmp       rax, [nFrames]
    jng       .dfg_Next
      mov       rax, 0
    .dfg_Next:
    mov       qword [nFramePosition], rax
    invoke    GdipImageSelectActiveFrame, [gImage], FrameDimensionTime, [nFramePosition]
    .dfg_Fin:
    ret
  endp
  
  proc prGetGifSize
    invoke    GdipGetImageWidth, [gImage], nWidth
    cmp       qword [nWidth], 0
    jz        .Err_Width
    invoke    GdipGetImageHeight, [gImage], nHeight
    cmp       qword [nHeight], 0
    jz        .Err_Width
    mov       rax, 0   ; Todo fue bien
    jmp       .ggs_Fin
    
    .Err_Width:
      invoke    MessageBox, NULL, szErrWidth, NULL, MB_ICONERROR
      mov       rax, 1
      jmp       .ggs_Fin
    .Err_Height:
      invoke    MessageBox, NULL, szErrHeight, NULL, MB_ICONERROR
      mov       rax, 2
    .ggs_Fin:
    ret
  endp

  proc WindowProc uses rbx rsi rdi, hwnd,wmsg,wparam,lparam
    local  pWnd:QWORD

    ;mov     [hwnd], rcx
    ;mov     [wmsg], rdx
    ;mov     [wparam], r8
    ;mov     [lparam], r9

    cmp    rdx, WM_DESTROY
    je     .wmDestroy
    cmp    rdx, WM_SIZE
    je     .wmSize
    cmp    rdx, WM_CHAR
    je     .wmChar
    cmp    rdx, WM_PAINT
    je     .wmPaint
    cmp    rdx, WM_CREATE
    je     .wmCreate
    cmp    rdx, WM_TIMER
    je     .wmTimer
    
    .defwndproc:
      invoke    DefWindowProc,rcx,rdx,r8,r9
      jmp       .finish2

    .wmPaint:
      mov       [pWnd], rcx
      invoke    BeginPaint, rcx, ps
      mov       [hClientDC], rax
      stdcall   prDrawFrameGif
      invoke    EndPaint, [pWnd], ps
      jmp       .finish

    .wmTimer:
      ;rcx es [hwnd]
      invoke    InvalidateRect, rcx, NULL, TRUE
      jmp       .finish

    .wmSize:
      mov       rax, r9 ;[lparam]
      and       rax, 0FFFFh
      mov       [vdxClient], rax
      mov       rax, r9 ;[lparam]
      shr       rax, 10h
      mov       [vdyClient], rax
      jmp       .finish

    .wmCreate:
      mov       qword [nFramePosition], 0
      ;rcx es [hwnd]
      invoke    SetTimer, rcx, cdIdTimer, 100, NULL
      jmp       .finish

    .wmDestroy:
      mov       [pWnd], rcx
      invoke    KillTimer, [pWnd], cdIdTimer
      invoke    DestroyWindow, [pWnd]
      invoke    PostQuitMessage,0
      jmp       .finish

    .wmChar:
      cmp       r8, VK_ESCAPE  ; [wParam]
      jz        .wmDestroy
      
    .finish:
      xor     rax,rax
    .finish2:
    ret
  endp

  start:
    sub       rsp, 8    ; Make stack dqword aligned

    mov       qword [gsi.GdiplusVersion], 1
    mov       qword [gsi.DebugEventCallback], 0
    mov       qword [gsi.SuppressBackgroundThread], 0
    mov       qword [gsi.SuppressExternalCodecs], 0
    invoke    GdiplusStartup, gtkn, gsi, 0
    stdcall   prLoadAnimGif
    or        rax, rax
    jnz       ErrorLeyendo
    stdcall   prGetGifSize
    or        rax, rax
    jnz       end_loop


    invoke    GetModuleHandle,0
    mov       [wc.hInstance],rax
    invoke    LoadIcon,rax,cdMainIcon
    mov       [wc.hIcon],rax
    mov       [wc.hIconSm],rax
    invoke    LoadCursor,0,IDC_ARROW
    mov       [wc.hCursor],rax
    invoke    RegisterClassEx,wc
    test      rax,rax
    jz        error

    invoke    CreateWindowEx, cdVBarTipo, szClass, szTitle,\
              cdVBtnTipo, cdXPos, cdYPos, cdXSize, cdYSize,\
              NULL, NULL, [wc + WNDCLASSEX.hInstance],NULL
    mov       [hMainWnd], rax
    test      rax,rax
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
    invoke    MoveWindow, [hMainWnd], cdXPos, cdYPos, rax, rbx, TRUE

    invoke    ShowWindow, [hMainWnd], SW_SHOWNORMAL
    invoke    UpdateWindow, [hMainWnd]

    msg_loop:
    invoke    GetMessage,msg,NULL,0,0
    cmp       rax,1
    jb        end_loop
    jne       msg_loop
    invoke    TranslateMessage,msg
    invoke    DispatchMessage,msg
    jmp       msg_loop

    ErrorLeyendo:
      invoke    MessageBox, NULL, szErrLectura, NULL, MB_ICONERROR
      jmp       end_loop
    error:
      invoke    MessageBox,NULL,MsgError,NULL,MB_ICONERROR+MB_OK

    end_loop:
    invoke    GdiplusShutdown, [gtkn]
    invoke    ExitProcess,[msg.wParam]

section '.bss' data readable writeable
  msg             MSG
  rctWnd          RECT
  rctClient       RECT
  ps              PAINTSTRUCT
  gsi             GdiplusStartupInput
  ptDiff          POINT
  hClientDC       rq       1
  hMainWnd        rq       1
  hBufDC          rq       1
  vdxClient       rq       1
  vdyClient       rq       1
  gImage          rq       1
  pDimIDs         rq       1
  pPropertyItem   rq       1
  nWidth          rq       1
  nHeight         rq       1
  nFrames         rq       1
  nFramePosition  rq       1
  gtkn            rq       1
  graphics        rq       1
  nSize           rq       1


section '.data' data readable writeable

  wc          WNDCLASSEX sizeof.WNDCLASSEX,0,WindowProc,0,0,NULL,NULL,NULL,cdColFondo,NULL,szClass,NULL

  szTitle            TCHAR 'Loading GIFs - FASM',0
  szClass            TCHAR 'ClaseGIFs',0
  MsgError           TCHAR 'Carga inicial fallida',0
  szErrLectura       TCHAR 'Error leyendo gif',0
  szErrFrames        TCHAR 'Error en frames gif',0
  szAnimGif          du    "../Res/movingwizard.gif", 0  ; UNICODE string
  szErrSinFrames     TCHAR 'gif sin frames',0
  szErrItemSize      TCHAR 'error item size',0
  szErrItemProp      TCHAR 'error en la obtención de la propiedad del item',0
  szErrSinFrameDim   TCHAR 'sin frames en la primera dimensión',0
  szErrWidth         TCHAR 'error en ancho del frame del gif',0
  szErrHeight        TCHAR 'error en alto del frame del gif',0
  FrameDimensionTime dd 6AEDBD6Dh, 418A3FB5h, 457FA683h, 72C89D22h

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

;  ; resource directory
;  directory RT_ICON,icons,\
;            RT_GROUP_ICON,group_icons,\
;            RT_VERSION,versions
;
;  ; resource subdirectories
;  resource icons,\
;       1,LANG_NEUTRAL,icon_data
;
;  resource group_icons,\
;           cdMainIcon, LANG_NEUTRAL, main_icon
;
;  resource versions,\
;       1,LANG_NEUTRAL,version
;
;  icon main_icon, icon_data,  '../Res/a64.ico'
;
;  versioninfo version,VOS__WINDOWS32,VFT_APP,VFT2_UNKNOWN,LANG_SPANISH+SUBLANG_DEFAULT,0,\
;              'FileDescription','Prog. 64 bits en Windows',\
;              'InternalName', 'Win64Prog',\
;              'ProductName', 'Win64Prog',\
;              'LegalCopyright','All Rights Reserved',\
;              'FileVersion','1.0.0',\
;              'ProductVersion','1.0.0',\
;              'CompanyName', '(c) abreojosensamblador.net'
