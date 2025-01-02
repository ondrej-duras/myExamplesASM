include 'macro/struct.inc'

struct IMAGE_DATA_DIRECTORY
  VirtualAddress    dd      ?
  isize             dd      ?
ends
;struct IMAGE_DATA_DIRECTORY

IMAGE_NUMBEROF_DIRECTORY_ENTRIES = 16

struct IMAGE_OPTIONAL_HEADER64
  Magic                         dw      ?
  MajorLinkerVersion            db      ?
  MinorLinkerVersion            db      ?
  SizeOfCode                    dd      ?
  SizeOfInitializedData         dd      ?
  SizeOfUninitializedData       dd      ?

  AddressOfEntryPoint           dd      ?
  BaseOfCode                    dd      ?
  ImageBase                     dq      ?

  SectionAlignment              dd      ?
  FileAlignment                 dd      ?
  MajorOperatingSystemVersion   dw      ?
  MinorOperatingSystemVersion   dw      ?
  MajorImageVersion             dw      ?
  MinorImageVersion             dw      ?

  MajorSubsystemVersion         dw      ?
  MinorSubsystemVersion         dw      ?
  Win32VersionValue             dd      ?
  SizeOfImage                   dd      ?
  SizeOfHeaders                 dd      ?

  CheckSum                      dd      ?
  Subsystem                     dw      ?
  DllCharacteristics            dw      ?
  SizeOfStackReserve            dq      ?

  SizeOfStackCommit             dq      ?
  SizeOfHeapReserve             dq      ?

  SizeOfHeapCommit              dq      ?
  LoaderFlags                   dd      ?
  NumberOfRvaAndSizes           dd      ?

  DataDirectory                 rb      sizeof.IMAGE_DATA_DIRECTORY*IMAGE_NUMBEROF_DIRECTORY_ENTRIES
ends
;struct IMAGE_OPTIONAL_HEADER64

IMAGE_DIRECTORY_ENTRY_EXPORT         = 0 ; Export directory
IMAGE_DIRECTORY_ENTRY_IMPORT         = 1 ; Import directory
IMAGE_DIRECTORY_ENTRY_RESOURCE       = 2 ; Resource directory
IMAGE_DIRECTORY_ENTRY_EXCEPTION      = 3 ; Exception directory
IMAGE_DIRECTORY_ENTRY_SECURITY       = 4 ; Security directory
IMAGE_DIRECTORY_ENTRY_BASERELOC      = 5 ; Base relocation table
IMAGE_DIRECTORY_ENTRY_DEBUG          = 6 ; Debug directory
IMAGE_DIRECTORY_ENTRY_ARCHITECTURE   = 7 ; Architecture-specific data
IMAGE_DIRECTORY_ENTRY_GLOBALPTR      = 8 ; The relative virtual address of global pointer
IMAGE_DIRECTORY_ENTRY_TLS            = 9 ; Thread local storage directory
IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG    = 10 ; Load configuration directory
IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT   = 11 ; Bound import directory
IMAGE_DIRECTORY_ENTRY_IAT            = 12 ; Import address table
IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT   = 13 ; Delay import table
IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR = 14 ; COM descriptor table


struct IMAGE_OPTIONAL_HEADER32
  Magic                         dw      ?
  MajorLinkerVersion            db      ?
  MinorLinkerVersion            db      ?
  SizeOfCode                    dd      ?
  SizeOfInitializedData         dd      ?
  SizeOfUninitializedData       dd      ?

  AddressOfEntryPoint           dd      ?
  BaseOfCode                    dd      ?
  BaseOfData                    dd      ?
  ImageBase                     dd      ?

  SectionAlignment              dd      ?
  FileAlignment                 dd      ?
  MajorOperatingSystemVersion   dw      ?
  MinorOperatingSystemVersion   dw      ?
  MajorImageVersion             dw      ?
  MinorImageVersion             dw      ?

  MajorSubsystemVersion         dw      ?
  MinorSubsystemVersion         dw      ?
  Win32VersionValue             dd      ?
  SizeOfImage                   dd      ?
  SizeOfHeaders                 dd      ?

  CheckSum                      dd      ?
  Subsystem                     dw      ?
  DllCharacteristics            dw      ?
  SizeOfStackReserve            dd      ?
  SizeOfStackCommit             dd      ?

  SizeOfHeapReserve             dd      ?
  SizeOfHeapCommit              dd      ?
  LoaderFlags                   dd      ?
  NumberOfRvaAndSizes           dd      ?

  DataDirectory                 rb      sizeof.IMAGE_DATA_DIRECTORY*IMAGE_NUMBEROF_DIRECTORY_ENTRIES
