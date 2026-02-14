' Sprite Compiler & Background Image Renderer

VersionNumber$ = "1.01"
'       - Modified load location of hte NTSC composite file to only use block $C000 while loading using option -c4

' V1.00
'       - Added support for not saving the background and writing the sprite with a solid colour behind it

' V0.08
'       - Added code to handle CoCo3 NTSC composite output modes with 256 colours
'       - Added dither options for the 256 colour modes

' V0.07
'       - Added code to handle CoCo3 sprites with 4 and 16 colours

' V0.06
'       - Added code to handle a palette file called CoCo3_Palette.asm which includes the palette colours from 0 to 15
'       - Can now handle GMODE 18 which is CoCo 1 & 2 Hi-RES mode that will use artifacting sprites
' V0.05
'       - Now supports coco1&2 GMODE screens with 4 Colours
'       - Adding support for CoCo 3 sprites
'       - Adding option -8kx for number of 8k block to use
' V0.04
'       - Fixed a bug with detecting transparency bit on the right side of the sprite
' V0.03
'       - Can now handle PNG with animation frames as input for making animated sprites
' V0.02
'       - initial version, mod from my 6309_Sprite_Compiler, start with handling 2 colour sprites
'         lots of old code can be cleared out, but seems to work for CoCo 1 GMODEs with 2 color graphics screens

$ScreenHide
$Console
_Dest _Console

Dim OriginalValue As Integer
Dim RotatedValue As Integer
Dim NegatedValue As Integer
Dim DecrementedValue As Integer
Dim IncrementedValue As Integer
Dim ComplementedValue As Integer
Dim ShiftedValue As Integer
Dim Blast(10)
Dim RGB As Long

' Bayer 8x8 ordered dither:
Dim OrderedArray(7, 7) As Integer
'Data 0,32,8,40,2,34,10,42
'Data 48,16,56,24,50,18,58,26
'Data 12,44,4,36,14,46,6,38
'Data 60,28,52,20,62,30,54,22
'Data 3,35,11,43,1,33,9,41
'Data 51,19,59,27,49,17,57,25
'Data 15,47,7,39,13,45,5,37
'Data 63,31,55,23,61,29,53,21

' 8x8 ordered dither:
'Data 0,0,8,0,2,0,10,0
'Data 0,0,0,0,0,0,0,0
'Data 12,0,4,0,14,0,6,0
'Data 0,0,0,0,0,0,0,0
'Data 3,0,11,0,1,0,9,0
'Data 0,0,0,0,0,0,0,0
'Data 15,0,7,0,13,0,5,0
'Data 0,0,0,0,0,0,0,0

' 4x4 ordered dither only the 4x4 values matter, the rest will be ignored
'Data 0,0,2,0,2,0,10,0
'Data 0,0,0,0,0,0,0,0
'Data 3,0,1,0,14,0,6,0
'Data 0,0,0,0,0,0,0,0
'Data 3,0,11,0,1,0,9,0
'Data 0,0,0,0,0,0,0,0
'Data 15,0,7,0,13,0,5,0
'Data 0,0,0,0,0,0,0,0

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
        OrderedArray(x, y) = Int((OrderedArray(x, y) * 255) / 63)
    Next x
Next y

Dim DiskOut(1000000) As _Unsigned _Byte

Dim R As Integer, G As Integer, B As Integer
Dim bestIndex As Integer
Dim bestDist As Long, dist As Long

Dim pal(16) As Long
Dim CoCo3Pal$(16)
Dim Sprite$(150)

Dim ColourList$(63)
For x = 0 To 63
    Read ColourList$(x) ' Get the colour names
Next x

Dim ColoursToUse(255, 2) As Integer ' Stores RGB values

PatternSize = 12
Dim patternFrequency(PatternSize, 255, 255) As Integer ' Frequency array
Dim i As Integer
Dim patternLength As Integer
Dim maxFrequency As Integer, maxPatternLength As Integer
Dim maxPatternRow As Integer, maxPatternStartCol As Integer
Dim Pattern(PatternSize) As _Byte ' Pattern to look for (max 12 nibbles/pixels )

' For Graphics Modes
Dim GMode$(200), GModeName$(200), GModeMaxX$(200), GModeMaxY$(200), GModeStartAddress$(200), GModeScreenSize$(200), GModeColours$(200)
GMode$(0) = "Internal_Alphanumeric" ' Internal alphanumeric 0   X   X   0   0 0 0    32x 16   (5x7 pixel ch)
GMode$(1) = "External_Alphanumeric" ' External alphanumeric 0   X   X   1   0 0 0    32x 16   (8x12 pixel ch)
GMode$(2) = "Semi_graphic_4" '        Semi graphic-4        0   X   X   0   0 0 0    32x 16   ch, 64x32 pixels
GMode$(3) = "Semi_graphic_4Hybrid" '  Semi graphic-8        0   X   X   0   0 1 0    64x 32x9 $800(2048)
GMode$(4) = "Semi_graphic_6" '        Semi graphic-6        0   X   X   1   0 0 0    64x 48   pixels
GMode$(5) = "Semi_graphic_6Hybrid" '  Semi graphic-12       0   X   X   0   1 0 0    64x 48x9 $C00(3072)
GMode$(6) = "Semi_graphic_8" '        Semi graphic-8        0   X   X   0   0 1 0    64x 64x9 $800(2048)
GMode$(7) = "Semi_graphic_12" '       Semi graphic-12       0   X   X   0   1 0 0    64x 96x9 $C00(3072)
GMode$(8) = "Semi_graphic_24" '       Semi graphic-24       0   X   X   0   1 1 0    64x192x9 $1800(6144)
GMode$(9) = "Full_graphic_1_C" '      Full graphic 1-C      1   0   0   0   0 0 1    64x 64x4 $400(1024)
GMode$(10) = "Full_graphic_1_R" '     Full graphic 1-R      1   0   0   1   0 0 1   128x 64x2 $400(1024)
GMode$(11) = "Full_graphic_2_C" '     Full graphic 2-C      1   0   1   0   0 1 0   128x 64x4 $800(2048)
GMode$(12) = "Full_graphic_2_R" '     Full graphic 2-R      1   0   1   1   0 1 1   128x 96x2 $600(1536)
GMode$(13) = "Full_graphic_3_C" '     Full graphic 3-C      1   1   0   0   1 0 0   128x 96x4 $C00(3072)
GMode$(14) = "Full_graphic_3_R" '     Full graphic 3-R      1   1   0   1   1 0 1   128x192x2 $C00(3072)
GMode$(15) = "Full_graphic_6_C" '     Full graphic 6-C      1   1   1   0   1 1 0   128x192x4 $1800(6144)
GMode$(16) = "Full_graphic_6_R" '     Full graphic 6-R      1   1   1   1   1 1 0   256x192x2 $1800(6144)
GMode$(17) = "DMAccess_grpahics" '    Direct memory access  X   X   X   X   1 1 1
GMode$(18) = "Full_graphic_6_R" '     Full graphic 6-R      1   1   1   1   1 1 0   256x192x2 $1800(6144)  Going to use Artifacting

GModeName$(0) = "IA": GModeMaxX$(0) = "31": GModeMaxY$(0) = "15": GModeStartAddress$(0) = "400": GModeScreenSize$(0) = "200": GModeColours$(0) = "9"
GModeName$(1) = "EA": GModeMaxX$(1) = "31": GModeMaxY$(1) = "15": GModeStartAddress$(1) = "400": GModeScreenSize$(1) = "200": GModeColours$(1) = "2"
GModeName$(2) = "SG4": GModeMaxX$(2) = "63": GModeMaxY$(2) = "31": GModeStartAddress$(2) = "400": GModeScreenSize$(2) = "200": GModeColours$(2) = "9"
GModeName$(3) = "SG4H": GModeMaxX$(3) = "63": GModeMaxY$(3) = "31": GModeStartAddress$(3) = "E00": GModeScreenSize$(3) = "800": GModeColours$(3) = "9"
GModeName$(4) = "SG6": GModeMaxX$(4) = "63": GModeMaxY$(4) = "47": GModeStartAddress$(4) = "400": GModeScreenSize$(4) = "200": GModeColours$(4) = "9"
GModeName$(5) = "SG6H": GModeMaxX$(5) = "63": GModeMaxY$(5) = "47": GModeStartAddress$(5) = "E00": GModeScreenSize$(5) = "C00": GModeColours$(5) = "9"
GModeName$(6) = "SG8": GModeMaxX$(6) = "63": GModeMaxY$(6) = "63": GModeStartAddress$(6) = "E00": GModeScreenSize$(6) = "800": GModeColours$(6) = "9"
GModeName$(7) = "SG12": GModeMaxX$(7) = "63": GModeMaxY$(7) = "95": GModeStartAddress$(7) = "E00": GModeScreenSize$(7) = "C00": GModeColours$(7) = "9"
GModeName$(8) = "SG24": GModeMaxX$(8) = "63": GModeMaxY$(8) = "191": GModeStartAddress$(8) = "E00": GModeScreenSize$(8) = "1800": GModeColours$(8) = "9"
GModeName$(9) = "FG1C": GModeMaxX$(9) = "63": GModeMaxY$(9) = "63": GModeStartAddress$(9) = "E00": GModeScreenSize$(9) = "400": GModeColours$(9) = "4"
GModeName$(10) = "FG1R": GModeMaxX$(10) = "127": GModeMaxY$(10) = "63": GModeStartAddress$(10) = "E00": GModeScreenSize$(10) = "400": GModeColours$(10) = "2"
GModeName$(11) = "FG2C": GModeMaxX$(11) = "127": GModeMaxY$(11) = "63": GModeStartAddress$(11) = "E00": GModeScreenSize$(11) = "800": GModeColours$(11) = "4"
GModeName$(12) = "FG2R": GModeMaxX$(12) = "127": GModeMaxY$(12) = "95": GModeStartAddress$(12) = "E00": GModeScreenSize$(12) = "600": GModeColours$(12) = "2"
GModeName$(13) = "FG3C": GModeMaxX$(13) = "127": GModeMaxY$(13) = "95": GModeStartAddress$(13) = "E00": GModeScreenSize$(13) = "C00": GModeColours$(13) = "4"
GModeName$(14) = "FG3R": GModeMaxX$(14) = "127": GModeMaxY$(14) = "191": GModeStartAddress$(14) = "E00": GModeScreenSize$(14) = "C00": GModeColours$(14) = "2"
GModeName$(15) = "FG6C": GModeMaxX$(15) = "127": GModeMaxY$(15) = "191": GModeStartAddress$(15) = "E00": GModeScreenSize$(15) = "1800": GModeColours$(15) = "4"
GModeName$(16) = "FG6R": GModeMaxX$(16) = "255": GModeMaxY$(16) = "191": GModeStartAddress$(16) = "E00": GModeScreenSize$(16) = "1800": GModeColours$(16) = "2"
GModeName$(17) = "DMAGraphic": GModeMaxX$(17) = "255": GModeMaxY$(17) = "191": GModeStartAddress$(17) = "E00": GModeScreenSize$(17) = "1800": GModeColours$(17) = "2"
GModeName$(18) = "FG6R": GModeMaxX$(18) = "255": GModeMaxY$(18) = "191": GModeStartAddress$(18) = "E00": GModeScreenSize$(18) = "1800": GModeColours$(18) = "2"

' CoCo 3 Graphic Modes    CoCo 3 Modes Resolution Memory
GMode$(100) = "Hires_Graphic_100" '   EQU     %00000001    ;  64x192x4,  $0C00 (3200)
GMode$(101) = "Hires_Graphic_101" '   EQU     %00100001    ;  64x200x4,  $0C80 (3200)
GMode$(102) = "Hires_Graphic_102" '   EQU     %01100001    ;  64x225x4,  $0E10 (3600)
GMode$(103) = "Hires_Graphic_103" '   EQU     %00001010    ;  64x192x16,  $1800 (6144)
GMode$(104) = "Hires_Graphic_104" '   EQU     %00101010    ;  64x200x16,  $1900 (6400)
GMode$(105) = "Hires_Graphic_105" '   EQU     %01101010    ;  64x225x16,  $1C20 (7200)
GMode$(106) = "Hires_Graphic_106" '   EQU     %00000101    ;  80x192x4,  $0F00 (3840)
GMode$(107) = "Hires_Graphic_107" '   EQU     %00100101    ;  80x200x4,  $0FA0 (4000)
GMode$(108) = "Hires_Graphic_108" '   EQU     %01100101    ;  80x225x4,  $1194 (4500)
GMode$(109) = "Hires_Graphic_109" '   EQU     %00001110    ;  80x192x16,  $1E00 (7680)
GMode$(110) = "Hires_Graphic_110" '   EQU     %00101110    ;  80x200x16,  $1F40 (8000)
GMode$(111) = "Hires_Graphic_111" '   EQU     %01101110    ;  80x225x16,  $2328 (9000)
GMode$(112) = "Hires_Graphic_112" '   EQU     %00000000    ;  128x192x2,  $0C00 (3072)
GMode$(113) = "Hires_Graphic_113" '   EQU     %00100000    ;  128x200x2,  $0C80 (3200)
GMode$(114) = "Hires_Graphic_114" '   EQU     %01100000    ;  128x225x2,  $0E10 (3600)
GMode$(115) = "Hires_Graphic_115" '   EQU     %00001001    ;  128x192x4,  $1800 (6144)
GMode$(116) = "Hires_Graphic_116" '   EQU     %00101001    ;  128x200x4,  $1900 (6400)
GMode$(117) = "Hires_Graphic_117" '   EQU     %01101001    ;  128x225x4,  $1C20 (7200)
GMode$(118) = "Hires_Graphic_118" '   EQU     %00010010    ;  128x192x16,  $3000 (12288)
GMode$(119) = "Hires_Graphic_119" '   EQU     %00110010    ;  128x200x16,  $3200 (12800)
GMode$(120) = "Hires_Graphic_120" '   EQU     %01110010    ;  128x225x16,  $3840 (14400)
GMode$(121) = "Hires_Graphic_121" '   EQU     %00000100    ;  160x192x2,  $0F00 (3840)
GMode$(122) = "Hires_Graphic_122" '   EQU     %00100100    ;  160x200x2,  $0FA0 (4000)
GMode$(123) = "Hires_Graphic_123" '   EQU     %01100100    ;  160x225x2,  $1194 (4500)
GMode$(124) = "Hires_Graphic_124" '   EQU     %00001101    ;  160x192x4,  $1E00 (7680)
GMode$(125) = "Hires_Graphic_125" '   EQU     %00101101    ;  160x200x4,  $1F40 (8000)
GMode$(126) = "Hires_Graphic_126" '   EQU     %01101101    ;  160x225x4,  $2328 (9000)
GMode$(127) = "Hires_Graphic_127" '   EQU     %00010110    ;  160x192x16,  $3C00 (15360)
GMode$(128) = "Hires_Graphic_128" '   EQU     %00110110    ;  160x200x16,  $3E80 (16000)
GMode$(129) = "Hires_Graphic_129" '   EQU     %01110110    ;  160x225x16,  $4650 (18000)
GMode$(130) = "Hires_Graphic_130" '   EQU     %00001000    ;  256x192x2,  $1800 (6144)
GMode$(131) = "Hires_Graphic_131" '   EQU     %00101000    ;  256x200x2,  $1900 (6400)
GMode$(132) = "Hires_Graphic_132" '   EQU     %01101000    ;  256x225x2,  $1C20 (7200)
GMode$(133) = "Hires_Graphic_133" '   EQU     %00010001    ;  256x192x4,  $3000 (12288)
GMode$(134) = "Hires_Graphic_134" '   EQU     %00110001    ;  256x200x4,  $3200 (12800)
GMode$(135) = "Hires_Graphic_135" '   EQU     %01110001    ;  256x225x4,  $3840 (14400)
GMode$(136) = "Hires_Graphic_136" '   EQU     %00011010    ;  256x192x16,  $6000 (24576)
GMode$(137) = "Hires_Graphic_137" '   EQU     %00111010    ;  256x200x16,  $6400 (25600)
GMode$(138) = "Hires_Graphic_138" '   EQU     %01111010    ;  256x225x16,  $7080 (28800)
GMode$(139) = "Hires_Graphic_139" '   EQU     %00001100    ;  320x192x2,  $1E00 (7680)
GMode$(140) = "Hires_Graphic_140" '   EQU     %00101100    ;  320x200x2,  $1F40 (8000)
GMode$(141) = "Hires_Graphic_141" '   EQU     %01101100    ;  320x225x2,  $2328 (9000)
GMode$(142) = "Hires_Graphic_142" '   EQU     %00010101    ;  320x192x4,  $3C00 (15360)
GMode$(143) = "Hires_Graphic_143" '   EQU     %00110101    ;  320x200x4,  $3E80 (16000)
GMode$(144) = "Hires_Graphic_144" '   EQU     %01110101    ;  320x225x4,  $4650 (18000)
GMode$(145) = "Hires_Graphic_145" '   EQU     %00011110    ;  320x192x16,  $7800 (30720)
GMode$(146) = "Hires_Graphic_146" '   EQU     %00111110    ;  320x200x16,  $7D00 (32000)
GMode$(147) = "Hires_Graphic_147" '   EQU     %01111110    ;  320x225x16,  $8CA0 (36000)
GMode$(148) = "Hires_Graphic_148" '   EQU     %00010000    ;  512x192x2,  $3000 (12288)
GMode$(149) = "Hires_Graphic_149" '   EQU     %00110000    ;  512x200x2,  $3200 (12800)
GMode$(150) = "Hires_Graphic_150" '   EQU     %01110000    ;  512x225x2,  $3840 (14400)
GMode$(151) = "Hires_Graphic_151" '   EQU     %00011001    ;  512x192x4,  $6000 (24576)
GMode$(152) = "Hires_Graphic_152" '   EQU     %00111001    ;  512x200x4,  $6400 (25600)
GMode$(153) = "Hires_Graphic_153" '   EQU     %01111001    ;  512x225x4,  $7080 (28800)
GMode$(154) = "Hires_Graphic_154" '   EQU     %00010100    ;  640x192x2,  $3C00 (15360)
GMode$(155) = "Hires_Graphic_155" '   EQU     %00110100    ;  640x200x2,  $3E80 (16000)
GMode$(156) = "Hires_Graphic_156" '   EQU     %01110100    ;  640x225x2,  $4650 (18000)
GMode$(157) = "Hires_Graphic_157" '   EQU     %00011101    ;  640x192x4,  $7800 (30720)
GMode$(158) = "Hires_Graphic_158" '   EQU     %00111101    ;  640x200x4,  $7D00 (32000)
GMode$(159) = "Hires_Graphic_159" '   EQU     %01111101    ;  640x225x4,  $8CA0 (36000)
GMode$(160) = "Hires_Graphic_160" '   EQU     %00011001    ;  512x192x4,  $6000 (24576)
GMode$(161) = "Hires_Graphic_161" '   EQU     %00111001    ;  512x200x4,  $6400 (25600)
GMode$(162) = "Hires_Graphic_162" '   EQU     %01111001    ;  512x225x4,  $7080 (28800)
GMode$(163) = "Hires_Graphic_163" '   EQU     %00011101    ;  640x192x4,  $7800 (30720)
GMode$(164) = "Hires_Graphic_164" '   EQU     %00111101    ;  640x200x4,  $7D00 (32000)
GMode$(165) = "Hires_Graphic_165" '   EQU     %01111101    ;  640x225x4,  $8CA0 (36000)


