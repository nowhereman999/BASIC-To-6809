$ScreenHide
$Console
_Dest _Console
Verbose = 0

Dim Array(270000) As _Unsigned _Byte
Dim INArray(270000) As _Unsigned _Byte

Dim LabelName$(100000)
Dim NumericVariable$(100000)
Dim NumericVariableCount As Integer

Dim FloatVariable$(100000)
Dim FloatVariableCount As Integer

Dim NumericArrayBits(100000) As Integer
Dim NumericArrayVariables$(100000), NumericArrayDimensions(100000) As Integer, NumericArrayDimensionsVal$(100000)
Dim StringArrayBits(100000) As Integer
Dim StringArrayVariables$(100000), StringArrayDimensions(100000) As Integer, StringArrayDimensionsVal$(100000)
Dim StringVariable$(100000)
Dim StringVariableCounter As Integer

Dim GeneralCommands$(2000)
Dim GeneralCommandsCount As Integer
Dim NumericCommands$(2000)
Dim NumericCommandsCount As Integer
Dim StringCommands$(2000)
Dim StringCommandsCount As Integer
Dim OperatorCommands$(2000)
Dim OperatorCommandsCount As Integer

Dim GeneralCommandsFound$(2000)
Dim GeneralCommandsFoundCount As Integer
Dim NumericCommandsFound$(2000)
Dim NumericCommandsFoundCount As Integer
Dim StringCommandsFound$(2000)
Dim StringCommandsFoundCount As Integer

Dim IncludeList$(10000)

Dim DefLabel$(10000)
Dim DefVar(1000) As Integer

Dim GModeLib(200) As Integer
Dim GModePageLib(200) As Integer


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

GModeName$(0) = "IA": GModeMaxX$(0) = "31": GModeMaxY$(0) = "15": GModeStartAddress$(0) = "400": GModeScreenSize$(0) = "200"
GModeName$(1) = "EA": GModeMaxX$(1) = "31": GModeMaxY$(1) = "15": GModeStartAddress$(1) = "400": GModeScreenSize$(1) = "200"
GModeName$(2) = "SG4": GModeMaxX$(2) = "63": GModeMaxY$(2) = "31": GModeStartAddress$(2) = "400": GModeScreenSize$(2) = "200"
GModeName$(3) = "SG4H": GModeMaxX$(3) = "63": GModeMaxY$(3) = "31": GModeStartAddress$(3) = "E00": GModeScreenSize$(3) = "800"
GModeName$(4) = "SG6": GModeMaxX$(4) = "63": GModeMaxY$(4) = "47": GModeStartAddress$(4) = "400": GModeScreenSize$(4) = "200"
GModeName$(5) = "SG6H": GModeMaxX$(5) = "63": GModeMaxY$(5) = "47": GModeStartAddress$(5) = "E00": GModeScreenSize$(5) = "C00"
GModeName$(6) = "SG8": GModeMaxX$(6) = "63": GModeMaxY$(6) = "63": GModeStartAddress$(6) = "E00": GModeScreenSize$(6) = "800"
GModeName$(7) = "SG12": GModeMaxX$(7) = "63": GModeMaxY$(7) = "95": GModeStartAddress$(7) = "E00": GModeScreenSize$(7) = "C00"
GModeName$(8) = "SG24": GModeMaxX$(8) = "63": GModeMaxY$(8) = "191": GModeStartAddress$(8) = "E00": GModeScreenSize$(8) = "1800"
GModeName$(9) = "FG1C": GModeMaxX$(9) = "63": GModeMaxY$(9) = "63": GModeStartAddress$(9) = "E00": GModeScreenSize$(9) = "400"
GModeName$(10) = "FG1R": GModeMaxX$(10) = "127": GModeMaxY$(10) = "63": GModeStartAddress$(10) = "E00": GModeScreenSize$(10) = "400"
GModeName$(11) = "FG2C": GModeMaxX$(11) = "127": GModeMaxY$(11) = "63": GModeStartAddress$(11) = "E00": GModeScreenSize$(11) = "800"
GModeName$(12) = "FG2R": GModeMaxX$(12) = "127": GModeMaxY$(12) = "95": GModeStartAddress$(12) = "E00": GModeScreenSize$(12) = "600"
GModeName$(13) = "FG3C": GModeMaxX$(13) = "127": GModeMaxY$(13) = "95": GModeStartAddress$(13) = "E00": GModeScreenSize$(13) = "C00"
GModeName$(14) = "FG3R": GModeMaxX$(14) = "127": GModeMaxY$(14) = "191": GModeStartAddress$(14) = "E00": GModeScreenSize$(14) = "C00"
GModeName$(15) = "FG6C": GModeMaxX$(15) = "127": GModeMaxY$(15) = "191": GModeStartAddress$(15) = "E00": GModeScreenSize$(15) = "1800"
GModeName$(16) = "FG6R": GModeMaxX$(16) = "255": GModeMaxY$(16) = "191": GModeStartAddress$(16) = "E00": GModeScreenSize$(16) = "1800"
GModeName$(17) = "DMAGraphic": GModeMaxX$(17) = "255": GModeMaxY$(17) = "191": GModeStartAddress$(17) = "E00": GModeScreenSize$(17) = "1800"

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

DefLabelCount = 0
DefVarCount = 0

Dim Signed16bit As Integer

Open "Basic_Commands/BasTo6809_CommandsGeneral.dat" For Input As #1
GeneralCommandsCount = 0
While EOF(1) = 0
    Line Input #1, i$
    GeneralCommandsCount = GeneralCommandsCount + 1
    GeneralCommands$(GeneralCommandsCount) = i$
Wend
Close #1
Open "Basic_Commands/BasTo6809_CommandsNumeric.dat" For Input As #1
NumericCommandsCount = 0
While EOF(1) = 0
    Line Input #1, i$
    NumericCommandsCount = NumericCommandsCount + 1
    NumericCommands$(NumericCommandsCount) = i$
Wend
Close #1
Open "Basic_Commands/BasTo6809_CommandsString.dat" For Input As #1
StringCommandsCount = 0
While EOF(1) = 0
    Line Input #1, i$
    StringCommandsCount = StringCommandsCount + 1
    StringCommands$(StringCommandsCount) = i$
Wend
Close #1
Open "Basic_Commands/BasTo6809_CommandsOperators.dat" For Input As #1
OperatorCommandsCount = 0
While EOF(1) = 0
    Line Input #1, i$
    i$ = Right$(i$, Len(i$) - 1)
    i$ = Left$(i$, InStr(i$, ",") - 2)
    OperatorCommandsCount = OperatorCommandsCount + 1
    OperatorCommands$(OperatorCommandsCount) = i$
Wend
Close #1

Check$ = "IF": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_IF = ii
Check$ = "THEN": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_THEN = ii
Check$ = "ELSE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_ELSE = ii
Check$ = "GOTO": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_GOTO = ii
Check$ = "END": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_END = ii
Check$ = "DIM": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_DIM = ii
Check$ = "DATA": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_DATA = ii
Check$ = "REM": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_REM = ii
Check$ = "'": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_REMApostrophe = ii
Check$ = "PRINT": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_PRINT = ii
Check$ = "PSET": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_PSET = ii
Check$ = "PRESET": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_PRESET = ii
Check$ = "GET": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_GET = ii
Check$ = "PUT": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_PUT = ii
Check$ = "GMODE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_GMODE = ii
Check$ = "SPRITE_LOAD": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_SPRITE_LOAD = ii

' Handle command line options
FI = 0
count = _CommandCount
If count = 0 Then
    Print "Compiler has no options given to it"
    System
End If
nt = 0: newp = 0: endp = 0: BranchCheck = 0: StringArraySize = 255: AutoStart = 0
Optimize = 2 ' Default to optimize level 2
For check = 1 To count
    N$ = Command$(check)
    If LCase$(Left$(N$, 2)) = "-c" Then BASICMode = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-s" Then StringArraySize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-o" Then Optimize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-b" Then BranchCheck = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-v" Then Verbose = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-p" Then ProgramStart$ = Right$(N$, Len(N$) - 2): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-f" Then Font$ = Right$(N$, Len(N$) - 2): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-a" Then AutoStart = 1: GoTo CheckNextCMDOption
    ' check if we got a file name yet if so then the next filename will be output
    OutName$ = N$
    CheckNextCMDOption:
Next check

' Fill the Array() with the preformatted BASIC text file
Fname$ = "BASIC_Text.bas"
Open Fname$ For Append As #1
length = LOF(1)
Close #1
If length < 1 Then Print "Error file: "; Fname$; " is 0 bytes. Or doesn't exist.": Kill Fname$: End
If Verbose > 0 Then Print "Length of Input file in bytes:"; length
Open Fname$ For Binary As #1
Get #1, , Array()
Close #1
Array(length) = &H0D: length = length + 1 ' add one last EOL

' Get the line Labels first so we can recognize them if there is a forward reference to a Label we haven't come across yet
NumericVariableCount = 0 ' Numeric variable name count
NumericVariable$(NumericVariableCount) = "Timer" ' Make the first variable the TIMER
NumericVariableCount = NumericVariableCount + 1 ' Numeric variable name count

x = 0
INx = 0
lc = 0
LineCount = 0
FloatVariableCount = 0 ' Floating Point variable name count
StringVariableCounter = 0 ' String variable name count
CommandsUsedCounter = 0 ' Counter for unique commmands used
NumArrayVarsUsedCounter = 0 ' Counter for number of NumericArrays used
StringArrayVarsUsedCounter = 0 ' Counter for number of String Array Variables used

Check$ = "REM": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_REM = ii
While x < length - 1 ' Loop until we've processed the entire BASIC program
    ' Start of new line
    ' Searching for Inline assembly -  read a full line
    y = x
    V = 0
    Temp$ = ""
    Do Until x >= length Or V = &H0D
        V = Array(x): x = x + 1
        Temp$ = Temp$ + Chr$(V)
    Loop
    p = InStr(Temp$, "ADDASSEM")
    If p > 0 Then
        ' We found the start of some inline assembly
        ' Ignore any labels found here...
        'copy lines unaltered until we get a ENDASSEM
        REM_AddCodeAlpha0:
        Temp$ = ""
        V = 0
        Do Until x >= length Or V = &H0D
            V = Array(x): x = x + 1
            Temp$ = Temp$ + Chr$(V)
        Loop
        ' Check if this line is the last
        If InStr(Temp$, "ENDASSEM") = 0 Then GoTo REM_AddCodeAlpha0
    Else
        x = y
    End If
    CheckLineSpaces0:
    V = Array(x): x = x + 1
    If V = &H20 Then GoTo CheckLineSpaces0 ' Skip spaces at the beginning of a line
    If V = &H0D Or V = &H0A Then GoTo GotLabel ' Skip to the bottom if we get a line feed or carriage return, this is an empty line
    Tokenized$ = ""
    CurrentLine$ = ""
    'Figure out if we have a line number or a label:
    If V >= Asc("0") And V <= Asc("9") Then ' Check if line starts with a number
        'Does start with a number
        LineCount = LineCount + 1
        While V >= Asc("0") And V <= Asc("9") ' is it a number?
            LabelName$(LineCount) = LabelName$(LineCount) + Chr$(V)
            V = Array(x): x = x + 1
        Wend
        If Verbose > 0 Then Print "Scanning line "; LabelName$(LineCount)
        CurrentLine$ = LabelName$(LineCount)
        If IsNumber(LabelName$(LineCount)) = 0 Then Print "Error: There's something wrong with the Line number or Label "; LabelName$(LineCount): System
        If V = &H0D Then
            ' this is a number line only
            GoTo GotLabel ' Skip to the bottom if we get a line feed or carriage return, this is an empty line
        End If
    Else
        'Not a line number, figure out if this line starts with a BASIC command
        T = Asc(UCase$(Chr$(V)))
        If T >= Asc("A") And T <= Asc("Z") Then
            'Maybe found a label
            Check$ = ""
            y = x - 1
            While V <> Asc(":") And V <> &H0D And V <> &H0A And V <> Asc(" ")
                Check$ = Check$ + Chr$(V)
                V = Array(x): x = x + 1
            Wend
            CheckLC$ = Check$
            If V = Asc(":") And Array(x) = &H0D Then
                'Could be a label or a general command with a colon after it
                ' Check for a General command
                Found = 0
                For c = 1 To GeneralCommandsCount
                    Temp$ = UCase$(GeneralCommands$(c))
                    Check$ = UCase$(Check$)
                    If Temp$ = Check$ Then
                        'Found a General Command
                        Found = 1: Exit For
                    End If
                Next c
                If Found = 0 Then
                    ' It is a label
                    LineCount = LineCount + 1
                    LabelName$(LineCount) = CheckLC$
                    CurrentLine$ = LabelName$(LineCount)
                    If Verbose > 0 Then Print "Scanning line "; LabelName$(LineCount); ":"
                    Tokenized$ = ""
                    GoTo GotLabel
                End If
            End If
            x = y

        End If
    End If
    V = Array(x): x = x + 1
    While V <> &H0D
        V = Array(x): x = x + 1
    Wend
    GotLabel:
Wend

' Get commands and variables used in program
' Tokenize the text version of the BASIC program to make it easier to handle parsing expressions
If Verbose > 0 Then Print "Doing Pass 1 - Finding commands and variables used"
x = 0
INx = 0
lc = 0
LineCountB = 0
If Verbose > 1 Then Print "Done scanning for labels"; LineCount
While x < length - 1 ' Loop until we've processed the entire BASIC program
    ' Start of new line
    ' Searching for Inline assembly -  read a full line
    y = x
    V = 0
    Temp$ = ""
    Do Until x >= length Or V = &H0D
        V = Array(x): x = x + 1
        Temp$ = Temp$ + Chr$(V)
    Loop
    p = InStr(Temp$, "ADDASSEM")
    If p > 0 Then
        ' We found the start of some inline assembly
        ' Copy the line number or label
        '    Tokenized$ = Chr$(Len(CurrentLine$)) + CurrentLine$ + Tokenized$ + Chr$(&HF5) + Chr$(&H0D) ' Line ends with $F50D
        CurrentLine$ = ""
        If Asc(Left$(Temp$, 1)) >= &H30 And Asc(Left$(Temp$, 1)) <= &H39 Then
            For ii = 1 To Len(Temp$)
                If Mid$(Temp$, ii, 1) = Chr$(&H20) Then Exit For
                CurrentLine$ = CurrentLine$ + Mid$(Temp$, ii, 1)
            Next ii
        End If
        Num = C_REM: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
        ' INArray(INx) = MSB: INx = INx + 1: INArray(INx) = LSB: INx = INx + 1 ' write command to ouput array
        Temp$ = Chr$(Len(CurrentLine$)) + CurrentLine$ + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB) + " ADDASSEM:" + Chr$(&HF5) + Chr$(&H0D)
        For ii = 1 To Len(Temp$)
            INArray(INx) = Asc(Mid$(Temp$, ii, 1)): INx = INx + 1
        Next ii
        ' Copy lines unaltered until we get a ENDASSEM
        REM_AddCode0:
        V = 0
        Temp$ = ""
        Do Until x >= length Or V = &H0D
            V = Array(x): x = x + 1
            Temp$ = Temp$ + Chr$(V)
        Loop
        ' Check if this line is the last
        p = InStr(Temp$, "ENDASSEM")
        If p = 0 Then
            For ii = 1 To Len(Temp$)
                INArray(INx) = Asc(Mid$(Temp$, ii, 1)): INx = INx + 1
            Next ii
            GoTo REM_AddCode0
        End If
        Num = C_REM: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
        '       INArray(INx) = MSB: INx = INx + 1: INArray(INx) = LSB: INx = INx + 1 ' write command to ouput array
        Temp$ = Chr$(0) + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB) + " ENDASSEM:" + Chr$(&HF5) + Chr$(&H0D)
        For ii = 1 To Len(Temp$)
            INArray(INx) = Asc(Mid$(Temp$, ii, 1)): INx = INx + 1
        Next ii
        GoTo ScanNextLine ' Skip to the bottom
    Else
        x = y
    End If
    V = Array(x): x = x + 1
    If V = &H20 Then GoTo ScanNextLine ' Skip spaces at the beginning of a line
    If V = &H0D Then GoTo ScanNextLine ' Skip to the bottom if we get a line feed or carriage return, this is an empty line
    Tokenized$ = ""
    CurrentLine$ = ""
    'Figure out if we have a line number or a label:
    If V >= Asc("0") And V <= Asc("9") Then ' Check if line starts with a number
        'Does start with a number
        LineCountB = LineCountB + 1
        While V >= Asc("0") And V <= Asc("9") ' is it a number?
            '  LabelName$(LineCountB) = LabelName$(LineCountB) + Chr$(v)
            V = Array(x): x = x + 1
        Wend
        If Verbose > 0 Then Print "Scanning line "; LabelName$(LineCount)
        CurrentLine$ = LabelName$(LineCountB)
        If IsNumber(LabelName$(LineCountB)) = 0 Then
            Print "There's something wrong with the Line number or Label "; LabelName$(LineCountB): System
        End If
        If V = &H0D Then
            ' this is a number line only
            GoTo ScanNextLine ' Skip to the bottom if we get a line feed or carriage return, this is an empty line
        End If
    Else
        'Not a line number, figure out if this line starts with a BASIC command
        T = Asc(UCase$(Chr$(V)))
        If T >= Asc("A") And T <= Asc("Z") Then
            'Maybe found a label
            Check$ = ""
            Start = x - 1
            While V <> Asc(":") And V <> &H0D And V <> Asc(" ")
                Check$ = Check$ + Chr$(V)
                V = Array(x): x = x + 1
            Wend
            If V = Asc(":") And Array(x) = &H0D Then
                'Could be a label or a general command with a colon after it
                ' Check for a General command
                Found = 0
                For c = 1 To GeneralCommandsCount
                    Temp$ = UCase$(GeneralCommands$(c))
                    Check$ = UCase$(Check$)
                    If Temp$ = Check$ Then
                        'Found a General Command
                        Found = 1
                    End If
                Next c
                If Found = 0 Then
                    ' It is a label
                    LineCountB = LineCountB + 1
                    CurrentLine$ = LabelName$(LineCountB)
                    If Verbose > 0 Then Print "Scanning line "; LabelName$(LineCountB); ":"
                    Tokenized$ = ""
                    GoTo LabelOnlyLine
                End If
            End If
            x = Start
            V = Array(x): x = x + 1
        End If
    End If
    ' Get the first argument/command
    ' No line number or label
    GetFirstArg:
    Expression$ = ""
    ColonCount = 0
    If V = &H20 Then V = Array(x): x = x + 1 ' skip past the first space on the line
    'Get the rest of this line as it is
    While V <> &H0D And x < length
        If V = &H22 Then ' is it a quote"
            Expression$ = Expression$ + Chr$(V)
            V = Array(x): x = x + 1
            ' Yes deal with text in quotes, copy all until we get an end quote or RETURN
            While V <> &H22 And V <> &H0D
                Expression$ = Expression$ + Chr$(V)
                V = Array(x): x = x + 1
            Wend
            If V = &H0D Then
                ' we got the end of the line without an end quote, let's add one
                Expression$ = Expression$ + Chr$(&H22)
                GoTo DoneGetFirstArg
            End If
            If V = &H22 Then ' did we get the end quote?
                'Yes got the end quote
                Expression$ = Expression$ + Chr$(V)
                GoTo GetMoreArgs
            End If
        Else
            ' Not inside a quote
            If V = Asc(":") Then
                Expression$ = Expression$ + Chr$(&HF5) ' flag colons as special characters $F53A
                While Array(x) = Asc(" ")
                    x = x + 1 ' skip the spaces after a ":"
                Wend
            End If
            If V = Asc("?") Then ' Change ? to a PRINT command
                Expression$ = Expression$ + "PRINT "
            Else
                Expression$ = Expression$ + Chr$(V)
            End If
        End If
        GetMoreArgs:
        V = Array(x): x = x + 1
    Wend
    DoneGetFirstArg:
    If InStr(0, Expression$, "THEN " + Chr$(&HF5) + ":") > 0 Then
        ' Fix THEN :ELSE to be THEN ELSE
        While InStr(0, Expression$, "THEN " + Chr$(&HF5) + ":") > 0
            Expression$ = Left$(Expression$, InStr(0, Expression$, "THEN " + Chr$(&HF5) + ":") + 4) + Right$(Expression$, Len(Expression$) - InStr(0, Expression$, "THEN " + Chr$(&HF5) + ":") - 6)
        Wend
    End If
    GoSub TokenizeExpression ' Go tokenize Expression$
    LabelOnlyLine:
    Tokenized$ = Chr$(Len(CurrentLine$)) + CurrentLine$ + Tokenized$ + Chr$(&HF5) + Chr$(&H0D) ' Line ends with $F50D
    For ii = 1 To Len(Tokenized$)
        INArray(INx) = Asc(Mid$(Tokenized$, ii, 1)): INx = INx + 1
    Next ii
    ScanNextLine:
Wend

If Verbose > 0 Then
    ' Print the commands used and variables used by this BASIC program
    Print "General Commands Used:"
    For ii = 0 To GeneralCommandsFoundCount - 1
        Print GeneralCommandsFound$(ii)
    Next ii
    Print "Numeric Commands Used:"
    For ii = 0 To NumericCommandsFoundCount - 1
        Print NumericCommandsFound$(ii)
    Next ii
    Print "String Commands Used:"
    For ii = 0 To StringCommandsFoundCount - 1
        Print StringCommandsFound$(ii)
    Next ii
    Print "Floating Point Variables Used:"
    For ii = 0 To FloatVariableCount - 1
        Print FloatVariable$(ii)
    Next ii
    Print "Numeric Variables Used:"
    For ii = 0 To NumericVariableCount - 1
        Print NumericVariable$(ii)
    Next ii
    Print "String Variables Used:"
    For ii = 0 To StringVariableCounter - 1
        Print StringVariable$(ii)
    Next ii
    Print "Numeric Arrays Used:"
    For ii = 0 To NumArrayVarsUsedCounter - 1
        Print NumericArrayVariables$(ii); " which has"; NumericArrayDimensions(ii); "Dimensions"
    Next ii
    Print "String Arrays Used:"
    For ii = 0 To StringArrayVarsUsedCounter - 1
        Print StringArrayVariables$(ii); " which has"; StringArrayDimensions(ii); "Dimensions"
    Next ii
End If

' Write tokenized data to file
' Copy array to output file first byte of the array is 0
' Example: array(0),array(1),array(2),...,array(length)
filesize = INx - 1
c = 0
For OP = 0 To filesize
    Array(c) = INArray(OP): c = c + 1
Next OP


ReDim LastOutArray(filesize) As _Unsigned _Byte
c = 0
For OP = 0 To filesize
    LastOutArray(c) = Array(OP): c = c + 1
Next OP
If _FileExists("BasicTokenizedB4Pass2.bin") Then Kill "BasicTokenizedB4Pass2.bin"
If Verbose > 0 Then Print "Writing to file "; "BasicTokenizedB4Pass2.bin"
Open "BasicTokenizedB4Pass2.bin" For Binary As #1
Put #1, , LastOutArray()
Close #1