ends
;struct IMAGE_OPTIONAL_HEADER32

IMAGE_NT_OPTIONAL_HDR32_MAGIC = 0x10b ; The file is PE32 executable image. 32-bit.
IMAGE_NT_OPTIONAL_HDR64_MAGIC = 0x20b ; The file is PE32+ executable image. 64-bit.
IMAGE_ROM_OPTIONAL_HDR_MAGIC  = 0x107 ; The file is a ROM image.

IMAGE_OPTIONAL_HEADER  equ  IMAGE_OPTIONAL_HEADER32

struct IMAGE_FILE_HEADER
  Machine               dw    ?
  NumberOfSections      dw    ?
  TimeDateStamp         dd    ?
  PointerToSymbolTable  dd    ?
  NumberOfSymbols       dd    ?

  SizeOfOptionalHeader  dw    ?
  Characteristics       dw    ?
ends
;struct IMAGE_FILE_HEADER

struct IMAGE_NT_HEADERS64
  Signature         dd                   ?
  FileHeader        IMAGE_FILE_HEADER
  OptionalHeader    IMAGE_OPTIONAL_HEADER64
ends
;struct IMAGE_NT_HEADERS

struct IMAGE_NT_HEADERS32
  Signature         dd                   ?
  FileHeader        IMAGE_FILE_HEADER
  OptionalHeader    IMAGE_OPTIONAL_HEADER32
ends
;struct IMAGE_NT_HEADERS

IMAGE_NT_HEADERS  equ  IMAGE_NT_HEADERS32

struct IMAGE_NT_HEADERSXX
union
      nthdrs IMAGE_NT_HEADERS32
      nthdrs64 IMAGE_NT_HEADERS64
ends
ends
;struct IMAGE_NT_HEADERSXX

struct IMAGE_EXPORT_DIRECTORY
  Characteristics           dd      ?
  TimeDateStamp             dd      ?
  MajorVersion              dw      ?
  MinorVersion              dw      ?
  nName                     dd      ?
  nBase                     dd      ?
  NumberOfFunctions         dd      ?
  NumberOfNames             dd      ?
  AddressOfFunctions        dd      ?
  AddressOfNames            dd      ?
  AddressOfNameOrdinals     dd      ?
ends
;struct IMAGE_EXPORT_DIRECTORY

struct IMAGE_DOS_HEADER
  e_magic           dw      ?
  e_cblp            dw      ?
  e_cp              dw      ?
  e_crlc            dw      ?
  e_cparhdr         dw      ?
  e_minalloc        dw      ?
  e_maxalloc        dw      ?
  e_ss              dw      ?
  e_sp              dw      ?
  e_csum            dw      ?
  e_ip              dw      ?
  e_cs              dw      ?
  e_lfarlc          dw      ?
  e_ovno            dw      ?
  e_res             rw      04h
  e_oemid           dw      ?
  e_oeminfo         dw      ?
  e_res2            rw      0Ah
  e_lfanew          dd      ?
ends
;struct IMAGE_DOS_HEADER

struct IMAGE_SECTION_HEADER
    Name1 rb 8
    ;Misc dd ?
    ;virtual at IMAGE_SECTION_HEADER.Misc
    ;    PhysicalAddress dd  ?
    ;    VirtualSize dd      ?
    ;end virtual
    VirtualSize dd          ?
    VirtualAddress dd       ?
    SizeOfRawData dd        ?
    PointerToRawData dd     ?
    PointerToRelocations dd ?
    PointerToLinenumbers dd ?
    NumberOfRelocations dw  ?
    NumberOfLinenumbers dw  ?
    Characteristics dd      ?
ends
;struct IMAGE_SECTION_HEADER

