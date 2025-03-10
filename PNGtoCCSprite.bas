' Sprint Compiler

VersionNumber$ = "0.01"
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

Dim RGB As Long

Dim pal(16) As Long
Dim CoCo3Pal$(16)
Dim Sprite$(150)

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

CoCo3_Palette$ = "CoCo3_Palette.asm"
Open CoCo3_Palette$ For Append As #1
length = LOF(1)
Close #1
If length < 1 Then
    Print "No "; CoCo3_Palette$; " file found in this folder, will use default CoCo3 Palette."
    'Convert CoCo 3 RGB colour values to 24 bit RGB values
    'CoCo 3 RGB format is xxRGBrgb
    CoCo3Pal$(0) = "%00111111" '      * 0 - White"
    CoCo3Pal$(1) = "%00100100" '       * 1 - Red"
    CoCo3Pal$(2) = "%00010010" '       * 2 - Green"
    CoCo3Pal$(3) = "%00001001" '       * 3 - Blue"
    CoCo3Pal$(4) = "%00100000" '       * 4 - Mid Red"
    CoCo3Pal$(5) = "%00010000" '       * 5 - Mid Green"
    CoCo3Pal$(6) = "%00001000" '       * 6 - Mid Blue"
    CoCo3Pal$(7) = "%00110100" '       * 7 - Orange"
    CoCo3Pal$(8) = "%00110110" '       * 8 - Yellow/Gold"
    CoCo3Pal$(9) = "%00100011" '       * 9 - Brown"
    CoCo3Pal$(10) = "%00001100" '      * A - Purple"
    CoCo3Pal$(11) = "%00011011" '      * B - Cyan"
    CoCo3Pal$(12) = "%00101101" '      * C - Magenta"
    CoCo3Pal$(13) = "%00111000" '      * D - Light Gray"
    CoCo3Pal$(14) = "%00000111" '      * E - Dark Gray"
    CoCo3Pal$(15) = "%00000000" '       * F - Black"
    Print "0 - White"
    Print "1 - Red"
    Print "2 - Green"
    Print "3 - Blue"
    Print "4 - Mid Red"
    Print "5 - Mid Green"
    Print "6 - Mid Blue"
    Print "7 - Orange"
    Print "8 - Yellow/Gold"
    Print "9 - Brown"
    Print "A - Purple"
    Print "B - Cyan"
    Print "C - Magenta"
    Print "D - Light Gray"
    Print "E - Dark Gray"
    Print "F - Black"
    Print
Else
    Print "Found "; CoCo3_Palette$; ", will use this Palette info when generating compiled sprites."
    Open CoCo3_Palette$ For Input As #1
    X = 0
    While X < 16
        Input #1, I$
        If Left$(I$, 1) = "*" Or Left$(I$, 1) = ";" Then
            'Skip, this line is a comment
        Else
            p = InStr(I$, "%")
            '            Print Mid$(I$, p, 9)
            CoCo3Pal$(X) = Mid$(I$, p, 9)
            p = InStr(I$, "*")
            Print Right$(I$, Len(I$) - p)
            X = X + 1
        End If
    Wend
    Close #1
End If
For X = 0 To 15
    test$ = CoCo2RGB$(CoCo3Pal$(X))
    pal(X) = Val("&H" + test$)
Next X

Dim array(5000000) As _Byte
Tab$ = String$(8, " ") ' tab space in output
FI = 0
count = _CommandCount
If count > 0 Then GoTo 100
99 Print "Sprite Compiler v"; VersionNumber$; " by Glen Hewlett"
Print
Print "Usage: SpriteCompiler -gGmode [-nNAME] [-bx] [-c] [-j] [-v#] InName.png"
Print "Where:"
Print "InName.png is a 32 bit (includes transparency) png filename"
Print "-gGmode - Gmode is the GMODE # the basic program will use to draw the created sprite"
Print "-bx option handles the way the sprite handles the graphics behind the sprite."
Print "-b0     - No backup or restore of the data behind the sprite will be done, this is the fastest but it makes a destructive sprite"
Print "-b1     - (default) Add code that will restore the background behind the sprite using the data from the next GMODE screen"
Print "-c      - Create a bitmap file for use with collison detection"
Print "-j      - Join the files into one"
Print "-d      - Include code to delete the sprite with palette 15"
Print "-t      - Make a Sprite using TFM, without transparencies using consistant LDQ #$ and TFM U+,D+ commands"
Print "-v#     - Set verbose level while generating compiled sprite (where # is 0 to 3)"
System
100 nt = 0: newp = 0: endp = 0: t = 0: o1 = 0: A = 0: TFM = 0
Verbose = 0
SaveRestoreBackground = 0
Join = 0
Delete = 0
Gmode = -1
For check = 1 To count
    N$ = Command$(check)
    If LCase$(Left$(N$, 2)) = "-g" Then Gmode = Val(Right$(N$, Len(N$) - 2)): GoTo 120
    '    If LCase$(Left$(N$, 2)) = "-n" Then CodeName$ = Right$(N$, Len(N$) - 2): GoTo 120
    If LCase$(Left$(N$, 2)) = "-b" Then SaveRestoreBackground = Val(Right$(N$, 1)): GoTo 120
    If LCase$(Left$(N$, 2)) = "-c" Then Collision = 1: GoTo 120
    If LCase$(Left$(N$, 2)) = "-j" Then Join = 1: GoTo 120
    If LCase$(Left$(N$, 2)) = "-d" Then Delete = 1: GoTo 120
    If LCase$(Left$(N$, 2)) = "-t" Then TFM = 1: GoTo 120
    If LCase$(Left$(N$, 2)) = "-v" Then Verbose = Val(Right$(N$, 1)): GoTo 120
    ' check if we got a file name yet if so then the next filename will be output
    If FI > 0 Then FName$ = N$: GoTo 120
    FI = 1
    FName$ = N$
    Open FName$ For Append As #1
    length = LOF(1)
    Close #1
    If length < 1 Then Print "Error file: "; FName$; " is 0 bytes. Or doesn't exits.": Kill FName$: End
    Print "Length of Input file is:"; length; " = $"; Hex$(length)
    GoTo 200
    Open FName$ For Binary As #1
    Get #1, , array()
    length = LOF(1)
    Close #1
120 Next check
Outname$ = FName$ + ".asm"
200
If SaveRestoreBackground > 1 Then SaveRestoreBackground = 1
If Gmode = -1 Then Print "ERROR: Must use -gGmode to provide a Gmode # to be used in the compiled BASIC program": GoTo 99
If Verbose > 0 Then
    If Verbose > 3 Then Verbose = 3
    If Verbose < 0 Then Verbose = 0
    Print "Verbose level set to:"; v
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
Screen _NewImage(640, 480, 32)

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
For Y = 0 To imageHeight - 1
    For X = 0 To imageWidth - 1
        pixelColors(X, Y) = Point(X, Y) ' Long values 32 bit colour
        ' Format of the long values in hex is AARRGGBB where AA is the Alpha value, 00 is tranparent, FF is full intensity
        '                                              RR,GG,BB are 8 bit values of the colours Red,Green,Blue
    Next X
Next Y

' Free the memory for the image
_FreeImage myImage
_Dest _Console
' Optionally Display some pixel info (use a limited range to avoid flooding)
If Verbose > 2 Then
    For Y = 0 To imageHeight - 1
        For X = 0 To imageWidth - 1
            Print Right$("00000000" + Hex$(pixelColors(X, Y)), 8); ",";
        Next X
        Print
    Next Y
End If

Dim PixVal As Long
Dim Temp As Single
Temp = Int(imageWidth / 8)
If Temp = imageWidth / 8 Then
    SpWidth = imageWidth
Else
    SpWidth = (Int(imageWidth / 8) + 1) * 8
End If
Dim SpriteOriginal$(SpWidth + 8, imageHeight)
Print "Image dimensions: Width"; imageWidth; ", Height"; imageHeight
For Y = 0 To imageHeight - 1
    For X = 0 To imageWidth - 1
        Pixel$ = Right$("00000000" + Hex$(pixelColors(X, Y)), 8)
        PixVal = Val("&H" + Mid$(Pixel$, 3, 2)) * 65536
        PixVal = PixVal + Val("&H" + Mid$(Pixel$, 5, 2)) * 256
        PixVal = PixVal + Val("&H" + Mid$(Pixel$, 7, 2))
        If PixVal > 0 Then Bit$ = "1" Else Bit$ = "0"
        If Val("&H" + Left$(Pixel$, 2)) < 127 Then Bit$ = "T"
        SpriteOriginal$(X, Y) = Bit$
    Next X
Next Y
Print "01234567";
Print "01234567";
Print "01234567";
Print "01234567";
Print "01234567";
Print "01234567";
Print "01234567";
Print "01234567"
For Y = 0 To imageHeight - 1
    For X = 0 To imageWidth - 1
        Print SpriteOriginal$(X, Y);
    Next X
    Print
Next Y
If SpWidth > imageWidth Then
    For Y = 0 To imageHeight - 1
        For X = imageWidth To SpWidth
            SpriteOriginal$(X, Y) = "T"
        Next X
    Next Y
End If
Print "SpWidth"; SpWidth
Print "01234567";
Print "01234567";
Print "01234567";
Print "01234567";
Print "01234567";
Print "01234567";
Print "01234567";
Print "01234567"
For Y = 0 To imageHeight - 1
    If Y = 25 Then
        Print
        Print "01234567";
        Print "01234567";
        Print "01234567";
        Print "01234567";
        Print "01234567";
        Print "01234567";
        Print "01234567";
        Print "01234567"
    End If
    For X = 0 To SpWidth - 1
        Print SpriteOriginal$(X, Y);
    Next X
    Print
Next Y

ScreenWidth = Val(GModeMaxX$(Gmode)) + 1
ScreenSize = Val("&H" + GModeScreenSize$(Gmode))
Print "Screenwidth="; ScreenWidth
Print "Colours used in GMODE #"; Gmode; "is "; GModeColours$(Gmode)
Print "bytes per row is"; ScreenWidth / 8
If GModeColours$(Gmode) <> "2" Then
    Print "Can only handle two colour sprites so far"
    System
End If
Print "FNameNoExt$= "; FNameNoExt$
imageWidth = SpWidth

TotalCycles = 0
If SaveRestoreBackground = 1 Then GoSub SaveRestoreBack ' write .asm file with code to save and restore the graphics data behind this sprite
TotalCycles = 0
Dim Pixels(imageWidth - 1, imageHeight - 1) As _Byte
Dim CopyOfPixels(imageWidth - 1, imageHeight - 1) As _Byte ' Copy of the Pixel Array
Dim OrigPixels(imageWidth - 1, imageHeight - 1) As _Byte ' Copy of the Pixel Array

DrawBytesPerRow = (SpWidth / 8)

XPos = 0: YPos = 0 ' Sprite drawing location in bytes (not pixels)
OldXPos = 0: OldYPos = 0 ' Used to caclulate LEAU and ABX values

Outname$ = FNameNoExt$ + ".asm"
Open Outname$ For Output As #2
Print #2, "; Sprite data for "; FNameNoExt$
Print #2, "; Enter with X pointing at the memory location on screen to draw the sprite"
Print #2, "; Sprite Width is:"; DrawBytesPerRow; "Bytes to draw before shifting"
Print #2, "; Height is:"; imageHeight; "Rows"

Print #2, FNameNoExt$ + "_Width:"
n = DrawBytesPerRow + 1: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
Instr1$ = "FCB": Instr2$ = N$: Com$ = "Max width in Bytes after shifting 7 times": GoSub DoOutput ' Print the output to file #2
Print #2, FNameNoExt$ + "_Height:"
n = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
Instr1$ = "FCB": Instr2$ = N$: Com$ = "Hieght in pixels": GoSub DoOutput ' Print the output to file #2

For Y = 0 To imageHeight - 1
    n = Y: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    Print #2, "; "; Right$("000" + N$, 3); " ";
    For X = 0 To SpWidth - 1
        Print #2, SpriteOriginal$(X, Y);
    Next X
    Print #2,
Next Y

Print #2, FNameNoExt$ + "_Restore:"
If DrawBytesPerRow + 1 >= 4 Then
    ' Stack blast erase from source of next GMODE screen
    Instr1$ = "PSHS": Instr2$ = "CC,DP": Com$ = "Backup the CC & DP": GoSub DoOutput ' Print the output to file #2
    Instr1$ = "ORCC": Instr2$ = "#%10010000": Com$ = "Disable the interrupts": GoSub DoOutput ' Print the output to file #2
    Instr1$ = "STS": Instr2$ = "@RestoreStack+2": Com$ = "Save the stack below (self mod)": GoSub DoOutput ' Print the output to file #2

    n = -(ScreenWidth / 8) - (DrawBytesPerRow + 1): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    SMove$ = N$ ' Amount to move S after blasting a row
    n = ScreenSize + ((imageHeight - 1) * (ScreenWidth / 8)): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    Instr1$ = "LEAS": Instr2$ = N$ + ",X": Com$ = "Move to the left edge of the bottom row of the next screen, this is the source": GoSub DoOutput ' Print the output to file #2
    UMove = (imageHeight - 1) * (ScreenWidth / 8)
    '    n = UMove: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    '    Instr1$ = "LEAU": Instr2$ = N$ + ",X": Com$ = "Move to the left edge of the bottom row of the destination": GoSub DoOutput ' Print the output to file #2

    RowStart = 0
    DoneFirstU = 0
    '    UMove = 0
    For row = 0 To imageHeight - 1
        NewLine = 1
        Print #2, "; Doing row"; row
        CopySize = DrawBytesPerRow + 1
        While CopySize > 0
            Select Case CopySize
                Case 1
                    UMove = UMove + CopySize
                    n = UMove: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                    If DoneFirstU = 0 Then
                        DoneFirstU = 1
                        Instr1$ = "LEAU": Instr2$ = N$ + ",X": Com$ = "Move to the correct starting location": GoSub DoOutput ' Print the output to file #2
                    Else
                        Instr1$ = "LEAU": Instr2$ = N$ + ",U": Com$ = "Move to the correct location": GoSub DoOutput ' Print the output to file #2
                    End If
                    Instr1$ = "PULS": Instr2$ = "A": Com$ = "Read" + Str$(CopySize) + " bytes": GoSub DoOutput ' Print the output to file #2
                    Instr1$ = "PSHU": Instr2$ = "A": Com$ = "Write" + Str$(CopySize) + " bytes": GoSub DoOutput ' Print the output to file #2
                    UMove = -(ScreenWidth / 8) - (DrawBytesPerRow + 1) + CopySize
                    CopySize = 0
                Case 2
                    UMove = UMove + CopySize
                    n = UMove: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                    If DoneFirstU = 0 Then
                        DoneFirstU = 1
                        Instr1$ = "LEAU": Instr2$ = N$ + ",X": Com$ = "Move to the correct starting location": GoSub DoOutput ' Print the output to file #2
                    Else
                        Instr1$ = "LEAU": Instr2$ = N$ + ",U": Com$ = "Move to the correct location": GoSub DoOutput ' Print the output to file #2
                    End If
                    Instr1$ = "PULS": Instr2$ = "D": Com$ = "Read" + Str$(CopySize) + " bytes": GoSub DoOutput ' Print the output to file #2
                    Instr1$ = "PSHU": Instr2$ = "D": Com$ = "Write" + Str$(CopySize) + " bytes": GoSub DoOutput ' Print the output to file #2
                    UMove = -(ScreenWidth / 8) - (DrawBytesPerRow + 1) + CopySize
                    CopySize = 0
                Case 3
                    UMove = UMove + CopySize
                    n = UMove: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                    If DoneFirstU = 0 Then
                        DoneFirstU = 1
                        Instr1$ = "LEAU": Instr2$ = N$ + ",X": Com$ = "Move to the correct starting location": GoSub DoOutput ' Print the output to file #2
                    Else
                        Instr1$ = "LEAU": Instr2$ = N$ + ",U": Com$ = "Move to the correct location": GoSub DoOutput ' Print the output to file #2
                    End If
                    Instr1$ = "PULS": Instr2$ = "A,X": Com$ = "Read" + Str$(CopySize) + " bytes": GoSub DoOutput ' Print the output to file #2
                    Instr1$ = "PSHU": Instr2$ = "A,X": Com$ = "Write" + Str$(CopySize) + " bytes": GoSub DoOutput ' Print the output to file #2
                    UMove = -(ScreenWidth / 8) - (DrawBytesPerRow + 1) + CopySize
                    CopySize = 0
                Case 4
                    UMove = UMove + CopySize
                    n = UMove: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                    If DoneFirstU = 0 Then
                        DoneFirstU = 1
                        Instr1$ = "LEAU": Instr2$ = N$ + ",X": Com$ = "Move to the correct starting location": GoSub DoOutput ' Print the output to file #2
                    Else
                        Instr1$ = "LEAU": Instr2$ = N$ + ",U": Com$ = "Move to the correct location": GoSub DoOutput ' Print the output to file #2
                    End If
                    Instr1$ = "PULS": Instr2$ = "D,X": Com$ = "Read" + Str$(CopySize) + " bytes": GoSub DoOutput ' Print the output to file #2
                    Instr1$ = "PSHU": Instr2$ = "D,X": Com$ = "Write" + Str$(CopySize) + " bytes": GoSub DoOutput ' Print the output to file #2
                    UMove = -(ScreenWidth / 8) - (DrawBytesPerRow + 1) + CopySize
                    CopySize = 0
                Case 5
                    UMove = UMove + CopySize
                    n = UMove: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                    If DoneFirstU = 0 Then
                        DoneFirstU = 1
                        Instr1$ = "LEAU": Instr2$ = N$ + ",X": Com$ = "Move to the correct starting location": GoSub DoOutput ' Print the output to file #2
                    Else
                        Instr1$ = "LEAU": Instr2$ = N$ + ",U": Com$ = "Move to the correct location": GoSub DoOutput ' Print the output to file #2
                    End If
                    Instr1$ = "PULS": Instr2$ = "A,X,Y": Com$ = "Read" + Str$(CopySize) + " bytes": GoSub DoOutput ' Print the output to file #2
                    Instr1$ = "PSHU": Instr2$ = "A,X,Y": Com$ = "Write" + Str$(CopySize) + " bytes": GoSub DoOutput ' Print the output to file #2
                    UMove = -(ScreenWidth / 8) - (DrawBytesPerRow + 1) + CopySize
                    CopySize = 0
                Case 6
                    UMove = UMove + CopySize
                    n = UMove: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                    If DoneFirstU = 0 Then
                        DoneFirstU = 1
                        Instr1$ = "LEAU": Instr2$ = N$ + ",X": Com$ = "Move to the correct starting location": GoSub DoOutput ' Print the output to file #2
                    Else
                        Instr1$ = "LEAU": Instr2$ = N$ + ",U": Com$ = "Move to the correct location": GoSub DoOutput ' Print the output to file #2
                    End If
                    Instr1$ = "PULS": Instr2$ = "D,X,Y": Com$ = "Read" + Str$(CopySize) + " bytes": GoSub DoOutput ' Print the output to file #2
                    Instr1$ = "PSHU": Instr2$ = "D,X,Y": Com$ = "Write" + Str$(CopySize) + " bytes": GoSub DoOutput ' Print the output to file #2
                    UMove = -(ScreenWidth / 8) - (DrawBytesPerRow + 1) + CopySize
                    CopySize = 0
                Case 7
                    UMove = UMove + CopySize
                    n = UMove: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                    If DoneFirstU = 0 Then
                        DoneFirstU = 1
                        Instr1$ = "LEAU": Instr2$ = N$ + ",X": Com$ = "Move to the correct starting location": GoSub DoOutput ' Print the output to file #2
                    Else
                        Instr1$ = "LEAU": Instr2$ = N$ + ",U": Com$ = "Move to the correct location": GoSub DoOutput ' Print the output to file #2
                    End If
                    Instr1$ = "PULS": Instr2$ = "D,DP,X,Y": Com$ = "Read" + Str$(CopySize) + " bytes": GoSub DoOutput ' Print the output to file #2
                    Instr1$ = "PSHU": Instr2$ = "D,DP,X,Y": Com$ = "Write" + Str$(CopySize) + " bytes": GoSub DoOutput ' Print the output to file #2
                    UMove = -(ScreenWidth / 8) - (DrawBytesPerRow + 1) + CopySize
                    CopySize = 0
                Case Is > 7
                    If NewLine = 1 Then
                        UMove = UMove + 7
                        NewLine = 0
                    Else
                        UMove = 7
                    End If
                    n = UMove: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                    If DoneFirstU = 0 Then
                        DoneFirstU = 1
                        Instr1$ = "LEAU": Instr2$ = N$ + ",X": Com$ = "Move to the correct starting location": GoSub DoOutput ' Print the output to file #2
                    Else
                        Instr1$ = "LEAU": Instr2$ = N$ + ",U": Com$ = "Move to the correct location": GoSub DoOutput ' Print the output to file #2
                    End If

                    Instr1$ = "PULS": Instr2$ = "D,DP,X,Y": Com$ = "Read 7 bytes": GoSub DoOutput ' Print the output to file #2
                    Instr1$ = "PSHU": Instr2$ = "D,DP,X,Y": Com$ = "Write 7 bytes": GoSub DoOutput ' Print the output to file #2
                    UMove = 7
                    CopySize = CopySize - 7
            End Select
        Wend
        If row <> imageHeight - 1 Then
            '  n = DrawBytesPerRow + (ScreenWidth / 8): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
            Instr1$ = "LEAS": Instr2$ = SMove$ + ",S": Com$ = "Move to the right edge of the next row down": GoSub DoOutput ' Print the output to file #2
        End If
    Next row
    Print #2, "@RestoreStack"
    Instr1$ = "LDS": Instr2$ = "#$FFFF": Com$ = "Restore the stack value (self modded above)": GoSub DoOutput ' Print the output to file #2
    Instr1$ = "PULS": Instr2$ = "CC,DP,PC": Com$ = "Restore the Condition Codes & DP and return": GoSub DoOutput ' Print the output to file #2
    Print #2,