GModeName$(100) = "HIG100": GModeMaxX$(100) = "63": GModeMaxY$(100) = "191": GModeStartAddress$(100) = "6000": GModeScreenSize$(100) = "0C00": GModeColours$(100) = "4"
GModeName$(101) = "HIG101": GModeMaxX$(101) = "63": GModeMaxY$(101) = "199": GModeStartAddress$(101) = "6000": GModeScreenSize$(101) = "0C80": GModeColours$(101) = "4"
GModeName$(102) = "HIG102": GModeMaxX$(102) = "63": GModeMaxY$(102) = "224": GModeStartAddress$(102) = "6000": GModeScreenSize$(102) = "0E10": GModeColours$(102) = "4"
GModeName$(103) = "HIG103": GModeMaxX$(103) = "63": GModeMaxY$(103) = "191": GModeStartAddress$(103) = "6000": GModeScreenSize$(103) = "1800": GModeColours$(103) = "16"
GModeName$(104) = "HIG104": GModeMaxX$(104) = "63": GModeMaxY$(104) = "199": GModeStartAddress$(104) = "6000": GModeScreenSize$(104) = "1900": GModeColours$(104) = "16"
GModeName$(105) = "HIG105": GModeMaxX$(105) = "63": GModeMaxY$(105) = "224": GModeStartAddress$(105) = "6000": GModeScreenSize$(105) = "1C20": GModeColours$(105) = "16"
GModeName$(106) = "HIG106": GModeMaxX$(106) = "79": GModeMaxY$(106) = "191": GModeStartAddress$(106) = "6000": GModeScreenSize$(106) = "0F00": GModeColours$(106) = "4"
GModeName$(107) = "HIG107": GModeMaxX$(107) = "79": GModeMaxY$(107) = "199": GModeStartAddress$(107) = "6000": GModeScreenSize$(107) = "0FA0": GModeColours$(107) = "4"
GModeName$(108) = "HIG108": GModeMaxX$(108) = "79": GModeMaxY$(108) = "224": GModeStartAddress$(108) = "6000": GModeScreenSize$(108) = "1194": GModeColours$(108) = "4"
GModeName$(109) = "HIG109": GModeMaxX$(109) = "79": GModeMaxY$(109) = "191": GModeStartAddress$(109) = "6000": GModeScreenSize$(109) = "1E00": GModeColours$(109) = "16"
GModeName$(110) = "HIG110": GModeMaxX$(110) = "79": GModeMaxY$(110) = "199": GModeStartAddress$(110) = "6000": GModeScreenSize$(110) = "1F40": GModeColours$(110) = "16"
GModeName$(111) = "HIG111": GModeMaxX$(111) = "79": GModeMaxY$(111) = "224": GModeStartAddress$(111) = "6000": GModeScreenSize$(111) = "2328": GModeColours$(111) = "16"
GModeName$(112) = "HIG112": GModeMaxX$(112) = "127": GModeMaxY$(112) = "191": GModeStartAddress$(112) = "6000": GModeScreenSize$(112) = "0C00": GModeColours$(112) = "2"
GModeName$(113) = "HIG113": GModeMaxX$(113) = "127": GModeMaxY$(113) = "199": GModeStartAddress$(113) = "6000": GModeScreenSize$(113) = "0C80": GModeColours$(113) = "2"
GModeName$(114) = "HIG114": GModeMaxX$(114) = "127": GModeMaxY$(114) = "224": GModeStartAddress$(114) = "6000": GModeScreenSize$(114) = "0E10": GModeColours$(114) = "2"
GModeName$(115) = "HIG115": GModeMaxX$(115) = "127": GModeMaxY$(115) = "191": GModeStartAddress$(115) = "6000": GModeScreenSize$(115) = "1800": GModeColours$(115) = "4"
GModeName$(116) = "HIG116": GModeMaxX$(116) = "127": GModeMaxY$(116) = "199": GModeStartAddress$(116) = "6000": GModeScreenSize$(116) = "1900": GModeColours$(116) = "4"
GModeName$(117) = "HIG117": GModeMaxX$(117) = "127": GModeMaxY$(117) = "224": GModeStartAddress$(117) = "6000": GModeScreenSize$(117) = "1C20": GModeColours$(117) = "4"
GModeName$(118) = "HIG118": GModeMaxX$(118) = "127": GModeMaxY$(118) = "191": GModeStartAddress$(118) = "6000": GModeScreenSize$(118) = "3000": GModeColours$(118) = "16"
GModeName$(119) = "HIG119": GModeMaxX$(119) = "127": GModeMaxY$(119) = "199": GModeStartAddress$(119) = "6000": GModeScreenSize$(119) = "3200": GModeColours$(119) = "16"
GModeName$(120) = "HIG120": GModeMaxX$(120) = "127": GModeMaxY$(120) = "224": GModeStartAddress$(120) = "6000": GModeScreenSize$(120) = "3840": GModeColours$(120) = "16"
GModeName$(121) = "HIG121": GModeMaxX$(121) = "127": GModeMaxY$(121) = "191": GModeStartAddress$(121) = "6000": GModeScreenSize$(121) = "0C00": GModeColours$(121) = "2"
GModeName$(122) = "HIG122": GModeMaxX$(122) = "127": GModeMaxY$(122) = "199": GModeStartAddress$(122) = "6000": GModeScreenSize$(122) = "0C80": GModeColours$(122) = "2"
GModeName$(123) = "HIG123": GModeMaxX$(123) = "127": GModeMaxY$(123) = "224": GModeStartAddress$(123) = "6000": GModeScreenSize$(123) = "0E10": GModeColours$(123) = "2"
GModeName$(124) = "HIG124": GModeMaxX$(124) = "159": GModeMaxY$(124) = "191": GModeStartAddress$(124) = "6000": GModeScreenSize$(124) = "1E00": GModeColours$(124) = "4"
GModeName$(125) = "HIG125": GModeMaxX$(125) = "159": GModeMaxY$(125) = "199": GModeStartAddress$(125) = "6000": GModeScreenSize$(125) = "1F40": GModeColours$(125) = "4"
GModeName$(126) = "HIG126": GModeMaxX$(126) = "159": GModeMaxY$(126) = "224": GModeStartAddress$(126) = "6000": GModeScreenSize$(126) = "2328": GModeColours$(126) = "4"
GModeName$(127) = "HIG127": GModeMaxX$(127) = "159": GModeMaxY$(127) = "191": GModeStartAddress$(127) = "6000": GModeScreenSize$(127) = "3C00": GModeColours$(127) = "16"
GModeName$(128) = "HIG128": GModeMaxX$(128) = "159": GModeMaxY$(128) = "199": GModeStartAddress$(128) = "6000": GModeScreenSize$(128) = "3E80": GModeColours$(128) = "16"
GModeName$(129) = "HIG129": GModeMaxX$(129) = "159": GModeMaxY$(129) = "224": GModeStartAddress$(129) = "6000": GModeScreenSize$(129) = "4650": GModeColours$(129) = "16"
GModeName$(130) = "HIG130": GModeMaxX$(130) = "255": GModeMaxY$(130) = "191": GModeStartAddress$(130) = "6000": GModeScreenSize$(130) = "1800": GModeColours$(130) = "2"
GModeName$(131) = "HIG131": GModeMaxX$(131) = "255": GModeMaxY$(131) = "199": GModeStartAddress$(131) = "6000": GModeScreenSize$(131) = "1900": GModeColours$(131) = "2"
GModeName$(132) = "HIG132": GModeMaxX$(132) = "255": GModeMaxY$(132) = "224": GModeStartAddress$(132) = "6000": GModeScreenSize$(132) = "1C20": GModeColours$(132) = "2"
GModeName$(133) = "HIG133": GModeMaxX$(133) = "255": GModeMaxY$(133) = "191": GModeStartAddress$(133) = "6000": GModeScreenSize$(133) = "3000": GModeColours$(133) = "4"
GModeName$(134) = "HIG134": GModeMaxX$(134) = "255": GModeMaxY$(134) = "199": GModeStartAddress$(134) = "6000": GModeScreenSize$(134) = "3200": GModeColours$(134) = "4"
GModeName$(135) = "HIG135": GModeMaxX$(135) = "255": GModeMaxY$(135) = "224": GModeStartAddress$(135) = "6000": GModeScreenSize$(135) = "3840": GModeColours$(135) = "4"
GModeName$(136) = "HIG136": GModeMaxX$(136) = "255": GModeMaxY$(136) = "191": GModeStartAddress$(136) = "6000": GModeScreenSize$(136) = "6000": GModeColours$(136) = "16"
GModeName$(137) = "HIG137": GModeMaxX$(137) = "255": GModeMaxY$(137) = "199": GModeStartAddress$(137) = "6000": GModeScreenSize$(137) = "6400": GModeColours$(137) = "16"
GModeName$(138) = "HIG138": GModeMaxX$(138) = "255": GModeMaxY$(138) = "224": GModeStartAddress$(138) = "6000": GModeScreenSize$(138) = "7080": GModeColours$(138) = "16"
GModeName$(139) = "HIG139": GModeMaxX$(139) = "319": GModeMaxY$(139) = "191": GModeStartAddress$(139) = "6000": GModeScreenSize$(139) = "1E00": GModeColours$(139) = "2"
GModeName$(140) = "HIG140": GModeMaxX$(140) = "319": GModeMaxY$(140) = "199": GModeStartAddress$(140) = "6000": GModeScreenSize$(140) = "1F40": GModeColours$(140) = "2"
GModeName$(141) = "HIG141": GModeMaxX$(141) = "319": GModeMaxY$(141) = "224": GModeStartAddress$(141) = "6000": GModeScreenSize$(141) = "2328": GModeColours$(141) = "2"
GModeName$(142) = "HIG142": GModeMaxX$(142) = "319": GModeMaxY$(142) = "191": GModeStartAddress$(142) = "6000": GModeScreenSize$(142) = "3C00": GModeColours$(142) = "4"
GModeName$(143) = "HIG143": GModeMaxX$(143) = "319": GModeMaxY$(143) = "199": GModeStartAddress$(143) = "6000": GModeScreenSize$(143) = "3E80": GModeColours$(143) = "4"
GModeName$(144) = "HIG144": GModeMaxX$(144) = "319": GModeMaxY$(144) = "224": GModeStartAddress$(144) = "6000": GModeScreenSize$(144) = "4650": GModeColours$(144) = "4"
GModeName$(145) = "HIG145": GModeMaxX$(145) = "319": GModeMaxY$(145) = "191": GModeStartAddress$(145) = "6000": GModeScreenSize$(145) = "7800": GModeColours$(145) = "16"
GModeName$(146) = "HIG146": GModeMaxX$(146) = "319": GModeMaxY$(146) = "199": GModeStartAddress$(146) = "6000": GModeScreenSize$(146) = "7D00": GModeColours$(146) = "16"
GModeName$(147) = "HIG147": GModeMaxX$(147) = "319": GModeMaxY$(147) = "224": GModeStartAddress$(147) = "6000": GModeScreenSize$(147) = "8CA0": GModeColours$(147) = "16"
GModeName$(148) = "HIG148": GModeMaxX$(148) = "511": GModeMaxY$(148) = "191": GModeStartAddress$(148) = "6000": GModeScreenSize$(148) = "3000": GModeColours$(148) = "2"
GModeName$(149) = "HIG149": GModeMaxX$(149) = "511": GModeMaxY$(149) = "199": GModeStartAddress$(149) = "6000": GModeScreenSize$(149) = "3200": GModeColours$(149) = "2"
GModeName$(150) = "HIG150": GModeMaxX$(150) = "511": GModeMaxY$(150) = "224": GModeStartAddress$(150) = "6000": GModeScreenSize$(150) = "3840": GModeColours$(150) = "2"
GModeName$(151) = "HIG151": GModeMaxX$(151) = "511": GModeMaxY$(151) = "191": GModeStartAddress$(151) = "6000": GModeScreenSize$(151) = "6000": GModeColours$(151) = "4"
GModeName$(152) = "HIG152": GModeMaxX$(152) = "511": GModeMaxY$(152) = "199": GModeStartAddress$(152) = "6000": GModeScreenSize$(152) = "6400": GModeColours$(152) = "4"
GModeName$(153) = "HIG153": GModeMaxX$(153) = "511": GModeMaxY$(153) = "224": GModeStartAddress$(153) = "6000": GModeScreenSize$(153) = "7080": GModeColours$(153) = "4"
GModeName$(154) = "HIG154": GModeMaxX$(154) = "639": GModeMaxY$(154) = "191": GModeStartAddress$(154) = "6000": GModeScreenSize$(154) = "3C00": GModeColours$(154) = "2"
GModeName$(155) = "HIG155": GModeMaxX$(155) = "639": GModeMaxY$(155) = "199": GModeStartAddress$(155) = "6000": GModeScreenSize$(155) = "3E80": GModeColours$(155) = "2"
GModeName$(156) = "HIG156": GModeMaxX$(156) = "639": GModeMaxY$(156) = "224": GModeStartAddress$(156) = "6000": GModeScreenSize$(156) = "4650": GModeColours$(156) = "2"
GModeName$(157) = "HIG157": GModeMaxX$(157) = "639": GModeMaxY$(157) = "191": GModeStartAddress$(157) = "6000": GModeScreenSize$(157) = "7800": GModeColours$(157) = "4"
GModeName$(158) = "HIG158": GModeMaxX$(158) = "639": GModeMaxY$(158) = "199": GModeStartAddress$(158) = "6000": GModeScreenSize$(158) = "7D00": GModeColours$(158) = "4"
GModeName$(159) = "HIG159": GModeMaxX$(159) = "639": GModeMaxY$(159) = "224": GModeStartAddress$(159) = "6000": GModeScreenSize$(159) = "8CA0": GModeColours$(159) = "4"
GModeName$(160) = "HIG160": GModeMaxX$(160) = "127": GModeMaxY$(160) = "191": GModeStartAddress$(160) = "6000": GModeScreenSize$(160) = "6000": GModeColours$(160) = "256"
GModeName$(161) = "HIG161": GModeMaxX$(161) = "127": GModeMaxY$(161) = "199": GModeStartAddress$(161) = "6000": GModeScreenSize$(161) = "6400": GModeColours$(161) = "256"
GModeName$(162) = "HIG162": GModeMaxX$(162) = "127": GModeMaxY$(162) = "224": GModeStartAddress$(162) = "6000": GModeScreenSize$(162) = "7080": GModeColours$(162) = "256"
GModeName$(163) = "HIG163": GModeMaxX$(163) = "159": GModeMaxY$(163) = "191": GModeStartAddress$(163) = "6000": GModeScreenSize$(163) = "7800": GModeColours$(163) = "256"
GModeName$(164) = "HIG164": GModeMaxX$(164) = "159": GModeMaxY$(164) = "199": GModeStartAddress$(164) = "6000": GModeScreenSize$(164) = "7D00": GModeColours$(164) = "256"
GModeName$(165) = "HIG165": GModeMaxX$(165) = "159": GModeMaxY$(165) = "224": GModeStartAddress$(165) = "6000": GModeScreenSize$(165) = "8CA0": GModeColours$(165) = "256"

