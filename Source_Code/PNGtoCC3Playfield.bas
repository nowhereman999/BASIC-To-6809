' Playfield creator

VersionNumber$ = "0.10"
'       - First version

'PLAYFIELD 1 ' Scrollable area of 256 x 7872 x 16 colours
'PLAYFIELD 2 ' Scrollable area of 512 x 3840 x 16 colours
'PLAYFIELD 3 ' Scrollable area of 1024 x 512 x 16 colours
'PLAYFIELD 4 ' Scrollable area of 2048 x 256 x 16 colours
'PLAYFIELD 5 ' Scrollable area of 2560 x 192 x 16 colours

' May add the 256 NTSC composite modes later...

$ScreenHide
$Console
_Dest _Console

Dim OrderedArray(7, 7) As Integer
' 2x2 ordered dither
Data 0,2,8,0,2,0,10,0
Data 3,1,0,0,0,0,0,0
Data 3,1,4,0,14,0,6,0
Data 0,0,0,0,0,0,0,0
Data 3,0,11,0,1,0,9,0
Data 0,0,0,0,0,0,0,0
Data 15,0,7,0,13,0,5,0
Data 0,0,0,0,0,0,0,0

For y = 0 To 7
    For x = 0 To 7
        Read OrderedArray(x, y)
        '  OrderedArray(x, y) = Int((OrderedArray(x, y) * 255) / 63)
    Next x
Next y

Dim DiskOut(10000000) As _Unsigned _Byte

Dim R As Integer, G As Integer, B As Integer
Dim bestIndex As Integer
Dim bestDist As Long, dist As Long

Dim CoCo3Pal$(16)

Dim ColourList$(63)
For x = 0 To 63
    Read ColourList$(x) ' Get the colour names
Next x

Dim ColoursToUse(255, 2) As Integer ' Stores RGB values

Dim i As Integer

Dim array(50000000) As _Byte
Tab$ = String$(8, " ") ' tab space in output
FI = 0
count = _CommandCount
If count > 0 Then GoTo 100
99 Print: Print "PNG to CoCo 3 Playfield Converter v"; VersionNumber$; " by Glen Hewlett"
Print "Converts a PNG image file into a CoCo 3 compatible Playfield that can be LOADMed on a CoCo 3"
Print "There are size restrictions on the PNG image:"
Print "The PNG width must be 512 or more pixels and a multiple of 256 pixels.  Example a width of 256 x 7 = 1792 is fine but a width of 1700"
Print "will be truncated to 256 x 6 = 1536 pixels."
Print "The PNG height must be 192 or more pixels and a multiple of 64.  Example a height of 64 x 7 = 448 is fine but a height of 400 will be"
Print "truncated to 64 x 6 = 384 pixels."
Print
Print "Usage: PNGtoCC3Playfield -px [-dx] [-makepal] [-blkxxx] [-big] InName.png"
Print "Where:"
Print "InName.png is a 32 bit RGBA (includes transparency) png file"
Print "-px      - Playfield # which represents a specific scrolling playfield size.  Values are:"
Print "           1 - 256 x 7872 pixel playfield with 16 colours (width must be 256 and height must be greater than 192 and a multiple of 64)"
Print "           2 - 512 x 3840 pixel playfield with 16 colours (width must be 512 pixels)"
Print "           3 - 1024 x 512 pixel playfield with 16 colours (width must be 1024 and height must be 512"
Print "           4 - 2048 x 256 pixel playfield with 16 colours (height must be 256 pixels)"
Print "           5 - 2560 x 192 pixel playfield with 16 colours (height must be 192 pixels)"
Print
Print "-dx      - Selects Dither method to use for the playfield image"
Print "           Where x is:"
Print "           0 = No Dithering"
Print "           1 = Floyd-Steinberg Dithering (Default)"
Print "           2 = Blue Noise Mask Dithering"
Print "           3 = Ordered Dithering"
Print
Print "-makepal - During the playfield conversion it will also create a palette file called CoCo3_Palette.asm for use with other"
Print "           images and other CoCo 3 programs."
Print "           If this option isn't given, it will use the CoCo3_Palette.asm file and use those colours for use with creating the playfield"
Print
Print "-blkxxx    The starting 8k block in the CoCo 3 RAM to start saving the playfield image (default is 128)"
Print
Print "-small   - Make many small .BIN files to be LOADMed from many floppy disks"
Print "           The Default is to make one big file to be loaded into memory off the SD card with the SDC_BIGLOADM command"
System
100 Verbose = 0
MakePal = 0
BlkStart = 128
DitherType = 1
BigLoadm = 1 ' default is to make an SDC_BIGLOADM file
PlayfieldType = 0
For check = 1 To count
    N$ = Command$(check)
    If LCase$(Left$(N$, 6)) = "-small" Then BigLoadm = 0: GoTo 120
    If LCase$(Left$(N$, 8)) = "-makepal" Then MakePal = 1: GoTo 120
    If LCase$(Left$(N$, 4)) = "-blk" Then BlkStart = Val(Right$(N$, Len(N$) - 4)): GoTo 120
    If LCase$(Left$(N$, 2)) = "-d" Then DitherType = Val(Right$(N$, Len(N$) - 2)): GoTo 120
    If LCase$(Left$(N$, 2)) = "-p" Then PlayfieldType = Val(Right$(N$, Len(N$) - 2)): GoTo 120
    ' check if we got a file name yet if so then the next filename will be output
    If FI > 0 Then FName$ = N$: GoTo 120
    FI = 1
    FName$ = N$
    Open FName$ For Append As #1
    length = LOF(1)
    Close #1
    If length < 1 Then Print "Error file: "; FName$; " is 0 bytes. Or doesn't exits.": Kill FName$: End
    ' Print "Length of Input file is:"; length; " = $"; Hex$(length)
    GoTo 200
    Open FName$ For Binary As #1
    Get #1, , array()
    length = LOF(1)
    Close #1
120 Next check
Outname$ = FName$ + ".asm"
200
If PlayfieldType < 1 Or PlayfieldType > 5 Then Print "ERROR: Playfield must be given and be a number between 1 and 5": GoTo 99

Colours = 16
FileName$ = GetFilenameOnly$(FName$) ' convert full path of filename to just the filename
FName$ = FileName$
If Right$(UCase$(FileName$), 3) <> "PNG" Then Print "Input file must be a 32 bit .PNG file that includes transparency": System
If CodeName$ = "" Then
    CodeName$ = Left$(FileName$, Len(FileName$) - 4)
End If
FNameNoExt$ = CodeName$

' Set up the graphics screen
Screen _NewImage(8000, 8000, 32)

' Load the image
myImage = _LoadImage(FName$, 32)

' Get the width and height of the image
imageWidth = _Width(myImage)
imageHeight = _Height(myImage)

' Set the array size
Dim pixelColors(imageWidth - 1, imageHeight - 1) As Long

' Display the image on-screen
_PutImage (0, 0), myImage ' Adjust as needed to ensure it's fully on-screen
' Read pixel colors from the image on the screen
For y = 0 To imageHeight - 1
    For x = 0 To imageWidth - 1
        pixelColors(x, y) = Point(x, y) ' Long values 32 bit colour
        ' Format of the long values in hex is AARRGGBB where AA is the Alpha value, 00 is tranparent, FF is full intensity
        '                                              RR,GG,BB are 8 bit values of the colours Red,Green,Blue
    Next x
Next y

' Free the memory for the image
_FreeImage myImage
_Dest _Console

If imageWidth < 256 Then Print "Error, image must be at least 256 pixels wide": System
imageWidth = Int(imageWidth / 256) * 256
If imageHeight < 192 Then Print "Error, image must be at least 192 pixels tall": System
imageHeight = Int(imageHeight / 64) * 64

Print "Generating a Playfield image"
Print "Width:"; imageWidth
Print "Height:"; imageHeight
Print "Calculating the best 16 colours to use..."


' We need to deal with palette info:
CoCo3_Palette$ = "CoCo3_Palette.asm"
If MakePal = 0 Then GoTo LoadCC3Palette ' Go load the and use palette (skip making one)
' Create a CoCo3_Palette.asm file from the colours used in this image

Dim colorArray(16777215) As Long ' 24-bit colors (max 16.7 million)
Dim color1 As Long
Dim uniqueColors As Long
Dim sortedColors(15) As Long
Dim sortedCounts(15) As Long
' Count color occurrences
For y = 0 To imageHeight - 1
    For x = 0 To imageWidth - 1
        Pixel$ = Right$("00000000" + Hex$(pixelColors(x, y)), 8)
        R = Val("&H" + Mid$(Pixel$, 3, 2))
        If R < 64 Then R = 0: GoTo HandleGreen
        If R < 128 Then R = &H55: GoTo HandleGreen
        If R > 191 Then R = &HFF: GoTo HandleGreen
        R = &HAA
        HandleGreen:
        G = Val("&H" + Mid$(Pixel$, 5, 2))
        If G < 64 Then G = 0: GoTo HandleBlue
        If G < 128 Then G = &H55: GoTo HandleBlue
        If G > 191 Then G = &HFF: GoTo HandleBlue
        G = &HAA
        HandleBlue:
        B = Val("&H" + Mid$(Pixel$, 7, 2))
        If B < 64 Then B = 0: GoTo Handled
        If B < 128 Then B = &H55: GoTo Handled
        If B > 191 Then B = &HFF: GoTo Handled
        B = &HAA
        Handled:
        ' Print R, G, B
        color1 = R * 65536 + G * 256 + B
        If colorArray(color1) = 0 Then uniqueColors = uniqueColors + 1
        colorArray(color1) = colorArray(color1) + 1
    Next x