Else
    ' Do restore using LOAD and STORE
    n = ScreenWidth / 8: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    Instr1$ = "LDB": Instr2$ = "#" + N$: Com$ = "B=value to move X down a row at a time": GoSub DoOutput ' Print the output to file #2
    n = ScreenSize: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    Instr1$ = "LEAY": Instr2$ = N$ + ",X": Com$ = "Y points at the source screen for row" + Str$(row): GoSub DoOutput ' Print the output to file #2
    For row = 0 To imageHeight - 1
        Select Case DrawBytesPerRow + 1
            Case 2
                Instr1$ = "LDU": Instr2$ = ",Y": Com$ = "Get U": GoSub DoOutput ' Print the output to file #2
                Instr1$ = "STU": Instr2$ = ",X": Com$ = "Store U": GoSub DoOutput ' Print the output to file #2
            Case 3
                Instr1$ = "LDU": Instr2$ = ",Y": Com$ = "Get U": GoSub DoOutput ' Print the output to file #2
                Instr1$ = "STU": Instr2$ = ",X": Com$ = "Store U": GoSub DoOutput ' Print the output to file #2
                Instr1$ = "LDA": Instr2$ = "2,Y": Com$ = "Get A": GoSub DoOutput ' Print the output to file #2
                Instr1$ = "STA": Instr2$ = "2,X": Com$ = "Store A": GoSub DoOutput ' Print the output to file #2
        End Select
        If row <> imageHeight - 1 Then
            n = DrawBytesPerRow + (ScreenWidth / 8): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
            Instr1$ = "ABX": Com$ = "Move X down a row": GoSub DoOutput ' Print the output to file #2
            n = ScreenWidth / 8: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
            Instr1$ = "LEAY": Instr2$ = N$ + ",Y": Com$ = "Y points at the source screen for row" + Str$(row): GoSub DoOutput ' Print the output to file #2
        End If
    Next row
    Instr1$ = "RTS": Com$ = "Return": GoSub DoOutput ' Print the output to file #2
End If

GoTo TryABX

TryABX:
For SpriteShift = 0 To 7 ' This will go from 0 to 7 to generate the 8 sprites needed based on its position
    n = SpriteShift: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    If N$ = "" Then N$ = "0"
    Print #2, FNameNoExt$ + "_" + N$ + ":"
    '    Print #2, ";               1         2         3         4         5         6         7"
    '    Print #2, ";     012345678901234567890123456789012345678901234567890123456789012345678901"
    '    Print #2, ";     000000001111111122222222333333334444444455555555666666667777777788888888"
    '    For Y = 0 To imageHeight - 1
    '        n = Y: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    '        Print #2, "; "; Right$("000" + N$, 3); " ";
    '        For X = 0 To SpWidth - 1
    '            Print #2, SpriteOriginal$(X, Y);
    '        Next X
    '        Print #2,
    '    Next Y
    Select Case SpriteShift:
        Case 1 To 7
            If SpriteOriginal$(SpWidth - 1, 0) = "T" Then
                'Shift it right, strip the T off the right and don't increase the SpWidth
                ' Shift sprite to the right, Add a T to the left
                For row = 0 To imageHeight - 1
                    row$ = "T"
                    For X = 0 To SpWidth - 1
                        row$ = row$ + SpriteOriginal$(X, row)
                    Next X
                    For X = 0 To SpWidth - 1
                        SpriteOriginal$(X, row) = Mid$(row$, X + 1, 1)
                    Next X
                Next row
            Else
                For row = 0 To imageHeight - 1
                    row$ = "T"
                    For X = 0 To SpWidth - 1
                        row$ = row$ + SpriteOriginal$(X, row)
                    Next X
                    For X = 0 To SpWidth
                        SpriteOriginal$(X, row) = Mid$(row$, X + 1, 1)
                    Next X
                    For X = SpWidth + 1 To SpWidth + 7
                        SpriteOriginal$(X, row) = "T"
                    Next X
                Next row
                SpWidth = SpWidth + 8
            End If
    End Select
    ' Draw Sprite
    LastA$ = ""
    LastU$ = ""
    n = (ScreenWidth / 8): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    For i = 7 To 0 Step -1
        If (n And (2 ^ i)) > 0 Then
            B$ = B$ + "1"
        Else
            B$ = B$ + "0"
        End If
    Next i
    LastB$ = B$
    Instr1$ = "LDB": Instr2$ = "#" + N$: Com$ = "Amount to move down the screen to the next row": GoSub DoOutput ' Print the output to file #2
    For row = 0 To imageHeight - 1
        Print #2, "; Row"; row
        row$ = ""
        For X = 0 To SpWidth - 1
            row$ = row$ + SpriteOriginal$(X, row)
        Next X
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
            If InStr(Mid$(row$, j, 8), "x") = 0 Then
                ' found a byte to process
                n = (j - 1) / 8: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                If InStr(Mid$(row$, j, 8), "T") > 0 Then
                    ' This byte has some transparency to deal with
                    Temp0$ = ""
                    Mask0$ = ""
                    For X = 1 To 8
                        If Mid$(Mid$(row$, j, 8), X, 1) = "T" Then
                            Temp0$ = Temp0$ + "0"
                            Mask0$ = Mask0$ + "1"
                        Else
                            Temp0$ = Temp0$ + Mid$(Mid$(row$, j, 8), X, 1)
                            Mask0$ = Mask0$ + "0"
                        End If
                    Next X
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
        Next j



        n = DrawBytesPerRow + (ScreenWidth / 8): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        If row <> imageHeight - 1 Then
            Instr1$ = "ABX": Com$ = "Move down a row": GoSub DoOutput ' Print the output to file #2
        End If
    Next row
    Instr1$ = "RTS": Com$ = "Done drawing the sprite, Return": GoSub DoOutput ' Print the output to file #2
Next SpriteShift
Close #2
System

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



For SpriteShift = 0 To 7 ' This will go from 0 to 7 to generate the 8 sprites needed based on its position
    n = SpriteShift: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    Print #2, FNameNoExt$ + "_" + N$ + ":"
    ' Draw Sprite
    LastA$ = ""
    LastB$ = ""
    LastX$ = ""
    LastY$ = ""
    For row = 0 To imageHeight - 1
        row$ = ""
        ByteCount = 0
        C = DrawBytesPerRow - 1
        Print #2, "; Row"; row
        While C >= 0
            ' Check to see if we have any transparent bits to handle
            Temp0$ = ""
            Mask0$ = ""
            n = ByteCount: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
            If N$ <> "" Then N$ = "-" + N$
            Transparency0 = 0
            For X = 0 To 7
                If SpriteOriginal$(C * 8 + X, row) = "T" Then
                    Transparency0 = 1
                    Temp0$ = Temp0$ + "0"
                    Mask0$ = Mask0$ + "1"
                Else
                    Temp0$ = Temp0$ + SpriteOriginal$(C * 8 + X, row)
                    Mask0$ = Mask0$ + "0"
                End If
            Next X
            C = C - 1
            If C >= 0 Then
                ' Check to see if we have any transparent bits to handle
                Temp1$ = ""
                Mask1$ = ""
                Transparency1 = 0
                For X = 0 To 7
                    If SpriteOriginal$(C * 8 + X, row) = "T" Then
                        Transparency1 = 1
                        Temp1$ = Temp1$ + "0"
                        Mask1$ = Mask1$ + "1"
                    Else
                        Temp1$ = Temp1$ + SpriteOriginal$(C * 8 + X, row)
                        Mask1$ = Mask1$ + "0"
                    End If
                Next X
                C = C - 1
                If Transparency1 = 1 And Transparency0 = 1 Then
                    ' Both A & B bits have transparencies
                    Instr1$ = "LDD": Instr2$ = "#%" + Mask1$ + Mask0$: Com$ = "Get the masks into A & B": GoSub DoOutput ' Print the output to file #2
                    Instr1$ = "ANDA": Instr2$ = N$ + "-2,U": Com$ = "Get the background into transparent bits into A": GoSub DoOutput ' Print the output to file #2
                    Instr1$ = "ANDB": Instr2$ = N$ + "-1,U": Com$ = "Get the background into transparent bits into B": GoSub DoOutput ' Print the output to file #2
                    Instr1$ = "ORA": Instr2$ = "#%" + Temp1$: Com$ = "Get the non transparent bits into A": GoSub DoOutput ' Print the output to file #2
                    Instr1$ = "ORB": Instr2$ = "#%" + Temp0$: Com$ = "Get the non transparent bits into B": GoSub DoOutput ' Print the output to file #2
                    LastA$ = ""
                    LastB$ = ""
                    GoSub PSHU
                Else
                    If Transparency0 = 1 Then
                        ' Only B has transparencies
                        Instr1$ = "LDD": Instr2$ = "#%" + Temp1$ + Mask0$: Com$ = "Get the sprite in A and the mask in B": GoSub DoOutput ' Print the output to file #2
                        Instr1$ = "ANDB": Instr2$ = N$ + "-1,U": Com$ = "Get the background into transparent bits into B": GoSub DoOutput ' Print the output to file #2
                        Instr1$ = "ORB": Instr2$ = "#%" + Temp0$: Com$ = "Get the non transparent bits into B": GoSub DoOutput ' Print the output to file #2
                        LastB$ = ""
                        GoSub PSHU
                    Else
                        If Transparency1 = 1 Then
                            Instr1$ = "LDD": Instr2$ = "#%" + Mask1$ + Temp0$: Com$ = "Get the mask in A and the sprite in B": GoSub DoOutput ' Print the output to file #2
                            Instr1$ = "ANDA": Instr2$ = N$ + "-2,U": Com$ = "Get the background into transparent bits into A": GoSub DoOutput ' Print the output to file #2
                            Instr1$ = "ORA": Instr2$ = "#%" + Temp1$: Com$ = "Get the non transparent bits into A": GoSub DoOutput ' Print the output to file #2
                            LastA$ = ""
                            GoSub PSHU
                        Else
                            ' Neither have transparancies
                            If ByteCount = 0 Then
                                Temp2$ = Temp0$
                                Temp3$ = Temp1$
                            End If
                            If ByteCount = 2 Then
                                Temp4$ = Temp2$
                                Temp5$ = Temp3$
                                Temp2$ = Temp0$
                                Temp3$ = Temp1$
                            End If
                            ByteCount = ByteCount + 2
                            If ByteCount = 6 Then
                                If LastA$ = Temp1$ And LastB$ <> Temp0$ Then
                                    Instr1$ = "LDB": Instr2$ = "#%" + Temp0$: Com$ = "Load B with Sprite data": GoSub DoOutput ' Print the output to file #2
                                    LastB$ = Temp0$
                                End If
                                If LastA$ <> Temp1$ And LastB$ = Temp0$ Then
                                    Instr1$ = "LDA": Instr2$ = "#%" + Temp1$: Com$ = "Load A with Sprite data": GoSub DoOutput ' Print the output to file #2
                                    LastA$ = Temp1$
                                End If
                                If LastA$ <> Temp1$ And LastB$ <> Temp0$ Then
                                    Instr1$ = "LDD": Instr2$ = "#%" + Temp1$ + Temp0$: Com$ = "Load D with Sprite data": GoSub DoOutput ' Print the output to file #2
                                    LastA$ = Temp1$
                                    LastB$ = Temp0$
                                End If
                                GoSub PSHU
                            End If
                        End If
                    End If
                End If
            Else
                ' Last byte left so only do B
                If Transparency0 = 1 Then
                    ' Only B has transparencies
                    Instr1$ = "LDB": Instr2$ = "#%" + Mask0$: Com$ = "Get the sprite in mask in B": GoSub DoOutput ' Print the output to file #2
                    Instr1$ = "ANDB": Instr2$ = "-1,U": Com$ = "Get the background into transparent bits into B": GoSub DoOutput ' Print the output to file #2
                    Instr1$ = "ORB": Instr2$ = "#%" + Temp0$: Com$ = "Get the non transparent bits into B": GoSub DoOutput ' Print the output to file #2
                    LastB$ = ""
                    GoSub PSHU_EndB
                Else
                    If LastB$ <> "#%" + Temp0$ Then
                        Instr1$ = "LDB": Instr2$ = "#%" + Temp0$: Com$ = "Load B with Sprite data": GoSub DoOutput ' Print the output to file #2
                        LastB$ = "#%" + Temp0$
                    End If
                    GoSub PSHU_EndB
                End If
            End If
        Wend
        If ByteCount > 0 Then GoSub PSHU_End
        n = DrawBytesPerRow + (ScreenWidth / 8): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        If row <> imageHeight - 1 Then
            Instr1$ = "LEAU": Instr2$ = N$ + ",U": Com$ = "Move to the right edge of the next row down": GoSub DoOutput ' Print the output to file #2
        End If
    Next row
    Instr1$ = "RTS": Com$ = "Done drawing the sprite, Return": GoSub DoOutput ' Print the output to file #2
Next SpriteShift


Close #2

System

PSHU:
If ByteCount = 0 Then
    Instr1$ = "PSHU": Instr2$ = "D": Com$ = "Write A & B on screen and move pointer left 2 bytes": GoSub DoOutput ' Print the output to file #2
Else
    If ByteCount = 2 Then
        If LastX$ <> "#%" + Temp3$ + Temp2$ Then
            Instr1$ = "LDX": Instr2$ = "#%" + Temp3$ + Temp2$: Com$ = "Load X with Sprite data": GoSub DoOutput ' Print the output to file #2
            LastX$ = "#%" + Temp3$ + Temp2$
        End If
        Instr1$ = "PSHU": Instr2$ = "D,X": Com$ = "Write A & B & X on screen and move pointer left 4 bytes": GoSub DoOutput ' Print the output to file #2
    Else
        If LastX$ <> "#%" + Temp3$ + Temp2$ Then
            Instr1$ = "LDX": Instr2$ = "#%" + Temp3$ + Temp2$: Com$ = "Load X with Sprite data": GoSub DoOutput ' Print the output to file #2
            LastX$ = "#%" + Temp3$ + Temp2$
        End If
        If LastY$ <> "#%" + Temp5$ + Temp4$ Then
            Instr1$ = "LDY": Instr2$ = "#%" + Temp5$ + Temp4$: Com$ = "Load Y with Sprite data": GoSub DoOutput ' Print the output to file #2
            LastY$ = "#%" + Temp5$ + Temp4$
        End If
        Instr1$ = "PSHU": Instr2$ = "D,X,Y": Com$ = "Write A & B & X & Y on screen and move pointer left 6 bytes": GoSub DoOutput ' Print the output to file #2
    End If
End If
ByteCount = 0
Return

PSHU_End:
If ByteCount = 2 Then
    If LastA$ <> Temp3$ And LastB$ <> Temp2$ Then
        Instr1$ = "LDD": Instr2$ = "#%" + Temp3$ + Temp2$: Com$ = "Load D with Sprite data": GoSub DoOutput ' Print the output to file #2
        LastD$ = "#%" + Temp3$ + Temp2$
    Else
        If LastA$ = Temp3$ And LastB$ <> Temp2$ Then
            Instr1$ = "LDB": Instr2$ = "#%" + Temp2$: Com$ = "Load B with Sprite data": GoSub DoOutput ' Print the output to file #2
        End If
        If LastA$ <> Temp3$ And LastB$ = Temp2$ Then
            Instr1$ = "LDA": Instr2$ = "#%" + Temp3$: Com$ = "Load A with Sprite data": GoSub DoOutput ' Print the output to file #2
        End If
    End If
    Instr1$ = "PSHU": Instr2$ = "D": Com$ = "Write A & B on screen and move pointer left 2 bytes": GoSub DoOutput ' Print the output to file #2
Else
    If LastD$ <> "#%" + Temp3$ + Temp2$ Then
        Instr1$ = "LDD": Instr2$ = "#%" + Temp3$ + Temp2$: Com$ = "Load D with Sprite data": GoSub DoOutput ' Print the output to file #2
        LastD$ = "#%" + Temp3$ + Temp2$
    End If
    If LastX$ <> "#%" + Temp5$ + Temp4$ Then
        Instr1$ = "LDX": Instr2$ = "#%" + Temp1$ + Temp0$: Com$ = "Load X with Sprite data": GoSub DoOutput ' Print the output to file #2
        LastX$ = "#%" + Temp5$ + Temp4$
    End If
    Instr1$ = "PSHU": Instr2$ = "D,X": Com$ = "Write A & B & X  on screen and move pointer left 4 bytes": GoSub DoOutput ' Print the output to file #2
End If
ByteCount = 0
Return

PSHU_EndB:
If ByteCount = 0 Then
    Instr1$ = "PSHU": Instr2$ = "B": Com$ = "Write B on screen and move pointer left 2 bytes": GoSub DoOutput ' Print the output to file #2
Else
    If ByteCount = 2 Then
        If LastX$ <> "#%" + Temp3$ + Temp2$ Then
            Instr1$ = "LDX": Instr2$ = "#%" + Temp3$ + Temp2$: Com$ = "Load X with Sprite data": GoSub DoOutput ' Print the output to file #2
            LastX$ = "#%" + Temp3$ + Temp2$
        End If
        Instr1$ = "PSHU": Instr2$ = "B,X": Com$ = "Write B & X on screen and move pointer left 4 bytes": GoSub DoOutput ' Print the output to file #2
    Else
        If LastX$ <> "#%" + Temp3$ + Temp2$ Then
            Instr1$ = "LDX": Instr2$ = "#%" + Temp3$ + Temp2$: Com$ = "Load X with Sprite data": GoSub DoOutput ' Print the output to file #2
            LastX$ = "#%" + Temp3$ + Temp2$
        End If
        If LastY$ <> "#%" + Temp5$ + Temp4$ Then
            Instr1$ = "LDY": Instr2$ = "#%" + Temp5$ + Temp4$: Com$ = "Load Y with Sprite data": GoSub DoOutput ' Print the output to file #2
            LastY$ = "#%" + Temp5$ + Temp4$
        End If
        Instr1$ = "PSHU": Instr2$ = "B,X,Y": Com$ = "Write B & X & Y on screen and move pointer left 6 bytes": GoSub DoOutput ' Print the output to file #2
    End If
End If
ByteCount = 0
Return






XPos = 0: YPos = 0 ' Sprite drawing location in bytes (not pixels)
OldXPos = 0: OldYPos = 0 ' Used to caclulate LEAU and ABX values
Outname$ = FNameNoExt$ + "_Backup" + ".asm"
Open Outname$ For Output As #2
' Backup the Bytes behind the sprite
Print #2, "; Backup Sprite data for "; FNameNoExt$
Print #2, "; Enter with U pointing at the memory location on screen to backup the data behind the sprite"
Print #2, "; Sprite Width is:"; BytesPerRowToBackup; "Bytes, one extra byte to backup for shifted start location"
Print #2, "; Height is:"; imageHeight; "Rows"
Print #2, FNameNoExt$ + "_BackupStart:"
n = BytesPerRowToBackup: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
Instr1$ = "RMB": Instr2$ = N$ + "*"
n = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
Instr2$ = Instr2$ + N$ + "+32": Com$ = "Reserve space for sprite background, plus an extra 32 bytes just incase an Interrupt occurs": GoSub DoOutput ' Print the output to file #2
Print #2, FNameNoExt$ + "_BackupEnd:"
Print #2, "Backup_" + FNameNoExt$ + ":"
Instr1$ = "STS": Instr2$ = "@SaveSHere+2": Com$ = "Backup the stack pointer's value at the end of the backup routine (self mod)": GoSub DoOutput ' Print the output to file #2
Instr1$ = "LDS": Instr2$ = "#" + FNameNoExt$ + "_BackupEnd": Com$ = "Set S pointer to the end of the backup buffer": GoSub DoOutput ' Print the output to file #2
For Y = 0 To imageHeight - 1
    Print #2, "; Backup row"; Y
    bcopy = BytesPerRowToBackup 'number of bytes to copy per row
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
        Instr1$ = "PULU": Instr2$ = "X,Y": Com$ = "Get four bytes from the screen": GoSub DoOutput ' Print the output to file #2
        Instr1$ = "PSHS": Instr2$ = "X,Y": Com$ = "Save four bytes from the screen": GoSub DoOutput ' Print the output to file #2
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
    If Y <> imageHeight - 1 Then
        n = ScreenWidth / 8: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr1$ = "LEAU": Instr2$ = N$
        n = BytesPerRowToBackup: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = Instr2$ + "-" + N$ + ",U": Com$ = "Move down to the start of the next row to copy": GoSub DoOutput ' Print the output to file #2
    End If
