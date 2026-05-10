' compileoptions -s32 -k


' Show V 1.00 - Glen Hewlett

' CoCo 3 Movie and NTSC image viewer
' NTSC 256 Colour & RGB Movie viewer
' NTSC Image viewer

' Hi-light the movie or image and press enter to view it
' When playing an NTM movie file you can scrub forward with the right arrow or backwards with the left arrow you can also
' Press the number keys to jump to the percent of the movie.
' Example:  Pressing 3 will jump to 30% point in the movie, pressing 8 will jump to 80% point in the movie
'
' In a folder with images you can press S to start a slideshow of the images in that folder.
' in slideshow mode press number keys from 1 to 9 to change the speed of the slideshow or hold BREAK to exit slideshow

DIM SDC_Response AS _BYTE
DIM I AS _UNSIGNED _BYTE
DIM I2 AS _UNSIGNED _BYTE
DIM I3 AS INTEGER
DIM Attribute AS _UNSIGNED _BYTE
DIM FileSize AS _UNSIGNED LONG
DIM FilePointer AS _UNSIGNED _BYTE
DIM SlidePage AS _UNSIGNED INTEGER
DIM Seconds AS _UNSIGNED INTEGER

DIM PageCount AS _UNSIGNED INTEGER

Seconds = 5 ' Delay between images shown during slideshow mode
GOSUB PaletteBlack
GMODE 136 ' Set biggest NTSC screen mode to NTSC 160 x 225 x 256 colour mode

10 LOCATE 0, 0 ' Make sure the font is loaded
20 PRINT #-3, "123"
GCLS ' clear the hires screen

' New NTSC composite mode palette gets close with a GIMEZ
'Palette 0, &H00
'Palette 1, &H22
'Palette 2, &H1F
'Palette 3, &H3F

WIDTH 40
GOSUB PaletteTextMode
CLS

DIM MainPointer AS _UNSIGNED INTEGER
DIM Pages AS _UNSIGNED INTEGER
DIM CurrentPage AS _UNSIGNED INTEGER
DIM FoundEnd AS _UNSIGNED _BYTE

' Let's make a file selector from the SDC
FolderName$ = "/" ' Initial folder

ShowNewFolder:
GOSUB PaletteTextMode
CLS
FilePointer = 0
Pages = 0
CurrentPage = 0
FoundEnd = 0
MainPointer = 0

SDC_Response = SDC_SETDIR(FolderName$) ' Set the directory
IF SDC_Response <> 0 THEN GOSUB SDCError

WildCard$ = "*.*"
SDC_Response = SDC_INITDIR(FolderName$ + WildCard$) ' Initialize the directory
IF SDC_Response <> 0 THEN GOSUB SDCError

' Find the number of pages
PageLoop:
SDC_Response = SDC_DIRPAGE(0) ' Get a directory Page
IF SDC_Response <> 0 THEN GOSUB SDCError
FOR I = 0 TO 15
    Entry$ = SDC_DIRLIST$(I)
    Attribute = ASC(MID$(Entry$, 12, 1)) ' attributes ($20 file, $10 dir, $02 hidden, $01 locked)
    IF Attribute = 0 THEN
        ' we reached the end of the directory listing
        FoundEnd = 1
        EXIT FOR
    END IF
NEXT I
Pages = Pages + 1
IF FoundEnd <> 1 THEN GOTO PageLoop
Pages = Pages - 1
ShowSelector:
GOSUB ShowCurPage ' Show the 16 entry directory page of CurrentPage

KeyLoop:
GOSUB HiLightRow ' Hilight row FilePointer
GOSUB GetFileName
IF EXT$ = "NTM" THEN
    GOSUB ShowMovieInfo ' Show movie header info
ELSE
    GOSUB ClearInfo
