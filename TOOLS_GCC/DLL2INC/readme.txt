


## Description
original source is at
https://github.com/RootDmytro/dll2inc



Lists exports of given DLL as FASM include file.
Some variation of this tool was usefull back in the day, so I decided to resurrect it here.

Initial version was "Coded by comrade" back in 2003.
I made a few improvements to make it usable.

Output is stored at the same path as the original file.
   So ensure that library is at a place where you have write permissions.
Output file is named as the original but with .inc extension instead of .dll.
   e.g. C:\path\library32.dll -> C:\path\library32.inc

==========================================================
dll2inc                                     March 10, 2004
Version 1.1                                      21:16 EST
Coded by comrade
==========================================================
Fixes/Updates           10.03.2003 21:15 EST (version 1.1)
 * added about message
 * added /a and /u switches, to filter ANSI and UNICODE
   calls (by checking for A or W suffix in procedure name)
==========================================================
Lists exports of given DLL to FASM include file.
==========================================================
E-mail: comrade2k@hotmail.com
   Web: http://comrade64.cjb.net/
        http://comrade.win32asm.com/
        http://comrade.ownz.com/
        http://www.comrade64.com/
   IRC: #asm, #coders, #win32asm on EFnet

==========================================================
dll2inc                                   February 3, 2022
Version 1.2                                     23:12 EEST
Updated by RootDmytro
==========================================================
Updates                03.02.2022 32:12 EEST (version 1.2)
 * console as output replaced with file that is created
   at the same path and with same file name as source DLL.
 * added support for PE32+ with 64-bit IMAGE_NT_HEADERS64.
 * added /i and /h switches, for section search methods
   /i normal search, this is default.
   /h heuristic search that ignores NumberOfRvaAndSizes.
 * improved export format to be inline with current
   FASM's format of api/*.inc files.

==========================================================
Lists exports of given DLL as FASM include file.
==========================================================
 GitHub: https://github.com/RootDmytro  
==========================================================