Next Y
Print #2, "@SaveSHere"
Instr1$ = "LDS": Instr2$ = "#$FFFF": Com$ = "Self mod restore stack pointer": GoSub DoOutput ' Print the output to file #2
Instr1$ = "RTS": Com$ = "Return": GoSub DoOutput ' Print the output to file #2
Print #2,
Close #2


' Do this once normally, then do again with all the coloured bits will be $F which is black as an erase sprite
DoneSprite = 0
While DoneSprite < 2
    TotalCycles = 0
    If DoneSprite = 1 Then
        SaveRestoreBackground = 0 ' No need to do this code, the second time
        Collision = 0 ' No need to do bitmap the second time
    End If
    TotalCycles = 0
    EvenOdd$ = "Even" ' First we do the even sprite
    DoSprite:
    FName$ = FileName$ + EvenOdd$
    FNameNoExt$ = CodeName$ + "_" + EvenOdd$
    'N = imageWidth: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    ' Filename without the extension
    ' FNameNoExt$
    'SpriteName$ = CodeName$ + "_" + N$ + "x"
    'N = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    'SpriteName$ = SpriteName$ + N$ + "_" + EvenOdd$ + ":"
    If DoneSprite = 1 Then
        SpriteName$ = CodeName$ + "_" + EvenOdd$ + "_Erase:"
    Else
        SpriteName$ = CodeName$ + "_" + EvenOdd$ + ":"
    End If
    If DoneSprite = 1 Then
        ' We are going through 2nd pass now so the nibbles were shifted to the right to do the odd pixels, if this is the Even pass then shift everything to the left
        '  Back to normal
        If EvenOdd$ = "Even" Then
            For Y = 0 To imageHeight - 1
                For X = 0 To imageWidth - 2
                    pixelColors(X, Y) = pixelColors(X + 1, Y) ' Shift the nibbles
                Next X
                pixelColors(imageWidth - 1, Y) = 0 ' Right most pixel is transparent and no colours
            Next Y
        End If
    End If
    If EvenOdd$ <> "Even" Then
        ' We've done the even sprite, let's shift the data and do the odd sprite
        For Y = 0 To imageHeight - 1
            For X = imageWidth - 2 To 0 Step -1
                pixelColors(X + 1, Y) = pixelColors(X, Y) ' Shift the nibbles
            Next X
            pixelColors(0, Y) = 0 ' Left most pixel is transparent and no colours
        Next Y
    End If
    For Y = 0 To imageHeight - 1
        For X = 0 To imageWidth - 1
            'Print "Pix="; Hex$(pixelColors(x, y))
            If Int(pixelColors(X, Y) / 16777216) = 0 Then
                ' Transparent pixel
                CCPal = 16
            Else
                ' Non Transparent pixel
                RGB = pixelColors(X, Y) And 16777215
                ' Convert 24 bit RGB value to CoCo 3 palette number to use
                ' Input 24 bit colour value in variable named RGB
                ' Output CoCo 3 Palette number in CCPal
                GoSub ConvertRGB2CoCo3Palette
            End If
            If DoneSprite = 1 Then If CCPal < 16 Then CCPal = 15 ' making the second pass write out sprite with background colour of 15
            Pixels(X, Y) = CCPal
            CopyOfPixels(X, Y) = CCPal 'Backup to keep track of which pixels have been used for the compiled sprite as we progress
            OrigPixels(X, Y) = CCPal 'Backup copy
        Next X
    Next Y
    If TFM = 1 Then GoTo DoTFM
    If DoneSprite = 1 Then
        ' If left or right nibble is $F then make the byte $FF, so we don't have to test for nibble's with transparencies, just restore the byte to background colour
        For Y = 0 To imageHeight - 1
            For X = 0 To imageWidth - 1 Step 2
                If Pixels(X, Y) = 15 Or Pixels(X + 1, Y) = 15 Then
                    Pixels(X, Y) = 15: Pixels(X + 1, Y) = 15
                    CopyOfPixels(X, Y) = 15: CopyOfPixels(X + 1, Y) = 15 'Backup to keep track of which pixels have been used for the compiled sprite as we progress
                    OrigPixels(X, Y) = 15: OrigPixels(X + 1, Y) = 15 'Backup copy
                End If
            Next X
        Next Y
    End If
    ' Include bitmap info if -c option is selected
    If Collision = 1 Then
        'Create a bitmap data file useful for collision detection
        Outname$ = CodeName$ + "_Bitmap" + EvenOdd$ + ".asm"
        Open Outname$ For Output As #2
        Print #2, CodeName$; "_Bitmap_"; EvenOdd$; ":"
        For Y = 0 To imageHeight - 1
            Instr1$ = "FCB": BitMap$ = ""
            For X = 0 To imageWidth - 1 Step 2
                If Int(pixelColors(X, Y) / 16777216) = 0 Then
                    ' Transparent pixel
                    BitMap$ = BitMap$ + "$0"
                Else
                    ' Non Transparent pixel
                    BitMap$ = BitMap$ + "$F"
                End If
                'Odd pixel
                If Int(pixelColors(X + 1, Y) / 16777216) = 0 Then
                    ' Transparent pixel
                    BitMap$ = BitMap$ + "0"
                Else
                    ' Non Transparent pixel
                    BitMap$ = BitMap$ + "F"
                End If
                BitMap$ = BitMap$ + ","
            Next X
            Instr2$ = Left$(BitMap$, Len(BitMap$) - 1)
            GoSub DoOutput ' Print the output
        Next Y
        If EvenOdd$ = "Odd" Then Print #2, CodeName$; "_End:"
        Close #2
    End If

    GoSub ShowSpriteOnScreen
    '*** Do blast method and one TFR X,W
    Do1TfrXW = 1 ' Add a TFR X,W command so we have a chance of doing STQs
    DoTFRMany = 0 ' Do a TFR when we do a LDX #
    ignoreValue = 16 ' This value or above will be ignored in patterns
    ' Clear the register values
    A$ = "": B$ = "": E$ = "": F$ = "": X$ = "": Y$ = "": U$ = ""
    XPos = 0: YPos = 0 ' Sprite drawing location in bytes (not pixels)
    OldXPos = 0: OldYPos = 0 ' Used to caclulate LEAU and ABX values
    Outname$ = FName$ + "_BlastLDST_TFR" + ".asm"
    Open Outname$ For Output As #2
    ' Draw the sprite to the file
    GoSub ShowSpriteInFile
    Print #2, SpriteName$
    TotalCycles = 0
    Print "Doing TFR Once Blasting/Load/Store Method"
    GoSub DoBlastingMethod
    BlastingTFRCycles = TotalCycles 'record Blasting TFR cycles
    Print "Done TFR Once Blasting/Load/Store Method"
    Print "Cycle Count is:"; BlastingTFRCycles
    ' Restore values to test stack blasting
    For Y = 0 To imageHeight - 1
        For X = 0 To imageWidth - 1
            Pixels(X, Y) = OrigPixels(X, Y)
            CopyOfPixels(X, Y) = OrigPixels(X, Y) 'Backup to keep track of which pixels have been used for the compiled sprite as we progress
        Next X
    Next Y

    '*** Do blast method only
    Do1TfrXW = 0 ' Don't add a TFR X,W command so we have a chance of doing STQs
    DoTFRMany = 0 ' Don't a TFR when we do a LDX #
    ignoreValue = 16 ' This value or above will be ignored in patterns
    ' Clear the register values
    A$ = "": B$ = "": E$ = "": F$ = "": X$ = "": Y$ = "": U$ = ""
    XPos = 0: YPos = 0 ' Sprite drawing location in bytes (not pixels)
    OldXPos = 0: OldYPos = 0 ' Used to caclulate LEAU and ABX values
    Outname$ = FName$ + "_BlastLDST" + ".asm"
    Open Outname$ For Output As #2
    ' Draw the sprite to the file
    GoSub ShowSpriteInFile
    Print #2, SpriteName$
    TotalCycles = 0
    Print "Doing Blasting/Load/Store Method"
    GoSub DoBlastingMethod
    BlastingCycles = TotalCycles 'record Blasting cycles
    Print "Done Blasting/Load/Store Method"
    Print "Cycle Count is:"; BlastingCycles
    ' Restore values to test with only doing Load/Store, no stack blasting
    For Y = 0 To imageHeight - 1
        For X = 0 To imageWidth - 1
            Pixels(X, Y) = OrigPixels(X, Y)
            CopyOfPixels(X, Y) = OrigPixels(X, Y) 'Backup to keep track of which pixels have been used for the compiled sprite as we progress
        Next X
    Next Y

    '*** Do blast method and TFR everytime we do a LDX #
    Do1TfrXW = 0 ' Don't add a TFR X,W command so we have a chance of doing STQs
    DoTFRMany = 1 ' Do a TFR when we do a LDX #
    ignoreValue = 16 ' This value or above will be ignored in patterns
    ' Clear the register values
    A$ = "": B$ = "": E$ = "": F$ = "": X$ = "": Y$ = "": U$ = ""
    XPos = 0: YPos = 0 ' Sprite drawing location in bytes (not pixels)
    OldXPos = 0: OldYPos = 0 ' Used to caclulate LEAU and ABX values
    Outname$ = FName$ + "_BlastLDST_TFR_Many" + ".asm"
    Open Outname$ For Output As #2
    ' Draw the sprite to the file
    Print "Doing Many TFR X,W - Blasting/Load/Store Method"
    GoSub ShowSpriteInFile
    Print #2, SpriteName$
    TotalCycles = 0
    GoSub DoBlastingMethod
    BlastingTFRManyCycles = TotalCycles 'record Blasting TFR cycles
    Print "Done Many TFR X,W - Blasting/Load/Store Method"
    Print "Cycle Count is:"; BlastingTFRManyCycles

    ' Do LD/St method
    FastestX = 999999
    For XPoint = 0 To imageWidth - 1 Step 2
        TotalCycles = 0
        GoSub FindBestX
        Print "TotalCycles="; TotalCycles, "Midpoint"; Midpoint
        If TotalCycles < FastestX Then
            FastestX = TotalCycles
            FastestXPos = Midpoint
        End If
    Next XPoint
    Print "FastestX="; FastestX, "FastestXPos"; FastestXPos
    'Set XPoint to the fastest method found and do that as the best Store method
    XPoint = FastestXPos * 2
    GoSub FindBestX

    Print "Done Load/Store Method"
    Print "Cycle Count is:"; TotalCycles
    'BlastingCycles = 1000
    'BlastingTFRCycles = 1000
    'BlastingTFRManyCycles = 1000
    Print "One TFR Blasting/Load/Store   uses:"; BlastingTFRCycles
    Print "Blasting/Load/Store           uses:"; BlastingCycles
    Print "Many TFRs Blasting/Load/Store uses:"; BlastingTFRManyCycles
    Print "Load/Store                    uses:"; TotalCycles

    If BlastingTFRCycles <= TotalCycles And BlastingTFRCycles <= BlastingCycles And BlastingTFRCycles <= BlastingTFRManyCycles Then
        'Keep One TFR/Load/Store version
        Kill FName$ + "_JustLDST" + ".asm"
        Kill FName$ + "_BlastLDST" + ".asm"
        Kill FName$ + "_BlastLDST_TFR_Many" + ".asm"
        Name FName$ + "_BlastLDST_TFR" + ".asm" As FName$ + ".asm"
        fastest = BlastingTFRCycles
        Print "TFR - Blasting/Load/Store method is the fastest"
        GoTo GotFastest
    End If
    If BlastingCycles <= TotalCycles And BlastingCycles <= BlastingTFRCycles And BlastingCycles <= BlastingTFRManyCycles Then
        'Keep Blasted version
        Kill FName$ + "_JustLDST" + ".asm"
        Kill FName$ + "_BlastLDST_TFR" + ".asm"
        Kill FName$ + "_BlastLDST_TFR_Many" + ".asm"
        Name FName$ + "_BlastLDST" + ".asm" As FName$ + ".asm"
        fastest = BlastingCycles
        Print "Blasting/Load/Store method is the fastest"
        GoTo GotFastest
    End If
    If TotalCycles <= BlastingCycles And TotalCycles <= BlastingTFRCycles And TotalCycles <= BlastingTFRManyCycles Then
        'Keep LD/ST version
        Kill FName$ + "_BlastLDST" + ".asm"
        Kill FName$ + "_BlastLDST_TFR" + ".asm"
        Kill FName$ + "_BlastLDST_TFR_Many" + ".asm"
        Name FName$ + "_JustLDST" + ".asm" As FName$ + ".asm"
        fastest = TotalCycles
        Print "Load/Store method is the fastest"
        GoTo GotFastest
    End If
    If BlastingTFRManyCycles <= BlastingTFRCycles And BlastingTFRManyCycles <= BlastingCycles And BlastingTFRManyCycles <= TotalCycles Then
        'Keep TFR Many Blasted version
        Kill FName$ + "_BlastLDST" + ".asm"
        Kill FName$ + "_BlastLDST_TFR" + ".asm"
        Kill FName$ + "_JustLDST" + ".asm"
        Name FName$ + "_BlastLDST_TFR_Many" + ".asm" As FName$ + ".asm"
        fastest = BlastingTFRManyCycles
        Print "Load/Store method is the fastest"
        GoTo GotFastest
    End If
    GotFastest:
    Print fastest; " * 30 fps ="; fastest * 30
    Print "Output filename is: "; FName$ + ".asm"

    If EvenOdd$ <> "Odd" Then
        'Do the sprite again with the pixels shifted to the right one nibble
        EvenOdd$ = "Odd"
        GoTo DoSprite
    End If

    Outname$ = CodeName$ + ".asm"
    'N = imageWidth: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    'Outname$ = Outname$ + N$ + "x"
    'N = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    'Outname$ = Outname$ + N$ + ".asm"
    Open "ReserveSpace.asm" For Output As #2
    Print #2, "; Reserve space to save the background behind the sprite"
    'Background$ = "Background_" + CodeName$ + "_"
    'N = imageWidth: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    'Background$ = Background$ + N$ + "x"
    'N = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    'Background$ = Background$ + N$ + ":"
    Background$ = "Background_" + CodeName$ + ":"
    Print #2, Background$
    Instr1$ = "RMB"
    n = imageWidth: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    Instr2$ = "50+(" + N$ + "/2)*"
    Com$ = "50 bytes for stack space just in case an irq happens, sprite width of " + N$ + "/2 * height of "
    n = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    Instr2$ = Instr2$ + N$
    Com$ = Com$ + N$
    GoSub DoOutput ' Print the output
    Print #2,
    Close #2
    File0$ = "ReserveSpace.asm"
    File1$ = CodeName$ + ".pngEven.asm"
    File2$ = CodeName$ + ".pngOdd.asm"
    n = imageWidth: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    File3$ = "SaveReBack_" + CodeName$ + "_" + N$ + "x"
    n = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    File3$ = File3$ + N$ + ".asm"
    File4$ = CodeName$ + "_Bitmap" + "Even.asm"
    File5$ = CodeName$ + "_Bitmap" + "Odd.asm"

    InFiles$ = File1$ + " " + File2$
    If DoneSprite = 1 Then
        ' Make a new file with the info
        ' SpriteName$ = CodeName$ + "_" + EvenOdd$ + "_Erase:"
        Open "TempFile0.asm" For Output As #2
        Print #2, CodeName$ + "_Start:"
        Instr1$ = "FDB": Instr2$ = CodeName$ + "_Even": Com$ = "Address of Code to Draw Even srite": GoSub DoOutput ' Print the output to file #2
        Instr1$ = "FDB": Instr2$ = CodeName$ + "_Odd": Com$ = "Address of Code to Draw Odd srite": GoSub DoOutput ' Print the output to file #2
        Instr1$ = "FDB": Instr2$ = CodeName$ + "_Bitmap_Even": Com$ = "Address of Bitmap data of Even srite": GoSub DoOutput ' Print the output to file #2
        Instr1$ = "FDB": Instr2$ = CodeName$ + "_Bitmap_Odd": Com$ = "Address of Bitmap data of Odd srite": GoSub DoOutput ' Print the output to file #2
        Instr1$ = "FDB": Instr2$ = CodeName$ + "_Even_Erase": Com$ = "Address of Code to Erase Even srite": GoSub DoOutput ' Print the output to file #2
        Instr1$ = "FDB": Instr2$ = CodeName$ + "_Odd_Erase": Com$ = "Address of Code to Erase Odd srite": GoSub DoOutput ' Print the output to file #2
        ' Write the width and height info to the file as filename_WH:
        Print #2, CodeName$; "_WH:"
        Instr1$ = "FCB"
        n = Int(imageWidth / 2): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$
        Com$ = "Width in bytes of this sprite": GoSub DoOutput ' Print the output
        Instr1$ = "FCB"
        n = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$
        Com$ = "Height of this sprite": GoSub DoOutput ' Print the output
        Print #2, CodeName$; "_W";
        Instr1$ = "EQU"
        n = Int(imageWidth / 2): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$
        Com$ = "Width in bytes of this sprite": GoSub DoOutput ' Print the output
        Print #2, CodeName$; "_H";
        Instr1$ = "EQU"
        n = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$
        Com$ = "Height of this sprite": GoSub DoOutput ' Print the output
        Close #2
        Shell "cat " + "TempFile0.asm " + ThisFile$ + " " + InFiles$ + " > TempFile1.asm"
        Kill "TempFile0.asm"
        Kill ThisFile$
        Name "TempFile1.asm" As ThisFile$
    Else
        If Join = 1 Then
            ' Join the files together
            InFiles$ = File1$ + " " + File2$
            If SaveRestoreBackground = 1 Then
                InFiles$ = InFiles$ + " " + File3$
            End If
            If Collision = 1 Then
                InFiles$ = InFiles$ + " " + File4$ + " " + File5$
            End If
            Shell "cat " + InFiles$ + " > " + Outname$
            ThisFile$ = Outname$
        End If
    End If
    Kill File0$
    Kill File1$
    Kill File2$
    If SaveRestoreBackground = 1 Then
        Kill File3$
    End If
    If Collision = 1 Then
        Kill File4$
        Kill File5$
    End If
    DoneSprite = DoneSprite + 1
Wend
System

DoBlastingMethod:
PatternSize = 12
' Loop through the patterns
'Make sure the pattern size is 4 or more

LEAUCount = 0 ' the first LEAU is an LEAU ,X the rest are LEAU ,U

