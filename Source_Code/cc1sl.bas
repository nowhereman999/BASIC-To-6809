' Version 1.1 fixes a bug to make sure the flag address is set to $FFFF
$ScreenHide
$Console
_Dest _Console
'SCREEN 11: ' WIDTH 80, 60

Dim array(70000) As _Unsigned _Byte
Dim RAM_64k(70000) As _Unsigned _Byte, Flag64k(70000) As _Unsigned _Byte, lomem(70000) As _Unsigned _Byte
Dim MemStart As _Unsigned Integer
Dim X1 As _Unsigned _Byte, X2 As _Unsigned _Byte, X3 As _Unsigned _Byte
Dim count As Long, Ratio As _Float, OldRatio As _Float
Dim TestSize As _Unsigned Integer
Dim BitsOut As _Unsigned Integer, Bits As _Unsigned _Byte
Dim B As _Unsigned _Byte, T As _Unsigned Integer
Dim FO As _Unsigned Long, OrigSize As _Unsigned Long
Dim N As _Unsigned Integer, blocks As _Unsigned Integer
Dim LoResNames$(100)
Dim CrSize As _Unsigned Integer
Dim RAWarray(4000) As _Unsigned _Byte

Fi = 0: LoadTablePos = 0
StringLenMax = 27
verbose = 0: ProgressBar = 0: OutName$ = "": DeCompressBar = 0
BlocksizeStart = 32
BlocksizeEnd = 1024
BlocksizeStep = 256
scns = 0
count = _CommandCount
If count > 0 Then GoTo 100
80
Print "cc1sl - CoCo 1 Super Loader v1.1 by Glen Hewlett"
Print "Usage: cc1sl [-l] [-vx] FILENAME.BIN -oOUTNAME.BIN [*.scn] or [*.csv]..."
Print "Turns a CoCo 1 Machine Language program into a loadable program no matter if it over writes BASIC ROM locations and more"
Print "See the cc1sl_help.txt for more info"
Print
Print "Where:"
Print "-l     Will add the word LOADING at the bottom of the screen while the program loads"
Print "-vx    Amount of info to display while generating the new file x can be 0 1 or 2.  Default x=0 where no info is shown"
Print "FILENAME.BIN is the name of your big CoCo 1 program, it must end with .BIN"
Print "OUTNAME.BIN  is the name of the output file to be created otherwise it defaults to GO.BIN"
Print "*.scn  A binary file that must end with .scn will be shown on the CoCo text screen while loading"
Print "*.csv  A csv text file that must end with .csv will be shown on the CoCo text screen while loading"
Print
System
100
For check = 1 To count
    N$ = Command$(check)
    If LCase$(Left$(N$, 2)) = "-l" Then
        ProgressBar = 1
        GoTo 140
    End If
    If LCase$(Left$(N$, 2)) = "-o" Then
        OutName$ = UCase$(Right$(N$, Len(N$) - 2))
        If Right$(OutName$, 4) = ".BIN" Then OutName$ = Left$(OutName$, Len(OutName$) - 4)
        OutName$ = Left$(OutName$, 8)
        GoTo 140
    End If
    If LCase$(Left$(N$, 2)) = "-v" Then
        verbose = Val(Right$(N$, 1))
        If verbose > 2 Then verbose = 2
        GoTo 140
    End If
    If LCase$(Right$(N$, 4)) = ".scn" Or LCase$(Right$(N$, 4)) = ".csv" Then
        If _FileExists(N$) Then
            If verbose > 0 Then Print "Input File found "; N$
            scns = scns + 1
            LoResNames$(scns) = N$
        Else
            Print "Can't find Input file: "; N$
            System
        End If
    End If
    ' check if we got a file name yet if so then the next filename will be output
    If UCase$(Right$(N$, 4)) = ".BIN" And Left$(N$, 2) <> "-o" Then
        Fname$ = N$
        If _FileExists(Fname$) Then
            If verbose > 0 Then Print "Input File found "; Fname$
        Else
            Print "Can't find Input file: "; Fname$: System
        End If
        Open Fname$ For Append As #1
        length = LOF(1)
        Close #1
        If length < 1 Then Print "Error file: "; Fname$; " is 0 bytes.": End
        If verbose = 2 Then Print "Length of Input file is:"; length; " = $"; Hex$(length)
        Open Fname$ For Binary As #1
        Get #1, , array()
        length = LOF(1)
        Close #1
    End If