END IF
I$ = INKEY$
KeyLoop1:
I$ = INKEY$: IF I$ = "" THEN GOTO KeyLoop1
SELECT CASE ASC(I$)
    CASE &H5E
        ' Up Arrow pressed
        IF FilePointer > 0 THEN
            GOSUB NormalizeRow ' Make row on screen look normal
            FilePointer = FilePointer - 1
        ELSE
            ' Top of screen display, maybe we should scroll
            IF CurrentPage > 0 THEN
                CurrentPage = CurrentPage - 1
                GOSUB ShowCurPage ' Show the 16 entry directory page of CurrentPage
                FilePointer = 0
                GOTO KeyLoop
            END IF
        END IF
    CASE &H0A
        ' Down Arrow pressed
        I = PEEK(&HE02 + 240 + FilePointer * 80) ' Check line below
        ' Print @20, Hex$(I); " "; Chr$(I); CurrentPage; Pages
        IF I <> 32 THEN
            ' The next line is not blank
            GOSUB NormalizeRow ' Make row on screen look normal
            FilePointer = FilePointer + 1
            GOTO KeyLoop
        ELSE
            ' Next line is blank
            ' Bottom of screen display, maybe we should scroll
            IF CurrentPage < Pages THEN
                CurrentPage = CurrentPage + 1
                GOSUB ShowCurPage ' Show the 16 entry directory page of CurrentPage
                FilePointer = 0
                GOTO KeyLoop
            END IF
        END IF
    CASE 3 '
        'BREAK Entered, go to the previous directory
        I = LEN(FolderName$)
        IF I > 1 THEN
            ' We need to go up a directory level
            I = I - 1 ' ignore the right most "/"
            WHILE MID$(FolderName$, I, 1) <> "/": I = I - 1: WEND
            FolderName$ = LEFT$(FolderName$, I)
        END IF
        GOTO ShowNewFolder
    CASE &H0D
        ' Enter pressed, See if we have a file to show
        ' Get the filename and Extension that is being hilighted
        IF FilePointer = 0 THEN
            ' Trying to get to the previous directory
            I = LEN(FolderName$)
            IF I > 1 THEN
                ' We need to go up a directory level
                I = I - 1 ' ignore the right most "/"
                WHILE MID$(FolderName$, I, 1) <> "/": I = I - 1: WEND
                FolderName$ = LEFT$(FolderName$, I)
            END IF
            GOTO ShowNewFolder
        END IF
        GOSUB GetFileName
        SELECT CASE EXT$
            ' Is it a folder?
            CASE "DIR"
                ' Enter a new folder
                NewFolder:
                FolderName$ = FolderName$ + RTRIM$(ShowName$) + "/"
                GOSUB NormalizeRow ' Make row on screen look normal
                GOTO ShowNewFolder
                ' Check for .NTS
            CASE "NTS"
                GOSUB PaletteBlack
                GCLS ' Clear the Hires Screen
                GOSUB ShowNTS
                I$ = INKEY$
                KeyLoop2:
                I$ = INKEY$: IF I$ = "" THEN GOTO KeyLoop2
                WIDTH 40
                GOSUB PaletteTextMode
            CASE "NTM"
                GOSUB PlayNTM ' Play the NTM movie file
                WIDTH 40
                GOSUB PaletteTextMode
                GOTO ShowSelector '  GoTo ShowNewFolder
        END SELECT
    CASE &H53
        ' S key pressed, start a slideshow of the current folder's NTS files
        GCLS ' Clear the Hires Screen
        GOSUB SlideShow
        WIDTH 40
        GOTO ShowNewFolder
END SELECT
GOTO KeyLoop

' Play a slideshow of all the NTS files in the current folder
SlideShow:
SlidePage = 0
I2 = 0
SlideLoop:
SDC_Response = SDC_SETDIR(FolderName$) ' Set the directory
IF SDC_Response <> 0 THEN GOSUB SDCError

SDC_Response = SDC_INITDIR(FolderName$ + WildCard$) ' Initialize the directory
IF SDC_Response <> 0 THEN GOSUB SDCError
FOR I = 0 TO SlidePage
    SDC_Response = SDC_DIRPAGE(0) ' Get a directory Page, which can be listed with the SDC_DirList$() command
    IF SDC_Response <> 0 THEN GOSUB SDCError
NEXT I