Dim array(50000000) As _Byte
Tab$ = String$(8, " ") ' tab space in output
FI = 0
count = _CommandCount
If count > 0 Then GoTo 100
99 Print: Print "PNG to CoCo Sprite Compiler & Background Image Renderer v"; VersionNumber$; " by Glen Hewlett"
Print
Print "Usage: PNGtoCCSB -gx [-sx] [-a[w]xx] [-bx] [-pxxx] [-scroll] [-cx] [-dx] [-x] [-blkxx] [-makepal] [-usepal] [-v#] InName.png"
Print "Where:"
Print "InName.png is a 32 bit RGBA (includes transparency) png file"
Print "-gx      - Where x is the GMODE # the basic program will use to draw the created sprite/background image"
Print "-axx     - This PNG image contains xx animation pictures"
Print "           This will create xx anim sprites from this single image"
Print "           The image should contain the animation frames all in a row (max 32 images per PNG file)"
Print "-awxx    - Similar to -axx but used with gmode 18 this PNG image contains xx animation pictures for a walk cycle,"
Print "           create xx anim sprites from this single image"
Print "           The image should contain the animation frames all in a row (max 32 frames per PNG file)"
Print "-ox      - Offset pixel for where the left edge of the sprite(s) will be generated from"
Print
Print "-bx        This option handles the way the sprite handles the graphics behind the sprite."
Print "-b0      - No backup or restore of the data behind the sprite will be done, this is the fastest but it makes a destructive sprite"
Print "-b1      - (default) Add code that will restore the background behind the sprite"
Print "-b2      - Always write a byte pattern behind the sprite, this is faster than restoring using option -b1"
Print "           You must set the background pattern with the -pxxx option"
Print "-pxxx    - Where xxx is a number from 0 to 255 which represents the byte pattern used behind a sprite using -b2 option"
Print
Print "-cx      - Convtert a Colour PNG file into a background image file for the CoCo"
Print "           It will match the colours as well as it can to the GMODE value given"
Print "-c1        1 = Converts the .PNG file into a LOADMable .BIN file with an offset of 0"
Print "-c2        2 = Converts the .PNG file into a .RAW binary data file"
Print "-c3        3 = Converts the .PNG file into a .ASM assembly file with FCB statements"
Print
Print "CoCo 2 specific options:"
Print "-sx      - Where x is either a 0 or a 1, to match the SCREEN 1,x colour format for a CoCo 1 or 2 screen mode (default is 0)"
Print
Print "CoCo 3 specific options:"
Print "-scroll  - Will generate a sprite to be used with a horizontally scrolling background"
Print "           *** Do not use this option if your background only scrolls vertically or doesn't scroll at all ***"
Print "-makepal - During the sprite conversion it will also create a palette file called CoCo3_Palette.asm for use with other"
Print "           images and CoCo 3 programs"
Print
Print "CoCo 3 NTSC Composite 256 colour options:"
Print "-c4      - Convert a PNG file to the special NTSC composite 256 colour format image"
Print "           The image will be a LOADMable file that will start at value of -blkxx or default of Mem block 0 on the CoCo3"
Print "-c5      - Convert a PNG file to the special NTSC composite 256 colour format image saved as a .RAW binary data file"
Print "-c6      - Convert a PNG file to the special NTSC composite 256 colour format image saved as a .ASM assembly file with FCB statements"
Print "-blkxx   - First block in memory for the screen to be loaded, only needed when -c4 option is used"
Print "-dx      - Only works with the -c4, -c5 & -c6 options, selects Dither method to use for the 256 colour image"
Print "           Where x is:"
Print "           0 = No Dithering"
Print "           1 = Floyd-Steinberg Dithering (Default)"
Print "           2 = Blue Noise Mask Dithering"
Print "           3 = Ordered Dithering"
Print "-xx      - NTSC Composite colour values"
Print "           0 = Use xroars calculated values (default)"
Print "           1 = Use NTSC monitor scanned Colour values"
Print
Print "-v#      - Set verbose level while generating compiled sprite (where # is 0 to 3)"
Print
System
100 nt = 0: newp = 0: endp = 0: t = 0: o1 = 0: A = 0: TFM = 0
Verbose = 0
Pattern = -1
SaveRestoreBackground = 1
Join = 0
Delete = 0
Gmode = -1
ScreenOption = 0
AnimFrames = 1
AnimWalk = 0
Artifact = 0
ConvertBackground = 0
MakePal = 0
BlkStart = 0
DitherType = 1 ' Default Floyd-Steinburg dither
Which256Colours = 0
ScrollMode = 0
Offset = 0
For check = 1 To count
    N$ = Command$(check)
    If LCase$(Left$(N$, 7)) = "-scroll" Then ScrollMode = 1: GoTo 120
    If LCase$(Left$(N$, 2)) = "-o" Then Offset = Val(Right$(N$, Len(N$) - 2)): GoTo 120
    If LCase$(Left$(N$, 2)) = "-x" Then Which256Colours = Val(Right$(N$, Len(N$) - 2)): GoTo 120
    If LCase$(Left$(N$, 8)) = "-makepal" Then MakePal = 1: GoTo 120
    If LCase$(Left$(N$, 4)) = "-blk" Then BlkStart = Val(Right$(N$, Len(N$) - 4)): GoTo 120
    If LCase$(Left$(N$, 2)) = "-g" Then Gmode = Val(Right$(N$, Len(N$) - 2)): GoTo 120
    If LCase$(Left$(N$, 2)) = "-d" Then DitherType = Val(Right$(N$, Len(N$) - 2)): GoTo 120
    If LCase$(Left$(N$, 2)) = "-s" Then ScreenOption = Val(Right$(N$, 1)): GoTo 120
    If LCase$(Left$(N$, 3)) = "-aw" Then
        Print "Found -aw"
        AnimFrames = Val(Right$(N$, Len(N$) - 3))
        If Animframe > 32 Then
            Print "ERROR: can only handle a sprite with a maximum of 32 frames": GoTo 99
        End If
        AnimWalk = 1
        GoTo 120
    End If
    If LCase$(Left$(N$, 2)) = "-a" Then
        AnimFrames = Val(Right$(N$, Len(N$) - 2))
        If Animframe > 32 Then
            Print "ERROR: can only handle a sprite with a maximum of 32 frames": GoTo 99
        End If
        GoTo 120
    End If
    '    If LCase$(Left$(N$, 2)) = "-n" Then CodeName$ = Right$(N$, Len(N$) - 2): GoTo 120
    If LCase$(Left$(N$, 2)) = "-b" Then SaveRestoreBackground = Val(Right$(N$, 1)): GoTo 120
    If LCase$(Left$(N$, 2)) = "-c" Then ConvertBackground = Val(Right$(N$, 1)): GoTo 120
    If LCase$(Left$(N$, 2)) = "-p" Then Pattern = Val(Right$(N$, Len(N$) - 2)): GoTo 120
    If LCase$(Left$(N$, 2)) = "-v" Then Verbose = Val(Right$(N$, 1)): GoTo 120
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
For c = 0 To Which256Colours
    ' Keep loading in colour values until we reach the one the user wants
    For x = 0 To 255
        Read ColoursToUse(x, 0) ' Get the Red value
        Read ColoursToUse(x, 1) ' Get the Green value
        Read ColoursToUse(x, 2) ' Get the Blue value
    Next x
Next c

If SaveRestoreBackground > 2 Then SaveRestoreBackground = 2
If SaveRestoreBackground = 2 Then
    If Pattern = -1 Then Print "ERROR: Must use -pxxx with option -b2 to set the byte pattern to fill when restoring the sprite": GoTo 99
End If
If Gmode = -1 Then Print "ERROR: Must use -gx to provide a Gmode # to be used in the compiled BASIC program": GoTo 99
If Gmode > 18 And Gmode < 100 Then Print "ERROR: Bad Gmode # given": GoTo 99
If Gmode > 165 Then Print "ERROR: Bad Gmode # given": GoTo 99
If Gmode > 99 Then CoCo3 = 1

Colours = Val(GModeColours$(Gmode))

If Colours = 2 Then ShiftCount = 7: ShiftBits = 1: ColoursPerByte = 8
If Colours = 4 Then ShiftCount = 3: ShiftBits = 2: ColoursPerByte = 4
If Colours = 16 Then ShiftCount = 1: ShiftBits = 4: ColoursPerByte = 2

If Gmode = 18 Then
    ' Special CoCo1 & 2 mode that specifies the user will be using hi-res with artifacting for the sprites
    ' this will be more like a 4 colour mode, except we won't need to find matching colours, just use the pixels as they are
    Artifact = 1
    ' treat it like a 4 colour sprite
    Colours = 4
    ShiftCount = 3: ShiftBits = 2: ColoursPerByte = 4
End If

If Verbose > 0 Then
    If Verbose > 3 Then Verbose = 3
    If Verbose < 0 Then Verbose = 0
    Print "Verbose level set to:"; Verbose
End If
FileName$ = GetFilenameOnly$(FName$) ' convert full path of filename to just the filename
FName$ = FileName$
If Right$(UCase$(FileName$), 3) <> "PNG" Then Print "Input file must be a 32 bit .PNG file that includes transparency": System
If CodeName$ = "" Then
    CodeName$ = Left$(FileName$, Len(FileName$) - 4)
End If
FNameNoExt$ = CodeName$

' Do Even sprite, then shift the nibbles right one nibble to create and do an odd version of the sprite
' Then create a .BIN bitmap file that can be used for collision detection

' Set up the graphics screen
Screen _NewImage(8000, 8000, 32)

' Load the image
myImage = _LoadImage(FName$, 32)

' Get the width and height of the image
imageWidth = _Width(myImage)
orig_imageWidth = imageWidth
imageWidth = imageWidth - Offset
tempW = imageWidth
imageHeight = _Height(myImage)

' Set the array size
Select Case Colours
    Case Is < 4
        Dim pixelColors(imageWidth - 1, imageHeight - 1) As Long
    Case 4
        Dim pixelColors(imageWidth * 2 - 1, imageHeight - 1) As Long
    Case 16
        Dim pixelColors(imageWidth * 4 - 1, imageHeight - 1) As Long
    Case 256
        Dim pixelColors(imageWidth - 1, imageHeight - 1) As Long
End Select

Dim AveragePixelValR As Long
Dim AveragePixelValG As Long
Dim AveragePixelValB As Long

' Display the image on-screen
_PutImage (0, 0), myImage ' Adjust as needed to ensure it's fully on-screen
'If ConvertBackground > 3 And Gmode > 159 Then
If ConvertBackground > 0 Then
    ' scale the image if we need to
    ScaleWidth = imageWidth / (Val(GModeMaxX$(Gmode)) + 1)
    ScaleHeight = imageHeight / (Val(GModeMaxY$(Gmode)) + 1)
    SY = 0
    For y = 0 To Val(GModeMaxY$(Gmode))
        SX = 0
        For x = 0 To Val(GModeMaxX$(Gmode))
            AveragePixelValR = 0
            AveragePixelValG = 0
            AveragePixelValB = 0
            For py = Int(SY) To Int(SY + Int(ScaleHeight) - 1)
                For px = Int(SX) To Int(SX + Int(ScaleWidth) - 1)
                    Pixel$ = Right$("00000000" + Hex$(Point(px, py)), 8)
                    AveragePixelValR = AveragePixelValR + Val("&H" + Mid$(Pixel$, 3, 2))
                    AveragePixelValG = AveragePixelValG + Val("&H" + Mid$(Pixel$, 5, 2))
                    AveragePixelValB = AveragePixelValB + Val("&H" + Mid$(Pixel$, 7, 2))
                Next px
            Next py
            AveragePixelValR = AveragePixelValR / (Int(ScaleHeight) * Int(ScaleWidth))
            AveragePixelValG = AveragePixelValG / (Int(ScaleHeight) * Int(ScaleWidth))
            AveragePixelValB = AveragePixelValB / (Int(ScaleHeight) * Int(ScaleWidth))
            pixelColors(x, y) = (AveragePixelValR + 65280) * 65536 + AveragePixelValG * 256 + AveragePixelValB
            SX = SX + ScaleWidth
        Next x
        SY = SY + ScaleHeight
    Next y
    imageWidth = Val(GModeMaxX$(Gmode)) + 1
    imageHeight = Val(GModeMaxY$(Gmode)) + 1
Else
    ' Read pixel colors from the image on the screen
    For y = 0 To imageHeight - 1
        For x = 0 To imageWidth - 1
            pixelColors(x, y) = Point(x + Offset, y) ' Long values 32 bit colour
            ' Format of the long values in hex is AARRGGBB where AA is the Alpha value, 00 is tranparent, FF is full intensity
            '                                              RR,GG,BB are 8 bit values of the colours Red,Green,Blue
        Next x
    Next y
End If
' Free the memory for the image
_FreeImage myImage
_Dest _Console
' Print messages
'If ConvertBackground > 3 And Gmode > 159 Then
If ConvertBackground > 0 Then
    If imageWidth < Val(GModeMaxX$(Gmode)) + 1 Then
        Print "Input image must be at least "; Val(GModeMaxX$(Gmode)) + 1; " pixels wide": System
    End If
    If imageHeight < Val(GModeMaxY$(Gmode)) + 1 Then
        Print "Input image must be at least "; Val(GModeMaxY$(Gmode)) + 1; " pixels tall": System
    End If
End If

' Optionally Display some pixel info (use a limited range to avoid flooding)
If Verbose > 2 Then
    For y = 0 To imageHeight - 1
        For x = 0 To imageWidth - 1
            Print Right$("00000000" + Hex$(pixelColors(x, y)), 8); ",";
        Next x
        Print
    Next y
End If

Dim PixVal As Long
Dim Temp As Single

If ConvertBackground > 3 Then GoTo Make256ColourImage ' Convert a PNG to CoCo 3, NTSC Composite 256 colours

Select Case Colours
    Case Is < 4
        ' Make sure image is a multiple of 8
        Temp = Int(imageWidth / 8)
        If Temp = imageWidth / 8 Then
            SpWidth = imageWidth
        Else
            SpWidth = (Int(imageWidth / 8) + 1) * 8
        End If
    Case 4
        ' make sure sprite width is a multiple of 4
        Temp = Int(imageWidth / 4)
        If Temp = imageWidth / 4 Then
            SpWidth = imageWidth
        Else
            SpWidth = (Int(imageWidth / 4) + 1) * 4
        End If
    Case 16
        ' make sure sprite width is a multiple of 2
        Temp = Int(imageWidth / 2)
        If Temp = imageWidth / 2 Then
            SpWidth = imageWidth
        Else
            SpWidth = (Int(imageWidth / 2) + 1) * 2
        End If
End Select

Dim SpriteOriginal$(SpWidth * 4 + 8, imageHeight)
Dim AnimSprite$(SpWidth * 4 + 8, imageHeight, AnimFrames)

' If we are using a CoCo 3 GMODE# then we need to deal with palette info:
' MakePal = 0
' UsePal = 0
If CoCo3 = 1 Then
    CoCo3_Palette$ = "CoCo3_Palette.asm"
    If MakePal = 0 Then GoTo LoadCC3Palette ' Go load the and use palette (skip making one)
    ' Create a CoCo3_Palette.asm file from the colours used in this image
    Print "Working on getting the best colours to use for this sprite on a CoCo 3..."

    Dim colorCount As _MEM
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
            If (R And 192) = 0 Then R = 0: GoTo HandleGreen
            If (R And 192) = 64 Then R = &H55: GoTo HandleGreen
            If (R And 192) = 128 Then R = &HAA: GoTo HandleGreen
            R = &HFF
            HandleGreen:
            G = Val("&H" + Mid$(Pixel$, 5, 2))
            If (G And 192) = 0 Then G = 0: GoTo HandleBlue
            If (G And 192) = 64 Then G = &H55: GoTo HandleBlue
            If (G And 192) = 128 Then G = &HAA: GoTo HandleBlue
            G = &HFF
            HandleBlue:
            B = Val("&H" + Mid$(Pixel$, 7, 2))
            If (B And 192) = 0 Then B = 0: GoTo Handled
            If (B And 192) = 64 Then B = &H55: GoTo Handled
            If (B And 192) = 128 Then B = &HAA: GoTo Handled
            B = &HFF
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
    Print #1, "; Palette file generated by PNGtoCCSprite Version "; VersionNumber$
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
    'Print "Found "; CoCo3_Palette$; ", will use this Palette info when generating the compiled sprite"
    Open CoCo3_Palette$ For Input As #1
    x = 0
    While x < Colours
        Line Input #1, I$
        If InStr(I$, " FCB ") Then
            'Found a line to process
            p = InStr(I$, "%")
            CoCo3Pal$(x) = Mid$(I$, p, 9)
            'Handle CoCo 3 Colour conversion
            CoCo3String$ = CoCo3Pal$(x)
            Red$ = Mid$(CoCo3String$, 4, 1) + Mid$(CoCo3String$, 7, 1)
            If Red$ = "00" Then Red$ = "00"
            If Red$ = "01" Then Red$ = "55"
            If Red$ = "10" Then Red$ = "AA"
            If Red$ = "11" Then Red$ = "FF"
            Green$ = Mid$(CoCo3String$, 5, 1) + Mid$(CoCo3String$, 8, 1)
            If Green$ = "00" Then Green$ = "00"
            If Green$ = "01" Then Green$ = "55"
            If Green$ = "10" Then Green$ = "AA"
            If Green$ = "11" Then Green$ = "FF"
            Blue$ = Mid$(CoCo3String$, 6, 1) + Mid$(CoCo3String$, 9, 1)
            If Blue$ = "00" Then Blue$ = "00"
            If Blue$ = "01" Then Blue$ = "55"
            If Blue$ = "10" Then Blue$ = "AA"
            If Blue$ = "11" Then Blue$ = "FF"
            ' Save it as a 8 bit colour values for Red,Green & Blue
            ColoursToUse(x, 0) = Val("&H" + Red$)
            ColoursToUse(x, 1) = Val("&H" + Green$)
            ColoursToUse(x, 2) = Val("&H" + Blue$)
            x = x + 1
        End If
    Wend
    Close #1
    ' Palette is setup
    If Colours = 2 Then
        ' Get the best 2 colours that can be used on the CoCo 3 and use them for this sprite
        For y = 0 To imageHeight - 1
            For x = 0 To imageWidth - 1
                Pixel$ = Right$("00000000" + Hex$(pixelColors(x / 2, y)), 8)
                R = Val("&H" + Mid$(Pixel$, 3, 2))
                G = Val("&H" + Mid$(Pixel$, 5, 2))
                B = Val("&H" + Mid$(Pixel$, 7, 2))
                ' Call subroutine to find the closest color return with closest match in variable bestIndex
                GoSub FindClosestColor
                ' Print "Closest Palette #"; bestIndex
                n = bestIndex: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                If N$ = "" Then Bit$ = "0"
                If N$ = "1" Then Bit$ = "1"
                If Val("&H" + Left$(Pixel$, 2)) < 127 Then Bit$ = "T"
                SpriteOriginal$(x, y) = Bit$
            Next x
        Next y
        If SpWidth > imageWidth Then
            For y = 0 To imageHeight - 1
                For x = imageWidth To SpWidth
                    SpriteOriginal$(x, y) = "T"
                Next x
            Next y
        End If
    End If
    If Colours = 4 Then
        ' Get the best 4 colours that can be used on the CoCo 3 and use them for this sprite
        SpWidth = SpWidth * 2 ' Two bits per pixel
        ' Format of the long values in hex is AARRGGBB where AA is the Alpha value, 00 is tranparent, FF is full intensity
        '                                              RR,GG,BB are 8 bit values of the colours Red,Green,Blue
        For y = 0 To imageHeight - 1
            For x = 0 To imageWidth * 2 - 1 Step 2
                Pixel$ = Right$("00000000" + Hex$(pixelColors(x / 2, y)), 8)
                R = Val("&H" + Mid$(Pixel$, 3, 2))
                G = Val("&H" + Mid$(Pixel$, 5, 2))
                B = Val("&H" + Mid$(Pixel$, 7, 2))
                ' Call subroutine to find the closest color return with closest match in variable bestIndex
                GoSub FindClosestColor
                ' Print "Closest Palette #"; bestIndex
                n = bestIndex: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                If N$ = "" Then N$ = "00"
                If N$ = "1" Then N$ = "01"
                If N$ = "2" Then N$ = "10"
                If N$ = "3" Then N$ = "11"
                Bit$ = N$
                If Val("&H" + Left$(Pixel$, 2)) < 127 Then Bit$ = "TT"
                SpriteOriginal$(x, y) = Left$(Bit$, 1)
                SpriteOriginal$(x + 1, y) = Right$(Bit$, 1)
            Next x
        Next y
        If SpWidth > imageWidth * 2 Then
            For y = 0 To imageHeight - 1
                For x = imageWidth * 2 To SpWidth Step 2
                    SpriteOriginal$(x, y) = "T"
                    SpriteOriginal$(x + 1, y) = "T"
                Next x
            Next y
        End If
    End If
    If Colours = 16 Then
        ' Get the best 16 colours that can be used on the CoCo 3 and use them for this sprite
        SpWidth = SpWidth * 4 ' Four bits per pixel
        ' Format of the long values in hex is AARRGGBB where AA is the Alpha value, 00 is tranparent, FF is full intensity
        '                                              RR,GG,BB are 8 bit values of the colours Red,Green,Blue
        For y = 0 To imageHeight - 1
            For x = 0 To imageWidth * 4 - 1 Step 4
                Pixel$ = Right$("00000000" + Hex$(pixelColors(x / 4, y)), 8)
                R = Val("&H" + Mid$(Pixel$, 3, 2))
                G = Val("&H" + Mid$(Pixel$, 5, 2))
                B = Val("&H" + Mid$(Pixel$, 7, 2))
                ' Call subroutine to find the closest color return with closest match in variable bestIndex
                GoSub FindClosestColor
                ' Print "Closest Palette #"; bestIndex
                n = bestIndex: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                If N$ = "" Then N$ = "0000"
                If N$ = "1" Then N$ = "0001"
                If N$ = "2" Then N$ = "0010"
                If N$ = "3" Then N$ = "0011"
                If N$ = "4" Then N$ = "0100"
                If N$ = "5" Then N$ = "0101"
                If N$ = "6" Then N$ = "0110"
                If N$ = "7" Then N$ = "0111"
                If N$ = "8" Then N$ = "1000"
                If N$ = "9" Then N$ = "1001"
                If N$ = "10" Then N$ = "1010"
                If N$ = "11" Then N$ = "1011"
                If N$ = "12" Then N$ = "1100"
                If N$ = "13" Then N$ = "1101"
                If N$ = "14" Then N$ = "1110"
                If N$ = "15" Then N$ = "1111"
                Bit$ = N$
                If Val("&H" + Left$(Pixel$, 2)) < 127 Then Bit$ = "TTTT"
                SpriteOriginal$(x, y) = Left$(Bit$, 1)
                SpriteOriginal$(x + 1, y) = Mid$(Bit$, 2, 1)
                SpriteOriginal$(x + 2, y) = Mid$(Bit$, 3, 1)
                SpriteOriginal$(x + 3, y) = Mid$(Bit$, 4, 1)
            Next x
        Next y
        If SpWidth > imageWidth * 4 Then
            For y = 0 To imageHeight - 1
                For x = imageWidth * 4 To SpWidth Step 4
                    SpriteOriginal$(x, y) = "T"
                    SpriteOriginal$(x + 1, y) = "T"
                    SpriteOriginal$(x + 2, y) = "T"
                    SpriteOriginal$(x + 3, y) = "T"
                Next x
            Next y
        End If
    End If

