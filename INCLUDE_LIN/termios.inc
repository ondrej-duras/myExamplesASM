include 'struct.inc' ; STRUCT.INC comes from FASMW package (Flat Assembler, package for windows)

NCCS = 32
HAVE_STRUCT_TERMIOS_C_ISPEED = 1
HAVE_STRUCT_TERMIOS_C_OSPEED = 1

struct cc
  vintr     db ?
  vquit     db ?
  verase    db ?
  vkill     db ?
  veof      db ?
  vtime     db ?
  vmin      db ?
  vswtc     db ?
  vstart    db ?
  vstop     db ?
  vsusp     db ?
  veol      db ?
  vreprint  db ?
  vdiscard  db ?
  vwerase   db ?
  vlnext    db ?
  veol2     db ?
            db 16 dup ?
ends

struct termios
  c_iflag    dd ?
  c_oflag    dd ?
  c_cflag    dd ?
  c_lflag    dd ?
  c_line     db ?
  c_cc       cc
  c_ispeed   dd ?
  c_ospeed   dd ?
ends

; c_cc characters
VINTR     = 0
VQUIT     = 1
VERASE    = 2
VKILL     = 3
VEOF      = 4
VTIME     = 5
VMIN      = 6
VSWTC     = 7
VSTART    = 8
VSTOP     = 9
VSUSP     = 10
VEOL      = 11
VREPRINT  = 12
VDISCARD  = 13
VWERASE   = 14
VLNEXT    = 15
VEOL2     = 16

; c_iflag bits
IGNBRK  = 0000001
BRKINT  = 0000002
IGNPAR  = 0000004
PARMRK  = 0000010
INPCK   = 0000020
ISTRIP  = 0000040
INLCR   = 0000100
IGNCR   = 0000200
ICRNL   = 0000400
IUCLC   = 0001000
IXON    = 0002000
IXANY   = 0004000
IXOFF   = 0010000
IMAXBEL = 0020000
IUTF8   = 0040000

; c_oflag bits
OPOST   = 0000001
OLCUC   = 0000002
ONLCR   = 0000004
OCRNL   = 0000010
ONOCR   = 0000020
ONLRET  = 0000040
OFILL   = 0000100
OFDEL   = 0000200
NLDLY   = 0000400
NL0     = 0000000
NL1     = 0000400
CRDLY   = 0003000
_CR0    = 0000000 ; Name changed from CRn to _CRn
_CR1    = 0001000
_CR2    = 0002000
_CR3    = 0003000
TABDLY  = 0014000
TAB0    = 0000000
TAB1    = 0004000
TAB2    = 0010000
TAB3    = 0014000
BSDLY   = 0020000
BS0     = 0000000
BS1     = 0020000
FFDLY   = 0100000
FF0     = 0000000
FF1     = 0100000
VTDLY   = 0040000
VT0     = 0000000
VT1     = 0040000
XTABS   = 0014000

; c_cflag bit meaning
CBAUD       = 0010017
B0          = 0000000   ; hang up
B50         = 0000001
B75         = 0000002
B110        = 0000003
B134        = 0000004
B150        = 0000005
B200        = 0000006
B300        = 0000007
B600        = 0000010
B1200       = 0000011
B1800       = 0000012
B2400       = 0000013
B4800       = 0000014
B9600       = 0000015
B19200      = 0000016
B38400      = 0000017
EXTA        = B19200
EXTB        = B38400
CSIZE       = 0000060
CS5         = 0000000
CS6         = 0000020
CS7         = 0000040
CS8         = 0000060
CSTOPB      = 0000100
CREAD       = 0000200
PARENB      = 0000400
PARODD      = 0001000
HUPCL       = 0002000
CLOCAL      = 0004000
CBAUDEX     = 0010000
B57600      = 0010001
B115200     = 0010002
B230400     = 0010003
B460800     = 0010004
B500000     = 0010005
B576000     = 0010006
B921600     = 0010007
B1000000    = 0010010
B1152000    = 0010011
B1500000    = 0010012
B2000000    = 0010013
B2500000    = 0010014
B3000000    = 0010015
B3500000    = 0010016
B4000000    = 0010017
__MAX_BAUD  = B4000000
CIBAUD      = 002003600000    ; input baud rate (not used)
CMSPAR      = 010000000000    ; mark or space (stick) parity
CRTSCTS     = 020000000000    ; flow control

; c_lflag bits
ISIG    = 0000001
ICANON  = 0000002
XCASE   = 0000004
ECHO    = 0000010
ECHOE   = 0000020
ECHOK   = 0000040
ECHONL  = 0000100
NOFLSH  = 0000200
TOSTOP  = 0000400
ECHOCTL = 0001000
ECHOPRT = 0002000
ECHOKE  = 0004000
FLUSHO  = 0010000
PENDIN  = 0040000
IEXTEN  = 0100000
EXTPROC = 0200000

; tcflow() and TCXONC use these
TCOOFF  = 0
TCOON   = 1
TCIOFF  = 2
TCION   = 3

; tcflush() and TCFLSH use these
TCIFLUSH  = 0
TCOFLUSH  = 1
TCIOFLUSH = 2

; tcsetattr uses these
TCSANOW   = 0
TCSADRAIN = 1
TCSAFLUSH = 2
