
; DirectDraw programming example

format PE GUI 4.0
entry start

include 'win32a.inc'

include 'B_DDRAW.INC'

section '.text' code readable executable

  start:

	and	[DDraw],0
	and	[DDSPrimary],0
	and	[DDSBack],0
	and	[DDPalette],0
	and	[DDSPicture],0

	invoke	GetModuleHandleA,NULL
	mov	[hinstance],eax

	invoke	LoadIconA,NULL,IDI_APPLICATION
	mov	[wc.hIcon],eax

	invoke	LoadCursorA,NULL,IDC_ARROW
	mov	[wc.hCursor],eax

	mov	[wc.style],0
	mov	[wc.lpfnWndProc],WindowProc
	mov	[wc.cbClsExtra],0
	mov	[wc.cbWndExtra],0
	mov	eax,[hinstance]
	mov	[wc.hInstance],eax
	mov	[wc.hbrBackground],0
	mov	dword [wc.lpszMenuName],NULL
	mov	dword [wc.lpszClassName],_class
	invoke	RegisterClassA,wc
	test	eax,eax
	jz	startup_error

	invoke	CreateWindowExA,\
		0,_class,_title,WS_POPUP+WS_VISIBLE,0,0,0,0,NULL,NULL,[hinstance],NULL
	test	eax,eax
	jz	startup_error
	mov	[hwnd],eax

	invoke	DirectDrawCreate,NULL,DDraw,NULL
	or	eax,eax
	jnz	ddraw_error

	cominvk DDraw,SetCooperativeLevel,\
		[hwnd],DDSCL_EXCLUSIVE+DDSCL_FULLSCREEN
	or	eax,eax
	jnz	ddraw_error

	cominvk DDraw,SetDisplayMode,\
		640,480,8
	or	eax,eax
	jnz	ddraw_error

	mov	[ddsd.dwSize],sizeof.DDSURFACEDESC
	mov	[ddsd.dwFlags],DDSD_CAPS+DDSD_BACKBUFFERCOUNT
	mov	[ddsd.ddsCaps.dwCaps],DDSCAPS_PRIMARYSURFACE+DDSCAPS_FLIP+DDSCAPS_COMPLEX
	mov	[ddsd.dwBackBufferCount],1
	cominvk DDraw,CreateSurface,\
		ddsd,DDSPrimary,NULL
	or	eax,eax
	jnz	ddraw_error

	mov	[ddscaps.dwCaps],DDSCAPS_BACKBUFFER
	cominvk DDSPrimary,GetAttachedSurface,\
		ddscaps,DDSBack
	or	eax,eax
	jnz	ddraw_error

	mov	esi,picture
	call	load_picture
	jc	open_error

	mov	esi,picture
	call	load_palette
	jc	open_error

	invoke	GetTickCount
	mov	[last_tick],eax

	jmp	paint

main_loop:

	invoke	PeekMessageA,msg,NULL,0,0,PM_NOREMOVE
	or	eax,eax
	jz	no_message
	invoke	GetMessageA,msg,NULL,0,0
	or	eax,eax
	jz	end_loop
	invoke	TranslateMessage,msg
	invoke	DispatchMessageA,msg

	jmp	main_loop

    no_message:
	cmp	[active],0
	je	sleep

	cominvk DDSPrimary,IsLost
	or	eax,eax
	jz	paint
	cmp	eax,DDERR_SURFACELOST
	jne	end_loop

	cominvk DDSPrimary,Restore

paint:

	mov	[rect.top],0
	mov	[rect.bottom],480
	mov	[rect.left],0
	mov	[rect.right],640

	cominvk DDSBack,BltFast,\
		0,0,[DDSPicture],rect,DDBLTFAST_SRCCOLORKEY
	or	eax,eax
	jnz	paint_done

	movzx	eax,[frame]
	xor	edx,edx
	mov	ebx,10
	div	ebx

	sal	eax,6
	add	eax,480
	mov	[rect.top],eax
	add	eax,64
	mov	[rect.bottom],eax
	sal	edx,6
	mov	[rect.left],edx
	add	edx,64
	mov	[rect.right],edx

	cominvk DDSBack,BltFast,\
		[x],[y],[DDSPicture],rect,DDBLTFAST_SRCCOLORKEY

	cominvk DDSPrimary,SetPalette,[DDPalette]

	cominvk DDSPrimary,Flip,0,0

    paint_done:

	invoke	GetTickCount
	mov	ebx,eax
	sub	ebx,[last_tick]
	cmp	ebx,20
	jb	main_loop
	add	[last_tick],20

	inc	[frame]
	cmp	[frame],60
	jb	main_loop
	mov	[frame],0
	jmp	main_loop

sleep:
	invoke	WaitMessage
	jmp	main_loop

ddraw_error:
	mov	eax,_ddraw_error
	jmp	error