140 Next check
If OutName$ = "" Then
    OutName$ = "GO"
End If
'Clear all CoCo RAM image
Dim u As _Unsigned Long, Block As _Unsigned _Byte

x = 0
' Load CoCo 1 M/L program into memory
' array(x) is a byte from the M/L program

'clear a flag buffer of 64k
For u = 0 To 65535
    Flag64k(u) = 0
Next u

200
T = array(x): x = x + 1
If T = 255 Then GoTo 400 ' Got the end of the file, next few bytes are the blanks and EXEC address - Go deal with it
If T <> 0 Then Print "File is corrupt... at position "; Hex$(x): System
'BlockLength is the size of the block to be copied
bl1 = array(x) * 256: x = x + 1
bl2 = array(x): x = x + 1
BlockLength = bl1 + bl2
'MemStart is the location in current 64k space that will be copied to
MemStart = array(x) * 256 + array(x + 1): x = x + 2
If verbose = 2 Then Print "Loading $"; Hex$(BlockLength); " data bytes, starting at address $"; Hex$(MemStart)
'Copy block of data from file to the current 64k buffer and flag the bytes as being used
For u = 0 To BlockLength - 1
    RAM_64k(MemStart + u) = array(x) 'copy to RAM image buffer
    Flag64k(MemStart + u) = 1 'flag these bytes as used
    x = x + 1
Next u
GoTo 200

'Found the end of the file next few bytes are the $0000 and then the execute address
400
bl1 = array(x) * 256: x = x + 1
bl2 = array(x): x = x + 1
If bl1 + bl2 <> 0 Then Print "File is corrupt... at position "; Hex$(x): System
Execute1 = array(x): Execute2 = array(x + 1)
Execute = Execute1 * 256 + Execute2
If verbose > 0 Then Print "Good M/L file."
If verbose > 0 Then Print "Execute address is $"; Hex$(Execute)

'Find some space in the final 64k segment after the load and just before execution begins
'in the regular 64k space

' Is any of the loaded data in the $0000 to $0DFF range?  If so we have to move it temporarily to some other free space
flag = 0
For x = 0 To &HDFF
    If Flag64k(x) = 1 Then flag = 1
Next x
If flag = 1 Then
    If verbose > 0 Then Print "Users program uses low MEM between $0000-$0DFF.": Print "Handling this situation..."
    'encode an array called lomem to describe the RAM used in $0000 to $0DFF
    x = 0
    y = 0
    While x < &HE00
        If Flag64k(x) = 1 Then
            If verbose > 0 Then Print "Uses RAM at: $"; Hex$(x)
            start = x
            starty = y
            lomem(y) = 0 ' 00 preamble flag
            lomem(y + 3) = Int(x / 256) ' Load address MSB
            lomem(y + 4) = x - Int(x / 256) * 256 ' Load address LSB
            y = y + 5
            While Flag64k(x) = 1 And x < &HE00
                lomem(y) = RAM_64k(x): y = y + 1
                x = x + 1
            Wend
            count = x - start
            lomem(starty + 1) = Int(count / 256) ' Length of data block MSB
            lomem(starty + 2) = count - Int(count / 256) * 256 ' Length of data block LSB
            If verbose > 0 Then Print "Size of: $"; Hex$(count)
            x = x - 1
        End If
        x = x + 1
    Wend
    lomem(y) = 255 ' flag the last byte as done
    lomemsize = y
End If

