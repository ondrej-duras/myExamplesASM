;##########################################################################
; dll2inc
; version 1.1
; 07.12.2003 - 10.03.2003
; coded by comrade <comrade2k@hotmail.com>
; IRC: #asm, #coders, #win32asm on EFnet
; Web: http://comrade64.cjb.net/
;      http://comrade.win32asm.com/
;##########################################################################
; version 1.2
; (03/II/2022)
; updated by RootDmytro
; GitHub: https://github.com/RootDmytro
;##########################################################################
format PE console 4.0
entry start
;##########################################################################
_TITLE          equ  "dll2inc"
_NAME           equ  "dll2inc"
_VERSION        equ  "1.2"
_VERSIONTEXT    equ  _VERSION

;##########################################################################
include 'win32a.inc'
include 'macro/if.inc'
include 'macros.inc'
include 'imagehdr.inc'

;##########################################################################
;##########################################################################
section '.code' code readable executable

;##########################################################################
start:
        push    ebx esi edi
        invoke  GetStdHandle, STD_OUTPUT_HANDLE
        mov     [hStdOut], eax
        mov     [hOutFile], eax
        stdcall ProcessCmdLine
        stdcall ReadCmd
        test    eax, eax
        jnz .err

        stdcall OpenFiles, [lpszSourceFile]
        test    eax, eax
        jnz .err

        ; DOS Headers
        invoke  ReadFile, [hFile], doshdr, sizeof.IMAGE_DOS_HEADER, esp, 0
        cmp     [doshdr.e_magic], "MZ"
        mov     eax, szErrInvalidFormat
        jne .err

        ; NT Headers
        mov     [dwDataDirPtr], nthdrsxx.nthdrs.OptionalHeader.DataDirectory
        invoke  SetFilePointer, [hFile], [doshdr.e_lfanew], 0, FILE_BEGIN
        invoke  ReadFile, [hFile], nthdrsxx, sizeof.IMAGE_NT_HEADERS32 - sizeof.IMAGE_DATA_DIRECTORY*16, esp, 0
        cmp     [nthdrsxx.nthdrs.Signature], "PE"
        mov     eax, szErrInvalidFormat
        jne .err
        cmp     [nthdrsxx.nthdrs.OptionalHeader.Magic], IMAGE_NT_OPTIONAL_HDR32_MAGIC
        je .loadsec
        cmp     [nthdrsxx.nthdrs.OptionalHeader.Magic], IMAGE_NT_OPTIONAL_HDR64_MAGIC
        je .loadpe64
        mov     eax, szErrInvalidFormat
        jmp .err

.loadpe64:
        mov     [dwDataDirPtr], nthdrsxx.nthdrs64.OptionalHeader.DataDirectory
        invoke  SetFilePointer, [hFile], [doshdr.e_lfanew], 0, FILE_BEGIN
        invoke  ReadFile, [hFile], nthdrsxx, sizeof.IMAGE_NT_HEADERS64 - sizeof.IMAGE_DATA_DIRECTORY*16, esp, 0

.loadsec:
        cmp     [cSecMethod], "H"
        jne .loadseci
        stdcall secheuristic
        test    eax, eax
        jnz .err
        jmp .secloaded
.loadseci:
        stdcall secindexed
        test    eax, eax
        jnz .err
.secloaded:

        stdcall findsec
        test    eax, eax
        jnz .err

        ; read export table
        mov     esi, [dwExportsOffset]
        sub     esi, [sechdr.VirtualAddress]
        add     esi, [sechdr.PointerToRawData]
        invoke  SetFilePointer, [hFile], esi, 0, FILE_BEGIN
        invoke  ReadFile, [hFile], expdir, sizeof.IMAGE_EXPORT_DIRECTORY, esp, 0

        ; read library name
        mov     eax, [expdir.nName]
        sub     eax, [sechdr.VirtualAddress]
        add     eax, [sechdr.PointerToRawData]
        invoke  SetFilePointer, [hFile], eax, 0, FILE_BEGIN
        invoke  ReadFile, [hFile], szName, 100h, esp, 0

        ; split file name and extension
        mov     eax, szName-1
.lib:   inc     eax
        lcase   byte [eax]
        cmp     byte [eax], "."
        jne @F
        mov     byte [eax], 0