WHILE I2 <= 15
    Entry$ = SDC_DIRLIST$(I2)
    Attribute = ASC(MID$(Entry$, 12, 1)) ' attributes

    IF Attribute = 0 THEN
        ' End of the listing, start again from first page
        GOTO SlideShow
    END IF

    IF Attribute = &H20 THEN
        ShowName$ = LEFT$(RTRIM$(LEFT$(Entry$, 8)) + "        ", 8)
        EXT$ = LEFT$(RTRIM$(MID$(Entry$, 9, 3)) + "   ", 3)

        IF EXT$ = "NTS" THEN
            GOSUB ShowNTS
            TIMER = 0

            TimerLoop:
            I$ = INKEY$
            IF TIMER < 60 * Seconds THEN
                IF I$ = "" THEN GOTO TimerLoop
                SELECT CASE ASC(I$)
                    CASE &H03, &H20 ' Break or Space Bar
                        RETURN
                    CASE &H30 TO &H39
                        Seconds = ASC(I$) - &H30
                END SELECT
                GOTO TimerLoop
            END IF
            I2 = I2 + 1
            GOTO SlideLoop
        END IF
    END IF
    I2 = I2 + 1
WEND
I$ = INKEY$
SELECT CASE ASC(I$)
    CASE &H03, &H20 ' Break or Space Bar
        RETURN
END SELECT

I2 = 0
SlidePage = SlidePage + 1
GOTO SlideLoop

PaletteBlack:
' ADDASSEM:
    LDX  #$FFB0             ; Start of Palette hardware registers
    LDD  #15                ; A = 0, B = 15
!   STA  B,X                ; Set Palette value to zero (Black)
    DECB                    ; Decrement the loop counter
    BPL <                   ; Loop until B = -1
' ENDASSEM:
RETURN

PaletteTextMode:
ATTR 1, 0 ' Foreground is palette 9, background is palette 0
PALETTEW 0, 0 ' Black background
PALETTEW 1, 63 ' White background
PALETTEW 8, 0 ' Black forground
PALETTEV 9, 63 ' White foreground, update the palette hardware
RETURN

NotNTS:
'Print "Bad NTS file": End
RETURN

UnSupported:
END

' Show the NTS on screen
ShowNTS:
DIM GmodeVal AS _UNSIGNED _BYTE
PALETTEW 0, 0
PALETTEW 1, &H10
PALETTEW 2, &H20
PALETTEV 3, &H30


'Print "Opening file:"; FolderName$ + ShowName$ + "." + EXT$
SDC_OPEN FolderName$ + ShowName$ + "." + EXT$, "R", 0 ' Open a file on the SD card for direct read access
' Get the GMODE value from the file:
' The file should always start with 00 00 01 FF A6 Gmode#
'Print "Reading Header:"
I = SDC_GETBYTE(0)
IF I <> 0 THEN GOTO NotNTS ' Must be &H00
I = SDC_GETBYTE(0)
IF I <> 0 THEN GOTO NotNTS ' Must be &H00
I = SDC_GETBYTE(0)
IF I <> &H01 THEN GOTO NotNTS ' Must be &H01
I = SDC_GETBYTE(0)
IF I <> &HFF THEN GOTO NotNTS ' Must be &HFF
I = SDC_GETBYTE(0)
IF I <> &HA6 THEN GOTO NotNTS ' Must be &HA6
' Next value is the GMODE #
GmodeVal = SDC_GETBYTE(0)
SDC_CLOSE (0) ' Close the file we know we are good

' Set the GMODE screen value (have to do this the hard way as GMODE can only be set once and not changed with the compiler
GOSUB SetGmode ' Change the GMODE to the mode in the image
SCREEN 1 ' Show Graphics screen

' Load the image (the image format is a regular LOADM file that knows where to load to match the GMODE
SDC_LOADM FolderName$ + ShowName$ + "." + EXT$, 0 ' load the image
RETURN

SetGmode:
' ADDASSEM:
    LDB _Var_GmodeVal   ; B = The _Unsigned _Byte value of this variable
    LDX #GmodeTable-160 ; X points at the table -160 (GMODE values are from 160 to 165)
    ABX                 ; X = X + B   (now points at the correct gmode resolution number)
    LDB ,X              ; Get the value in the table
    STB $FF99           ; Set the Vid_Res_Reg
    RTS     ; return from BASIC's call here