' find space in the unused parts of lower 32k RAM for the loader code
LoaderLen = &HD0 + &H10
If verbose > 0 Then Print "Need to find RAM space in the lower 32k for loadercode size: $"; Hex$(LoaderLen)
x = &HE00
While x < &H7F00
    count = 0
    If Flag64k(x) = 0 Then
        Loader_Program = x
        While Flag64k(x) = 0
            count = count + 1
            x = x + 1
        Wend
        x = x - 1
        If count > LoaderLen Then
            If verbose > 0 Then Print "Found enough free space to use for loader code from: $"; Hex$(Loader_Program); " to: $"; Hex$(Loader_Program + LoaderLen)
            c = 0
            For u = Loader_Program To Loader_Program + LoaderLen
                Flag64k(u) = 2
            Next u
            GoTo 450
        End If
    End If
    x = x + 1
Wend
Print "ERROR: Unfortunately this file uses too much low RAM space can't use this loader."
Print "ERROR: Need to find RAM space in the lower 32k for loadercode size: $"; Hex$(LoaderLen)
Print "ERROR: You might get it to work if you change your program to use RAM from $8000 to $FEFF"
System

' add array to normal used array in a block of memory from $0E00 to $FEFF
' y= size of lowmem array
' lowsize=lomem array size
450
If flag = 1 Then
    If verbose > 0 Then Print "Need to find a section for lower RAM useage of size: $"; Hex$(y)
    x = &HE00
    While x < 65280
        count = 0
        If Flag64k(x) = 0 Then
            Low_Program_Data = x
            While Flag64k(x) = 0 And x < 65280
                count = count + 1
                x = x + 1
            Wend
            x = x - 1
            If count > y Then
                If verbose > 0 Then Print "Found enough free space to add low mem user program/data"
                If verbose > 0 Then Print "Loader will copy program data/code from: $"; Hex$(Low_Program_Data)
                If verbose > 0 Then Print "with a combined size of: $"; Hex$(y)
                c = 0
                For u = Low_Program_Data To Low_Program_Data + y
                    RAM_64k(u) = lomem(c)
                    Flag64k(u) = 1
                    c = c + 1
                Next u
                GoTo 500
            End If
        End If
        x = x + 1
    Wend
    Print "ERROR: Unfortunately this file uses too much RAM can't use this loader"
    Print "ERROR: You might get it to work if you change your program to not load RAM from $0000 to $0E00"
    System
End If


500
' figure out divisor
y = 0
count = 0
x = &H0E00
While x < 65280
    If Flag64k(x) = 1 Then
        While Flag64k(x) = 1
            y = y + 1
            x = x + 1
        Wend
        count = count + 1
    End If
    x = x + 1
Wend
codelen = y + count * 5 + 5
divisor = Int(codelen / 33) + 1
If verbose > 0 Then Print "codelen="; codelen, Hex$(codelen)
If verbose > 0 Then Print "diviosr="; divisor, Hex$(divisor)
x = 0
'Add user screens
If scns > 0 Then
    RawBIN$ = LoResNames$(1)
    GoSub 8900
    X1 = Int((Rawlength + 1) / 256)
    X2 = (Rawlength + 1) - (X1 * 256)
    'New Block to load
    array(x) = 0: x = x + 1
    'size of text screen image = &H200
    array(x) = &H02: x = x + 1
    array(x) = &H00: x = x + 1
    'starting location of the screen $400 in CoCo RAM
    array(x) = &H04: x = x + 1
    array(x) = &H00: x = x + 1
    startx = x
    For q = 1 To 512
        array(x) = 96: x = x + 1 ' Fill screen, just in case users background screen is small
    Next q
    endx = x
    x = startx
    If Rawlength > 511 Then Rawlength = 511
    For q = 0 To Rawlength
        array(x) = RAWarray(q): x = x + 1
    Next q
    x = endx