Next y
' Find the 16 most common colors
For i = 0 To 15
    maxCount = 0
    maxIndex = -1
    For color1 = 0 To 16777215
        If colorArray(color1) > maxCount Then
            maxCount = colorArray(color1)
            maxIndex = color1
        End If
    Next color1
    If maxIndex <> -1 Then
        sortedColors(i) = maxIndex
        sortedCounts(i) = maxCount
        colorArray(maxIndex) = 0 ' Remove from further consideration
    End If
Next i

Open CoCo3_Palette$ For Output As #1
Print #1, "; Palette file generated by PNGtoCC3Playfield Version "; VersionNumber$
Print #1, "; from PNG file: "; FName$
Print #1, "; Source file has"; uniqueColors; "CoCo 3 capable colours"
Print #1, "; Converted it to 16 colours below:"
Print #1, ";               %xxRGBrgb     Value   Colour Name (Times Used)"
Print #1, "CoCo3_Palette:"
UnUsedSlot = 0
For i = 0 To 15
    v = 0
    V$ = Right$("000000" + Hex$(sortedColors(i)), 6)
    R$ = Left$(V$, 1): G$ = Mid$(V$, 3, 1): B$ = Right$(V$, 1)
    If R$ = "5" Then v = v + 4 ' xx000100
    If R$ = "A" Then v = v + 32 'xx100000
    If R$ = "F" Then v = v + 36 'xx100100
    If G$ = "5" Then v = v + 2 ' xx000010
    If G$ = "A" Then v = v + 16 'xx010000
    If G$ = "F" Then v = v + 18 'xx100100
    If B$ = "5" Then v = v + 1 ' xx000001
    If B$ = "A" Then v = v + 8 ' xx001000
    If B$ = "F" Then v = v + 9 ' xx001001
    binStr$ = ""
    For i2 = 0 To 7
        If v And (2 ^ (7 - i2)) Then
            binStr$ = binStr$ + "1"
        Else
            binStr$ = binStr$ + "0"
        End If
    Next i2
    Instr1$ = "FCB": Instr2$ = "%" + binStr$
    Com$ = ""
    If v < 10 Then Com$ = Com$ + " "
    Com$ = Com$ + Str$(v) + "    "

    If v = 0 And UnUsedSlot = 1 Then
        Com$ = Com$ + "Unused Palette Slot (0)"
    Else
        Com$ = Com$ + ColourList$(v) + " ("
        n = sortedCounts(i): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        If N$ = "" Then N$ = "0"
        Com$ = Com$ + N$ + ")"
    End If
    Print #1, "        "; Instr1$; "     "; Instr2$; "     ;"; Com$
    If v = 0 And UnUsedSlot = 0 Then UnUsedSlot = 1
Next i
Close #1 ' Finished creating the CoCo3_Palette.asm file

LoadCC3Palette:
'Fill the palette with the colours from the CoCo3_Palette.asm file in the correct order
Open CoCo3_Palette$ For Append As #1
length = LOF(1)
Close #1
If length < 1 Then Print "ERROR: No "; CoCo3_Palette$; " file found in this folder": System
Open CoCo3_Palette$ For Input As #1
x = 0
While x < Colours
    Line Input #1, I$
    If InStr(I$, " FCB ") Then
        'Found a line to process
        P = InStr(I$, "%")
        CoCo3Pal$(x) = Mid$(I$, P, 9)
        'Handle CoCo 3 Colour conversion
        CoCo3String$ = CoCo3Pal$(x)
        Red$ = Mid$(CoCo3String$, 4, 1) + Mid$(CoCo3String$, 7, 1)
        ColourValue = 0
        If Red$ = "01" Then ColourValue = 85 * 65536
        If Red$ = "10" Then ColourValue = 170 * 65536
        If Red$ = "11" Then ColourValue = 255 * 65536
        Green$ = Mid$(CoCo3String$, 5, 1) + Mid$(CoCo3String$, 8, 1)
        If Green$ = "01" Then ColourValue = ColourValue + 85 * 256
        If Green$ = "10" Then ColourValue = ColourValue + 170 * 256
        If Green$ = "11" Then ColourValue = ColourValue + 255 * 256
        Blue$ = Mid$(CoCo3String$, 6, 1) + Mid$(CoCo3String$, 9, 1)
        If Blue$ = "01" Then ColourValue = ColourValue + 85
        If Blue$ = "10" Then ColourValue = ColourValue + 170
        If Blue$ = "11" Then ColourValue = ColourValue + 255
        ' Save it as a 8 bit colour values for Red,Green & Blue
        sortedColors(x) = ColourValue
        x = x + 1
    End If
Wend
Close #1

' Do dither which will convert pixels in pixelColors(x,Y) to DitherOut(x,y) = bestindex
Dim errorR(imageWidth, imageHeight) As Integer
Dim errorG(imageWidth, imageHeight) As Integer
Dim errorB(imageWidth, imageHeight) As Integer
Dim DitherOut(imageWidth - 1, imageHeight - 1) As _Unsigned _Byte
Select Case DitherType + 1
    Case 1
        Print "No dither option selected"
    Case 2
        Print "Doing Floyd-Steinburg dither (default)"
    Case 3
        Print "Doing Blue Noise Texture dither"
    Case 4
        Print "Doing Ordered dither"
End Select
On DitherType + 1 GOSUB DoNoDither, DoFloydDither, DoBlueNoiseTexture, DoOrderDither

FileNumber = 0
BlockPointer = BlkStart 'BlockNumber= 8k block in CoCo3's memory
On PlayfieldType GOSUB View1_256_7872, View2_512x3840, View3_1024x512, View4_2048x256, View5_2560x192

System

'Make a scrollable background image which will be 256 x 7872 pixels wide
View1_256_7872:
If imageWidth <> 256 Then Print "Image Width is:"; imageWidth; "with playfield #1 file needs to be 256": GoTo 99
If imageHeight < 192 Then Print "Image Height is:"; imageHeight; "with playfield #1 file needs to be 192 or higher": GoTo 99
If imageHeight > 7872 Then Print "Image Height is:"; imageHeight; "with playfield #1 file needs to be 7872 or less": GoTo 99
If imageHeight / 64 <> Int(imageHeight / 64) Then Print "Image Height must be a multiple of 64": GoTo 99

P = 0
If BigLoadm = 1 Then
    ' Do one big special SDC_BIGLOADM file
    ' Make a 512 byte Bank table with a value of $FFFF to flag the end
    TotalBlocks = 128
    BlockCount = 0
    DiskOut(P) = &H00: P = P + 1
    DiskOut(P) = &H01: P = P + 1 ' Save file version 1
    BlockCount = BlockCount + 1
    For BlockNumber = 1 To TotalBlocks
        DiskOut(P) = Int(BlockPointer / 256): P = P + 1
        DiskOut(P) = BlockPointer - Int(BlockPointer / 256) * 256: P = P + 1
        BlockCount = BlockCount + 1
        BlockPointer = BlockPointer + 1
    Next BlockNumber
    DiskOut(P) = &HFF: P = P + 1
    DiskOut(P) = &HFF: P = P + 1
    BlockCount = BlockCount + 1
    ' Fill the rest of the table with zeros
    While BlockCount <> 256
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        BlockCount = BlockCount + 1
    Wend
    ' Write the actual screen blocks to the file
    y = 0
    If imageHeight < 4097 Then GoTo DoUntilEnd0
    While y <= 4095
        For x = 0 To 255 Step 2
            DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
        Next x
        y = y + 1
    Wend
    ' Fix middle blocks
    ' We've reached the end of the 512k video block
    ' We need to repeat rows 3968 to 4095
    y = 3904
    While y <= 4095
        For x = 0 To 255 Step 2
            DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
        Next x
        y = y + 1
    Wend

    ' Write until the end
    DoUntilEnd0:
    While y <= imageHeight - 1
        For x = 0 To 255 Step 2
            DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
        Next x
        y = y + 1
    Wend

    ReDim LastOutArray(P - 1) As _Unsigned _Byte
    c = 0
    For Op = 0 To P - 1
        LastOutArray(Op) = DiskOut(c): c = c + 1
    Next Op
    n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    N$ = Right$("00" + N$, 2)
    TempName$ = FNameNoExt$ + N$ + ".BIN"
    If _FileExists(TempName$) Then Kill TempName$
    If Verbose > 0 Then Print "Writing Disk file "; TempName$
    Open TempName$ For Binary As #2
    Put #2, , LastOutArray()
    Close #2