GmodeTable:
    FCB %00011001    ;  512x192x 256
    FCB %00111001    ;  512x200x 256
    FCB %01111001    ;  512x225x 256
    FCB %00011101    ;  640x192x 256
    FCB %00111101    ;  640x200x 256
    FCB %01111101    ;  640x225x 256
' ENDASSEM:

' Hilight row FilePointer on screen
HiLightRow:
' ADDASSEM:
    LDX  #$E01+2*80         ; Start at the 2nd line + 1
    LDB  _Var_FilePointer   ; Get the file pointer value
    LDA  #80                ; 80 characters per line (character + attribute byte
    MUL
    LEAX D,X                ; X points at the start of the row on screen
    LDB #40                 ; 40 characters per line
    LDA #%00000001          ; Forground is black, background is white
!   STA ,X++                ; Chnge attribute value
    DECB                    ; Decrement the loop counter
    BNE <                   ; Loop
' ENDASSEM:
RETURN

' Normalize row @ FilePointer on screen
NormalizeRow:
' ADDASSEM:
    LDX  #$E01+2*80         ; Start at the 2nd line + 1
    LDB  _Var_FilePointer   ; Get the file pointer value
    LDA  #80                ; 80 characters per line (character + attribute byte
    MUL
    LEAX D,X                ; X points at the start of the row on screen
    LDB #40                 ; 40 characters per line
    LDA #%00001000          ; Forground is black, background is white
!   STA ,X++                ; Chnge attribute value
    DECB                    ; Decrement the loop counter
    BNE <                   ; Loop
' ENDASSEM:
RETURN

' Clear bottom info area of the screen starting @ 40*20
ClearInfo:
' ADDASSEM:
    LDX  #$E00+80*20        ; Start at the bottom where the text is
    LDA  #' '               ; A = blank
!   STA ,X++
    CMPX    #$E00+80*27
    BNE <
' ENDASSEM:
RETURN

' Get the filename
GetFileName:
' Let's convert the bytes on the text screen back to a filename for the SDC to read from
' ADDASSEM:
    LDX  #$E02+2*80         ; Start at the 2nd line
    LDB  _Var_FilePointer   ; Get the file pointer value
    LDA  #80                ; 80 characters per line (character + attribute byte
    MUL
    LEAX D,X                ; X points at the start of the row on screen
    LDU #_StrVar_ShowName   ; U points at the string variable ShowName$
    LDB #8                  ; Get 8 bytes of the filename
    STB ,U+                 ; First byte of the String variable is the length of the string, save 8
!   LDA ,X++                ; Get the filename character
    STA ,U+                 ; Save filename character
    DECB                    ; Decrement the loop counter
    BNE <                   ; Loop
; Get the extension too
    LEAX    2,X             ; Skip forward to the extension shown on screen
    LDU #_StrVar_EXT        ; U points at the string variable EXT$
    LDB #3                  ; Get 3 bytes of the filename
    STB ,U+                 ; First byte of the String variable is the length of the string, save 3
!   LDA ,X++                ; Get the filename character
    STA ,U+                 ; Save filename character
    DECB                    ; Decrement the loop counter
    BNE <                   ; Loop
' ENDASSEM:
RETURN
' Show 16 entrys of CurrentPage on screen
ShowCurPage:
CLS

PRINT @0, FolderName$ + WildCard$
'Print "|--------------------------------------|";
PRINT "   NAME   EXT     FILESIZE"
PRINT "/.."
SDC_Response = SDC_SETDIR(FolderName$) ' Set the directory
IF SDC_Response <> 0 THEN GOSUB SDCError

PageCount = 0
SDC_Response = SDC_INITDIR(FolderName$ + WildCard$) ' Initialize the directory
IF SDC_Response <> 0 THEN GOSUB SDCError