End If
' Add loading progress bar at the bottom of the screen
If ProgressBar = 1 Then
    If scns > 0 Then
        x = startx + 512 - 32
    Else
        array(x) = &H00: x = x + 1 ' Pre-amble Flag
        array(x) = &H00: x = x + 1 ' Length of Block MSB
        array(x) = &H20: x = x + 1 ' Length of Block LSB
        array(x) = &H05: x = x + 1 ' Load address MSB
        array(x) = &HE0: x = x + 1 ' Load address LSB
    End If
    For y = 1 To 12
        array(x) = 32: x = x + 1
    Next y
    array(x) = Asc("L") - 64: x = x + 1
    array(x) = Asc("O") - 64: x = x + 1
    array(x) = Asc("A") - 64: x = x + 1
    array(x) = Asc("D") - 64: x = x + 1
    array(x) = Asc("I") - 64: x = x + 1
    array(x) = Asc("N") - 64: x = x + 1
    array(x) = Asc("G") - 64: x = x + 1
    For y = 1 To 13
        array(x) = 32: x = x + 1
    Next y
End If

array(x) = &H00: x = x + 1 ' Pre-amble Flag
array(x) = &H00: x = x + 1 ' Length of Block MSB
array(x) = &H03: x = x + 1 ' Length of Block LSB
array(x) = &H01: x = x + 1 ' Load address MSB
array(x) = &H76: x = x + 1 ' Load address LSB

array(x) = &H7E: x = x + 1 ' JMP instruction
temp = Loader_Program + &H18 + &H10
MSB = Int((temp) / 256): LSB = temp - MSB * 256
array(x) = MSB: x = x + 1 ' Loader program address + $18 MSB
array(x) = LSB: x = x + 1 ' Loader program address + $18 LSB

array(x) = &H00: x = x + 1 ' Pre-amble Flag
array(x) = &H00: x = x + 1 ' Length of Block MSB
'If flag = 1 Then
array(x) = &H04: x = x + 1 ' Length of Block LSB
'Else
'array(x) = &H02: x = x + 1 ' Length of Block LSB
'End If

temp = Loader_Program
MSB = Int((temp) / 256): LSB = temp - MSB * 256
array(x) = MSB: x = x + 1 ' Loader program address MSB
array(x) = LSB: x = x + 1 ' Loader program address LSB
temp = divisor
MSB = Int((temp) / 256): LSB = temp - MSB * 256
array(x) = MSB: x = x + 1 ' Divisor MSB
array(x) = LSB: x = x + 1 ' Divisor LSB

If flag = 1 Then
    temp = Low_Program_Data
Else
    temp = &HFFFF
End If
MSB = Int((temp) / 256): LSB = temp - MSB * 256
array(x) = MSB: x = x + 1 ' MSB address to copy low RAM data from
array(x) = LSB: x = x + 1 ' LSB address to copy low RAM data from

array(x) = &H00: x = x + 1 ' Pre-amble Flag
array(x) = &H00: x = x + 1 ' Length of Block MSB
array(x) = &HAB: x = x + 1 ' Length of Block LSB
temp = Loader_Program + &H18 + &H10
MSB = Int((temp) / 256): LSB = temp - MSB * 256
array(x) = MSB: x = x + 1 ' Loader program address + $18 MSB
array(x) = LSB: x = x + 1 ' Loader program address + $18 LSB
'copy data statements for the rest
y = x + &HAB
While x < y
    Read s$
    For T = 1 To Len(s$) Step 2
        array(x) = Val("&H" + Mid$(s$, T, 2)): x = x + 1
    Next T
Wend
array(x) = &HFF: x = x + 1 ' Post-amble Flag
array(x) = &H00: x = x + 1 ' Always zero
array(x) = &H00: x = x + 1 ' Always zero
array(x) = &HA0: x = x + 1 ' EXECute address MSB (not used)
array(x) = &H27: x = x + 1 ' EXECute address LSB (not used)