While PatternSize > 3
    If Verbose > 0 Then Print "Finding the next largest and most common pattern, PatternSize="; PatternSize
    ' GoSub ShowUpdatedSprite 'Show the current sprite data - in array CopyOfPixels()
    For Y = 0 To imageHeight - 1
        For X = 0 To imageWidth - 1
            Pixels(X, Y) = CopyOfPixels(X, Y)
        Next X
    Next Y
    ' We now have the sprite in the array Pixels()
    'Let's look for duplicate patterns that are 12 nibbles/pixels long we can push them on screen as 6 bytes (PSHU D,X,Y)
    For patternLength = PatternSize To 2 Step -2
        ' Set the starting point in the array
        For Y = 0 To imageHeight - 1 ' Test through all the rows
            For X = 0 To imageWidth - 1 Step 2 'Test through all the columns, even number columns only
                ' Get the pattern to match against
                For i = 0 To patternLength - 1
                    If X + i > imageWidth - 1 Then GoTo SkipChecking
                    If Pixels(X + i, Y) > 15 Then PatternCount = 0: GoTo NoCheck 'If any value is invalid then don't check the pattern
                    Pattern(i) = Pixels(X + i, Y)
                    ' Mark these pixels as now unusable
                    Pixels(X + i, Y) = 17
                Next i
                SkipChecking:
                GoSub CheckForPattern ' Go count the # of times this pattern is in the array, return with count in variable PatternCount
                '    If PatternCount > 0 Then Print PatternCount
                NoCheck:
                patternFrequency(patternLength, X, Y) = PatternCount
                ' Restore Pixels array
                For y1 = 0 To imageHeight - 1
                    For x1 = 0 To imageWidth - 1
                        Pixels(x1, y1) = CopyOfPixels(x1, y1) ' Backup copy
                    Next x1
                Next y1
            Next X
        Next Y
    Next patternLength

    ' Find the most frequently repeated pattern of the greatest length
    CountDown = PatternSize
    NextBiggestPattern:
    maxFrequency = 0
    For patternLength = CountDown To 2 Step -2 ' Check larger patterns first
        For Y = 0 To imageHeight - 1 ' Test through all the rows
            For X = 0 To imageWidth - patternLength - 1 Step 2 'Test through all the columns, even number columns only
                If patternFrequency(patternLength, X, Y) > maxFrequency Then
                    maxFrequency = patternFrequency(patternLength, X, Y)
                    maxPatternLength = patternLength
                    maxPatternRow = Y
                    maxPatternStartCol = X
                End If
            Next X
        Next Y
        If maxFrequency > 0 Then Exit For ' Exit if the most repeated pattern is found
    Next patternLength

    ' Output the result
    If maxFrequency > 0 Then
        'maxFrequency value is actually one higher
        maxFrequency = maxFrequency + 1
        If Verbose > 1 Then
            Print "Most frequent pattern length: "; maxPatternLength
            Print "Starts at row: "; maxPatternRow; ", column: "; maxPatternStartCol
            Print "Frequency: "; maxFrequency
            Print "Pattern is:";
            For i = 0 To maxPatternLength - 1
                Pattern(i) = Pixels(maxPatternStartCol + i, maxPatternRow)
                Print Hex$(Pattern(i));
            Next i
            Print
        Else
            For i = 0 To maxPatternLength - 1
                Pattern(i) = Pixels(maxPatternStartCol + i, maxPatternRow)
            Next i
        End If
    Else
        If Verbose > 1 Then Print "No repeating patterns found."
        maxPatternLength = 0
    End If
    Print "got here"; maxPatternLength, "maxFrequency"; maxFrequency
    If maxPatternLength < 5 Then GoTo DoneBlasting

    ' Sprite will enter with the screen location at the top left position of the sprite in X which is 0,0 in the sprite array
    ' Move U or X to the correct starting position, depending on the type of sprite compiling we will do
    ' If the sprite has lots of similar patterns then it's best to blast the registers with the PSHU instruction
    ' Otherwise it's fastest to do a LDQ/STQ on each row then do a LDB #128/ABX to move down a row
    ' Still need to write the logic to determine what type of compiled method to use

    ' Stack Blast method
    ' Do this pattern until all rows with this pattern are complete
    '    Print "Handling pattern: "; 'Length of"; maxPatternLength ;" "
    Print "maxPatternLength="; maxPatternLength
    For t = 0 To patternLength - 1
        Print Hex$(Pattern(t));
    Next t
    Print
    For DoRows = maxFrequency To 1 Step -1
        ' "DoRows"; DoRows
        ' GoSub ShowUpdatedSprite 'Show the current sprite data - in array CopyOfPixels()
        ' Find the lowest row with this pattern
        ' Return with PatX & PatY pointing at the pattern start location in pixels
        GoSub CheckForPattern ' Go count the # of times this pattern is in the array, return with count in variable PatternCount
        If OldPatx = PatX And OldPatY = PatY Then GoTo SkipThisRow
        ' "PatX="; PatX, "PatY="; PatY ' these are pixel locations
        'Print "OldXPos="; OldXPos, "OldYPos="; OldYPos '
        ' Sprite drawing location in bytes (not pixels)
        XPos = PatX / 2 - OldXPos 'XPos now has the amount it has to move in bytes
        YPos = PatY - OldYPos 'YPos now has the amount of rows it has to move
        '        Print "Amount to move"; XPos, YPos

        Instr1$ = "LEAU"
        ' Move to the end of the pattern, stack blasting goes from right to left
        n = XPos + maxPatternLength / 2: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + "+128*"
        n = YPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        If N$ = "" Then N$ = "0"
        Instr2$ = Instr2$ + N$
        If LEAUCount = 0 Then
            ' First time we move the sprite start location relative to X
            LEAUCount = 1
            Instr2$ = Instr2$ + ",X"
        Else
            ' All the rest are relative to U
            Instr2$ = Instr2$ + ",U"
        End If
        Com$ = "move user stack to proper position " + Str$(PatX / 2 + maxPatternLength / 2) + "," + Str$(PatY): GoSub DoOutput ' Print the output
        ' Move U to the correct location where the stack blast starts (XPos is in bytes)
        XPos = PatX / 2 + maxPatternLength / 2
        YPos = PatY
        'Print "XPos here is"; XPos
        'Print "YPos here is"; YPos
        GoSub LoadRegisters ' Based on how many pixels maxPatternLength is we load the registers to prep for a PSHU
        ' First check and handle any transparent nibbles, once dealt with mark them as value 17
        For Testpixel = 0 To imageWidth - 2 Step 2
            'Print "Testpixel="; Testpixel, CopyOfPixels(Testpixel, YPos), CopyOfPixels(Testpixel + 1, YPos)
            'Testpixel = Position to check for transparency
            'Print Testpixel
            If CopyOfPixels(Testpixel, YPos) > 15 And CopyOfPixels(Testpixel + 1, YPos) > 15 Then
                ' both nibbles are transparent, therefore ignore them
                CopyOfPixels(Testpixel, YPos) = 17: CopyOfPixels(Testpixel + 1, YPos) = 17 ' ignore them completely
            Else ' check if one of the nibbles are transparent
                If CopyOfPixels(Testpixel, YPos) = 16 Or CopyOfPixels(Testpixel + 1, YPos) = 16 Then
                    ' We have a transparent nibble
                    n = Testpixel / 2 - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
                    If CopyOfPixels(Testpixel, YPos) = 16 Then
                        'just the left nibble is transparent
                        Instr1$ = "AIM"
                        Instr2$ = "#$F0;" + N$ + ",U": Com$ = "Keep the left nibble value (make right nibble palette 0)": GoSub DoOutput ' Print the output
                        If CopyOfPixels(Testpixel + 1, YPos) <> 0 Then
                            ' If the pixel we will draw on the right is <> 0 then we need to do the OR below, otherwise we are good with palette 0 at this point
                            Instr1$ = "OIM"
                            Instr2$ = "#$0" + Hex$(CopyOfPixels(Testpixel + 1, YPos)) + ";" + N$ + ",U": Com$ = "Change the right nibble to our pixel value": GoSub DoOutput ' Print the output
                        End If
                    Else
                        'just the right nibble is transparent
                        Instr1$ = "AIM"
                        Instr2$ = "#$0F;" + N$ + ",U": Com$ = "Keep the right nibble value (make left nibble palette 0)": GoSub DoOutput ' Print the output
                        If CopyOfPixels(Testpixel, YPos) <> 0 Then
                            ' If the pixel we will draw on the left is <> 0 then we need to do the OR below, otherwise we are good with palette 0 at this point
                            Instr1$ = "OIM"
                            Instr2$ = "#$" + Hex$(CopyOfPixels(Testpixel, YPos)) + "0;" + N$ + ",U": Com$ = "Change the left nibble to our pixel value": GoSub DoOutput ' Print the output
                        End If
                    End If
                    CopyOfPixels(Testpixel, YPos) = 17: CopyOfPixels(Testpixel + 1, YPos) = 17 ' ignore these pixels in the future completely
                End If
            End If
        Next Testpixel
        ' Check pixels on this row to see if they can be stored/PSHUed on screen
        ' get the count of how many bytes we have to the right of the current byte location (about to blast from)
        BytePos = XPos ' (XPos is in bytes)
        RightBytes = imageWidth / 2 - BytePos
        'Print "RightBytes="; RightBytes
        GoSub ClearSpriteArray 'Makes every value in Sprite$()="ZZ"
        SEnd = 0
        For BytePos = XPos * 2 To (imageWidth - 2) Step 2
            If CopyOfPixels(BytePos, YPos) < 16 And CopyOfPixels(BytePos + 1, YPos) < 16 Then
                'This is a byte to check if we can write to
                Sprite$(SEnd) = Hex$(CopyOfPixels(BytePos, YPos)) + Hex$(CopyOfPixels(BytePos + 1, YPos))
            End If
            SEnd = SEnd + 1
        Next BytePos
        URelative = 0
        If SEnd > 0 Then GoSub StoreBytesAtU
        MoveX = 0
        Com$ = "Blast 1st the registers to the screen"
        Instr1$ = "Something is": Instr2$ = "wrong"
        Select Case maxPatternLength
            Case 2
                Instr1$ = "PSHU": Instr2$ = "A": MoveX = -1
            Case 4
                Instr1$ = "PSHU": Instr2$ = "A,B": MoveX = -2
            Case 6
                Instr1$ = "PSHU": Instr2$ = "A,X": MoveX = -3
            Case 8
                Instr1$ = "PSHU": Instr2$ = "D,X": MoveX = -4
            Case 10
                Instr1$ = "PSHU": Instr2$ = "A,X,Y": MoveX = -5
            Case 12
                Instr1$ = "PSHU": Instr2$ = "D,X,Y": MoveX = -6
        End Select
        GoSub DoOutput ' Print the output
        'Update Xpos (Byte Location)
        XPos = XPos + MoveX
        ' See if we can write or blast more data to the screen on this row with the current values of the registers
        ' Print "XPos="; XPos, "YPos="; YPos
        XPixelPos = XPos * 2 'change byte position to pixel position
        ' Mark used pixels in array
        For X = XPixelPos To XPixelPos + maxPatternLength - 1
            CopyOfPixels(X, YPos) = 17 ' mark bytes as used
            '    Pixels(x, YPos) = 17 ' mark bytes as used
        Next X
        DidBlast = 1
        While DidBlast = 1
            GoSub CheckandDoBlast ' See and blast if we can blast some more data on this row
        Wend

        ' Check pixels on the rest of this row to see if they can be stored/PSHUed on screen
        ' First test to see if pattern is to the left of what was just blasted on screen, as we are already in the correct position to blast again
        ' If not see if we can blast A,X,Y, or B,X,Y or D,X or D,Y or A,X or B,X or A,Y or B,Y, or D or X or Y or A or B
        ' If not blasting see if we can STORE values of on the row... If we can use A,B as is and see if we can load E & F and do a STQ
        ' Cool 6309 instructions to handle pixels that are only one nibble, means you don't have to use LDA and STA (change a register's value) but 2 cycles slower
        ' than doing a LDA/ANDA/ORA/STA:
        ' AIM     #$0F;4,U  - AND memory 4,U with value $0F (clear left nibble)
        ' OIM     #$C0;4,U  - OR  memory 4,U with value $C0 (set left nibble to palette $C)

        ' Check pixels on this row to see if they can be stored/PSHUed on screen
        ' get the count of how many bytes we have to the left of the current byte location (just blasted)
        ' (XPos is in bytes)
        GoSub ClearSpriteArray 'Makes every value in Sprite$()="ZZ"
        SEnd = 0
        For BytePos = 0 To (XPos - 1) * 2 Step 2
            If CopyOfPixels(BytePos, YPos) < 16 And CopyOfPixels(BytePos + 1, YPos) < 16 Then
                ' This is a byte to check if we can write to
                ' Print "BytePos - XPos="; BytePos - XPos, "BytePos="; BytePos, "BytePos + 1="; BytePos + 1, "YPos="; YPos
                Sprite$(SEnd) = Hex$(CopyOfPixels(BytePos, YPos)) + Hex$(CopyOfPixels(BytePos + 1, YPos))
            End If
            SEnd = SEnd + 1
        Next BytePos
        If SEnd > 0 Then
            URelative = -XPos
            GoSub StoreBytesAtU
        End If
        'Update Pixels()
        For Y = 0 To imageHeight - 1
            For X = 0 To imageWidth - 1
                Pixels(X, Y) = CopyOfPixels(X, Y)
            Next X
        Next Y
        OldXPos = XPos
        OldYPos = YPos
        OldPatx = PatX
        OldPatY = PatY
    Next DoRows
    SkipThisRow:
    '    PatternSize = PatternSize - 2
Wend
'Come here once we've done all the patterns that are larger then 3 bytes
DoneBlasting:
'Update Pixels()
For Y = 0 To imageHeight - 1
    For X = 0 To imageWidth - 1
        Pixels(X, Y) = CopyOfPixels(X, Y)
    Next X
Next Y

OldXPos = XPos
OldYPos = YPos
' GoSub ShowUpdatedSprite 'Show the current sprite data - in array CopyOfPixels()
' First time through we find the starting location and move X to the position relative to U's location
'Find new starting position which will be the top row with data on it
'Print "OldXPos"; OldXPos
'Print "OldYPos"; OldYPos
' Find the first row with data
For Y = 0 To imageHeight - 1
    For X = 0 To (imageWidth - 1) Step 2
        '  Print X, Y, Hex$(Pixels(X, Y))
        If Pixels(X, Y) < 16 Or Pixels(X + 1, Y) < 16 Then
            'We just found the location of data that must be dealt with
            GoTo SetupXLocation
        End If
    Next X
    ' Print
Next Y

' Move X to the middle of this row
SetupXLocation:
Midpoint = Int(imageWidth / 4)
' Print "Midpoint"; Midpoint
' Print "Found data at X="; x; " Y="; Y
' Print "Pixels(X, Y) ="; Pixels(x, Y)
Instr1$ = "LEAX"
MovedX = 0
n = Midpoint - OldXPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
Instr2$ = N$ + "+128*"
n = Y - OldYPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
If N$ = "" Then N$ = "0"

If LEAUCount = 0 Then
    ' First time we move the sprite start location relative to X
    LEAUCount = 1
    Instr2$ = Instr2$ + N$ + ",X"
Else
    ' All the rest are relative to U
    Instr2$ = Instr2$ + N$ + ",U"
End If

'Instr2$ = Instr2$ + N$ + ",U"
Com$ = "Position X to the middle of the top row with data": GoSub DoOutput ' Print the output
X = Midpoint
XPos = X: YPos = Y
LastY = Y

' Resuse the code below to do the load/Store method only to compare with stack blasting and load/store
DoLoadStoreOnly:
FirstCheck = 0
MovedX = 0
' Find the next row with data starting from the top of the sprite
FindNextRow:
For Y = 0 To imageHeight - 1
    For X = 0 To (imageWidth - 2) Step 2
        If CopyOfPixels(X, Y) < 16 Or CopyOfPixels(X + 1, Y) < 16 Then
            'We just found the location of data that must be dealt with
            GoTo FoundTopRow
        End If
    Next X
Next Y
' If we get here then there's no more nibbles/bytes to do, we are done with this sprite
' Close the files and return
Instr1$ = "RTS": Com$ = "All done, Return": GoSub DoOutput ' Print the output
Close #2
Return

FoundTopRow:
XPos = Midpoint: YPos = Y
If MovedX = 0 Then
    'Skip this the first time
    MovedX = 1
Else
    'Not the first time
    If LastY <> Y Then
        ' We've processed this rows data,  otherwise don't move down yet
        If LastY + 1 = Y Then
            'We've only moved down one row, do an ABX where B = 128
            'We need to make sure B=128 and then do an ABX, unless we move more then one row
            If B$ <> "80" Then
                ' Make B = 128
                R$ = "80": GoSub DoLDB 'Go find the best way to make B=value R$, and print the output
            End If
            Instr1$ = "ABX"
            Instr2$ = ""
            Com$ = "Move down a row": GoSub DoOutput ' Print the output
        Else
            ' We need to do an LEAX to move down a bunch of rows
            Instr1$ = "LEAX"
            n = Y - LastY: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
            Instr2$ = "128*" + N$ + ",X"
            Com$ = "Move down " + N$ + " rows": GoSub DoOutput ' Print the output
        End If
    End If
End If
LastY = Y
GoSub HandleTransparencies ' Deal with transparency for XPos=X on row YPos
' At this point we've
' 1 - Moved Register X to the middle of this row and sprite
' 2 - handled the transparent nibbles of this row
' Do LDA/STA,LDU/STU,LDQ/STQ the rest of this row

CheckForMoreData:
Found = 0
For BytePos = 0 To imageWidth - 1
    If CopyOfPixels(BytePos, YPos) < 16 Then GoTo ProcessMoreData
Next BytePos
GoTo DoneRow

' If we get here then there is still more data to handle
ProcessMoreData:
If DoneSprite = 1 And FirstCheck = 0 Then
    FirstCheck = FirstCheck + 1
    'Print "Starting New LD/ST *****"
    ' LOAD Q
    Instr1$ = "LDU"
    U$ = "FFFF"
    Instr2$ = "#$" + U$
    Com$ = "Load U": GoSub DoOutput ' Print the output

    GoTo SkipCheck1Done
End If
' See if we can use Q,D,U,Y,A,B as they are in that order
' See if we can do a STQ
For BytePos = 0 To (imageWidth - 1) - 7 Step 2
    If A$ = Hex$(CopyOfPixels(BytePos, YPos)) + Hex$(CopyOfPixels(BytePos + 1, YPos)) And B$ = Hex$(CopyOfPixels(BytePos + 2, YPos)) + Hex$(CopyOfPixels(BytePos + 3, YPos)) And E$ = Hex$(CopyOfPixels(BytePos + 4, YPos)) + Hex$(CopyOfPixels(BytePos + 5, YPos)) And F$ = Hex$(CopyOfPixels(BytePos + 6, YPos)) + Hex$(CopyOfPixels(BytePos + 7, YPos)) Then
        'We just found a location to do a STQ
        Print "Doing a STQ - A$"; A$, "B$"; B$, E$; "; E$, "; F$; "; F$"
        Instr1$ = "STQ"
        n = BytePos / 2 - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + ",X"
        Com$ = "Store Q": GoSub DoOutput ' Print the output
        'Flag pxiels/bytes as used
        CopyOfPixels(BytePos, YPos) = 17: CopyOfPixels(BytePos + 1, YPos) = 17: CopyOfPixels(BytePos + 2, YPos) = 17: CopyOfPixels(BytePos + 3, YPos) = 17: CopyOfPixels(BytePos + 4, YPos) = 17: CopyOfPixels(BytePos + 5, YPos) = 17: CopyOfPixels(BytePos + 6, YPos) = 17: CopyOfPixels(BytePos + 7, YPos) = 17
        GoTo CheckForMoreData
    End If
Next BytePos
' See if we can do a STD
For BytePos = 0 To (imageWidth - 1) - 3 Step 2
    If A$ = Hex$(CopyOfPixels(BytePos, YPos)) + Hex$(CopyOfPixels(BytePos + 1, YPos)) And B$ = Hex$(CopyOfPixels(BytePos + 2, YPos)) + Hex$(CopyOfPixels(BytePos + 3, YPos)) Then
        'We just found a location to do a STD
        Instr1$ = "STD"
        n = BytePos / 2 - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + ",X"
        Com$ = "Store D": GoSub DoOutput ' Print the output
        'Flag pxiels/bytes as used
        CopyOfPixels(BytePos, YPos) = 17: CopyOfPixels(BytePos + 1, YPos) = 17: CopyOfPixels(BytePos + 2, YPos) = 17: CopyOfPixels(BytePos + 3, YPos) = 17
        GoTo CheckForMoreData
    End If
Next BytePos
' See if we can do a STU
For BytePos = 0 To (imageWidth - 1) - 3 Step 2
    If U$ = Hex$(CopyOfPixels(BytePos, YPos)) + Hex$(CopyOfPixels(BytePos + 1, YPos)) + Hex$(CopyOfPixels(BytePos + 2, YPos)) + Hex$(CopyOfPixels(BytePos + 3, YPos)) Then
        'We just found a location to do a STU
        Instr1$ = "STU"
        n = BytePos / 2 - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + ",X"
        Com$ = "Store U": GoSub DoOutput ' Print the output
        'Flag pxiels/bytes as used
        CopyOfPixels(BytePos, YPos) = 17: CopyOfPixels(BytePos + 1, YPos) = 17: CopyOfPixels(BytePos + 2, YPos) = 17: CopyOfPixels(BytePos + 3, YPos) = 17
        GoTo CheckForMoreData
    End If
Next BytePos
' See if we can do a STY
For BytePos = 0 To (imageWidth - 1) - 3 Step 2
    If Y$ = Hex$(CopyOfPixels(BytePos, YPos)) + Hex$(CopyOfPixels(BytePos + 1, YPos)) + Hex$(CopyOfPixels(BytePos + 2, YPos)) + Hex$(CopyOfPixels(BytePos + 3, YPos)) Then
        'We just found a location to do a STY
        Instr1$ = "STY"
        n = BytePos / 2 - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + ",X"
        Com$ = "Store Y": GoSub DoOutput ' Print the output
        'Flag pxiels/bytes as used
        CopyOfPixels(BytePos, YPos) = 17: CopyOfPixels(BytePos + 1, YPos) = 17: CopyOfPixels(BytePos + 2, YPos) = 17: CopyOfPixels(BytePos + 3, YPos) = 17
        GoTo CheckForMoreData
    End If
Next BytePos
' See if we can do a STW
For BytePos = 0 To (imageWidth - 1) - 3 Step 2
    If E$ = Hex$(CopyOfPixels(BytePos, YPos)) + Hex$(CopyOfPixels(BytePos + 1, YPos)) And F$ = Hex$(CopyOfPixels(BytePos + 2, YPos)) + Hex$(CopyOfPixels(BytePos + 3, YPos)) Then
        'We just found a location to do a STW
        Instr1$ = "STW"
        n = BytePos / 2 - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + ",X"
        Com$ = "Store W": GoSub DoOutput ' Print the output
        'Flag pxiels/bytes as used
        CopyOfPixels(BytePos, YPos) = 17: CopyOfPixels(BytePos + 1, YPos) = 17: CopyOfPixels(BytePos + 2, YPos) = 17: CopyOfPixels(BytePos + 3, YPos) = 17
        GoTo CheckForMoreData
    End If
Next BytePos
' See if we can do a STA
For BytePos = 0 To (imageWidth - 1) - 1 Step 2
    If A$ = Hex$(CopyOfPixels(BytePos, YPos)) + Hex$(CopyOfPixels(BytePos + 1, YPos)) Then
        'We just found a location to do a STA
        Instr1$ = "STA"
        n = BytePos / 2 - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + ",X"
        Com$ = "Store A": GoSub DoOutput ' Print the output
        'Flag pxiels/bytes as used
        CopyOfPixels(BytePos, YPos) = 17: CopyOfPixels(BytePos + 1, YPos) = 17
        GoTo CheckForMoreData
    End If
Next BytePos
' See if we can do a STB
For BytePos = 0 To (imageWidth - 1) - 1 Step 2
    If B$ = Hex$(CopyOfPixels(BytePos, YPos)) + Hex$(CopyOfPixels(BytePos + 1, YPos)) Then
        'We just found a location to do a STB
        Instr1$ = "STB"
        n = BytePos / 2 - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + ",X"
        Com$ = "Store B": GoSub DoOutput ' Print the output
        'Flag pxiels/bytes as used
        CopyOfPixels(BytePos, YPos) = 17: CopyOfPixels(BytePos + 1, YPos) = 17
        GoTo CheckForMoreData
    End If
Next BytePos
' See if we can do a STE
For BytePos = 0 To (imageWidth - 1) - 1 Step 2
    If E$ = Hex$(CopyOfPixels(BytePos, YPos)) + Hex$(CopyOfPixels(BytePos + 1, YPos)) Then
        'We just found a location to do a STB
        Instr1$ = "STE"
        n = BytePos / 2 - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + ",X"
        Com$ = "Store E": GoSub DoOutput ' Print the output
        'Flag pxiels/bytes as used
        CopyOfPixels(BytePos, YPos) = 17: CopyOfPixels(BytePos + 1, YPos) = 17
        GoTo CheckForMoreData
    End If
Next BytePos
' See if we can do a STF
For BytePos = 0 To (imageWidth - 1) - 1 Step 2
    If F$ = Hex$(CopyOfPixels(BytePos, YPos)) + Hex$(CopyOfPixels(BytePos + 1, YPos)) Then
        'We just found a location to do a STB
        Instr1$ = "STF"
        n = BytePos / 2 - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + ",X"
        Com$ = "Store F": GoSub DoOutput ' Print the output
        'Flag pxiels/bytes as used
        CopyOfPixels(BytePos, YPos) = 17: CopyOfPixels(BytePos + 1, YPos) = 17
        GoTo CheckForMoreData
    End If
Next BytePos

SkipCheck1Done:
' If we get here there is more data to process, we now need to do a LD/ST
' Get the largest consecutive bytes that need to be stored
maxLen = 0
currentLen = 0
startIndex = 0
maxStartIndex = -1

For BytePos = 0 To (imageWidth - 1) - 1 Step 2
    If CopyOfPixels(BytePos, YPos) <= 15 Then
        If currentLen = 0 Then
            startIndex = BytePos / 2
        End If
        currentLen = currentLen + 1
    Else
        If currentLen > maxLen Then
            maxLen = currentLen
            maxStartIndex = startIndex
        End If
        currentLen = 0
    End If
Next BytePos

' Check for the last segment
If currentLen > maxLen Then
    maxLen = currentLen
    maxStartIndex = startIndex
End If

'If maxLen > 0 Then
'    Print "Maximum length of consecutive entries <= 15: "; maxLen
'    Print "Starting location in the array: "; maxStartIndex
'Else
'    Print "No consecutive entries <= 15 found."
'End If

Select Case maxLen
    Case Is > 3
        'Do LDQ/STQ
        A = -1: b = -1: E = -1: F = -1
        If A$ = Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos)) Then A = 1
        If B$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 3, YPos)) Then b = 1
        If E$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 4, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 5, YPos)) Then E = 1
        If F$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 6, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 7, YPos)) Then F = 1
        If A + b + E + F = -4 Then
            ' LOAD Q
            Instr1$ = "LDQ"
            A$ = Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos))
            B$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 3, YPos))
            E$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 4, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 5, YPos))
            F$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 6, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 7, YPos))
            Instr2$ = "#$" + A$ + B$ + E$ + F$
            Com$ = "Load Q": GoSub DoOutput ' Print the output
            GoTo QIsGood
        End If
        If A + b + C + d = -3 Then
            ' one accumulator is already good so load the other 3
            If A = 1 Then
                ' Load B and W
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 3, YPos))
                GoSub DoLDB 'Go find the best way to make B=value R$, and print the output
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 4, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 5, YPos))
                R$ = R$ + Hex$(CopyOfPixels(maxStartIndex * 2 + 6, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 7, YPos))
                GoSub DoLDW 'Go find the best way to make W (E & F)=value R$, and print the output
            End If
            If b = 1 Then
                ' Load A and W
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos))
                GoSub DoLDA 'Go find the best way to make A=value R$, and print the output
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 4, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 5, YPos))
                R$ = R$ + Hex$(CopyOfPixels(maxStartIndex * 2 + 6, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 7, YPos))
                GoSub DoLDW 'Go find the best way to make W (E & F)=value R$, and print the output
            End If
            If E = 1 Then
                ' Load D and F
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos))
                R$ = R$ + Hex$(CopyOfPixels(maxStartIndex * 2 + 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 3, YPos))
                GoSub DoLDD 'Go find the best way to make D (A & B)=value R$, and print the output
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 6, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 7, YPos))
                GoSub DoLDF 'Go find the best way to make F=value R$, and print the output
            End If
            If F = 1 Then
                ' Load D and E
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos))
                R$ = R$ + Hex$(CopyOfPixels(maxStartIndex * 2 + 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 3, YPos))
                GoSub DoLDD 'Go find the best way to make D (A & B)=value R$, and print the output
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 4, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 5, YPos))
                GoSub DoLDE 'Go find the best way to make E=value R$, and print the output
            End If
            GoTo QIsGood
        End If
        If A + b + E + F = -2 Then
            ' two accumulators are already good so load the other 2
            If A = 1 And b = 1 Then
                'Load W
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 4, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 5, YPos))
                R$ = R$ + Hex$(CopyOfPixels(maxStartIndex * 2 + 6, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 7, YPos))
                GoSub DoLDW 'Go find the best way to make W (E & F)=value R$, and print the output
            End If
            If A = 1 And E = 1 Then
                'Load B & F
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 3, YPos))
                GoSub DoLDB 'Go find the best way to make B=value R$, and print the output
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 6, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 7, YPos))
                GoSub DoLDF 'Go find the best way to make F=value R$, and print the output
            End If
            If A = 1 And F = 1 Then
                'Load B & E
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 3, YPos))
                GoSub DoLDB 'Go find the best way to make B=value R$, and print the output
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 4, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 5, YPos))
                GoSub DoLDE 'Go find the best way to make E=value R$, and print the output
            End If
            If b = 1 And E = 1 Then
                'Load A & F
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos))
                GoSub DoLDA 'Go find the best way to make A=value R$, and print the output
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 6, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 7, YPos))
                GoSub DoLDF 'Go find the best way to make F=value R$, and print the output
            End If
            If b = 1 And F = 1 Then
                'Load A & E
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos))
                GoSub DoLDA 'Go find the best way to make A=value R$, and print the output
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 4, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 5, YPos))
                GoSub DoLDE 'Go find the best way to make E=value R$, and print the output
            End If
            If E = 1 And F = 1 Then
                ' Load D
                R$ = Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos))
                R$ = R$ + Hex$(CopyOfPixels(maxStartIndex * 2 + 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 3, YPos))
                GoSub DoLDD 'Go find the best way to make D (A & B)=value R$, and print the output
            End If
            GoTo QIsGood
        End If
        If A = -1 Then
            'LDA
            R$ = Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos))
            GoSub DoLDA 'Go find the best way to make A=value R$, and print the output
            GoTo QIsGood
        End If
        If b = -1 Then
            'LDB
            R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 3, YPos))
            GoSub DoLDB 'Go find the best way to make B=value R$, and print the output
            GoTo QIsGood
        End If
        If E = -1 Then
            'LDE
            R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 4, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 5, YPos))
            GoSub DoLDE 'Go find the best way to make E=value R$, and print the output
            GoTo QIsGood
        End If
        If F = -1 Then
            'LDF
            R$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 6, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 7, YPos))
            GoSub DoLDF 'Go find the best way to make F=value R$, and print the output
            GoTo QIsGood
        End If
        QIsGood:
        Instr1$ = "STQ"
        n = maxStartIndex - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + ",X"
        Com$ = "Store Q": GoSub DoOutput ' Print the output
        'Mark pixels as used
        CopyOfPixels(maxStartIndex * 2, YPos) = 17: CopyOfPixels(maxStartIndex * 2 + 1, YPos) = 17
        CopyOfPixels(maxStartIndex * 2 + 2, YPos) = 17: CopyOfPixels(maxStartIndex * 2 + 3, YPos) = 17
        CopyOfPixels(maxStartIndex * 2 + 4, YPos) = 17: CopyOfPixels(maxStartIndex * 2 + 5, YPos) = 17
        CopyOfPixels(maxStartIndex * 2 + 6, YPos) = 17: CopyOfPixels(maxStartIndex * 2 + 7, YPos) = 17

    Case 3
        'Do LDA/STA   & LDU/STU
        If A$ <> Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos)) Then
            R$ = Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos))
            GoSub DoLDA 'Go find the best way to make A=value R$, and print the output
        End If
        Instr1$ = "STA"
        n = maxStartIndex - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + ",X"
        Com$ = "Store A": GoSub DoOutput ' Print the output
        'Mark pixels as used
        CopyOfPixels(maxStartIndex * 2, YPos) = 17: CopyOfPixels(maxStartIndex * 2 + 1, YPos) = 17
        If U$ <> Hex$(CopyOfPixels(maxStartIndex * 2 + 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 3, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 4, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 5, YPos)) Then
            U$ = Hex$(CopyOfPixels(maxStartIndex * 2 + 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 3, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 4, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 5, YPos))
            Instr1$ = "LDU"
            Instr2$ = "#$" + U$
            Com$ = "Load U": GoSub DoOutput ' Print the output
        End If
        Instr1$ = "STU"
        n = maxStartIndex + 1 - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + ",X"
        Com$ = "Store U": GoSub DoOutput ' Print the output
        'Mark pixels as used
        CopyOfPixels(maxStartIndex * 2 + 2, YPos) = 17: CopyOfPixels(maxStartIndex * 2 + 3, YPos) = 17
        CopyOfPixels(maxStartIndex * 2 + 4, YPos) = 17: CopyOfPixels(maxStartIndex * 2 + 5, YPos) = 17
    Case 2
        'Do LDU/STU
        If U$ <> Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 3, YPos)) Then
            U$ = Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 3, YPos))
            Instr1$ = "LDU"
            Instr2$ = "#$" + U$
            Com$ = "Load U": GoSub DoOutput ' Print the output
        End If
        Instr1$ = "STU"
        n = maxStartIndex - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + ",X"
        Com$ = "Store U": GoSub DoOutput ' Print the output
        'Mark pixels as used
        CopyOfPixels(maxStartIndex * 2, YPos) = 17: CopyOfPixels(maxStartIndex * 2 + 1, YPos) = 17: CopyOfPixels(maxStartIndex * 2 + 2, YPos) = 17: CopyOfPixels(maxStartIndex * 2 + 3, YPos) = 17
    Case 1
        'Do LDA/STA
        If A$ <> Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos)) Then
            R$ = Hex$(CopyOfPixels(maxStartIndex * 2, YPos)) + Hex$(CopyOfPixels(maxStartIndex * 2 + 1, YPos))
            GoSub DoLDA 'Go find the best way to make A=value R$, and print the output
        End If
        Instr1$ = "STA"
        n = maxStartIndex - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr2$ = N$ + ",X"
        Com$ = "Store A": GoSub DoOutput ' Print the output
        'Mark pixels as used
        CopyOfPixels(maxStartIndex * 2, YPos) = 17: CopyOfPixels(maxStartIndex * 2 + 1, YPos) = 17