Else
    ' Not a CoCo 3
    If Colours = 2 Or Artifact = 1 Then
        For y = 0 To imageHeight - 1
            For x = 0 To imageWidth - 1
                Pixel$ = Right$("00000000" + Hex$(pixelColors(x, y)), 8)
                PixVal = Val("&H" + Mid$(Pixel$, 3, 2)) * 65536
                PixVal = PixVal + Val("&H" + Mid$(Pixel$, 5, 2)) * 256
                PixVal = PixVal + Val("&H" + Mid$(Pixel$, 7, 2))
                If PixVal > 0 Then Bit$ = "1" Else Bit$ = "0"
                If Val("&H" + Left$(Pixel$, 2)) < 127 Then Bit$ = "T"
                SpriteOriginal$(x, y) = Bit$
            Next x
        Next y
        If SpWidth > imageWidth Then
            For y = 0 To imageHeight - 1
                For x = imageWidth To SpWidth
                    SpriteOriginal$(x, y) = "T"
                Next x
            Next y
        End If
    End If
    If Colours = 4 And Artifact = 0 Then
        If ScreenOption = 0 Then
            ColoursToUse(0, 0) = &H00: ColoursToUse(0, 1) = &HD6: ColoursToUse(0, 2) = &H00 ' 00D600 Bright Green / Neon Green (A vivid green, similar to fresh grass or a traffic signal)
            ColoursToUse(1, 0) = &HB8: ColoursToUse(1, 1) = &HE6: ColoursToUse(1, 2) = &H00 ' B8E600 Lime Green / Yellow-Green (A bright, citrusy green with a yellowish tint)
            ColoursToUse(2, 0) = &H4F: ColoursToUse(2, 1) = &H39: ColoursToUse(2, 2) = &HBB ' 4F39BB Royal Blue / Deep Violet (A rich blue with a purple hue, close to indigo)
            ColoursToUse(3, 0) = &HA1: ColoursToUse(3, 1) = &H23: ColoursToUse(3, 2) = &H30 ' A12330 Deep Red / Burgundy (A dark, muted red with a hint of brown)
        Else
            ColoursToUse(0, 0) = &HBD: ColoursToUse(0, 1) = &HC8: ColoursToUse(0, 2) = &HA9 ' BDC8A9 Soft Sage Green (A pale, muted greenish-gray)
            ColoursToUse(1, 0) = &H00: ColoursToUse(1, 1) = &HB2: ColoursToUse(1, 2) = &H6B ' 00B26B Jade Green (A rich green with a hint of blue)
            ColoursToUse(2, 0) = &HD9: ColoursToUse(2, 1) = &H42: ColoursToUse(2, 2) = &HF8 ' D942F8 Vivid Magenta / Electric Purple (A bright purplish-pink)
            ColoursToUse(3, 0) = &HE2: ColoursToUse(3, 1) = &H7A: ColoursToUse(3, 2) = &H00 ' E27A00 Burnt Orange (A strong, warm orange tone)
        End If

        SpWidth = SpWidth * 2 ' Two bits per pixel
        ' Format of the long values in hex is AARRGGBB where AA is the Alpha value, 00 is tranparent, FF is full intensity
        '                                              RR,GG,BB are 8 bit values of the colours Red,Green,Blue
        For y = 0 To imageHeight - 1
            For x = 0 To imageWidth * 2 - 1 Step 2
                Pixel$ = Right$("00000000" + Hex$(pixelColors(x / 2, y)), 8)
                R = Val("&H" + Mid$(Pixel$, 3, 2))
                G = Val("&H" + Mid$(Pixel$, 5, 2))
                B = Val("&H" + Mid$(Pixel$, 7, 2))
                ' Call subroutine to find the closest color return with closest match in variable bestIndex
                GoSub FindClosestColor
                ' Print "Closest Palette #"; bestIndex
                n = bestIndex: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                If N$ = "" Then N$ = "00"
                If N$ = "1" Then N$ = "01"
                If N$ = "2" Then N$ = "10"
                If N$ = "3" Then N$ = "11"
                Bit$ = N$
                If Val("&H" + Left$(Pixel$, 2)) < 127 Then Bit$ = "TT"
                SpriteOriginal$(x, y) = Left$(Bit$, 1)
                SpriteOriginal$(x + 1, y) = Right$(Bit$, 1)
            Next x
        Next y
        If SpWidth > imageWidth * 2 Then
            For y = 0 To imageHeight - 1
                For x = imageWidth * 2 To SpWidth Step 2
                    SpriteOriginal$(x, y) = "T"
                    SpriteOriginal$(x + 1, y) = "T"
                Next x
            Next y
        End If
    End If
End If

ScreenWidth = Val(GModeMaxX$(Gmode)) + 1
ScreenHeight = Val(GModeMaxY$(Gmode)) + 1
ScreenSize = Val("&H" + GModeScreenSize$(Gmode))

If ConvertBackground > 0 Then GoTo ConvertBackground

Print "GMODE # selected:"; Gmode
Print "Screen Width:"; ScreenWidth
Print "Screen Height:"; ScreenHeight
Print "Colours:"; Colours
If CoCo3 = 0 And Colours = 4 Then
    n = ScreenOption: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    If N$ = "" Then N$ = "0"
    Print "Using colour set for BASIC's SCREEN 1,"; N$; " command"
End If
'Print "Screen bytes per row is"; ScreenWidth / 8
Print "Generating Sprite with the following info:"
Print "Sprite Width:"; imageWidth / AnimFrames
Print "Sprite Height:"; imageHeight
Print "Number of frames in this sprite:"; AnimFrames

Print "Filename: "; FNameNoExt$; ".asm"
DrawBytesPerRow = (imageWidth / AnimFrames) / 8
If Colours = 4 And Artifact = 0 Then
    DrawBytesPerRow = (imageWidth / AnimFrames) / 4
End If
If Colours = 16 Then
    DrawBytesPerRow = (imageWidth / AnimFrames) / 2
End If

If DrawBytesPerRow <> Int(DrawBytesPerRow) Then DrawBytesPerRow = Int(DrawBytesPerRow) + 1
imageWidth = SpWidth

TotalCycles = 0
Dim Pixels(imageWidth - 1, imageHeight - 1) As _Byte
Dim CopyOfPixels(imageWidth - 1, imageHeight - 1) As _Byte ' Copy of the Pixel Array
Dim OrigPixels(imageWidth - 1, imageHeight - 1) As _Byte ' Copy of the Pixel Array

SpWidth = SpWidth / AnimFrames

XPos = 0: YPos = 0 ' Sprite drawing location in bytes (not pixels)
OldXPos = 0: OldYPos = 0 ' Used to caclulate LEAU and ABX values

Outname$ = FNameNoExt$ + ".asm"
Open Outname$ For Output As #2
Print #2, "; Sprite Name            : "; FNameNoExt$
Print #2, "; Sprite Width in pixels :"; imageWidth - 1
Print #2, "; Sprite Height in pixels:"; imageHeight
Print #2, "; # of Colours           :"; Colours
Print #2, "; # of Animation Frames  :"; AnimFrames

' Build Jump Table
Print #2, FNameNoExt$; "_Draw:"
If AnimWalk = 1 And Gmode = 18 Then
    ' Handle special 4 cells of animation for a walking sprite
    Instr1$ = "FCB": Instr2$ = "1": Com$ = "1 = This is a special Anim/Walk sprite": GoSub DoOutput ' Print the output to file #2
    For FrameNumber = 0 To AnimFrames - 1
        n = FrameNumber: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        If N$ = "" Then N$ = "0"
        Instr1$ = "FDB": Instr2$ = FNameNoExt$ + "_" + N$ + "_0": Com$ = "Address to draw sprite": GoSub DoOutput ' Print the output to file #2
    Next FrameNumber
Else
    If Gmode = 18 Then
        Instr1$ = "FCB": Instr2$ = "0": Com$ = "0 = This is a normal sprite (not special Anim/Walk)": GoSub DoOutput ' Print the output to file #2
    End If
    ' Normal sprites
    For FrameNumber = 0 To AnimFrames - 1
        n = FrameNumber: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        If N$ = "" Then N$ = "0"
        FN$ = N$
        For i = 0 To ShiftCount
            n = i: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
            If N$ = "" Then N$ = "0"
            Instr1$ = "FDB": Instr2$ = FNameNoExt$ + "_" + FN$ + "_" + N$: Com$ = "Address to draw sprite": GoSub DoOutput ' Print the output to file #2
        Next i
    Next FrameNumber
End If

BytesPerRowToBackup = DrawBytesPerRow + 1 'number of bytes to copy per row after shifting 7 times
SpWidthOrig = SpWidth
For FrameNumber = 0 To AnimFrames - 1
    For y = 0 To imageHeight - 1
        For x = 0 To SpWidth - 1
            AnimSprite$(x, y, FrameNumber) = SpriteOriginal$(FrameNumber * SpWidth + x, y)
        Next x
    Next y
Next FrameNumber

GoSub Restore_BackupSprite ' Only need to use one backup & restore section for the animated sprite

If AnimWalk = 1 And Gmode = 18 Then
    ' Get ready to only draw 4 sprites
    CountWalk = 0
End If
For FrameNumber = 0 To AnimFrames - 1
    If Verbose > 0 Then Print "Working on FrameNumber"; FrameNumber
    n = FrameNumber: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    If N$ = "" Then N$ = "0"
    FrameNumber$ = N$ ' Framenumber without a space at the beginning
    For y = 0 To imageHeight - 1
        For x = 0 To SpWidth - 1
            SpriteOriginal$(x, y) = AnimSprite$(x, y, FrameNumber)
        Next x
    Next y
    SpWidth = SpWidthOrig ' Restore SpWidth as it gets changed everytime we do ShowAFrame
    GoSub ShowAFrame
Next FrameNumber
Close #2
System

ShowAFrame:
Print #2, "; Frame Number:"; FrameNumber
'Print #2, FNameNoExt$ + "_Width:"
'n = DrawBytesPerRow + 1: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
'Instr1$ = "FCB": Instr2$ = N$: Com$ = "Max width in Bytes after shifting 7 times": GoSub DoOutput ' Print the output to file #2
'Print #2, FNameNoExt$ + "_Height:"
'n = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
'Instr1$ = "FCB": Instr2$ = N$: Com$ = "Hieght in pixels": GoSub DoOutput ' Print the output to file #2
'For Y = 0 To imageHeight - 1
'    n = Y: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
'    Print #2, "; "; Right$("000" + N$, 3); " ";
'    For X = 0 To SpWidth - 1
'        Temp$ = SpriteOriginal$(X, Y): If Temp$ = "T" Then Temp$ = "."
'        Print #2, Temp$;
'    Next X
'    Print #2,
'Next Y

' Draw the Sprite
If AnimWalk = 1 And Gmode = 18 And SpriteShift = CountWalk Then
    ' Get ready to only draw 4 sprites in position 0
    SpriteShift = 0
    GoSub DoDrawShift
Else
    For SpriteShift = 0 To ShiftCount ' This will go from 0 to ShiftCount to generate the 8 sprites needed based on its position
        GoSub DoDrawShift
    Next SpriteShift
End If
Print #2,
Return


DoDrawShift:
' Draw the sprite in comments
n = SpriteShift: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
If N$ = "" Then N$ = "0"
Print #2, FNameNoExt$ + "_" + FrameNumber$ + "_" + N$ + ":"
Select Case Colours:
    Case 2
        Select Case SpriteShift:
            Case 1 To 7
                ' Check if the right side of the image is transparent
                RT = 1 'start as flagging right side row as transparent
                For Row = 0 To imageHeight - 1
                    If SpriteOriginal$(SpWidth - 1, Row) <> "T" Then RT = 0: Exit For
                Next Row
                If RT = 1 Then
                    ' Right side pixel is transparent
                    ' Shift it right, strip the T off the right and don't increase the SpWidth
                    ' Shift sprite to the right, Add a T to the left
                    For Row = 0 To imageHeight - 1
                        row$ = "T"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth - 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                    Next Row
                Else
                    ' Make the sprite 8 pixels wider and fill the left with a Transparent pixel + original pixels + 7 transparent pixels
                    For Row = 0 To imageHeight - 1
                        row$ = "T"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                        For x = SpWidth + 1 To SpWidth + 7
                            SpriteOriginal$(x, Row) = "T"
                        Next x
                    Next Row
                    SpWidth = SpWidth + 8
                End If
        End Select
    Case 4
        ' Handle 4 colours
        Select Case SpriteShift:
            Case 1 To 3
                ' Check if the right side of the image is transparent
                RT = 1 'start as flagging right side row as transparent
                For Row = 0 To imageHeight - 1
                    If SpriteOriginal$(SpWidth - 1, Row) <> "T" Then RT = 0: Exit For
                Next Row
                If RT = 1 Then
                    ' Right side pixel is transparent
                    ' Shift it right, strip the TT off the right and don't increase the SpWidth
                    ' Shift sprite to the right, Add a T to the left
                    For Row = 0 To imageHeight - 1
                        row$ = "TT"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth - 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                    Next Row
                Else
                    ' Make the sprite 8 pixels wider and fill the left with a Transparent pixel + original pixels + 7 transparent pixels
                    For Row = 0 To imageHeight - 1
                        row$ = "TT"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth + 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                        For x = SpWidth + 2 To SpWidth + 7
                            SpriteOriginal$(x, Row) = "T"
                        Next x
                    Next Row
                    SpWidth = SpWidth + 8
                End If
        End Select
    Case 16
        ' Handle 16 colours
        Select Case SpriteShift:
            Case 1
                ' Check if the right side of the image is transparent
                RT = 1 'start as flagging right side row as transparent
                For Row = 0 To imageHeight - 1
                    If SpriteOriginal$(SpWidth - 1, Row) <> "T" Then RT = 0: Exit For
                Next Row
                If RT = 1 Then
                    ' Right side pixel is transparent
                    ' Shift it right, strip the TT off the right and don't increase the SpWidth
                    ' Shift sprite to the right, Add a T to the left
                    For Row = 0 To imageHeight - 1
                        row$ = "TTTT"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth - 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                    Next Row
                Else
                    ' Make the sprite 8 pixels wider and fill the left with a Transparent pixel + original pixels + 7 transparent pixels
                    For Row = 0 To imageHeight - 1
                        row$ = "TTTT"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth + 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                        For x = SpWidth + 4 To SpWidth + 7
                            SpriteOriginal$(x, Row) = "T"
                        Next x
                    Next Row
                    SpWidth = SpWidth + 8
                End If
        End Select
End Select

For y = 0 To imageHeight - 1
    n = y: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    Print #2, "; "; Right$("000" + N$, 3); " ";
    For x = 0 To SpWidth - 1
        Temp$ = SpriteOriginal$(x, y): If Temp$ = "T" Then Temp$ = "."
        Print #2, Temp$;
    Next x
    Print #2,
Next y



' Draw Sprite
'    Print #2, ";               1         2         3         4         5         6         7"
'    Print #2, ";     012345678901234567890123456789012345678901234567890123456789012345678901"
'    Print #2, ";     000000001111111122222222333333334444444455555555666666667777777788888888"
'    For Y = 0 To imageHeight - 1
'        n = Y: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
'        Print #2, "; "; Right$("000" + N$, 3); " ";
'        For X = 0 To SpWidth - 1
'            Temp$ = SpriteOriginal$(X, Y): If Temp$ = "T" Then Temp$ = "."
'            Print #2, Temp$;
'        Next X
'        Print #2,
'    Next Y
LastA$ = ""
LastU$ = ""
B$ = ""
n = (ScreenWidth / (8 / ShiftBits))
If Artifact = 1 Then n = 32
GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
For i = 7 To 0 Step -1
    If (n And (2 ^ i)) > 0 Then
        B$ = B$ + "1"
    Else
        B$ = B$ + "0"
    End If