' Copy all of RAM except the section used by the loader code to the array()
y = x
x = &H0E00
While x < 65280
    If Flag64k(x) = 1 Then
        If verbose > 0 Then Print "Start of RAM block to save at: $"; Hex$(x)
        start = x
        starty = y
        array(y) = 0 ' 00 pre-amble flag
        array(y + 3) = Int(x / 256) ' Load address MSB
        array(y + 4) = x - Int(x / 256) * 256 ' Load address LSB
        y = y + 5
        While Flag64k(x) = 1
            array(y) = RAM_64k(x): y = y + 1
            x = x + 1
        Wend
        count = x - start
        array(starty + 1) = Int(count / 256) ' Length of data block MSB
        array(starty + 2) = count - Int(count / 256) * 256 ' Length of data block LSB
        If verbose > 0 Then Print "with a size of: $"; Hex$(count)
        x = x - 1
    End If
    x = x + 1
Wend
array(y) = &HFF: y = y + 1 ' Post-amble
array(y) = 0: y = y + 1
array(y) = 0: y = y + 1
array(y) = Int(Execute / 256) 'EXECute adress MSB
y = y + 1
array(y) = Execute - Int(Execute / 256) * 256 'EXECute adress LSB

If verbose > 0 Then
    x = 0
    Block = 1
    While array(x) = 0
        Print "Block #:"; Block: Block = Block + 1
        length = array(x + 1) * 256 + array(x + 2)
        StartAddress = array(x + 3) * 256 + array(x + 4)
        Print "Length of block: "; Hex$(length)
        Print "Start Address: "; Hex$(StartAddress)
        Print "End Address: "; Hex$(StartAddress + length - 1)
        x = x + 5 + length
    Wend
End If
filesize = y
Dim LastOutArray(filesize) As _Unsigned _Byte
c = 0
For Op = 0 To y
    LastOutArray(c) = array(Op): c = c + 1
Next Op
If _FileExists(OutName$ + ".BIN") Then Kill OutName$ + ".BIN"
If verbose > 0 Then Print "Writing to file "; OutName$ + ".BIN"
Open OutName$ + ".BIN" For Binary As #1
Put #1, , LastOutArray()
Close #1

System
'END


5800
For qq = 1 To Len(h$)
    v = Asc(Mid$(h$, qq, 1))
    Print Right$("00" + Hex$(v), 2); " ";
Next qq
Return

8900
If verbose > 0 Then Print "Inserting screen "; LoResNames$(1)
Open RawBIN$ For Append As #4
Rawlength = LOF(4)
Close #4
If Rawlength < 1 Then Print "Error file: "; RawBIN$; " is 0 bytes.": System

Open RawBIN$ For Binary As #4
Get #4, , RAWarray()
Rawlength = LOF(4) - 1
Close #4
If LCase$(Right$(RawBIN$, 3)) = "csv" Then
    i = 0: a$ = "": T = 0
    While i <= Rawlength And T < 512
        While RAWarray(i) > 47 And RAWarray(i) < 58
            a$ = a$ + Chr$(RAWarray(i))
            i = i + 1
        Wend
        If a$ <> "" Then
            RAWarray(T) = Val(a$): T = T + 1
            a$ = ""
        End If
        i = i + 1
    Wend
    Rawlength = T - 1
End If

If Rawlength > 512 Then Print "Error file: "; RawBIN$; " is too big"; Rawlength; ",max can be is 512 bytes.": System
Return