End Select




'If we get here then we've stored all the data for this row, we can now move down to the next row with data
DoneRow:


'All done, process more data on this row or look for another row
GoTo FindNextRow




System

' Do a LD value of accumulators
' Enter with R$ = The value we need in the resulting accumulator
' See if we can use:
' CLRA,CLRB,CLRD,CLRE,CLRF,CLRW
' COMA,COMB,COMD,COME,COMF,COMW
' DECA,DECB,DECD,DECE,DECF,DECW
' INCA,INCB,INCD,INCE,INCF,INCW
' NEGA,NEGB,NEGD
' If not, use LOAD
DoLDA:
Found = 0
If A$ <> "" Then
    T$ = A$
    GoSub DoComplement 'Convert Hex value in T$ to it's complement and return with the result in ComplementHex$
    GoSub DoDec 'Decrement the Hex value in T$ and return with the result in DecrementedHex$
    GoSub DoInc 'Increment the Hex value in T$ and return with the result in IncrementedHex$
    GoSub DoNegative 'Convert Hex value in T$ to it's negative value and return with the result in NegativeHex$
    GoSub DoASR ' Do shift ASR of the 8 bit Hex value in T$ and return with the result in ASRHex$
    GoSub DoLSL ' Do shift left of the 8 bit Hex value in T$ and return with the result in LSLHex$
    GoSub DoLSR ' Do shift right of the 8 bit Hex value in T$ and return with the result in LSRHex$
    '    GoSub DoRol ' Do ROL of the 8 bit Hex value in T$ and return with the result in ROLHex$
    '    GoSub DoRor ' Do ROR of the 8 bit Hex value in T$ and return with the result in RORHex$
    If R$ = "00" Then Instr1$ = "CLRA": Found = 1 'Handle making the value zero
    If ComplementHex$ = R$ Then Instr1$ = "COMA": Found = 1
    If DecrementedHex$ = R$ Then Instr1$ = "DECA": Found = 1
    If IncrementedHex$ = R$ Then Instr1$ = "INCA": Found = 1
    If NegativeHex$ = R$ Then Instr1$ = "NEGA": Found = 1
    If ASRHex$ = R$ Then Instr1$ = "ASRA": Found = 1
    If LSLHex$ = R$ Then Instr1$ = "LSLA": Found = 1
    If LSRHex$ = R$ Then Instr1$ = "LSRA": Found = 1
    '    If ROLHex$ = R$ Then Instr1$ = "ROLA": Found = 1
    '    If RORHex$ = R$ Then Instr1$ = "RORA": Found = 1
End If
If Found = 0 Then
    ' can't use any smaller/quicker instructions must do a LD
    Instr1$ = "LDA"
    Instr2$ = "#$" + R$
End If
Com$ = "A is now $" + R$: GoSub DoOutput ' Print the output
A$ = R$
Return
DoLDB:
Found = 0
If B$ <> "" Then
    T$ = B$
    GoSub DoComplement 'Convert Hex value in T$ to it's complement and return with the result in ComplementHex$
    GoSub DoDec 'Decrement the Hex value in T$ and return with the result in DecrementedHex$
    GoSub DoInc 'Increment the Hex value in T$ and return with the result in IncrementedHex$
    GoSub DoNegative 'Convert Hex value in T$ to it's negative value and return with the result in NegativeHex$
    GoSub DoASR ' Do shift ASR of the 8 bit Hex value in T$ and return with the result in ASRHex$
    GoSub DoLSL ' Do shift left of the 8 bit Hex value in T$ and return with the result in LSLHex$
    GoSub DoLSR ' Do shift right of the 8 bit Hex value in T$ and return with the result in LSRHex$
    '    GoSub DoRol ' Do ROL of the 8 bit Hex value in T$ and return with the result in ROLHex$
    '    GoSub DoRor ' Do ROR of the 8 bit Hex value in T$ and return with the result in RORHex$
    If R$ = "00" Then Instr1$ = "CLRB": Found = 1 'Handle making the value zero
    If ComplementHex$ = R$ Then Instr1$ = "COMB": Found = 1
    If DecrementedHex$ = R$ Then Instr1$ = "DECB": Found = 1
    If IncrementedHex$ = R$ Then Instr1$ = "INCB": Found = 1
    If NegativeHex$ = R$ Then Instr1$ = "NEGB": Found = 1
    If ASRHex$ = R$ Then Instr1$ = "ASRB": Found = 1
    If LSLHex$ = R$ Then Instr1$ = "LSLB": Found = 1
    If LSRHex$ = R$ Then Instr1$ = "LSRB": Found = 1
    '    If ROLHex$ = R$ Then Instr1$ = "ROLB": Found = 1
    '    If RORHex$ = R$ Then Instr1$ = "RORB": Found = 1
End If
If Found = 0 Then
    ' can't use any smaller/quicker instructions must do a LD
    Instr1$ = "LDB"
    Instr2$ = "#$" + R$
End If
Com$ = "B is now $" + R$: GoSub DoOutput ' Print the output
B$ = R$
Return

DoLDE:
Found = 0
If E$ <> "" Then
    T$ = E$
    GoSub DoComplement 'Convert Hex value in T$ to it's complement and return with the result in ComplementHex$
    GoSub DoDec 'Decrement the Hex value in T$ and return with the result in DecrementedHex$
    GoSub DoInc 'Increment the Hex value in T$ and return with the result in IncrementedHex$
    If R$ = "00" Then Instr1$ = "CLRE": Found = 1 'Handle making the value zero
    If ComplementHex$ = R$ Then Instr1$ = "COME": Found = 1
    If DecrementedHex$ = R$ Then Instr1$ = "DECE": Found = 1
    If IncrementedHex$ = R$ Then Instr1$ = "INCE": Found = 1
End If
If Found = 0 Then
    ' can't use any smaller/quicker instructions must do a LD
    Instr1$ = "LDE"
    Instr2$ = "#$" + R$
End If
Com$ = "E is now $" + R$: GoSub DoOutput ' Print the output
E$ = R$
Return
DoLDF:
Found = 0
If F$ <> "" Then
    T$ = F$
    GoSub DoComplement 'Convert Hex value in T$ to it's complement and return with the result in ComplementHex$
    GoSub DoDec 'Decrement the Hex value in T$ and return with the result in DecrementedHex$
    GoSub DoInc 'Increment the Hex value in T$ and return with the result in IncrementedHex$
    If R$ = "00" Then Instr1$ = "CLRF": Found = 1 'Handle making the value zero
    If ComplementHex$ = R$ Then Instr1$ = "COMF": Found = 1
    If DecrementedHex$ = R$ Then Instr1$ = "DECF": Found = 1
    If IncrementedHex$ = R$ Then Instr1$ = "INCF": Found = 1
End If
If Found = 0 Then
    ' can't use any smaller/quicker instructions must do a LD
    Instr1$ = "LDF"
    Instr2$ = "#$" + R$