Next i
LastB$ = B$
If ScrollMode = 0 Then
    Instr1$ = "LDB": Instr2$ = "#" + N$: Com$ = "Amount to move down the screen to the next row": GoSub DoOutput ' Print the output to file #2
End If

For Row = 0 To imageHeight - 1
    Print #2, "; Row"; Row
    row$ = ""
    TransparentRow = 1 ' Default = Transparent row
    For x = 0 To SpWidth - 1
        Temp$ = SpriteOriginal$(x, Row)
        If Temp$ <> "T" Then TransparentRow = 0
        row$ = row$ + Temp$
    Next x
    ' check a row of transparent bytes

    If TransparentRow = 1 Then
        ' This row is transparent and will be ignored
        ' Check if the rest will also be transparent, if so we are done
        TransparentRow = 1 ' Default = Transparent row
        For CheckRow = Row To imageHeight - 1
            For x = 0 To SpWidth - 1
                Temp$ = SpriteOriginal$(x, CheckRow)
                If Temp$ <> "T" Then TransparentRow = 0
            Next x
        Next CheckRow
        If TransparentRow = 1 Then
            ' The rest is also transparent, we are done
            Print #2, "; The rest of the rows are transparent and will be skipped"
            Row = imageHeight - 1 ' this will end the loop
        End If
    Else
        ' Row is not transparent so handle the bytes
        GoSub FindWordCounts
        If LargestWord > 0 Then
            ' Fill in the largest words first
            If LastU$ <> LargeWord$ Then
                Instr1$ = "LDU": Instr2$ = "#%" + LargeWord$: Com$ = "Get the sprite data into U": GoSub DoOutput ' Print the output to file #2
            End If
            For p = 0 To DrawBytesPerRow * 8 - 1 Step 8
                If Mid$(row$, p + 1, 16) = LargeWord$ Then
                    n = p / 8: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                    Instr1$ = "STU": Instr2$ = N$ + ",X": Com$ = "write the sprite data on screen": GoSub DoOutput ' Print the output to file #2
                    If p = 0 Then
                        Temp$ = String$(16, "x") + Mid$(row$, 17)
                    Else
                        Temp$ = Mid$(row$, 1, p) + String$(16, "x") + Mid$(row$, p + 17)
                    End If
                    row$ = Temp$
                End If
            Next p
        End If
        GoSub FindByteCounts
        If LargestByte > 0 Then
            ' Fill in the largest bytes next
            If LastA$ <> LargeByte$ Then
                Instr1$ = "LDA": Instr2$ = "#%" + LargeByte$: Com$ = "Get the sprite data into A": GoSub DoOutput ' Print the output to file #2
            End If
            For p = 0 To DrawBytesPerRow * 8 - 1 Step 8
                If Mid$(row$, p + 1, 8) = LargeByte$ Then
                    n = p / 8: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                    Instr1$ = "STA": Instr2$ = N$ + ",X": Com$ = "write the sprite data on screen": GoSub DoOutput ' Print the output to file #2
                    If p = 0 Then
                        Temp$ = String$(8, "x") + Mid$(row$, 9)
                    Else
                        Temp$ = Mid$(row$, 1, p) + String$(8, "x") + Mid$(row$, p + 9)
                    End If
                    row$ = Temp$
                End If
            Next p
        End If
        ' Fill in what's left
        For j = 1 To Len(row$) - 7 Step 8

            '          Print "Mid$(row$, j, 8)="; Mid$(row$, j, 8), j

            If InStr(Mid$(row$, j, 8), "x") = 0 Then
                ' found a byte to process
                If Mid$(row$, j, 8) <> "TTTTTTTT" Then
                    ' if the byte is not all transparent
                    n = (j - 1) / 8: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                    If InStr(Mid$(row$, j, 8), "T") > 0 Then
                        ' This byte has some transparency to deal with
                        Temp0$ = ""
                        Mask0$ = ""
                        For x = 1 To 8
                            If Mid$(Mid$(row$, j, 8), x, 1) = "T" Then
                                Temp0$ = Temp0$ + "0"
                                Mask0$ = Mask0$ + "1"
                            Else
                                Temp0$ = Temp0$ + Mid$(Mid$(row$, j, 8), x, 1)
                                Mask0$ = Mask0$ + "0"
                            End If
                        Next x
                        Instr1$ = "LDA": Instr2$ = "#%" + Mask0$: Com$ = "Get the mask in A": GoSub DoOutput ' Print the output to file #2
                        Instr1$ = "ANDA": Instr2$ = N$ + ",X": Com$ = "Get the background into transparent bits into A": GoSub DoOutput ' Print the output to file #2
                        Instr1$ = "ORA": Instr2$ = "#%" + Temp0$: Com$ = "Get the non transparent bits into A": GoSub DoOutput ' Print the output to file #2
                        LastA$ = ""
                    Else
                        'Just a normal byte
                        If LastA$ <> Mid$(row$, j, 8) Then
                            Instr1$ = "LDA": Instr2$ = "#%" + Mid$(row$, j, 8): Com$ = "Get the sprite data into A": GoSub DoOutput ' Print the output to file #2
                        End If
                    End If
                    Instr1$ = "STA": Instr2$ = N$ + ",X": Com$ = "write the sprite data on screen": GoSub DoOutput ' Print the output to file #2
                End If
            End If
        Next j
    End If
    If Row <> imageHeight - 1 Then
        If ScrollMode = 0 Then
            Instr1$ = "ABX": Com$ = "Move down a row": GoSub DoOutput ' Print the output to file #2
        Else
            Instr1$ = "LEAX": Instr2$ = "256,X": Com$ = "Move down a row on the scrollable screen": GoSub DoOutput ' Print the output to file #2

        End If
    End If
Next Row
Instr1$ = "RTS": Com$ = "Done drawing the sprite, Return": GoSub DoOutput ' Print the output to file #2
Return

Restore_BackupSprite:
On SaveRestoreBackground + 1 GOTO RestoreBackground0, RestoreBackground1, RestoreBackground2

' No restore at all
RestoreBackground0:
Print #2, "; Option -b0 used which is to not restore the background behind the sprite VSYNC 1 & VSYNC 0"
Print #2, "Restore_" + FNameNoExt$ + "_1:"
Print #2, "Restore_" + FNameNoExt$ + "_0:"
Print #2, "; Option -b0 used which is to not backup Sprite data for "; FNameNoExt$
Print #2, "Backup_" + FNameNoExt$ + ":"
Instr1$ = "RTS": Com$ = "Nothing to do, simply Return": GoSub DoOutput ' Print the output to file #2
Return

' Restore background behind the sprite VSYNC 1 - Copy sprite from frame 0
RestoreBackground1:
Print #2, "; Restore the background behind the sprite VSYNC 1"
Print #2, "Restore_" + FNameNoExt$ + "_1:"
'n = -ScreenSize + (ScreenWidth / (8 / ShiftBits)) * (imageHeight - 1): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
'Instr1$ = "LEAS": Instr2$ = ",X": Com$ = "Point at the bottom left edge of the frame 0 sprite location": GoSub DoOutput ' Print the output to file #2
If Gmode < 99 Then
    n = Val("&H" + GModeScreenSize$(Gmode)): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
Else
    n = &H6000: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
End If
Instr1$ = "LEAY": Instr2$ = N$ + ",X": Com$ = "Point at the top left edge of the screen 1 sprite location": GoSub DoOutput ' Print the output to file #2
n = ScreenWidth / (8 / ShiftBits)
If Artifact = 1 Then n = 32
GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""

' Draw the sprite in comments
n = SpriteShift: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
If N$ = "" Then N$ = "0"
Print #2, FNameNoExt$ + "_" + FrameNumber$ + "_" + N$ + ":"
Select Case Colours:
    Case 2
        Select Case SpriteShift:
            Case 1 To 7
                ' Check if the right side of the image is transparent
                RT = 1 'start as flagging right side row as transparent
                For Row = 0 To imageHeight - 1
                    If SpriteOriginal$(SpWidth - 1, Row) <> "T" Then RT = 0: Exit For
                Next Row
                If RT = 1 Then
                    ' Right side pixel is transparent
                    ' Shift it right, strip the T off the right and don't increase the SpWidth
                    ' Shift sprite to the right, Add a T to the left
                    For Row = 0 To imageHeight - 1
                        row$ = "T"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth - 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                    Next Row
                Else
                    ' Make the sprite 8 pixels wider and fill the left with a Transparent pixel + original pixels + 7 transparent pixels
                    For Row = 0 To imageHeight - 1
                        row$ = "T"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                        For x = SpWidth + 1 To SpWidth + 7
                            SpriteOriginal$(x, Row) = "T"
                        Next x
                    Next Row
                    SpWidth = SpWidth + 8
                End If
        End Select
    Case 4
        ' Handle 4 colours
        Select Case SpriteShift:
            Case 1 To 3
                ' Check if the right side of the image is transparent
                RT = 1 'start as flagging right side row as transparent
                For Row = 0 To imageHeight - 1
                    If SpriteOriginal$(SpWidth - 1, Row) <> "T" Then RT = 0: Exit For
                Next Row
                If RT = 1 Then
                    ' Right side pixel is transparent
                    ' Shift it right, strip the TT off the right and don't increase the SpWidth
                    ' Shift sprite to the right, Add a T to the left
                    For Row = 0 To imageHeight - 1
                        row$ = "TT"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth - 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                    Next Row
                Else
                    ' Make the sprite 8 pixels wider and fill the left with a Transparent pixel + original pixels + 7 transparent pixels
                    For Row = 0 To imageHeight - 1
                        row$ = "TT"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth + 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                        For x = SpWidth + 2 To SpWidth + 7
                            SpriteOriginal$(x, Row) = "T"
                        Next x
                    Next Row
                    SpWidth = SpWidth + 8
                End If
        End Select
    Case 16
        ' Handle 16 colours
        Select Case SpriteShift:
            Case 1
                ' Check if the right side of the image is transparent
                RT = 1 'start as flagging right side row as transparent
                For Row = 0 To imageHeight - 1
                    If SpriteOriginal$(SpWidth - 1, Row) <> "T" Then RT = 0: Exit For
                Next Row
                If RT = 1 Then
                    ' Right side pixel is transparent
                    ' Shift it right, strip the TT off the right and don't increase the SpWidth
                    ' Shift sprite to the right, Add a T to the left
                    For Row = 0 To imageHeight - 1
                        row$ = "TTTT"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth - 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                    Next Row
                Else
                    ' Make the sprite 8 pixels wider and fill the left with a Transparent pixel + original pixels + 7 transparent pixels
                    For Row = 0 To imageHeight - 1
                        row$ = "TTTT"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth + 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                        For x = SpWidth + 4 To SpWidth + 7
                            SpriteOriginal$(x, Row) = "T"
                        Next x
                    Next Row
                    SpWidth = SpWidth + 8
                End If
        End Select
End Select

For y = 0 To imageHeight - 1
    n = y: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    Print #2, "; "; Right$("000" + N$, 3); " ";
    For x = 0 To SpWidth - 1
        Temp$ = SpriteOriginal$(x, y): If Temp$ = "T" Then Temp$ = "."
        Print #2, Temp$;
    Next x
    Print #2,
Next y

' Draw Sprite
'    Print #2, ";               1         2         3         4         5         6         7"
'    Print #2, ";     012345678901234567890123456789012345678901234567890123456789012345678901"
'    Print #2, ";     000000001111111122222222333333334444444455555555666666667777777788888888"
'    For Y = 0 To imageHeight - 1
'        n = Y: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
'        Print #2, "; "; Right$("000" + N$, 3); " ";
'        For X = 0 To SpWidth - 1
'            Temp$ = SpriteOriginal$(X, Y): If Temp$ = "T" Then Temp$ = "."
'            Print #2, Temp$;
'        Next X
'        Print #2,
'    Next Y
LastA$ = ""
LastU$ = ""
B$ = ""
n = (ScreenWidth / (8 / ShiftBits))
If Artifact = 1 Then n = 32
GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
For i = 7 To 0 Step -1
    If (n And (2 ^ i)) > 0 Then
        B$ = B$ + "1"
    Else
        B$ = B$ + "0"
    End If
Next i
LastB$ = B$
If ScrollMode = 0 Then
    MoveYAmount$ = N$
    Instr1$ = "LDB": Instr2$ = "#" + N$: Com$ = "Amount to move down the screen to the next row": GoSub DoOutput ' Print the output to file #2
End If
For Row = 0 To imageHeight - 1
    Print #2, "; Row"; Row
    row$ = ""

    TransparentRow = 1 ' Default = Transparent row
    For x = 0 To SpWidth - 1
        Temp$ = SpriteOriginal$(x, Row)
        If Temp$ <> "T" Then TransparentRow = 0
        row$ = row$ + Temp$
    Next x
    ' check a row of transparent bytes
    If TransparentRow = 1 And AnimFrames = 1 Then
        ' This row is transparent and will be ignored
        ' Check if the rest will also be transparent, if so we are done
        ' If we only have a signle frame, we can skip rows that are completely transparent
        TransparentRow = 1 ' Default = Transparent row
        For CheckRow = Row To imageHeight - 1
            For x = 0 To SpWidth - 1
                Temp$ = SpriteOriginal$(x, CheckRow)
                If Temp$ <> "T" Then TransparentRow = 0
            Next x
        Next CheckRow
        If TransparentRow = 1 Then
            ' The rest is also transparent, we are done
            Print #2, "; The rest of the rows are transparent and will be skipped"
            Row = imageHeight - 1 ' this will end the loop
        End If

    Else
        ' Row is not transparent so handle the bytes
        p = 2
        While DrawBytesPerRow + 1 - p >= 0
            n = p - 2: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
            Instr1$ = "LDU": Instr2$ = N$ + ",X": Com$ = "read the sprite data on screen 0": GoSub DoOutput ' Print the output to file #2
            Instr1$ = "STU": Instr2$ = N$ + ",Y": Com$ = "write the sprite data on screen 1": GoSub DoOutput ' Print the output to file #2
            p = p + 2
        Wend
        p = p - 1
        While DrawBytesPerRow + 1 - p >= 0
            n = p - 1: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
            Instr1$ = "LDA": Instr2$ = N$ + ",X": Com$ = "read the sprite data on screen 0": GoSub DoOutput ' Print the output to file #2
            Instr1$ = "STA": Instr2$ = N$ + ",Y": Com$ = "write the sprite data on screen 1": GoSub DoOutput ' Print the output to file #2
            p = p + 1
        Wend

        If AnimFrames = 1 Then
            ' If we only have a signle frame, we can skip rows that are completely transparent
            If Row + 1 <= imageHeight - 1 Then
                TransparentRow = 1 ' Default = Transparent row
                For x = 0 To SpWidth - 1
                    Temp$ = SpriteOriginal$(x, Row + 1)
                    If Temp$ <> "T" Then TransparentRow = 0
                    row$ = row$ + Temp$
                Next x
                ' check a row of transparent bytes
                If TransparentRow = 1 Then
                    ' This row is transparent and will be ignored
                    ' Check if the rest will also be transparent, if so we are done
                    TransparentRow = 1 ' Default = Transparent row
                    For CheckRow = Row + 1 To imageHeight - 1
                        For x = 0 To SpWidth - 1
                            Temp$ = SpriteOriginal$(x, CheckRow)
                            If Temp$ <> "T" Then TransparentRow = 0
                        Next x
                    Next CheckRow
                    If TransparentRow = 1 Then
                        ' The rest is also transparent, we are done
                        Print #2, "; The rest of the rows are transparent and will be skipped"
                        Row = imageHeight - 1 ' this will end the loop
                    End If
                End If
            End If
        End If

    End If
    If Row <> imageHeight - 1 Then
        If ScrollMode = 0 Then
            Instr1$ = "ABX": Com$ = "Move down a row": GoSub DoOutput ' Print the output to file #2
            Instr1$ = "LEAY": Instr2$ = MoveYAmount$ + ",Y": Com$ = "Move down a row on the scrollable screen": GoSub DoOutput ' Print the output to file #2
        Else
            Instr1$ = "LEAX": Instr2$ = "256,X": Com$ = "Move down a row on the scrollable screen": GoSub DoOutput ' Print the output to file #2
            Instr1$ = "LEAY": Instr2$ = "256,Y": Com$ = "Move down a row on the scrollable screen": GoSub DoOutput ' Print the output to file #2
        End If
    End If
Next Row
Instr1$ = "RTS": Com$ = "Done drawing the sprite, Return": GoSub DoOutput ' Print the output to file #2
Print #2,

' Restore background behind the sprite VSYNC 0
Print #2, "; Restore the background behind the sprite VSYNC 0"
Print #2, "Restore_" + FNameNoExt$ + "_0:"
Instr1$ = "PSHS": Instr2$ = "DP": Com$ = "Save DP": GoSub DoOutput ' Print the output to file #2
Instr1$ = "STS": Instr2$ = "@SaveSHere+2": Com$ = "Backup the stack pointer's value at the end of the backup routine (self mod)": GoSub DoOutput ' Print the output to file #2
Instr1$ = "LDS": Instr2$ = "#" + FNameNoExt$ + "_BackupStart" + "+32": Com$ = "Set S pointer to the end of the last row of the backup buffer + 32 extra space for stack during F/IRQ": GoSub DoOutput ' Print the output to file #2

n = (ScreenWidth / (8 / ShiftBits)) * (imageHeight - 1) + DrawBytesPerRow + 1
If Artifact = 1 Then n = 32 * (imageHeight - 1) + DrawBytesPerRow + 1
If ScrollMode = 1 Then n = 256 * (imageHeight - 1) + DrawBytesPerRow + 1
GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
Instr1$ = "LEAU": Instr2$ = N$ + ",X": Com$ = "Point at the bottom, right edge of the sprite backup location": GoSub DoOutput ' Print the output to file #2

' Calculate restore pattern
bcopy = DrawBytesPerRow + 1 'number of bytes to copy per row
For x = 7 To 1 Step -1
    Blast(x) = 0
    c = 0
    While bcopy >= x
        bcopy = bcopy - x
        c = c + 1
    Wend
    Blast(x) = c
Next x