' Re-format IF statements that are only one line and don't end with an ENDIF just an EOL to end with and ENDIF (so all IF's can be handled the same)
If Verbose > 0 Then Print "Doing Pass 2 - Changing single line IF commands to IF/THEN/ELSE/END IF, multiple lines"
c = 0
x = 0
While x <= filesize
    V = Array(x): x = x + 1 ' get a byte
    INArray(c) = V: c = c + 1 'write byte to ouput array
    If V = &HFF And Array(x) * 256 + Array(x + 1) = C_IF Then
        'It is an IF command
        V = Array(x): x = x + 1 ' get the command to do
        INArray(c) = V: c = c + 1 ' write byte to ouput array
        V = Array(x): x = x + 1 ' get the command to do
        INArray(c) = V: c = c + 1 ' write byte to ouput array
        'Make sure it wasn't part of an END IF
        'END IF = FF xx xx FF xx xx F5 0D
        If x > 6 Then
            ' check for an END IF
            If Array(x - 6) = &HFF And Array(x - 5) * 256 + Array(x - 4) = C_END Then
                'It is part of an END IF
                GoTo PartOfENDIF
            End If
        End If
        'Otherwise it is a regular IF
        ' Find the THEN command for this IF
        Do Until V = &HFF And (Array(x) * 256 + Array(x + 1) = C_THEN Or Array(x) * 256 + Array(x + 1) = C_GOTO) ' If we come across a GOTO instead of a THEN, make it a THEN
            V = Array(x): x = x + 1 ' get a byte
            INArray(c) = V: c = c + 1 ' write byte to ouput array
        Loop 'loop until we find a THEN or GOTO command
        ' Just in case we found a GOTO instead of a THEN, change it to a THEN
        ' Make it a THEN even if it was a GOTO
        Num = C_THEN: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
        INArray(c) = MSB: c = c + 1: INArray(c) = LSB: c = c + 1 ' write command to ouput array
        x = x + 2 ' skip forward past command number
        ' Print "Checking for stuff after the THEN"
        V = Array(x) ' get a byte
        If Array(x) = &HF5 And Array(x + 1) = &H3A Then
            While Array(x) = &HF5 And Array(x + 1) = &H3A: x = x + 2: Wend ' consume any colons directly after the THEN
            V = Array(x): x = x + 1
        Else
            x = x + 1
        End If
        If V = (&HF5 And Array(x) = &H0D) Or (V = &HFF And Array(x) * 256 + Array(x + 1) = C_REM) Or (V = &HFF And Array(x) * 256 + Array(x + 1) = C_REMApostrophe) Then ' After THEN do we have an EOL, or REMarks?
            ' if so this is already an IF/THEN/ELSE/ELSEIF/ENDIF so don't need to change it to be a multi line IF
            INArray(c) = V: c = c + 1 ' write byte to ouput array
            If V = &HF5 And Array(x) = &H0D Then INArray(c) = &H0D: c = c + 1: x = x + 1
        Else
            ' Print "not a multi line IF"
            ' This is a one line IF/THEN/ELSE command that ends with a $F5 $0D
            ' Make it a multi line IF THEN ELSE
            ' We've copied everything upto and including the THEN
            ' Make the byte after the THEN an EOL
            IfCounter = 1
            INArray(c) = &HF5: c = c + 1 ' Add EOL
            INArray(c) = &H0D: c = c + 1 ' Add EOL
            INArray(c) = 0: c = c + 1 ' start of next line - line label length of zero
            'Check for a number could be IF THEN 50
            FoundLineNumber:
            If V >= Asc("0") And V <= Asc("9") Then
                ' Found a line number, change it to a new line with GOTO linenumber
                INArray(c) = &HFF: c = c + 1 ' General command
                Num = C_GOTO: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                INArray(c) = MSB: c = c + 1: INArray(c) = LSB: c = c + 1 ' write command to ouput array
                While V >= Asc("0") And V <= Asc("9")
                    INArray(c) = V: c = c + 1 ' write line number
                    V = Array(x): x = x + 1 ' copy the line number
                Wend
                x = x - 1
                While Array(x) = &HF5 And Array(x + 1) = &H3A: V = Array(x): x = x + 2: Wend ' consume any colons
                V = Array(x): x = x + 1
                If V = &HF5 And Array(x) = &H0D Then INArray(c) = &HF5: c = c + 1: GoTo FixedGoto ' The &H0D will be added below
            End If
            ' Not a line number after the THEN
            x = x - 1
            Do Until V = &HF5 And Array(x) = &H0D
                V = Array(x): x = x + 1 ' get a byte
                INArray(c) = V: c = c + 1 ' write byte to ouput array
                If V = &HFF Then
                    If Array(x) * 256 + Array(x + 1) = C_IF Then
                        ' Found an IF
                        IfCounter = IfCounter + 1
                        c = c - 1 ' Don't keep the &HFF it just wrote
                        INArray(c) = &HF5: c = c + 1 ' add EOL instead of the IF Command
                        INArray(c) = &H0D: c = c + 1 ' add EOL
                        INArray(c) = &H00: c = c + 1 ' line label length of zero
                        INArray(c) = &HFF: c = c + 1 ' Add the command Token
                        V = Array(x): x = x + 1 ' Get the IF Command #MSB
                        INArray(c) = V: c = c + 1 ' Write the IF Command #MSB
                        V = Array(x): x = x + 1 ' Get the IF Command #LSB
                        INArray(c) = V: c = c + 1 ' Write the IF Command #LSB
                    End If
                    If Array(x) * 256 + Array(x + 1) = C_THEN Or Array(x) * 256 + Array(x + 1) = C_ELSE Then
                        ' Found THEN or ELSE
                        c = c - 1 ' Don't keep the &HFF it just wrote
                        INArray(c) = &HF5: c = c + 1 ' add EOL
                        INArray(c) = &H0D: c = c + 1 ' add EOL
                        INArray(c) = 0: c = c + 1 ' line label length
                        INArray(c) = &HFF: c = c + 1 ' write &HFF command byte to ouput array
                        V = Array(x): x = x + 1 ' get the THEN or ELSE command # MSB
                        INArray(c) = V: c = c + 1 ' write byte to ouput array
                        V = Array(x): x = x + 1 ' get the THEN or ELSE command # LSB
                        INArray(c) = V: c = c + 1 ' write byte to ouput array
                        V = Array(x): x = x + 1 ' get the next byte
                        If V = &HF5 And Array(x) = &H3A Then
                            ' We have a colon
                            x = x - 1
                            While Array(x) = &HF5 And Array(x + 1) = &H3A: x = x + 2: Wend ' consume any colons
                            V = Array(x): x = x + 1 ' get the next byte
                        End If
                        If V >= Asc("0") And V <= Asc("9") Then GoTo FoundLineNumber
                        x = x - 1
                        INArray(c) = &HF5: c = c + 1 ' Add EOL
                        INArray(c) = &H0D: c = c + 1 ' Add EOL
                        INArray(c) = 0: c = c + 1 ' line label length of zero
                    End If
                End If
            Loop
            FixedGoto:
            V = Array(x): x = x + 1 ' get a byte the $0D
            INArray(c) = V: c = c + 1 ' write byte to ouput array
            For I = 1 To IfCounter
                'END IF = FF xx xx FF xx xx F5 0D
                INArray(c) = 0: c = c + 1 ' line label length of zero
                INArray(c) = &HFF: c = c + 1
                Num = C_END: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                INArray(c) = MSB: c = c + 1: INArray(c) = LSB: c = c + 1 ' write command to ouput array
                INArray(c) = &HFF: c = c + 1
                Num = C_IF: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                INArray(c) = MSB: c = c + 1: INArray(c) = LSB: c = c + 1 ' write command to ouput array
                INArray(c) = &HF5: c = c + 1 ' Add EOL
                INArray(c) = &H0D: c = c + 1 ' EOL
            Next I
        End If
    End If
    PartOfENDIF:
Wend

' Tokens for variables type:
' &HF0 = Numeric Arrays           (4 Bytes)
' &HF1 = String Arrays            (3 Bytes)
' &HF2 = Regular Numeric Variable (3 Bytes)
' &HF3 = Regular String Variable  (3 Bytes)
' &HF4 = Floating Point Variable
' &HF5 = Special characters like a EOL, colon, comma, semi colon, quote, brackets    (2 Bytes)

' &HFB = DEF FN Function
' &HFC = Operator Command (2 Bytes)
' &HFD = String Command  (3 Bytes)
' &HFE = Numeric Command (3 Bytes)
' &HFF = General Command (3 Bytes)

' Change Variable _Var_Timer = to command TIMER =

Check$ = "TIMER": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_TIMER = ii
CheckForTimer:
While OP <= filesize
    V = INArray(OP): OP = OP + 1
    If V < &HF0 Then GoTo CheckForTimer
    'We have a Token
    Select Case V
        Case &HF0, &HF1: ' Found a Numeric or String array
            OP = OP + 3
        Case &HF2: ' Found a numeric variable
            If INArray(OP) * 256 + INArray(OP + 1) = 0 Then
                If INArray(OP + 2) = &HFC Then
                    If INArray(OP + 3) = &H3D Then ' Check for =
                        ' Found "_Var_Timer =" as a variable
                        INArray(OP - 1) = &HFF ' Make it a General command
                        Num = C_TIMER: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                        INArray(OP) = MSB: INArray(OP + 1) = LSB ' write command to ouput array
                        OP = OP + 2
                    End If
                End If
            End If
        Case &HF3, &HF4: ' Found a string or fating point variable
            OP = OP + 2
        Case &HF5 ' Found a special character
            OP = OP + 1
        Case &HFB: ' Found a DEF FN Function
            OP = OP + 2
        Case &HFC: ' Found an Operator
            OP = OP + 1
        Case &HFD, &HFE, &HFF: 'Found String,Numeric or General command
            OP = OP + 2
    End Select
Wend

' Copy array INArray() to Array()
filesize = c - 1
c = 0
For OP = 0 To filesize
    Array(c) = INArray(OP): c = c + 1
Next OP

ReDim LastOutArray(filesize) As _Unsigned _Byte
c = 0
For OP = 0 To filesize
    LastOutArray(c) = Array(OP): c = c + 1
Next OP
If _FileExists("BasicTokenizedB4Pass3.bin") Then Kill "BasicTokenizedB4Pass3.bin"
If Verbose > 0 Then Print "Writing to file "; "BasicTokenizedB4Pass3.bin"
Open "BasicTokenizedB4Pass3.bin" For Binary As #1
Put #1, , LastOutArray()
Close #1

' Decided to not skip it just in case someone select the -coco option even though they truly are using -ascii
'If BASICMode = 1 Then GoTo SkipCheckingForElseIF ' CoCo BASIC won't have ELSEIF

' Change any ElseIf to ELSE/IF
c = 0
x = 0
AddENDIF = 0
ElseIfCheckPartOfENDIF:
While x <= filesize
    V = Array(x): x = x + 1 ' get a byte
    INArray(c) = V: c = c + 1 'write byte to ouput array
    If V > &HEF Then
        'We have a Token
        Select Case V
            Case &HF0, &HF1: ' Found a Numeric or String array
                V = Array(x): x = x + 1 ' get a byte
                INArray(c) = V: c = c + 1 'write byte to ouput array
                V = Array(x): x = x + 1 ' get a byte
                INArray(c) = V: c = c + 1 'write byte to ouput array
                V = Array(x): x = x + 1 ' get a byte
                INArray(c) = V: c = c + 1 'write byte to ouput array
            Case &HF2, &HF3, &HF4: ' Found a numeric or string or Floating point variable
                V = Array(x): x = x + 1 ' get a byte
                INArray(c) = V: c = c + 1 'write byte to ouput array
                V = Array(x): x = x + 1 ' get a byte
                INArray(c) = V: c = c + 1 'write byte to ouput array
            Case &HF5 ' Found a special character
                V = Array(x): x = x + 1 ' get a byte
                INArray(c) = V: c = c + 1 'write byte to ouput array
            Case &HFB: ' Found a DEF FN Function
                V = Array(x): x = x + 1 ' get a byte
                INArray(c) = V: c = c + 1 'write byte to ouput array
                V = Array(x): x = x + 1 ' get a byte
                INArray(c) = V: c = c + 1 'write byte to ouput array
            Case &HFC: ' Found an Operator
                V = Array(x): x = x + 1 ' get a byte
                INArray(c) = V: c = c + 1 'write byte to ouput array
            Case &HFD, &HFE: 'Found String or Numeric command
                V = Array(x): x = x + 1 ' get a byte
                INArray(c) = V: c = c + 1 'write byte to ouput array
                V = Array(x): x = x + 1 ' get a byte
                INArray(c) = V: c = c + 1 'write byte to ouput array
            Case &HFF: ' Found a General command
                Temp1 = Array(x): x = x + 1 ' get a byte
                INArray(c) = Temp1: c = c + 1 'write byte to ouput array
                Temp2 = Array(x): x = x + 1 ' get a byte
                INArray(c) = Temp2: c = c + 1 'write byte to ouput array
                V = Temp1 * 256 + Temp2
                If V = C_ELSE Then
                    ' Found an Else, check for IF
                    If Array(x) = &HFF And Array(x + 1) * 256 + Array(x + 2) = C_IF Then
                        ' We found an ELSE IF
                        ' Change ELSEIF to ELSE - EOL
                        INArray(c) = &HF5: c = c + 1: INArray(c) = &H0D: c = c + 1 ' EOL
                        INArray(c) = 0: c = c + 1 ' line label length of zero
                    End If
                End If
        End Select
    End If
Wend

filesize = c - 1
ReDim LastOutArray(filesize) As _Unsigned _Byte
c = 0
For OP = 0 To filesize
    Array(c) = INArray(OP)
    LastOutArray(c) = INArray(OP): c = c + 1
Next OP
If _FileExists("BasicTokenized.bin") Then Kill "BasicTokenized.bin"
If Verbose > 0 Then Print "Writing to file "; "BasicTokenized.bin"
Open "BasicTokenized.bin" For Binary As #1
Put #1, , LastOutArray()
Close #1

If Verbose > 0 Then Print "Doing Pass 3 - Figuring out Arrays sizes, within the DIM commands..."
x = 0
While x < filesize
    V = Array(x): x = x + 1 ' get the command to do
    If V = &HFF Then ' Found a command
        V = Array(x) * 256 + Array(x + 1): x = x + 2
        If V = C_DIM Then ' Is it the DIM command?
            ' Found a DIM command, go setup the array sizes
            GoSub DoDim
        End If
    End If
Wend

If Verbose > 0 Then Print "Doing Pass 4 - Finding special cases that will need other files to be included..."
x = 0
While x < filesize
    V = Array(x): x = x + 1 ' get the command to do
    If V = &HFF Then ' Found a command
        V = Array(x) * 256 + Array(x + 1): x = x + 2
        Select Case V
            Case C_PRINT 'This is the PRINT command
                ' Found a PRINT command, see if we have a print #-3, which will print to the graphics screen
                ' #-3, =  F5 23 FC 2D 33 F5 2C
                If Array(x) = &HF5 And Array(x + 1) = &H23 And Array(x + 2) = &HFC And Array(x + 3) = &H2D And Array(x + 4) = &H33 And Array(x + 5) = &HF5 And Array(x + 6) = &H2C Then
                    x = x + 7
                    PrintGraphicsText = 1
                End If
            Case C_SPRITE_LOAD
                ' Found a Sprite Load command
                ' Get the address and name of the sprite to load
                If Array(x) = &HF5 And Array(x + 1) = &H22 Then
                    ' Found an open quote
                    x = x + 2 ' move past the open quote

                    '       sdfgsdfg
                Else


                End If
                For c = 1 To 25
                    Print Hex$(Array(x)): x = x + 1
                Next c
                System

        End Select
    End If
Wend

Open "NumericVariablesUsed.txt" For Output As #1
For I = 0 To NumericVariableCount - 1
    Print #1, NumericVariable$(I)
Next I
Close #1
Open "FloatingPointVariablesUsed.txt" For Output As #1
For I = 0 To FloatVariableCount - 1
    Print #1, FloatVariable$(I)
Next I
Close #1
Open "StringVariablesUsed.txt" For Output As #1
For I = 0 To StringVariableCounter - 1
    Print #1, StringVariable$(I)
Next I
Close #1
Open "GeneralCommandsFound.txt" For Output As #1
For I = 0 To GeneralCommandsFoundCount - 1
    Print #1, GeneralCommandsFound$(I)
Next I
Close #1
Open "StringCommandsFound.txt" For Output As #1
For I = 0 To StringCommandsFoundCount - 1
    Print #1, StringCommandsFound$(I)
Next I
Close #1
Open "NumericCommandsFound.txt" For Output As #1
For I = 0 To NumericCommandsFoundCount - 1
    Print #1, NumericCommandsFound$(I)
Next I
Close #1
Open "NumericArrayVarsUsed.txt" For Output As #1
For I = 0 To NumArrayVarsUsedCounter - 1
    Print #1, NumericArrayVariables$(I)
    Print #1, NumericArrayDimensions(I)
    Print #1, NumericArrayBits(I)
Next I
Close #1
Open "StringArrayVarsUsed.txt" For Output As #1
For I = 0 To StringArrayVarsUsedCounter - 1
    Print #1, StringArrayVariables$(I)
    Print #1, StringArrayDimensions(I)
    Print #1, StringArrayBits(I)
Next I
Close #1
Open "DefFNUsed.txt" For Output As #1
For I = 0 To DefLabelCount - 1
    Print #1, DefLabel$(I)
Next I
Close #1
Open "DefVarUsed.txt" For Output As #1
For I = 0 To DefVarCount - 1
    Print #1, DefVar(I)
Next I
Close #1

'See if we should need to use Disk access and Background sound
For ii = 0 To GeneralCommandsFoundCount - 1
    Temp$ = UCase$(GeneralCommandsFound$(ii))
    If Temp$ = "LOADM" Then
        Disk = 1 ' Flag that we use Disk access
    End If
    If Temp$ = "PLAY" Then
        PlayCommand = 1 ' Flag that we use the Play Command
    End If
    If Temp$ = "LINE" Then
        LineCommand = 1 ' Flag that we will use the LINE command
    End If
    If Temp$ = "SDC_PLAY" Or Temp$ = "SDC_PLAYORCL" Or Temp$ = "SDC_PLAYORCR" Or Temp$ = "SDC_PLAYORCS" Then
        SDCPLAY = 1 ' Flag that we need extra SDCPlayback buffer space
    End If
    If Temp$ = "SDC_OPEN" Or Temp$ = "SDC_LOADM" Or Temp$ = "SDC_SAVEM" Then
        SDCVersionCheck = 1 ' include code to make sure we have the correct SDC firmware
    End If
Next ii

For ii = 0 To 171
    If GModeLib(ii) = 1 Then
        If ii < 100 Then
            ' CoCo 1 & 2 graphics mode, Check if ProgramStart should be changed
            If GModePageLib(ii) <> 0 Then
                ' the user wants to use multiple graphics pages
                PStart = Val("&H" + ProgramStart$) + Val("&H" + GModeScreenSize$(ii)) * GModePageLib(ii)
                ProgramStart$ = Hex$(PStart)
            End If
        End If
    End If
Next ii

' Start writing to the .asm file
Open OutName$ For Output As #1
DirectPage$ = ProgramStart$
DirectPage = Val("&H" + DirectPage$)
DirectPage = DirectPage / 256
DirectPage$ = Hex$(DirectPage)
T1$ = "    ": T2$ = T1$ + T1$
If BranchCheck > 0 Then
    ' User wants all branches checked for minimum size
    A$ = "PRAGMA": B$ = "noforwardrefmax": C$ = "This option is necessary for auto branch size feature to work properly, makes lwasm REALLY slow, but code will be smaller and faster": GoSub AO
End If
A$ = "PRAGMA": B$ = "autobranchlength": C$ = "Tell LWASM to automatically use long branches if the short branch is too small, see compiler docs for option -b1 to make this work properly": GoSub AO
Print #1, "; Program reserves $100 bytes before the starting location below for stack space"
A$ = "ORG": B$ = "$" + ProgramStart$: C$ = "Program code starts here": GoSub AO
A$ = "SETDP": B$ = "$" + DirectPage$: C$ = "Direct page is setup here": GoSub AO
Print #1, "Seed1           RMB     1     ; Random number seed location"
Print #1, "Seed2           RMB     1     ; Random number seed location"
Print #1, "RNDC            RMB     1     ; Used by Random number generator"
Print #1, "RNDX            RMB     1     ; Used by Random number generator"
Print #1, "StartClearHere:" ' This is the start address of variables that will all be cleared to zero when the program starts
' Save space for 10 temporary 16 bit numbers
Print #1, "; Temporary Numbers:"
For Num = 0 To 10
    GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If Num < 10 Then Num$ = "0" + Num$
    Print #1, "_Var_PF"; Num$; T1$; "RMB "; T1$; "2"
Next Num
Print #1, "Temp1           RMB     1     ; Temporary byte used for many routines"
Print #1, "Temp2           RMB     1     ; Temporary byte used for many routines"
Print #1, "Temp3           RMB     1     ; Temporary byte used for many routines"
Print #1, "Temp4           RMB     1     ; Temporary byte used for many routines"
Print #1, "Denominator     RMB     2     ; Denominator, used in division"
Print #1, "Numerator       RMB     2     ; Numerator, used in division"
Print #1, "DATAPointer     RMB     2     ; Variable that points to the current DATA location"
Print #1, "_NumVar_IFRight RMB     2     ; Temp bytes for IF Compares"

If PrintGraphicsText = 1 Then
    ' Found program uses PRINT #-3, to print to the graphics screen
    Print #1, "GraphicCURPOS   RMB     2     ; Reserve RAM for the Graphics Cursor"
End If

' Reserve space for Floating Point variables
Print #1, "; Floating Point Variables Used:"; FloatVariableCount
For ii = 0 To FloatVariableCount - 1
    Print #1, "_FPVar_"; FloatVariable$(ii); T1$; "RMB "; T1$; "5"
Next ii
Print #1, "; Numeric Variables Used:"; NumericVariableCount
For ii = 0 To NumericVariableCount - 1
    Print #1, "_Var_"; NumericVariable$(ii); T1$; "RMB "; T1$; "2"
Next ii
Print #1, "EveryCasePointer  RMB   2     ; Pointer at the table to keep track of the CASE/EVERYCASE Flags"
Print #1, "EveryCaseStack  RMB     10*2  ; Space Used for nested Cases"
Print #1, "SoundTone       RMB     1     ; SOUND Tone value"
Print #1, "SoundDuration   RMB     2     ; SOUND Command duration value"
Print #1, "CASFLG          RMB     1     ; Case flag for keyboard output $FF=UPPER (normal), 0=LOWER"
Print #1, "OriginalIRQ     RMB     3     ; We save the original branch and location of the IRQ here, restored before we exit"
' Add temp string space
For Num = 0 To 1
    GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If Num < 10 Then Num$ = "0" + Num$
    Print #1, "_StrVar_PF"; Num$; T1$; "RMB "; T1$; "256     ; Temp String Variable"
Next Num
' Add temp IF string space
Print #1, "_StrVar_IFRight"; T1$; "RMB "; T1$; "256     ; Temp String Variable for IF Compares"
If SDCPLAY = 1 Then
    ' We need extra SDCPlayback buffer space
    Print #1, "SDCPLAY_Extra"; T1$; "RMB "; T1$; "256     ; Extra temp Space for SDCPLAY command"
End If

' Add the String Variables used
Print #1, "; String Variables Used:"; StringVariableCounter
For ii = 0 To StringVariableCounter - 1
    Z$ = "_StrVar_" + StringVariable$(ii): GoSub AO
    A$ = "RMB": B$ = "1": C$ = "String Variable " + StringVariable$(ii) + " length (0 to 255) initialized to 0": GoSub AO
    A$ = "RMB": B$ = "255": C$ = "255 bytes available for string variable " + StringVariable$(ii): GoSub AO
Next ii
Print #1, "; Numeric Arrays Used:"; NumArrayVarsUsedCounter
If NumArrayVarsUsedCounter > 0 Then
    For ii = 0 To NumArrayVarsUsedCounter - 1
        Temp$ = "2*" 'Two bytes (16 bits) per element
        For D1 = 0 To NumericArrayDimensions(ii) - 1
            Num = Val("&H" + Mid$(NumericArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 ' + 1 because it is zero based
            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            Temp$ = Temp$ + Num$ + "*"
        Next D1
        Temp$ = Left$(Temp$, Len(Temp$) - 1) ' Remove the extra '*'
        Print #1, "_ArrayNum_"; NumericArrayVariables$(ii)
        Print #1, "; Reserve bytes per element size, set with the DIM command"
        If NumericArrayBits(ii) = 8 Then
            ' Arraysize is 8 bits
            For D1 = 0 To NumericArrayDimensions(ii) - 1
                Num = Val("&H" + Mid$(NumericArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 ' + 1 because it is zero based
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                A$ = "FCB": B$ = Num$: C$ = "Default size of each array element is 11 (0 to 10), changed with the DIM command": GoSub AO
            Next D1
        Else
            ' Arraysize is 16 bits
            For D1 = 0 To NumericArrayDimensions(ii) - 1
                Num = Val("&H" + Mid$(NumericArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 ' + 1 because it is zero based
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                A$ = "FDB": B$ = Num$: C$ = "Use 16 bit values, changed with the DIM command": GoSub AO
            Next D1
        End If
        A$ = "RMB": B$ = Temp$: C$ = "Two bytes (16 bits) per element": GoSub AO
    Next ii
End If

Print #1, "; String Arrays Used:"; StringArrayVarsUsedCounter
If StringArrayVarsUsedCounter > 0 Then
    For ii = 0 To StringArrayVarsUsedCounter - 1
        StringArrayReserveSize = StringArraySize + 1 ' Need an extra byte for the actual string size value
        Num = StringArrayReserveSize
        GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        'Temp$ = "256*" '256 bytes per element
        Temp$ = Num$ + "*" '# of bytes per element
        For D1 = 0 To StringArrayDimensions(ii) - 1
            Num = Val("&H" + Mid$(StringArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 ' + 1 because it is zero based
            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            Temp$ = Temp$ + Num$ + "*"
        Next D1
        Temp$ = Left$(Temp$, Len(Temp$) - 1) ' Remove the extra '*'
        Print #1, "_ArrayStr_"; StringArrayVariables$(ii)
        Print #1, "; Reserve bytes per element size, set with the DIM command"
        If StringArrayBits(ii) = 8 Then
            ' Arraysize is 8 bits
            For D1 = 0 To StringArrayDimensions(ii) - 1
                Num = Val("&H" + Mid$(StringArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 ' + 1 because it is zero based
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                A$ = "FCB": B$ = Num$: C$ = "Default size of each array element is 11 (0 to 10), changed with the DIM command": GoSub AO
            Next D1
        Else
            ' Arraysize is 16 bits
            For D1 = 0 To StringArrayDimensions(ii) - 1
                Num = Val("&H" + Mid$(StringArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 ' + 1 because it is zero based
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                A$ = "FDB": B$ = Num$: C$ = "Use 16 bit values, changed with the DIM command": GoSub AO
            Next D1
        End If
        A$ = "RMB": B$ = Temp$: C$ = "String size+1 per element": GoSub AO
    Next ii
End If
Print #1, "EndClearHere:" ' This is the end address of variables that will all be cleared to zero when the program starts

Print #1, "; General Commands Used:"; GeneralCommandsFoundCount
For ii = 0 To GeneralCommandsFoundCount - 1
    Print #1, "; " + GeneralCommandsFound$(ii)
Next ii

Print #1, "; Numeric Commands Used:"; NumericCommandsFoundCount
For ii = 0 To NumericCommandsFoundCount - 1
    Print #1, "; " + NumericCommandsFound$(ii)
Next ii

Print #1, "; String Commands Used:"; StringCommandsFoundCount
For ii = 0 To StringCommandsFoundCount - 1
    Print #1, "; " + StringCommandsFound$(ii)
Next ii

For c = 0 To vc - 1
    If Right$(var$(c), 3) <> "Str" Then Print #1, "_Var_"; var$(c); T1$; "FDB "; T1$; "$0000"
Next c

For c = 0 To vc - 1
    If Right$(var$(c), 3) = "Str" Then
        Print #1, "_StrVar_"; var$(c); T1$; "FCB "; T1$; "$00     ; String Variable "; var$(c); " length (0 to 255) initialized to 0"
        A$ = "RMB": B$ = "255": C$ = "255 bytes available for string variable " + var$(c): GoSub AO
    End If
Next c

If Verbose > 0 Then Print "Adding the required Libraries..."
' Need to tweak code so we only include code that we need in our program
' Add includes that are necessary
' Add graphics libraries that are needed depending on the GMODE used
For ii = 0 To 171
    If GModeLib(ii) = 1 Then
        Temp$ = "GraphicCommands/GraphicVariables": GoSub AddIncludeTemp ' Add code for graphics variables
        If ii > 99 Then
            CoCo3 = 1
            Temp$ = "GraphicCommands/GraphicCC3_Code": GoSub AddIncludeTemp ' Add code for CoCo3 graphics handling
        Else
            ' CoCo 1 & 2 graphics mode, Check if ProgramStart should be changed
            If GModePageLib(ii) <> 0 Then
                ' the user wants to use multiple graphics pages
                PStart = Val("&H" + ProgramStart$) + Val("&H" + GModeScreenSize$(ii)) * GModePageLib(ii)
                ProgramStart$ = Hex$(PStart)
            End If
        End If
        Temp$ = "GraphicCommands/" + GModeName$(ii) + "/" + GModeName$(ii) + "_Main": GoSub AddIncludeTemp
    End If
Next ii
' Make sure Grpahics commands are first to be included
For ii = 0 To GeneralCommandsFoundCount - 1
    Temp$ = UCase$(GeneralCommandsFound$(ii))

    If Temp$ = "CIRCLE" Then
        For i3 = 0 To 171
            If GModeLib(i3) = 1 Then
                Temp$ = "GraphicCommands/" + GModeName$(i3) + "/" + GModeName$(i3) + "_Circle": GoSub AddIncludeTemp
            End If
        Next i3
    End If
    If Temp$ = "LINE" Then
        For i3 = 0 To 171
            If GModeLib(i3) = 1 Then
                Temp$ = "GraphicCommands/" + GModeName$(i3) + "/" + GModeName$(i3) + "_Line": GoSub AddIncludeTemp
            End If
        Next i3
    End If
    If Temp$ = "PAINT" Then
        For i3 = 0 To 171
            If GModeLib(i3) = 1 Then
                Temp$ = "GraphicCommands/" + GModeName$(i3) + "/" + GModeName$(i3) + "_Paint": GoSub AddIncludeTemp
            End If
        Next i3
    End If
    If Temp$ = "DRAW" Then
        Temp$ = "GraphicCommandDraw": GoSub AddIncludeTemp ' Add code for Doing the DRAW command
        Temp$ = "DecimalStringToD": GoSub AddIncludeTemp ' Add commands for converting decimal numbers to D
    End If
    If Temp$ = "GET" Or Temp$ = "PUT" Then
        Temp$ = "GraphicCommandsGetPut": GoSub AddIncludeTemp ' Add code to handle Get and Put commands
        If PUTPRESET = 1 Then Temp$ = "GraphicCommandsPut_PRESET": GoSub AddIncludeTemp ' Add code to handle Put PRESET command
        If PUTAND = 1 Then Temp$ = "GraphicCommandsPut_AND": GoSub AddIncludeTemp ' Add code to handle Put AND command
        If PUTOR = 1 Then Temp$ = "GraphicCommandsPut_OR": GoSub AddIncludeTemp ' Add code to handle Put OR command
        If PUTNOT = 1 Then Temp$ = "GraphicCommandsPut_NOT": GoSub AddIncludeTemp ' Add code to handle Put NOT command
        If PUTXOR = 1 Then Temp$ = "GraphicCommandsPut_XOR": GoSub AddIncludeTemp ' Add code to handle Put XOR command
    End If
Next ii
If PrintGraphicsText = 1 Then
    ' Found program uses PRINT #-3, to print to the graphics screen
    For i3 = 0 To 171
        If GModeLib(i3) = 1 Then
            Temp$ = "GraphicCommands/" + GModeName$(i3) + "/" + GModeName$(i3) + "_Print_Graphic_Screen": GoSub AddIncludeTemp
            Temp$ = "GraphicCommands/" + GModeName$(i3) + "/" + GModeName$(i3) + "_Locate": GoSub AddIncludeTemp
            Temp$ = "GraphicCommands/" + GModeName$(i3) + "/Graphic_Screen_Fonts/" + Font$: GoSub AddIncludeTemp
        End If
    Next i3
End If

' List of includes needs to be added, only if it's not already in the list
Print #1, "; Section of necessary included code:"
For ii = 0 To GeneralCommandsFoundCount - 1
    Temp$ = UCase$(GeneralCommandsFound$(ii))

    If Temp$ = "AUDIO" Then
        Temp$ = "Audio_Muxer": GoSub AddIncludeTemp ' Add code for Selecting the audio muxer and to turn it on or off
    End If
    If Temp$ = "CLS" Then
        Temp$ = "CLS": GoSub AddIncludeTemp ' Add code for clearing the screen
    End If
    If Temp$ = "GETJOYD" Then
        Temp$ = "GetJoyD": GoSub AddIncludeTemp ' Add code to quickly get the Joystick values and set the values of 0,31 or 63
    End If
    If Temp$ = "INPUT" Then
        Temp$ = "KeyboardInput": GoSub AddIncludeTemp
        Temp$ = "INPUTCode": GoSub AddIncludeTemp
        Temp$ = "DecimalStringToD": GoSub AddIncludeTemp ' Add commands for converting decimal numbers to D
    End If
    If Temp$ = "LOADM" Then
        Temp$ = "Disk_Commands": GoSub AddIncludeTemp ' Add code for Disk commands
    End If
    If Temp$ = "PLAY" Then
        Temp$ = "Play": GoSub AddIncludeTemp ' Add code for PLAY command
        Temp$ = "Audio_Muxer": GoSub AddIncludeTemp 'SOUND routine also requires the Muxer to be turned on
        Temp$ = "DecimalStringToD": GoSub AddIncludeTemp ' Add commands for converting decimal numbers to D
    End If
    If Temp$ = "SDC_PLAY" Or Temp$ = "SDC_PLAYORCL" Or Temp$ = "SDC_PLAYORCR" Or Temp$ = "SDC_PLAYORCS" Then
        If Temp$ = "SDCPLAY" Then Temp$ = "SDCPlay": GoSub AddIncludeTemp: Temp$ = "Audio_Muxer": GoSub AddIncludeTemp ' Add code for Selecting the audio muxer and to turn it on or off
        If Temp$ = "SDCPLAYORCL" Then Temp$ = "SDCPlayOrc90Left": GoSub AddIncludeTemp
        If Temp$ = "SDCPLAYORCR" Then Temp$ = "SDCPlayOrc90Right": GoSub AddIncludeTemp
        If Temp$ = "SDCPLAYORCS" Then Temp$ = "SDCPlayOrc90Stereo": GoSub AddIncludeTemp
        Temp$ = "StreamFile_Library": GoSub AddIncludeTemp
        '
    End If
    If Temp$ = "SDC_GETBYTE0" Or Temp$ = "SDC_GETBYTE1" Or Temp$ = "SDC_PUTBYTE0" Or Temp$ = "SDC_PUTBYTE1" Or Temp$ = "SDC_DIRPAGE" Or Temp$ = "SDC_SETPOS" Or Temp$ = "SDC_CLOSE" Or Temp$ = "SDC_OPEN" Then
        Temp$ = "CommSDC": GoSub AddIncludeTemp
        Temp$ = "SDCFileAccess": GoSub AddIncludeTemp
        '
    End If
    If Temp$ = "SDC_LOADM" Or Temp$ = "SDC_SAVEM" Then
        Temp$ = "CommSDC": GoSub AddIncludeTemp
        Temp$ = "SDCFileAccess": GoSub AddIncludeTemp
        Temp$ = "SDCLoadmSavem": GoSub AddIncludeTemp
    End If
    If Temp$ = "SOUND" Then
        Temp$ = "Sound": GoSub AddIncludeTemp ' Add code for the sound command
        Temp$ = "Audio_Muxer": GoSub AddIncludeTemp 'SOUND routine also requires the Muxer to be turned on
    End If
Next ii

For ii = 0 To StringCommandsFoundCount - 1
    Temp$ = UCase$(StringCommandsFound$(ii))
    If Temp$ = "INKEY$" Then
        Temp$ = "Inkey": GoSub AddIncludeTemp ' Add the Inkey library
    End If
    If Temp$ = "STR$" Then
        Temp$ = "D_to_String": GoSub AddIncludeTemp ' Add the D_to_String library
    End If
    If Temp$ = "SDC_FILEINFO$" Or Temp$ = "SDC_GETCURDIR$" Then
        Temp$ = "CommSDC": GoSub AddIncludeTemp
        Temp$ = "SDCFileAccess": GoSub AddIncludeTemp
        '        Temp$ = "SDCVersionCheck": GoSub AddIncludeTemp
    End If
Next ii
For ii = 0 To NumericCommandsFoundCount - 1
    Temp$ = UCase$(NumericCommandsFound$(ii))
    If Temp$ = "BUTTON" Then
        Temp$ = "JoyButton": GoSub AddIncludeTemp 'Add code to handle reading the joystick buttons
    End If
    If Temp$ = "SDC_GETBYTE" Or Temp$ = "SDC_MKDIR" Or Temp$ = "SDC_SETDIR" Or Temp$ = "SDC_INITDIR" Or Temp$ = "SDC_DELETE" Then
        Temp$ = "CommSDC": GoSub AddIncludeTemp
        Temp$ = "SDCFileAccess": GoSub AddIncludeTemp
        '        Temp$ = "SDCVersionCheck": GoSub AddIncludeTemp
    End If
    If Temp$ = "JOYSTK" Then
        Temp$ = "Joystick": GoSub AddIncludeTemp 'Add code to handle analog Joystick input
        Temp$ = "Audio_Muxer": GoSub AddIncludeTemp 'Joystick routine also requires the Muxer to be turned off
    End If
    '    If Temp$ = "POINT" Then
    '        Temp$ = "SetResetPoint": GoSub AddIncludeTemp
    '    End If
    If Temp$ = "RND" Or Temp$ = "RNDZ" Or Temp$ = "RNDL" Then
        Temp$ = "Random": GoSub AddIncludeTemp ' Add the code to do a Random number
    End If
    If Temp$ = "VAL" Then
        Temp$ = "DecimalStringToD": GoSub AddIncludeTemp
        Temp$ = "HexStringToD": GoSub AddIncludeTemp
    End If
    if temp$="FLOATADD" or temp$="FLOATSUB" or temp$="FLOATMUL" or temp$="FLOATDIV" or temp$="FLOATSQR" or temp$="FLOATSIN" or temp$="FLOATCOS" or temp$="FLOATTAN" _
       or temp$="FLOATATAN" or temp$="FLOATEXP" or temp$="FLOATLOG" then
        Temp$ = "FloatingPointMath": GoSub AddIncludeTemp 'Add floating point math routines
    End If
Next ii
If FloatVariableCount > 0 Then Temp$ = "FloatingPointMath": GoSub AddIncludeTemp 'Add floating point math routines
' Libraries always included, other libraries use them, so they are required
Temp$ = "Equates": GoSub AddIncludeTemp
Temp$ = "Print": GoSub AddIncludeTemp
Temp$ = "Print_Serial": GoSub AddIncludeTemp
Temp$ = "D_to_String": GoSub AddIncludeTemp
Temp$ = "DHex_to_String": GoSub AddIncludeTemp
Temp$ = "Mulitply16x16": GoSub AddIncludeTemp
Temp$ = "Divide16with16": GoSub AddIncludeTemp
Temp$ = "SquareRoot": GoSub AddIncludeTemp
GoSub WriteIncludeListToFile ' Write all the INCLUDE files needed to the .ASM file

If Disk = 0 Then
    ' Sound and Timer 60 Hz IRQ
    Z$ = "; Sound and Timer 60hz IRQ ": GoSub AO
    Z$ = "BASIC_IRQ:": GoSub AO
    A$ = "LDA": B$ = "$FF03": C$ = "CHECK FOR 60HZ INTERRUPT": GoSub AO
    A$ = "BPL": B$ = "Not60Hz": C$ = "RETURN IF 63.5 MICROSECOND INTERRUPT": GoSub AO
    A$ = "LDA": B$ = "$FF02": C$ = "RESET PIA0, PORT B INTERRUPT FLAG": GoSub AO
    A$ = "LDX": B$ = "SoundDuration": C$ = "Get the new Sound duration value": GoSub AO
    A$ = "BEQ": B$ = ">": C$ = "RETURN IF TIMER = 0": GoSub AO
    A$ = "LEAX": B$ = "-1,X": C$ = "DECREMENT TIMER IF NOT = 0": GoSub AO
    A$ = "STX": B$ = "SoundDuration": C$ = "Save the new Sound duration value": GoSub AO
    Z$ = "!"
    A$ = "INC": B$ = "_Var_Timer+1": C$ = "Increment the LSB of the Timer Value": GoSub AO
    A$ = "BNE": B$ = "Not60Hz": C$ = "Skip ahead if not zero": GoSub AO
    A$ = "INC": B$ = "_Var_Timer": C$ = "Increment the MSB of the Timer Value": GoSub AO
    Z$ = "Not60Hz"
    A$ = "RTI": B$ = "": C$ = "RETURN FROM INTERRUPT": GoSub AO
Else
    ' DISK controller Interrupts
    '; NMI SERVICE
    Z$ = "DNMISV:"
    A$ = "LDA": B$ = "NMIFLG": C$ = "GET NMI FLAG": GoSub AO
    A$ = "BEQ": B$ = "LD8AE": C$ = "RETURN IF NOT ACTIVE": GoSub AO
    A$ = "LDX": B$ = "DNMIVC": C$ = "GET NEW RETURN VECTOR": GoSub AO
    A$ = "STX": B$ = "10,S": C$ = "STORE AT STACKED PC SLOT ON STACK": GoSub AO
    A$ = "CLR": B$ = "NMIFLG": C$ = "RESET NMI FLAG": GoSub AO
    Z$ = "LD8AE"
    A$ = "RTI": B$ = "": C$ = "RETURN FROM INTERRUPT": GoSub AO
    '; Disk IRQ SERVICE and Sound and Timer 60 Hz IRQ
    Z$ = "BASIC_IRQ:"
    A$ = "LDA": B$ = "$FF03": C$ = "63.5 MICRO SECOND OR 60 HZ INTERRUPT?": GoSub AO
    A$ = "BPL": B$ = "LD8AE": C$ = "RETURN IF 63.5 MICROSECOND": GoSub AO
    A$ = "LDA": B$ = "$FF02": C$ = "RESET 60 HZ PIA INTERRUPT FLAG": GoSub AO
    A$ = "LDA": B$ = "RDYTMR": C$ = "GET TIMER": GoSub AO
    A$ = "BEQ": B$ = "LD8CD": C$ = "BRANCH IF NOT ACTIVE": GoSub AO
    A$ = "DECA": C$ = "DECREMENT THE TIMER": GoSub AO
    A$ = "STA": B$ = "RDYTMR": C$ = "SAVE IT": GoSub AO
    A$ = "BNE": B$ = "LD8CD": C$ = "BRANCH IF NOT TIME TO TURN OFF DISK MOTORS": GoSub AO
    A$ = "LDA": B$ = "DRGRAM": C$ = "GET DSKREG IMAGE": GoSub AO
    A$ = "ANDA": B$ = "#$B0": C$ = "TURN ALL MOTORS AND DRIVE SELECTS OFF": GoSub AO
    A$ = "STA": B$ = "DRGRAM": C$ = "PUT IT BACK IN RAM IMAGE": GoSub AO
    A$ = "STA": B$ = "DSKREG": C$ = "SEND TO CONTROL REGISTER (MOTORS OFF)": GoSub AO
    Z$ = "LD8CD"
    A$ = "LDX": B$ = "SoundDuration": C$ = "Get the new Sound duration value": GoSub AO
    A$ = "BEQ": B$ = ">": C$ = "RETURN IF TIMER = 0": GoSub AO
    A$ = "LEAX": B$ = "-1,X": C$ = "DECREMENT TIMER IF NOT = 0": GoSub AO
    A$ = "STX": B$ = "SoundDuration": C$ = "Save the new Sound duration value": GoSub AO
    Z$ = "!"
    A$ = "INC": B$ = "_Var_Timer+1": C$ = "Increment the LSB of the Timer Value": GoSub AO
    A$ = "BNE": B$ = "Not60Hz": C$ = "Skip ahead if not zero": GoSub AO
    A$ = "INC": B$ = "_Var_Timer": C$ = "Increment the MSB of the Timer Value": GoSub AO
    Z$ = "Not60Hz"
    A$ = "RTI": B$ = "": C$ = "RETURN FROM INTERRUPT": GoSub AO
End If
If PlayCommand = 1 Then
    ' Include special PLAY IRQ to jump to while playing notes
    Z$ = "; Timer & Play 60hz IRQ ": GoSub AO
    Z$ = "PLAY_IRQ:": GoSub AO
    A$ = "LDA": B$ = "$FF03": C$ = "CHECK FOR 60HZ INTERRUPT": GoSub AO
    A$ = "BPL": B$ = "Not60HzPlay": C$ = "RETURN IF 63.5 MICROSECOND INTERRUPT": GoSub AO
    A$ = "LDA": B$ = "$FF02": C$ = "RESET PIA0, PORT B INTERRUPT FLAG": GoSub AO
    A$ = "INC": B$ = "_Var_Timer+1": C$ = "Increment the LSB of the Timer Value": GoSub AO
    A$ = "BNE": B$ = ">": C$ = "Skip ahead if not zero": GoSub AO
    A$ = "INC": B$ = "_Var_Timer": C$ = "Increment the MSB of the Timer Value": GoSub AO
    Z$ = "!"
    A$ = "LDD": B$ = "PLYTMR": C$ = "GET THE PLAY TIMER": GoSub AO
    A$ = "BEQ": B$ = ">": C$ = "Exit IRQ": GoSub AO
    A$ = "SUBD": B$ = "VD5": C$ = "SUBTRACT OUT PLAY INTERVAL": GoSub AO
    A$ = "STD": B$ = "PLYTMR": C$ = "SAVE THE NEW TIMER VALUE": GoSub AO
    A$ = "BHI": B$ = ">": C$ = "BRANCH IF PLAY COMMAND NOT DONE": GoSub AO
    A$ = "CLR": B$ = "PLYTMR": C$ = "RESET MSB OF PLAY TIMER IF DONE": GoSub AO
    A$ = "CLR": B$ = "PLYTMR+1": C$ = "RESET LSB OF PLAY TIMER": GoSub AO
    Z$ = "PlayIRQExit:": GoSub AO
    A$ = "PULS": B$ = "A": C$ = "GET THE CONDITION CODE REG": GoSub AO
    A$ = "LDS": B$ = "7,S": C$ = "LOAD THE STACK POINTER WITH THE CONTENTS OF THE U REGISTER": GoSub AO
    Print #1, "; WHICH WAS STACKED WHEN THE INTERRUPT WAS HONORED."
    A$ = "ANDA": B$ = "#$7F": C$ = "CLEAR E FLAG - MAKE COMPUTER THINK THIS WAS AN FIRQ": GoSub AO
    A$ = "PSHS": B$ = "A": C$ = "Save Condition Code": GoSub AO
    Print #1, "; THE RTI WILL NOW NOT RETURN TO WHERE IT WAS"
    Print #1, "; INTERRUPTED FROM - IT WILL RETURN TO THE MAIN PLAY"
    Print #1, "; COMMAND INTERPRETATION LOOP."
    Print #1, "!"
    Z$ = "Not60HzPlay"
    A$ = "RTI": B$ = "": C$ = "RETURN FROM INTERRUPT": GoSub AO
End If

Print #1, "* Main Program"
Print #1, "START:"
A$ = "PSHS": B$ = "CC,D,DP,X,Y,U": C$ = "Save the original BASIC Register values": GoSub AO
A$ = "STS": B$ = "RestoreStack+2": C$ = "save the original BASIC stack pointer value (try to Return at the end of the program) (self modify code)": GoSub AO
A$ = "LDS": B$ = "#$0400": C$ = "Set up the stack pointer": GoSub AO
A$ = "ORCC": B$ = "#$50": C$ = "Turn off the interrupts": GoSub AO
A$ = "LDA": B$ = "#$" + DirectPage$: GoSub AO
A$ = "TFR": B$ = "A,DP": C$ = "Setup the Direct page to use our variable location": GoSub AO
If CoCo3 = 1 Then
    'we are using CoCo 3 commands, So let's put it in CoCo 3 mode and hispeed
    Z$ = "* CoCo 3 commands were detected, Enabling CoCo3 mode and Hi Speed": GoSub AO
    A$ = "LDA": B$ = "#%01111100": C$ = "CoCo 3 Mode, MMU Enabled, GIME IRQ Enabled, GIME FIRQ Enabled, Vector RAM at FEXX enabled, Standard SCS Normal, ROM Map 16k Int, 16k Ext": GoSub AO
    A$ = "STA": B$ = "$FF90": C$ = "Make the changes": GoSub AO
    A$ = "STA": B$ = "$FFD9": C$ = "Double Speed mode": GoSub AO
End If
Z$ = "* Enable 6309 native mode if it's present": GoSub AO
A$ = "CLRA": GoSub AO
A$ = "TFR": B$ = "A,X": C$ = "6809 - X will now be $FF00, 6309 - X will equal $0000 (in native mode or not, doesn't matter)": GoSub AO
A$ = "CMPX": B$ = "#$0000": GoSub AO
A$ = "BNE": B$ = ">": C$ = "If <> 0 then skip forward it's a 6809": GoSub AO
A$ = "FCB": B$ = "$11,$3D,%00000001": C$ = "otherwise, put 6309 in native mode": GoSub AO
Z$ = "!": GoSub AO

Z$ = "* Enable 6 Bit DAC output": GoSub AO
A$ = "LDA": B$ = "$FF23": C$ = "* PIA1_Byte_3_IRQ_Ct_Snd * $FF23 GET PIA": GoSub AO
A$ = "ORA": B$ = "#%00001000": C$ = "* SET 6-BIT SOUND ENABLE": GoSub AO
A$ = "STA": B$ = "$FF23": C$ = "* PIA1_Byte_3_IRQ_Ct_Snd * $FF23 STORE": GoSub AO

If LineCommand = 1 Then
    A$ = "LDD": B$ = "#128": C$ = "Set D to the middle of the screen": GoSub AO
    A$ = "STD": B$ = "endX": C$ = "Save as previous end position": GoSub AO
    A$ = "LDD": B$ = "#96": C$ = "Set D to the middle of the screen": GoSub AO
    A$ = "STD": B$ = "endY": C$ = "Save as the previous end position": GoSub AO
End If
If PrintGraphicsText = 1 Then
    ' Found program uses PRINT #-3, to print to the graphics screen
    A$ = "LDD": B$ = "#$0E00": C$ = "Set D to the top left of the screen": GoSub AO
    A$ = "STD": B$ = "GraphicCURPOS": C$ = "Set the graphics cursor to the top left corner": GoSub AO
End If
If PlayCommand = 1 Then
    ' Initialize the PLAY command variables
    A$ = "LDD": B$ = "#$BA42": C$ = "MID HIGH VALUE + MID LOW VALUE": GoSub AO
    A$ = "STD": B$ = "VOLHI": C$ = "INITIALIZE PLAY VOLUME": GoSub AO
    A$ = "LDA": B$ = "#$02": GoSub AO
    A$ = "STA": B$ = "TEMPO": C$ = "INITIALIZE TEMPO TO 2": GoSub AO
    A$ = "STA": B$ = "OCTAVE": C$ = "INITIALIZE OCTAVE TO 3": GoSub AO
    A$ = "ASLA": C$ = "X2": GoSub AO
    A$ = "STA": B$ = "NOTELN": C$ = "INITIALIZE NOTE LENGTH TO 5": GoSub AO
    A$ = "CLR": B$ = "DOTVAL": C$ = "CLEAR NOTE TIMER SCALE FACTOR": GoSub AO
End If

A$ = "BRA": B$ = "SkipClear": C$ = "On startup skip ahead and do a BSR to this section to clear the variables, as CLEAR will use this code": GoSub AO
' Clear variable RAM  (make this a routine as the CLEAR command will use it to erase all the variables
Z$ = "ClearVariables:": GoSub AO
A$ = "LDX": B$ = "#StartClearHere": C$ = "Set the start address of the variables that will be cleared to zero when the program starts": GoSub AO
A$ = "CLRA": C$ = "Clear Accumulator A": GoSub AO
Z$ = "!"
A$ = "STA": B$ = ",X+": C$ = "Clear the variable space, move pointer forward": GoSub AO
A$ = "CMPX": B$ = "#EndClearHere": C$ = "Compare the current address to the end of the variables that will be cleared to zero when the program starts": GoSub AO
A$ = "BNE": B$ = "<": C$ = "Loop until all cleared": GoSub AO

' Restore sizes of numeric arrays
Lastnum$ = ""
If NumArrayVarsUsedCounter > 0 Then
    Print #1, "; Restore sizes of numeric array Elements"
    For ii = 0 To NumArrayVarsUsedCounter - 1
        A$ = "LDX": B$ = "#_ArrayNum_" + NumericArrayVariables$(ii): C$ = "Set the base pointer": GoSub AO
        Lastnum$ = ""
        ArrayWidth = NumericArrayBits(ii)
        If ArrayWidth = 8 Then
            ' 8 bit array
            For D1 = 0 To NumericArrayDimensions(ii) - 1
                Num = Val("&H" + Mid$(NumericArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 '+1 because it's zero based
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If Num$ <> Lastnum$ Then
                    A$ = "LDA": B$ = "#" + Num$: C$ = "Element size set with the DIM command": GoSub AO
                    Lastnum$ = Num$
                End If
                A$ = "STA": B$ = ",X+": GoSub AO
            Next D1
        Else
            ' 16 bit array
            For D1 = 0 To NumericArrayDimensions(ii) - 1
                Num = Val("&H" + Mid$(NumericArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 '+1 because it's zero based
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If Num$ <> Lastnum$ Then
                    A$ = "LDD": B$ = "#" + Num$: C$ = "Element size set with the DIM command": GoSub AO
                    Lastnum$ = Num$
                End If
                A$ = "STD": B$ = ",X++": GoSub AO
            Next D1
        End If
    Next ii
End If
' Clear String Array RAM
' Restore sizes of string arrays
If StringArrayVarsUsedCounter > 0 Then
    Print #1, "; Restore sizes of string array Elements"
    For ii = 0 To StringArrayVarsUsedCounter - 1
        A$ = "LDX": B$ = "#_ArrayStr_" + StringArrayVariables$(ii): C$ = "Set the base pointer": GoSub AO
        Lastnum$ = ""
        ArrayWidth = StringArrayBits(ii)
        If ArrayWidth = 8 Then
            ' 8 bit array
            For D1 = 0 To StringArrayDimensions(ii) - 1
                Num = Val("&H" + Mid$(StringArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 '+1 because it's zero based
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If Num$ <> Lastnum$ Then
                    A$ = "LDA": B$ = "#" + Num$: C$ = "Element size set with the DIM command": GoSub AO
                    Lastnum$ = Num$
                End If
                A$ = "STA": B$ = ",X+": GoSub AO
            Next D1
        Else
            ' 16 bit array
            For D1 = 0 To StringArrayDimensions(ii) - 1
                Num = Val("&H" + Mid$(StringArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 '+1 because it's zero based
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If Num$ <> Lastnum$ Then
                    A$ = "LDD": B$ = "#" + Num$: C$ = "Element size set with the DIM command": GoSub AO
                    Lastnum$ = Num$
                End If
                A$ = "STD": B$ = ",X++": GoSub AO
            Next D1
        End If
    Next ii
End If
A$ = "LDD": B$ = "#DataStart": C$ = "Get the Address where DATA starts": GoSub AO
A$ = "STD": B$ = "DATAPointer": C$ = "Save it in the DATAPointer variable": GoSub AO
A$ = "LDD": B$ = "#EveryCaseStack-2": C$ = "Table for nested CASE's, -2 because we add 2 everytime we come across a SELECT CASE/EVERYCASE": GoSub AO
A$ = "STD": B$ = "EveryCasePointer": C$ = "Set the CASEpointer for keeping track of nested SELECT CASE commands": GoSub AO
A$ = "RTS": C$ = "Return from clearing the variables": GoSub AO

Z$ = "SkipClear:": GoSub AO
A$ = "BSR": B$ = "ClearVariables": C$ = "Go clear the all the variables": GoSub AO
A$ = "DEC": B$ = "CASFLG": C$ = "set the case flag to $FF = Normal uppercase": GoSub AO
A$ = "LDD": B$ = ">$0112": C$ = "Get the Extended BASIC's TIMER value": GoSub AO
A$ = "STD": B$ = "_Var_Timer": C$ = "Use Basic's Timer as a starting point for the TIMER value, just in case someone uses it for Randomness": GoSub AO
A$ = "STD": B$ = "Seed1": C$ = "Save TIMER value as the Random number seed value": GoSub AO

' Address    Interrupt    CoCo 2 Vector    CoCo 3 Vector
' $FFF2      SWI3         $100             $FEEE
' $FFF4      SWI2         $103             $FEF1
' $FFF6      FIRQ         $10F             $FEF4    * Make it an RTI ($3B)
' $FEF8      IRQ          $10C             $FEF7    * Go to our BASIC_IRQ
' $FFFA      SWI          $106             $FEFA
' $FFFC      NMI          $109             $FEFD    * Go to our Disk controller IRQ
' $FFFE      RESET        $A027            $8C1B

' Setup IRQ jump address
A$ = "LDX": B$ = "$FFFE": C$ = "Get the RESET location": GoSub AO
A$ = "CMPX": B$ = "#$8C1B": C$ = "Check if it's a CoCo 3": GoSub AO
A$ = "BNE": B$ = "SaveCoCo1": C$ = "Setup IRQ, using CoCo 1 IRQ Jump location": GoSub AO
A$ = "STA": B$ = "$FFD9": C$ = "Put the CoCo 3 in double speed mode": GoSub AO
A$ = "LDX": B$ = "#$FEF7": C$ = "X = Address for the COCO 3 IRQ JMP": GoSub AO
A$ = "LDY": B$ = "#$FEFD": C$ = "Y = Address for the COCO 3 NMI JMP": GoSub AO
A$ = "BRA": B$ = ">": C$ = "Skip ahead": GoSub AO
Z$ = "SaveCoCo1": GoSub AO
A$ = "LDX": B$ = "#$010C": C$ = "X = Address for the COCO 1 IRQ JMP": GoSub AO
A$ = "LDY": B$ = "#$0109": C$ = "Y = Address for the COCO 1 NMI JMP": GoSub AO
Z$ = "!"
If PlayCommand = 1 Then
    A$ = "STX": B$ = "IRQAddress": C$ = "Save the IRQ address for the PLAY command to change/restore": GoSub AO
    A$ = "INC": B$ = "IRQAddress+1": C$ = "Increment the IRQAddress so it points at the actual JMP location": GoSub AO
End If
' Save the original IRQ jump address so we can restore it once done
A$ = "LDU": B$ = "#OriginalIRQ": C$ = "U=Address of the IRQ": GoSub AO
A$ = "LDA": B$ = ",X": C$ = "A = Branch Instruction": GoSub AO
A$ = "STA": B$ = ",U": C$ = "Save Branch Instruction": GoSub AO
A$ = "LDD": B$ = "1,X": C$ = "D = Address": GoSub AO
A$ = "STD": B$ = "1,U": C$ = "Backup the Address of the IRQ": GoSub AO
' Use our IRQ address
A$ = "LDA": B$ = "#$7E": C$ = "JMP instruction": GoSub AO
A$ = "STA": B$ = ",X": C$ = "A = JMP Instruction": GoSub AO
A$ = "LDU": B$ = "#BASIC_IRQ": C$ = "U=Address of the our IRQ": GoSub AO
A$ = "STU": B$ = "1,X": C$ = "U=Address of the IRQ": GoSub AO
If Disk = 1 Then
    ' Add our NMI
    A$ = "STA": B$ = ",Y": C$ = "A = JMP Instruction": GoSub AO
    A$ = "LDU": B$ = "#DNMISV": C$ = "D=Address of the our NMIRQ": GoSub AO
    A$ = "STU": B$ = "1,Y": C$ = "D=Address of the IRQ": GoSub AO
End If
' Make FIRQ an RTI
A$ = "LDA": B$ = "#$3B": C$ = "RTI instruction": GoSub AO
A$ = "STA": B$ = "$010F": C$ = "Save instruction for the CoCo1": GoSub AO
A$ = "STA": B$ = "$FEF4": C$ = "Save instruction for the CoCo3": GoSub AO
If SDCPLAY = 1 Or SDCVersionCheck = 1 Then ' If we are doing any SDC streaming check the version as it must byt V127 or higher
    A$ = "JSR": B$ = "CheckSDCFirmwareVersion": C$ = "Check the version of the SDC controller must be > v126": GoSub AO
End If
' Start the IRQ
Z$ = "* This is where we enable the IRQ": GoSub AO
A$ = "ANDCC": B$ = "#%11101111": C$ = "= %11101111 this will Enable the IRQ to start": GoSub AO

Z$ = "; *** User's Program code starts here ***": GoSub AO
System 1 ' End with flag of 1 = All went OK

' Tokens for variables type:
' &HF0 = Numeric Arrays
' &HF1 = String Arrays
' &HF2 = Regular Numeric Variable
' &HF3 = Regular String Variable
' &HF4 = Floating Point Variable
' &HF5 = Special characters like a EOL, colon, comma, semi colon, quote, brackets

' &HFB = DEF FN Function
' &HFC = Operator Command
' &HFD = String Command
' &HFE = Numeric Command
' &HFF = General Command

TokenizeExpression:
If Verbose > 1 Then Print "Expression to tokenize is:"; Expression$
' Go through command list and see if we match any, replacing any matches with tokens
Tokenized$ = ""
I = 1
GetNextToken:
While I <= Len(Expression$)
    i$ = Mid$(Expression$, I, 1)
    ' Check for  Special characters like a comma, semi colon, quote , brackets
    If i$ = Chr$(&H22) Then
        Tokenized$ = Tokenized$ + Chr$(&HF5) + i$ ' Tokenize the first quote
        I = I + 1 'Move past it
        i$ = Mid$(Expression$, I, 1)
        While i$ <> Chr$(&H22) ' keep copying until we get an end quote
            If i$ = Chr$(&H0D) Then Print "Error1: something is wrong getting the charcters in quotes at";: GoTo FoundError
            Tokenized$ = Tokenized$ + i$ ' Copy the data inside the quotes
            I = I + 1
            i$ = Mid$(Expression$, I, 1)
        Wend
        Tokenized$ = Tokenized$ + Chr$(&HF5) + i$ ' make the end quote also tokenized
        I = I + 1
        GoTo GetNextToken ' go handle stuff in quotes
    End If
    ' Check for a General command
    For c = 1 To GeneralCommandsCount
        Temp$ = UCase$(GeneralCommands$(c))
        BaseString$ = UCase$(Right$(Expression$, Len(Expression$) - I + 1))
        If Temp$ = "TIMER" Then Temp$ = "Ignore" ' Don't change TIMER commands to commands here, as they need to be left as variable names, they get fixed as TIMER= afterwards
        If InStr(BaseString$, Temp$) = 1 Then
            'Found a General Command
            If I > 1 Then
                ' Check for a space before the start of this command
                If Mid$(Expression$, I - 1, 1) = " " Or Mid$(Expression$, I - 1, 1) = ":" Then LeftSpace = 1 Else LeftSpace = 0
            Else
                LeftSpace = 1
            End If
            ' It could be a General command, check for a space after the found command
            If I + Len(Temp$) <= Len(Expression$) Then
                ' check if we have a space or special character or a number after the found command
                If Mid$(Expression$, i + Len(Temp$), 1) = " " Or Mid$(Expression$, i + Len(Temp$), 1) = chr$(&HF5) or Mid$(Expression$, i + Len(Temp$), 1)=chr$(&H22) _
                or (asc(Mid$(Expression$, i + Len(Temp$), 1)) >= &H30 and asc(Mid$(Expression$, i + Len(Temp$), 1)) <= &H39) Then
                    RightSpace = 1
                Else
                    RightSpace = 0
                End If
            Else
                RightSpace = 1
            End If
            ' Make changes for General commands that have bracket values, otherwise they will be picked up as numeric array variables
            If Temp$ = "SET" Then
                ' Found 3 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 4, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "GET" Then
                ' Found 3 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 4, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "PUT" Then
                ' Found 3 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 4, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "PSET" Then
                ' Found 4 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 5, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "LINE" Then
                ' Found 4 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 5, 1) = "(" Or Mid$(BaseString$, 5, 1) = "-" Then
                    'This general command does have an open bracket or -
                    RightSpace = 1
                End If
            End If
            If Temp$ = "PRINT" Then
                ' Found 5 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 6, 1) = "@" Or Mid$(BaseString$, 6, 1) = "#" Then
                    RightSpace = 1
                End If
            End If
            If Temp$ = "RESET" Then
                ' Found 5 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 6, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "PAINT" Then
                ' Found 5 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 6, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "CIRCLE" Then
                ' Found 6 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 7, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "PRESET" Then
                ' Found 6 letter general command which may or may not have a space before the open bracket
                If Mid$(BaseString$, 7, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "SDC_CLOSE" Then
                ' found a 9 character general command
                If Mid$(BaseString$, 10, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If Temp$ = "SDC_SETPOS" Then
                ' found a 9 character general command
                If Mid$(BaseString$, 11, 1) = "(" Then
                    'This general command does have an open bracket
                    RightSpace = 1
                End If
            End If
            If LeftSpace = 1 And RightSpace = 1 Then
                If Temp$ = "GMODE" Then
                    ' Find out which graphics modes the user wants in their program
                    V$ = ""
                    p = I + 6
                    GettingGmode:
                    If p <= Len(Expression$) Then
                        If Asc(Mid$(Expression$, p, 1)) >= Asc("0") And Asc(Mid$(Expression$, p, 1)) <= Asc("9") Then
                            V$ = V$ + Mid$(Expression$, p, 1)
                            p = p + 1
                        Else
                            GoTo GotGMode
                        End If
                        GoTo GettingGmode
                    End If
                    GotGMode:
                    GModeLib(Val(V$)) = 1
                    V1$ = ""
                    If Mid$(Expression$, p, 1) = " " Then
                        p = p + 3
                        GettingGmodePage:
                        If p <= Len(Expression$) Then
                            If Asc(Mid$(Expression$, p, 1)) >= Asc("0") And Asc(Mid$(Expression$, p, 1)) <= Asc("9") Then
                                V1$ = V1$ + Mid$(Expression$, p, 1)
                                p = p + 1
                            Else
                                GoTo GotGModePage
                            End If
                            GoTo GettingGmodePage
                        End If
                        GotGModePage:
                        If Len(V1$) = 0 Then V1$ = "2" ' If a variable is used then we will set it to two pages to be reserved
                        Temp2 = GModePageLib(Val(V$))
                        If Temp2 < Val(V1$) Then GModePageLib(Val(V$)) = Val(V1$)
                    End If
                End If
                GoSub AddToGeneralCommandList ' Add General Command Temp$ to the general command list
                Num = c: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                Tokenized$ = Tokenized$ + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB) 'Token &HFF is for General Commands
                ' Check for a REM or '
                If c = C_REM Or c = C_REMApostrophe Then
                    'We found a REM or ' - copy the rest of this line
                    I = I + Len(Temp$) ' move pointer forward
                    While I <= Len(Expression$)
                        i$ = Mid$(Expression$, I, 1)
                        Tokenized$ = Tokenized$ + i$
                        I = I + 1
                    Wend
                    GoTo TokenAdded0
                End If
                ' Find the DATA Token
                Check$ = "DATA": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
                ' Check for a DATA
                If c = ii Then
                    'We found a DATA command - copy the rest of this line
                    I = I + Len(Temp$) ' move pointer forward past "DATA" command
                    While I <= Len(Expression$) And i$ <> Chr$(&HF5)
                        i$ = Mid$(Expression$, I, 1): I = I + 1
                        If i$ = Chr$(&H22) Then
                            Tokenized$ = Tokenized$ + Chr$(&HF5) + i$ ' Tokenize the first quote
                            i$ = Mid$(Expression$, I, 1): I = I + 1
                            While i$ <> Chr$(&H22) ' keep copying until we get an end quote
                                Tokenized$ = Tokenized$ + i$ ' Copy the data inside the quotes
                                i$ = Mid$(Expression$, I, 1): I = I + 1
                            Wend
                            Tokenized$ = Tokenized$ + Chr$(&HF5) + i$ ' make the end quote also tokenized
                        Else
                            Tokenized$ = Tokenized$ + i$
                        End If
                    Wend
                    If i$ = Chr$(&HF5) Then
                        'Found a control Token, copy the next byte
                        i$ = Mid$(Expression$, I, 1)
                        Tokenized$ = Tokenized$ + i$
                        I = I + 1
                    End If
                    GoTo TokenAdded0
                End If
                ' Find the DEF Token
                Check$ = "DEF": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
                ' Check for a DEF
                If c = ii Then
                    'We found a DEF command, we need to handle the FNx()=...  part
                    I = I + Len(Temp$) + 3 ' move pointer forward so it now points at the FN label
                    Temp$ = ""
                    ' Get the FN variable name in Temp$
                    While I <= Len(Expression$)
                        i$ = Mid$(Expression$, I, 1)
                        If i$ = "(" Then Exit While
                        Temp$ = Temp$ + i$
                        I = I + 1
                    Wend
                    DefLabel$(DefLabelCount) = Temp$
                    Num = DefLabelCount: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                    Tokenized$ = Tokenized$ + Chr$(&HFB) + Chr$(MSB) + Chr$(LSB) ' Flag this as an FN #, and the value of this FN label
                    DefLabelCount = DefLabelCount + 1
                    GoTo TokenAdded0
                End If
                I = I + Len(Temp$) ' move pointer forward
                GoTo TokenAdded0
            End If
        End If
    Next c
    ' Check for a Numeric command
    For c = 1 To NumericCommandsCount
        Temp$ = UCase$(NumericCommands$(c))
        BaseString$ = UCase$(Right$(Expression$, Len(Expression$) - I + 1))
        If InStr(BaseString$, Temp$) = 1 Then
            'Found a Numeric Command
            If I > 1 Then
                ' Check for a stuff before the start of this command
                If Mid$(Expression$, I - 1, 1) = " " Or Mid$(Expression$, I - 1, 1) = "(" Or Mid$(Expression$, I - 1, 1) = "=" Then LeftSpace = 1 Else LeftSpace = 0
            Else
                LeftSpace = 1
            End If
            ' It could be a General command, check for a space after the found command
            If I + Len(Temp$) < Len(Expression$) Then
                ' check if we have a space or ( after the found command
                If Mid$(Expression$, I + Len(Temp$), 1) = " " Or Mid$(Expression$, I + Len(Temp$), 1) = "(" Then RightSpace = 1 Else RightSpace = 0
            Else
                RightSpace = 1
            End If
            ' Check for a FN
            If Temp$ = "FN" And LeftSpace = 1 Then
                'We found an FN command, ignore the variablename before the (
                Temp$ = ""
                I = I + 2 ' skip past FN
                While I <= Len(Expression$)
                    i$ = Mid$(Expression$, I, 1)
                    If i$ = "(" Then Exit While
                    Temp$ = Temp$ + i$
                    I = I + 1
                Wend
                'Find the FN Label number that matches and write it to the Tokenized file
                For ii = 0 To DefLabelCount
                    If DefLabel$(ii) = Temp$ Then
                        Num = ii: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                        Tokenized$ = Tokenized$ + Chr$(&HFB) + Chr$(MSB) + Chr$(LSB) ' Flag this as an FN #, and the value of this FN label
                        Exit For
                    End If
                Next ii
            End If
            If LeftSpace = 1 And RightSpace = 1 Then
                GoSub AddToNumericCommandList
                Num = c: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                Tokenized$ = Tokenized$ + Chr$(&HFE) + Chr$(MSB) + Chr$(LSB) 'Token $FE is for Numeric Commands
                I = I + Len(Temp$) ' move pointer forward
                GoTo TokenAdded0
            End If
        End If
    Next c
    ' Check for a String command
    For c = 1 To StringCommandsCount
        Temp$ = UCase$(StringCommands$(c))
        BaseString$ = UCase$(Right$(Expression$, Len(Expression$) - I + 1))
        If InStr(BaseString$, Temp$) = 1 Then
            'Found a String Command
            GoSub AddToStringCommandList
            Num = c: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
            Tokenized$ = Tokenized$ + Chr$(&HFD) + Chr$(MSB) + Chr$(LSB) 'Token $FD is for String Commands
            I = I + Len(Temp$) ' move pointer forward
            GoTo TokenAdded0
        End If
    Next c
    ' Check for an Operator command
    For c = 1 To OperatorCommandsCount
        Temp$ = UCase$(OperatorCommands$(c))
        BaseString$ = UCase$(Right$(Expression$, Len(Expression$) - I + 1))
        If InStr(BaseString$, Temp$) = 1 Then
            'Found an Operator Command
            If c > &H29 Then
                Tokenized$ = Tokenized$ + Chr$(&HFC) + Chr$(c) 'Token &HFC is for Operator Commands
                I = I + Len(Temp$) ' move pointer forward
                GoTo TokenAdded0
            Else
                If I > 1 Then
                    ' Check for a stuff before the start of this command
                    If Mid$(Expression$, I - 1, 1) = " " Then LeftSpace = 1 Else LeftSpace = 0
                Else
                    LeftSpace = 1
                End If
                ' It could be a General command, check for a space after the found command
                If I + Len(Temp$) < Len(Expression$) Then
                    ' check if we have a space after the found command
                    If Mid$(Expression$, I + Len(Temp$), 1) = " " Then RightSpace = 1 Else RightSpace = 0
                Else
                    RightSpace = 1
                End If
                If LeftSpace = 1 And RightSpace = 1 Then
                    Tokenized$ = Tokenized$ + Chr$(&HFC) + Chr$(c) 'Token &HFC is for Operator Commands
                    I = I + Len(Temp$) ' move pointer forward
                    GoTo TokenAdded0
                End If
            End If
        End If
    Next c
    AddTokenAsIs0:
    Tokenized$ = Tokenized$ + i$
    I = I + 1
    TokenAdded0:
    If Temp$ = "DRAW" Then ' Found a Draw command, change any X inside a quote to ":DRAW (whatever before the next semi colon" : DRAW" the rest
        Temp$ = Right$(Expression$, Len(Expression$) - I)
        Expression$ = Left$(Expression$, I)
        EndString = InStr(Temp$, Chr$(&HF5)) ' Mark end at a Colon
        If EndString = 0 Then
            EndString = Len(Temp$) ' If no colons then end is the end of string
            EndPart$ = ""
        Else
            EndPart$ = Right$(Temp$, Len(Temp$) - EndString + 1)
            Temp$ = Left$(Temp$, EndString - 1)
        End If
        While Right$(Temp$, 1) = " ": Temp$ = Left$(Temp$, Len(Temp$) - 1): Wend
        ' Remove spaces in quoted parts
        Temp1$ = ""
        qc = 0
        For T1 = 1 To Len(Temp$)
            T1$ = Mid$(Temp$, T1, 1)
            If T1$ = Chr$(&H22) Then qc = qc + 1
            If (qc And 1) = 1 Then
                If T1$ <> " " Then
                    Temp1$ = Temp1$ + T1$
                End If
            Else
                Temp1$ = Temp1$ + T1$
            End If
        Next T1
        Temp$ = Temp1$
        Temp1$ = ""
        T1 = 1
        '        While T1 < Len(Temp$) - 1
        '            If UCase$(Mid$(Temp$, T1, 2)) <> ";X" Then
        '                Temp1$ = Temp1$ + Mid$(Temp$, T1, 1)
        '            Else
        '                Temp1$ = Temp1$ + Chr$(&H22) + " " ' add end quote & a space
        '                Temp1$ = Temp1$ + Chr$(&HF5) + ":DRAW " 'add : DRAW
        '                T1 = T1 + 2
        '                While Mid$(Temp$, T1, 1) <> ";"
        '                    Temp1$ = Temp1$ + Mid$(Temp$, T1, 1)
        '                    T1 = T1 + 1
        '                Wend
        '                Temp1$ = Temp1$ + " " ' add end quote   & a space
        '                Temp1$ = Temp1$ + Chr$(&HF5) + ":DRAW " + Chr$(&H22) 'add : DRAW
        '                T1 = T1 - 1
        '            End If
        '            T1 = T1 + 1
        '        Wend
        While T1 < Len(Temp$) - 1
            If UCase$(Mid$(Temp$, T1, 1)) <> "X" Then
                Temp1$ = Temp1$ + Mid$(Temp$, T1, 1)
            Else
                If Right$(Temp$, 2) <> Chr$(&H3B) + Chr$(&H22) Then
                    ' if it doesn't end with a semi + quote
                    Temp$ = Left$(Temp$, Len(Temp$) - 1) + Chr$(&H3B) + Chr$(&H22) 'Make it end with a semi colon and a quote
                End If
                Temp1$ = Temp1$ + Chr$(&H22) + " " ' add end quote & a space
                Temp1$ = Temp1$ + Chr$(&HF5) + ":DRAW " 'add :DRAW
                T1 = T1 + 1 ' move past the X
                Do Until Mid$(Temp$, T1, 1) = ";" ' Look for end semi colon
                    Temp1$ = Temp1$ + Mid$(Temp$, T1, 1)
                    T1 = T1 + 1
                Loop
                Temp1$ = Temp1$ + " " ' add end quote & a space
                Temp1$ = Temp1$ + Chr$(&HF5) + ":DRAW " + Chr$(&H22) 'add :DRAW
                T1 = T1 - 1
            End If
            T1 = T1 + 1
        Wend

        If T1 < Len(Temp$) Then Temp1$ = Temp1$ + Right$(Temp$, Len(Temp$) - T1 + 1)
        ReplaceCount = Replace(Temp1$, "DRAW " + Chr$(&H22) + ";", "DRAW " + Chr$(&H22)) '  Replace(text$, old$, new$)  ' Change DRAW "; to DRAW "
        ReplaceCount = Replace(Temp1$, "DRAW " + Chr$(&H22) + Chr$(&H22), "") '  Replace(text$, old$, new$)  ' Remove null Draw commands
        ReplaceCount = Replace(Temp1$, Chr$(&HF5) + ": " + Chr$(&HF5) + ":", Chr$(&HF5) + ":") '  Replace(text$, old$, new$)  ' Remove null Draw commands
        Expression$ = Expression$ + Temp1$ + " " + EndPart$
    End If
    If Temp$ = "PLAY" Then ' Found a Play command, change any X inside a quote to ":PLAY (whatever before the next semi colon" : PLAY" the rest
        Temp$ = Right$(Expression$, Len(Expression$) - I)
        Expression$ = Left$(Expression$, I)
        EndString = InStr(Temp$, Chr$(&HF5)) ' Mark end at a Colon
        If EndString = 0 Then
            EndString = Len(Temp$) ' If no colons then end is the end of string
            EndPart$ = ""
        Else
            EndPart$ = Right$(Temp$, Len(Temp$) - EndString + 1)
            Temp$ = Left$(Temp$, EndString - 1)
        End If
        While Right$(Temp$, 1) = " ": Temp$ = Left$(Temp$, Len(Temp$) - 1): Wend
        ' Remove spaces in quoted parts
        Temp1$ = ""
        qc = 0
        For T1 = 1 To Len(Temp$)
            T1$ = Mid$(Temp$, T1, 1)
            If T1$ = Chr$(&H22) Then qc = qc + 1
            If (qc And 1) = 1 Then
                If T1$ <> " " Then
                    Temp1$ = Temp1$ + T1$
                End If
            Else
                Temp1$ = Temp1$ + T1$
            End If
        Next T1
        Temp$ = Temp1$
        Temp1$ = ""
        T1 = 1
        While T1 < Len(Temp$) - 1
            If UCase$(Mid$(Temp$, T1, 1)) <> "X" Then
                Temp1$ = Temp1$ + Mid$(Temp$, T1, 1)
            Else
                ' Found an X
                If Right$(Temp$, 2) <> Chr$(&H3B) + Chr$(&H22) Then
                    ' if it doesn't end with a semicolon + quote
                    Temp$ = Left$(Temp$, Len(Temp$) - 1) + Chr$(&H3B) + Chr$(&H22) 'Make it end with a semi colon and a quote
                End If
                Temp1$ = Temp1$ + Chr$(&H22) + " " ' add end quote & a space
                Temp1$ = Temp1$ + Chr$(&HF5) + ":PLAY " 'add :PLAY
                T1 = T1 + 1 ' move past the X
                Do Until Mid$(Temp$, T1, 1) = ";" ' Look for end semi colon
                    Temp1$ = Temp1$ + Mid$(Temp$, T1, 1)
                    T1 = T1 + 1
                Loop
                Temp1$ = Temp1$ + " " ' add end quote & a space
                Temp1$ = Temp1$ + Chr$(&HF5) + ":PLAY " + Chr$(&H22) 'add :PLAY
                T1 = T1 - 1
            End If
            T1 = T1 + 1
        Wend
        If T1 < Len(Temp$) Then Temp1$ = Temp1$ + Right$(Temp$, Len(Temp$) - T1 + 1)
        ReplaceCount = Replace(Temp1$, "PLAY " + Chr$(&H22) + ";", "PLAY " + Chr$(&H22)) '  Replace(text$, old$, new$)  ' Change PLAY "; to PLAY "
        ReplaceCount = Replace(Temp1$, "PLAY " + Chr$(&H22) + Chr$(&H22), "") '  Replace(text$, old$, new$)  ' Remove null PLAY commands
        ReplaceCount = Replace(Temp1$, Chr$(&HF5) + ": " + Chr$(&HF5) + ":", Chr$(&HF5) + ":") '  Replace(text$, old$, new$)  ' Remove null PLAY commands
        If Left$(Temp1$, 9) = Chr$(&H22) + Chr$(&H22) + " " + Chr$(&HF5) + ":PLAY" Then Temp1$ = Right$(Temp1$, Len(Temp1$) - 9) ' remove an empty first PLAY ""
        Expression$ = Expression$ + Temp1$ + " " + EndPart$
    End If
Wend
If Verbose > 1 Then
    Print "1st:"
    For I = 1 To Len(Tokenized$)
        a = Asc(Mid$(Tokenized$, I, 1))
        If a < 16 Then Print "0";
        Print Hex$(Asc(Mid$(Tokenized$, I, 1)));
    Next I
    Print
End If
' Special commands that need manual tweaking
' Check and skip lines that start with REMarks
Num = C_REM
GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
If InStr(Tokenized$, Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) = 1 Then
    ' Found a REM at the start of this line, skip checking special commands
    GoTo SkipCheckingSpecialCommands
End If
Num = C_REMApostrophe
GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
If InStr(Tokenized$, Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) = 1 Then
    ' Found a ' at the start of this line, skip checking special commands
    GoTo SkipCheckingSpecialCommands
End If

' LINE may or may not have ,B or BF at the end which might get turned into variable below
' Change the Tokenized$ command so it will have
' after ,PSET or ,PRESET we will have
' ,0,0 - No Box or Box Fill
' ,1,0 - Draw a Box
' ,1,1 - Draw a box and fill it

Check$ = "LINE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
GoSub FixLineCommand ' Find the LINE Token and fix the formatting if found

' GET command, we must have an array pointer after the last last close bracket and comma
TempCOM$ = ""
I = 1
' Find the GET Token
Num = C_GET
GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
While InStr(I, Tokenized$, Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) > 0 ' See if we still have any GET commands to deal with
    Start = I
    ' This line of code has the GET command in it
    I = InStr(I, Tokenized$, Chr$(&H29) + Chr$(&H20) + Chr$(&H2C) + Chr$(&H20)) ' Find the ") , "
    If I = 0 Then Print "Error: GET command doesn't have Close bracket and comma on";: GoTo FoundError 'Can't find the ),
    I = I + 4 ' Move past the ), - Now point at the array name
    ArrayStart = I
    Temp$ = ""
    While I <= Len(Tokenized$)
        i$ = Mid$(Tokenized$, I, 1): I = I + 1
        If i$ = Chr$(&H20) Or i$ = Chr$(&HF5) Then I = I - 1: Exit While
        Temp$ = Temp$ + i$
    Wend
    If i$ = Chr$(&H20) Then
        ' Check for a , G after the array
        ANameEnd = InStr(I, Tokenized$, ", G") ' Find the ", G"
        If ANameEnd > 0 Then
            I = ANameEnd + 3
            i$ = ""
        Else
            Print "Error: GET command ends with something other than a ,G";: GoTo FoundError 'Can't find the PUT action
        End If
    End If
    Dimensions = 2: ' graphics have two dimensions
    GoSub AddToNumArrayVariableList ' Add variable Temp$ to the Numeric array variable List and the number of dimensions the String array has
    If Found = 1 Then
        Num = ii: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
        GETArray$ = Chr$(&HF0) + Chr$(MSB) + Chr$(LSB) + Chr$(2)
    Else
        Num = NumArrayVarsUsedCounter - 1: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
        GETArray$ = Chr$(&HF0) + Chr$(MSB) + Chr$(LSB) + Chr$(2)
    End If
    TempCOM$ = TempCOM$ + Mid$(Tokenized$, Start, ArrayStart - Start - 1) + GETArray$ ' Copy the rest of the PUT command, I points at the Colon or the end of this line
    Check$ = "GET": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
    Num = ii
    GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
Wend
If TempCOM$ <> "" Then
    ' We found a GET command
    Tokenized$ = TempCOM$ + Right$(Tokenized$, Len(Tokenized$) - I + 1)
End If

' PUT command, we must have an array pointer after the last last close bracket and comma
TempCOM$ = ""
I = 1
' Find the PUT Token
Num = C_PUT
GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
While InStr(I, Tokenized$, Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) > 0 ' See if we still have any PUT commands to deal with
    Start = I
    ' This line of code has the PUT command in it
    I = InStr(I, Tokenized$, Chr$(&H29) + Chr$(&H20) + Chr$(&H2C) + Chr$(&H20)) ' Find the ") , "
    If I = 0 Then Print "Error: PUT command doesn't have Close bracket and comma on";: GoTo FoundError 'Can't find the ),
    I = I + 4 ' Move past the ), - Now point at the array name
    ArrayStart = I
    Temp$ = ""
    While I <= Len(Tokenized$)
        i$ = Mid$(Tokenized$, I, 1): I = I + 1
        If i$ = Chr$(&H20) Or i$ = Chr$(&HF5) Then I = I - 1: Exit While
        Temp$ = Temp$ + i$
    Wend
    PUTPSET = 1 ' Default to ,PSET
    If i$ = Chr$(&H20) Then
        Num = C_PSET
        ' Extract the high byte (higher 8 bits)
        MSByte = Num \ 256 ' Integer division by 256
        ' Extract the low byte (lower 8 bits)
        LSByte = Num And 255 ' Equivalent to num MOD 256
        ANameEnd = InStr(I, Tokenized$, Chr$(&H2C) + Chr$(&H20) + Chr$(&HFF) + Chr$(MSByte) + Chr$(LSByte)) ' Find the " , PSET"
        If ANameEnd > 0 Then
            PUTPSET = 1
            PutType = 0
            I = ANameEnd + 5
        Else
            Num = C_PRESET
            ' Extract the high byte (higher 8 bits)
            MSByte = Num \ 256 ' Integer division by 256
            ' Extract the low byte (lower 8 bits)
            LSByte = Num And 255 ' Equivalent to num MOD 256
            ANameEnd = InStr(I, Tokenized$, Chr$(&H2C) + Chr$(&H20) + Chr$(&HFF) + Chr$(MSByte) + Chr$(LSByte)) ' Find the " , PRESET"
            If ANameEnd > 0 Then
                PUTPRESET = 1
                PutType = 1
                I = ANameEnd + 5
            Else
                ANameEnd = InStr(I, Tokenized$, Chr$(&H2C) + Chr$(&H20) + Chr$(&HFC) + Chr$(&H10)) ' Find the " , AND"
                If ANameEnd > 0 Then
                    PUTAND = 1
                    PutType = 2
                    I = ANameEnd + 4
                Else
                    ANameEnd = InStr(I, Tokenized$, Chr$(&H2C) + Chr$(&H20) + Chr$(&HFC) + Chr$(&H11)) ' Find the " , OR"
                    If ANameEnd > 0 Then
                        PUTOR = 1
                        PutType = 3
                        I = ANameEnd + 4
                    Else
                        ANameEnd = InStr(I, Tokenized$, Chr$(&H2C) + Chr$(&H20) + Chr$(&HFC) + Chr$(&H14)) ' Find the " , NOT"
                        If ANameEnd > 0 Then
                            PUTNOT = 1
                            PutType = 4
                            I = ANameEnd + 4
                        Else
                            ANameEnd = InStr(I, Tokenized$, Chr$(&H2C) + Chr$(&H20) + Chr$(&HFC) + Chr$(&H13)) ' Find the " , XOR"
                            If ANameEnd > 0 Then
                                PUTXOR = 1
                                PutType = 5
                                I = ANameEnd + 4
                            Else
                                Print "Error: PUT command doesn't end with an action like PSET,PRESET,AND,OR or NOT on";: GoTo FoundError 'Can't find the PUT action
                            End If
                        End If
                    End If
                End If
            End If
        End If
    End If
    Dimensions = 2: ' graphics have two dimensions
    GoSub AddToNumArrayVariableList ' Add variable Temp$ to the Numeric array variable List and the number of dimensions the String array has
    If Found = 1 Then
        Num = ii: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
        ArrayPutType$ = Chr$(&HF0) + Chr$(MSB) + Chr$(LSB) + Chr$(PutType)
    Else
        Num = NumArrayVarsUsedCounter - 1: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
        ArrayPutType$ = Chr$(&HF0) + Chr$(MSB) + Chr$(LSB) + Chr$(PutType)
    End If
    TempCOM$ = TempCOM$ + Mid$(Tokenized$, Start, ArrayStart - Start - 1) + ArrayPutType$ ' Copy the rest of the PUT command, I points at the Colon or the end of this line
    Check$ = "PUT": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
    Num = ii
    GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
Wend
If TempCOM$ <> "" Then
    ' We found a PUT command
    Tokenized$ = TempCOM$ + Right$(Tokenized$, Len(Tokenized$) - I + 1)
End If

SkipCheckingSpecialCommands:
' Tokens for variables type:
' &HF0 = Numeric Arrays
' &HF1 = String Arrays
' &HF2 = Regular Numeric Variable
' &HF3 = Regular String Variable
' &HF4 = Floating Point Variable
' &HF5 = Special characters like a EOL, colon, comma, semi colon, quote, brackets

' &HFB = DEF FN Function
' &HFC = Operator Command
' &HFD = String Command
' &HFE = Numeric Command
' &HFF = General Command

' Expression has now been tokenized with commands:
' Found $FB,FC,FD,FE,FF

' Next tokenize Numeric Arrays & String Arrays
' Find Numeric & String Arrays

Expression$ = Tokenized$
Tokenized$ = ""
I = 1
GetNextToken1:
While I <= Len(Expression$)
    i$ = Mid$(Expression$, I, 1): I = I + 1
    If Asc(i$) > &HEF Then
        ' We hit a token, copy it
        Tokenized$ = Tokenized$ + i$
        Select Case Asc(i$)
            Case &HF5:
                'We have a special character tokenized already
                i$ = Mid$(Expression$, I, 1): I = I + 1 ' Get the Special character
                Tokenized$ = Tokenized$ + i$ ' Copy it
                If i$ = Chr$(&H22) Then
                    ' Found a quote, so copy all until we get the end tokenized quote
                    i$ = Mid$(Expression$, I, 1): I = I + 1 ' Get a byte
                    While i$ <> Chr$(&H22) ' keep copying until we find the end quote
                        Tokenized$ = Tokenized$ + i$ ' Copy the byte
                        i$ = Mid$(Expression$, I, 1): I = I + 1 ' Get a byte
                    Wend
                    Tokenized$ = Tokenized$ + i$ ' Copy the end quote
                End If
                GoTo GetNextToken1
            Case &HFB:
                ' DEF FN Function?
                i$ = Mid$(Expression$, I, 1): I = I + 1: Tokenized$ = Tokenized$ + i$
                i$ = Mid$(Expression$, I, 1): I = I + 1: Tokenized$ = Tokenized$ + i$
                GoTo GetNextToken1
            Case &HFC:
                ' Operator?
                i$ = Mid$(Expression$, I, 1): I = I + 1: Tokenized$ = Tokenized$ + i$
                GoTo GetNextToken1
            Case &HFD:
                ' String Command?
                i$ = Mid$(Expression$, I, 1): I = I + 1: Tokenized$ = Tokenized$ + i$
                i$ = Mid$(Expression$, I, 1): I = I + 1: Tokenized$ = Tokenized$ + i$
                GoTo GetNextToken1
            Case &HFE:
                ' Numeric Command?
                i$ = Mid$(Expression$, I, 1): I = I + 1: Tokenized$ = Tokenized$ + i$
                i$ = Mid$(Expression$, I, 1): I = I + 1: Tokenized$ = Tokenized$ + i$
                'skip forward until after the open and close brackets
                GoTo GetNextToken1
            Case &HFF:
                ' General Command?
                i$ = Mid$(Expression$, I, 1): I = I + 1: Tokenized$ = Tokenized$ + i$
                V = Asc(i$) * 256
                i$ = Mid$(Expression$, I, 1): I = I + 1: Tokenized$ = Tokenized$ + i$
                V = V + Asc(i$)
                If V = C_REM Then
                    ' Found a REM, copy the rest of the expression as is, no more tokenizing needed
                    While I <= Len(Expression$)
                        i$ = Mid$(Expression$, I, 1): I = I + 1
                        Tokenized$ = Tokenized$ + i$
                    Wend
                    GoTo GetNextToken1
                End If
                If V = C_REMApostrophe Then
                    ' Found an apostrophe ' copy the rest of the expression as is, no more tokenizing needed
                    While I <= Len(Expression$)
                        i$ = Mid$(Expression$, I, 1): I = I + 1
                        Tokenized$ = Tokenized$ + i$
                    Wend
                    GoTo GetNextToken1
                End If
                ' Check for a DATA
                If V = C_DATA Then
                    'We found a DATA command - copy the rest of this line upto a colon or the end
                    While I <= Len(Expression$)
                        i$ = Mid$(Expression$, I, 1): I = I + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&HF5) Then
                            i$ = Mid$(Expression$, I, 1): I = I + 1
                            Tokenized$ = Tokenized$ + i$
                            If i$ = Chr$(&H3A) Then Exit While
                        End If
                    Wend
                End If
                If V = C_PUT Or V = C_GET Then ' Check for a PUT or GET command
                    'We found a PUT or GET command - copy the rest of this line upto a colon or the end
                    While I <= Len(Expression$)
                        i$ = Mid$(Expression$, I, 1): I = I + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&HF5) Then
                            i$ = Mid$(Expression$, I, 1): I = I + 1
                            Tokenized$ = Tokenized$ + i$
                            If i$ = Chr$(&H3A) Then Exit While
                        End If
                    Wend
                End If
                GoTo GetNextToken1
        End Select
    End If
    CheckStart = I - 1 ' This is as far back as we can go looking for an array label
    ' Find an open bracket, which could be part of an array variable
    For ii = CheckStart + 1 To Len(Expression$)
        If Mid$(Expression$, ii, 1) = "=" Then Exit For ' This is not an array
        If Mid$(Expression$, ii, 1) = "(" Then
            ' Found an open bracket
            ' Might be the start of an array variable
            ' Test for $ or a letter before the "("
            Check$ = UCase$(Mid$(Expression$, ii - 1, 1))
            If Check$ = "$" Then ' Is it a string array?
                'We found a string array to tokenize
                Start = ii - 1 ' start points at the character before the "("
                While Start >= CheckStart
                    Check$ = Mid$(Expression$, Start, 1)
                        If (Asc(Check$) >= Asc("A") And Asc(Check$) <= Asc("Z")) Or (Asc(Check$) >= Asc("0") And Asc(Check$) <= Asc("9")) Or _
                           (Asc(Check$) >= Asc("a") And Asc(Check$) <= Asc("z")) Then
                        ' It is a letter or number?
                        Start = Start - 1
                    Else
                        Exit While
                    End If
                Wend
                LabelStart = Start + 1
                If LabelStart <> CheckStart Then GoTo CopyOtherBytes 'We missed some bytes before this array, go deal with them first
                Temp$ = Mid$(Expression$, LabelStart, ii - LabelStart - 1) '-1 as we don't want the $
                'Count the dimensions in the array
                BracketStart = ii
                Start = ii + 1 ' Start after the open bracket
                Dimensions = 1: Bracket = 1
                While Bracket > 0
                    If Start > Len(Expression$) Then Print "Need a close bracket on";: GoTo FoundError
                    If Bracket = 1 And Mid$(Expression$, Start, 1) = "," Then Dimensions = Dimensions + 1
                    If Mid$(Expression$, Start, 1) = "(" Then Bracket = Bracket + 1
                    If Mid$(Expression$, Start, 1) = ")" Then Bracket = Bracket - 1
                    Start = Start + 1
                Wend
                GoSub AddToStringArrayVariableList ' Add variable Temp$ to the String array variable List and the number of dimensions the String array has
                If Found = 1 Then
                    Num = ii: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                    Tokenized$ = Tokenized$ + Chr$(&HF1) + Chr$(MSB) + Chr$(LSB) + Chr$(Dimensions)
                Else
                    Num = StringArrayVarsUsedCounter - 1: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                    Tokenized$ = Tokenized$ + Chr$(&HF1) + Chr$(MSB) + Chr$(LSB) + Chr$(Dimensions)
                End If
                ' Copy the rest of the array to tokenized$
                For y = BracketStart To Start - 1
                    Tokenized$ = Tokenized$ + Mid$(Expression$, y, 1)
                Next y
                I = Start ' Update i's position
                GoTo GetNextToken1
            Else ' Not a string array, check for Numeric array
                If (Asc(Check$) >= Asc("A") And Asc(Check$) <= Asc("Z")) Or (Asc(Check$) >= Asc("0") And Asc(Check$) <= Asc("9")) Or _
                  (Asc(Check$) >= Asc("a") And Asc(Check$) <= Asc("z")) Then ' Is it a letter or number?
                    ' It is part of a Numeric array variable name
                    Start = ii - 1 ' start points at the character before the "("
                    While Start >= CheckStart
                        Check$ = Mid$(Expression$, Start, 1)
                        If (Asc(Check$) >= Asc("A") And Asc(Check$) <= Asc("Z")) Or (Asc(Check$) >= Asc("0") And Asc(Check$) <= Asc("9")) Or _
                           (Asc(Check$) >= Asc("a") And Asc(Check$) <= Asc("z")) Then
                            ' It is a letter or number?
                            Start = Start - 1
                        Else
                            Exit While
                        End If
                    Wend
                    LabelStart = Start + 1
                    If LabelStart <> CheckStart Then GoTo CopyOtherBytes 'We missed some bytes before this array, go deal with them first
                    Temp$ = Mid$(Expression$, LabelStart, ii - LabelStart)
                    'Count the dimensions in the array
                    BracketStart = ii
                    Start = ii + 1 ' Start after the open bracket
                    Dimensions = 1: Bracket = 1
                    While Bracket > 0
                        If Start > Len(Expression$) Then Print "Need a close bracket on";: GoTo FoundError
                        If Bracket = 1 And Mid$(Expression$, Start, 1) = "," Then Dimensions = Dimensions + 1
                        If Mid$(Expression$, Start, 1) = "(" Then Bracket = Bracket + 1
                        If Mid$(Expression$, Start, 1) = ")" Then Bracket = Bracket - 1
                        Start = Start + 1
                    Wend
                    GoSub AddToNumArrayVariableList ' Add variable Temp$ to the Numeric array variable List and the number of dimensions the String array has
                    If Found = 1 Then
                        Num = ii: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                        Tokenized$ = Tokenized$ + Chr$(&HF0) + Chr$(MSB) + Chr$(LSB) + Chr$(Dimensions)
                    Else
                        Num = NumArrayVarsUsedCounter - 1: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                        Tokenized$ = Tokenized$ + Chr$(&HF0) + Chr$(MSB) + Chr$(LSB) + Chr$(Dimensions)
                    End If
                    ' Copy the rest of the array to tokenized$
                    For y = BracketStart To Start - 1
                        Tokenized$ = Tokenized$ + Mid$(Expression$, y, 1)
                    Next y
                    I = Start ' Update i's position
                    GoTo GetNextToken1
                Else
                    ' Not an array break out of the FOR Next loop
                    GoTo CopyOtherBytes
                End If
            End If
        End If
    Next ii
    CopyOtherBytes:
    If i$ = "&" And I < Len(Expression$) Then
        ' Might be hex value "&H"
        Tokenized$ = Tokenized$ + i$ ' output the "&"
        i$ = Mid$(Expression$, I, 1): I = I + 1
        If i$ = "H" Then
            ' We found "&H"
            Tokenized$ = Tokenized$ + i$ ' copy the H to the output
            ' Get the first hex value
            While I <= Len(Expression$)
                i$ = UCase$(Mid$(Expression$, I, 1)): I = I + 1
                If (Asc(i$) >= Asc("A") And Asc(i$) <= Asc("F")) Or (Asc(i$) >= Asc("0") And Asc(i$) <= Asc("9")) Then
                    Tokenized$ = Tokenized$ + i$
                Else
                    I = I - 1
                    Exit While
                End If
            Wend
            GoTo GetNextToken1
        End If
    End If
    Tokenized$ = Tokenized$ + i$
Wend
If Verbose > 1 Then
    Print "2nd:"
    For I = 1 To Len(Tokenized$)
        a = Asc(Mid$(Tokenized$, I, 1))
        If a < 16 Then Print "0";
        Print Hex$(Asc(Mid$(Tokenized$, I, 1)));
    Next I
    Print
End If

' Tokenize Special Characters
Expression$ = Tokenized$
Tokenized$ = ""
I = 1
GetNextToken2:
While I <= Len(Expression$)
    V = Asc(Mid$(Expression$, I, 1)): I = I + 1
    If V < &HF0 Then
        If V = &H23 Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(V): GoTo GetNextToken2 ' Found #
        If V = &H28 Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(V): GoTo GetNextToken2 ' Found open bracket
        If V = &H29 Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(V): GoTo GetNextToken2 ' Found close bracket
        If V = &H2C Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(V): GoTo GetNextToken2 ' Found comma
        If V = &H3B Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(V): GoTo GetNextToken2 ' Found semi colon
        Tokenized$ = Tokenized$ + Chr$(V)
        GoTo GetNextToken2 ' copy other values
    End If
    'We have a Token
    Tokenized$ = Tokenized$ + Chr$(V) 'copy the token
    Select Case V
        Case &HF0, &HF1: ' Found a Numeric or String array
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy MSB of Array ID
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy LSB of Array ID
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy # of dimensions
        Case &HF2, &HF3, &HF4: ' Found a numeric or string or floating point variable
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy MSB of variable ID
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy LSB of variable ID
        Case &HF5 ' Found a special character
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy Special character
            'We have a special character tokenized already
            If V = &H22 Then
                ' Found a quote, so copy all until we get the end tokenized quote
                i$ = Mid$(Expression$, I, 1) ' Get a byte
                While i$ <> Chr$(&H22) ' keep skipping until we find the end quote
                    Tokenized$ = Tokenized$ + i$ ' Copy the byte
                    I = I + 1: i$ = Mid$(Expression$, I, 1) ' Get a byte
                Wend
            End If
        Case &HFB: ' Found a DEF FN Function
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy MSB of FN ID
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy LSB of FN ID
        Case &HFC: ' Found an Operator
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy Operator
        Case &HFD, &HFE: 'Found String,Numeric command
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy MSB of command ID
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy LSB of command ID
        Case &HFF: 'Found General command
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy MSB of command ID
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy LSB of command ID
            ' Check for a DATA command
            V = Asc(Mid$(Expression$, I - 2, 1)) * 256 + Asc(Mid$(Expression$, I - 1, 1))
            If V = C_DATA Then
                'We found a line with the DATA command, copy it all as it is, don't add extra control characters
                While I <= Len(Expression$)
                    i$ = Mid$(Expression$, I, 1): I = I + 1
                    Tokenized$ = Tokenized$ + i$
                    If i$ = Chr$(&HF5) Then
                        i$ = Mid$(Expression$, I, 1): I = I + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&H3A) Then Exit While
                    End If
                Wend
                GoTo GetNextToken2
            End If
            If V = C_REM Or V = C_REMApostrophe Then
                'We found a line with the REM command, copy it all as it is, don't add extra control characters
                While I <= Len(Expression$)
                    i$ = Mid$(Expression$, I, 1): I = I + 1
                    Tokenized$ = Tokenized$ + i$
                    If i$ = Chr$(&HF5) Then
                        i$ = Mid$(Expression$, I, 1): I = I + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&H3A) Then Exit While
                    End If
                Wend
                GoTo GetNextToken2
            End If
    End Select
    GoTo GetNextToken2
Wend
' Tokens for variables type:
' &HF0 = Numeric Arrays
' &HF1 = String Arrays
' &HF2 = Regular Numeric Variable
' &HF3 = Regular String Variable
' &HF4 = Floating Point Variable
' &HF5 = Special characters like a EOL, colon, comma, semi colon, quote, brackets

' &HFC = Operator Command
' &HFD = String Command
' &HFE = Numeric Command
' &HFF = General Command

' Find Numeric & String Variables
Expression$ = Tokenized$
Tokenized$ = ""
I = 1
GetNextToken3:
While I <= Len(Expression$)
    i$ = Mid$(Expression$, I, 1)
    If Asc(i$) > &HEF Then ' Test if we hit a token
        If i$ = Chr$(&HF5) Then
            Tokenized$ = Tokenized$ + i$ ' copy the &HF5
            'We have a special character tokenized already
            I = I + 1: i$ = Mid$(Expression$, I, 1) ' Get the Special character
            Tokenized$ = Tokenized$ + i$ ' Copy it
            If i$ = Chr$(&H22) Then
                ' Found a quote, so copy all until we get the end tokenized quote
                I = I + 1: i$ = Mid$(Expression$, I, 1) ' Get a byte
                While Mid$(Expression$, I, 1) <> Chr$(&H22) ' keep skipping until we find the end quote
                    Tokenized$ = Tokenized$ + i$ ' Copy the byte
                    I = I + 1: i$ = Mid$(Expression$, I, 1) ' Get a byte
                Wend
                GoTo GetNextToken3
            End If
            I = I + 1: i$ = Mid$(Expression$, I, 1) ' Get a byte
            GoTo GetNextToken3
        End If
        ' This needs to account for 16 bit numbers now
        If Asc(i$) = &HF0 Or Asc(i$) = &HF1 Then
            ' Copy the token plus 3 more values (array , # of dimensions)
            Tokenized$ = Tokenized$ + i$ ' copy the token
            I = I + 1: i$ = Mid$(Expression$, I, 1) ' Get the array MSB
            Tokenized$ = Tokenized$ + i$ ' Copy
            I = I + 1: i$ = Mid$(Expression$, I, 1) ' Get the array LSB
            Tokenized$ = Tokenized$ + i$ ' Copy
            I = I + 1: i$ = Mid$(Expression$, I, 1) ' Get the # of dimensions in the array
            Tokenized$ = Tokenized$ + i$ ' Copy
            I = I + 1
            GoTo GetNextToken3
        Else
            ' Check for a REM or '
            Check$ = "REM": GoSub FindGenCommandInExpression 'Checks if position i in Expression$ has the command Check$, return Found=1 is found else Found=0
            If Found = 1 Then
                While I <= Len(Expression$)
                    i$ = Mid$(Expression$, I, 1)
                    Tokenized$ = Tokenized$ + i$
                    I = I + 1
                Wend
                GoTo GetNextToken3
            End If
            ' Check for a an apostrophe '
            Check$ = "'": GoSub FindGenCommandInExpression 'Checks if position i in Expression$ has the command Check$, return Found=1 is found else Found=0
            If Found = 1 Then
                While I <= Len(Expression$)
                    i$ = Mid$(Expression$, I, 1)
                    Tokenized$ = Tokenized$ + i$
                    I = I + 1
                Wend
                GoTo GetNextToken3
            End If
            ' Check for a DATA
            Check$ = "DATA": GoSub FindGenCommandInExpression 'Checks if position i in Expression$ has the command Check$, return Found=1 is found else Found=0
            If Found = 1 Then
                'We found a DATA command - copy the rest of this line
                While I <= Len(Expression$)
                    i$ = Mid$(Expression$, I, 1): I = I + 1
                    Tokenized$ = Tokenized$ + i$
                    If i$ = Chr$(&HF5) Then
                        i$ = Mid$(Expression$, I, 1): I = I + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&H3A) Then Exit While
                    End If
                Wend
                GoTo GetNextToken3
            End If
            If Asc(i$) = &HFC Then
                ' Hit an operator, copy only one value after
                Tokenized$ = Tokenized$ + i$ ' copy the token
                I = I + 1: i$ = Mid$(Expression$, I, 1) ' Get the operator
                Tokenized$ = Tokenized$ + i$ ' Copy
                I = I + 1
                GoTo GetNextToken3
            Else
                ' We hit a token, copy it
                Tokenized$ = Tokenized$ + i$ ' copy the token
                I = I + 1: i$ = Mid$(Expression$, I, 1) ' Get the array MSB
                Tokenized$ = Tokenized$ + i$ ' Copy
                I = I + 1: i$ = Mid$(Expression$, I, 1) ' Get the array LSB
                Tokenized$ = Tokenized$ + i$ ' Copy
                I = I + 1
                GoTo GetNextToken3
            End If
        End If
    Else
        If i$ = "&" And I < Len(Expression$) Then
            ' Might be hex value "&H"
            Tokenized$ = Tokenized$ + i$ ' output the "&"
            I = I + 1 ' move past the "&"
            i$ = Mid$(Expression$, I, 1)
            If i$ = "H" Then
                ' We found "&H"
                Tokenized$ = Tokenized$ + i$ ' copy the H to the output
                I = I + 1
                ' Get the first hex value
                i$ = UCase$(Mid$(Expression$, I, 1)): I = I + 1
                While I <= Len(Expression$)
                    If (Asc(i$) >= Asc("A") And Asc(i$) <= Asc("F")) Or (Asc(i$) >= Asc("0") And Asc(i$) <= Asc("9")) Then
                        Tokenized$ = Tokenized$ + i$
                        i$ = UCase$(Mid$(Expression$, I, 1)): I = I + 1
                    Else
                        Exit While
                    End If
                Wend
                I = I - 1
            End If
        Else
            ' Check for a variable
            If Asc(UCase$(i$)) >= Asc("A") And Asc(UCase$(i$)) <= Asc("Z") Then ' Is it a letter?
                ' It is part of a variable name, we don't know if it's numeric or string at the moment
                ' Get the variable name
                Start = I ' start points at the 2nd character of the variable
                While Start <= Len(Expression$)
                    If Mid$(Expression$, Start, 1) = " " Or Mid$(Expression$, Start, 1) = Chr$(&HF5) Or Mid$(Expression$, Start, 1) = Chr$(&HFC) _
                    Or Mid$(Expression$, Start, 1) = "$" or Mid$(Expression$, Start, 1) = "=" Then Exit While
                    Start = Start + 1
                Wend
                If Mid$(Expression$, Start, 1) = "$" Then Start = Start + 1
                Temp$ = Mid$(Expression$, I, Start - I)
                If Right$(Temp$, 1) = "$" Then
                    'We found a string variable to tokenize
                    GoSub AddStringVariable ' Add variable Temp$ to the String variable List
                    If Found = 1 Then
                        Num = ii: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                        Tokenized$ = Tokenized$ + Chr$(&HF3) + Chr$(MSB) + Chr$(LSB)
                    Else
                        Num = StringVariableCounter - 1: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                        Tokenized$ = Tokenized$ + Chr$(&HF3) + Chr$(MSB) + Chr$(LSB)
                    End If
                    I = I + Len(Temp$) ' move pointer forward
                    GoTo GetNextToken3
                Else
                    'Test if Temp$ is a label instead of a variable name, write it as is if it is a LABEL
                    LabelCheck$ = Temp$
                    FoundL = 0
                    For ii1 = 1 To LineCount
                        If LabelCheck$ = LabelName$(ii1) Then FoundL = 1
                    Next ii1
                    If FoundL = 0 Then
                        ' We have a numeric variable to tokenize
                        Test$ = UCase$(Temp$) ' Make it all capital letters
                        If Test$ = "TIMER" Then Temp$ = "Timer" ' make sure the Timer variable is always the same
                        If Len(Temp$) > 3 Then
                            If Left$(Temp$, 3) = "FP_" Then
                                ' We found a floating point variable
                                GoSub AddFloatingPointVariable ' Add Floating Point variable Temp$ to the Floating Point variable List
                                If Found = 1 Then
                                    Num = ii: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                                    Tokenized$ = Tokenized$ + Chr$(&HF4) + Chr$(MSB) + Chr$(LSB)
                                Else
                                    Num = FloatVariableCount - 1: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                                    Tokenized$ = Tokenized$ + Chr$(&HF4) + Chr$(MSB) + Chr$(LSB)
                                End If
                            Else
                                GoSub AddNumericVariable ' Add variable Temp$ to the Numeric variable List
                                If Found = 1 Then
                                    Num = ii: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                                    Tokenized$ = Tokenized$ + Chr$(&HF2) + Chr$(MSB) + Chr$(LSB)
                                Else
                                    Num = NumericVariableCount - 1: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                                    Tokenized$ = Tokenized$ + Chr$(&HF2) + Chr$(MSB) + Chr$(LSB)
                                End If
                            End If
                        Else
                            GoSub AddNumericVariable ' Add variable Temp$ to the Numeric variable List
                            If Found = 1 Then
                                Num = ii: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                                Tokenized$ = Tokenized$ + Chr$(&HF2) + Chr$(MSB) + Chr$(LSB)
                            Else
                                Num = NumericVariableCount - 1: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                                Tokenized$ = Tokenized$ + Chr$(&HF2) + Chr$(MSB) + Chr$(LSB)
                            End If
                        End If
                    Else
                        ' We found a label, write it out as is
                        For ii1 = 1 To Len(LabelCheck$)
                            Tokenized$ = Tokenized$ + Mid$(LabelCheck$, ii1, 1)
                        Next ii1
                    End If
                    I = I + Len(Temp$) ' move pointer forward
                    GoTo GetNextToken3
                End If
            End If
        End If
    End If
    Tokenized$ = Tokenized$ + i$
    I = I + 1
Wend
' Remove all spaces that aren't in a quote or DATA statement
Expression$ = Tokenized$
Tokenized$ = ""
I = 1

LoopFindSpaces:
While I <= Len(Expression$)
    V = Asc(Mid$(Expression$, I, 1)): I = I + 1
    If V < &HF0 Then
        If V <> &H20 Then Tokenized$ = Tokenized$ + Chr$(V) ' If not a space then copy it
        GoTo LoopFindSpaces
    End If
    'We have a Token
    Tokenized$ = Tokenized$ + Chr$(V) 'copy the token
    Select Case V
        Case &HF0, &HF1: ' Found a Numeric or String array
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy MSB of Array ID
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy LSB of Array ID
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy # of dimensions
        Case &HF2, &HF3, &HF4: ' Found a numeric or string or floating point variable
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy MSB of variable ID
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy LSB of variable ID
        Case &HF5 ' Found a special character
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy Special character
            'We have a special character tokenized already
            If V = &H22 Then
                ' Found a quote, so copy all until we get the end tokenized quote
                i$ = Mid$(Expression$, I, 1) ' Get a byte
                While i$ <> Chr$(&H22) ' keep skipping until we find the end quote
                    Tokenized$ = Tokenized$ + i$ ' Copy the byte
                    I = I + 1: i$ = Mid$(Expression$, I, 1) ' Get a byte
                Wend
            End If
        Case &HFB: ' Found a DEF FN Function
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy MSB of FN ID
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy LSB of FN ID
        Case &HFC: ' Found an Operator
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy Operator
        Case &HFD, &HFE: 'Found String,Numeric command
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy MSB of command ID
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy LSB of command ID
        Case &HFF: 'Found General command
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy MSB of command ID
            V = Asc(Mid$(Expression$, I, 1)): Tokenized$ = Tokenized$ + Chr$(V): I = I + 1 ' Copy LSB of command ID
            V = Asc(Mid$(Expression$, I - 2, 1)) * 256 + Asc(Mid$(Expression$, I - 1, 1))
            ' Check for a REM or '
            If V = C_REM Or V = C_REMApostrophe Then
                'We found a line with the REM command, copy it all as it is, don't add extra control characters
                While I <= Len(Expression$)
                    i$ = Mid$(Expression$, I, 1): I = I + 1
                    Tokenized$ = Tokenized$ + i$
                    If i$ = Chr$(&HF5) Then
                        i$ = Mid$(Expression$, I, 1): I = I + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&H3A) Then Exit While
                    End If
                Wend
                GoTo LoopFindSpaces
            End If
            ' Check for a DATA command
            If V = C_DATA Then
                'We found a line with the DATA command
                MoreDataToCheck:
                If I > Len(Expression$) Then GoTo LoopFindSpaces ' we have reached the end of the expression
                V = Asc(Mid$(Expression$, I, 1)): I = I + 1 'Ge the first byte after the command DATA or after a comma
                If V = Asc(" ") Then
                    If I <= Len(Expression$) Then
                        GoTo MoreDataToCheck ' skip extra spaces after a comma or after the command DATA
                    Else
                        GoTo LoopFindSpaces ' we have reached the end of the expression
                    End If
                End If
                If V = &H2C Then
                    'Found a comma, leave it as it is
                    Tokenized$ = Tokenized$ + Chr$(V) ' copy the comma
                    GoTo MoreDataToCheck ' check next value
                End If
                If (V >= Asc("0") And V <= Asc("9")) Then
                    'We have a number to copy, so we can erase any spaces we find until a comma or end of Expression$
                    Do Until V = &H2C Or I > Len(Expression$)
                        If V = &HF5 Then
                            If Asc(Mid$(Expression$, I, 1)) = &H3A Then
                                Exit Do
                            End If
                        End If
                        If V <> Asc(" ") Then Tokenized$ = Tokenized$ + Chr$(V)
                        V = Asc(Mid$(Expression$, I, 1)): I = I + 1
                    Loop
                    Tokenized$ = Tokenized$ + Chr$(V)
                    If V = &HF5 Then
                        ' We found a colon on this line
                        V = Asc(Mid$(Expression$, I, 1)): I = I + 1
                        Tokenized$ = Tokenized$ + Chr$(V) ' Copy the colon
                        GoTo LoopFindSpaces ' look for more commands after the colon
                    End If
                    If I > Len(Expression$) Then GoTo LoopFindSpaces ' we are at the end
                    GoTo MoreDataToCheck ' Handle more data
                End If
                If V = Asc("&") And Mid$(Expression$, I, 1) = "H" Then
                    'it's a hex number get it all and convert it to a number
                    Temp$ = ""
                    I = I + 1 ' skip past the "H"
                    V = Asc(Mid$(Expression$, I, 1)): I = I + 1
                    Do Until V = &H2C Or I > Len(Expression$)
                        If V = &HF5 Then
                            If Asc(Mid$(Expression$, I, 1)) = &H3A Then
                                Exit Do
                            End If
                        End If
                        Temp$ = Temp$ + Chr$(V)
                        V = Asc(Mid$(Expression$, I, 1)): I = I + 1
                    Loop
                    If V = &HF5 Then
                        ' We found a colon on this line
                        V = Asc(Mid$(Expression$, I, 1)): I = I + 1
                        Tokenized$ = Tokenized$ + Chr$(V) ' Copy the colon
                        GoTo LoopFindSpaces ' look for more commands after the colon
                    End If
                    If V = &H2C Then
                        ' Not the end of the Expression yet
                        Signed16bit = Val("&H" + Temp$)
                        Temp$ = Str$(Signed16bit)
                        Tokenized$ = Tokenized$ + Temp$ + Chr$(V) ' add the converted number and the comma
                        GoTo MoreDataToCheck ' Handle more data
                    Else
                        Temp$ = Temp$ + Chr$(V)
                        Signed16bit = Val("&H" + Temp$)
                        Temp$ = Str$(Signed16bit)
                        If Left$(Temp$, 1) = " " Then Temp$ = Right$(Temp$, Len(Temp$) - 1)
                        ' at the end of the Expression$
                        Tokenized$ = Tokenized$ + Temp$ ' add the converted number
                        GoTo LoopFindSpaces ' We've reached the end of the line
                    End If
                End If
                'Otherwise it's a string copy spaces in the string
                DataString:
                If V = &HF5 And Asc(Mid$(Expression$, I, 1)) = &H22 Then
                    ' Found a quote
                    Tokenized$ = Tokenized$ + Chr$(V) ' Copy &HF5
                    V = Asc(Mid$(Expression$, I, 1)): I = I + 1 ' Get the quote
                    ' inside quoted text ignore commas
                    Do Until (V = &HF5 And Asc(Mid$(Expression$, I, 1)) = &H22) Or I > Len(Expression$) ' copy until we get a close quote or End of line
                        If V = &HF5 Then
                            If Asc(Mid$(Expression$, I, 1)) = &H3A Then
                                Exit Do
                            End If
                        End If
                        Tokenized$ = Tokenized$ + Chr$(V)
                        V = Asc(Mid$(Expression$, I, 1)): I = I + 1
                    Loop
                    Tokenized$ = Tokenized$ + Chr$(V)
                    If V = &HF5 And Asc(Mid$(Expression$, I, 1)) = &H22 Then
                        ' We found an end quote
                        V = Asc(Mid$(Expression$, I, 1)): I = I + 1
                        Tokenized$ = Tokenized$ + Chr$(V)
                        GoTo MoreDataToCheck ' Handle more data
                    End If
                    If V = &HF5 And Asc(Mid$(Expression$, I, 1)) = &H3A Then
                        ' We found a colon on this line
                        V = Asc(Mid$(Expression$, I, 1)): I = I + 1
                        Tokenized$ = Tokenized$ + Chr$(V) ' Copy the colon
                        GoTo LoopFindSpaces ' look for more commands after the colon
                    End If
                    GoTo LoopFindSpaces ' look for more commands
                Else
                    ' Not a quote, copy as is until we get a comma, Colon or EOL
                    Do Until V = &H2C Or I > Len(Expression$)
                        If V = &HF5 Then
                            If Asc(Mid$(Expression$, I, 1)) = &H3A Then
                                Exit Do
                            End If
                        End If
                        Tokenized$ = Tokenized$ + Chr$(V)
                        V = Asc(Mid$(Expression$, I, 1)): I = I + 1
                    Loop
                    ' Make sure right most byte is not a space
                    If I > Len(Expression$) Then
                        'Got to EOL
                        Tokenized$ = Tokenized$ + Chr$(V)
                        Tokenized$ = Left$(Tokenized$, Len(Tokenized$) - 1)
                        While Right$(Tokenized$, 1) = " ": Tokenized$ = Left$(Tokenized$, Len(Tokenized$) - 1): Wend ' make sure there isn't a space before the end
                        If Chr$(V) <> " " Then Tokenized$ = Tokenized$ + Chr$(V) ' Add last byte if it's not a space
                        GoTo MoreDataToCheck ' Handle more data
                    Else
                        While Right$(Tokenized$, 1) = " ": Tokenized$ = Left$(Tokenized$, Len(Tokenized$) - 1): Wend ' make sure there isn't a space before the end
                        Tokenized$ = Tokenized$ + Chr$(V) ' Write the &HF5 or comma
                        If V = &HF5 Then
                            ' We found a colon on this line
                            V = Asc(Mid$(Expression$, I, 1)): I = I + 1
                            Tokenized$ = Tokenized$ + Chr$(V) ' Copy the colon
                            GoTo LoopFindSpaces ' look for more commands after the colon
                        End If
                        ' Found a comma
                        GoTo MoreDataToCheck ' Handle more data
                    End If
                End If
            End If
    End Select
Wend
' Get the DEF FN variable's used (If any)
' Find the DEF Token
Check$ = "DEF": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
If Found = 1 Then
    Num = ii
    GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
    I = 1
    While I <= Len(Tokenized$)
        V = Asc(Mid$(Tokenized$, I, 1))
        If V = &HFF Then
            If Asc(Mid$(Tokenized$, I + 1, 1)) = MSB And Asc(Mid$(Tokenized$, I + 2, 1)) = LSB Then
                ' Found a DEF FN, let's get the Variable type and number
                DefVar(DefVarCount) = Asc(Mid$(Tokenized$, I + 9, 1)) * 256 + Asc(Mid$(Tokenized$, I + 10, 1))
                DefVarCount = DefVarCount + 1
            End If
        End If
        I = I + 1
    Wend
End If
DoneGettingExpression:
If Verbose > 1 Then
    Print "3rd:"
    For I = 1 To Len(Tokenized$)
        a = Asc(Mid$(Tokenized$, I, 1))
        If a < 16 Then Print "0";
        Print Hex$(Asc(Mid$(Tokenized$, I, 1)));
    Next I
    Print
End If
Return
' Get General Expression
' Returns with single expression in GenExpression$
GetGenExpression:
V = Array(x): x = x + 1
GenExpression$ = Chr$(V)
If V < &HF0 Then Return ' Copy single byte, as is
'We have a Token
Select Case V
    Case &HF0, &HF1: ' Found a Numeric or String array
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of Array ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of Array ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy # of dimensions
    Case &HF2, &HF3, &HF4: ' Found a numeric or string or floating point variable
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of variable ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of variable ID
    Case &HF5 ' Found a special character
        V = Array(x): x = x + 1
        GenExpression$ = GenExpression$ + Chr$(V) ' Copy special character
    Case &HFB: ' Found a DEF FN Function
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of FN ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of FN ID
    Case &HFC: ' Found an Operator
        V = Array(x): x = x + 1
        GenExpression$ = GenExpression$ + Chr$(V) ' Operator character
    Case &HFD, &HFE, &HFF: 'Found String,Numeric or General command
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of command ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of command ID
End Select
Return
' Found a numeric variable, add it to the list
AddNumericVariable:
Found = 0
For ii = 0 To NumericVariableCount
    If NumericVariable$(ii) = Temp$ Then
        Found = 1
        Return
    End If
Next ii
NumericVariable$(NumericVariableCount) = Temp$
NumericVariableCount = NumericVariableCount + 1
Return

' Found a Floating Point variable, add it to the list
AddFloatingPointVariable:
Found = 0
For ii = 0 To FloatVariableCount
    If FloatVariable$(ii) = Temp$ Then
        Found = 1
        Return
    End If
Next ii
FloatVariable$(FloatVariableCount) = Temp$
FloatVariableCount = FloatVariableCount + 1
Return

' Found a string variable, add it to the list
AddStringVariable:
Found = 0
For ii = 0 To StringVariableCounter
    If StringVariable$(ii) = Left$(Temp$, Len(Temp$) - 1) Then
        Found = 1
        Return
    End If
Next ii
StringVariable$(StringVariableCounter) = Left$(Temp$, Len(Temp$) - 1)
StringVariableCounter = StringVariableCounter + 1
Return
' Add variable Temp$ to the Numeric array variable List and the number of dimensions the Numeric array has
AddToNumArrayVariableList:
Found = 0
For ii = 0 To NumArrayVarsUsedCounter
    If NumericArrayVariables$(ii) = Temp$ Then
        Found = 1
        Return
    End If
Next ii
NumericArrayVariables$(NumArrayVarsUsedCounter) = Temp$
NumericArrayDimensions(NumArrayVarsUsedCounter) = Dimensions
' Default each array element to 11 (0 to 10)
NumericArrayDimensionsVal$(NumArrayVarsUsedCounter) = ""
For D1 = 1 To Dimensions: NumericArrayDimensionsVal$(NumArrayVarsUsedCounter) = NumericArrayDimensionsVal$(NumArrayVarsUsedCounter) + "000B": Next D1
NumArrayVarsUsedCounter = NumArrayVarsUsedCounter + 1
Return

' Add variable Temp$ to the String array variable List and the number of dimensions the String array has
AddToStringArrayVariableList:
Found = 0
For ii = 0 To StringArrayVarsUsedCounter
    If StringArrayVariables$(ii) = Temp$ Then
        Found = 1
        Return
    End If
Next ii
StringArrayVariables$(StringArrayVarsUsedCounter) = Temp$
StringArrayDimensions(StringArrayVarsUsedCounter) = Dimensions
' Default each array element to 11 (0 to 10)
StringArrayDimensionsVal$(StringArrayVarsUsedCounter) = ""
For D1 = 1 To Dimensions: StringArrayDimensionsVal$(StringArrayVarsUsedCounter) = StringArrayDimensionsVal$(StringArrayVarsUsedCounter) + "0002": Next D1
StringArrayVarsUsedCounter = StringArrayVarsUsedCounter + 1
Return

' Add General Command Temp$ to the general command list
AddToGeneralCommandList:
Found = 0
For ii = 0 To GeneralCommandsFoundCount
    If GeneralCommandsFound$(ii) = Temp$ Then
        Found = 1
        Return
    End If
Next ii
GeneralCommandsFound$(GeneralCommandsFoundCount) = Temp$
GeneralCommandsFoundCount = GeneralCommandsFoundCount + 1
Return
' Add String Command Temp$ to the string command list
AddToStringCommandList:
Found = 0
For ii = 0 To StringCommandsFoundCount
    If StringCommandsFound$(ii) = Temp$ Then
        Found = 1
        Return
    End If
Next ii
StringCommandsFound$(StringCommandsFoundCount) = Temp$
StringCommandsFoundCount = StringCommandsFoundCount + 1
Return
' Add Numeric Command Temp$ to the Numeric command list
AddToNumericCommandList:
Found = 0
For ii = 0 To NumericCommandsFoundCount
    If NumericCommandsFound$(ii) = Temp$ Then
        Found = 1
        Return
    End If
Next ii
NumericCommandsFound$(NumericCommandsFoundCount) = Temp$
NumericCommandsFoundCount = NumericCommandsFoundCount + 1
Return


' To calculate the maximum RAM required for an array:
' Default arrays are 0 to 10 = 11 elements
' 4 dimension, Numeric array would be calculated with
' Ram required = (11 * 11 * 11 * 11) * 2
' A 2 dimension, String array would be calculated with
' Ram required = (11 * 11) * 256
DoDim:
V = Array(x): x = x + 1
' Get the tokenized array
' F0 = Numeric Arrays
' F1 = String Arrays
If V = &HF0 Then
    'Set the size of a numeric array
    ii = Array(x) * 256 + Array(x + 1): x = x + 2 ' Get the array identifier value
    NumericArrayBits(ii) = 8 ' Set the default # of bits needed for the array as 8 bits
    NumericArrayDimensionsVal$(ii) = "" ' clear the # of Element values per dimension
    NumOfDims = Array(x): x = x + 1 ' Get the number of dimensions for the arrays
    ' Get the number of elements per dimension
    ' These values will be before a comma
    V = Array(x): x = x + 2 ' consume the $F5 & open bracket
    For T1 = 1 To NumOfDims
        Temp$ = ""
        V = Array(x): x = x + 1 ' get the first value
        While V <> &HF5 ' comma will be &HF5 &H2C and close bracket will be &HF5 &H29
            Temp$ = Temp$ + Chr$(V)
            V = Array(x): x = x + 1 ' Get the next digit of the number
        Wend
        V = Array(x): x = x + 1 ' consume the comma or close bracket
        DimVal$ = Hex$(Val(Temp$)) ' Make the value a hex string
        DimVal$ = Right$("0000" + DimVal$, 4) ' Make sure the value is four digits
        If Val("&H" + DimVal$) > 254 Then NumericArrayBits(ii) = 16 ' If any of the Element sizes are more that 254 flag as 16 bit array
        NumericArrayDimensionsVal$(ii) = NumericArrayDimensionsVal$(ii) + DimVal$
    Next T1
Else
    If V = &HF1 Then
        'Set the size of a string array
        ii = Array(x) * 256 + Array(x + 1): x = x + 2 ' Get the array identifier value
        StringArrayBits(ii) = 8 ' Set the default # of bits needed for the array as 8 bits
        StringArrayDimensionsVal$(ii) = "" ' clear the # of Element values per dimension
        NumOfDims = Array(x): x = x + 1 ' Get the number of dimensions for the arrays
        ' Get the number of elements per dimension
        ' These values will be before a comma
        V = Array(x): x = x + 2 ' consume the $F5 & open bracket
        For T1 = 1 To NumOfDims
            Temp$ = ""
            V = Array(x): x = x + 1 ' get the first value
            While V <> &HF5 ' comma will be &HF5 &H2C and close bracket will be &HF5 &H29
                Temp$ = Temp$ + Chr$(V)
                V = Array(x): x = x + 1 ' Get the next digit of the number
            Wend
            V = Array(x): x = x + 1 ' consume the comma or close bracket
            DimVal$ = Hex$(Val(Temp$)) ' Make the value a hex string
            DimVal$ = Right$("0000" + DimVal$, 4) ' Make sure the value is four digits
            If Val("&H" + DimVal$) > 254 Then StringArrayBits(ii) = 16 ' If any of the Element sizes are more that 254 flag as 16 bit array
            StringArrayDimensionsVal$(ii) = StringArrayDimensionsVal$(ii) + DimVal$
        Next T1
    End If
End If
If V = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) Then V = Array(x): x = x + 1: Return ' We are done with the DIM command
If V = &HFF Then
    V = Array(x) * 256 + Array(x + 1)
    If V = C_REM Or V = C_REMApostrophe Then
        ' we have a REMark
        GoTo ConsumeCommentsAndEOL ' Consume any comments and the EOL and Return
    End If
End If
GoTo DoDim ' Set the next array values

ConsumeCommentsAndEOL:
If V = &H0D Or V = &H3A Then Return
Do Until V = &HF5 And Array(x) = &H0D 'consume any comments and the EOL
    V = Array(x): x = x + 1
Loop
V = Array(x): x = x + 1
Return

' Send assembly instructions out to .asm file
AO:
'Print z$ at the beginning of the line
If Len(Z$) < 8 Then
    Print #1, Left$(Z$ + "        ", 8); Left$(A$ + "        ", 8);
Else
    Print #1, Z$; T2$; Left$(A$ + "        ", 8);
End If
If Len(B$) > 13 Then Print #1, B$; "   "; Else Print #1, Left$(B$ + "              ", 14);
If C$ <> "" Then Print #1, "; "; C$ Else Print #1,
Z$ = "": A$ = "": B$ = "": C$ = "" 'Clear the strings so next entry won't be repeated
Return

AddIncludeTemp:
Found = 0
For AI = 1 To IncludeCount
    If IncludeList$(AI) = Temp$ Then Found = 1: Exit For
Next AI
If Found = 0 Then
    'Add the new include to the list
    IncludeCount = IncludeCount + 1
    IncludeList$(IncludeCount) = Temp$
End If
Return
WriteIncludeListToFile:
For AI = 1 To IncludeCount
    Print #1, T2$; "INCLUDE     ./Basic_Includes/"; IncludeList$(AI); ".asm"
Next AI
Return

'Convert number in Num to a string without spaces as Num$
NumAsString:
If Num = 0 Then
    Num$ = "0"
Else
    If Num > 0 Then
        'Postive value remove the first space in the string
        Num$ = Right$(Str$(Num), Len(Str$(Num)) - 1)
    Else
        'Negative value we keep the minus sign
        Num$ = Str$(Num)
    End If
End If
Return

FoundError:
Print " line "; linelabel$: System

' For testing show the length and bytes in the string Show$, IF input=1 then system
show:
Print "Working on line "; linelabel$
Print "Length of "; show$; " is"; Len(show$)
For ii = 1 To Len(show$)
    Print ii, Hex$(Asc(Mid$(show$, ii, 1))), Chr$(Asc(Mid$(show$, ii, 1)))
Next ii
Input q
If q = 1 Then System
Return

' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
NumToMSBLSBString:
MSB = Int(Num / 256)
LSB = Num - MSB * 256
MSB$ = Str$(MSB)
LSB$ = Str$(LSB)
Return

' Gets the General Command number, returns with number in ii, Found=1 if found and Found=0 if not found
FindGenCommandNumber:
Found = 0
For ii = 0 To GeneralCommandsCount
    If GeneralCommands$(ii) = Check$ Then
        Found = 1
        Exit For
    End If
Next ii
Return

'Checks if position i in Expression$ has the command Check$, return Found=1 is found else Found=0
FindGenCommandInExpression:
Found = 0
If Asc(Mid$(Expression$, I, 1)) = &HFF Then
    For ii = 0 To GeneralCommandsCount
        If GeneralCommands$(ii) = Check$ Then
            Exit For
        End If
    Next ii
    If Asc(Mid$(Expression$, I + 1, 1)) * 256 + Asc(Mid$(Expression$, I + 2, 1)) = ii Then
        Found = 1
    End If
End If
Return

' Convert numbers to Floating point format
'DECLARE FUNCTION FloatTo6809Format# (num AS DOUBLE)
Dim FPNum As Double
Dim lineFC As String
Dim label As String
Dim expo As Integer, sign As _Byte, mant As Long
Dim byte(5) As _Byte

label = ""
Print "* These are the floating point constants."
Print "* They are generated by the QB64 version of makeflot."
FPConversionLoop:
Do
    ' Read input from the user
    Line Input lineFC
    lineFC = RTrim$(lineFC)

    If Len(lineFC) = 0 Then
        ' Skip empty lines
        GoTo FPConversionLoop
    End If

    If Left$(lineFC, 1) = "*" Then
        ' Print comments as they are
        Print lineFC
        GoTo FPConversionLoop
    End If

    ' Check if it's a label or a number
    If (Asc(Left$(lineFC, 1)) >= 65 And Asc(Left$(lineFC, 1)) <= 90) Or (Asc(Left$(lineFC, 1)) >= 97 And Asc(Left$(lineFC, 1)) <= 122) Then
        ' It's a label
        label = lineFC
    Else
        ' It's a number, convert it
        FPNum = Val(lineFC)
        If FPNum = 0 Then
            sign = 0
            expo = 0
            mant = 0
        Else
            If FPNum < 0 Then sign = &H80 Else sign = 0
            FPNum = Abs(FPNum)
            expo = &H9F

            ' Normalize mantissa
            Do While FPNum < 2147483648#
                FPNum = FPNum * 2
                expo = expo - 1
            Loop
            Do While FPNum >= 4294967296#
                FPNum = FPNum / 2
                expo = expo + 1
            Loop

            mant = Int(FPNum + 0.5)
        End If

        ' Create the 5-byte floating point representation
        byte(0) = expo
        byte(1) = (Val("&H" + Left$(Hex$(mant), 2)) And &H7F) Or sign
        byte(2) = Val("&H" + Mid$(Hex$(mant), 3, 2))
        byte(3) = Val("&H" + Mid$(Hex$(mant), 5, 2))
        byte(4) = Val("&H" + Right$(Hex$(mant), 2))

        ' Print the floating-point constant in the same format
        Print label; Spc(16 - Len(label));
        Print "fcb $"; Hex$(byte(0)); ",$"; Hex$(byte(1)); ",$"; Hex$(byte(2)); ",$"; Hex$(byte(3)); ",$"; Hex$(byte(4)); " ;"; lineFC
        label = ""
    End If

Loop Until 1 > 1

Print "* End of floating point constants."
System

' LINE may or may not have ,B or BF at the end which might get turned into variable below
' Change the Tokenized$ command so it will have
' after ,PSET or ,PRESET we will have
' ,0,0 - No Box or Box Fill
' ,1,0 - Draw a Box
' ,1,1 - Draw a box and fill it
FixLineCommand:
Temp$ = ""
I = 1
Num = ii
GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
While InStr(I, Tokenized$, Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) > 0
    StartLine = I ' Start of the line
    ' Does this command end with a Colon?
    EndLine = InStr(I, Tokenized$, Chr$(&HF5) + Chr$(&H3A))
    If EndLine = 0 Then
        ' No other LINE commands after colons, this is the last
        EndLine = Len(Tokenized$)
        FoundColon$ = ""
    Else
        EndLine = EndLine - 1
        FoundColon$ = Chr$(&HF5)
    End If
    BFTemp$ = ",0,0"
    If Mid$(Tokenized$, EndLine - 2, 3) = ", B" Then BFTemp$ = ",1,0"
    If Mid$(Tokenized$, EndLine - 3, 4) = ", BF" Then BFTemp$ = ",1,1"
    If BFTemp$ = ",0,0" Then
        ' No B or BF at the end of this line
        Temp$ = Temp$ + Mid$(Tokenized$, StartLine, EndLine - StartLine + 1) + BFTemp$ + FoundColon$
    End If
    If BFTemp$ = ",1,0" Then
        ' B at the end of this line
        Temp$ = Temp$ + Mid$(Tokenized$, StartLine, EndLine - StartLine - 3) + BFTemp$ + FoundColon$
    End If
    If BFTemp$ = ",1,1" Then
        ' BF at the end of this line
        Temp$ = Temp$ + Mid$(Tokenized$, StartLine, EndLine - StartLine - 4) + BFTemp$ + FoundColon$
    End If
    I = EndLine + 2
Wend
If Temp$ <> "" Then
    ' We found a LINE command
    Tokenized$ = Temp$ + Right$(Tokenized$, Len(Tokenized$) - I + 1)
End If
Return


'Test if a string contains a number or a variable
Function IsNumber (s$)
    If Val(s$) <> 0 Or (Val(s$) = 0 And Left$(s$, 1) = "0") Then
        IsNumber = 1 ' It's a number
    Else
        IsNumber = 0 ' It's not a number, hence a variable
    End If
End Function

Function Replace (text$, old$, new$) 'can also be used as a SUB without the count assignment
    Do
        find = InStr(start + 1, text$, old$) 'find location of a word in text
        If find Then
            count = count + 1
            first$ = Left$(text$, find - 1) 'text before word including spaces
            last$ = Right$(text$, Len(text$) - (find + Len(old$) - 1)) 'text after word
            text$ = first$ + new$ + last$
        End If
        start = find
    Loop While find
    Replace = count 'function returns the number of replaced words. Comment out in SUB
End Function