@@:     cmp     byte [eax], 0
        jne .lib
        inc     eax ; eax now points to extension string

        ; initialize declaration list
        ; 2 extra arguments will be used by szFullLibraryFormat in future version
        cinvoke wsprintf, szMessage, szLibraryFormat, szName, szName, eax, szName
        invoke  WriteFile, [hOutFile], szMessage, eax, esp, 0

        ; iterate over names
        mov     eax, [expdir.AddressOfNames]
        sub     eax, [sechdr.VirtualAddress]
        add     eax, [sechdr.PointerToRawData]
        mov     [dwPosition], eax

.name:  dec     [expdir.NumberOfNames]
        jl .quit
        invoke  SetFilePointer, [hFile], [dwPosition], 0, FILE_BEGIN
        add     [dwPosition], 04h
        invoke  ReadFile, [hFile], lpName, 04h, esp, 0 ; read name ptr

        mov     eax, [lpName]
        sub     eax, [sechdr.VirtualAddress]
        add     eax, [sechdr.PointerToRawData]
        invoke  SetFilePointer, [hFile], eax, 0, FILE_BEGIN
        invoke  ReadFile, [hFile], szName, 100h, esp, 0 ; read name

        ; copy current name to szAlias buffer
        mov     esi, szName
        mov     edi, szAlias
        xor     eax, eax
.char:  lodsb
        test    al, al
        stosb
        jnz .char

        cmp     [cFormat], 0    ; format none
        je .outn
        mov     al, [esi-02h]
        cmp     al, "A"
        je .chkf
        cmp     al, "W"
        jne .outn
.chkf:  cmp     al, [cFormat]
        jne .name
        mov     byte [edi-02h], 0
.outn:  cinvoke wsprintf, szMessage, szImportFormat, szAlias, szName
        invoke  WriteFile, [hOutFile], szMessage, eax, esp, 0
        cmp     [expdir.NumberOfNames], 0
        je .endln
        invoke  WriteFile, [hOutFile], szNext, 5, esp, 0
        jmp .name
.endln: invoke  WriteFile, [hOutFile], szNewLine, 2, esp, 0
        jmp .name

.err:   mov     ebx, eax
        test    ebx, ebx
        jnz @F
        invoke  GetLastError
        invoke  FormatMessage, FORMAT_MESSAGE_FROM_SYSTEM, 0, eax, 0, szMessage, 100h, 0
        mov     ebx, szMessage
@@:     stdcall strlen, ebx
        invoke  WriteFile, [hStdOut], ebx, eax, esp, 0
.quit:  invoke  CloseHandle, [hOutFile]
        invoke  CloseHandle, [hFile]
        pop     edi esi ebx
        invoke  ExitProcess, 0
        ret

;##########################################################################
align 16

; side effects: argv, argc
proc ProcessCmdLine
        push    ebx esi edi
        invoke  GetCommandLine
        mov     esi, eax
        mov     edi, argv

        xor     ecx, ecx
        xor     ebx, ebx
        xor     edx, edx

.cmss:  mov     eax, esi
        mov     dl, 20h
        cmp     byte [esi], 22h
        sete    cl
        lea     edx, [edx+ecx*2]
        add     eax, ecx
        stosd
.cm00:  inc     esi
        cmp     byte [esi], 0
        je .cm01
        cmp     byte [esi], dl
        jne .cm00
        mov     byte [esi], 0
        add     esi, ecx
        inc     esi
        cmp     byte [esi], 0
        je .cm01
        inc     [argc]
        jmp .cmss
.cm01:  pop     edi esi ebx
        inc     [argc]
        ret
endp

;##########################################################################
align 16

; side effects: cFormat, cSecMethod, lpszSourceFile
; returns zero or error string
proc ReadCmd
        push    ebx esi edi
        mov     eax, [argc]
        dec     eax
        shl     eax, 2
        mov     ebx, [argv+eax]

        cmp     [argc], 2
        mov     eax, szMsgAbout
        jb .err
        cmp     [argc], 4
        ja .err

        lea     esi, [argv+04h]
        xor     edx, edx         ; format none
        mov     ecx, [argc]
        dec     ecx