BlastAmount = DrawBytesPerRow + 1 'number of bytes to copy per row
UMove = 0
For Row = imageHeight - 1 To 0 Step -1
    Print #2, "; Restoring row"; Row
    BlastCount = 0
    For x = 1 To 7
        If Blast(x) > 0 Then
            c = Blast(x)
            Select Case x
                Case 1
                    While c > 0
                        Instr1$ = "PULS": Instr2$ = "A": Com$ = "Get Data to restore": GoSub DoOutput ' Print the output to file #2
                        Instr1$ = "PSHU": Instr2$ = "A": Com$ = "Write a Data to the screen": GoSub DoOutput ' Print the output to file #2
                        c = c - 1
                    Wend
                Case 2
                    While c > 0
                        Instr1$ = "PULS": Instr2$ = "D": Com$ = "Get Data to restore": GoSub DoOutput ' Print the output to file #2
                        Instr1$ = "PSHU": Instr2$ = "D": Com$ = "Write a Data to the screen": GoSub DoOutput ' Print the output to file #2
                        c = c - 1
                    Wend
                Case 3
                    While c > 0
                        Instr1$ = "PULS": Instr2$ = "A,X": Com$ = "Get Data to restore": GoSub DoOutput ' Print the output to file #2
                        Instr1$ = "PSHU": Instr2$ = "A,X": Com$ = "Write a Data to the screen": GoSub DoOutput ' Print the output to file #2
                        c = c - 1
                    Wend
                Case 4
                    While c > 0
                        Instr1$ = "PULS": Instr2$ = "D,X": Com$ = "Get Data to restore": GoSub DoOutput ' Print the output to file #2
                        Instr1$ = "PSHU": Instr2$ = "D,X": Com$ = "Write a Data to the screen": GoSub DoOutput ' Print the output to file #2
                        c = c - 1
                    Wend
                Case 5
                    While c > 0
                        Instr1$ = "PULS": Instr2$ = "A,X,Y": Com$ = "Get Data to restore": GoSub DoOutput ' Print the output to file #2
                        Instr1$ = "PSHU": Instr2$ = "A,X,Y": Com$ = "Write a Data to the screen": GoSub DoOutput ' Print the output to file #2
                        c = c - 1
                    Wend
                Case 6
                    While c > 0
                        Instr1$ = "PULS": Instr2$ = "D,X,Y": Com$ = "Get Data to restore": GoSub DoOutput ' Print the output to file #2
                        Instr1$ = "PSHU": Instr2$ = "D,X,Y": Com$ = "Write a Data to the screen": GoSub DoOutput ' Print the output to file #2
                        c = c - 1
                    Wend
                Case 7
                    While c > 0
                        Instr1$ = "PULS": Instr2$ = "D,DP,X,Y": Com$ = "Get Data to restore": GoSub DoOutput ' Print the output to file #2
                        Instr1$ = "PSHU": Instr2$ = "D,DP,X,Y": Com$ = "Write a Data to the screen": GoSub DoOutput ' Print the output to file #2
                        c = c - 1
                    Wend
            End Select
        End If
    Next x
    UMove = -(ScreenWidth / (8 / ShiftBits)) + (DrawBytesPerRow + 1)
    If Artifact = 1 Then UMove = -32 + (DrawBytesPerRow + 1)
    If ScrollMode = 1 Then UMove = -256 + (DrawBytesPerRow + 1)
    n = UMove: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    If Row <> 0 Then Instr1$ = "LEAU": Instr2$ = N$ + ",U": Com$ = "Move to the correct position to write data on screen": GoSub DoOutput ' Print the output to file #2
Next Row
Print #2, "@SaveSHere"
Instr1$ = "LDS": Instr2$ = "#$FFFF": Com$ = "Self mod restore stack pointer": GoSub DoOutput ' Print the output to file #2
Instr1$ = "PULS": Instr2$ = "DP,PC": Com$ = "Restore DP & Return": GoSub DoOutput ' Print the output to file #2
Print #2,

' Backup data behind the sprite to it's own buffer
XPos = 0: YPos = 0 ' Sprite drawing location in bytes (not pixels)
OldXPos = 0: OldYPos = 0 ' Used to caclulate LEAU and ABX values
Outname$ = FNameNoExt$ + "_Backup" + ".asm"
' Backup the Bytes behind the sprite
Print #2, "; Backup Sprite data for "; FNameNoExt$
Print #2, "; Enter with X pointing at the memory location on screen to backup the data behind the sprite"
Print #2, "; Sprite Width is:"; BytesPerRowToBackup; "Bytes, one extra byte to backup for shifted start location"
Print #2, "; Height is:"; imageHeight; "Rows"
Print #2, FNameNoExt$ + "_BackupStart:"

n = BytesPerRowToBackup: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
Instr1$ = "RMB": Instr2$ = N$ + "*"
n = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
Instr2$ = Instr2$ + N$ + "+32": Com$ = "Reserve space for sprite background, plus a little extra for the stack (If F/IRQ happens)": GoSub DoOutput ' Print the output to file #2
Print #2, FNameNoExt$ + "_BackupEnd:"
Print #2, "Backup_" + FNameNoExt$ + ":"
Instr1$ = "PSHS": Instr2$ = "DP": Com$ = "Save Condition Codes & DP": GoSub DoOutput ' Print the output to file #2
Instr1$ = "STS": Instr2$ = "@SaveSHere+2": Com$ = "Backup the stack pointer's value at the end of the backup routine (self mod)": GoSub DoOutput ' Print the output to file #2
Instr1$ = "LDS": Instr2$ = "#" + FNameNoExt$ + "_BackupEnd": Com$ = "Set S pointer to the end of the backup buffer": GoSub DoOutput ' Print the output to file #2

Instr1$ = "LEAU": Instr2$ = ",X": Com$ = "U = X": GoSub DoOutput ' Print the output to file #2
For y = 0 To imageHeight - 1
    Print #2, "; Backup row"; y
    bcopy = BytesPerRowToBackup 'number of bytes to copy per row
    While bcopy >= 7
        Instr1$ = "PULU": Instr2$ = "D,DP,X,Y": Com$ = "Get seven bytes from the screen": GoSub DoOutput ' Print the output to file #2
        Instr1$ = "PSHS": Instr2$ = "D,DP,X,Y": Com$ = "Save seven bytes from the screen": GoSub DoOutput ' Print the output to file #2
        bcopy = bcopy - 7
    Wend
    While bcopy >= 6
        Instr1$ = "PULU": Instr2$ = "D,X,Y": Com$ = "Get six bytes from the screen": GoSub DoOutput ' Print the output to file #2
        Instr1$ = "PSHS": Instr2$ = "D,X,Y": Com$ = "Save six bytes from the screen": GoSub DoOutput ' Print the output to file #2
        bcopy = bcopy - 6
    Wend
    While bcopy >= 5
        Instr1$ = "PULU": Instr2$ = "A,X,Y": Com$ = "Get five bytes from the screen": GoSub DoOutput ' Print the output to file #2
        Instr1$ = "PSHS": Instr2$ = "A,X,Y": Com$ = "Save five bytes from the screen": GoSub DoOutput ' Print the output to file #2
        bcopy = bcopy - 5
    Wend
    While bcopy >= 4
        Instr1$ = "PULU": Instr2$ = "D,X": Com$ = "Get four bytes from the screen": GoSub DoOutput ' Print the output to file #2
        Instr1$ = "PSHS": Instr2$ = "D,X": Com$ = "Save four bytes from the screen": GoSub DoOutput ' Print the output to file #2
        bcopy = bcopy - 4
    Wend
    While bcopy >= 3
        Instr1$ = "PULU": Instr2$ = "A,X": Com$ = "Get three bytes from the screen": GoSub DoOutput ' Print the output to file #2
        Instr1$ = "PSHS": Instr2$ = "A,X": Com$ = "Save three bytes from the screen": GoSub DoOutput ' Print the output to file #2
        bcopy = bcopy - 3
    Wend
    While bcopy >= 2
        Instr1$ = "PULU": Instr2$ = "D": Com$ = "Get two bytes from the screen": GoSub DoOutput ' Print the output to file #2
        Instr1$ = "PSHS": Instr2$ = "D": Com$ = "Save two bytes from the screen": GoSub DoOutput ' Print the output to file #2
        bcopy = bcopy - 2
    Wend
    While bcopy >= 1
        Instr1$ = "PULU": Instr2$ = "A": Com$ = "Get a byte from the screen": GoSub DoOutput ' Print the output to file #2
        Instr1$ = "PSHS": Instr2$ = "A": Com$ = "Save a byte from the screen": GoSub DoOutput ' Print the output to file #2
        bcopy = bcopy - 1
    Wend
    If y <> imageHeight - 1 Then
        n = ScreenWidth / (8 / ShiftBits)
        If Artifact = 1 Then n = 32
        If ScrollMode = 1 Then n = 256
        GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr1$ = "LEAU": Instr2$ = N$
        n = BytesPerRowToBackup: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = Instr2$ + "-" + N$ + ",U": Com$ = "Move down to the start of the next row to copy": GoSub DoOutput ' Print the output to file #2
    End If
Next y
Print #2, "@SaveSHere"
Instr1$ = "LDS": Instr2$ = "#$FFFF": Com$ = "Self mod restore stack pointer": GoSub DoOutput ' Print the output to file #2
Instr1$ = "PULS": Instr2$ = "DP,PC": Com$ = "Restore DP & Return": GoSub DoOutput ' Print the output to file #2
Print #2,
Return

' Restore with a byte pattern, option -b2
RestoreBackground2:
Print #2, "; Option -b2 restore the background behind the sprite with a byte pattern -p"; Pattern; " VSYNC 1 & VYSNC 2"
Print #2, "Restore_" + FNameNoExt$ + "_1:"
Print #2, "Restore_" + FNameNoExt$ + "_0:"
n = ScreenWidth / (8 / ShiftBits)
If Artifact = 1 Then n = 32
GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
' Draw the sprite in comments
n = SpriteShift: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
If N$ = "" Then N$ = "0"
Print #2, FNameNoExt$ + "_" + FrameNumber$ + "_" + N$ + ":"
Select Case Colours:
    Case 2
        Select Case SpriteShift:
            Case 1 To 7
                ' Check if the right side of the image is transparent
                RT = 1 'start as flagging right side row as transparent
                For Row = 0 To imageHeight - 1
                    If SpriteOriginal$(SpWidth - 1, Row) <> "T" Then RT = 0: Exit For
                Next Row
                If RT = 1 Then
                    ' Right side pixel is transparent
                    ' Shift it right, strip the T off the right and don't increase the SpWidth
                    ' Shift sprite to the right, Add a T to the left
                    For Row = 0 To imageHeight - 1
                        row$ = "T"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth - 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                    Next Row
                Else
                    ' Make the sprite 8 pixels wider and fill the left with a Transparent pixel + original pixels + 7 transparent pixels
                    For Row = 0 To imageHeight - 1
                        row$ = "T"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                        For x = SpWidth + 1 To SpWidth + 7
                            SpriteOriginal$(x, Row) = "T"
                        Next x
                    Next Row
                    SpWidth = SpWidth + 8
                End If
        End Select
    Case 4
        ' Handle 4 colours
        Select Case SpriteShift:
            Case 1 To 3
                ' Check if the right side of the image is transparent
                RT = 1 'start as flagging right side row as transparent
                For Row = 0 To imageHeight - 1
                    If SpriteOriginal$(SpWidth - 1, Row) <> "T" Then RT = 0: Exit For
                Next Row
                If RT = 1 Then
                    ' Right side pixel is transparent
                    ' Shift it right, strip the TT off the right and don't increase the SpWidth
                    ' Shift sprite to the right, Add a T to the left
                    For Row = 0 To imageHeight - 1
                        row$ = "TT"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth - 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                    Next Row
                Else
                    ' Make the sprite 8 pixels wider and fill the left with a Transparent pixel + original pixels + 7 transparent pixels
                    For Row = 0 To imageHeight - 1
                        row$ = "TT"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth + 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                        For x = SpWidth + 2 To SpWidth + 7
                            SpriteOriginal$(x, Row) = "T"
                        Next x
                    Next Row
                    SpWidth = SpWidth + 8
                End If
        End Select
    Case 16
        ' Handle 16 colours
        Select Case SpriteShift:
            Case 1
                ' Check if the right side of the image is transparent
                RT = 1 'start as flagging right side row as transparent
                For Row = 0 To imageHeight - 1
                    If SpriteOriginal$(SpWidth - 1, Row) <> "T" Then RT = 0: Exit For
                Next Row
                If RT = 1 Then
                    ' Right side pixel is transparent
                    ' Shift it right, strip the TT off the right and don't increase the SpWidth
                    ' Shift sprite to the right, Add a T to the left
                    For Row = 0 To imageHeight - 1
                        row$ = "TTTT"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth - 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                    Next Row
                Else
                    ' Make the sprite 8 pixels wider and fill the left with a Transparent pixel + original pixels + 7 transparent pixels
                    For Row = 0 To imageHeight - 1
                        row$ = "TTTT"
                        For x = 0 To SpWidth - 1
                            row$ = row$ + SpriteOriginal$(x, Row)
                        Next x
                        For x = 0 To SpWidth + 1
                            SpriteOriginal$(x, Row) = Mid$(row$, x + 1, 1)
                        Next x
                        For x = SpWidth + 4 To SpWidth + 7
                            SpriteOriginal$(x, Row) = "T"
                        Next x
                    Next Row
                    SpWidth = SpWidth + 8
                End If
        End Select
End Select

For y = 0 To imageHeight - 1
    n = y: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    Print #2, "; "; Right$("000" + N$, 3); " ";
    For x = 0 To SpWidth - 1
        Temp$ = SpriteOriginal$(x, y): If Temp$ = "T" Then Temp$ = "."
        Print #2, Temp$;
    Next x
    Print #2,
Next y

' Draw Sprite
'    Print #2, ";               1         2         3         4         5         6         7"
'    Print #2, ";     012345678901234567890123456789012345678901234567890123456789012345678901"
'    Print #2, ";     000000001111111122222222333333334444444455555555666666667777777788888888"
'    For Y = 0 To imageHeight - 1
'        n = Y: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
'        Print #2, "; "; Right$("000" + N$, 3); " ";
'        For X = 0 To SpWidth - 1
'            Temp$ = SpriteOriginal$(X, Y): If Temp$ = "T" Then Temp$ = "."
'            Print #2, Temp$;
'        Next X
'        Print #2,
'    Next Y

Instr1$ = "PSHS": Instr2$ = "DP": Com$ = "Save DP": GoSub DoOutput ' Print the output to file #2
n = (ScreenWidth / (8 / ShiftBits)) * (imageHeight - 1) + DrawBytesPerRow + 1
If Artifact = 1 Then n = 32 * (imageHeight - 1) + DrawBytesPerRow + 1
If ScrollMode = 1 Then n = 256 * (imageHeight - 1) + DrawBytesPerRow + 1
GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
Instr1$ = "LEAU": Instr2$ = N$ + ",X": Com$ = "Point at the bottom, right edge of the sprite backup location": GoSub DoOutput ' Print the output to file #2

n = Pattern * &H100 + Pattern: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
If N$ = "" Then N$ = "$0000"
Instr1$ = "LDD": Instr2$ = "#" + N$: Com$ = "D = byte Pattern user wants for the background": GoSub DoOutput ' Print the output to file #2
Instr1$ = "LDX": Instr2$ = "#" + N$: Com$ = "X = byte Pattern user wants for the background": GoSub DoOutput ' Print the output to file #2
Instr1$ = "TFR": Instr2$ = "X,Y": Com$ = "Y = byte Pattern user wants for the background": GoSub DoOutput ' Print the output to file #2
Instr1$ = "TFR": Instr2$ = "A,DP": Com$ = "DP = byte Pattern user wants for the background": GoSub DoOutput ' Print the output to file #2

' Calculate restore pattern
bcopy = DrawBytesPerRow + 1 'number of bytes to copy per row
For x = 7 To 1 Step -1
    Blast(x) = 0
    c = 0
    While bcopy >= x
        bcopy = bcopy - x
        c = c + 1
    Wend
    Blast(x) = c
Next x

BlastAmount = DrawBytesPerRow + 1 'number of bytes to copy per row
UMove = 0
For Row = imageHeight - 1 To 0 Step -1
    Print #2, "; Restoring row"; Row
    BlastCount = 0
    For x = 1 To 7
        If Blast(x) > 0 Then
            c = Blast(x)
            Select Case x
                Case 1
                    While c > 0
                        Instr1$ = "PSHU": Instr2$ = "A": Com$ = "Write a Data to the screen": GoSub DoOutput ' Print the output to file #2
                        c = c - 1
                    Wend
                Case 2
                    While c > 0
                        Instr1$ = "PSHU": Instr2$ = "D": Com$ = "Write a Data to the screen": GoSub DoOutput ' Print the output to file #2
                        c = c - 1
                    Wend
                Case 3
                    While c > 0
                        Instr1$ = "PSHU": Instr2$ = "A,X": Com$ = "Write a Data to the screen": GoSub DoOutput ' Print the output to file #2
                        c = c - 1
                    Wend
                Case 4
                    While c > 0
                        Instr1$ = "PSHU": Instr2$ = "D,X": Com$ = "Write a Data to the screen": GoSub DoOutput ' Print the output to file #2
                        c = c - 1
                    Wend
                Case 5
                    While c > 0
                        Instr1$ = "PSHU": Instr2$ = "A,X,Y": Com$ = "Write a Data to the screen": GoSub DoOutput ' Print the output to file #2
                        c = c - 1
                    Wend
                Case 6
                    While c > 0
                        Instr1$ = "PSHU": Instr2$ = "D,X,Y": Com$ = "Write a Data to the screen": GoSub DoOutput ' Print the output to file #2
                        c = c - 1
                    Wend
                Case 7
                    While c > 0
                        Instr1$ = "PSHU": Instr2$ = "D,DP,X,Y": Com$ = "Write a Data to the screen": GoSub DoOutput ' Print the output to file #2
                        c = c - 1
                    Wend
            End Select
        End If
    Next x
    UMove = -(ScreenWidth / (8 / ShiftBits)) + (DrawBytesPerRow + 1)
    If Artifact = 1 Then UMove = -32 + (DrawBytesPerRow + 1)
    If ScrollMode = 1 Then UMove = -256 + (DrawBytesPerRow + 1)
    n = UMove: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    If Row <> 0 Then Instr1$ = "LEAU": Instr2$ = N$ + ",U": Com$ = "Move to the correct position to write data on screen": GoSub DoOutput ' Print the output to file #2