Else
    ' Do multiple files for use with SDC_LOADM or LOADM
    ' Write the actual screen blocks to the file
    y = 0
    If imageHeight < 4097 Then GoTo DoUntilEnd1
    While y <= 4095
        P = 0
        StartLocation = &HFFA2
        Blocksize = 3 ' every 64 rows is &H2000 bytes, so a screen of 192 rows will be 3 * &H2000
        If BlockPointer = skip Then BlockPointer = (BlockPointer And 192) + 64
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1

        StartLocation = &H4000
        Blocksize = &H2000 * 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        ' Write three blocks to the file (each file is one screen of 256 pixels x 192 pixels, which is 128 bytes x 192 rows)
        c = 0
        While c < 192 * 128
            For x = 0 To 255 Step 2
                DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
            Next x
            y = y + 1
        Wend

        ' Put 8k block back to normal
        NormalBlock2 = &H3A ' 8k block in CoCo3's memory
        StartLocation = &HFFA2
        Blocksize = 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        ' Postamble
        DiskOut(P) = 255: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        ' Last block is a 255 then two zero's then the execute address
        ' Next two bytes is the block length, then the address in RAM that the data will load at
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1 ' Execute address
        DiskOut(P) = 0: P = P + 1 ' Execute address
        c = 0
        ReDim LastOutArray(P - 1) As _Unsigned _Byte
        For Op = 0 To P - 1
            LastOutArray(Op) = DiskOut(c): c = c + 1
        Next Op
        n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        N$ = Right$("00" + N$, 2)
        TempName$ = FNameNoExt$ + N$ + ".BIN"
        If _FileExists(TempName$) Then Kill TempName$
        If Verbose > 0 Then Print "Writing Disk file "; TempName$
        Open TempName$ For Binary As #2
        Put #2, , LastOutArray()
        Close #2
        FileNumber = FileNumber + 1
    Wend
    ' Fix middle blocks
    ' We've reached the end of the 512k video block
    ' We need to repeat rows 3968 to 4095
    y = 3904
    While y <= 4095
        P = 0
        StartLocation = &HFFA2
        Blocksize = 3 ' every 64 rows is &H2000 bytes, so a screen of 192 rows will be 3 * &H2000
        If BlockPointer = skip Then BlockPointer = (BlockPointer And 192) + 64
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1

        StartLocation = &H4000
        Blocksize = &H2000 * 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        ' Write three blocks to the file (each file is one screen of 256 pixels x 192 pixels, which is 128 bytes x 192 rows)
        c = 0
        While c < 192 * 128
            For x = 0 To 255 Step 2
                DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
            Next x
            y = y + 1
        Wend

        ' Put 8k block back to normal
        NormalBlock2 = &H3A ' 8k block in CoCo3's memory
        StartLocation = &HFFA2
        Blocksize = 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        ' Postamble
        DiskOut(P) = 255: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        ' Last block is a 255 then two zero's then the execute address
        ' Next two bytes is the block length, then the address in RAM that the data will load at
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1 ' Execute address
        DiskOut(P) = 0: P = P + 1 ' Execute address
        c = 0
        ReDim LastOutArray(P - 1) As _Unsigned _Byte
        For Op = 0 To P - 1
            LastOutArray(Op) = DiskOut(c): c = c + 1
        Next Op
        n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        N$ = Right$("00" + N$, 2)
        TempName$ = FNameNoExt$ + N$ + ".BIN"
        If _FileExists(TempName$) Then Kill TempName$
        If Verbose > 0 Then Print "Writing Disk file "; TempName$
        Open TempName$ For Binary As #2
        Put #2, , LastOutArray()
        Close #2
        FileNumber = FileNumber + 1
    Wend
    ' Write until the end
    DoUntilEnd1:
    While y <= imageHeight - 1
        P = 0
        StartLocation = &HFFA2
        Blocksize = 3 ' every 64 rows is &H2000 bytes, so a screen of 192 rows will be 3 * &H2000
        If BlockPointer = skip Then BlockPointer = (BlockPointer And 192) + 64
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1

        StartLocation = &H4000
        Blocksize = &H2000 * 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        ' Write three blocks to the file (each file is one screen of 256 pixels x 192 pixels, which is 128 bytes x 192 rows)
        c = 0
        While c < 192 * 128
            For x = 0 To 255 Step 2
                DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
            Next x
            y = y + 1
        Wend

        ' Put 8k block back to normal
        NormalBlock2 = &H3A ' 8k block in CoCo3's memory
        StartLocation = &HFFA2
        Blocksize = 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        ' Postamble
        DiskOut(P) = 255: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        ' Last block is a 255 then two zero's then the execute address
        ' Next two bytes is the block length, then the address in RAM that the data will load at
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1 ' Execute address
        DiskOut(P) = 0: P = P + 1 ' Execute address
        c = 0
        ReDim LastOutArray(P - 1) As _Unsigned _Byte
        For Op = 0 To P - 1
            LastOutArray(Op) = DiskOut(c): c = c + 1
        Next Op
        n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        N$ = Right$("00" + N$, 2)
        TempName$ = FNameNoExt$ + N$ + ".BIN"
        If _FileExists(TempName$) Then Kill TempName$
        If Verbose > 0 Then Print "Writing Disk file "; TempName$
        Open TempName$ For Binary As #2
        Put #2, , LastOutArray()
        Close #2
        FileNumber = FileNumber + 1
    Wend
End If
Return

'Make a scrollable background image which will be 512 x 3840 pixels wide
View2_512x3840:
If imageWidth <> 512 Then Print "Image Width is:"; imageWidth; "with playfield #2 width must be 512": GoTo 99
If imageHeight < 192 Then Print "Image Height is:"; imageHeight; "with playfield #2 file needs to be 192 or higher": GoTo 99
If imageHeight > 3840 Then Print "Image Height is:"; imageHeight; "with playfield #2 file needs to be 3840 or less": GoTo 99
If imageHeight / 192 <> Int(imageHeight / 192) Then Print "Image Height must be a multiple of 192": GoTo 99

P = 0
If BigLoadm = 1 Then
    ' Do one big special SDC_BIGLOADM file
    ' Make a 512 byte Bank table with a value of $FFFF to flag the end
    TotalBlocks = 128
    BlockCount = 0
    DiskOut(P) = &H00: P = P + 1
    DiskOut(P) = &H01: P = P + 1 ' Save file version 1
    BlockCount = BlockCount + 1
    For BlockNumber = 1 To TotalBlocks
        DiskOut(P) = Int(BlockPointer / 256): P = P + 1
        DiskOut(P) = BlockPointer - Int(BlockPointer / 256) * 256: P = P + 1
        BlockCount = BlockCount + 1
        BlockPointer = BlockPointer + 1
    Next BlockNumber
    DiskOut(P) = &HFF: P = P + 1
    DiskOut(P) = &HFF: P = P + 1
    BlockCount = BlockCount + 1
    ' Fill the rest of the table with zeros
    While BlockCount <> 256
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        BlockCount = BlockCount + 1
    Wend
    ' Write the actual screen blocks to the file
    y = 0
    If imageHeight < 2049 Then GoTo DoUntilEnd2
    While y <= 2047
        For x = 0 To 511 Step 2
            DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
        Next x
        y = y + 1
    Wend
    ' Fix middle blocks
    ' We've reached the end of the 512k video block
    ' We need to repeat rows 1856 to 2047
    y = 1856
    While y <= 2047
        For x = 0 To 511 Step 2
            DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
        Next x
        y = y + 1
    Wend

    ' Write until the end
    DoUntilEnd2:
    While y <= imageHeight - 1
        For x = 0 To 511 Step 2
            DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
        Next x
        y = y + 1
    Wend

    ReDim LastOutArray(P - 1) As _Unsigned _Byte
    c = 0
    For Op = 0 To P - 1
        LastOutArray(Op) = DiskOut(c): c = c + 1
    Next Op
    n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    N$ = Right$("00" + N$, 2)
    TempName$ = FNameNoExt$ + N$ + ".BIN"
    If _FileExists(TempName$) Then Kill TempName$
    If Verbose > 0 Then Print "Writing Disk file "; TempName$
    Open TempName$ For Binary As #2
    Put #2, , LastOutArray()
    Close #2