.readargs:
        dec     ecx
        jz .argok
        lodsd

        cmp     word [eax], "/a"
        jne @F
        mov     dl, "A"          ; format ansi
        jmp .readargs
     @@:
        cmp     word [eax], "/u"
        jne @F
        mov     dl, "W"          ; format unicode
        jmp .readargs
     @@:
        cmp     word [eax], "/h"
        jne @F
        mov     dh, "H"          ; section reading method heuristic
        jmp .readargs
     @@:
        cmp     word [eax], "/i"
        jne @F
        mov     dh, "I"          ; default section reading method indexing
        jmp .readargs
     @@:

        jmp .readargs


.argok:
        mov     [cFormat], dl
        mov     [cSecMethod], dh
        mov     [lpszSourceFile], ebx
        xor     eax, eax
.err:
        pop     edi esi ebx
        ret
endp

;##########################################################################
align 16

; returns NULL on success or lpsz error message on error
; side effects: hFile, szOutFilePath, hOutFile
proc OpenFiles source
        invoke  CreateFile,[source],GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,0,0
        mov     [hFile], eax
        mov     ecx, szErrOpenSource
        cmp     eax, INVALID_HANDLE_VALUE
        je .err

        stdcall AppendExtension, [source], szOutFilePath

        invoke  CreateFile,szOutFilePath,GENERIC_WRITE,FILE_SHARE_WRITE,0,CREATE_ALWAYS,0,0
        mov     [hOutFile], eax
        mov     ecx, szErrCreateOutF
        cmp     eax, INVALID_HANDLE_VALUE
        je .err
        xor     ecx, ecx
  .err: mov     eax, ecx
        ret
endp

;##########################################################################
align 16

proc strlen src
        xor     eax, eax
        mov     edx, [src]
        test    edx, edx
        jz .quit
        dec     eax
        dec     edx
@@:     inc     edx
        inc     eax
        cmp     byte [edx], 0
        jne @B
.quit:  ret
endp

align 16
        ; copy file path and name and append .inc extension
proc AppendExtension src, dst
        push    ebx esi edi
        mov     esi, [src]
        mov     edi, [dst]
  .scanpath:
        lodsb
        test    al, al
        jz .endscan
        stosb
        jmp .scanpath
  .endscan:
        cmp     byte [edi-4], "."
        jne .append
        sub     edi, 4
  .append:
        mov     esi, szIncExtension
        movsd
        stosb
        pop     edi esi ebx
        ret
endp

align 16

; side effects: dwPosition, [dwDataDirPtr]
; returns zero or error string
proc secheuristic
        push    ebx esi edi
        ; NumberOfRvaAndSizes should contain actual number of IMAGE_DATA_DIRECTORY entries at DataDirectory
        ; but it doesn't have to be true.
        ; Also number entries can be different from the default 16. It can be anything even 0.
        ; Just look for first section instead
        mov     edi, [dwDataDirPtr]
        mov     ebx, IMAGE_NUMBEROF_DIRECTORY_ENTRIES * 2
.findsec:
        invoke  SetFilePointer, [hFile], 0, 0, FILE_CURRENT
        mov     [dwPosition], eax
        invoke  ReadFile, [hFile], edi, sizeof.IMAGE_DATA_DIRECTORY, esp, 0
        cmp     byte [edi], '.'
        jne .contsearch
        cmp     byte [edi+1], 9h
        jb .contsearch
        cmp     byte [edi+1], 7Fh
        jna .secfound
.contsearch:
        add     edi, sizeof.IMAGE_DATA_DIRECTORY
        dec     ebx
        jnz .findsec
        mov     eax, szErrInvalidFormat
        jmp .end
.secfound:
        invoke  SetFilePointer, [hFile], [dwPosition], 0, FILE_BEGIN
        xor     eax, eax
.end:
        pop     edi esi ebx
        ret
endp

align 16

; side effects: dwPosition, [dwDataDirPtr]
; returns zero or error string
proc secindexed
        push    ebx esi edi
        mov     edi, [dwDataDirPtr]
        mov     eax, [edi-4]
        mov     ebx, sizeof.IMAGE_DATA_DIRECTORY
        mul     ebx
        invoke  ReadFile, [hFile], edi, eax, esp, 0
        invoke  SetFilePointer, [hFile], 0, 0, FILE_CURRENT
        mov     [dwPosition], eax
        xor     eax, eax
        pop     edi esi ebx
        ret