Next Row
Instr1$ = "PULS": Instr2$ = "DP,PC": Com$ = "Restore DP & Return": GoSub DoOutput ' Print the output to file #2
Print #2,
Print #2, "; Option -b2 used which is to not backup Sprite data for "; FNameNoExt$
Print #2, "Backup_" + FNameNoExt$ + ":"
Instr1$ = "RTS": Com$ = "Nothing to do, simply Return": GoSub DoOutput ' Print the output to file #2
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
For i = 0 To Colours - 1
    ' Convert RGB to Luma (perceptual brightness)
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

'Dim PixVal As Long
'Dim Temp As Single

' Read pixel colors from the image on the screen
For y = 0 To imageHeight - 1
    For x = 0 To imageWidth - 1
        pixelColors(x, y) = Point(x, y) ' Long values 32 bit colour
        ' Format of the long values in hex is AARRGGBB where AA is the Alpha value, 00 is tranparent, FF is full intensity
        '                                              RR,GG,BB are 8 bit values of the colours Red,Green,Blue
    Next x
Next y

' Print "-cx     - Convtert .PNG into a file where x is:"
' Print "-c1     - Converts the .PNG file into a LOADM able file with an offset of 0"
' Print "-c2     - Converts the .PNG file into a .bin raw data file"
' Print "-c3     - Convert the .PNG file into an assembly file with FCB statements"
' Enter with value in ConvertBackground
ConvertBackground:
Padding = 0
If Colours = 2 Then
    If imageWidth / 8 <> Int(imageWidth / 8) Then Padding = ((Int(imageWidth / 8) + 1) * 8) - imageWidth
End If
If Colours = 4 Then
    If imageWidth / 4 <> Int(imageWidth / 4) Then Padding = (imageWidth = (Int(imageWidth / 4) + 1) * 4) - imageWidth
End If
If Colours = 16 Then
    If imageWidth / 2 <> Int(imageWidth / 2) Then Padding = (imageWidth = (Int(imageWidth / 2) + 1) * 2) - imageWidth
End If
Print "imagewidth="; imageWidth
'Print "Padding="; Padding
Print "imageheight="; imageHeight


' Last block is a 255 then two zero's then the execute address
' Next two bytes is the block length, then the address in RAM that the data will load at
Select Case Colours
    Case 2
        Blocksize = (imageWidth + Padding) / 8 * imageHeight
    Case 4
        Blocksize = (imageWidth + Padding) / 4 * imageHeight
    Case 16
        Blocksize = (imageWidth + Padding) / 2 * imageHeight
    Case Else
        Print "ERROR: can only handle images with 2,4 or 16 colours": System
End Select

' Print "-cx     - Convtert .PNG into a file where x is:"
' Print "-c1     - Converts the .PNG file into a LOADM able file with an offset of 0"
' Print "-c2     - Converts the .PNG file into a .bin raw data file"
' Print "-c3     - Convert the .PNG file into an assembly file with FCB statements"
p = 0
If ConvertBackground = 1 Then
    DiskOut(p) = 0: p = p + 1 ' Preamble value 0 = data, 255 = Last block
    DiskOut(p) = Int(Blocksize / 256): p = p + 1
    DiskOut(p) = Blocksize - Int(Blocksize / 256) * 256: p = p + 1 'Load address LSB
    StartLocation = 0
    DiskOut(p) = Int(StartLocation / 256): p = p + 1
    DiskOut(p) = StartLocation - Int(StartLocation / 256) * 256: p = p + 1 'Load address LSB
End If
For y = 0 To imageHeight - 1
    For x = 0 To imageWidth - 1 Step 8
        v = 0
        If SpriteOriginal$(x, y) = "1" Then v = v + 128
        If SpriteOriginal$(x + 1, y) = "1" Then v = v + 64
        If SpriteOriginal$(x + 2, y) = "1" Then v = v + 32
        If SpriteOriginal$(x + 3, y) = "1" Then v = v + 16
        If SpriteOriginal$(x + 4, y) = "1" Then v = v + 8
        If SpriteOriginal$(x + 5, y) = "1" Then v = v + 4
        If SpriteOriginal$(x + 6, y) = "1" Then v = v + 2
        If SpriteOriginal$(x + 7, y) = "1" Then v = v + 1
        DiskOut(p) = v: p = p + 1
    Next x
Next y
If ConvertBackground = 1 Then
    ' Postamble
    DiskOut(p) = 255: p = p + 1 ' Preamble value 0 = data, 255 = Last block
    ' Last block is a 255 then two zero's then the execute address
    ' Next two bytes is the block length, then the address in RAM that the data will load at
    DiskOut(p) = 0: p = p + 1
    DiskOut(p) = 0: p = p + 1
    DiskOut(p) = 0: p = p + 1 ' Execute address
    DiskOut(p) = 0: p = p + 1 ' Execute address
End If
c = 0
If ConvertBackground = 3 Then
    TempName$ = FNameNoExt$ + ".ASM"
    If _FileExists(TempName$) Then Kill TempName$
    If Verbose > 0 Then Print "Writing Disk file "; TempName$
    Open TempName$ For Output As #2
    Print #2, "; Assembly file converted from .PNG file: "; FName$
    Print #2, "; Image Width:"; imageWidth + Padding
    Print #2, "; Image Height:"; imageHeight
    Print #2, "; # of Colours:"; Colours
    Print #2, FNameNoExt$; ":"
    c = 0: Row = 0: Temp = imageWidth + Padding
    For Op = 0 To p - 1
        If c = 0 Then Print #2, "; Row"; Row
        Instr1$ = "FCB": Instr2$ = "$" + Hex$(DiskOut(Op)): Com$ = Str$(c): GoSub DoOutput ' Print the output to file #2
        c = c + 1
        If c = Temp Then Row = Row + 1: c = 0
    Next Op
    Close #2
    System
End If

ReDim LastOutArray(p - 1) As _Unsigned _Byte
For Op = 0 To p - 1
    LastOutArray(Op) = DiskOut(c): c = c + 1
Next Op
If ConvertBackground = 1 Then TempName$ = FNameNoExt$ + ".BIN"
If ConvertBackground = 2 Then TempName$ = FNameNoExt$ + ".RAW"
If _FileExists(TempName$) Then Kill TempName$
If Verbose > 0 Then Print "Writing Disk file "; TempName$
Open TempName$ For Binary As #2
Put #2, , LastOutArray()
Close #2
System

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

Make256ColourImage:
If imageWidth <> Val(GModeMaxX$(Gmode)) + 1 Then
    Print "Scaling image width from"; imageWidth; " to"; Val(GModeMaxX$(Gmode)) + 1
    ScaleWidth = Val(GModeMaxX$(Gmode)) / imageWidth
    For y = 0 To imageHeight
        For x = 0 To imageWidth



        Next x
    Next y
End If

ScaleHeight = Val(GModeMaxY$(Gmode))


If imageWidth <> Val(GModeMaxX$(Gmode)) + 1 Then Print "ERROR: Image width must be"; Val(GModeMaxX$(Gmode)) + 1: System
Dim DitherOut(imageWidth - 1, imageHeight - 1) As _Unsigned _Byte

On DitherType + 1 GOSUB DoNoDither, DoFloydDither, DoBlueNoiseTexture, DoOrderDither

Colours = 256
p = 0


'
'ConvertBackground = 5 = raw
'ConvertBackground = 6 = asm file


If ConvertBackground = 4 Then
    ' User wants a LOADMable CoCo3 file

    Dim TempArray(41000) As _Unsigned _Byte




    ' Fill array with data
    c = 0
    For y = 0 To imageHeight - 1
        For x = 0 To imageWidth - 1
            TempArray(c) = DitherOut(x, y): c = c + 1
        Next x
    Next y



    BlockNumber = BlkStart 'BlockNumber= 8k block in CoCo3's memory

    c = 0
    BlocksNeeded = Int((imageHeight * imageWidth) / &H2000) + 1
    For i = 1 To BlocksNeeded
        StartLocation = &HFFA6
        Blocksize = 1
        DiskOut(p) = 0: p = p + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(p) = Int(Blocksize / 256): p = p + 1
        DiskOut(p) = Blocksize - Int(Blocksize / 256) * 256: p = p + 1 'Load address LSB
        DiskOut(p) = Int(StartLocation / 256): p = p + 1
        DiskOut(p) = StartLocation - Int(StartLocation / 256) * 256: p = p + 1 'Load address LSB
        DiskOut(p) = BlockNumber: p = p + 1: BlockNumber = BlockNumber + 1
        StartLocation = &HC000
        Blocksize = &H2000
        DiskOut(p) = 0: p = p + 1 ' Preamble value 0 = data, 255 = Last block
        DiskOut(p) = Int(Blocksize / 256): p = p + 1
        DiskOut(p) = Blocksize - Int(Blocksize / 256) * 256: p = p + 1 'Load address LSB
        DiskOut(p) = Int(StartLocation / 256): p = p + 1
        DiskOut(p) = StartLocation - Int(StartLocation / 256) * 256: p = p + 1 'Load address LSB
        For i2 = 1 To &H2000
            DiskOut(p) = TempArray(c): p = p + 1: c = c + 1
        Next i2
    Next i
End If

If ConvertBackground = 4 Then
    ' User wants a LOADMable CoCo3 file
    ' Put 8k blocks back to normal
    BlockNumber = &H3E 'BlockNumber= 8k block in CoCo3's memory
    StartLocation = &HFFA6
    Blocksize = 1
    DiskOut(p) = 0: p = p + 1 ' Preamble value 0 = data, 255 = Last block
    DiskOut(p) = Int(Blocksize / 256): p = p + 1
    DiskOut(p) = Blocksize - Int(Blocksize / 256) * 256: p = p + 1 'Load address LSB
    DiskOut(p) = Int(StartLocation / 256): p = p + 1
    DiskOut(p) = StartLocation - Int(StartLocation / 256) * 256: p = p + 1 'Load address LSB
    DiskOut(p) = BlockNumber: p = p + 1: BlockNumber = BlockNumber + 1

    ' Postamble
    DiskOut(p) = 255: p = p + 1 ' Preamble value 0 = data, 255 = Last block
    ' Last block is a 255 then two zero's then the execute address
    ' Next two bytes is the block length, then the address in RAM that the data will load at
    DiskOut(p) = 0: p = p + 1
    DiskOut(p) = 0: p = p + 1
    DiskOut(p) = 0: p = p + 1 ' Execute address
    DiskOut(p) = 0: p = p + 1 ' Execute address
End If

c = 0
If ConvertBackground = 6 Then
    TempName$ = FNameNoExt$ + ".ASM"
    If _FileExists(TempName$) Then Kill TempName$
    If Verbose > 0 Then Print "Writing Disk file "; TempName$
    Open TempName$ For Output As #2
    Print #2, "; Assembly file converted from .PNG file: "; FName$
    Print #2, "; Image Width:"; imageWidth
    Print #2, "; Image Height:"; imageHeight
    Print #2, "; # of Colours:"; Colours
    Print #2, FNameNoExt$; ":"
    c = 0: Row = 0: Temp = imageWidth
    For Op = 0 To p - 1
        If c = 0 Then Print #2, "; Row"; Row
        Instr1$ = "FCB": Instr2$ = "$" + Hex$(DiskOut(Op)): Com$ = Str$(c): GoSub DoOutput ' Print the output to file #2
        c = c + 1
        If c = Temp Then Row = Row + 1: c = 0
    Next Op
    Close #2
    System
End If

ReDim LastOutArray(p - 1) As _Unsigned _Byte
For Op = 0 To p - 1
    LastOutArray(Op) = DiskOut(c): c = c + 1
Next Op
If ConvertBackground = 4 Then TempName$ = FNameNoExt$ + ".BIN"
If ConvertBackground = 5 Then TempName$ = FNameNoExt$ + ".RAW"
If _FileExists(TempName$) Then Kill TempName$
If Verbose > 0 Then Print "Writing Disk file "; TempName$
Open TempName$ For Binary As #2
Put #2, , LastOutArray()
Close #2
System


DoNoDither:
For y = 0 To imageHeight - 1
    For x = 0 To imageWidth - 1
        Pixel$ = Right$("00000000" + Hex$(pixelColors(x, y)), 8)
        R = Val("&H" + Mid$(Pixel$, 3, 2))
        G = Val("&H" + Mid$(Pixel$, 5, 2))
        B = Val("&H" + Mid$(Pixel$, 7, 2))
        ' Call subroutine to find the closest color return with closest match in variable bestIndex
        GoSub FindClosestColor ' Check through Colours # of colours and return with the closest colour index number in bestIndex
        DitherOut(x, y) = bestIndex
    Next x
Next y
Return

' Ordered Dither
DoOrderDither:
For y = 0 To imageHeight - 1
    For x = 0 To imageWidth - 1
        ' Extract RGB values from 32-bit pixelColors(x, y)
        Pixel$ = Right$("00000000" + Hex$(pixelColors(x, y)), 8)
        R = Val("&H" + Mid$(Pixel$, 3, 2))
        G = Val("&H" + Mid$(Pixel$, 5, 2))
        B = Val("&H" + Mid$(Pixel$, 7, 2))

        ' Get Bayer threshold value
        threshold = OrderedArray(x And 1, y And 1)

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
        For i = 0 To 255
            cr = ColoursToUse(i, 0)
            cg = ColoursToUse(i, 1)
            cb = ColoursToUse(i, 2)

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
DoFloydDither:
Dim errorR(0 To imageWidth, 0 To imageHeight) As Integer
Dim errorG(0 To imageWidth, 0 To imageHeight) As Integer
Dim errorB(0 To imageWidth, 0 To imageHeight) As Integer

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
        For i = 0 To 255
            cr = ColoursToUse(i, 0)
            cg = ColoursToUse(i, 1)
            cb = ColoursToUse(i, 2)

            dist = (R - cr) * (R - cr) + (G - cg) * (G - cg) + (B - cb) * (B - cb)
            If dist < bestDistance Then
                bestDistance = dist
                bestIndex = i
            End If
        Next i

        ' Store the dithered pixel
        DitherOut(x, y) = bestIndex

        ' Compute the error
        chosenR = ColoursToUse(bestIndex, 0)
        chosenG = ColoursToUse(bestIndex, 1)
        chosenB = ColoursToUse(bestIndex, 2)
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
        For i = 0 To 255
            cr = ColoursToUse(i, 0)
            cg = ColoursToUse(i, 1)
            cb = ColoursToUse(i, 2)

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