Else
    ' Do multiple files for use with SDC_LOADM or LOADM
    ' Write the actual screen blocks to the file
    y = 0
    If imageHeight < 2049 Then GoTo DoUntilEnd3
    While y <= 2047
        P = 0
        StartLocation = &HFFA2
        Blocksize = 3 ' every 64 rows is &H2000 bytes, so a screen of 192 rows will be 3 * &H2000
        If BlockPointer = skip Then BlockPointer = (BlockPointer And 192) + 64
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        StartLocation = &H4000
        Blocksize = &H2000 * 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        ' Write three blocks to the file (each file is one screen of 256 pixels x 192 pixels, which is 128 bytes x 192 rows)
        c = 0
        While c < &H6000
            For x = 0 To 511 Step 2
                DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
            Next x
            y = y + 1
        Wend
        ' Put 8k block back to normal
        NormalBlock2 = &H3A ' 8k block in CoCo3's memory
        StartLocation = &HFFA2
        Blocksize = 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        ' Postamble
        DiskOut(P) = 255: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        ' Last block is a 255 then two zero's then the execute address
        ' Next two bytes is the block length, then the address in RAM that the data will load at
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1 ' Execute address
        DiskOut(P) = 0: P = P + 1 ' Execute address
        c = 0
        ReDim LastOutArray(P - 1) As _Unsigned _Byte
        For Op = 0 To P - 1
            LastOutArray(Op) = DiskOut(c): c = c + 1
        Next Op
        n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        N$ = Right$("00" + N$, 2)
        TempName$ = FNameNoExt$ + N$ + ".BIN"
        If _FileExists(TempName$) Then Kill TempName$
        If Verbose > 0 Then Print "Writing Disk file "; TempName$
        Open TempName$ For Binary As #2
        Put #2, , LastOutArray()
        Close #2
        FileNumber = FileNumber + 1
        P = 0
        StartLocation = &HFFA2
        Blocksize = 3 ' every 64 rows is &H2000 bytes, so a screen of 192 rows will be 3 * &H2000
        If BlockPointer = skip Then BlockPointer = (BlockPointer And 192) + 64
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1

        StartLocation = &H4000
        Blocksize = &H2000 * 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        ' Write three blocks to the file (each file is one screen of 256 pixels x 192 pixels, which is 128 bytes x 192 rows)
        c = 0
        While c < &H6000
            For x = 0 To 511 Step 2
                DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
            Next x
            y = y + 1
        Wend
        ' Put 8k block back to normal
        NormalBlock2 = &H3A ' 8k block in CoCo3's memory
        StartLocation = &HFFA2
        Blocksize = 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        ' Postamble
        DiskOut(P) = 255: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        ' Last block is a 255 then two zero's then the execute address
        ' Next two bytes is the block length, then the address in RAM that the data will load at
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1 ' Execute address
        DiskOut(P) = 0: P = P + 1 ' Execute address
        c = 0
        ReDim LastOutArray(P - 1) As _Unsigned _Byte
        For Op = 0 To P - 1
            LastOutArray(Op) = DiskOut(c): c = c + 1
        Next Op
        n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        N$ = Right$("00" + N$, 2)
        TempName$ = FNameNoExt$ + N$ + ".BIN"
        If _FileExists(TempName$) Then Kill TempName$
        If Verbose > 0 Then Print "Writing Disk file "; TempName$
        Open TempName$ For Binary As #2
        Put #2, , LastOutArray()
        Close #2
        FileNumber = FileNumber + 1
    Wend
    ' Fix middle blocks
    ' We've reached the end of the 512k video block
    ' We need to repeat rows 3968 to 4095
    y = 1856
    While y <= 2047
        P = 0
        StartLocation = &HFFA2
        Blocksize = 3 ' every 64 rows is &H2000 bytes, so a screen of 192 rows will be 3 * &H2000
        If BlockPointer = skip Then BlockPointer = (BlockPointer And 192) + 64
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1

        StartLocation = &H4000
        Blocksize = &H2000 * 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        ' Write three blocks to the file (each file is one screen of 256 pixels x 192 pixels, which is 128 bytes x 192 rows)
        c = 0
        While c < &H6000
            For x = 0 To 511 Step 2
                DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
            Next x
            y = y + 1
        Wend
        ' Put 8k block back to normal
        NormalBlock2 = &H3A ' 8k block in CoCo3's memory
        StartLocation = &HFFA2
        Blocksize = 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        ' Postamble
        DiskOut(P) = 255: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        ' Last block is a 255 then two zero's then the execute address
        ' Next two bytes is the block length, then the address in RAM that the data will load at
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1 ' Execute address
        DiskOut(P) = 0: P = P + 1 ' Execute address
        c = 0
        ReDim LastOutArray(P - 1) As _Unsigned _Byte
        For Op = 0 To P - 1
            LastOutArray(Op) = DiskOut(c): c = c + 1
        Next Op
        n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        N$ = Right$("00" + N$, 2)
        TempName$ = FNameNoExt$ + N$ + ".BIN"
        If _FileExists(TempName$) Then Kill TempName$
        If Verbose > 0 Then Print "Writing Disk file "; TempName$
        Open TempName$ For Binary As #2
        Put #2, , LastOutArray()
        Close #2
        FileNumber = FileNumber + 1
        P = 0
        StartLocation = &HFFA2
        Blocksize = 3 ' every 64 rows is &H2000 bytes, so a screen of 192 rows will be 3 * &H2000
        If BlockPointer = skip Then BlockPointer = (BlockPointer And 192) + 64
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1

        StartLocation = &H4000
        Blocksize = &H2000 * 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        ' Write three blocks to the file (each file is one screen of 256 pixels x 192 pixels, which is 128 bytes x 192 rows)
        c = 0
        While c < &H6000
            For x = 0 To 511 Step 2
                DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
            Next x
            y = y + 1
        Wend
        ' Put 8k block back to normal
        NormalBlock2 = &H3A ' 8k block in CoCo3's memory
        StartLocation = &HFFA2
        Blocksize = 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        ' Postamble
        DiskOut(P) = 255: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        ' Last block is a 255 then two zero's then the execute address
        ' Next two bytes is the block length, then the address in RAM that the data will load at
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1 ' Execute address
        DiskOut(P) = 0: P = P + 1 ' Execute address
        c = 0
        ReDim LastOutArray(P - 1) As _Unsigned _Byte
        For Op = 0 To P - 1
            LastOutArray(Op) = DiskOut(c): c = c + 1
        Next Op
        n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        N$ = Right$("00" + N$, 2)
        TempName$ = FNameNoExt$ + N$ + ".BIN"
        If _FileExists(TempName$) Then Kill TempName$
        If Verbose > 0 Then Print "Writing Disk file "; TempName$
        Open TempName$ For Binary As #2
        Put #2, , LastOutArray()
        Close #2
        FileNumber = FileNumber + 1
    Wend
    ' Write until the end
    DoUntilEnd3:
    While y <= imageHeight - 1
        P = 0
        StartLocation = &HFFA2
        Blocksize = 3 ' every 64 rows is &H2000 bytes, so a screen of 192 rows will be 3 * &H2000
        If BlockPointer = skip Then BlockPointer = (BlockPointer And 192) + 64
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1

        StartLocation = &H4000
        Blocksize = &H2000 * 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        ' Write three blocks to the file (each file is one screen of 256 pixels x 192 pixels, which is 128 bytes x 192 rows)
        c = 0
        While c < &H6000
            For x = 0 To 511 Step 2
                DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
            Next x
            y = y + 1
        Wend
        ' Put 8k block back to normal
        NormalBlock2 = &H3A ' 8k block in CoCo3's memory
        StartLocation = &HFFA2
        Blocksize = 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        ' Postamble
        DiskOut(P) = 255: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        ' Last block is a 255 then two zero's then the execute address
        ' Next two bytes is the block length, then the address in RAM that the data will load at
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1 ' Execute address
        DiskOut(P) = 0: P = P + 1 ' Execute address
        c = 0
        ReDim LastOutArray(P - 1) As _Unsigned _Byte
        For Op = 0 To P - 1
            LastOutArray(Op) = DiskOut(c): c = c + 1
        Next Op
        n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        N$ = Right$("00" + N$, 2)
        TempName$ = FNameNoExt$ + N$ + ".BIN"
        If _FileExists(TempName$) Then Kill TempName$
        If Verbose > 0 Then Print "Writing Disk file "; TempName$
        Open TempName$ For Binary As #2
        Put #2, , LastOutArray()
        Close #2
        FileNumber = FileNumber + 1
        P = 0
        StartLocation = &HFFA2
        Blocksize = 3 ' every 64 rows is &H2000 bytes, so a screen of 192 rows will be 3 * &H2000
        If BlockPointer = skip Then BlockPointer = (BlockPointer And 192) + 64
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1

        StartLocation = &H4000
        Blocksize = &H2000 * 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        ' Write three blocks to the file (each file is one screen of 256 pixels x 192 pixels, which is 128 bytes x 192 rows)
        c = 0
        While c < &H6000
            For x = 0 To 511 Step 2
                DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
            Next x
            y = y + 1
        Wend
        ' Put 8k block back to normal
        NormalBlock2 = &H3A ' 8k block in CoCo3's memory
        StartLocation = &HFFA2
        Blocksize = 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        ' Postamble
        DiskOut(P) = 255: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        ' Last block is a 255 then two zero's then the execute address
        ' Next two bytes is the block length, then the address in RAM that the data will load at
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1 ' Execute address
        DiskOut(P) = 0: P = P + 1 ' Execute address
        c = 0
        ReDim LastOutArray(P - 1) As _Unsigned _Byte
        For Op = 0 To P - 1
            LastOutArray(Op) = DiskOut(c): c = c + 1
        Next Op
        n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        N$ = Right$("00" + N$, 2)
        TempName$ = FNameNoExt$ + N$ + ".BIN"
        If _FileExists(TempName$) Then Kill TempName$
        If Verbose > 0 Then Print "Writing Disk file "; TempName$
        Open TempName$ For Binary As #2
        Put #2, , LastOutArray()
        Close #2
        FileNumber = FileNumber + 1
    Wend