open_error:
	mov	eax,_open_error
    error:
	invoke	MessageBoxA,[hwnd],eax,_error,MB_OK+MB_ICONERROR
	invoke	DestroyWindow,[hwnd]
	invoke	PostQuitMessage,1
	jmp	main_loop
startup_error:
	invoke	MessageBoxA,[hwnd],_startup_error,_error,MB_OK+MB_ICONERROR
end_loop:

	cmp	[DDSPicture],0
	je	picture_released
	cominvk DDSPicture,Release
    picture_released:
	cmp	[DDPalette],0
	je	palette_released
	cominvk DDPalette,Release
    palette_released:
	cmp	[DDSBack],0
	je	back_surface_released
	cominvk DDSPrimary,DeleteAttachedSurface,0,DDSBack
    back_surface_released:
	cmp	[DDSPrimary],0
	je	primary_surface_released
	cominvk DDSPrimary,Release
    primary_surface_released:
	cmp	[DDraw],0
	je	ddraw_released
	cominvk DDraw,Release
    ddraw_released:

	invoke	ExitProcess,[msg.wParam]

include 'C_GIF87A.INC'

proc WindowProc hwnd,wmsg,wparam,lparam
	push	ebx esi edi
	mov	eax,[wmsg]
	cmp	eax,WM_CREATE
	je	.wmcreate
	cmp	eax,WM_DESTROY
	je	.wmdestroy
	cmp	eax,WM_ACTIVATE
	je	.wmactivate
	cmp	eax,WM_SETCURSOR
	je	.wmsetcursor
	cmp	eax,WM_MOUSEMOVE
	je	.wmmousemove
	cmp	eax,WM_KEYDOWN
	je	.wmkeydown
    .defwindowproc:
	invoke	DefWindowProcA,[hwnd],[wmsg],[wparam],[lparam]
	jmp	.finish
    .wmcreate:
	xor	eax,eax
	jmp	.finish
    .wmkeydown:
	cmp	[wparam],VK_ESCAPE
	jne	.finish
    .wmdestroy:
	cominvk DDraw,RestoreDisplayMode
	invoke	PostQuitMessage,0
	xor	eax,eax
	jmp	.finish
    .wmactivate:
	mov	eax,[wparam]
	mov	[active],al
	jmp	.finish
    .wmsetcursor:
	invoke	SetCursor,0
	xor	eax,eax
	jmp	.finish
    .wmmousemove:
	movsx	eax,word [lparam]
	mov	[x],eax
	movsx	eax,word [lparam+2]
	mov	[y],eax
    .finish:
	pop	edi esi ebx
	ret
endp

section '.data' data readable writeable

  _title db 'flat assembler DirectDraw application',0
  _class db 'FDDRAW32',0

  _error db 'Error',0
  _startup_error db 'Startup failed.',0
  _ddraw_error db 'Direct Draw initialization failed.',0
  _open_error db 'Failed opening data file.',0

  picture db 'D_DDRAW.GIF',0

section '.bss' readable writeable

  hinstance dd ?
  hwnd dd ?
  wc WNDCLASS
  msg MSG

  ddsd DDSURFACEDESC
  ddscaps DDSCAPS

  DDraw DirectDraw
  DDSPrimary DirectDrawSurface
  DDSBack DirectDrawSurface

  DDSPicture DirectDrawSurface
  DDPalette DirectDrawPalette

  bytes_count dd ?
  last_tick dd ?
  frame db ?
  active db ?
  LZW_bits db ?
  LZW_table rd (0F00h-2)*2
  buffer rb 40000h
  rect RECT
  x dd ?
  y dd ?

section '.idata' import data readable

  library kernel,'KERNEL32.DLL',\
	  user,'USER32.DLL',\
	  ddraw,'DDRAW.DLL'

  import kernel,\
	 GetModuleHandleA,'GetModuleHandleA',\
	 CreateFileA,'CreateFileA',\
	 ReadFile,'ReadFile',\
	 CloseHandle,'CloseHandle',\
	 GetTickCount,'GetTickCount',\
	 ExitProcess,'ExitProcess'

  import user,\
	 RegisterClassA,'RegisterClassA',\
	 CreateWindowExA,'CreateWindowExA',\
	 DestroyWindow,'DestroyWindow',\
	 DefWindowProcA,'DefWindowProcA',\
	 GetMessageA,'GetMessageA',\
	 PeekMessageA,'PeekMessageA',\
	 TranslateMessage,'TranslateMessage',\
	 DispatchMessageA,'DispatchMessageA',\
	 LoadCursorA,'LoadCursorA',\
	 LoadIconA,'LoadIconA',\
	 SetCursor,'SetCursor',\
	 MessageBoxA,'MessageBoxA',\
	 PostQuitMessage,'PostQuitMessage',\
	 WaitMessage,'WaitMessage'

  import ddraw,\
	 DirectDrawCreate,'DirectDrawCreate'