' NTSC 256 colour mode for composite output only on a CoCo3
' From XROAR's values
' Colour Value 0
Data 12,12,11
' Colour Value 1
Data 13,25,18
' Colour Value 2
Data 16,39,28
' Colour Value 3
Data 31,81,46
' Colour Value 4
Data 19,15,33
' Colour Value 5
Data 22,28,42
' Colour Value 6
Data 26,44,56
' Colour Value 7
Data 39,90,85
' Colour Value 8
Data 31,15,75
' Colour Value 9
Data 34,29,91
' Colour Value 10
Data 38,49,114
' Colour Value 11
Data 54,101,165
' Colour Value 12
Data 67,0,234
' Colour Value 13
Data 71,0,255
' Colour Value 14
Data 72,51,255
' Colour Value 15
Data 79,126,255
' Colour Value 16
Data 27,15,19
' Colour Value 17
Data 27,27,27
' Colour Value 18
Data 29,43,35
' Colour Value 19
Data 38,88,57
' Colour Value 20
Data 34,17,42
' Colour Value 21
Data 34,31,52
' Colour Value 22
Data 37,48,68
' Colour Value 23
Data 48,98,104
' Colour Value 24
Data 47,15,91
' Colour Value 25
Data 49,32,109
' Colour Value 26
Data 52,52,137
' Colour Value 27
Data 66,108,194
' Colour Value 28
Data 87,0,255
' Colour Value 29
Data 87,0,255
' Colour Value 30
Data 86,60,255
' Colour Value 31
Data 92,136,255
' Colour Value 32
Data 48,16,28
' Colour Value 33
Data 47,30,36
' Colour Value 34
Data 47,48,47
' Colour Value 35
Data 53,97,74
' Colour Value 36
Data 59,18,56
' Colour Value 37
Data 59,34,69
' Colour Value 38
Data 59,53,86
' Colour Value 39
Data 67,107,128
' Colour Value 40
Data 77,11,114
' Colour Value 41
Data 79,33,137
' Colour Value 42
Data 80,56,167
' Colour Value 43
Data 91,118,234
' Colour Value 44
Data 123,0,255
' Colour Value 45
Data 121,21,255
' Colour Value 46
Data 120,69,255
' Colour Value 47
Data 122,150,255
' Colour Value 48
Data 117,13,47
' Colour Value 49
Data 115,33,58
' Colour Value 50
Data 113,55,75
' Colour Value 51
Data 112,113,112
' Colour Value 52
Data 140,10,87
' Colour Value 53
Data 138,35,105
' Colour Value 54
Data 136,60,129
' Colour Value 55
Data 136,124,185
' Colour Value 56
Data 173,0,166
' Colour Value 57
Data 171,26,195
' Colour Value 58
Data 169,60,235
' Colour Value 59
Data 167,138,255
' Colour Value 60
Data 241,0,255
' Colour Value 61
Data 237,34,255
' Colour Value 62
Data 233,83,255
' Colour Value 63
Data 228,175,255
' Colour Value 64
Data 18,23,7
' Colour Value 65
Data 21,35,11
' Colour Value 66
Data 26,53,20
' Colour Value 67
Data 40,106,36
' Colour Value 68
Data 27,27,27
' Colour Value 69
Data 28,39,34
' Colour Value 70
Data 32,61,44
' Colour Value 71
Data 47,118,70
' Colour Value 72
Data 37,31,61
' Colour Value 73
Data 38,46,75
' Colour Value 74
Data 43,69,94
' Colour Value 75
Data 60,133,139
' Colour Value 76
Data 69,16,201
' Colour Value 77
Data 74,43,233
' Colour Value 78
Data 79,79,255
' Colour Value 79
Data 89,163,255
' Colour Value 80
Data 34,27,12
' Colour Value 81
Data 34,38,19
' Colour Value 82
Data 36,58,28
' Colour Value 83
Data 47,114,45
' Colour Value 84
Data 43,30,34
' Colour Value 85
Data 42,43,42
' Colour Value 86
Data 45,65,55
' Colour Value 87
Data 57,127,85
' Colour Value 88
Data 56,33,75
' Colour Value 89
Data 57,48,91
' Colour Value 90
Data 60,75,113
' Colour Value 91
Data 74,143,165
' Colour Value 92
Data 96,6,233
' Colour Value 93
Data 98,47,255
' Colour Value 94
Data 99,88,255
' Colour Value 95
Data 106,176,255
' Colour Value 96
Data 59,29,21
' Colour Value 97
Data 58,42,29
' Colour Value 98
Data 57,64,37
' Colour Value 99
Data 66,125,60
' Colour Value 100
Data 72,32,45
' Colour Value 101
Data 71,48,55
' Colour Value 102
Data 72,72,72
' Colour Value 103
Data 79,139,108
' Colour Value 104
Data 92,35,95
' Colour Value 105
Data 92,53,113
' Colour Value 106
Data 93,81,141
' Colour Value 107
Data 102,155,201
' Colour Value 108
Data 143,1,255
' Colour Value 109
Data 142,57,255
' Colour Value 110
Data 140,98,255
' Colour Value 111
Data 144,192,255
' Colour Value 112
Data 139,31,40
' Colour Value 113
Data 137,48,48
' Colour Value 114
Data 135,77,62
' Colour Value 115
Data 134,146,93
' Colour Value 116
Data 164,32,72
' Colour Value 117
Data 162,53,87
' Colour Value 118
Data 160,83,109
' Colour Value 119
Data 159,160,159
' Colour Value 120
Data 201,31,141
' Colour Value 121
Data 198,56,166
' Colour Value 122
Data 195,93,202
' Colour Value 123
Data 195,177,255
' Colour Value 124
Data 244,27,255
' Colour Value 125
Data 245,70,255
' Colour Value 126
Data 246,117,255
' Colour Value 127
Data 252,220,255
' Colour Value 128
Data 29,36,2
' Colour Value 129
Data 30,50,6
' Colour Value 130
Data 35,76,10
' Colour Value 131
Data 53,143,25
' Colour Value 132
Data 36,41,16
' Colour Value 133
Data 37,57,25
' Colour Value 134
Data 42,85,33
' Colour Value 135
Data 60,159,53
' Colour Value 136
Data 47,48,47
' Colour Value 137
Data 49,66,58
' Colour Value 138
Data 54,99,74
' Colour Value 139
Data 73,179,112
' Colour Value 140
Data 79,56,164
' Colour Value 141
Data 82,80,192
' Colour Value 142
Data 89,118,231
' Colour Value 143
Data 107,216,254
' Colour Value 144
Data 44,39,7
' Colour Value 145
Data 45,56,10
' Colour Value 146
Data 48,82,17
' Colour Value 147
Data 63,154,33
' Colour Value 148
Data 55,45,26
' Colour Value 149
Data 56,63,32
' Colour Value 150
Data 58,92,42
' Colour Value 151
Data 73,170,66
' Colour Value 152
Data 71,51,58
' Colour Value 153
Data 72,72,72
' Colour Value 154
Data 75,106,90
' Colour Value 155
Data 90,190,134
' Colour Value 156
Data 113,59,193
' Colour Value 157
Data 114,86,224
' Colour Value 158
Data 119,127,255
' Colour Value 159
Data 129,232,254
' Colour Value 160
Data 75,44,13
' Colour Value 161
Data 75,62,19
' Colour Value 162
Data 75,90,28
' Colour Value 163
Data 85,167,45
' Colour Value 164
Data 91,48,34
' Colour Value 165
Data 90,70,43
' Colour Value 166
Data 91,102,55
' Colour Value 167
Data 100,185,84
' Colour Value 168
Data 115,55,75
' Colour Value 169
Data 113,79,91
' Colour Value 170
Data 114,115,114
' Colour Value 171
Data 124,207,166
' Colour Value 172
Data 171,60,232
' Colour Value 173
Data 169,93,255
' Colour Value 174
Data 169,141,255
' Colour Value 175
Data 173,249,254
' Colour Value 176
Data 170,47,33
' Colour Value 177
Data 167,71,39
' Colour Value 178
Data 164,106,48
' Colour Value 179
Data 165,193,73
' Colour Value 180
Data 200,53,58
' Colour Value 181
Data 196,80,70
' Colour Value 182
Data 192,118,87
' Colour Value 183
Data 193,212,128
' Colour Value 184
Data 239,60,115
' Colour Value 185
Data 237,89,136
' Colour Value 186
Data 233,132,167
' Colour Value 187
Data 233,234,233
' Colour Value 188
Data 245,73,255
' Colour Value 189
Data 246,112,255
' Colour Value 190
Data 248,164,255
' Colour Value 191
Data 255,255,255
' Colour Value 192
Data 48,69,3
' Colour Value 193
Data 51,95,2
' Colour Value 194
Data 59,134,0
' Colour Value 195
Data 85,234,0
' Colour Value 196
Data 59,78,5
' Colour Value 197
Data 62,105,7
' Colour Value 198
Data 70,149,11
' Colour Value 199
Data 96,255,26
' Colour Value 200
Data 74,89,28
' Colour Value 201
Data 77,121,35
' Colour Value 202
Data 84,168,45
' Colour Value 203
Data 105,255,72
' Colour Value 204
Data 112,113,112
' Colour Value 205
Data 115,150,134
' Colour Value 206
Data 123,207,163
' Colour Value 207
Data 133,255,230
' Colour Value 208
Data 71,74,4
' Colour Value 209
Data 73,101,2
' Colour Value 210
Data 78,144,2
' Colour Value 211
Data 100,248,0
' Colour Value 212
Data 86,84,10
' Colour Value 213
Data 88,113,15
' Colour Value 214
Data 92,159,22
' Colour Value 215
Data 111,255,37
' Colour Value 216
Data 108,97,36
' Colour Value 217
Data 108,129,44
' Colour Value 218
Data 114,180,57
' Colour Value 219
Data 125,255,88
' Colour Value 220
Data 158,122,135
' Colour Value 221
Data 159,160,159
' Colour Value 222
Data 164,218,192
' Colour Value 223
Data 167,255,254
' Colour Value 224
Data 114,82,7
' Colour Value 225
Data 113,111,9
' Colour Value 226
Data 116,157,10
' Colour Value 227
Data 129,255,16
' Colour Value 228
Data 136,93,23
' Colour Value 229
Data 135,124,28
' Colour Value 230
Data 137,173,33
' Colour Value 231
Data 145,255,52
' Colour Value 232
Data 166,106,49
' Colour Value 233
Data 164,140,59
' Colour Value 234
Data 166,194,74
' Colour Value 235
Data 168,255,111
' Colour Value 236
Data 233,130,165
' Colour Value 237
Data 231,172,193
' Colour Value 238
Data 233,234,233
' Colour Value 239
Data 227,255,255
' Colour Value 240
Data 237,94,31
' Colour Value 241
Data 235,128,32
' Colour Value 242
Data 232,182,34
' Colour Value 243
Data 230,255,46
' Colour Value 244
Data 241,106,42
' Colour Value 245
Data 242,143,48
' Colour Value 246
Data 246,198,58
' Colour Value 247
Data 251,255,86
' Colour Value 248
Data 242,122,77
' Colour Value 249
Data 244,162,92
' Colour Value 250
Data 248,224,113
' Colour Value 251
Data 252,255,164
' Colour Value 252
Data 247,151,231
' Colour Value 253
Data 251,199,255
' Colour Value 254
Data 255,255,255
' Colour Value 255
Data 255,255,255

' My scanned values
' Colour Value 0
Data 5,6,12
' Colour Value 1
Data 9,9,14
' Colour Value 2
Data 18,38,51
' Colour Value 3
Data 37,138,169
' Colour Value 4
Data 24,12,20
' Colour Value 5
Data 32,22,43
' Colour Value 6
Data 47,68,135
' Colour Value 7
Data 70,134,185
' Colour Value 8
Data 90,31,77
' Colour Value 9
Data 88,45,126
' Colour Value 10
Data 71,63,177
' Colour Value 11
Data 55,110,213
' Colour Value 12
Data 100,39,193
' Colour Value 13
Data 86,50,206
' Colour Value 14
Data 78,65,229
' Colour Value 15
Data 73,101,239
' Colour Value 16
Data 29,9,13
' Colour Value 17
Data 37,19,18
' Colour Value 18
Data 60,62,70
' Colour Value 19
Data 71,151,172
' Colour Value 20
Data 77,27,37
' Colour Value 21
Data 92,50,69
' Colour Value 22
Data 95,90,144
' Colour Value 23
Data 93,139,181
' Colour Value 24
Data 130,49,96
' Colour Value 25
Data 126,64,138
' Colour Value 26
Data 110,79,180
' Colour Value 27
Data 87,122,210
' Colour Value 28
Data 134,51,192
' Colour Value 29
Data 117,60,209
' Colour Value 30
Data 107,74,229
' Colour Value 31
Data 102,112,240
' Colour Value 32
Data 85,21,20
' Colour Value 33
Data 100,50,31
' Colour Value 34
Data 122,100,76
' Colour Value 35
Data 117,166,157
' Colour Value 36
Data 138,54,51
' Colour Value 37
Data 143,87,75
' Colour Value 38
Data 140,114,130
' Colour Value 39
Data 129,146,172
' Colour Value 40
Data 155,73,94
' Colour Value 41
Data 152,93,127
' Colour Value 42
Data 143,108,173
' Colour Value 43
Data 127,140,202
' Colour Value 44
Data 163,70,182
' Colour Value 45
Data 156,80,203
' Colour Value 46
Data 144,93,224
' Colour Value 47
Data 137,131,237
' Colour Value 48
Data 195,55,36
' Colour Value 49
Data 201,88,44
' Colour Value 50
Data 198,125,96
' Colour Value 51
Data 178,173,162
' Colour Value 52
Data 185,92,72
' Colour Value 53
Data 180,118,98
' Colour Value 54
Data 177,135,140
' Colour Value 55
Data 168,154,175
' Colour Value 56
Data 184,107,115
' Colour Value 57
Data 179,121,138
' Colour Value 58
Data 173,132,174
' Colour Value 59
Data 167,156,200
' Colour Value 60
Data 194,97,182
' Colour Value 61
Data 200,107,204
' Colour Value 62
Data 198,118,225
' Colour Value 63
Data 193,154,236
' Colour Value 64
Data 15,13,17
' Colour Value 65
Data 24,35,24
' Colour Value 66
Data 46,83,53
' Colour Value 67
Data 69,148,132
' Colour Value 68
Data 51,34,32
' Colour Value 69
Data 71,74,56
' Colour Value 70
Data 81,105,111
' Colour Value 71
Data 90,137,154
' Colour Value 72
Data 102,54,71
' Colour Value 73
Data 98,79,106
' Colour Value 74
Data 93,101,151
' Colour Value 75
Data 83,133,184
' Colour Value 76
Data 114,61,166
' Colour Value 77
Data 102,72,184
' Colour Value 78
Data 93,85,208
' Colour Value 79
Data 91,124,226
' Colour Value 80
Data 47,21,18
' Colour Value 81
Data 64,59,29
' Colour Value 82
Data 83,103,61
' Colour Value 83
Data 94,154,137
' Colour Value 84
Data 97,57,44
' Colour Value 85
Data 110,88,64
' Colour Value 86
Data 114,113,115
' Colour Value 87
Data 116,140,157
' Colour Value 88
Data 131,75,84
' Colour Value 89
Data 130,93,108
' Colour Value 90
Data 124,107,148
' Colour Value 91
Data 111,138,179
' Colour Value 92
Data 140,73,162
' Colour Value 93
Data 134,83,182
' Colour Value 94
Data 124,95,208
' Colour Value 95
Data 119,134,225
' Colour Value 96
Data 105,51,29
' Colour Value 97
Data 117,92,38
' Colour Value 98
Data 126,127,61
' Colour Value 99
Data 125,158,124
' Colour Value 100
Data 133,85,55
' Colour Value 101
Data 139,104,65
' Colour Value 102
Data 141,119,101
' Colour Value 103
Data 143,145,157
' Colour Value 104
Data 148,99,85
' Colour Value 105
Data 146,112,104
' Colour Value 106
Data 142,127,143
' Colour Value 107
Data 133,150,176
' Colour Value 108
Data 155,93,157
' Colour Value 109
Data 157,103,174
' Colour Value 110
Data 157,114,203
' Colour Value 111
Data 151,150,220
' Colour Value 112
Data 194,86,36
' Colour Value 113
Data 189,117,43
' Colour Value 114
Data 182,142,78
' Colour Value 115
Data 171,169,137
' Colour Value 116
Data 165,111,72
' Colour Value 117
Data 166,125,82
' Colour Value 118
Data 166,135,119
' Colour Value 119
Data 169,154,166
' Colour Value 120
Data 171,123,103
' Colour Value 121
Data 169,134,119
' Colour Value 122
Data 165,141,150
' Colour Value 123
Data 159,162,184
' Colour Value 124
Data 180,120,162
' Colour Value 125
Data 189,123,182
' Colour Value 126
Data 195,137,204
' Colour Value 127
Data 196,167,219
' Colour Value 128
Data 30,51,26
' Colour Value 129
Data 43,96,36
' Colour Value 130
Data 59,127,53
' Colour Value 131
Data 73,155,112
' Colour Value 132
Data 74,80,47
' Colour Value 133
Data 89,104,59
' Colour Value 134
Data 92,116,93
' Colour Value 135
Data 103,141,148
' Colour Value 136
Data 112,91,71
' Colour Value 137
Data 109,106,90
' Colour Value 138
Data 105,119,129
' Colour Value 139
Data 97,144,164
' Colour Value 140
Data 117,94,153
' Colour Value 141
Data 113,104,170
' Colour Value 142
Data 104,117,197
' Colour Value 143
Data 100,156,215
' Colour Value 144
Data 66,73,30
' Colour Value 145
Data 75,108,37
' Colour Value 146
Data 84,135,56
' Colour Value 147
Data 89,155,113
' Colour Value 148
Data 101,92,49
' Colour Value 149
Data 111,108,58
' Colour Value 150
Data 114,126,97
' Colour Value 151
Data 119,146,153
' Colour Value 152
Data 132,100,76
' Colour Value 153
Data 128,113,95
' Colour Value 154
Data 122,121,130
' Colour Value 155
Data 119,152,168
' Colour Value 156
Data 138,106,154
' Colour Value 157
Data 141,114,170
' Colour Value 158
Data 132,130,200
' Colour Value 159
Data 126,162,217
' Colour Value 160
Data 112,104,37
' Colour Value 161
Data 113,130,41
' Colour Value 162
Data 121,150,56
' Colour Value 163
Data 123,171,108
' Colour Value 164
Data 132,113,56
' Colour Value 165
Data 134,121,62
' Colour Value 166
Data 137,134,91
' Colour Value 167
Data 141,157,154
' Colour Value 168
Data 145,114,74
' Colour Value 169
Data 146,127,90
' Colour Value 170
Data 138,133,127
' Colour Value 171
Data 139,163,170
' Colour Value 172
Data 158,120,146
' Colour Value 173
Data 164,131,165
' Colour Value 174
Data 165,146,193
' Colour Value 175
Data 156,177,217
' Colour Value 176
Data 186,127,38
' Colour Value 177
Data 178,149,41
' Colour Value 178
Data 176,165,69
' Colour Value 179
Data 166,185,125
' Colour Value 180
Data 163,128,62
' Colour Value 181
Data 157,137,76
' Colour Value 182
Data 159,148,114
' Colour Value 183
Data 166,170,166
' Colour Value 184
Data 164,132,91
' Colour Value 185
Data 164,141,111
' Colour Value 186
Data 163,152,145
' Colour Value 187
Data 169,179,181
' Colour Value 188
Data 187,140,155
' Colour Value 189
Data 197,148,171
' Colour Value 190
Data 202,164,201
' Colour Value 191
Data 201,192,221
' Colour Value 192
Data 67,132,36
' Colour Value 193
Data 63,155,40
' Colour Value 194
Data 76,169,51
' Colour Value 195
Data 87,178,86
' Colour Value 196
Data 98,130,54
' Colour Value 197
Data 110,140,66
' Colour Value 198
Data 120,149,90
' Colour Value 199
Data 121,164,140
' Colour Value 200
Data 124,128,63
' Colour Value 201
Data 125,140,77
' Colour Value 202
Data 123,156,116
' Colour Value 203
Data 117,178,160
' Colour Value 204
Data 150,146,130
' Colour Value 205
Data 146,160,154
' Colour Value 206
Data 138,169,185
' Colour Value 207
Data 129,193,213
' Colour Value 208
Data 98,144,38
' Colour Value 209
Data 93,162,42
' Colour Value 210
Data 99,175,52
' Colour Value 211
Data 106,187,89
' Colour Value 212
Data 126,143,57
' Colour Value 213
Data 131,152,69
' Colour Value 214
Data 134,157,92
' Colour Value 215
Data 133,177,146
' Colour Value 216
Data 138,137,66
' Colour Value 217
Data 136,149,83
' Colour Value 218
Data 139,166,119
' Colour Value 219
Data 133,186,165
' Colour Value 220
Data 167,154,135
' Colour Value 221
Data 167,166,157
' Colour Value 222
Data 164,177,190
' Colour Value 223
Data 156,198,217
' Colour Value 224
Data 131,161,44
' Colour Value 225
Data 126,176,46
' Colour Value 226
Data 132,188,56
' Colour Value 227
Data 130,199,89
' Colour Value 228
Data 148,155,57
' Colour Value 229
Data 147,164,71
' Colour Value 230
Data 151,171,97
' Colour Value 231
Data 147,186,145
' Colour Value 232
Data 151,150,70
' Colour Value 233
Data 151,161,83
' Colour Value 234
Data 157,176,112
' Colour Value 235
Data 156,199,163
' Colour Value 236
Data 187,165,127
' Colour Value 237
Data 189,179,151
' Colour Value 238
Data 190,190,188
' Colour Value 239
Data 183,208,217
' Colour Value 240
Data 189,173,44
' Colour Value 241
Data 187,189,51
' Colour Value 242
Data 190,200,64
' Colour Value 243
Data 182,215,107
' Colour Value 244
Data 188,168,58
' Colour Value 245
Data 183,177,72
' Colour Value 246
Data 178,187,103
' Colour Value 247
Data 174,200,157
' Colour Value 248
Data 179,163,80
' Colour Value 249
Data 180,173,91
' Colour Value 250
Data 187,188,125
' Colour Value 251
Data 193,212,175
' Colour Value 252
Data 214,175,137
' Colour Value 253
Data 218,188,161
' Colour Value 254
Data 220,199,197
' Colour Value 255
Data 215,215,224