End If
Return

'Make a scrollable background image which will be 1024 x 1024 pixels wide
View3_1024x512:
If imageWidth <> 1024 Then Print "Image Width is:"; imageWidth; "with playfield #3 file must be 1024": GoTo 99
If imageHeight < 256 Then Print "Image Height is:"; imageHeight; "with playfield #3 file needs to be 256 or higher": GoTo 99
If imageHeight > 1024 Then Print "Image Height is:"; imageHeight; "with playfield #3 file needs to be 1024 or less": GoTo 99
If imageHeight / 256 <> Int(imageHeight / 256) Then Print "Image Height must be a multiple of 256": GoTo 99

chunks = Int((imageHeight * 256) / &H2000)
skip = -1
P = 0
If BigLoadm = 1 Then
    ' Do one big special SDC_BIGLOADM file
    ' Make a 512 byte Bank table with a value of $FFFF to flag the end
    TotalBlocks = (Int(imageWidth / 256)) * 256 * imageHeight / &H2000
    BlockCount = 0
    DiskOut(P) = &H00: P = P + 1
    DiskOut(P) = &H01: P = P + 1 ' Save file version 1
    BlockCount = BlockCount + 1
    For BlockNumber = 1 To TotalBlocks
        If BlockPointer = skip Then BlockPointer = (BlockPointer And 192) + 64
        DiskOut(P) = Int(BlockPointer / 256): P = P + 1
        DiskOut(P) = BlockPointer - Int(BlockPointer / 256) * 256: P = P + 1
        BlockCount = BlockCount + 1
        BlockPointer = BlockPointer + 1
    Next BlockNumber
    DiskOut(P) = &HFF: P = P + 1
    DiskOut(P) = &HFF: P = P + 1
    BlockCount = BlockCount + 1
    ' Fill the rest of the table with zeros
    While BlockCount <> 256
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        BlockCount = BlockCount + 1
    Wend
    ' Write the actual screen blocks to the file
    For StartX = 0 To imageWidth - 511 Step 256
        For y = 0 To imageHeight - 1
            For x = StartX To StartX + 511 Step 2
                DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
            Next x
        Next y
    Next StartX

    c = 0
    ReDim LastOutArray(P - 1) As _Unsigned _Byte
    For Op = 0 To P - 1
        LastOutArray(Op) = DiskOut(c): c = c + 1
    Next Op
    n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    N$ = Right$("00" + N$, 2)
    TempName$ = FNameNoExt$ + N$ + ".BIN"
    If _FileExists(TempName$) Then Kill TempName$
    If Verbose > 0 Then Print "Writing Disk file "; TempName$
    Open TempName$ For Binary As #2
    Put #2, , LastOutArray()
    Close #2
Else
    ' Do multiple files for use with SDC_LOADM or LOADM
    fileSize = imageHeight * 256
    StartX = 0
    While StartX <= imageWidth - 511
        y = 0
        While y <= imageHeight - 1
            P = 0
            StartLocation = &HFFA2
            Blocksize = 4

            DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
            DiskOut(P) = Int(Blocksize / 256): P = P + 1
            DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = Int(StartLocation / 256): P = P + 1
            DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
            DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
            DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
            DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1

            StartLocation = &H4000
            Blocksize = &H2000 * 4
            DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
            DiskOut(P) = Int(Blocksize / 256): P = P + 1
            DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = Int(StartLocation / 256): P = P + 1
            DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
            ' Write the actual screen blocks to the files
            c = 0
            While c <> &H8000
                For x = StartX To StartX + 511 Step 2
                    DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
                Next x
                y = y + 1
            Wend
            ' Put 8k block back to normal
            NormalBlock2 = &H3A ' 8k block in CoCo3's memory
            StartLocation = &HFFA2
            Blocksize = 4
            DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
            DiskOut(P) = Int(Blocksize / 256): P = P + 1
            DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = Int(StartLocation / 256): P = P + 1
            DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
            DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
            DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
            DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
            ' Postamble
            DiskOut(P) = 255: P = P + 1 ' Preamble value 0 = data, 255 = Last block
            ' Last block is a 255 then two zero's then the execute address
            ' Next two bytes is the block length, then the address in RAM that the data will load at
            DiskOut(P) = 0: P = P + 1
            DiskOut(P) = 0: P = P + 1
            DiskOut(P) = 0: P = P + 1 ' Execute address
            DiskOut(P) = 0: P = P + 1 ' Execute address
            c = 0
            ReDim LastOutArray(P - 1) As _Unsigned _Byte
            For Op = 0 To P - 1
                LastOutArray(Op) = DiskOut(c): c = c + 1
            Next Op
            n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
            N$ = Right$("00" + N$, 2)
            TempName$ = FNameNoExt$ + N$ + ".BIN"
            If _FileExists(TempName$) Then Kill TempName$
            If Verbose > 0 Then Print "Writing Disk file "; TempName$
            Open TempName$ For Binary As #2
            Put #2, , LastOutArray()
            Close #2
            FileNumber = FileNumber + 1
        Wend
        StartX = StartX + 256 ' point at the next screen to the right
        BlockPointer = BlockPointer + 32
    Wend
End If
Return

View4_2048x256:
If imageWidth > 2048 Then Print "Image Width is:"; imageWidth; "with playfield #4 width must be 2048 or less": GoTo 99
If imageWidth < 512 Then Print "Image Width is:"; imageWidth; "with playfield #4 width must be 512 or more": GoTo 99
If imageWidth / 256 <> Int(imageWidth / 256) Then Print "Image Height must be a multiple of 256": GoTo 99
If imageHeight <> 256 Then Print "Image Height is:"; imageHeight; "with playfield #4 height must be 256": GoTo 99

P = 0
If BigLoadm = 1 Then
    ' Do one big special SDC_BIGLOADM file
    ' Make a 512 byte Bank table with a value of $FFFF to flag the end
    TotalBlocks = 128
    BlockCount = 0
    DiskOut(P) = &H00: P = P + 1
    DiskOut(P) = &H01: P = P + 1 ' Save file version 1
    BlockCount = BlockCount + 1
    For BlockNumber = 1 To TotalBlocks
        DiskOut(P) = Int(BlockPointer / 256): P = P + 1
        DiskOut(P) = BlockPointer - Int(BlockPointer / 256) * 256: P = P + 1
        BlockCount = BlockCount + 1
        BlockPointer = BlockPointer + 1
    Next BlockNumber
    DiskOut(P) = &HFF: P = P + 1
    DiskOut(P) = &HFF: P = P + 1
    BlockCount = BlockCount + 1
    ' Fill the rest of the table with zeros
    While BlockCount <> 256
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        BlockCount = BlockCount + 1
    Wend
    ' Write the actual screen blocks to the file
    For StartX = 0 To imageWidth - 511 Step 256
        For y = 0 To imageHeight - 1
            For x = StartX To StartX + 511 Step 2
                DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1
            Next x
        Next y
    Next StartX
    ReDim LastOutArray(P - 1) As _Unsigned _Byte
    c = 0
    For Op = 0 To P - 1
        LastOutArray(Op) = DiskOut(c): c = c + 1
    Next Op
    n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    N$ = Right$("00" + N$, 2)
    TempName$ = FNameNoExt$ + N$ + ".BIN"
    If _FileExists(TempName$) Then Kill TempName$
    If Verbose > 0 Then Print "Writing Disk file "; TempName$
    Open TempName$ For Binary As #2
    Put #2, , LastOutArray()
    Close #2