End If
Com$ = "F is now $" + R$: GoSub DoOutput ' Print the output
F$ = R$
Return
' 16 bit versions
DoLDD:
Found = 0
If A$ <> "" And B$ <> "" Then
    T$ = A$ + B$
    GoSub DoComplement16 'Convert 16 bit Hex value in T$ to it's complement and return with the result in ComplementHex$
    GoSub DoDec16 'Decrement the 16 bit Hex value in T$ and return with the result in DecrementedHex$
    GoSub DoInc16 'Increment the 16 bit Hex value in T$ and return with the result in IncrementedHex$
    GoSub DoNegative16 'Convert 16 bit Hex value in T$ to it's negative value and return with the result in NegativeHex$
    GoSub DoASR16 ' Do shift ASR of the 16 bit Hex value in T$ and return with the result in ASRHex$
    GoSub DoLSL16 ' Do shift left of the 16 bit Hex value in T$ and return with the result in LSLHex$
    GoSub DoLSR16 ' Do shift left of the 16 bit Hex value in T$ and return with the result in LSRHex$
    '    GoSub DoRol16 ' Do ROL of the 16 bit Hex value in T$ and return with the result in ROLHex$
    '    GoSub DoRor16 ' Do ROL of the 16 bit Hex value in T$ and return with the result in RORHex$
    If R$ = "0000" Then Instr1$ = "CLRD": Found = 1 'Handle making the value zero
    If ComplementHex$ = R$ Then Instr1$ = "COMD": Found = 1
    If DecrementedHex$ = R$ Then Instr1$ = "DECD": Found = 1
    If IncrementedHex$ = R$ Then Instr1$ = "INCD": Found = 1
    If NegativeHex$ = R$ Then Instr1$ = "NEGD": Found = 1
    If ASRHex$ = R$ Then Instr1$ = "ASRD": Found = 1
    If LSLHex$ = R$ Then Instr1$ = "LSLD": Found = 1
    If LSRHex$ = R$ Then Instr1$ = "LSRD": Found = 1
    '    If ROLHex$ = R$ Then Instr1$ = "ROLD": Found = 1
    '    If RORHex$ = R$ Then Instr1$ = "RORD": Found = 1
End If
If Found = 0 Then
    ' can't use any smaller/quicker instructions must do a LD
    Instr1$ = "LDD"
    Instr2$ = "#$" + R$
End If
Com$ = "D is now $" + R$: GoSub DoOutput ' Print the output
A$ = Left$(R$, 2): B$ = Right$(R$, 2)
Return

DoLDW:
Found = 0
If E$ <> "" And F$ <> "" Then
    T$ = E$ + F$
    GoSub DoComplement16 'Convert 16 bit Hex value in T$ to it's complement and return with the result in ComplementHex$
    GoSub DoDec16 'Decrement the 16 bit Hex value in T$ and return with the result in DecrementedHex$
    GoSub DoInc16 'Increment the 16 bit Hex value in T$ and return with the result in IncrementedHex$
    GoSub DoLSR16 ' Do shift left of the 16 bit Hex value in T$ and return with the result in LSRHex$
    '    GoSub DoRol16 ' Do ROL of the 16 bit Hex value in T$ and return with the result in ROLHex$
    '    GoSub DoRor16 ' Do ROL of the 16 bit Hex value in T$ and return with the result in RORHex$
    If T$ = "0000" Then Instr1$ = "CLRW": Found = 1 'Handle making the value zero
    If ComplementHex$ = R$ Then Instr1$ = "COMW": Found = 1
    If DecrementedHex$ = R$ Then Instr1$ = "DECW": Found = 1
    If IncrementedHex$ = R$ Then Instr1$ = "INCW": Found = 1
    If LSRHex$ = R$ Then Instr1$ = "LSRW": Found = 1
    '    If ROLHex$ = R$ Then Instr1$ = "ROLW": Found = 1
    '    If RORHex$ = R$ Then Instr1$ = "RORW": Found = 1
End If
If Found = 0 Then
    ' can't use any smaller/quicker instructions must do a LD
    Instr1$ = "LDW"
    Instr2$ = "#$" + R$
End If
Com$ = "W is now $" + R$: GoSub DoOutput ' Print the output
E$ = Left$(R$, 2): F$ = Right$(R$, 2)
Return

' Deal with transparency for XPos=X on row YPos
HandleTransparencies:
' First check and handle any transparent nibbles, once dealt with mark them as value 17
For Testpixel = 0 To imageWidth - 2 Step 2
    '  Print "Testpixel="; Testpixel, CopyOfPixels(Testpixel, YPos), CopyOfPixels(Testpixel + 1, YPos)
    'Testpixel = Position to check for transparency
    If CopyOfPixels(Testpixel, YPos) > 15 And CopyOfPixels(Testpixel + 1, YPos) > 15 Then
        ' both nibbles are transparent, therefore ignore them
        CopyOfPixels(Testpixel, YPos) = 17: CopyOfPixels(Testpixel + 1, YPos) = 17 ' ignore them completely
    Else ' check if one of the nibbles are transparent
        n = Testpixel / 2 - XPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        If CopyOfPixels(Testpixel, YPos) = 16 Then
            'just the left nibble is transparent
            Instr1$ = "AIM"
            Instr2$ = "#$F0;" + N$ + ",X": Com$ = "Keep the left nibble value (make right nibble palette 0)": GoSub DoOutput ' Print the output
            If CopyOfPixels(Testpixel + 1, YPos) <> 0 Then
                ' If the pixel we will draw on the right is <> 0 then we need to do the OR below, otherwise we are good with palette 0 at this point
                Instr1$ = "OIM"
                Instr2$ = "#$0" + Hex$(CopyOfPixels(Testpixel + 1, YPos)) + ";" + N$ + ",X": Com$ = "Change the right nibble to our pixel value": GoSub DoOutput ' Print the output
            End If
            CopyOfPixels(Testpixel, YPos) = 17: CopyOfPixels(Testpixel + 1, YPos) = 17 ' ignore them completely
        End If
        If CopyOfPixels(Testpixel + 1, YPos) = 16 Then
            'just the right nibble is transparent
            Instr1$ = "AIM"
            Instr2$ = "#$0F;" + N$ + ",X": Com$ = "Keep the right nibble value (make left nibble palette 0)": GoSub DoOutput ' Print the output
            If CopyOfPixels(Testpixel, YPos) <> 0 Then
                ' If the pixel we will draw on the left is <> 0 then we need to do the OR below, otherwise we are good with palette 0 at this point
                Instr1$ = "OIM"
                Instr2$ = "#$" + Hex$(CopyOfPixels(Testpixel, YPos)) + "0;" + N$ + ",X": Com$ = "Change the left nibble to our pixel value": GoSub DoOutput ' Print the output
            End If
            CopyOfPixels(Testpixel, YPos) = 17: CopyOfPixels(Testpixel + 1, YPos) = 17 ' ignore them completely
        End If
    End If
Next Testpixel
Return

' Based on how many pixels maxPatternLength is we load the registers to prep for a PSHU
LoadRegisters:
On maxPatternLength GOTO Skip, Length2, Skip, Length4, Skip, Length6, Skip, Length8, Skip, Length10, Skip, Length12

Length12: 'Load Y$
R$ = Hex$(Pattern(8)) + Hex$(Pattern(9)) + Hex$(Pattern(10)) + Hex$(Pattern(11))
If Y$ <> R$ Then
    Y$ = R$
    Instr1$ = "LDY": Instr2$ = "#$" + R$: GoSub DoOutput ' Print the output
End If
GoTo Length8
Length10: 'Load Y$
R$ = Hex$(Pattern(6)) + Hex$(Pattern(7)) + Hex$(Pattern(8)) + Hex$(Pattern(9))
If Y$ <> R$ Then
    Y$ = R$
    Instr1$ = "LDY": Instr2$ = "#$" + R$: GoSub DoOutput ' Print the output
End If
GoTo Length6
Length8: 'Load X$
R$ = Hex$(Pattern(4)) + Hex$(Pattern(5)) + Hex$(Pattern(6)) + Hex$(Pattern(7))
If X$ <> R$ Then
    X$ = R$
    Instr1$ = "LDX": Instr2$ = "#$" + R$: GoSub DoOutput ' Print the output
    If Do1TfrXW = 1 Then
        ' If we do it we only do it once
        Do1TfrXW = 0
        GoSub DoTFR_XW 'Do a TFR X,W unless W already = X
    Else
        'Check if we are to try TFR X,W when we do a LDX #
        If DoTFRMany = 1 Then
            GoSub DoTFR_XW 'Do a TFR X,W unless W already = X
        End If
    End If
End If
GoTo Length4
Length6: 'Load X$
R$ = Hex$(Pattern(2)) + Hex$(Pattern(3)) + Hex$(Pattern(4)) + Hex$(Pattern(5))
If X$ <> R$ Then
    X$ = R$
    Instr1$ = "LDX": Instr2$ = "#$" + R$: GoSub DoOutput ' Print the output
    If Do1TfrXW = 1 Then
        ' If we do it we only do it once
        Do1TfrXW = 0
        GoSub DoTFR_XW 'Do a TFR X,W unless W already = X
    Else
        'Check if we are to try TFR X,W when we do a LDX #
        If DoTFRMany = 1 Then
            GoSub DoTFR_XW 'Do a TFR X,W unless W already = X
        End If
    End If
End If
GoTo Length2
Length4: 'Load D$ or A$ or B$ depending on if they are already the correct value
R$ = Hex$(Pattern(0)) + Hex$(Pattern(1))
R1$ = Hex$(Pattern(2)) + Hex$(Pattern(3))
If A$ <> R$ And B$ <> R1$ Then
    'Neither A or B match so do a LDD
    Instr1$ = "LDD": Instr2$ = "#$" + R$ + R1$: GoSub DoOutput ' Print the output
    A$ = R$: B$ = R1$
    Return
Else
    ' One or both matched
    If A$ = R$ And B$ = R1$ Then
        ' Both match, no need to load either register
        Return
    Else
        If A$ = R$ Then
            'just need to load B
            Instr1$ = "LDB": Instr2$ = "#$" + R1$: GoSub DoOutput ' Print the output
            B$ = R1$
            Return
        Else
            'Just need to load A
            Instr1$ = "LDA": Instr2$ = "#$" + R$: GoSub DoOutput ' Print the output
            A$ = R$
            Return
        End If
    End If
End If
Length2: 'Load A$
R$ = Hex$(Pattern(0)) + Hex$(Pattern(1))
If A$ <> R$ Then
    A$ = R$
    Instr1$ = "LDA": Instr2$ = "#$" + R$: GoSub DoOutput ' Print the output
End If
Skip:
Return

'Do a TFR X,W unless W already = X
DoTFR_XW:
If E$ <> Left$(X$, 2) And F$ <> Right$(X$, 2) Then
    'We need to do a TFR X,W
    Instr1$ = "TFR"
    Instr2$ = "X,W": Com$ = "Copy X to W": GoSub DoOutput ' Print the output
    E$ = Left$(X$, 2)
    F$ = Right$(X$, 2)
End If
Return

' Do a TFM compiled sprite
'        LDX     #ScreenStart Location  (Top left corner shere sprite will be shown)
'        LDB     #23
'        ABX
'        LDW     #26
'        TFM     U+,X+    ...
DoTFM:
Dim TFM$(225) ' Max rows per CoCo3 screen
Open "Object" + CodeName$ + ".asm" For Output As #2
Print #2, "Obj_" + CodeName$ + "_Start:"
GoSub ShowSpriteInFile
'Start from the top left corner of the sprite as the Destination address source address
' First setup U as the source pointer
Instr1$ = "LDU"
Instr2$ = "#" + "Obj_" + CodeName$ + "_U": Com$ = "U points at the start of the source data": GoSub DoOutput ' Print the output
AmountMoved = 128
For Y = 0 To imageHeight - 1
    TFM$(Y) = ""
    Found = 0
    AddToX = 128 - AmountMoved
    AmountMoved = 0
    count = 0
    X = 0
    While X <= imageWidth - 1 'read bytes
        ' Print "Y"; Y, "X"; X
        If Pixels(X, Y) < 16 Or Pixels(X + 1, Y) < 16 Then
            ' we found the start of a section
            PSX = X / 2
            Found = 1
            ' Find the end
            While X <= imageWidth - 1 'read bytes
                If Pixels(X, Y) < 16 Or Pixels(X + 1, Y) < 16 Then
                    PEX = X / 2
                Else
                    GoTo FoundEnd
                End If
                X = X + 2
            Wend
            FoundEnd:

            'Print "PSX"; PSX, "PEX"; PEX
            '   System
            AddToX = AddToX + PSX
            count = PEX - PSX + 1
            AmountMoved = AmountMoved + PSX + count
            Instr1$ = "LDB"
            n = AddToX: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
            If n = 0 Then N$ = "00"
            Instr2$ = "#" + N$: Com$ = "B has the amount of bytes to move forward": GoSub DoOutput ' Print the output
            Instr1$ = "ABX"
            Instr2$ = "": Com$ = "Move X forward": GoSub DoOutput ' Print the output
            Instr1$ = "LDW"
            n = count: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
            Instr2$ = "#" + N$: Com$ = "W has the amount of bytes to copy": GoSub DoOutput ' Print the output
            Instr1$ = "TFM"
            Instr2$ = "U+,X+": Com$ = "Move X forward": GoSub DoOutput ' Print the output
            TotalCycles = TotalCycles + 3 * count
            For i = PSX * 2 To PEX * 2 Step 2
                MSN = Pixels(i, Y)
                LSN = Pixels(i + 1, Y)
                If MSN > 15 Then MSN = 15
                TFM$(Y) = TFM$(Y) + Hex$(MSN)
                If LSN > 15 Then LSN = 15
                TFM$(Y) = TFM$(Y) + Hex$(LSN)
            Next i
        End If
        X = X + 2
    Wend
    If Found = 0 Then
        Instr1$ = "LDB"
        Instr2$ = "#128" + N$: Com$ = "Move down to the next row": GoSub DoOutput ' Print the output
        Instr1$ = "ABX"
        Instr2$ = "": Com$ = "Move X forward": GoSub DoOutput ' Print the output
    End If
Next Y
Instr1$ = "RTS": Com$ = "Return": GoSub DoOutput ' Print the output

Print #2, "Obj_" + CodeName$ + "_U:"
For Y = 0 To imageHeight - 1
    Print #2, "        FCB     ";
    O$ = ""
    For i = 1 To Len(TFM$(Y)) Step 2
        O$ = O$ + "$" + Mid$(TFM$(Y), i, 2) + ","
    Next i
    Print #2, Left$(O$, Len(O$) - 1)
Next Y
Close #2
Print "Total Cycles:"; TotalCycles
System





' Print the output to file #2
DoOutput:
If Left$(Instr2$, 1) = "+" Then Instr2$ = Right$(Instr2$, Len(Instr2$) - 1)
GoSub DoCycleCount
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
DoCycleCount:
IFound = 0
If Instr1$ = "ORCC" Then TotalCycles = TotalCycles + 1: GoSub Load8
If Instr1$ = "LDA" Then GoSub Load8
If Instr1$ = "LDB" Then GoSub Load8
If Instr1$ = "ORA" Then GoSub Load8
If Instr1$ = "ORB" Then GoSub Load8
If Instr1$ = "ANDA" Then GoSub LEA
If Instr1$ = "ANDB" Then GoSub LEA
If Instr1$ = "LDD" Then GoSub Load16
If Instr1$ = "LDX" Then GoSub Load16
If Instr1$ = "LDU" Then GoSub Load16
If Instr1$ = "LDY" Then TotalCycles = TotalCycles + 1: GoSub Load16
If Instr1$ = "LDW" Then TotalCycles = TotalCycles + 1: GoSub Load16
If Instr1$ = "LDQ" Then TotalCycles = TotalCycles + 2: GoSub Load16
If Instr1$ = "STA" Then GoSub Store
If Instr1$ = "STB" Then GoSub Store
If Instr1$ = "STD" Then TotalCycles = TotalCycles + 1: GoSub Store
If Instr1$ = "STE" Then TotalCycles = TotalCycles + 1: GoSub Store
If Instr1$ = "STF" Then TotalCycles = TotalCycles + 1: GoSub Store
If Instr1$ = "STX" Then TotalCycles = TotalCycles + 1: GoSub Store
If Instr1$ = "STU" Then TotalCycles = TotalCycles + 1: GoSub Store
If Instr1$ = "STY" Then TotalCycles = TotalCycles + 2: GoSub Store
If Instr1$ = "STW" Then TotalCycles = TotalCycles + 2: GoSub Store
If Instr1$ = "STQ" Then TotalCycles = TotalCycles + 4: GoSub Store
If Left$(Instr1$, 3) = "COM" Then
    If Right$(Instr1$, 1) = "A" Or Right$(Instr1$, 1) = "B" Then
        GoSub OneCycle
    Else
        GoSub TwoCycles
    End If
End If
If Left$(Instr1$, 3) = "DEC" Then
    If Right$(Instr1$, 1) = "A" Or Right$(Instr1$, 1) = "B" Then
        GoSub OneCycle
    Else
        GoSub TwoCycles
    End If
End If
If Left$(Instr1$, 3) = "INC" Then
    If Right$(Instr1$, 1) = "A" Or Right$(Instr1$, 1) = "B" Then
        GoSub OneCycle
    Else
        GoSub TwoCycles
    End If
End If
If Left$(Instr1$, 3) = "NEG" Then
    If Right$(Instr1$, 1) = "A" Or Right$(Instr1$, 1) = "B" Then
        GoSub OneCycle
    Else
        GoSub TwoCycles
    End If
End If
If Left$(Instr1$, 3) = "ASR" Then
    If Right$(Instr1$, 1) = "A" Or Right$(Instr1$, 1) = "B" Then
        GoSub OneCycle
    Else
        GoSub TwoCycles
    End If
End If
If Left$(Instr1$, 3) = "LSL" Then
    If Right$(Instr1$, 1) = "A" Or Right$(Instr1$, 1) = "B" Then
        GoSub OneCycle
    Else
        GoSub TwoCycles
    End If
End If
If Left$(Instr1$, 3) = "LSR" Then
    If Right$(Instr1$, 1) = "A" Or Right$(Instr1$, 1) = "B" Then
        GoSub OneCycle
    Else
        GoSub TwoCycles
    End If
End If
If Left$(Instr1$, 3) = "ROL" Then
    If Right$(Instr1$, 1) = "A" Or Right$(Instr1$, 1) = "B" Then
        GoSub OneCycle
    Else
        GoSub TwoCycles
    End If
End If
If Left$(Instr1$, 3) = "ROR" Then
    If Right$(Instr1$, 1) = "A" Or Right$(Instr1$, 1) = "B" Then
        GoSub OneCycle
    Else
        GoSub TwoCycles
    End If
End If
If Left$(Instr1$, 3) = "CLR" Then
    If Right$(Instr1$, 1) = "A" Or Right$(Instr1$, 1) = "B" Then
        GoSub OneCycle
    Else
        GoSub TwoCycles
    End If
End If
If Left$(Instr1$, 3) = "LEA" Then GoSub LEA
If Instr1$ = "AIM" Then GoSub AIM
If Instr1$ = "OIM" Then GoSub AIM
If Instr1$ = "PSHU" Then GoSub PSHU_Calc
If Instr1$ = "PULU" Then GoSub PSHU_Calc
If Instr1$ = "PSHS" Then GoSub PSHU_Calc
If Instr1$ = "PULS" Then GoSub PSHU_Calc
If Instr1$ = "ABX" Then GoSub OneCycle
If Instr1$ = "RTS" Then GoSub FourCycles
If Instr1$ = "TFR" Then GoSub FourCycles
If Instr1$ = "STS" Then GoSub FiveCycles
If Instr1$ = "LDS" Then GoSub FourCycles
If Instr1$ = "EQU" Then IFound = 1 ' No cycles, just DATA
If Instr1$ = "RMB" Then IFound = 1 ' No cycles, just clearing RAM space
If Instr1$ = "FCB" Then IFound = 1 ' No cycles, just DATA
If Instr1$ = "FDB" Then IFound = 1 ' No cycles, just DATA
If Instr1$ = "TFM" Then GoSub SixCycles ' 6 cycles + 3n (n is the number of bytes to move - in W)

If IFound = 0 Then Print "Can't do cycle count on "; Instr1$; " "; Instr2$; " yet": Print "Total CyCles="; TotalCycles: System
Return
OneCycle:
IFound = 1
TotalCycles = TotalCycles + 1 ' add 1 cycle
Return
TwoCycles:
IFound = 1
TotalCycles = TotalCycles + 2 ' add 2 cycles
Return
ThreeCycles:
IFound = 1
TotalCycles = TotalCycles + 3 ' add 3 cycles
Return
FourCycles:
IFound = 1
TotalCycles = TotalCycles + 4 ' add 4 cycles
Return
FiveCycles:
IFound = 1
TotalCycles = TotalCycles + 5 ' add 5 cycles
Return
SixCycles:
IFound = 1
TotalCycles = TotalCycles + 5 ' add 5 cycles
Return


' 8 bit load
Load8:
IFound = 1
TotalCycles = TotalCycles + 2 ' Default 8 bit load for immediate load
Return
Load16:
IFound = 1
TotalCycles = TotalCycles + 3 ' Default 16 bit load for immediate load
Return
LEA:
IFound = 1
TotalCycles = TotalCycles + 4 ' minimum LEA cycles
Temp$ = Left$(Instr2$, Len(Instr2$) - 2)
p = InStr(Temp$, "*")
Oper2 = Val(Mid$(Temp$, p + 1))
v = Oper2 * 128
p = InStr(Temp$, "+")
If p > 0 Then v = v + Val(Left$(Temp$, p - 1))
If v <> 0 Then TotalCycles = TotalCycles + 1 ' not 0 then minimum takes 1 more cycle
If v > 127 Or v < -127 Then TotalCycles = TotalCycles + 2 ' it takes 2 more cycles (large value)
Return
AIM:
IFound = 1
TotalCycles = TotalCycles + 7 ' minimum AIM cycles
Temp$ = Left$(Instr2$, Len(Instr2$) - 2)
If Right$(Temp$, 1) <> ";" Then
    ' There is a value here
    p = InStr(Temp$, ";")
    v = Val(Mid$(Temp$, p + 1))
    If v <> 0 Then TotalCycles = TotalCycles + 1 ' not 0 then minimum takes 1 more cycle
    If v > 127 Or v < -127 Then TotalCycles = TotalCycles + 2 ' it takes 2 more cycles (large value)