'                      (      loader6.asm):00006                 ORG     $0176
'0176 7E0E18           (      loader6.asm):00007 [4]             JMP     START
'                      (      loader6.asm):00008
'                      (      loader6.asm):00009                 ORG     $0E00
'0E00 0003             (      loader6.asm):00010         Divisor FDB     $0003     * counter until next byte on load bar is shown
'0E02 FFFF             (      loader6.asm):00011         Low_Program_Data FDB   $FFFF * Address where block of data to be copied to Low RAM $0000-$1000 will be,  If =$FFFF then it's not used (No low data in users program)
'0E04                  (      loader6.asm):00012         Counter RMB     $0002     * byte to count down
'0E06                  (      loader6.asm):00013         LDPTRAD RMB     $0002     * Actual pointer to the RAM location of load pointer
'0E08                  (      loader6.asm):00014         Space   RMB     $20       * Extra space for temp STACK
'                      (      loader6.asm):00015
'0E18                  (      loader6.asm):00016         START:
Data "8E05E0"
'0E18 8E05E0           (      loader6.asm):00017 [3]             LDX     #$05E0    * Point to the bottom row of the screen
Data "AF8CD8"
'0E1B AF8CD8           (      loader6.asm):00018 [5+1]           STX     LDPTRAD,PCR   * ""
Data "AE8CCF"
'0E1E AE8CCF           (      loader6.asm):00019 [5+1]           LDX     Divisor,PCR   *
Data "AF8CD0"
'0E21 AF8CD0           (      loader6.asm):00020 [5+1]           STX     Counter,PCR   * Set the count of the bytes to be read per screen update
Data "328D0000"
'0E24 328D0000         (      loader6.asm):00021 [4+5]           LEAS    NEXT,PCR     * Set the stack pointer so that our decoding doesn't over write the stack buffer where BASIC usually keeps it
'                      (      loader6.asm):00022                                   * We don't need the code above again so the stack can clear it without any ill effects
'                      (      loader6.asm):00023
'0E28                  (      loader6.asm):00024         NEXT
Data "8D29"
'0E28 8D29             (      loader6.asm):00025 [7]             BSR     GetByte   * Get a byte from file in accumulator A
Data "4D"
'0E2A 4D               (      loader6.asm):00026 [2]             TSTA
Data "265E"
'0E2B 265E             (      loader6.asm):00027 [3]             BNE     EOF       * If byte from file is a $00 then it's the start of a new block of Data, ELSE End Of File
'                      (      loader6.asm):00028
'                      (      loader6.asm):00029         * if byte from file is a $FF then it's the end of the file
Data "8D24"
'0E2D 8D24             (      loader6.asm):00030 [7]             BSR     GetByte   * Get a byte from file in accumulator A
Data "1F89"
'0E2F 1F89             (      loader6.asm):00031 [6]             TFR     A,B       * Save MSB in B temporarily
Data "8D20"
'0E31 8D20             (      loader6.asm):00032 [7]             BSR     GetByte   * Get a byte from file in accumulator A
Data "1E89"
'0E33 1E89             (      loader6.asm):00033 [8]             EXG     A,B       * re-arrange LSB in A and MSB in B to proper MSB,LSB in D
Data "1F02"
'0E35 1F02             (      loader6.asm):00034 [6]             TFR     D,Y       * save length of this block in Y
Data "8D1A"
'0E37 8D1A             (      loader6.asm):00035 [7]             BSR     GetByte   * Get a byte from file in accumulator A
Data "1F89"
'0E39 1F89             (      loader6.asm):00036 [6]             TFR     A,B       * Save MSB in B temporarily
Data "8D16"
'0E3B 8D16             (      loader6.asm):00037 [7]             BSR     GetByte   * Get a byte from file in accumulator A
Data "1E89"
'0E3D 1E89             (      loader6.asm):00038 [8]             EXG     A,B       * re-arrange LSB in A and MSB in B to proper MSB,LSB in D
Data "1F01"
'0E3F 1F01             (      loader6.asm):00039 [6]             TFR     D,X       * starting address in X
Data "33AB"
'0E41 33AB             (      loader6.asm):00040 [4+4]           LEAU    D,Y       * U = start address + Length of the block
Data "11838000"
'0E43 11838000         (      loader6.asm):00041 [5]             CMPU    #$8000    * is this next block to load going to cross into the high RAM area?
Data "242E"
'0E47 242E             (      loader6.asm):00042 [3]             BHS     HighRAM   * if so then handle copying bytes into high RAM area
'                      (      loader6.asm):00043         !
Data "8D08"
'0E49 8D08             (      loader6.asm):00044 [7]             BSR     GetByte   * Get a byte from file in accumulator A
Data "A780"
'0E4B A780             (      loader6.asm):00045 [4+2]           STA     ,X+       * store it
Data "313F"
'0E4D 313F             (      loader6.asm):00046 [4+1]           LEAY    -1,Y
Data "26F8"
'0E4F 26F8             (      loader6.asm):00047 [3]             BNE     <         * keep looping if not done
Data "20D5"
'0E51 20D5             (      loader6.asm):00048 [3]             BRA     NEXT      * look for another block
'                      (      loader6.asm):00049
'0E53                  (      loader6.asm):00050         GetByte:
Data "6A8C9F"
'0E53 6A8C9F           (      loader6.asm):00051 [6+1]           DEC     Counter+1,PCR * decrement the counter until we reach zero
Data "261C"
'0E56 261C             (      loader6.asm):00052 [3]             BNE     >         * if not zero skip ahead else
Data "A68C99"
'0E58 A68C99           (      loader6.asm):00053 [4+1]           LDA     Counter,PCR
Data "2706"
'0E5B 2706             (      loader6.asm):00054 [3]             BEQ     CountedZero
Data "4A"
'0E5D 4A               (      loader6.asm):00055 [2]             DECA
Data "A78C93"
'0E5E A78C93           (      loader6.asm):00056 [4+1]           STA     Counter,PCR
Data "2011"
'0E61 2011             (      loader6.asm):00057 [3]             BNE     >
'0E63                  (      loader6.asm):00058         CountedZero:
Data "EE8C8A"
'0E63 EE8C8A           (      loader6.asm):00059 [5+1]           LDU     Divisor,PCR   * Restore the countdown
Data "EF8C8B"
'0E66 EF8C8B           (      loader6.asm):00060 [5+1]           STU     Counter,PCR   * value again
Data "A69C8A"
'0E69 A69C8A           (      loader6.asm):00061 [4+4]           LDA     [LDPTRAD,PCR] * Get byte from screen
Data "8B40"
'0E6C 8B40             (      loader6.asm):00062 [2]             ADDA    #64       * invert the colour from black to green
Data "A79C85"
'0E6E A79C85           (      loader6.asm):00063 [4+4]           STA     [LDPTRAD,PCR] * update the screen
Data "6C8C83"
'0E71 6C8C83           (      loader6.asm):00064 [6+1]           INC     LDPTRAD+1,PCR * move the pointer on the screen to the right
'                      (      loader6.asm):00065         !
Data "7EA176"
'0E74 7EA176           (      loader6.asm):00066 [4]             JMP     $A176     * Get a byte from file in accumulator A and return to calling routine
'                      (      loader6.asm):00067
'0E77                  (      loader6.asm):00068         HighRAM:
Data "8DDA"
'0E77 8DDA             (      loader6.asm):00069 [7]             BSR     GetByte   * Get a byte from file in accumulator A
Data "1A50"
'0E79 1A50             (      loader6.asm):00070 [3]             ORCC    #%01010000  * SET F and I bits hi of the Condition Code register this disables the FIRQ and IRQ - need this if we are writing to the RAM $8000-$FFFF
Data "F7FFDF"
'0E7B F7FFDF           (      loader6.asm):00071 [5]             STB     $FFDF     * Put machine in ALL RAM mode
Data "A780"
'0E7E A780             (      loader6.asm):00072 [4+2]           STA     ,X+       * store it
Data "F7FFDE"
'0E80 F7FFDE           (      loader6.asm):00073 [5]             STB     $FFDE     * Put it back in normal ROM mode
Data "1CAF"
'0E83 1CAF             (      loader6.asm):00074 [3]             ANDCC   #%10101111  * SET F and I bits low of the Condition Code register this enables the FIRQ and IRQ
Data "313F"
'0E85 313F             (      loader6.asm):00075 [4+1]           LEAY    -1,Y
Data "26EE"
'0E87 26EE             (      loader6.asm):00076 [3]             BNE     HighRAM   * keep looping if not done
Data "209D"
'0E89 209D             (      loader6.asm):00077 [3]             BRA     NEXT      * look for another block
'                      (      loader6.asm):00078
'0E8B                  (      loader6.asm):00079         EOF:
Data "8DC6"
'0E8B 8DC6             (      loader6.asm):00080 [7]             BSR     GetByte   * Get a byte from file in accumulator A
Data "8DC4"
'0E8D 8DC4             (      loader6.asm):00081 [7]             BSR     GetByte   * Get a byte from file in accumulator A
Data "8DC2"
'0E8F 8DC2             (      loader6.asm):00082 [7]             BSR     GetByte   * Get a byte from file in accumulator A
Data "1F89"
'0E91 1F89             (      loader6.asm):00083 [6]             TFR     A,B       * Save MSB of EXEC address in B temporarily
Data "8DBE"
'0E93 8DBE             (      loader6.asm):00084 [7]             BSR     GetByte   * Get a byte from file in accumulator A
Data "1E89"
'0E95 1E89             (      loader6.asm):00085 [8]             EXG     A,B       * re-arrange LSB in A and MSB in B to proper MSB,LSB in D
Data "ED8D0026"
'0E97 ED8D0026         (      loader6.asm):00086 [5+5]           STD     StartUserProgram+1,PCR * EXECute address is stored as self modifying code below so it will be JuMPed to
Data "1A50"
'0E9B 1A50             (      loader6.asm):00087 [3]             ORCC    #%01010000  * SET F and I bits hi of the Condition Code register this disables the FIRQ and IRQ - need this if we are writing to the RAM $8000-$FFFF
Data "F7FFDF"
'0E9D F7FFDF           (      loader6.asm):00088 [5]             STB     $FFDF     * Put machine in ALL RAM mode
Data "AE8DFF4E"
'0EA0 AE8DFF4E         (      loader6.asm):00089 [5+5]           LDX     Low_Program_Data,PCR
Data "8CFFFF"
'0EA4 8CFFFF           (      loader6.asm):00090 [4]             CMPX    #$FFFF    * Test if X = $FFFF
Data "2713"
'0EA7 2713             (      loader6.asm):00091 [3]             BEQ     Set_Display_Normal * If X = $FFFF then the low RAM isn't loaded into by the users program, skip ahead
'0EA9                  (      loader6.asm):00092         CheckMore:
Data "A680"
'0EA9 A680             (      loader6.asm):00093 [4+2]           LDA     ,X+       * If it's zero then copy bytes to low RAM
Data "260F"
'0EAB 260F             (      loader6.asm):00094 [3]             BNE     Set_Display_Normal  * End block copying with a $FF
Data "10AE81"
'0EAD 10AE81           (      loader6.asm):00095 [6+3]           LDY     ,X++      * D = the length of the data block
Data "EE81"
'0EB0 EE81             (      loader6.asm):00096 [5+3]           LDU     ,X++      * U = Load Start Address
Data "A680"
'0EB2 A680             (      loader6.asm):00097 [5+2]   !       LDA     ,X+
Data "A7C0"
'0EB4 A7C0             (      loader6.asm):00098 [5+2]           STA     ,U+
Data "313F"
'0EB6 313F             (      loader6.asm):00099 [4+1]           LEAY    -1,Y
Data "26F8"
'0EB8 26F8             (      loader6.asm):00100 [3]             BNE     <
Data "20ED"
'0EBA 20ED             (      loader6.asm):00101 [3]             BRA     CheckMore
'                      (      loader6.asm):00102
'0EBC                  (      loader6.asm):00103         Set_Display_Normal:
Data "328D0003"
'0EBC 328D0003         (      loader6.asm):00104 [4+5]           LEAS    Program_Data,PCR * For now make the stack pointer use the space this loader used, the user program should control the stack after this point.
'0EC0                  (      loader6.asm):00105         StartUserProgram:
Data "7E0000"
'0EC0 7E0000           (      loader6.asm):00106 [4]             JMP     >$0000         * Jump to EXECute address this address is self modifying code from above
'0EC3                  (      loader6.asm):00107         Program_Data:
'                      (      loader6.asm):00108
'                      (      loader6.asm):00109
'                      (      loader6.asm):00110                 END     START
'




'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