Else
    ' Do multiple files for use with SDC_LOADM or LOADM
    ' Write the actual screen blocks to the file
    For StartX = 0 To imageWidth - 511 Step 256
        y = 0
        While y <= imageHeight - 1
            P = 0
            StartLocation = &HFFA2
            Blocksize = 4 ' every 64 rows is &H2000 bytes, so a screen of 192 rows will be 3 * &H2000
            DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
            DiskOut(P) = Int(Blocksize / 256): P = P + 1
            DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = Int(StartLocation / 256): P = P + 1
            DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
            DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
            DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
            DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
            StartLocation = &H4000
            Blocksize = &H2000 * 4
            DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
            DiskOut(P) = Int(Blocksize / 256): P = P + 1
            DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = Int(StartLocation / 256): P = P + 1
            DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
            ' Write three blocks to the file (each file is one screen of 256 pixels x 192 pixels, which is 128 bytes x 192 rows)
            c = 0
            While c < &H8000
                For x = StartX To StartX + 511 Step 2
                    DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1
                Next x
                y = y + 1
            Wend
            ' Put 8k block back to normal
            NormalBlock2 = &H3A ' 8k block in CoCo3's memory
            StartLocation = &HFFA2
            Blocksize = 3
            DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
            DiskOut(P) = Int(Blocksize / 256): P = P + 1
            DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = Int(StartLocation / 256): P = P + 1
            DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
            DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
            DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
            ' Postamble
            DiskOut(P) = 255: P = P + 1 ' Preamble value 0 = data, 255 = Last block
            ' Last block is a 255 then two zero's then the execute address
            ' Next two bytes is the block length, then the address in RAM that the data will load at
            DiskOut(P) = 0: P = P + 1
            DiskOut(P) = 0: P = P + 1
            DiskOut(P) = 0: P = P + 1 ' Execute address
            DiskOut(P) = 0: P = P + 1 ' Execute address
            c = 0
            ReDim LastOutArray(P - 1) As _Unsigned _Byte
            For Op = 0 To P - 1
                LastOutArray(Op) = DiskOut(c): c = c + 1
            Next Op
            n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
            N$ = Right$("00" + N$, 2)
            TempName$ = FNameNoExt$ + N$ + ".BIN"
            If _FileExists(TempName$) Then Kill TempName$
            If Verbose > 0 Then Print "Writing Disk file "; TempName$
            Open TempName$ For Binary As #2
            Put #2, , LastOutArray()
            Close #2
            FileNumber = FileNumber + 1
            P = 0
            StartLocation = &HFFA2
            Blocksize = 4 ' every 64 rows is &H2000 bytes, so a screen of 192 rows will be 3 * &H2000
            DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
            DiskOut(P) = Int(Blocksize / 256): P = P + 1
            DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = Int(StartLocation / 256): P = P + 1
            DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
            DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
            DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
            DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
            StartLocation = &H4000
            Blocksize = &H2000 * 4
            DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
            DiskOut(P) = Int(Blocksize / 256): P = P + 1
            DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = Int(StartLocation / 256): P = P + 1
            DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
            ' Write three blocks to the file (each file is one screen of 256 pixels x 192 pixels, which is 128 bytes x 192 rows)
            c = 0
            While c < &H8000
                For x = 0 To 511 Step 2
                    DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1: c = c + 1
                Next x
                y = y + 1
            Wend
            ' Put 8k block back to normal
            NormalBlock2 = &H3A ' 8k block in CoCo3's memory
            StartLocation = &HFFA2
            Blocksize = 4
            DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
            DiskOut(P) = Int(Blocksize / 256): P = P + 1
            DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = Int(StartLocation / 256): P = P + 1
            DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
            DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
            DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
            DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
            DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
            ' Postamble
            DiskOut(P) = 255: P = P + 1 ' Preamble value 0 = data, 255 = Last block
            ' Last block is a 255 then two zero's then the execute address
            ' Next two bytes is the block length, then the address in RAM that the data will load at
            DiskOut(P) = 0: P = P + 1
            DiskOut(P) = 0: P = P + 1
            DiskOut(P) = 0: P = P + 1 ' Execute address
            DiskOut(P) = 0: P = P + 1 ' Execute address
            c = 0
            ReDim LastOutArray(P - 1) As _Unsigned _Byte
            For Op = 0 To P - 1
                LastOutArray(Op) = DiskOut(c): c = c + 1
            Next Op
            n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
            N$ = Right$("00" + N$, 2)
            TempName$ = FNameNoExt$ + N$ + ".BIN"
            If _FileExists(TempName$) Then Kill TempName$
            If Verbose > 0 Then Print "Writing Disk file "; TempName$
            Open TempName$ For Binary As #2
            Put #2, , LastOutArray()
            Close #2
            FileNumber = FileNumber + 1
        Wend
    Next StartX
End If
Return

View5_2560x192:
If imageWidth < 512 Then Print "Image Width is:"; imageWidth; "with playfield #5 width must be 512 or more": GoTo 99
If imageWidth / 256 <> Int(imageWidth / 256) Then Print "Image Width must be a multiple of 256": GoTo 99
If imageHeight <> 192 Then Print "Image Height is:"; imageHeight; "with playfield #5 file must be 192": GoTo 99
If imageHeight > 2560 Then Print "Image Height is:"; imageHeight; "with playfield #5 file needs to be 2560 or less": GoTo 99
P = 0
If BigLoadm = 1 Then
    ' Do one big special SDC_BIGLOADM file
    ' Make a 512 byte Bank table with a value of $FFFF to flag the end
    TotalBlocks = 128
    BlockCount = 0
    DiskOut(P) = &H00: P = P + 1
    DiskOut(P) = &H01: P = P + 1 ' Save file version 1
    BlockCount = BlockCount + 1
    For BlockNumber = 1 To TotalBlocks
        If BlockCount = 61 Then BlockPointer = BlockPointer + 4 ' move to the next 512k video block
        DiskOut(P) = Int(BlockPointer / 256): P = P + 1
        DiskOut(P) = BlockPointer - Int(BlockPointer / 256) * 256: P = P + 1
        BlockCount = BlockCount + 1
        BlockPointer = BlockPointer + 1
    Next BlockNumber
    DiskOut(P) = &HFF: P = P + 1
    DiskOut(P) = &HFF: P = P + 1
    BlockCount = BlockCount + 1
    ' Fill the rest of the table with zeros
    While BlockCount <> 256
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        BlockCount = BlockCount + 1
    Wend
    ' Write the actual screen blocks to the file
    For StartX = 0 To imageWidth - 511 Step 256
        For y = 0 To 191
            For x = StartX To StartX + 511 Step 2
                DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1
            Next x
        Next y
    Next StartX
    ReDim LastOutArray(P - 1) As _Unsigned _Byte
    c = 0
    For Op = 0 To P - 1
        LastOutArray(Op) = DiskOut(c): c = c + 1
    Next Op
    n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    N$ = Right$("00" + N$, 2)
    TempName$ = FNameNoExt$ + N$ + ".BIN"
    If _FileExists(TempName$) Then Kill TempName$
    If Verbose > 0 Then Print "Writing Disk file "; TempName$
    Open TempName$ For Binary As #2
    Put #2, , LastOutArray()
    Close #2
