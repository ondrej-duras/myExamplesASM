;===============================================================================
;Program        : Win32Console
;Version        : 0.0.1
;Author         : Yeoh HS
;Date           : Nov 2009, edited in December 2017
;Purpose        : a simple Win32 console program template
;Flat Assembler : 1.73.01
;Resources      : Win32Console.res (created with Pelles C)
;===============================================================================

format PE CONSOLE 4.0
entry start

include 'win32ax.inc'
include 'macro\if.inc'

section '.data' data readable writeable
    CRLF         db '',13,10,0
    strfmt       db '%s',0
    cmdline      rb 260
    strsep       db " ",0
    strtokretval rb 1024
    arg1         rb 32
    arg2         rb 32
    arg3         rb 32

section '.code' code readable executable
start:
    stdcall getcmdargs
    cinvoke printf, strfmt, arg1
    cinvoke printf, strfmt, CRLF
    cinvoke printf, strfmt, arg2
    cinvoke printf, strfmt, CRLF
    cinvoke printf, strfmt, arg3
    cinvoke printf, strfmt, CRLF

.finished:
    invoke  ExitProcess,0

;-------------------------------------------------------------------------------
proc showhelp
     cinvoke printf, strfmt, CRLF
     cinvoke printf, strfmt, 'Program Name version 0.0.1 Copyright (c) 2009 by Yeoh HS'
     cinvoke printf, strfmt, CRLF
     cinvoke printf, strfmt, 'Usage: prog arg1 arg2 arg3'
     cinvoke printf, strfmt, CRLF
     cinvoke printf, strfmt, 'arg1 - purpose of arg1'
     cinvoke printf, strfmt, CRLF
     cinvoke printf, strfmt, 'arg2 - purpose of arg2'
     cinvoke printf, strfmt, CRLF
     cinvoke printf, strfmt, 'arg3 - purpose of arg3'
     cinvoke printf, strfmt, CRLF
     ret
endp

;-------------------------------------------------------------------------------
proc getcmdargs
    invoke GetCommandLine
    cinvoke strcpy,cmdline,eax

    cinvoke strtok, cmdline,strsep
    mov dword[strtokretval], eax

    cinvoke strtok, NULL,strsep
    mov dword[strtokretval],eax
    .if dword[strtokretval] = NULL
        stdcall showhelp
        jmp .finished
    .else
        cinvoke strcpy, arg1, dword[strtokretval]
    .endif

    cinvoke strtok, NULL,strsep
    mov dword[strtokretval], eax
    .if dword[strtokretval] = NULL
        stdcall showhelp
        jmp .finished
    .else
        cinvoke strcpy, arg2, dword[strtokretval]
    .endif

    cinvoke strtok, NULL,strsep
    mov dword[strtokretval], eax
    .if dword[strtokretval] = NULL
        stdcall showhelp
        jmp .finished
    .else
        cinvoke strcpy, arg3, dword[strtokretval]
    .endif
     jmp .okay
.finished:
    invoke  ExitProcess,0
.okay:
     ret
endp

;-------------------------------------------------------------------------------
section '.idata' import data readable writeable

library kernel32,'kernel32.dll',\
        msvcrt,  'msvcrt.dll'

include 'api\kernel32.inc'

import msvcrt,\
       strcpy, 'strcpy',\
       strtok, 'strtok',\
       printf, 'printf'
;-------------------------------------------------------------------------------
;section '.rsrc' data readable resource from 'win32console.res'

; end of file ==================================================================