endp

align 16

; side effects: dwExportsOffset
; returns zero or error string
proc findsec
        push    ebx esi edi
        mov     esi, [dwDataDirPtr] ; load ptr to 0-directory: IMAGE_DIRECTORY_ENTRY_EXPORT
        mov     esi, [esi] ; load VirtualAddress ptr
        movzx   ebx, [nthdrsxx.nthdrs.FileHeader.NumberOfSections]

        ; find corresponding section
.sec:   dec     ebx
        mov     eax, szErrInvalidFormat
        jl .err
        invoke  ReadFile, [hFile], sechdr, sizeof.IMAGE_SECTION_HEADER, esp, 0
        mov     eax, [sechdr.VirtualAddress]
        cmp     eax, esi
        ja .sec
        add     eax, [sechdr.SizeOfRawData]
        cmp     eax, esi
        jb .sec
        mov     [dwExportsOffset], esi
.end:
        xor     eax, eax
.err:
        pop     edi esi ebx
        ret
endp

;##########################################################################
;##########################################################################
;##########################################################################
;##########################################################################
section ".data" data readable writeable
    data import
        library kernel32,"kernel32.dll",user32,"user32.dll"
        include "%include%/api/kernel32.inc"
        include "%include%/api/user32.inc"
    end data
;##########################################################################
;##########################################################################

        db "^doshdr        $"
        doshdr          IMAGE_DOS_HEADER
        align 16
        db "^nthdrsXX      $"
        nthdrsxx        IMAGE_NT_HEADERSXX
        align 16
        db "^sechdr        $"
        sechdr          IMAGE_SECTION_HEADER
        ExtraDirBuffer  rb sizeof.IMAGE_DATA_DIRECTORY*IMAGE_NUMBEROF_DIRECTORY_ENTRIES
        align 16
        db "^expdir        $"
        expdir          IMAGE_EXPORT_DIRECTORY

        align 16

        szMsgAbout      db      _TITLE,13,10
                        db      "version ",_VERSIONTEXT,13,10
                        db      "coded by comrade <comrade2k@hotmail.com>",13,10
                        db      "07.12.2003 - ",DATE," ",TIME,13,10,13,10
                        db      "IRC:",9,"#asm, #coders, #win32asm on EFnet",13,10
                        db      "Web:",9,"http://comrade64.cjb.net/",13,10
                        db      9,"http://comrade.win32asm.com/",13,10,13,10
                        db      9,"http://www.comrade64.com/",13,10,13,10
                        db      "Usage: ",_NAME,".exe /a /i library.dll",13,10
                        db      "       switches are optional to indicate.",13,10
                        db      "       /a filter ANSI procedures",13,10
                        db      "       /u filter UNICODE procedures.",13,10
                        db      "       specify /i or /h for sections search method",13,10
                        db      "       /i (default) standard indexed search",13,10
                        db      "       /h heuristic search.",13,10,0
        szErrInvalidFormat db   "Invalid format.",13,10,0
        szErrOpenSource db      "Could not open source file.",13,10,0
        szErrCreateOutF db      "Could not create output file.",13,10,0
        szNext          db      ",\"
        szNewLine       db      13,10
        szTab           db      9
        szError         db      "Error",0
        szIncExtension  db      ".inc",0
        szLibraryFormat db      13,10,"; %s API calls",13,10,13,10,"import %s,\",13,10,9,0
        szFullLibraryFormat db  "library %s, ""%s.%s""",13,10,"import %s, ",0 ; unused now
        szImportFormat  db      "%s, ""%s""",0
;##########################################################################

        align 16

        dwExportsOffset rd      01h
        dwDataDirPtr    rd      01h
        hStdOut         rd      01h
        hOutFile        rd      01h
        hFile           rd      01h
        cFormat         rb      01h
        cSecMethod      rb      01h
        lpName          rd      01h
        lpszSourceFile  rd      01h
        dwPosition      rd      01h
        argc            rd      01h
        argv            rd      10h
        szName          rb      100h
        szOutFilePath   rb      100h
        szAlias         rb      100h
        szMessage       rb      100h

;##########################################################################
;##########################################################################