Else
    ' Do multiple files for use with SDC_LOADM or LOADM
    ' Write the actual screen blocks to the file
    For StartX = 0 To imageWidth - 511 Step 256
        P = 0
        StartLocation = &HFFA2
        Blocksize = 3 ' every 96 rows is &H6000 bytes
        If BlockPointer = BlockPointer + 60 Then BlockPointer = BlockPointer + 4
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        StartLocation = &H4000
        Blocksize = &H2000 * 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        ' Write three blocks to the file (each file is one screen of 256 pixels x 192 pixels, which is 128 bytes x 192 rows)
        For y = 0 To 95
            For x = StartX To StartX + 511 Step 2
                DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1
            Next x
        Next y
        StartLocation = &HFFA2
        Blocksize = 3 ' every 96 rows is &H6000 bytes
        If BlockPointer = BlockPointer + 60 Then BlockPointer = BlockPointer + 4
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        DiskOut(P) = BlockPointer: P = P + 1: BlockPointer = BlockPointer + 1
        StartLocation = &H4000
        Blocksize = &H2000 * 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        ' Write three blocks to the file (each file is one screen of 256 pixels x 192 pixels, which is 128 bytes x 192 rows)
        For y = 96 To 191
            For x = StartX To StartX + 511 Step 2
                DiskOut(P) = DitherOut(x, y) * 16 + DitherOut(x + 1, y): P = P + 1
            Next x
        Next y
        ' Put 8k block back to normal
        NormalBlock2 = &H3A ' 8k block in CoCo3's memory
        StartLocation = &HFFA2
        Blocksize = 3
        DiskOut(P) = 0: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(P) = Int(Blocksize / 256): P = P + 1
        DiskOut(P) = Blocksize - Int(Blocksize / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = Int(StartLocation / 256): P = P + 1
        DiskOut(P) = StartLocation - Int(StartLocation / 256) * 256: P = P + 1 'Load address LSB
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        DiskOut(P) = NormalBlock2: P = P + 1: NormalBlock2 = NormalBlock2 + 1
        ' Postamble
        DiskOut(P) = 255: P = P + 1 ' Preamble value 0 = data, 255 = Last block
        ' Last block is a 255 then two zero's then the execute address
        ' Next two bytes is the block length, then the address in RAM that the data will load at
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1
        DiskOut(P) = 0: P = P + 1 ' Execute address
        DiskOut(P) = 0: P = P + 1 ' Execute address
        c = 0
        ReDim LastOutArray(P - 1) As _Unsigned _Byte
        For Op = 0 To P - 1
            LastOutArray(Op) = DiskOut(c): c = c + 1
        Next Op
        n = FileNumber: GoSub NumAsString ' Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        N$ = Right$("00" + N$, 2)
        TempName$ = FNameNoExt$ + N$ + ".BIN"
        If _FileExists(TempName$) Then Kill TempName$
        If Verbose > 0 Then Print "Writing Disk file "; TempName$
        Open TempName$ For Binary As #2
        Put #2, , LastOutArray()
        Close #2
        FileNumber = FileNumber + 1
    Next StartX
End If
Return







FindByteCounts:
' Find repeated 8-bit bytes
'Print "Repeated 8-bit bytes:"
LargestByte = 0
For i = 1 To Len(row$) - 7 Step 8
    If InStr(Mid$(row$, i, 8), "x") = 0 And InStr(Mid$(row$, i, 8), "T") = 0 Then
        byte$ = Mid$(row$, i, 8)
        count = 0
        For j = 1 To Len(row$) - 7 Step 8
            If Mid$(row$, j, 8) = byte$ Then count = count + 1
        Next j
        If count > LargestByte Then LargestByte = count: LargeByte$ = byte$
    End If
Next i
Return

FindWordCounts:
' Find repeated 16-bit words
'Print "Repeated 16-bit words:"
LargestWord = 0
For i = 1 To Len(row$) - 15 Step 8
    If InStr(Mid$(row$, i, 16), "T") = 0 Then
        word$ = Mid$(row$, i, 16)
        count = 0
        For j = 1 To Len(row$) - 15 Step 8
            If Mid$(row$, j, 16) = word$ Then count = count + 1
        Next j
        If count > LargestWord Then LargestWord = count: LargeWord$ = word$
    End If
Next i
Return

FindClosestColor:
bestDist = &H7FFFFFFF ' Start with a large number
bestIndex = -1
' Pre-calculate target luma
For i = 0 To Colours - 1
    Ri = ColoursToUse(i, 0)
    Gi = ColoursToUse(i, 1)
    Bi = ColoursToUse(i, 2)

    ' Standard RGB Euclidean distance (no brightness bias)
    dist = (R - Ri) ^ 2 + (G - Gi) ^ 2 + (B - Bi) ^ 2

    If dist < bestDist Then
        bestDist = dist
        bestIndex = i
    End If
Next i
Return

' Print the output to file #2
DoOutput:
If Left$(Instr2$, 1) = "+" Then Instr2$ = Right$(Instr2$, Len(Instr2$) - 1)
'GoSub DoCycleCount
O$ = Tab$ + Left$(Instr1$ + "        ", 8)
If Len(Instr2$) > 16 Then
    O$ = O$ + Instr2$
Else
    O$ = O$ + Left$(Instr2$ + "                ", 16)
End If
If Com$ <> "" Then O$ = O$ + "    ; " + Com$: Com$ = ""
Print #2, O$ 'Print instructions to output
Instr1$ = "": Instr2$ = "": Com$ = "" ' Clear them for next input
Return

'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
NumAsString:
If n = 0 Then
    N$ = ""
Else
    If n > 0 Then
        'Postive value remove the first space in the string
        N$ = Right$(Str$(n), Len(Str$(n)) - 1)
    Else
        'Negative value we keep the minus sign
        N$ = Str$(n)
    End If
End If
Return

DoNoDither:
For y = 0 To imageHeight - 1
    For x = 0 To imageWidth - 1
        ' Extract RGB values from 32-bit pixelColors(x, y)
        Pixel$ = Right$("00000000" + Hex$(pixelColors(x, y)), 8)
        R = Val("&H" + Mid$(Pixel$, 3, 2))
        G = Val("&H" + Mid$(Pixel$, 5, 2))
        B = Val("&H" + Mid$(Pixel$, 7, 2))

        ' Find the closest color in the palette
        bestIndex = 0
        bestDistance = 999999
        For i = 0 To 15
            V$ = Right$("000000" + Hex$(sortedColors(i)), 6)
            R$ = Left$(V$, 1): G$ = Mid$(V$, 3, 1): B$ = Right$(V$, 1)
            cr = 0
            If R$ = "5" Then cr = &H55
            If R$ = "A" Then cr = &HAA
            If R$ = "F" Then cr = &HFF
            cg = 0
            If G$ = "5" Then cg = &H55
            If G$ = "A" Then cg = &HAA
            If G$ = "F" Then cg = &HFF
            cb = 0
            If B$ = "5" Then cb = &H55
            If B$ = "A" Then cb = &HAA
            If B$ = "F" Then cb = &HFF

            dist = (R - cr) * (R - cr) + (G - cg) * (G - cg) + (B - cb) * (B - cb)
            If dist < bestDistance Then
                bestDistance = dist
                bestIndex = i
            End If
        Next i

        DitherOut(x, y) = bestIndex
    Next x
Next y
Return

' Ordered Dither
DoOrderDither:
For y = 0 To imageHeight - 1
    For x = 0 To imageWidth - 1
        ' Extract RGB values from 32-bit pixelColors(x, y)
        ' Extract RGB values from 32-bit pixelColors(x, y)
        Pixel$ = Right$("00000000" + Hex$(pixelColors(x, y)), 8)
        R = Val("&H" + Mid$(Pixel$, 3, 2))
        G = Val("&H" + Mid$(Pixel$, 5, 2))
        B = Val("&H" + Mid$(Pixel$, 7, 2))

        ' Get Bayer threshold value
        threshold = OrderedArray(x And 7, y And 7)

        ' Apply dithering threshold to each color channel
        R = R + threshold - 2
        G = G + threshold - 2
        B = B + threshold - 2

        ' Clamp values to valid range
        If R < 0 Then R = 0 Else If R > 255 Then R = 255
        If G < 0 Then G = 0 Else If G > 255 Then G = 255
        If B < 0 Then B = 0 Else If B > 255 Then B = 255

        ' Find the closest color in the palette
        bestIndex = 0
        bestDistance = 999999
        For i = 0 To 15
            V$ = Right$("000000" + Hex$(sortedColors(i)), 6)
            R$ = Left$(V$, 1): G$ = Mid$(V$, 3, 1): B$ = Right$(V$, 1)
            cr = 0
            If R$ = "5" Then cr = &H55
            If R$ = "A" Then cr = &HAA
            If R$ = "F" Then cr = &HFF
            cg = 0
            If G$ = "5" Then cg = &H55
            If G$ = "A" Then cg = &HAA
            If G$ = "F" Then cg = &HFF
            cb = 0
            If B$ = "5" Then cb = &H55
            If B$ = "A" Then cb = &HAA
            If B$ = "F" Then cb = &HFF

            dist = (R - cr) * (R - cr) + (G - cg) * (G - cg) + (B - cb) * (B - cb)
            If dist < bestDistance Then
                bestDistance = dist
                bestIndex = i
            End If
        Next i

        ' Store the dithered pixel
        DitherOut(x, y) = bestIndex
    Next x
Next y
Return

' Floyd Dither
' sortedColors(i)
DoFloydDither:
For y = 0 To imageHeight - 1
    For x = 0 To imageWidth - 1
        ' Extract RGB values from 32-bit pixelColors(x, y)
        Pixel$ = Right$("00000000" + Hex$(pixelColors(x, y)), 8)
        R = Val("&H" + Mid$(Pixel$, 3, 2)) + errorR(x, y)
        G = Val("&H" + Mid$(Pixel$, 5, 2)) + errorG(x, y)
        B = Val("&H" + Mid$(Pixel$, 7, 2)) + errorB(x, y)

        ' Clamp values between 0-255
        If R < 0 Then R = 0 Else If R > 255 Then R = 255
        If G < 0 Then G = 0 Else If G > 255 Then G = 255
        If B < 0 Then B = 0 Else If B > 255 Then B = 255

        ' Find the closest color in the palette
        bestIndex = 0
        bestDistance = 999999
        For i = 0 To 15
            V$ = Right$("000000" + Hex$(sortedColors(i)), 6)
            R$ = Left$(V$, 1): G$ = Mid$(V$, 3, 1): B$ = Right$(V$, 1)
            cr = 0
            If R$ = "5" Then cr = &H55
            If R$ = "A" Then cr = &HAA
            If R$ = "F" Then cr = &HFF
            cg = 0
            If G$ = "5" Then cg = &H55
            If G$ = "A" Then cg = &HAA
            If G$ = "F" Then cg = &HFF
            cb = 0
            If B$ = "5" Then cb = &H55
            If B$ = "A" Then cb = &HAA
            If B$ = "F" Then cb = &HFF

            dist = (R - cr) * (R - cr) + (G - cg) * (G - cg) + (B - cb) * (B - cb)
            If dist < bestDistance Then
                bestDistance = dist
                bestIndex = i
            End If
        Next i

        ' Store the dithered pixel
        DitherOut(x, y) = bestIndex

        ' Compute the error
        V$ = Right$("000000" + Hex$(sortedColors(bestIndex)), 6)
        R$ = Left$(V$, 1): G$ = Mid$(V$, 3, 1): B$ = Right$(V$, 1)
        chosenR = 0
        If R$ = "5" Then chosenR = &H55
        If R$ = "A" Then chosenR = &HAA
        If R$ = "F" Then chosenR = &HFF
        chosenG = 0
        If G$ = "5" Then chosenG = &H55
        If G$ = "A" Then chosenG = &HAA
        If G$ = "F" Then chosenG = &HFF
        chosenB = 0
        If B$ = "5" Then chosenB = &H55
        If B$ = "A" Then chosenB = &HAA
        If B$ = "F" Then chosenB = &HFF

        errR = R - chosenR
        errG = G - chosenG
        errB = B - chosenB

        ' Distribute the error
        If x < imageWidth - 1 Then
            errorR(x + 1, y) = errorR(x + 1, y) + errR * 7 / 16
            errorG(x + 1, y) = errorG(x + 1, y) + errG * 7 / 16
            errorB(x + 1, y) = errorB(x + 1, y) + errB * 7 / 16
        End If
        If y < imageHeight - 1 Then
            If x > 0 Then
                errorR(x - 1, y + 1) = errorR(x - 1, y + 1) + errR * 3 / 16
                errorG(x - 1, y + 1) = errorG(x - 1, y + 1) + errG * 3 / 16
                errorB(x - 1, y + 1) = errorB(x - 1, y + 1) + errB * 3 / 16
            End If
            errorR(x, y + 1) = errorR(x, y + 1) + errR * 5 / 16
            errorG(x, y + 1) = errorG(x, y + 1) + errG * 5 / 16
            errorB(x, y + 1) = errorB(x, y + 1) + errB * 5 / 16
            If x < imageWidth - 1 Then
                errorR(x + 1, y + 1) = errorR(x + 1, y + 1) + errR * 1 / 16
                errorG(x + 1, y + 1) = errorG(x + 1, y + 1) + errG * 1 / 16
                errorB(x + 1, y + 1) = errorB(x + 1, y + 1) + errB * 1 / 16
            End If
        End If
    Next x
Next y
Return


' Blue Noise Dithering
' replaces original pixelColors() with dithered versions of pixelColors()
' Load a blue noise texture (must be precomputed as an array)
' Blue Noise Dithering Routine
DoBlueNoiseTexture:
Dim BlueNoise(imageWidth - 1, imageHeight - 1) As _Unsigned Long ' Match image dimensions

' Step 1: Initialize with random values
For y = 0 To imageHeight - 1
    For x = 0 To imageWidth - 1
        BlueNoise(x, y) = Int(Rnd * 256) ' Random value 0-255
    Next
Next

' Step 2: Find actual min/max noise values
minNoise = 255
maxNoise = 0
For y = 0 To imageHeight - 1
    For x = 0 To imageWidth - 1
        If BlueNoise(x, y) < minNoise Then minNoise = BlueNoise(x, y)
        If BlueNoise(x, y) > maxNoise Then maxNoise = BlueNoise(x, y)
    Next
Next

' Step 3: Apply a void-and-cluster refinement
For i = 1 To 100 ' Number of refinement iterations
    x = Int(Rnd * imageWidth)
    y = Int(Rnd * imageHeight)

    dx = (Rnd * 3) - 1
    dy = (Rnd * 3) - 1

    If x + dx >= 0 And x + dx < imageWidth And y + dy >= 0 And y + dy < imageHeight Then
        swapChance = Abs(BlueNoise(x, y) - 128) / 128
        If Rnd < swapChance Then Swap BlueNoise(x, y), BlueNoise(x + dx, y + dy)
    End If
Next i

' Step 4: Apply blue noise dithering
For y = 0 To imageHeight - 1
    For x = 0 To imageWidth - 1
        Pixel$ = Right$("00000000" + Hex$(pixelColors(x, y)), 8)
        R = Val("&H" + Mid$(Pixel$, 3, 2))
        G = Val("&H" + Mid$(Pixel$, 5, 2))
        B = Val("&H" + Mid$(Pixel$, 7, 2))

        ' Normalize noise to -1 to 1 range
        noise = BlueNoise(x, y)
        noise = 2 * ((noise - minNoise) / (maxNoise - minNoise)) - 1

        ' Adjust noise strength dynamically based on brightness
        Brightness = (R + G + B) \ 3
        adjustedNoise = noise * (10.0 + (Brightness / 255) * 10.0)

        ' Apply noise to the most dominant color
        If R > G And R > B Then
            R = R + adjustedNoise
        ElseIf G > R And G > B Then
            G = G + adjustedNoise
        Else
            B = B + adjustedNoise
        End If

        ' Clamp values
        If R < 0 Then R = 0 Else If R > 255 Then R = 255
        If G < 0 Then G = 0 Else If G > 255 Then G = 255
        If B < 0 Then B = 0 Else If B > 255 Then B = 255

        ' Find the closest color in the palette
        bestIndex = 0
        bestDistance = 999999
        For i = 0 To 15
            V$ = Right$("000000" + Hex$(sortedColors(i)), 6)
            R$ = Left$(V$, 1): G$ = Mid$(V$, 3, 1): B$ = Right$(V$, 1)
            cr = 0
            If R$ = "5" Then cr = &H55
            If R$ = "A" Then cr = &HAA
            If R$ = "F" Then cr = &HFF
            cg = 0
            If G$ = "5" Then cg = &H55
            If G$ = "A" Then cg = &HAA
            If G$ = "F" Then cg = &HFF
            cb = 0
            If B$ = "5" Then cb = &H55
            If B$ = "A" Then cb = &HAA
            If B$ = "F" Then cb = &HFF

            dist = (R - cr) * (R - cr) + (G - cg) * (G - cg) + (B - cb) * (B - cb)
            If dist < bestDistance Then
                bestDistance = dist
                bestIndex = i
            End If
        Next i

        DitherOut(x, y) = bestIndex
    Next
Next
Return

' Input string is in CoCo3 RGB format as    "%00100100" '       * 1 - Red"
Function CoCo2RGB$ (CoCo3String As String)
    ' This function takes a string and returns a modified version of it
    Dim Red As String
    Dim Green As String
    Dim Blue As String
    Red = Mid$(CoCo3String, 4, 1) + Mid$(CoCo3String, 7, 1)
    If Red = "00" Then Red = "00"
    If Red = "01" Then Red = "55"
    If Red = "10" Then Red = "AA"
    If Red = "11" Then Red = "FF"
    Green = Mid$(CoCo3String, 5, 1) + Mid$(CoCo3String, 8, 1)
    If Green = "00" Then Green = "00"
    If Green = "01" Then Green = "55"
    If Green = "10" Then Green = "AA"
    If Green = "11" Then Green = "FF"
    Blue = Mid$(CoCo3String, 6, 1) + Mid$(CoCo3String, 9, 1)
    If Blue = "00" Then Blue = "00"
    If Blue = "01" Then Blue = "55"
    If Blue = "10" Then Blue = "AA"
    If Blue = "11" Then Blue = "FF"
    'Print CoCo3String + "," + Red + "," + Green + "," + Blue
    ' Return the modified string
    CoCo2RGB$ = Red + Green + Blue
End Function
Function GetFilenameOnly$ (FUllFileName As String)
    Dim LastBackslashPos As Integer
    LastBackslashPos = 0
    ' Test what this system uses for folder indicators:
    'Windows uses "\"
    'MacOS and Linux uses "/"
    Dim OperatingSystem As String
    OperatingSystem = _OS$

    Select Case OperatingSystem
        Case "WIN"
            Slash$ = "\"
        Case Else
            Slash$ = "/"
    End Select

    ' Loop through the string to find the last backslash
    For i = 1 To Len(FUllFileName)
        If Mid$(FUllFileName, i, 1) = Slash$ Then
            LastBackslashPos = i
        End If
    Next i

    ' Extract the filename part
    If LastBackslashPos > 0 Then
        GetFilenameOnly$ = Mid$(FUllFileName, LastBackslashPos + 1)
    Else
        GetFilenameOnly$ = FUllFileName
    End If
End Function

Data "Black"
Data "Low intensity blue"
Data "Low intensity green"
Data "Low intensity cyan"
Data "Low intensity red"
Data "Low intensity magenta"
Data "Low intensity brown"
Data "Low intensity white"
Data "Medium intensity blue"
Data "Full intensity blue"
Data "Green tint blue"
Data "Cyan tint blue"
Data "Red tint blue"
Data "Magenta tint blue"
Data "Brown tint blue"
Data "Faded blue"
Data "Medium intensity green"
Data "Blue tint green"
Data "Full intensity green"
Data "Cyan tint green"
Data "Red tint green"
Data "Magenta tint green"
Data "Brown tint green"
Data "Faded green"
Data "Medium intensity cyan"
Data "Blue tint cyan"
Data "Green tint cyan"
Data "Full intensity cyan"
Data "Red tint cyan"
Data "Magenta tint cyan"
Data "Brown tint cyan"
Data "Faded cyan"
Data "Medium intensity red"
Data "Blue tint red"
Data "Light Orange"
Data "Cyan tint red"
Data "Full intensity red"
Data "Magenta tint red"
Data "Brown tint red"
Data "Faded red"
Data "Medium intensity magenta"
Data "Blue tint magenta"
Data "Green tint magenta"
Data "Cyan tint magenta"
Data "Red tint magenta"
Data "Full intensity magenta"
Data "Brown tint magenta"
Data "Faded magenta"
Data "Medium intensity yellow"
Data "Blue tint yellow"
Data "Green tint yellow"
Data "Cyan tint yellow"
Data "Red tint yellow"
Data "Magenta tint yellow"
Data "Full intensity yellow"
Data "Faded yellow"
Data "Medium intensity white"
Data "Light blue"
Data "Light green"
Data "Light cyan"
Data "Light red"
Data "Light magenta"
Data "Light yellow"
Data "White"