End If
Return
PSHU_Calc:
IFound = 1
TotalCycles = TotalCycles + 5 ' minimum PSHU cycles
If Instr2$ = "A,B" Then TotalCycles = TotalCycles + 1
If Instr2$ = "A,X" Then TotalCycles = TotalCycles + 2
If Instr2$ = "D,X" Then TotalCycles = TotalCycles + 3
If Instr2$ = "A,X,Y" Then TotalCycles = TotalCycles + 4
If Instr2$ = "D,X,Y" Then TotalCycles = TotalCycles + 5
Return
Store:
IFound = 1
TotalCycles = TotalCycles + 4 ' minimum ST cycles
If Len(Instr2$) <> 2 Then
    ' There is a value here
    Temp$ = Left$(Instr2$, Len(Instr2$) - 2)
    v = Val(Temp$)
    If v <> 0 Then TotalCycles = TotalCycles + 1 ' not 0 then minimum takes 1 more cycle
    If v > 127 Or v < -127 Then TotalCycles = TotalCycles + 2 ' it takes 2 more cycles (large value)
End If
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

' Count how many times this pattern is used in the sprite
CheckForPattern:
PatternCount = 0
For TestY = 0 To imageHeight - 1 ' Test through all the rows
    For TestX = 0 To imageWidth - 1 Step 2 'Test through all the columns, even number columns only
        Found = 1
        For t = 0 To patternLength - 1
            If TestX + t > imageWidth - 1 Then Found = 0: Exit For
            If Pattern(t) <> Pixels(TestX + t, TestY) Or Pixels(TestX + t, TestY) > 15 Then
                Found = 0
                Exit For
            End If
        Next t
        If Found = 1 Then
            'We found a copy of the pattern
            PatternCount = PatternCount + 1 ' Increment the counter
            PatX = TestX: PatY = TestY
            ' Mark these pixels as unusable
            For t = 0 To patternLength - 1
                Pixels(TestX + t, TestY) = 17
            Next t
        End If
    Next TestX
Next TestY
Return


' Convert 24 bit RGB value to CoCo 3 palette number to use
' Input 24 bit colour value in variable named RGB
' Output CoCo 3 Palette number in CCPal
ConvertRGB2CoCo3Palette:
Dim minDistance As Long
minDistance = 99999999 ' Arbitrary large number
R = Int(RGB / 65536)
G = (RGB And 65280) / 256
b = RGB And 255
'Print "RGB="; Hex$(RGB), R, G, B
'Print Hex$(R), Hex$(G), Hex$(B)
' Calculate Euclidean distance
For i = 0 To 15
    Rp = Int(pal(i) / 65536)
    Gp = (pal(i) And 65280) / 256
    Bp = pal(i) And 255
    '     distance = (r - RED(palette(i)))^2 + (g - GREEN(palette(i)))^2 + (b - BLUE(palette(i)))^2
    distance = (R - Rp) ^ 2 + (G - Gp) ^ 2 + (b - Bp) ^ 2
    If distance < minDistance Then
        minDistance = distance
        CCPal = i
    End If
Next
Return
'Show the current sprite data - in array CopyOfPixels
ShowUpdatedSprite:
If Verbose > 1 Then
    Print "Image Width:"; imageWidth, "Image Height:"; imageHeight
    For Y = 0 To imageHeight - 1
        Print Hex$(Y); " ";
        For X = 0 To imageWidth - 1
            v = CopyOfPixels(X, Y)
            If v < 16 Then
                Print Hex$(v);
            Else
                If v = 16 Then Print ".";
                If v = 17 Then Print "U";
            End If
        Next X
        Print
    Next Y
End If
Return
ShowSpriteInFile:
Print #2, "; Source filename: "; FileName$
Print #2, "; Image Width:"; imageWidth, "Image Height:"; imageHeight
For Y = 0 To imageHeight - 1
    Print #2, "; "; Right$("00" + Right$(Str$(Y), Len(Str$(Y)) - 1), 3); " ";
    For X = 0 To imageWidth - 1
        v = Pixels(X, Y)
        If v < 16 Then
            Print #2, Hex$(v);
        Else
            If v = 16 Then Print #2, ".";
            If v = 17 Then Print #2, "U";
        End If
    Next X
    Print #2,
Next Y
Return

ShowSpriteOnScreen:
Print "; Source filename: "; FileName$
Print "; Image Width:"; imageWidth, "Image Height:"; imageHeight
For Y = 0 To imageHeight - 1
    Print "; "; Right$("00" + Right$(Str$(Y), Len(Str$(Y)) - 1), 3); " ";
    For X = 0 To imageWidth - 1
        v = Pixels(X, Y)
        If v < 16 Then
            Print Hex$(v);
        Else
            If v = 16 Then Print ".";
            If v = 17 Then Print "U";
        End If
    Next X
    Print
Next Y
Return



'Makes every value in Sprite$()="ZZ"
ClearSpriteArray:
For i = 0 To 150
    Sprite$(i) = "ZZ"
Next i
Return

'Enter with U as the starting poistion that matches Sprite$(0), could be a negative if Looking at the left of U for bytes to write
'SEnd is the end of the sprite$ array to test with
StoreBytesAtU:
SEnd = SEnd - 1
'Print "U pos is:"; U
'Print #2, "; SEnd"; SEnd; " ";
'For i = 0 To SEnd
'    Print #2, Sprite$(i);
'Next i
'Print #2,
KeepChecking:
If SEnd > 2 Then
    For i = 0 To SEnd - 3
        If A$ = Sprite$(i) And B$ = Sprite$(i + 1) And E$ = Sprite$(i + 2) And F$ = Sprite$(i + 3) Then
            Instr1$ = "STQ"
            GoTo CalcNLocation ' Output relative location of ,U
        End If
    Next i
End If
If SEnd > 0 Then
    For i = 0 To SEnd - 1
        If A$ = Sprite$(i) And B$ = Sprite$(i + 1) Then
            Instr1$ = "STD"
            GoTo CalcNLocation ' Output relative location of ,U
        End If
    Next i
End If
If SEnd > 0 Then
    For i = 0 To SEnd - 1
        If X$ = Sprite$(i) + Sprite$(i + 1) Then
            Instr1$ = "STX"
            GoTo CalcNLocation ' Output relative location of ,U
        End If
    Next i
End If
If SEnd > 0 Then
    For i = 0 To SEnd - 1
        If Y$ = Sprite$(i) + Sprite$(i + 1) Then
            Instr1$ = "STY"
            GoTo CalcNLocation ' Output relative location of ,U
        End If
    Next i
End If
If SEnd > 0 Then
    For i = 0 To SEnd - 1
        If E$ = Sprite$(i) And F$ = Sprite$(i + 1) Then
            Instr1$ = "STW"
            GoTo CalcNLocation ' Output relative location of ,U
        End If
    Next i
End If
For i = 0 To SEnd
    If A$ = Sprite$(i) Then
        Instr1$ = "STA"
        GoTo CalcNLocation ' Output relative location of ,U
    End If
Next i
For i = 0 To SEnd
    If B$ = Sprite$(i) Then
        Instr1$ = "STB"
        GoTo CalcNLocation ' Output relative location of ,U
    End If
Next i
' If we get here then no more stores needed, return
Return

' Print the relative location of the ST from FoundA
CalcNLocation:
n = URelative + i ' Byte position in row
BytePos = XPos * 2 + URelative * 2 + i * 2
'Print #2, "; BytePos is"; BytePos; " i is"; i; "Xpos is"; XPos; " URelative is"; URelative

If Instr1$ = "STA" Then Sprite$(i) = "ZZ": ByteCount = 1: GoSub FlagBytesAsUsed
If Instr1$ = "STB" Then Sprite$(i) = "ZZ": ByteCount = 1: GoSub FlagBytesAsUsed
If Instr1$ = "STD" Then Sprite$(i) = "ZZ": Sprite$(i + 1) = "ZZ": ByteCount = 2: GoSub FlagBytesAsUsed
If Instr1$ = "STQ" Then Sprite$(i) = "ZZ": Sprite$(i + 1) = "ZZ": Sprite$(i + 2) = "ZZ": Sprite$(i + 3) = "ZZ": ByteCount = 4: GoSub FlagBytesAsUsed
If Instr1$ = "STX" Then Sprite$(i) = "ZZ": Sprite$(i + 1) = "ZZ": ByteCount = 2: GoSub FlagBytesAsUsed
If Instr1$ = "STY" Then Sprite$(i) = "ZZ": Sprite$(i + 1) = "ZZ": ByteCount = 2: GoSub FlagBytesAsUsed
If Instr1$ = "STW" Then Sprite$(i) = "ZZ": Sprite$(i + 1) = "ZZ": ByteCount = 2: GoSub FlagBytesAsUsed
GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
Instr2$ = N$ + ",U"
GoSub DoOutput ' Print the output
GoTo KeepChecking

' Flag bytes in send() as used
FlagBytesAsUsed:
'Print "BytePos:"; BytePos
For Nibbles1 = 1 To ByteCount * 2
    CopyOfPixels(BytePos + Nibbles1 - 1, YPos) = 17 ' Flag nibble as used
Next Nibbles1
Return

'Convert Hex value in T$ to it's complement and output the result in ComplementHex$
DoComplement:
' Convert input hex string to a numeric value
OriginalValue = Val("&H" + T$)

' Calculate 8-bit complement
ComplementedValue = 255 - OriginalValue ' 255 is the maximum value for 8 bits

' Convert complement value back to hex string
ComplementHex$ = Hex$(ComplementedValue)

' Ensure the result is a 2-digit hex string
If Len(ComplementHex$) < 2 Then
    ComplementHex$ = "0" + ComplementHex$
End If
Return

'Convert Hex value in T$ to it's negative value and return with the result in NegativeHex$
DoNegative:
' Convert hex string to integer
OriginalValue = Val("&H" + T$)

' Perform two's complement negation
' 255 is the max value for an 8-bit number, so subtract from 255 and add 1
NegatedValue = 255 - OriginalValue + 1

' Ensure the value is treated as 8-bit
NegatedValue = NegatedValue And 255

' Convert back to hex string
NegativeHex$ = Hex$(NegatedValue)

' Ensure the result is a 2-digit hex string
If Len(NegativeHex$) < 2 Then
    NegativeHex$ = "0" + NegativeHex$
End If
Return

DoDec:
' Convert hex string to integer
OriginalValue = Val("&H" + T$)

' Perform decrement
DecrementedValue = OriginalValue - 1

' Handle underflow for 8-bit value
If DecrementedValue < 0 Then
    DecrementedValue = 255
End If

' Convert back to hex string
DecrementedHex$ = Hex$(DecrementedValue)

' Ensure the result is a 2-digit hex string
If Len(DecrementedHex$) < 2 Then
    DecrementedHex$ = "0" + DecrementedHex$
End If
Return

DoInc:
' Convert hex string to integer
OriginalValue = Val("&H" + T$)

' Perform increment
IncrementedValue = OriginalValue + 1

' Handle overflow for 8-bit value
If IncrementedValue > 255 Then
    IncrementedValue = 0
End If

' Convert back to hex string
IncrementedHex$ = Hex$(IncrementedValue)

' Ensure the result is a 2-digit hex string
If Len(IncrementedHex$) < 2 Then
    IncrementedHex$ = "0" + IncrementedHex$
End If
Return


' ASLA & ASLB - same as LSLA & LSLB
DoLSL:
' Convert hex string to an 8-bit integer
OriginalValue = Val("&H" + T$)
' Perform arithmetic shift left (multiply by 2)
ShiftedValue = OriginalValue * 2
' Handle overflow for 8-bit value
ShiftedValue = ShiftedValue And &HFF
' Convert back to hex string
LSLHex$ = Hex$(ShiftedValue)
' Ensure the result is a 2-digit hex string
If Len(LSLHex$) < 2 Then
    LSLHex$ = "0" + LSLHex$
End If
Return

' ASRA & ASRB
DoASR:
' Convert hex string to an 8-bit integer
OriginalValue = Val("&H" + T$)
' Perform arithmetic shift right (divide by 2 and preserve the sign bit)
ShiftedValue = (OriginalValue \ 2) Or (OriginalValue And &H80)
' Handle 8-bit value representation
ShiftedValue = ShiftedValue And &HFF
' Convert back to hex string
ASRHex$ = Hex$(ShiftedValue)
' Ensure the result is a 2-digit hex string
If Len(ASRHex$) < 2 Then
    ASRHex$ = "0" + ASRHex$
End If
Return

' LSRA & LSRB
DoLSR:
' Convert hex string to an 8-bit integer
OriginalValue = Val("&H" + T$)
' Perform logical shift right (divide by 2)
ShiftedValue = OriginalValue \ 2
' Handle 8-bit value representation
ShiftedValue = ShiftedValue And &HFF
' Convert back to hex string
LSRHex$ = Hex$(ShiftedValue)
' Ensure the result is a 2-digit hex string
If Len(LSRHex$) < 2 Then
    LSRHex$ = "0" + LSRHex$
End If
Return

'ROLA & ROLB
DoRol:
' Convert hex string to an 8-bit integer
OriginalValue = Val("&H" + T$)
' Perform rotate left (shift left and wrap around the leftmost bit)
RotatedValue = (OriginalValue * 2) And &HFF
' Check if the leftmost bit was 1 before rotation
If (OriginalValue And &H80) Then
    RotatedValue = RotatedValue Or 1
End If
' Convert back to hex string
ROLHex$ = Hex$(RotatedValue)
' Ensure the result is a 2-digit hex string
If Len(ROLHex$) < 2 Then
    ROLHex$ = "0" + ROLHex$
End If
Return

' RORA & RORB
DoRor:
' Convert hex string to an 8-bit integer
OriginalValue = Val("&H" + T$)
' Perform rotate right (shift right and wrap around the rightmost bit)
RotatedValue = (OriginalValue \ 2) Or ((OriginalValue And 1) * &H80)
' Handle 8-bit value representation
RotatedValue = RotatedValue And &HFF
' Convert back to hex string
RORHex$ = Hex$(RotatedValue)
' Ensure the result is a 2-digit hex string
If Len(RORHex$) < 2 Then
    RORHex$ = "0" + RORHex$
End If
Return

DoInc16:
' Convert hex string to a 16-bit integer
OriginalValue = Val("&H" + T$)

' Perform increment
IncrementedValue = OriginalValue + 1

' Handle overflow for 16-bit value
If IncrementedValue > &HFFFF Then
    IncrementedValue = 0
End If

' Convert back to hex string
IncrementedHex$ = Hex$(IncrementedValue)

' Ensure the result is a 4-digit hex string
While Len(IncrementedHex$) < 4
    IncrementedHex$ = "0" + IncrementedHex$
Wend
Return

DoDec16:
' Convert hex string to a 16-bit integer
OriginalValue = Val("&H" + T$)

' Perform decrement
DecrementedValue = OriginalValue - 1

' Handle underflow for 16-bit value
If DecrementedValue < 0 Then
    DecrementedValue = &HFFFF ' Maximum value for 16-bit
End If

' Convert back to hex string
DecrementedHex$ = Hex$(DecrementedValue)

' Ensure the result is a 4-digit hex string
While Len(DecrementedHex$) < 4
    DecrementedHex$ = "0" + DecrementedHex$
Wend
Return
DoComplement16:
' Convert hex string to a 16-bit integer
OriginalValue = Val("&H" + T$)

' Perform one's complement operation
ComplementedValue = Not OriginalValue

' Handle 16-bit value representation
ComplementedValue = ComplementedValue And &HFFFF

' Convert back to hex string
ComplementedHex$ = Hex$(ComplementedValue)

' Ensure the result is a 4-digit hex string
While Len(ComplementedHex$) < 4
    ComplementedHex$ = "0" + ComplementedHex$
Wend
Return

DoNegative16:
' Convert hex string to a 16-bit integer
OriginalValue = Val("&H" + T$)

' Perform two's complement negation
' First, invert all the bits
NegatedValue = Not OriginalValue

' Then, add 1
NegatedValue = NegatedValue + 1

' Handle 16-bit value representation
NegatedValue = NegatedValue And &HFFFF

' Convert back to hex string
NegatedHex$ = Hex$(NegatedValue)

' Ensure the result is a 4-digit hex string
While Len(NegatedHex$) < 4
    NegatedHex$ = "0" + NegatedHex$
Wend
Return


' ASRD - there is no ASRW
DoASR16:
' Convert hex string to a 16-bit integer
OriginalValue = Val("&H" + T$)
' Perform arithmetic shift right (divide by 2)
ShiftedValue = OriginalValue \ 2
' If the original value was negative, preserve the sign bit
If (OriginalValue And &H8000) Then
    ShiftedValue = ShiftedValue Or &H8000
End If
' Convert back to hex string
ASRHex$ = Hex$(ShiftedValue)
' Ensure the result is a 4-digit hex string
While Len(ASRHex$) < 4
    ASRHex$ = "0" + ASRHex$
Wend
Return

'LSLD - there is no LSLW
DoLSL16:
' Convert hex string to a 16-bit integer
OriginalValue = Val("&H" + T$)
' Perform logical shift left (multiply by 2)
ShiftedValue = OriginalValue * 2
' Handle overflow for 16-bit value
ShiftedValue = ShiftedValue And &HFFFF
' Convert back to hex string
LSLHex$ = Hex$(ShiftedValue)
' Ensure the result is a 4-digit hex string
While Len(LSLHex$) < 4
    LSLHex$ = "0" + LSLHex$
Wend
Return
'LSRD  & LSRW
DoLSR16:
' Convert hex string to a 16-bit integer
OriginalValue = Val("&H" + T$)
' Perform arithmetic shift right (divide by 2)
ShiftedValue = OriginalValue \ 2
' If the original value was negative, set the highest bit
If (OriginalValue And &H8000) Then
    ShiftedValue = ShiftedValue Or &H8000
End If
' Convert back to hex string
LSRHex$ = Hex$(ShiftedValue)
' Ensure the result is a 4-digit hex string
While Len(LSRHex$) < 4
    LSRHex$ = "0" + LSRHex$
Wend
Return
'ROLD & ROLW
DoRol16:
' Convert hex string to a 16-bit integer
OriginalValue = Val("&H" + T$)
' Perform rotate left (shift left and wrap around the leftmost bit)
RotatedValue = (OriginalValue * 2) And &HFFFF
' Check if the leftmost bit was 1 before rotation
If (OriginalValue And &H8000) Then
    RotatedValue = RotatedValue Or 1
End If
' Convert back to hex string
ROLHex$ = Hex$(RotatedValue)
' Ensure the result is a 4-digit hex string
While Len(ROLHex$) < 4
    ROLHex$ = "0" + ROLHex$
Wend
Return
'RORD & RORW
DoRor16:
' Convert hex string to a 16-bit integer
OriginalValue = Val("&H" + T$)
' Perform rotate right (shift right and wrap around the rightmost bit)
RotatedValue = (OriginalValue \ 2) Or ((OriginalValue And 1) * &H8000)
' Convert back to hex string
RORHex$ = Hex$(RotatedValue)
' Ensure the result is a 4-digit hex string
While Len(RORHex$) < 4
    RORHex$ = "0" + RORHex$
Wend
Return

' Enter with Xpos = position in the row
' If possible do a PSHU and return with MoveX with the amount to move left (negative value)
CheckandDoBlast:
DidBlast = 1
' Check if we can store 6 bytes at Xpos
If XPos > 5 Then
    ' check if we can do a PSHU D,X,Y
    StartX = XPos * 2 - 12
    If A$ = Hex$(CopyOfPixels(StartX, YPos)) + Hex$(CopyOfPixels(StartX + 1, YPos)) Then
        'A$ is good see if we can also do B$
        If B$ = Hex$(CopyOfPixels(StartX + 2, YPos)) + Hex$(CopyOfPixels(StartX + 3, YPos)) Then
            'B$ is good see if we can also do X$
            If X$ = Hex$(CopyOfPixels(StartX + 4, YPos)) + Hex$(CopyOfPixels(StartX + 5, YPos)) + Hex$(CopyOfPixels(StartX + 6, YPos)) + Hex$(CopyOfPixels(StartX + 7, YPos)) Then
                'X$ is good see if we can also do X$
                If Y$ = Hex$(CopyOfPixels(StartX + 8, YPos)) + Hex$(CopyOfPixels(StartX + 9, YPos)) + Hex$(CopyOfPixels(StartX + 10, YPos)) + Hex$(CopyOfPixels(StartX + 11, YPos)) Then
                    'Y$ is good, do a PSHU D,X,Y
                    Instr1$ = "PSHU": Instr2$ = "D,X,Y"
                    Com$ = "Blast the registers to the screen": GoSub DoOutput ' Print the output
                    For X = StartX To StartX + 11
                        CopyOfPixels(X, YPos) = 17 ' mark bytes as used
                        Pixels(X, YPos) = 17 ' mark bytes as used
                    Next X
                    MoveX = -6
                    XPos = XPos + MoveX
                    Return
                End If
            End If
        End If
    End If