ShowDirPageLoop:
SDC_Response = SDC_DIRPAGE(0) ' Get a directory Page, which can be listed with the SDC_DirList$() command
IF SDC_Response <> 0 THEN GOSUB SDCError
IF PageCount = CurrentPage THEN
    FOR I = 0 TO 15
        Entry$ = SDC_DIRLIST$(I) ' get the 16 byte directory entry I
        Attribute = ASC(MID$(Entry$, 12, 1)) ' attributes ($20 file, $10 dir, $02 hidden, $01 locked)
        IF Attribute <> 0 THEN
            IF Attribute = &H10 THEN
                ' It's a directory
                PreName$ = "/"
                ShowName$ = LEFT$(RTRIM$(LEFT$(Entry$, 8)) + "        ", 8)
                EXT$ = "DIR"
            ELSE
                ' Not a directory
                PreName$ = " "
                ShowName$ = LEFT$(RTRIM$(LEFT$(Entry$, 8)) + "        ", 8)
                EXT$ = LEFT$(RTRIM$(MID$(Entry$, 9, 3)) + "   ", 3)
            END IF
            IF EXT$ = "NTS" OR EXT$ = "DIR" OR EXT$ = "NTM" THEN
                PRINT PreName$; ShowName$; " "; EXT$; " ";
                IF EXT$ = "DIR" THEN
                    ' no need to show the size
                    PRINT
                ELSE
                    FileSize = ASC(MID$(Entry$, 13, 1)) * 256 + ASC(MID$(Entry$, 14, 1))
                    FileSize = FileSize * 65536 + ASC(MID$(Entry$, 15, 1)) * 256 + ASC(MID$(Entry$, 16, 1))
                    IF FileSize < 1000000 THEN
                        Size$ = RIGHT$("            " + STR$(FileSize), 12)
                        PRINT Size$; " Bytes"
                    ELSE
                        FileSize = FileSize \ 1000000
                        Size$ = RIGHT$("            " + STR$(FileSize), 12)
                        PRINT Size$; " MB"
                    END IF
                END IF
            END IF
        ELSE
            EXIT FOR
        END IF
    NEXT I
    RETURN
END IF
PageCount = PageCount + 1
GOTO ShowDirPageLoop

SDCError:
PRINT "SDC_Response="; SDC_Response: PRINT "Error!  Should return with zero"
END

' Play the NTM movie
PlayNTM:
SDC_PLAYMOVIE FolderName$ + ShowName$ + "." + EXT$, 0 ' Will go into graphics mode based on the movie type
RETURN

' Show movie header info
ShowMovieInfo:
SDC_OPEN FolderName$ + ShowName$ + "." + EXT$, "R", 0 ' Open a file on the SD card for direct read access
SDC_SETPOS0 (232) ' Set the read position to byte 232 in the file

PRINT @40*20, ""; ' Set print location at the bottom section of the sreen
FOR I3 = 1 TO 40 * 7
    I = SDC_GETBYTE(0) ' Read a byte
    PRINT CHR$(I);
NEXT I3
SDC_CLOSE (0) ' Close the file
RETURN

' Debugging code
DIM ACCA AS _UNSIGNED _BYTE
DIM ACCB AS _UNSIGNED _BYTE
DIM REGX AS _UNSIGNED INTEGER
DIM REGY AS _UNSIGNED INTEGER
DIM REGU AS _UNSIGNED INTEGER
DIM REGS AS _UNSIGNED INTEGER
DIM REGCC AS _UNSIGNED _BYTE
DIM REGDP AS _UNSIGNED _BYTE

' ADDASSEM:
ShowValues:
    STA _Var_ACCA
    STB _Var_ACCB
    STX _Var_REGX
    STY _Var_REGY
    STU _Var_REGU
    STS _Var_REGS
    TFR CC,A
    STA _Var_REGCC
' ENDASSEM:

WIDTH 40
GOSUB PaletteTextMode
CLS
PRINT "A="; HEX$(ACCA)
PRINT "B="; HEX$(ACCB)
PRINT "DP="; HEX$(REGDP)
PRINT "X="; HEX$(REGX)
PRINT "Y="; HEX$(REGY)
PRINT "U="; HEX$(REGU)
PRINT "S="; HEX$(REGS)
PRINT "CC="; HEX$(REGCC)
999 GOTO 999