End If
' Check if we can store 5 bytes at Xpos
If XPos > 4 Then
    ' check if we can do a PSHU A,X,Y
    StartX = XPos * 2 - 10
    If A$ = Hex$(CopyOfPixels(StartX, YPos)) + Hex$(CopyOfPixels(StartX + 1, YPos)) Then
        'A$ is good see if we can also do X$
        If X$ = Hex$(CopyOfPixels(StartX + 2, YPos)) + Hex$(CopyOfPixels(StartX + 3, YPos)) + Hex$(CopyOfPixels(StartX + 4, YPos)) + Hex$(CopyOfPixels(StartX + 5, YPos)) Then
            'X$ is good see if we can also do X$
            If Y$ = Hex$(CopyOfPixels(StartX + 6, YPos)) + Hex$(CopyOfPixels(StartX + 7, YPos)) + Hex$(CopyOfPixels(StartX + 8, YPos)) + Hex$(CopyOfPixels(StartX + 9, YPos)) Then
                'Y$ is good, do a PSHU A,X,Y
                Instr1$ = "PSHU": Instr2$ = "A,X,Y"
                Com$ = "Blast the registers to the screen": GoSub DoOutput ' Print the output
                For X = StartX To StartX + 9
                    CopyOfPixels(X, YPos) = 17 ' mark bytes as used
                    Pixels(X, YPos) = 17 ' mark bytes as used
                Next X
                MoveX = -5
                XPos = XPos + MoveX
                Return
            End If
        End If
    End If
End If
' Check if we can store 5 bytes at Xpos
If XPos > 4 Then
    ' check if we can do a PSHU B,X,Y
    StartX = XPos * 2 - 10
    If B$ = Hex$(CopyOfPixels(StartX, YPos)) + Hex$(CopyOfPixels(StartX + 1, YPos)) Then
        'B$ is good see if we can also do X$
        If X$ = Hex$(CopyOfPixels(StartX + 2, YPos)) + Hex$(CopyOfPixels(StartX + 3, YPos)) + Hex$(CopyOfPixels(StartX + 4, YPos)) + Hex$(CopyOfPixels(StartX + 5, YPos)) Then
            'X$ is good see if we can also do X$
            If Y$ = Hex$(CopyOfPixels(StartX + 6, YPos)) + Hex$(CopyOfPixels(StartX + 7, YPos)) + Hex$(CopyOfPixels(StartX + 8, YPos)) + Hex$(CopyOfPixels(StartX + 9, YPos)) Then
                'Y$ is good, do a PSHU A,X,Y
                Instr1$ = "PSHU": Instr2$ = "B,X,Y"
                Com$ = "Blast the registers to the screen": GoSub DoOutput ' Print the output
                For X = StartX To StartX + 9
                    CopyOfPixels(X, YPos) = 17 ' mark bytes as used
                    Pixels(X, YPos) = 17 ' mark bytes as used
                Next X
                MoveX = -5
                XPos = XPos + MoveX
                Return
            End If
        End If
    End If
End If
' Check if we can store 4 bytes at Xpos
If XPos > 3 Then
    ' check if we can do a PSHU D,X
    StartX = XPos * 2 - 8
    If A$ = Hex$(CopyOfPixels(StartX, YPos)) + Hex$(CopyOfPixels(StartX + 1, YPos)) Then
        'A$ is good see if we can also do B$
        If B$ = Hex$(CopyOfPixels(StartX + 2, YPos)) + Hex$(CopyOfPixels(StartX + 3, YPos)) Then
            'B$ is good see if we can also do X$
            If X$ = Hex$(CopyOfPixels(StartX + 4, YPos)) + Hex$(CopyOfPixels(StartX + 5, YPos)) + Hex$(CopyOfPixels(StartX + 6, YPos)) + Hex$(CopyOfPixels(StartX + 7, YPos)) Then
                'X$ is good see if we can also do X$
                Instr1$ = "PSHU": Instr2$ = "D,X"
                Com$ = "Blast the registers to the screen": GoSub DoOutput ' Print the output
                For X = StartX To StartX + 7
                    CopyOfPixels(X, YPos) = 17 ' mark bytes as used
                    Pixels(X, YPos) = 17 ' mark bytes as used
                Next X
                MoveX = -4
                XPos = XPos + MoveX
                Return
            End If
        End If
    End If
End If
' Check if we can store 4 bytes at Xpos
If XPos > 3 Then
    ' check if we can do a PSHU D,Y
    StartX = XPos * 2 - 8
    If A$ = Hex$(CopyOfPixels(StartX, YPos)) + Hex$(CopyOfPixels(StartX + 1, YPos)) Then
        'A$ is good see if we can also do B$
        If B$ = Hex$(CopyOfPixels(StartX + 2, YPos)) + Hex$(CopyOfPixels(StartX + 3, YPos)) Then
            'B$ is good see if we can also do X$
            If Y$ = Hex$(CopyOfPixels(StartX + 4, YPos)) + Hex$(CopyOfPixels(StartX + 5, YPos)) + Hex$(CopyOfPixels(StartX + 6, YPos)) + Hex$(CopyOfPixels(StartX + 7, YPos)) Then
                'X$ is good see if we can also do X$
                Instr1$ = "PSHU": Instr2$ = "D,Y"
                Com$ = "Blast the registers to the screen": GoSub DoOutput ' Print the output
                For X = StartX To StartX + 7
                    CopyOfPixels(X, YPos) = 17 ' mark bytes as used
                    Pixels(X, YPos) = 17 ' mark bytes as used
                Next X
                MoveX = -4
                XPos = XPos + MoveX
                Return
            End If
        End If
    End If
End If
' Check if we can store 4 bytes at Xpos
If XPos > 3 Then
    ' check if we can do a PSHU X,Y
    StartX = XPos * 2 - 8
    If X$ = Hex$(CopyOfPixels(StartX, YPos)) + Hex$(CopyOfPixels(StartX + 1, YPos)) + Hex$(CopyOfPixels(StartX + 2, YPos)) + Hex$(CopyOfPixels(StartX + 3, YPos)) Then
        'X$ is good see if we can also do X$
        If Y$ = Hex$(CopyOfPixels(StartX + 4, YPos)) + Hex$(CopyOfPixels(StartX + 5, YPos)) + Hex$(CopyOfPixels(StartX + 6, YPos)) + Hex$(CopyOfPixels(StartX + 7, YPos)) Then
            'Y$ is good, do a PSHU X,Y
            Instr1$ = "PSHU": Instr2$ = "X,Y"
            Com$ = "Blast the registers to the screen": GoSub DoOutput ' Print the output
            For X = StartX To StartX + 7
                CopyOfPixels(X, YPos) = 17 ' mark bytes as used
                Pixels(X, YPos) = 17 ' mark bytes as used
            Next X
            MoveX = -4
            XPos = XPos + MoveX
            Return
        End If
    End If
End If
' Flag that we didn't do any blasting at this location
DidBlast = 0
Return

' Write .asm file with code to save and restore the graphics data behind this sprite
SaveRestoreBack:
StackBytes = 50 ' Extra bytes at the beginning of the background buffer
n = imageWidth: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
' Filename without the extension
' FNameNoExt$
SaveReBack$ = "SaveReBack_" + FNameNoExt$ + "_" + N$ + "x"
'CodeName$ = "SaveBackground_" + N$ + "x"
n = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
'CodeName$ = CodeName$ + N$ + ".asm"
SaveReBack$ = SaveReBack$ + N$ + ".asm"
'Open CodeName$ For Output As #2
Open SaveReBack$ For Output As #2

Print #2, "* Enter with:"
Print #2, "* U pointing to the top left corner of where the sprite will be displayed"
Print #2, "* X pointing to the start of the background buffer"
Print #2, "* Exits with X = Original U value (Starting point of sprite on screen), all other registers are clobbered"
Print #2, "* Routine leaves"; StackBytes; "extra bytes at the beginning of the buffer to allow for (F)IRQs using the stack space temporarily"
Print #2, "* This will need a buffer size of $"; Hex$(StackBytes + Int(imageWidth / 2) * imageHeight); " bytes."
Print #2, "*"
n = imageWidth: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
T$ = "* Backup behind a " + N$ + " x "
n = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
T$ = T$ + N$ + " Sprite"
Print #2, T$
'N = imageWidth: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
'T$ = "BackUp_" + FNameNoExt$ + "_" + N$ + "x"
'N = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
'T$ = T$ + N$ + ":"
'Print #2, T$
Print #2, "BackUp_"; FNameNoExt$; ":"
n = imageWidth: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
T$ = "* Backup behind a " + N$ + " x "
n = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
T$ = T$ + N$ + " Sprite"

'N = imageWidth: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
T$ = "BackedUp_" + FNameNoExt$: ' + "_" + N$
'N = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
'T$ = T$ + "x" + N$

Instr1$ = "PSHS": Instr2$ = "U": Com$ = "Save the U register, Exits with this value in X as the next routine will probably draw the sprite at this location": GoSub DoOutput ' Print the output

Instr1$ = "STS": Instr2$ = T$ + "+2": Com$ = "Backup the stack (self mod below)": GoSub DoOutput ' Print the output
n = Int(imageWidth / 2): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
StorageLoc$ = N$
n = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
StorageLoc$ = StorageLoc$ + "*" + N$
Instr1$ = "LEAS": Instr2$ = "50+" + StorageLoc$ + ",X": Com$ = "Move S to the bottom of the RAM you want to store the sprite": GoSub DoOutput ' Print the output

' Set the width to the value you have
width1 = Int(imageWidth / 2) ' divide by two becuase each byte is two pixels

' Calculate how many full D, X, Y sets can be read
FullSets = width1 \ 6
RemainingBytes = width1 Mod 6

For Y = 0 To imageHeight - 1
    ' Read the full sets of D, X, Y
    n = 0
    For i = 1 To FullSets
        n = n + 6: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr1$ = "PULU": Instr2$ = "D,X,Y": Com$ = "Read " + N$ + " Bytes": GoSub DoOutput ' Print the output
        Instr1$ = "PSHS": Instr2$ = "D,X,Y": Com$ = "Stored " + N$ + " Bytes": GoSub DoOutput ' Print the output
    Next i
    n = n + RemainingBytes: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    ' Handle the remaining bytes
    Select Case RemainingBytes
        Case 1
            Instr1$ = "PULU": Instr2$ = "A": Com$ = "Read " + N$ + " Bytes": GoSub DoOutput ' Print the output
            Instr1$ = "PSHS": Instr2$ = "A": Com$ = "Stored " + N$ + " Bytes": GoSub DoOutput ' Print the output
        Case 2
            Instr1$ = "PULU": Instr2$ = "D": Com$ = "Read " + N$ + " Bytes": GoSub DoOutput ' Print the output
            Instr1$ = "PSHS": Instr2$ = "D": Com$ = "Stored " + N$ + " Bytes": GoSub DoOutput ' Print the output
        Case 3
            Instr1$ = "PULU": Instr2$ = "A,X": Com$ = "Read " + N$ + " Bytes": GoSub DoOutput ' Print the output
            Instr1$ = "PSHS": Instr2$ = "A,X": Com$ = "Stored " + N$ + " Bytes": GoSub DoOutput ' Print the output
        Case 4
            Instr1$ = "PULU": Instr2$ = "D,X": Com$ = "Read " + N$ + " Bytes": GoSub DoOutput ' Print the output
            Instr1$ = "PSHS": Instr2$ = "D,X": Com$ = "Stored " + N$ + " Bytes": GoSub DoOutput ' Print the output
        Case 5
            Instr1$ = "PULU": Instr2$ = "A,X,Y": Com$ = "Read " + N$ + " Bytes": GoSub DoOutput ' Print the output
            Instr1$ = "PSHS": Instr2$ = "A,X,Y": Com$ = "Stored " + N$ + " Bytes": GoSub DoOutput ' Print the output
    End Select
    If Y < imageHeight - 1 Then
        n = Int(imageWidth / 2): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr1$ = "LEAU": Instr2$ = "128-" + N$ + ",U"
        n = Y + 1: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Com$ = "Move down to the start of row " + N$: GoSub DoOutput ' Print the output
    End If
Next Y
Print #2, T$; ":"
Instr1$ = "LDS": Instr2$ = "#$FFFF": Com$ = "Restore the stack (self modded above)": GoSub DoOutput ' Print the output
Instr1$ = "PULS": Instr2$ = "X,PC": Com$ = "All done restore X with the location where the sprite will be drawn and return": GoSub DoOutput ' Print the output
Print #2, "; Total Cycles is"; TotalCycles

' Write code to do the restore of data behind the sprite
TotalCycles = 0
Print #2, "* Enter with:"
Print #2, "* U pointing to the top left corner of where the sprite was displayed"
Print #2, "* X pointing to the start of the background buffer"
Print #2, "* All registers are clobbered"
Print #2, "* Routine leaves"; StackBytes; "extra bytes at the beginning of the buffer to allow for (F)IRQs using the stack space temporarily"
Print #2, "* This will need a buffer size of $"; Hex$(StackBytes + Int(imageWidth / 2) * imageHeight); " bytes."
Print #2, "*"
n = imageWidth: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
T$ = "* Restore what was behind a " + N$ + " x "
n = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
T$ = T$ + N$ + " Sprite"
Print #2, T$
'N = imageWidth: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
'T$ = "Restore_" + FNameNoExt$ + "_" + N$ + "x"
'N = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
'T$ = T$ + N$ + ":"
'Print #2, T$
Print #2, "Restore_"; FNameNoExt$; ":"
n = imageWidth: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
T$ = "* Restore what was behind a " + N$ + " x "
n = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
T$ = T$ + N$ + " Sprite"

'N = imageWidth: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
T$ = "Restored_" + FNameNoExt$: ' + "_" + N$
'N = imageHeight: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
'T$ = T$ + "x" + N$
Instr1$ = "STS": Instr2$ = T$ + "+2": Com$ = "Backup the stack (self mod below)": GoSub DoOutput ' Print the output
Instr1$ = "LEAS": Instr2$ = "50,X": Com$ = "Move S to the start of the background data": GoSub DoOutput ' Print the output
n = imageHeight - 1: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
Instr1$ = "LEAU": Instr2$ = N$ + "*128"
n = Int(imageWidth / 2): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
Instr2$ = Instr2$ + "+" + N$ + ",U": Com$ = "Move U to the start of the bottom row": GoSub DoOutput ' Print the output

For Y = imageHeight - 1 To 0 Step -1
    n = 0
    n = n + RemainingBytes: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
    ' Handle the remaining bytes
    Select Case RemainingBytes
        Case 1
            Instr1$ = "PULS": Instr2$ = "A": Com$ = "Read " + N$ + " Bytes": GoSub DoOutput ' Print the output
            Instr1$ = "PSHU": Instr2$ = "A": Com$ = "Stored " + N$ + " Bytes": GoSub DoOutput ' Print the output
        Case 2
            Instr1$ = "PULS": Instr2$ = "D": Com$ = "Read " + N$ + " Bytes": GoSub DoOutput ' Print the output
            Instr1$ = "PSHU": Instr2$ = "D": Com$ = "Stored " + N$ + " Bytes": GoSub DoOutput ' Print the output
        Case 3
            Instr1$ = "PULS": Instr2$ = "A,X": Com$ = "Read " + N$ + " Bytes": GoSub DoOutput ' Print the output
            Instr1$ = "PSHU": Instr2$ = "A,X": Com$ = "Stored " + N$ + " Bytes": GoSub DoOutput ' Print the output
        Case 4
            Instr1$ = "PULS": Instr2$ = "D,X": Com$ = "Read " + N$ + " Bytes": GoSub DoOutput ' Print the output
            Instr1$ = "PSHU": Instr2$ = "D,X": Com$ = "Stored " + N$ + " Bytes": GoSub DoOutput ' Print the output
        Case 5
            Instr1$ = "PULS": Instr2$ = "A,X,Y": Com$ = "Read " + N$ + " Bytes": GoSub DoOutput ' Print the output
            Instr1$ = "PSHU": Instr2$ = "A,X,Y": Com$ = "Stored " + N$ + " Bytes": GoSub DoOutput ' Print the output
    End Select
    ' Read the full sets of D, X, Y
    For i = 1 To FullSets
        n = n + 6: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr1$ = "PULS": Instr2$ = "D,X,Y": Com$ = "Read " + N$ + " Bytes": GoSub DoOutput ' Print the output
        Instr1$ = "PSHU": Instr2$ = "D,X,Y": Com$ = "Stored " + N$ + " Bytes": GoSub DoOutput ' Print the output
    Next i
    If Y >= 0 Then
        n = Int(imageWidth / 2): GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        Instr1$ = "LEAU": Instr2$ = N$ + "-128,U"
        n = Y - 1: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
        If N$ = "" Then N$ = "0"
        Com$ = "Move to the beginning of " + N$: GoSub DoOutput ' Print the output
    End If
Next Y
Print #2, T$; ":"
Instr1$ = "LDS": Instr2$ = "#$FFFF": Com$ = "Restore the stack (self modded above)": GoSub DoOutput ' Print the output
Instr1$ = "RTS": Com$ = "All done backing up data behind where the sprite will be drawn": GoSub DoOutput ' Print the output
Print #2, "; Total Cycles is"; TotalCycles
Close #2
Return

FindBestX:
' Restore values to test Load/Store method
For Y = 0 To imageHeight - 1
    For X = 0 To imageWidth - 1
        Pixels(X, Y) = OrigPixels(X, Y)
        CopyOfPixels(X, Y) = OrigPixels(X, Y) 'Backup to keep track of which pixels have been used for the compiled sprite as we progress
    Next X
Next Y
' Do a LD/ST version
Do1TfrXW = 0 ' Don't add a TFR X,W command so we have a chance of doing STQs
DoTFRMany = 0 ' Do a TFR when we do a LDX #
A$ = "": B$ = "": E$ = "": F$ = "": X$ = "": Y$ = "": U$ = ""
XPos = 0: YPos = 0 ' Sprite drawing location in bytes (not pixels)
OldXPos = 0: OldYPos = 0 ' Used to caclulate ABX values
Outname$ = FName$ + "_JustLDST" + ".asm"
Open Outname$ For Output As #2
Print "Doing Load/Store Method"
' Draw the sprite to the file
GoSub ShowSpriteInFile
Print #2, SpriteName$
TotalCycles = 0
XPos = 0: YPos = 0 ' Sprite drawing location in bytes (not pixels)
OldXPos = 0: OldYPos = 0 ' Used to caclulate LEAX and ABX values
LastY = 0
OldXPos = XPos
OldYPos = YPos
' GoSub ShowUpdatedSprite 'Show the current sprite data - in array CopyOfPixels()
' First time through we find the starting location and move X to the position relative to U's location
'Find new starting position which will be the top row with data on it
'Print "OldXPos"; OldXPos
'Print "OldYPos"; OldYPos
' Find the first row with data
For Y = 0 To imageHeight - 1
    For X = 0 To (imageWidth - 1) Step 2
        '  Print X, Y, Hex$(Pixels(X, Y))
        If Pixels(X, Y) < 16 Or Pixels(X + 1, Y) < 16 Then
            'We just found the location of data that must be dealt with
            'Y = 0
            GoTo SetupXLocation0
        End If
    Next X
    ' Print
Next Y
Y = 0
' Move X to midpoint of this row
SetupXLocation0:
Midpoint = Int(XPoint / 2)
'Print "Midpoint"; Midpoint
'Print "Found data at X="; x; " Y="; Y
'Print "Pixels(X, Y) ="; Pixels(x, Y)
Instr1$ = "LEAX"
MovedX = 0
n = Midpoint - OldXPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
Instr2$ = N$ + "+128*"
n = Y - OldYPos: GoSub NumAsString 'Convert number in N to a string without spaces as N$ - a value of zero is ignored comes back as N$=""
If N$ = "" Then N$ = "0"
Instr2$ = Instr2$ + N$ + ",X"
Com$ = "Position X to start at " + N$ + " of the top row with data": GoSub DoOutput ' Print the output
X = Midpoint
XPos = X: YPos = Y
LastY = Y
GoSub DoLoadStoreOnly
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

