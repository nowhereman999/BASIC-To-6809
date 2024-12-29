$ScreenHide
$Console
_Dest _Console

' - Now REM's are removed from everyline after the line is sent to the .asm file as it is, so the compiler won't have to deal with them.

Dim Array(270000) As _Unsigned _Byte
Dim DataArray(270000) As _Unsigned _Byte
Dim DataArrayCount As Integer

Dim NumericVariable$(100000)
Dim NumericVariableCount As Integer

Dim FloatVariable$(100000)
Dim FloatVariableCount As Integer

Dim StringVariable$(100000)
Dim StringVariableCounter As Integer
Dim NumericArrayVariables$(100000), NumericArrayDimensions(100000) As Integer, NumericArrayDimensionsVal$(100000)
Dim StringArrayVariables$(100000), StringArrayDimensions(100000) As Integer, StringArrayDimensionsVal$(100000)

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

' No More
' PSET
' PCLS
' RESET
' PRESET

' Add
' GCLEAR
' GCOPY

Dim DefLabel$(10000)
Dim DefVar(1000) As Integer
DefLabelCount = 0
DefVarCount = 0

' Need to keep track of FOR LOOPs
Dim FORSTack(100)

' Stuff for IF/THEN/ELSE/ENDIF
Dim IFSTack(100) As Integer 'If Stack
Dim ElseStack(100) As Integer ' Else Stack
Dim ELSELocation(100) As Integer 'Flag if the IF has an ELSE

Dim D As Integer
Dim values(100) As Double ' Predefine a large enough array for values
Dim ops(100) As String ' Predefine a large enough array for operators

' Stuff for FP conversion
Dim FloatNum As Double
Dim expo As Integer, sign As _Byte, mant As Long
Dim FPbyte(5) As _Byte

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

' Handle command line options
FI = 0
count = _CommandCount
If count = 0 Then
    Print "Compiler has no options given to it"
    System
End If
nt = 0: newp = 0: endp = 0: BranchCheck = 0: StringArraySize = 255: KeepTempFiles = 0: AutoStart = 0
Optimize = 2 ' Default to optimize level 2
For check = 1 To count
    N$ = Command$(check)
    If LCase$(Left$(N$, 2)) = "-c" Then BASICMode = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-s" Then StringArraySize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-o" Then Optimize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-b" Then BranchCheck = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-v" Then Verbose = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-k" Then KeepTempFiles = 1: GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-a" Then AutoStart = 1: GoTo CheckNextCMDOption
    ' check if we got a file name yet if so then the next filename will be output
    OutName$ = N$
    CheckNextCMDOption:
Next check
FName$ = "BasicTokenized.bin"
Open FName$ For Append As #1
length = LOF(1)
Close #1
If length < 1 Then Print "Error file: "; FName$; " is 0 bytes. Or doesn't exist.": Kill FName$: System
If Verbose > 0 Then Print "Length of Input file in bytes:"; length
Open FName$ For Binary As #1
Get #1, , INArray()
Close #1
Filesize = length

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

' Fill the Array() with the Tokenized version of the BASIC program
FName$ = "BasicTokenized.bin"
Open FName$ For Append As #1
length = LOF(1)
Close #1
If length < 1 Then Print "Error file: "; FName$; " is 0 bytes. Or doesn't exist.": Kill FName$: End
If Verbose > 0 Then Print "Length of Input file in bytes:"; length
Open FName$ For Binary As #1
Get #1, , Array()
Close #1

Check$ = "REM": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
REM_CMD = ii
Check$ = "'": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
REM_Apostraphe_CMD = ii
Check$ = "STEP": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
STEP_CMD = ii
Check$ = "LET": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
LET_CMD = ii
Check$ = "TO": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
TO_CMD = ii
Check$ = "GOTO": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
GOTO_CMD = ii
Check$ = "GOSUB": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
GOSUB_CMD = ii
Check$ = "SELECT": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
SELECT_CMD = ii
Check$ = "ON": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
ON_CMD = ii
Check$ = "OFF": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
OFF_CMD = ii
Check$ = "PSET": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
PSET_CMD = ii
Check$ = "PRESET": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
PRESET_CMD = ii
Check$ = "DO": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
DO_CMD = ii
Check$ = "FOR": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FOR_CMD = ii
Check$ = "WHILE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
WHILE_CMD = ii
Check$ = "UNTIL": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
UNTIL_CMD = ii
Check$ = "CASE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CASE_CMD = ii
Check$ = "EVERYCASE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
EVERYCASE_CMD = ii
Check$ = "IS": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
IS_CMD = ii
Check$ = "TIMER": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
TIMER_CMD = ii
Check$ = "END": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
END_CMD = ii
Check$ = "IF": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
IF_CMD = ii
Check$ = "THEN": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
THEN_CMD = ii
Check$ = "ELSE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
ELSE_CMD = ii
Check$ = "TAB": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
TAB_CMD = ii
Check$ = "INT": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
INT_CMD = ii
Check$ = "FLOATADD": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATADD_CMD = ii
Check$ = "FLOATSUB": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATSUB_CMD = ii
Check$ = "FLOATMUL": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATMUL_CMD = ii
Check$ = "FLOATDIV": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATDIV_CMD = ii
Check$ = "FLOATSQR": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATSQR_CMD = ii
Check$ = "FLOATSIN": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATSIN_CMD = ii
Check$ = "FLOATCOS": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATCOS_CMD = ii
Check$ = "FLOATTAN": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATTAN_CMD = ii
Check$ = "FLOATATAN": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATATAN_CMD = ii
Check$ = "FLOATEXP": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATEXP_CMD = ii
Check$ = "FLOATLOG": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATLOG_CMD = ii
Check$ = "FLOATTOSTR": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
FLOATTOSTR_CMD = ii
Check$ = "CMPGT": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CMPGT_CMD = ii
Check$ = "CMPGE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CMPGE_CMD = ii
Check$ = "CMPEQ": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CMPEQ_CMD = ii
Check$ = "CMPNE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CMPNE_CMD = ii
Check$ = "CMPLE": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CMPLE_CMD = ii
Check$ = "CMPLT": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
CMPLT_CMD = ii
Check$ = "STRTOFLOAT": GoSub FindNumCommandNumber ' Gets the Numeric Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
STRTOFLOAT_CMD = ii


x = 0
INx = 0
lc = 0
LineCount = 0
StringVariableCounter = 0 ' String variable name count
CommandsUsedCounter = 0 ' Counter for unique commmands used
NumArrayVarsUsedCounter = 0 ' Counter for number of NumericArrays used
StringArrayVarsUsedCounter = 0 ' Counter for number of String Array Variables used
' Fill the arrays from files
NumericVariableCount = 0
Open "NumericVariablesUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, NumericVariable$(NumericVariableCount)
    NumericVariableCount = NumericVariableCount + 1
Wend
Close #1
Open "FloatingPointVariablesUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, FloatVariable$(FloatVariableCount)
    FloatVariableCount = FloatVariableCount + 1
Wend
Close #1
StringVariableCounter = 0
Open "StringVariablesUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, StringVariable$(StringVariableCounter)
    StringVariableCounter = StringVariableCounter + 1
Wend
Close #1
GeneralCommandsFoundCount = 0
Open "GeneralCommandsFound.txt" For Input As #1
While EOF(1) = 0
    Input #1, GeneralCommandsFound$(GeneralCommandsFoundCount)
    GeneralCommandsFoundCount = GeneralCommandsFoundCount + 1
Wend
Close #1
StringCommandsFoundCount = 0
Open "StringCommandsFound.txt" For Input As #1
While EOF(1) = 0
    Input #1, StringCommandsFound$(StringCommandsFoundCount)
    StringCommandsFoundCount = StringCommandsFoundCount + 1
Wend
Close #1
NumericCommandsFoundCount = 0
Open "NumericCommandsFound.txt" For Input As #1
While EOF(1) = 0
    Input #1, NumericCommandsFound$(NumericCommandsFoundCount)
    NumericCommandsFoundCount = NumericCommandsFoundCount + 1
Wend
Close #1
NumericArrayVarsUsedCounter = 0
Open "NumericArrayVarsUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, NumericArrayVariables$(NumericArrayVarsUsedCounter)
    Input #1, NumericArrayDimensions(NumericArrayVarsUsedCounter)
    NumericArrayVarsUsedCounter = NumericArrayVarsUsedCounter + 1
Wend
Close #1
StringArrayVarsUsedCounter = 0
Open "StringArrayVarsUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, StringArrayVariables$(StringArrayVarsUsedCounter)
    Input #1, StringArrayDimensions(StringArrayVarsUsedCounter)
    StringArrayVarsUsedCounter = StringArrayVarsUsedCounter + 1
Wend
Close #1
DefLabelCount = 0
Open "DefFNUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, DefLabel$(DefLabelCount)
    DefLabelCount = DefLabelCount + 1
Wend
Close #1
DefVarCount = 0
Open "DefVarUsed.txt" For Input As #1
While EOF(1) = 0
    Input #1, DefVar(DefVarCount)
    DefVarCount = DefVarCount + 1
Wend
Close #1
' Start writing to the .asm file
Open OutName$ For Append As #1

' Main process loop

' Found a general command, add it to the list and tokenize it
' Tokens for variables types and Commands
' F0 = Numeric Array Variable
' F1 = String Array Variable
' F2 = Regular Numeric Variable
' F3 = Regular String Variable
' F5 = + EOL($0D) or + Colon($3A)
' FC = Operator Command
' FD = String Command
' FE = Numeric Command
' FF = General Command
x = 0
vOld = 0
DoAnotherLine:
If Array(x) = &HF5 Then
    x = x + 2 ' Skip past Colon or EOL
End If
If vOld <> Asc(":") Then
    ' We are still on the same line, don't check for a label or line number
    v = Array(x): x = x + 1
Else
    v = 0
End If
While x < Filesize
    ' Do if we didn't just process a colon otherwise we're still on the same line so don't look for a label or line number
    ' Every Tokenized BASIC line starts with a byte that is the length of the Line number/Label
    ' If it's zero there is no line number or label on this line
    OldLineLabel$ = linelabel$
    linelabel$ = ""
    If v = 0 Then
        linelabel$ = OldLineLabel$ + "b"
        GoTo SkipLabel ' Skip getting a line number or label from lines that don't have them
    End If
    For l = 1 To v
        v = Array(x): x = x + 1
        linelabel$ = linelabel$ + Chr$(v)
    Next l
    If Verbose > 1 And linelabel$ <> "" Then Print "Working on Line: "; linelabel$
    Print #1, "_L"; linelabel$
    SkipLabel:
    ' Decode line so we can print it as normal in the .asm file
    C$ = ""
    Start = x ' Save where we are
    v = Array(x): x = x + 1
    If v = &HF5 And Array(x) = &H0D Then vOld = &H0D: v = Array(x): x = x + 1: GoTo DoAnotherLine
    Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' Is it the end of a line? or colon?
        If v >= &HF0 Then
            Lastv = v
            GoSub DecodeToken ' return with decoded command/variable in Temp$
            C$ = C$ + Temp$
            If Lastv = &HFF Then C$ = C$ + " " ' Add a space after a general command
            v = 0
        Else
            C$ = C$ + Chr$(v)
        End If
        v = Array(x): x = x + 1
    Loop
    v = Array(x): x = x + 1
    vOld = v ' Save it as we might have reached a colon
    ' Print the line we are working on to the .asm file
    If C$ <> "" Then Print #1, "; "; C$: C$ = ""
    x = Start ' Restore where to start (new line or after a colon)
    'Check if this line starts with a REM or '

    'Check for REM or '
    If Array(x) = &HFF Then
        v = (Array(x + 1)) * 256 + Array(x + 2)
        If v = REM_CMD Or v = REM_Apostraphe_CMD Then
            ' this line starts with a REM, handle it
            x = x + 3
            GoSub DoREM ' Go handle a new line that starts with a REM or '
            GoTo DoAnotherLine
        End If
    End If
    ' Check for a REMarks on the rest of this line, and modify line so the REMarks are skipped

    RemStart = 0
    Check1 = REM_CMD \ 256: Check2 = REM_CMD And 255
    Check3 = REM_Apostraphe_CMD \ 256: Check4 = REM_Apostraphe_CMD And 255
    GoSub GetGenExpression ' Returns with single expression in GenExpression$
    Do Until GenExpression$ = Chr$(&HF5) + Chr$(&H0D) Or GenExpression$ = Chr$(&HF5) + Chr$(&H3A)
        If GenExpression$ = Chr$(&HFF) + Chr$(Check1) + Chr$(Check2) Or GenExpression$ = Chr$(&HFF) + Chr$(Check3) + Chr$(Check4) Then
            ' This line has a REM, copy stuff before the REM to the end of the line and move x pointer to the start of actual commands
            RemStart = x - 3: Exit Do
        Else
            Expression$ = Expression$ + GenExpression$
        End If
        GoSub GetGenExpression ' Returns with single expression in GenExpression$
    Loop
    If RemStart > 0 Then
        Do Until Array(x) = &HF5 And Array(x + 1) = &H0D: x = x + 1: Loop
        ' this line has remarks to be ignored
        Endx = x
        AmountToCopy = RemStart - Start
        Difference = Endx - RemStart
        For ii = Endx - 1 To Endx - AmountToCopy Step -1
            Array(ii) = Array(ii - Difference)
        Next ii
        Start = Endx - AmountToCopy
    End If
    ' Handle the actual line here:
    x = Start ' Restore where to start (new line or after a colon)
    ' Figure out what type of token we have and deal with it
    v = Array(x): x = x + 1 ' get the token
    If Verbose > 3 Then Print "Token is: "; Hex$(v)
    If v < &HF0 And v > &HF4 And v <> &HFF Then
        Print "Error on or just after "; linelabel; " Needs either a variable or a General command, but found ";
        If v = &HFC Then Print "Operator Command": System
        If v = &HFD Then Print "String Command": System
        If v = &HFE Then Print "Numeric Command": System
        Print "Bad syntax on";: GoTo FoundError
    End If
    If v = &HFF Then
        ' Found a general command
        v = Array(x) * 256 + Array(x + 1): x = x + 2
        If v = LET_CMD Then
            'We have the LET command, ignore this
            v = Array(x): x = x + 1 ' get the variable to handle
        Else
            If Verbose > 3 Then Print "Found a General command: "; GeneralCommands$(v)
            GoSub JumpToGeneralCommand
            GoTo DoAnotherLine ' Jump to the general command pointed at by V, Ends with a RETURN
        End If
    End If
    'Print "v="; Hex$(v)
    If v = &HF0 Then GoSub HandleNumericArray: GoTo DoAnotherLine
    If v = &HF1 Then GoSub HandleStringArray: GoTo DoAnotherLine
    If v = &HF2 Then GoSub HandleNumericVariable: GoTo DoAnotherLine
    If v = &HF3 Then GoSub HandleStringVariable: GoTo DoAnotherLine
    If v = &HF4 Then GoSub HandleFloatVariable: GoTo DoAnotherLine
Wend
Print #1, "EXITProgram:"
A$ = "ORCC": B$ = "#$50": C$ = "Turn off the interrupts": GoSub AO
A$ = "STA": B$ = "$FFD8": C$ = "Put Coco back in normal speed": GoSub AO
' Restore the IRQ jump address
A$ = "LDX": B$ = "$FFFE": C$ = "Get the RESET location": GoSub AO
A$ = "CMPX": B$ = "#$8C1B": C$ = "Check if it's a CoCo 3": GoSub AO
A$ = "BNE": B$ = "RestoreCoCo1": C$ = "Setup IRQ, using CoCo 1 IRQ Jump location": GoSub AO
A$ = "LDX": B$ = "#$FEF7": C$ = "X = Address for the COCO 3 IRQ JMP": GoSub AO
A$ = "BRA": B$ = ">": C$ = "Skip ahead": GoSub AO
Z$ = "RestoreCoCo1": GoSub AO
A$ = "LDX": B$ = "#$010C": C$ = "X = Address for the COCO 1 IRQ JMP": GoSub AO
Z$ = "!"
' Restore it
A$ = "LDU": B$ = "#OriginalIRQ": C$ = "U = Address of the original IRQ": GoSub AO
A$ = "LDA": B$ = ",U": C$ = "A = Branch Instruction": GoSub AO
A$ = "STA": B$ = ",X": C$ = "Save Branch Instruction": GoSub AO
A$ = "LDD": B$ = "1,U": C$ = "D = address": GoSub AO
A$ = "STD": B$ = "1,X": C$ = "Restore the Address of the IRQ": GoSub AO
Print #1, "RestoreStack:"
A$ = "LDS": B$ = "#$0000": C$ = "Selfmodified when this programs starts - this restores S just how BASIC had it": GoSub AO
A$ = "PULS": B$ = "CC,D,DP,X,Y,U,PC": C$ = "Restore the original BASIC Register values and return to BASIC, if it can": GoSub AO

' Add data Table if needed
Print #1, "DataStart:"
If DataArrayCount > 0 Then
    For x = 0 To DataArrayCount - 1 Step 4
        Print #1, "        FQB     $";
        q1$ = Right$("00" + Hex$(DataArray(x)), 2) + Right$("00" + Hex$(DataArray(x + 1)), 2)
        q2$ = Right$("00" + Hex$(DataArray(x + 2)), 2) + Right$("00" + Hex$(DataArray(x + 3)), 2)
        Print #1, q1$; q2$; "   ;";
        Print #1, Right$("0000" + Hex$(x + a), 4); ": ";
        Print #1, Right$("00" + Hex$(DataArray(x)), 2); " "; Right$("00" + Hex$(DataArray(x + 1)), 2); " ";
        Print #1, Right$("00" + Hex$(DataArray(x + 2)), 2); " "; Right$("00" + Hex$(DataArray(x + 3)), 2)
    Next x
End If

If AutoStart = 1 Then
    ' Make the program autostart (takes over the IRQ JMP routine)
    A$ = "ORG": B$ = "$0176": C$ = "Make the program autostart by changing the CLOSE ONE FILE jump to jump to ours instead": GoSub AO
    A$ = "JMP": B$ = "START": C$ = "Make it point to the start of this program": GoSub AO
End If
A$ = "END": B$ = "START": GoSub AO
Close #1

' Check if we should optimize the program
If Optimize > 0 Then
    ' Optimize it
    ' At this point the program will execute but we can remove extra lines of code as the numeric parser always exits with a STD _Var_PF00
    ' It has been flagged with "*XX We can delete the line above XX*" a line after the last STD _Var_PF00 (that can be erased)
    ' Let's remove those lines below
    Open OutName$ For Input As #1
    Open "Temp.txt" For Output As #2
    CheckForNumericExtra:
    While EOF(1) = 0
        Line Input #1, i$
        While EOF(1) = 0
            Line Input #1, i2$
            If i2$ = "*XX We can delete the line above XX*" Then
                GoTo CheckForNumericExtra
            Else
                Print #2, i$
                i$ = i2$
            End If
        Wend
        Print #2, i$
    Wend
    Close #1
    Close #2
    Kill OutName$ 'Kill the original
    Name "Temp.txt" As OutName$ ' Rename Temp.txt to OutName$
End If
If Optimize > 1 Then
    ' - Add optimize option 2 which will find (similar to):
    '        LDD     xxxx
    '        STD     _Var_PF00
    '        LDD     yyyy
    '        STD     _Var_PF01
    '        LDD     _Var_PF00
    '        ADDD    _Var_PF01
    ' And replace it with:
    '        LDD     xxxx
    '        ADDD    yyyy

    Dim buffer$(6)
    fileName$ = OutName$
    ' Open the input file for reading
    Open fileName$ For Input As #1
    ' Create a temporary output file
    outputFile = FreeFile
    Open "temp.asm" For Output As #2
    Do While Not EOF(1)
        ' Read the next line
        Line Input #1, line$
        ' Shift the buffer
        For I = 1 To 5
            buffer$(I) = buffer$(I + 1)
        Next I
        buffer$(6) = line$
        ' Check if the buffer matches the pattern
        If Left$(buffer$(1), 16) = "        LDD     " AND _
           Left$(buffer$(2), 25) = "        STD     _Var_PF00" AND _
           Left$(buffer$(3), 16) = "        LDD     " AND _
           Left$(buffer$(4), 25) = "        STD     _Var_PF01" AND _
           Left$(buffer$(5), 25) = "        LDD     _Var_PF00" Then
            ' Extract the instruction from the last line
            lastLine$ = buffer$(6)
            lastLine$ = Mid$(lastLine$, 9, InStr(9, lastLine$, " ") - 9)
            ' Write the replacement lines
            Print #2, buffer$(1)
            Print #2, "        "; lastLine$; "    "; Mid$(buffer$(3), 17, Len(buffer$(3)) - 17)
            ' Clear the buffer
            For I = 2 To 6
                Line Input #1, line$
                buffer$(I) = line$
            Next I
        Else
            ' Write the buffered line if it's not part of the pattern
            Print #2, buffer$(1)
        End If
    Loop
    ' Write the remaining lines in the buffer
    For I = 2 To 6
        If buffer$(I) <> "" Then
            Print #2, buffer$(I)
        End If
    Next I
    ' Close the files
    Close #1
    Close #2
    ' Replace the original file with the modified file
    Kill fileName$
    Name "temp.asm" As fileName$
End If

If KeepTempFiles = 0 Then
    'Erase the temp files
    Kill "NumericVariablesUsed.txt"
    Kill "FloatingPointVariablesUsed.txt"
    Kill "StringVariablesUsed.txt"
    Kill "GeneralCommandsFound.txt"
    Kill "StringCommandsFound.txt"
    Kill "NumericCommandsFound.txt"
    Kill "NumericArrayVarsUsed.txt"
    Kill "StringArrayVarsUsed.txt"
    Kill "DefFNUsed.txt"
    Kill "DefVarUsed.txt"
    Kill "BASIC_Text.bas"
    Kill "BasicTokenized.bin"
    Kill "BasicTokenizedB4Pass2.bin"
    Kill "BasicTokenizedB4Pass3.bin"
End If
If Verbose > 0 Then Print "All Done :)"
System 1 ' 1 signifies exit with no errors :)

' Returns with X pointing at the memory location for the Numeric Array, D is unchanged
MakeXPointAtNumericArray:
A$ = "PSHS": B$ = "D": C$ = "Save D": GoSub AO
If Verbose > 3 Then Print "Going to deal with  Numeric array"
v = Array(x) * 256 + Array(x + 1): x = x + 2
NV$ = NumericArrayVariables$(v)
If Verbose > 3 Then Print "Numeric array variable is: "; NV$
NumDims = Array(x): x = x + 3 ' Consume the $F5 & open bracket
If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims
If NumDims = 1 Then ' does it only have one dimension? if so it's simpler
    ' Yes just a single dimension array
    If Verbose > 3 Then Print "handling a one dimensional array"
    If Verbose > 3 Then Print #1, "; Started handling the array here:"
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
Else
    ' Handle multi dimensional arrays
    ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)
    If Verbose > 3 Then Print "handling a multi dimensional array"
    A$ = "LDX": B$ = "#_ArrayNum_" + NV$ + "+1": C$ = " X points at the 2nd array Element size": GoSub AO ' X points at the 2nd array Element size
    A$ = "PSHS": B$ = "X": C$ = "Save X on the stack, so we can point to it and just in case we have arrays inside arrays...": GoSub AO
    ' Get d1
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," move pointer past the comma
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AO ' D = d1
    If NumDims = 2 Then GoTo DoNumArrCloseBracket0 ' skip ahead if we only have 2 dimension in the array
    'Get NumElements2
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement2": GoSub AO
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO ' LSB of d1
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO ' D=d1* NumElements2
    A$ = "PSHS": B$ = "D": C$ = "Save the result on the stack": GoSub AO ' Save it on the stack
    A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AO
    A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AO
    A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AO
    Z$ = "!": GoSub AO ' Num Element Pointer is now pointing at NumElements3
    'Get d2
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," move pointer past the comma
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    ' Add d2
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
    A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AO
    If Verbose > 2 Then Print "number of dimensions:"; NumDims
    If NumDims > 3 Then
        For TempNumArray1 = 3 To NumDims - 1 ' Number of dimensions in the array - 1 since last wont have a comma seperating it
            ' Get NumElementsX
            ' Get NumElementsX
            A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AO
            A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO
            A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO '                        Need 16bit muliply
            A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AO
            A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AO
            A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AO
            A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AO
            Z$ = "!": GoSub AO
            ' Add dX
            GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," move pointer past the comma
            ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
            A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
            A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AO
        Next TempNumArray1
    End If
    ' Last dimension value ends with a close bracket
    DoNumArrCloseBracket0:
    ' Get NumElementsX
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AO
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO '                                 Need 16bit multiply
    A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AO
    ' Add dX
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
    A$ = "LEAS": B$ = "6,S": C$ = "Fix the stack": GoSub AO
End If
A$ = "LSLB": GoSub AO
A$ = "ROLA": C$ = "D=D*2, 16 bit integers in the numeric array": GoSub AO
num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
A$ = "ADDD": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "D points at the start of the destination mem location in the array": GoSub AO

A$ = "TFR": B$ = "D,X": C$ = "Make X the pointer to where this array is stored in RAM": GoSub AO
A$ = "PULS": B$ = "D": C$ = "Save the memory location to write the value that this array equals": GoSub AO
Return 'X pointing at the memory location for the Numeric Array, D is unchanged

' Exits with a Return
HandleNumericArray:
If Verbose > 3 Then Print "Going to deal with Numeric array"
v = Array(x) * 256 + Array(x + 1): x = x + 2
NV$ = NumericArrayVariables$(v)
If Verbose > 3 Then Print "Numeric array variable is: "; NV$
NumDims = Array(x): x = x + 3 ' Consume the $F5 & open bracket
If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims

If NumDims = 1 Then ' does it only have one dimension? if so it's simpler
    ' Yes just a single dimension array
    If Verbose > 3 Then Print "handling a one dimensional array"
    If Verbose > 3 Then Print #1, "; Started handling the array here:"
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
Else
    ' Handle multi dimensional arrays
    ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)
    If Verbose > 3 Then Print "handling a multi dimensional array"
    A$ = "LDX": B$ = "#_ArrayNum_" + NV$ + "+1": C$ = "X points at the 2nd array Element size": GoSub AO ' X points at the 2nd array Element size
    A$ = "PSHS": B$ = "X": C$ = "Save X on the stack, so we can point to it and just in case we have arrays inside arrays...": GoSub AO
    ' Get d1
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," and move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AO ' D = d1
    If NumDims = 2 Then GoTo DoNumArrCloseBracket1 ' skip ahead if we only have 2 dimension in the array
    'Get NumElements2
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement2": GoSub AO
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO ' LSB of d1
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO ' D=d1* NumElements2
    A$ = "PSHS": B$ = "D": C$ = "Save the result on the stack": GoSub AO ' Save it on the stack
    A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AO
    A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AO
    A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AO
    Z$ = "!": GoSub AO ' Num Element Pointer is now pointing at NumElements3
    'Get d2
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," and move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    ' Add d2
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
    A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AO
    If Verbose > 2 Then Print "number of dimensions:"; NumDims
    If NumDims > 3 Then
        For TempNumArray1 = 3 To NumDims - 1 ' Number of dimensions in the array - 1 since last ont have a comma seperating it
            ' Get NumElementsX
            A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AO
            A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO
            A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO '                        Need 16bit muliply
            A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AO
            A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AO
            A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AO
            A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AO
            Z$ = "!": GoSub AO
            ' Add dX
            GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," and move past it
            ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
            A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
            A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AO
        Next TempNumArray1
    End If
    DoNumArrCloseBracket1:

    ' Last dimension value ends with a close bracket
    ' Get NumElementsX
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AO
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO '                                 Need 16bit multiply
    A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AO
    ' Add dX
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
    A$ = "LEAS": B$ = "6,S": C$ = "Fix the stack": GoSub AO
End If
A$ = "LSLB": GoSub AO
A$ = "ROLA": C$ = "D=D*2, 16 bit integers in the numeric array": GoSub AO
num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
A$ = "ADDD": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "D points at the start of the destination string": GoSub AO
A$ = "PSHS": B$ = "D": C$ = "Save the memory location to write the value that this array equals": GoSub AO
v = Array(x): x = x + 1
If v <> &HFC Then Print "Syntax error, looking for = sign while getting Numeric Array in";: GoTo FoundError
v = Array(x): x = x + 1
If v <> &H3D Then Print "Syntax error, looking for = sign in while getting Numeric Array in";: GoTo FoundError
'Get an expression that ends with an EOL
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
FirstChar = Asc(Left$(Expression$, 1))
If FirstChar = &HF4 Then
    ' We found a floating point number, round it to the nearest signed 16 bit integer value
    If Len(Expression$) <> 3 Then
        Print "Something is wrong with the floating point variable being assigned to "; NV; " on";: GoTo FoundError
    End If
    v = Asc(Mid$(Expression$, 2, 1)) * 256 + Asc(Right$(Expression$, 1))
    SourceFPV$ = "_FPVar_" + FloatVariable$(v)
    A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AO
    A$ = "LDX": B$ = "#" + SourceFPV$: C$ = "Point X at the floaing point variable": GoSub AO
    A$ = "JSR": B$ = "FPLOD": C$ = "Copy FP NUMBER FROM ADDRESS X AND PUSH ONTO USER STACK": GoSub AO
    A$ = "JSR": B$ = "FP2INT": C$ = "Convert FP number at -5,U to a signed 16-bit number in D": GoSub AO
    A$ = "STD": B$ = "[,S++]": C$ = "Save D in the array, and fix the stack": GoSub AO
    Return
End If
num = INT_CMD: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
' The INT command on the CoCo truncates the decimal part of a floating point number, if the floating point number is a negative then it also subtracts 1 to the result
If FirstChar = &HFE Then
    If Len(Expression$) > 7 Then
        If Asc(Mid$(Expression$, 2, 1)) = MSB And Asc(Mid$(Expression$, 3, 1)) = LSB Then
            ' Found the INT command
            If Asc(Mid$(Expression$, 6, 1)) = &HF4 Then
                ' We found a floating point number, convert number to a signed 16 bit number (no rounding)
                If Len(Expression$) <> 10 Then
                    Print "Something is wrong with the floating point variable being converted to an integer assigned to "; NV; " on";: GoTo FoundError
                End If
                v = Asc(Mid$(Expression$, 7, 1)) * 256 + Asc(Mid$(Expression$, 8, 1))
                SourceFPV$ = "_FPVar_" + FloatVariable$(v)
                GoSub Float2INT ' Enter with  SourceFPV$ as the source FP string variable and NV$ as the destination signed 16 bit integer variable
                Return
            End If
        End If
    End If
End If
' Check Expression$ for a variable or numeric commands, if there aren't any, then ExType=0 and NewExpression$ will be the expression without any tokenized characters
GoSub CheckForVariable
If ExType = 0 Then
    GoSub EvaluateNewExpression
    num = D: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    A$ = "LDD": B$ = "#" + Num$: C$ = "Since we don't have any variables or numeric commands, this is the calculated value": GoSub AO
Else
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
End If
A$ = "STD": B$ = "[,S++]": C$ = "Save D in the array, and fix the stack": GoSub AO
Return

' Returns with X pointing at the memory location for the String Array, D is unchanged
MakeXPointAtStringArray:
If Verbose > 3 Then Print "Going to deal with String array"
v = Array(x) * 256 + Array(x + 1): x = x + 2
SV$ = StringArrayVariables$(v)
If Verbose > 3 Then Print "String array variable is: "; SV$
NumDims = Array(x): x = x + 3 ' Consume the $F5 & open bracket

If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims
If NumDims = 1 Then ' does it only have one dimension? if so it's simpler
    ' Yes just a single dimension array
    If Verbose > 3 Then Print "handling a one dimensional array"
    If Verbose > 3 Then Print #1, "; Started handling the array here:"
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
Else
    ' Handle multi dimensional arrays
    ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)
    If Verbose > 3 Then Print "handling a multi dimensional array"
    A$ = "LDX": B$ = "#_ArrayStr_" + SV$ + "+1": C$ = "X points at the 2nd array Element size": GoSub AO ' X points at the 2nd array Element size
    A$ = "PSHS": B$ = "X": C$ = "Save X on the stack, so we can point to it and just in case we have arrays inside arrays...": GoSub AO
    ' Get d1
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AO ' D = d1
    If NumDims = 2 Then GoTo DoStrArrCloseBracket0 ' skip ahead if we only have 2 dimension in the array
    'Get NumElements2
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement2": GoSub AO
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO ' LSB of d1
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO ' D=d1* NumElements2
    A$ = "PSHS": B$ = "D": C$ = "Save the result on the stack": GoSub AO ' Save it on the stack
    A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AO
    A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AO
    A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AO
    Z$ = "!": GoSub AO ' Num Element Pointer is now pointing at NumElements3
    'Get d2
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    ' Add d2
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
    A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AO
    If Verbose > 2 Then Print "number of dimensions:"; NumDims
    If NumDims > 3 Then
        For TempNumArray1 = 3 To NumDims - 1 ' Number of dimensions in the array - 1 since last wont have a comma seperating it
            ' Get NumElementsX
            A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AO
            A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO
            A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO '                        Need 16bit muliply
            A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AO
            A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AO
            A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AO
            A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AO
            Z$ = "!": GoSub AO
            ' Add dX
            GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," & move past it
            ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
            A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
            A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AO
        Next TempNumArray1
    End If
    ' Last dimension value ends with a close bracket
    DoStrArrCloseBracket0:
    ' Get NumElementsX
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AO
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO '                                 Need 16bit multiply
    A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AO
    ' Add dX
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
    A$ = "LEAS": B$ = "6,S": C$ = "Fix the stack": GoSub AO
End If
' * size of each element
If StringArraySize = 255 Then
    ' We only use B string arrays are 256 bytes each, we can't have more than 255 (actually way less)
    A$ = "TFR": B$ = "B,A": C$ = "D = B * 256": GoSub AO
    A$ = "CLRB": C$ = Chr$(&H22) + Chr$(&H22): GoSub AO
Else
    ' A little slower but saves RAM
    num = StringArraySize: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    A$ = "LDA": B$ = "#" + Num$ + "+1": C$ = "String Array size requested by the user +1 because first digit is the string length": GoSub AO
    A$ = "MUL": C$ = "D = A * B": GoSub AO
End If
num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
A$ = "ADDD": B$ = "#_ArrayStr_" + SV$ + "+" + Num$: C$ = "D points at the start of the destination string": GoSub AO
A$ = "TFR": B$ = "D,X": C$ = "Make X the pointer to where this array is stored in RAM": GoSub AO
Return 'X pointing at the memory location for the Numeric Array, D is unchanged

' Exits with a Return
HandleStringArray:
If Verbose > 3 Then Print "Going to deal with String array"
v = Array(x) * 256 + Array(x + 1): x = x + 2
SV$ = StringArrayVariables$(v)
If Verbose > 3 Then Print "String array variable is: "; SV$
NumDims = Array(x): x = x + 3 ' Consume the $F5 & open bracket
If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims
If NumDims = 1 Then ' does it only have one dimension? if so it's simpler
    ' Yes just a single dimension array
    If Verbose > 3 Then Print "handling a one dimensional array"
    If Verbose > 3 Then Print #1, "; Started handling the array here:"
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
Else
    ' Handle multi dimensional arrays

    ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)
    If Verbose > 3 Then Print "handling a multi dimensional array"
    A$ = "LDX": B$ = "#_ArrayStr_" + SV$ + "+1": C$ = "X points at the 2nd array Element size": GoSub AO ' X points at the 2nd array Element size
    A$ = "PSHS": B$ = "X": C$ = "Save X on the stack, so we can point to it and just in case we have arrays inside arrays...": GoSub AO
    ' Get d1
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AO ' D = d1
    If NumDims = 2 Then GoTo DoStrArrCloseBracket1 ' skip ahead if we only have 2 dimension in the array
    'Get NumElements2
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement2": GoSub AO
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO ' LSB of d1
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO ' D=d1* NumElements2
    A$ = "PSHS": B$ = "D": C$ = "Save the result on the stack": GoSub AO ' Save it on the stack
    A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AO
    A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AO
    A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AO
    Z$ = "!": GoSub AO ' Num Element Pointer is now pointing at NumElements3
    'Get d2
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    ' Add d2
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
    A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AO
    If Verbose > 2 Then Print "number of dimensions:"; NumDims
    If NumDims > 3 Then
        For TempNumArray1 = 3 To NumDims - 1 ' Number of dimensions in the array - 1 since last wont have a comma seperating it
            ' Get NumElementsX
            A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AO
            A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO
            A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO '                                 Need 16bit multiply
            A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AO
            A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AO
            A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AO
            A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AO
            Z$ = "!": GoSub AO
            ' Add dX
            GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," & move past it
            ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
            A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
            A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AO
        Next TempNumArray1
    End If
    DoStrArrCloseBracket1:
    ' Last dimension value ends with a close bracket
    ' Get NumElementsX
    A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AO
    A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO
    A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO '                                 Need 16bit multiply
    A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AO
    ' Add dX
    GoSub GetExpressionB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression returns with D = the value
    A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
    A$ = "LEAS": B$ = "6,S": C$ = "Fix the stack": GoSub AO
End If
' * size of each element
If StringArraySize = 255 Then
    ' We only use B string arrays are 256 bytes each, we can't have more than 255 (actually way less)
    A$ = "TFR": B$ = "B,A": C$ = "D = B * 256": GoSub AO
    A$ = "CLRB": C$ = Chr$(&H22) + Chr$(&H22): GoSub AO
Else
    ' A little slower but saves RAM
    num = StringArraySize: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    A$ = "LDA": B$ = "#" + Num$ + "+1": C$ = "String Array size requested by the user +1 because first digit is the string length": GoSub AO
    A$ = "MUL": C$ = "D = A * B": GoSub AO
End If
num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
A$ = "ADDD": B$ = "#_ArrayStr_" + SV$ + "+" + Num$: C$ = "D = D + Start of this array memory": GoSub AO
A$ = "PSHS": B$ = "D": C$ = "Save it on the stack": GoSub AO

v = Array(x): x = x + 1
If v <> &HFC Then Print "Syntax error, looking for = sign while getting String Array in";: GoTo FoundError
v = Array(x): x = x + 1
If v <> &H3D Then Print "Syntax error, looking for = sign while getting String Array in";: GoTo FoundError
GoSub GetExpressionB4EOL ' Get the expression before an End of Line
GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00

' Copy _StrVar_PF00 to String Array variable
A$ = "PULS": B$ = "X": C$ = "X points at the start of the destination string": GoSub AO
A$ = "LDU": B$ = "#_StrVar_PF00": C$ = "U points at the start of the source string": GoSub AO
A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AO
A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AO
A$ = "BEQ": B$ = "Done@": C$ = "If the length of the string is zero then don't print it (Skip ahead)": GoSub AO
Z$ = "!"
A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AO
A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AO
A$ = "DECB": C$ = "Decrement the counter": GoSub AO
A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AO
Z$ = "Done@": GoSub AO
Print #1, "" ' Leave a space between sections so Done@ will work for each section
Return

' Exits with a return
HandleNumericVariable:
v = Array(x) * 256 + Array(x + 1): x = x + 2
NV$ = "_Var_" + NumericVariable$(v)
If Verbose > 3 Then Print "Numeric variable is: "; NV$
v = Array(x): x = x + 1
If v <> &HFC Then Print "Syntax error12, looking for = sign in";: GoTo FoundError
v = Array(x): x = x + 1
If v <> &H3D Then Print "Syntax error13, looking for = sign in";: GoTo FoundError
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
' Check Expression$ for a variable or numeric commands, if there aren't any, then ExType=0 and NewExpression$ will be the expression without any tokenized characters
FirstChar = Asc(Left$(Expression$, 1))
If FirstChar = &HF4 Then
    ' We found a floating point number, round it to the nearest signed 16 bit integer value
    If Len(Expression$) <> 3 Then
        Print "Something is wrong with the floating point variable being assigned to "; NV; " on";: GoTo FoundError
    End If
    v = Asc(Mid$(Expression$, 2, 1)) * 256 + Asc(Right$(Expression$, 1))
    SourceFPV$ = "_FPVar_" + FloatVariable$(v)
    A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AO
    A$ = "LDX": B$ = "#" + SourceFPV$: C$ = "Point X at the floaing point variable": GoSub AO
    A$ = "JSR": B$ = "FPLOD": C$ = "Copy FP NUMBER FROM ADDRESS X AND PUSH ONTO USER STACK": GoSub AO
    A$ = "JSR": B$ = "FP2INT": C$ = "Convert FP number at -5,U to a signed 16-bit number in D": GoSub AO
    A$ = "STD": B$ = NV$: C$ = "Save to numeric variable": GoSub AO
    Return
End If
num = INT_CMD: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
' The INT command on the CoCo truncates the decimal part of a floating point number, if the floating point number is a negative then it also subtracts 1 to the result
If FirstChar = &HFE Then
    If Len(Expression$) > 7 Then
        If Asc(Mid$(Expression$, 2, 1)) = MSB And Asc(Mid$(Expression$, 3, 1)) = LSB Then
            ' Found the INT command
            If Asc(Mid$(Expression$, 6, 1)) = &HF4 Then
                ' We found a floating point number, convert number to a signed 16 bit number (no rounding)
                If Len(Expression$) <> 10 Then
                    Print "Something is wrong with the floating point variable being converted to an integer assigned to "; NV; " on";: GoTo FoundError
                End If
                v = Asc(Mid$(Expression$, 7, 1)) * 256 + Asc(Mid$(Expression$, 8, 1))
                SourceFPV$ = "_FPVar_" + FloatVariable$(v)
                GoSub Float2INT ' Enter with  SourceFPV$ as the source FP string variable and NV$ as the destination signed 16 bit integer variable
                Return
            End If
        End If
    End If
End If
' Check Expression$ for a variable or numeric commands, if there aren't any, then ExType=0 and NewExpression$ will be the expression without any tokenized characters
GoSub CheckForVariable
If ExType = 0 Then
    GoSub EvaluateNewExpression
    num = D: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    A$ = "LDD": B$ = "#" + Num$: C$ = "Since we don't have any variables or numeric commands, this is the calculated value": GoSub AO
Else
    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
End If
A$ = "STD": B$ = NV$: C$ = "Save Numeric variable": GoSub AO
Return

' Enter with  SourceFPV$ as the source FP string variable and NV$ as the destination signed 16 bit integer variable
' The INT command on the CoCo truncates the decimal part of a floating point number, if the floating point number is a negative then it also subtracts 1 from the result
Float2INT:
'Let's round the value by 0.5
'A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AO
A$ = "LDU": B$ = "#" + SourceFPV$ + "+5": C$ = "Point X at the floaing point variable": GoSub AO
'A$ = "JSR": B$ = "FPLOD": C$ = "Copy FP NUMBER FROM ADDRESS X AND PUSH ONTO USER STACK": GoSub AO
A$ = "JSR": B$ = "FP2INT": C$ = "Convert FP number at -5,U to a signed 16-bit number in D": GoSub AO
A$ = "LDX": B$ = SourceFPV$ + "+1": C$ = "Check if original was a positive": GoSub AO
A$ = "BPL": B$ = ">": C$ = "If positive then skip ahead ": GoSub AO
A$ = "SUBD": B$ = "#$0001": C$ = "If negative subtract 1": GoSub AO
Z$ = "!"
A$ = "STD": B$ = NV$: C$ = "Save to numeric variable": GoSub AO
Print #-1,
Return

HandleFloatVariable:
v = Array(x) * 256 + Array(x + 1): x = x + 2
FPV$ = "_FPVar_" + FloatVariable$(v)
v = Array(x): x = x + 1
If v <> &HFC Then Print "Syntax error12, looking for = sign in";: GoTo FoundError
v = Array(x): x = x + 1
If v <> &H3D Then Print "Syntax error13, looking for = sign in";: GoTo FoundError
Start1 = x
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
EP = 1 'pointer in Expression$
FirstChar = Asc(Mid$(Expression$, EP, 1)): EP = EP + 1
Select Case FirstChar
    Case &HFE
        'Handle numeric/float command
        CheckFloatIF:
        v = Asc(Mid$(Expression$, EP, 1)) * 256 + Asc(Mid$(Expression$, EP + 1, 1)): EP = EP + 2 ' Get numeric command ID
        Select Case v
            Case FLOATADD_CMD
                FloatCMD$ = "FPADD"
                ArgCount = 2
            Case FLOATSUB_CMD
                FloatCMD$ = "FPSUB"
                ArgCount = 2
            Case FLOATMUL_CMD
                FloatCMD$ = "FPMUL"
                ArgCount = 2
            Case FLOATDIV_CMD
                FloatCMD$ = "FPDIV"
                ArgCount = 2
            Case CMPGT_CMD
                FloatCMD$ = "FPCMP_Tweak"
                ArgCount = 2
                CompType = 1
            Case CMPGE_CMD
                FloatCMD$ = "FPCMP_Tweak"
                ArgCount = 2
                CompType = 2
            Case CMPEQ_CMD
                FloatCMD$ = "FPCMP_Tweak"
                ArgCount = 2
                CompType = 3
            Case CMPNE_CMD
                FloatCMD$ = "FPCMP_Tweak"
                ArgCount = 2
                CompType = 4
            Case CMPLE_CMD
                FloatCMD$ = "FPCMP_Tweak"
                ArgCount = 2
                CompType = 5
            Case CMPLT_CMD
                FloatCMD$ = "FPCMP_Tweak"
                ArgCount = 2
                CompType = 6
            Case FLOATSQR_CMD
                FloatCMD$ = "FPSQRT"
                ArgCount = 1
            Case FLOATSIN_CMD
                FloatCMD$ = "FPSIN"
                ArgCount = 1
            Case FLOATCOS_CMD
                FloatCMD$ = "FPCOS"
                ArgCount = 1
            Case FLOATTAN_CMD
                FloatCMD$ = "FPTAN"
                ArgCount = 1
            Case FLOATATAN_CMD
                FloatCMD$ = "FPATAN"
                ArgCount = 1
            Case FLOATEXP_CMD
                FloatCMD$ = "FPEXP"
                ArgCount = 1
            Case FLOATLOG_CMD
                FloatCMD$ = "FPLN"
                ArgCount = 1
            Case INT_CMD
                EP = EP + 2 ' consume the open bracket
                Expression$ = Mid$(Expression$, EP, Len(Expression$) - EP - 1)
                ' Check Expression$ for a variable or numeric commands, if there aren't any, then ExType=0 and NewExpression$ will be the expression without any tokenized characters
                GoSub CheckForVariable
                If ExType = 0 Then
                    GoSub EvaluateNewExpression
                    num = D: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "LDD": B$ = "#" + Num$: C$ = "Since we don't have any variables or numeric commands, this is the calculated value": GoSub AO
                Else
                    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
                End If
                A$ = "LDU": B$ = "#" + FPV$: C$ = "Point U at the beginning of the Floating point variable": GoSub AO
                A$ = "JSR": B$ = "INT2FP": C$ = "Convert signed 16-BIT integer in D to floating point number and store it at U, U=U+5": GoSub AO
                Return
            Case STRTOFLOAT_CMD
                ' Handle String to Float command
                EP = EP + 2 ' consume the open bracket
                Expression$ = Mid$(Expression$, EP, Len(Expression$) - EP - 1)
                GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
                ' Copy _StrVar_PF00 to string variable
                A$ = "LDX": B$ = "#_StrVar_PF00": C$ = "X points at the start of the source string": GoSub AO
                A$ = "LDB": B$ = ",X+": C$ = "Get String length, Incrment X": GoSub AO
                A$ = "ABX": C$ = "X=X+B": GoSub AO
                A$ = "CLR": B$ = ",X": C$ = "Clear the end of the string": GoSub AO
                A$ = "LDY": B$ = "#_StrVar_PF00+1": C$ = "Y points at the start of the source string": GoSub AO
                A$ = "LDU": B$ = "#" + FPV$: C$ = "U points at the floating point number": GoSub AO
                A$ = "JSR": B$ = "SCANNUM": C$ = "Convert String at Y to FP number at U": GoSub AO
                Return
            Case Else
                Print "Can't figure out the type of number/expression, maybe it needs to use INT() on";: GoTo FoundError
        End Select
        If Asc(Mid$(Expression$, EP, 1)) = &HF5 And Asc(Mid$(Expression$, EP + 1, 1)) = &H28 Then
            EP = EP + 2 'move past the open bracket
            If ArgCount = 1 Then
                v = Asc(Mid$(Expression$, EP, 1))
                If v = &HFC And Mid$(Expression$, EP + 1, 1) = "-" Then
                    negval = 1
                Else
                    negval = 0
                End If
                If (v >= Asc("0") And v <= Asc("9")) Or v = Asc(".") Or v = &HFC Then
                    ' This is a number value
                    If v = &HFC Then 'See if it's a negative
                        ' we have a minus sign
                        FPString$ = Mid$(Expression$, EP + 1, Len(Expression$) - EP - 2)
                    Else
                        FPString$ = Mid$(Expression$, EP, Len(Expression$) - EP - 1)
                    End If
                    GoSub FPConversion ' Convert floating point string FPString$ to 5 Byte Floating point HEX value FPBytes$
                    A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AO
                    A$ = "LDD": B$ = "#$" + Left$(FPBytes$, 4): C$ = "First two digits of the FP number " + FPString$: GoSub AO
                    A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AO
                    A$ = "LDD": B$ = "#$" + Mid$(FPBytes$, 5, 4): C$ = "Third and fourth digits of the FP number " + FPString$: GoSub AO
                    A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AO
                    A$ = "LDA": B$ = "#$" + Right$(FPBytes$, 2): C$ = "Fifth digit of the FP number " + FPString$: GoSub AO
                    A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AO
                    A$ = "JSR": B$ = FloatCMD$: C$ = "Do the FP operation": GoSub AO
                    A$ = "LDD": B$ = "-5,U": C$ = "First two digits of the FP result": GoSub AO
                    A$ = "STD": B$ = FPV$: C$ = "Save it": GoSub AO
                    A$ = "LDD": B$ = "-3,U": C$ = "Third and fourth digits of the FP result": GoSub AO
                    A$ = "STD": B$ = FPV$ + "+2": C$ = "Save it": GoSub AO
                    A$ = "LDA": B$ = "-1,U": C$ = "Fifth digit of the FP result": GoSub AO
                    A$ = "STA": B$ = FPV$ + "+4": C$ = "Save it": GoSub AO
                Else
                    If v = &HF4 Then
                        ' We have a FP variable
                        A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AO
                        EP = EP + 1 ' consume the &HF4
                        v = Asc(Mid$(Expression$, EP, 1)) * 256 + Asc(Mid$(Expression$, EP + 1, 1))
                        SourceFPV$ = "_FPVar_" + FloatVariable$(v)
                        A$ = "LDD": B$ = SourceFPV$: C$ = "First two digits of the source FP number": GoSub AO
                        A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AO
                        A$ = "LDD": B$ = SourceFPV$ + "+2": C$ = "Third and fourth digits of source the FP number": GoSub AO
                        A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AO
                        A$ = "LDA": B$ = SourceFPV$ + "+4": C$ = "Fifth digit of the source FP number": GoSub AO
                        A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AO
                        'If we have a minus sign make this a negative of current value
                        If negval = 1 Then
                            'there is a negative sign
                            A$ = "JSR": B$ = "FPNEG": C$ = "Do FP negation": GoSub AO
                        End If
                        A$ = "JSR": B$ = FloatCMD$: C$ = "Do the FP operation": GoSub AO
                        A$ = "LDD": B$ = "-5,U": C$ = "First two digits of the FP result": GoSub AO
                        A$ = "STD": B$ = FPV$: C$ = "Save it": GoSub AO
                        A$ = "LDD": B$ = "-3,U": C$ = "Third and fourth digits of the FP result": GoSub AO
                        A$ = "STD": B$ = FPV$ + "+2": C$ = "Save it": GoSub AO
                        A$ = "LDA": B$ = "-1,U": C$ = "Fifth digit of the FP result": GoSub AO
                        A$ = "STA": B$ = FPV$ + "+4": C$ = "Save it": GoSub AO
                    Else
                        If v = &HFE Then
                            ' Might have the INT command
                            v = Asc(Mid$(Expression$, EP + 1, 1)) * 256 + Asc(Mid$(Expression$, EP + 2, 1)): EP = EP + 3 ' move past the INT command
                            If v = INT_CMD Then
                                ' Treat it like a normal unsigned integer expession
                                EP = EP + 2 ' consume the open bracket
                                Expression$ = Mid$(Expression$, EP, Len(Expression$) - EP - 3)
                                ' Check Expression$ for a variable or numeric commands, if there aren't any, then ExType=0 and NewExpression$ will be the expression without any tokenized characters
                                GoSub CheckForVariable
                                If ExType = 0 Then
                                    GoSub EvaluateNewExpression
                                    num = D: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                                    A$ = "LDD": B$ = "#" + Num$: C$ = "Since we don't have any variables or numeric commands, this is the calculated value": GoSub AO
                                Else
                                    ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression
                                End If
                                A$ = "LDU": B$ = "#FPStackspace": C$ = "Point U at the beginning of the Floating point stack": GoSub AO
                                A$ = "JSR": B$ = "INT2FP": C$ = "Convert signed 16-BIT integer in D to floating point number and store it at U, U=U+5": GoSub AO
                                A$ = "JSR": B$ = FloatCMD$: C$ = "Do the FP operation": GoSub AO
                                A$ = "LDD": B$ = "-5,U": C$ = "First two digits of the FP number": GoSub AO
                                A$ = "STD": B$ = FPV$: C$ = "Save it": GoSub AO
                                A$ = "LDD": B$ = "-3,U": C$ = "Third and fourth digits of the FP number": GoSub AO
                                A$ = "STD": B$ = FPV$ + "+2": C$ = "Save it": GoSub AO
                                A$ = "LDA": B$ = "-1,U": C$ = "Fifth digit of the FP number": GoSub AO
                                A$ = "STA": B$ = FPV$ + "+4": C$ = "Save it": GoSub AO
                            Else
                                Print "Can't figure out the type of number/expression, maybe it needs to use INT() on";: GoTo FoundError
                            End If
                        End If
                    End If
                End If
            Else
                'Two arguments
                x = Start1 + 5
                If Array(x) = &HFC And Array(x + 1) = Asc("-") Then
                    negval = 1
                    x = x + 2 ' Move past the &HFC and minus
                Else
                    negval = 0
                End If
                v = Array(x)

                Select Case v
                    Case Asc("0") To Asc("9")
                        ' This is a number value
                        A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AO
                        FPString$ = Chr$(Array(x)): x = x + 1
                        While (Array(x) >= Asc("0") And Array(x) <= Asc("9")) Or Array(x) = Asc(".")
                            FPString$ = FPString$ + Chr$(Array(x)): x = x + 1
                        Wend
                        If Array(x) <> &HF5 And Array(x + 1) <> Asc(",") Then Print "Error finding a comma on";: GoTo FoundError
                        x = x + 2 'move past the comma
                        If negval = 1 Then
                            'there is a negative sign
                            FPString$ = "-" + FPString$
                        End If
                        GoSub FPConversion ' Convert floating point string FPString$ to 5 Byte Floating point HEX value FPBytes$
                        A$ = "LDD": B$ = "#$" + Left$(FPBytes$, 4): C$ = "First two digits of the FP number " + FPString$: GoSub AO
                        A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AO
                        A$ = "LDD": B$ = "#$" + Mid$(FPBytes$, 5, 4): C$ = "Third and fourth digits of the FP number " + FPString$: GoSub AO
                        A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AO
                        A$ = "LDA": B$ = "#$" + Right$(FPBytes$, 2): C$ = "Fifth digit of the FP number " + FPString$: GoSub AO
                        A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AO
                        'If we have a minus sign make this a negative of current value
                    Case Asc(".")
                        ' This is a number value that starts with a decimal
                        A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AO
                        FPString$ = Chr$(Array(x)): x = x + 1
                        While (Array(x) >= Asc("0") And Array(x) <= Asc("9"))
                            FPString$ = FPString$ + Chr$(Array(x)): x = x + 1
                        Wend
                        If Array(x) <> &HF5 And Array(x + 1) <> Asc(",") Then Print "Error finding a comma on";: GoTo FoundError
                        x = x + 2 'move past the comma
                        If negval = 1 Then
                            'there is a negative sign
                            FPString$ = "-" + FPString$
                        End If
                        GoSub FPConversion ' Convert floating point string FPString$ to 5 Byte Floating point HEX value FPBytes$
                        A$ = "LDD": B$ = "#$" + Left$(FPBytes$, 4): C$ = "First two digits of the FP number " + FPString$: GoSub AO
                        A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AO
                        A$ = "LDD": B$ = "#$" + Mid$(FPBytes$, 5, 4): C$ = "Third and fourth digits of the FP number " + FPString$: GoSub AO
                        A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AO
                        A$ = "LDA": B$ = "#$" + Right$(FPBytes$, 2): C$ = "Fifth digit of the FP number " + FPString$: GoSub AO
                        A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AO
                    Case &HF4
                        ' We have an FP variable
                        A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AO
                        v = Array(x + 1) * 256 + Array(x + 2): x = x + 3 ' Consume the &HF4 and the variable  & the comma
                        SourceFPV$ = "_FPVar_" + FloatVariable$(v)
                        If Array(x) <> &HF5 And Array(x + 1) <> Asc(",") Then Print "Can't find comma with floating point command on";: GoTo FoundError
                        x = x + 2 'move past the comma
                        A$ = "LDD": B$ = SourceFPV$: C$ = "First two digits of the source FP number": GoSub AO
                        A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AO
                        A$ = "LDD": B$ = SourceFPV$ + "+2": C$ = "Third and fourth digits of source the FP number": GoSub AO
                        A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AO
                        A$ = "LDA": B$ = SourceFPV$ + "+4": C$ = "Fifth digit of the source FP number": GoSub AO
                        A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AO
                        'If we have a minus sign make this a negative of current value
                        If negval = 1 Then
                            'there is a negative sign
                            A$ = "JSR": B$ = "FPNEG": C$ = "Do FP negation": GoSub AO
                        End If
                    Case &HFE
                        ' Might have the INT command
                        v = Array(x + 1) * 256 + Array(x + 2): x = x + 3 ' move past the INT command
                        If v = INT_CMD Then
                            ' Found INT Command, Get the first expression
                            GoSub GetExpressionB4Comma: x = x + 2 'Handle an expression that ends with a comma skip brackets & move past it
                            ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
                            A$ = "LDU": B$ = "#FPStackspace": C$ = "Point U at the beginning of the Floating point stack": GoSub AO
                            A$ = "JSR": B$ = "INT2FP": C$ = "Convert signed 16-BIT integer in D to floating point number and store it at U, U=U+5": GoSub AO
                        Else
                            Print "Can't figure out the type of number/expression, maybe it needs to use INT() on";: GoTo FoundError
                        End If
                End Select
                If Array(x) = &HFC And Array(x + 1) = Asc("-") Then
                    negval = 1
                    x = x + 2 ' Move past the &HFC and minus
                Else
                    negval = 0
                End If
                v = Array(x)
                Select Case v
                    Case Asc("0") To Asc("9")
                        ' This is a number value
                        A$ = "LDU": B$ = "#FPStackspace+10": C$ = "Point U at the beginning of the Floating point stack+10": GoSub AO
                        FPString$ = Chr$(Array(x)): x = x + 1
                        While (Array(x) >= Asc("0") And Array(x) <= Asc("9")) Or Array(x) = Asc(".")
                            FPString$ = FPString$ + Chr$(Array(x)): x = x + 1
                        Wend
                        If Array(x) <> &HF5 And Array(x + 1) <> Asc(")") Then Print "Error finding a close bracket on";: GoTo FoundError
                        x = x + 2 'move past the close bracket
                        If negval = 1 Then
                            'there is a negative sign
                            FPString$ = "-" + FPString$
                            negval = 0
                        End If
                        GoSub FPConversion ' Convert floating point string FPString$ to 5 Byte Floating point HEX value FPBytes$
                        A$ = "LDD": B$ = "#$" + Left$(FPBytes$, 4): C$ = "First two digits of the FP number " + FPString$: GoSub AO
                        A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AO
                        A$ = "LDD": B$ = "#$" + Mid$(FPBytes$, 5, 4): C$ = "Third and fourth digits of the FP number " + FPString$: GoSub AO
                        A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AO
                        A$ = "LDA": B$ = "#$" + Right$(FPBytes$, 2): C$ = "Fifth digit of the FP number " + FPString$: GoSub AO
                        A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AO
                    Case Asc(".")
                        ' This is a number value that starts with a decimal
                        A$ = "LDU": B$ = "#FPStackspace+10": C$ = "Point U at the beginning of the Floating point stack+10": GoSub AO
                        FPString$ = Chr$(Array(x)): x = x + 1
                        While (Array(x) >= Asc("0") And Array(x) <= Asc("9"))
                            FPString$ = FPString$ + Chr$(Array(x)): x = x + 1
                        Wend
                        If Array(x) <> &HF5 And Array(x + 1) <> Asc(")") Then Print "Error finding a close bracket on";: GoTo FoundError
                        x = x + 2 'move past the close bracket
                        If negval = 1 Then
                            'there is a negative sign
                            FPString$ = "-" + FPString$
                            negval = 0
                        End If
                        GoSub FPConversion ' Convert floating point string FPString$ to 5 Byte Floating point HEX value FPBytes$
                        A$ = "LDD": B$ = "#$" + Left$(FPBytes$, 4): C$ = "First two digits of the FP number " + FPString$: GoSub AO
                        A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AO
                        A$ = "LDD": B$ = "#$" + Mid$(FPBytes$, 5, 4): C$ = "Third and fourth digits of the FP number " + FPString$: GoSub AO
                        A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AO
                        A$ = "LDA": B$ = "#$" + Right$(FPBytes$, 2): C$ = "Fifth digit of the FP number " + FPString$: GoSub AO
                        A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AO
                    Case &HF4
                        ' We have a FP variable
                        A$ = "LDU": B$ = "#FPStackspace+10": C$ = "Point U at the beginning of the Floating point stack+10": GoSub AO
                        v = Array(x + 1) * 256 + Array(x + 2): x = x + 3 ' Consume the &HF4 and the variable & the close bracket
                        SourceFPV$ = "_FPVar_" + FloatVariable$(v)
                        If Array(x) <> &HF5 And Array(x + 1) <> Asc(")") Then Print "Can't find close bracket with floating point command on";: GoTo FoundError
                        x = x + 2 'move past the comma
                        A$ = "LDD": B$ = SourceFPV$: C$ = "First two digits of the source FP number": GoSub AO
                        A$ = "STD": B$ = "-5,U": C$ = "Save it": GoSub AO
                        A$ = "LDD": B$ = SourceFPV$ + "+2": C$ = "Third and fourth digits of source the FP number": GoSub AO
                        A$ = "STD": B$ = "-3,U": C$ = "Save it": GoSub AO
                        A$ = "LDA": B$ = SourceFPV$ + "+4": C$ = "Fifth digit of the source FP number": GoSub AO
                        A$ = "STA": B$ = "-1,U": C$ = "Save it": GoSub AO
                    Case &HFE
                        ' Might have the INT command
                        v = Array(x + 1) * 256 + Array(x + 2): x = x + 3 ' move past the INT command
                        If v = INT_CMD Then
                            ' Found INT Command, Get the 2nd expression
                            GoSub GetExpressionB4EndBracket: x = x + 4 ' Get the expression that ends with a close bracket & move past it and the final close bracket
                            Expression$ = Expression$ + Chr$(&HF5) + ")" 'add the close bracket
                            ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression result with value in D
                            A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack": GoSub AO
                            A$ = "JSR": B$ = "INT2FP": C$ = "Convert signed 16-BIT integer in D to floating point number and store it at U, U=U+5": GoSub AO
                        Else
                            Print "Can't figure out the type of number/expression, maybe it needs to use INT() on";: GoTo FoundError
                        End If
                End Select
                'If we have a minus sign make this a negative of current value
                If negval = 1 Then
                    'there is a negative sign
                    A$ = "JSR": B$ = "FPNEG": C$ = "Do FP negation": GoSub AO
                End If
                A$ = "JSR": B$ = FloatCMD$: C$ = "Do the FP operation": GoSub AO
                If FloatCMD$ = "FPCMP_Tweak" Then
                    'Doing a Float Compare
                    ' returns with a LDD with the result, zero is false, #$FFFF if true
                    Select Case CompType
                        Case 1
                            'CMPGT_CMD
                            A$ = "BGT": B$ = ">": C$ = "Branch if greater than": GoSub AO
                        Case 2
                            'CMPGE_CMD
                            A$ = "BGE": B$ = ">": C$ = "Branch if greater than or Equal": GoSub AO
                        Case 3
                            'CMPEQ_CMD
                            A$ = "BEQ": B$ = ">": C$ = "Branch if Equal": GoSub AO
                        Case 4
                            'CMPNE_CMD
                            A$ = "BNE": B$ = ">": C$ = "Branch if Equal": GoSub AO
                        Case 5
                            'CMPLE_CMD
                            A$ = "BLE": B$ = ">": C$ = "Branch if less than or equal": GoSub AO
                        Case 6
                            'CMPLT_CMD
                            A$ = "BLT": B$ = ">": C$ = "Branch if less than": GoSub AO
                    End Select
                    A$ = "LDD": B$ = "#$0000": C$ = "Flag as false": GoSub AO
                    A$ = "BRA": B$ = "@FPComp": C$ = "skip ahead": GoSub AO
                    Z$ = "!"
                    A$ = "LDD": B$ = "#$FFFF": C$ = "Flag as true": GoSub AO
                    Z$ = "@FPComp": GoSub AO
                    Print #1, ' Leave space so @ works correctly
                    Return ' Go back to IF FloatingPoint Compare
                Else
                    A$ = "LDD": B$ = "-5,U": C$ = "First two digits of the FP number": GoSub AO
                    A$ = "STD": B$ = FPV$: C$ = "Save it": GoSub AO
                    A$ = "LDD": B$ = "-3,U": C$ = "Third and fourth digits of the FP number": GoSub AO
                    A$ = "STD": B$ = FPV$ + "+2": C$ = "Save it": GoSub AO
                    A$ = "LDA": B$ = "-1,U": C$ = "Fifth digit of the FP number": GoSub AO
                    A$ = "STA": B$ = FPV$ + "+4": C$ = "Save it": GoSub AO
                End If
            End If
        Else
            Print "No bracket after Floatingpoint command on";: GoTo FoundError
        End If
    Case &HF2
        'Integer numeric variable
        v = Asc(Mid$(Expression$, 2, 1)) * 256 + Asc(Right$(Expression$, 1))
        SourceVar$ = "_Var_" + NumericVariable$(v)
        A$ = "LDD": B$ = SourceVar$: C$ = "Get the signed 16 bit number in D": GoSub AO
        A$ = "LDU": B$ = "#" + FPV$: C$ = "Point U at the start of the FP variable": GoSub AO
        A$ = "JSR": B$ = "INT2FP": C$ = "Convert signed 16-BIT integer in D to floating point number and store it at U, U=U+5": GoSub AO
    Case &HF4
        'Floating point variable
        If Len(Expression$) <> 3 Then
            Print "Something is wrong with the floating point variable being assigned to "; FPV$; " on";: GoTo FoundError
        End If
        v = Asc(Mid$(Expression$, 2, 1)) * 256 + Asc(Right$(Expression$, 1))
        SourceFPV$ = "_FPVar_" + FloatVariable$(v)
        A$ = "LDD": B$ = SourceFPV$: C$ = "First two digits of the source FP number": GoSub AO
        A$ = "STD": B$ = FPV$: C$ = "Save it": GoSub AO
        A$ = "LDD": B$ = SourceFPV$ + "+2": C$ = "Third and fourth digits of source the FP number": GoSub AO
        A$ = "STD": B$ = FPV$ + "+2": C$ = "Save it": GoSub AO
        A$ = "LDA": B$ = SourceFPV$ + "+4": C$ = "Fifth digit of the source FP number": GoSub AO
        A$ = "STA": B$ = FPV$ + "+4": C$ = "Save it": GoSub AO
    Case Else
        ' A number
        If FirstChar = &HFC Then 'See if it's a negative
            ' we have a minus sign
            FPString$ = Right$(Expression$, Len(Expression$) - EP + 1)
        Else
            FPString$ = Expression$
        End If
        GoSub FPConversion ' Convert floating point string FPString$ to 5 Byte Floating point HEX value FPBytes$
        A$ = "LDD": B$ = "#$" + Left$(FPBytes$, 4): C$ = "First two digits of the FP number " + FPString$: GoSub AO
        A$ = "STD": B$ = FPV$: C$ = "Save it": GoSub AO
        A$ = "LDD": B$ = "#$" + Mid$(FPBytes$, 5, 4): C$ = "Third and fourth digits of the FP number " + FPString$: GoSub AO
        A$ = "STD": B$ = FPV$ + "+2": C$ = "Save it": GoSub AO
        A$ = "LDA": B$ = "#$" + Right$(FPBytes$, 2): C$ = "Fifth digit of the FP number " + FPString$: GoSub AO
        A$ = "STA": B$ = FPV$ + "+4": C$ = "Save it": GoSub AO
End Select
Return
' Convert numbers to Floating point format
FPConversion:
' Read input from the user
FPString$ = RTrim$(FPString$)

' It's a number, convert it
FloatNum = Val(FPString$)
If FloatNum = 0 Then
    sign = 0
    expo = 0
    mant = 0
Else
    If FloatNum < 0 Then sign = &H80 Else sign = 0
    FloatNum = Abs(FloatNum)
    expo = &H9F

    ' Normalize mantissa
    Do While FloatNum < 2147483648#
        FloatNum = FloatNum * 2
        expo = expo - 1
    Loop
    Do While FloatNum >= 4294967296#
        FloatNum = FloatNum / 2
        expo = expo + 1
    Loop

    mant = Int(FloatNum + 0.5)
End If

' Create the 5-byte floating point representation
FPbyte(0) = expo
FPbyte(1) = (Val("&H" + Left$(Hex$(mant), 2)) And &H7F) Or sign
FPbyte(2) = Val("&H" + Mid$(Hex$(mant), 3, 2))
FPbyte(3) = Val("&H" + Mid$(Hex$(mant), 5, 2))
FPbyte(4) = Val("&H" + Right$(Hex$(mant), 2))
FPBytes$ = Right$("00" + Hex$(FPbyte(0)), 2)
FPBytes$ = FPBytes$ + Right$("00" + Hex$(FPbyte(1)), 2)
FPBytes$ = FPBytes$ + Right$("00" + Hex$(FPbyte(2)), 2)
FPBytes$ = FPBytes$ + Right$("00" + Hex$(FPbyte(3)), 2)
FPBytes$ = FPBytes$ + Right$("00" + Hex$(FPbyte(4)), 2)
Return

CheckForVariable:
' Check Expression$ for a variable or numeric command, if there aren't any, then calculate the expression and use that for a LDD
ExType = 0
NewExpression$ = ""
For ii = 1 To Len(Expression$)
    ChecForVariable2:
    v = Asc(Mid$(Expression$, ii, 1))
    If v = &HF5 Or v = &HFC Then ii = ii + 1: GoTo ChecForVariable2
    If v > &HEF Then ExType = 2: Return
    NewExpression$ = NewExpression$ + Chr$(v)
Next ii
Return

'Exits with a Return
HandleStringVariable:
v = Array(x) * 256 + Array(x + 1): x = x + 2
StringVar$ = "_StrVar_" + StringVariable$(v)
If Verbose > 3 Then Print "String variable is: "; StringVar$
v = Array(x): x = x + 1
If v <> &HFC Then Print "Syntax error14, looking for = sign in";: GoTo FoundError
v = Array(x): x = x + 1
If v <> &H3D Then Print "Syntax error15, looking for = sign in";: GoTo FoundError
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$

EP = 1 'pointer in Expression$
FirstChar = Asc(Mid$(Expression$, EP, 1)): EP = EP + 1
If FirstChar = &HFE Then
    'Handle numeric/float command
    v = Asc(Mid$(Expression$, EP, 1)) * 256 + Asc(Mid$(Expression$, EP + 1, 1)): EP = EP + 4 ' Get numeric command ID, move past open bracket
    If v = FLOATTOSTR_CMD Then
        ' Convert floating point number to string
        v = Asc(Mid$(Expression$, EP, 1)): EP = EP + 1
        If v = &HF4 Then
            v = Asc(Mid$(Expression$, EP, 1)) * 256 + Asc(Mid$(Expression$, EP + 1, 1)): EP = EP + 2
            FPV$ = "_FPVar_" + FloatVariable$(v)
            A$ = "LDX": B$ = "#" + FPV$: C$ = "Point X at the beginning of the Floating point number": GoSub AO
            A$ = "LDU": B$ = "#FPStackspace+5": C$ = "Point U at the beginning of the Floating point stack+5": GoSub AO
            A$ = "JSR": B$ = "FPLOD": C$ = "LOAD FP NUMBER FROM ADDRESS X AND PUSH ONTO FP STACK": GoSub AO
            A$ = "LDY": B$ = "#" + StringVar$: C$ = "Y points at the destination string": GoSub AO
            A$ = "JSR": B$ = "FPSCIENT": C$ = "CONVERT FP NUMBER TO STRING AT ADDRESS Y IN SCIENTIFIC NOTATION": GoSub AO
        Else
            Print "Must only have one floating point variable inside the FLOATTOSTR brackets on";: GoTo FoundError
        End If
    End If
Else
    GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
    ' Copy _StrVar_PF00 to string variable
    A$ = "LDU": B$ = "#_StrVar_PF00": C$ = "U points at the start of the source string": GoSub AO
    A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AO
    A$ = "LDX": B$ = "#" + StringVar$: C$ = "X points at the length of the destination string": GoSub AO
    A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AO
    A$ = "BEQ": B$ = "Done@": C$ = "If the length of the string is zero then don't print it (Skip ahead)": GoSub AO
    Z$ = "!"
    A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AO
    A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AO
    A$ = "DECB": C$ = "Decrement the counter": GoSub AO
    A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AO
    Z$ = "Done@": GoSub AO
    Print #1, "" ' Leave a space between sections so Done@ will work for each section
End If
Return

ConsumeCommentsAndEOL:
If v = &H0D Or v = &H3A Then Return
Do Until v = &HF5 And Array(x) = &H0D 'consume any comments and the EOL
    v = Array(x): x = x + 1
Loop
v = Array(x): x = x + 1
Return

SkipUntilEOLColon:
If v = &H0D Or v = &H3A Then Return
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A) ' skip until we find an EOL or a Colon
    v = Array(x): x = x + 1
Loop
v = Array(x): x = x + 1
Return

DoELSE:
num = ElseStack(IFSP): GoSub NumAsString 'num=IFCount associated with this IFProc
If num < 10 Then Num$ = "0" + Num$
A$ = "BRA": B$ = "_IFDone_" + Num$: C$ = "Jump to END IF line": GoSub AO
Z$ = "_ELSE_" + Num$: C$ = "If result is zero = FALSE then jump to ELSE/Next line": GoSub AO
GoTo ConsumeCommentsAndEOL ' Consume any comments and the EOL and Return

DoELSEIF:
' If Process
' IFCount is the global # of IF's in the BASIC program
' IFProc is the number of IF's currently being processed
'
' Everytime we get an IF we:
' IF IFProc>0 then
' Do the evaluation and
' IF ELSELocation(IFProc) >0 then
' BRANCH TO AN ELSE_IFStack(IFProc)_IFPROC
' ELSE
' BRANCH TO AN IFDONE_IFStack(IFProc)_IFPROC
' IFProc=IFProc-1
' Return
' Otherwise if IFProc=0 then do below (We found a new IF)

' IFCount=IFCount+1
' IFProc=IFProc+1

' Push the IFCounter on the IFStack(IFProc)
' ELSELocation(IFProc) = 0
' Scan IF's until we get the END IF associated with our IF
' While looking for our END IF, if we come across another IF then we recursively hit this same IF routine
' IF we come across an ELSE then save it in array ELSELocation(IFProc)=IFProc where it is associated with the IFParse number we are doing
' IF we come across an END IF then we:
'       IFProc=IFProc-1
'       if IFProc is 0 then we found the last END IF and all the nested IFs are found and recorded
'       IF IFProc is not 0 then keep looping
'
' 2nd part of IF (Find if this IF has an ELSE to jump to or an END IF)
' Do the evaluation and
' IF ELSELocation(IFProc) >0 then
' BRANCH TO AN ELSE_IFStack(IFProc)_IFPROC
' ELSE
' BRANCH TO AN IFDONE_IFStack(IFProc)_IFPROC
' IFProc=IFProc-1
' Return


'DoELSE:
'ELSE
' Add label  ELSE_IFStack(IFProc)_IFPROC
' Return

'DoENDIF:
' Add Label  IFDONE_IFStack(IFProc)_IFPROC
' IFProc=IFProc-1


' Found an IF
DoIF:
If ENDIFCheck > 0 Then GoTo IFProcessed ' We've already processed this IF so skip processing again
FirstIFLocation = x ' This is the point where the expression starts
ElseCount = 0

NestedIF:
IFLocation = x ' This is the point where the expression starts
IfCount = IfCount + 1
IFProc = IFProc + 1
IFSTack(IFProc) = IfCount 'If Stack
ElseStack(IFProc) = IfCount ' Else Stack
ELSELocation(IFProc) = 0
ENDIFCheck = 1
FoundELSE = 0
GoSub DoesThisIFHaveAnELSE ' Check if this IF has an ELSE if so FoundELSE will = 1
ELSELocation(IFProc) = FoundELSE

x = IFLocation ' x = the point where the expression starts for the first IF

'Keep checking until we get an END IF that goes with the current IF (adding to IFProc if we find more IFs
ENDIFCheck = 0
FindElses:
If x + 4 > Filesize Then GoTo GotNestedIFs ' Keep checking unless we get to the end of the file
v = Array(x): x = x + 1 'get a byte
If v = &HFF And Array(x) * 256 + Array(x + 1) = END_CMD And Array(x + 2) = &HFF And Array(x + 3) * 256 + Array(x + 4) = IF_CMD Then
    'We found an END IF
    ENDIFCheck = ENDIFCheck - 1
    If ENDIFCheck = 0 Then GoTo GotNestedIFs ' check until we get to the END IF that is associated with our IF
End If
If v = &HFF And Array(x) * 256 + Array(x + 1) = IF_CMD Then
    If Array(x - 4) = &HFF And Array(x - 3) * 256 + Array(x - 2) = END_CMD Then
        'Found an END IF, carry on
    Else
        GoTo NestedIF ' found another real IF
    End If
End If
GoTo FindElses ' Loop until we get the END IF associated with our IF
GotNestedIFs:
ENDIFCheck = IFProc
IfCount = IfCount - IFProc ' Reset the IFCounter to what it was before we got our first IF (not nested IF)
x = FirstIFLocation ' x = the point where the expression starts for the first IF
IFProc = 0
IFSP = 0

' We get here after the IF and nested IFs are processed or a nested IF has just been found
IFProcessed:
IFProc = IFProc + 1
IfCount = IfCount + 1
IFSP = IFSP + 1
ElseStack(IFSP) = IfCount

' We are inside a nested IF/THEN/ELSE we've already processed
' x points just past the IF        , ' This is the point where the expression starts
CheckIfTrue$ = ""
SaveIFX = x ' Save this position, just in case we have floating point compares to test for
v = 0
While v <> &HFF ' Keep copying until we get the next command which should be a THEN
    v = Array(x): x = x + 1
    CheckIfTrue$ = CheckIfTrue$ + Chr$(v)
Wend
'(x), Hex$(Array(x)), Hex$(Array(x + 1)), Hex$(Array(x + 2)), Hex$(Array(x + 3))
v = Array(x) * 256 + Array(x + 1): x = x + 2
If v <> THEN_CMD Then Print "Need a THEN after the IF statement on";: GoTo FoundError
CheckIfTrue$ = Left$(CheckIfTrue$, Len(CheckIfTrue$) - 1) ' remove the &HFF on the end

' Add code to handle
'CMPGT(FP_A,10.432) THEN (do this if >)
'CMPGE(FP_A,10.432) THEN (do this if >=)
'CMPEQ(FP_A,10.432) THEN (do this if = )
'CMPLE(FP_A,10.432) THEN (do this if <=)
'CMPLT(FP_A,10.432) THEN (do this if <)

If Left$(CheckIfTrue$, 1) <> Chr$(&HFE) Then GoTo NotFloatComp 'Skip and handle normal IF conditions
' Make sure it's a Floating point compare
v = Asc(Mid$(CheckIfTrue$, 2, 1)) * 256 + Asc(Mid$(CheckIfTrue$, 3, 1))
Select Case v
    Case CMPGT_CMD: GoTo DoFPCompare
    Case CMPGE_CMD: GoTo DoFPCompare
    Case CMPEQ_CMD: GoTo DoFPCompare
    Case CMPNE_CMD: GoTo DoFPCompare
    Case CMPLE_CMD: GoTo DoFPCompare
    Case CMPLT_CMD: GoTo DoFPCompare
    Case Else: GoTo NotFloatComp
End Select
DoFPCompare:
'If we get here then we are doing a floating Point compare
SaveX = x ' save the current position of x
Start1 = SaveIFX ' x points just after the IF statement
x = Start1
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
EP = 2 'pointer in Expression$
GoSub CheckFloatIF ' Go handle Float Compares returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
x = SaveX ' Restore x
GoTo CheckAfterFlotComp
NotFloatComp:
GoSub GoCheckIfTrue ' This parses CheckIfTrue$, gets it ready to be evaluated in the string NewString$
GoSub EvaluateNewString ' This Evaluates NewString$ and returns with a LDD with the result, zero is false so it will do an ELSE, if there is one otherwise do what is after the THEN
CheckAfterFlotComp:
num = IFSTack(IFProc): GoSub NumAsString 'num=IFCount associated with this IFProc
If num < 10 Then Num$ = "0" + Num$
If ELSELocation(IFProc) > 0 Then
    'There is an ELSE to jump
    A$ = "BEQ": B$ = "_ELSE_" + Num$: C$ = "If result is zero = FALSE then jump to ELSE/Next line": GoSub AO
Else
    ' No Else then jump to the END IF
    A$ = "BEQ": B$ = "_IFDone_" + Num$: C$ = "If result is zero = FALSE then jump to END IF line": GoSub AO
End If
'x = x - 2: v = Array(x)
'GoTo ConsumeCommentsAndEOL ' Consume any comments and the EOL and Return
Return

' Check if this IF has an associated ELSE
DoesThisIFHaveAnELSE:
If x + 3 > Filesize Then GoTo GotNestedIFs ' Keep checking unless we get to the end of the file
v = Array(x): x = x + 1 'get a byte
If v = &HFF And Array(x) * 256 + Array(x + 1) = IF_CMD Then
    If Array(x - 4) = &HFF And Array(x - 3) * 256 + Array(x - 2) = END_CMD Then
        'Found And End IF
    Else
        ENDIFCheck = ENDIFCheck + 1 ' found a real IF
    End If
End If
If v = &HFF And Array(x) * 256 + Array(x + 1) = ELSE_CMD Then
    'We found an ELSE command for the current IF
    If ENDIFCheck = 1 Then
        FoundELSE = 1
        Return
    End If
End If
If v = &HFF And Array(x) * 256 + Array(x + 1) = END_CMD And Array(x + 2) = &HFF And Array(x + 3) * 256 + Array(x + 4) = IF_CMD Then
    'We found an END IF
    ENDIFCheck = ENDIFCheck - 1
    If ENDIFCheck = 0 Then Return ' check until we get to the END IF that is associated with our IF
End If
GoTo DoesThisIFHaveAnELSE

' Format the characters between the IF and the THEN as:
' ex.  IF ((A*(4+B)=2 AND C=3) OR B=1 OR D=1) AND Z=2 THEN as
' CheckIfTrue$="((A*(4+B)=2 AND C=3) OR B=1 OR D=1) AND Z=2"
' GOSUB GoCheckIfTrue

' Evaluate CheckIfTrue$ and C flag will be zero if False or 1 if True
GoCheckIfTrue:
' Deal with brackets
' Need to turn    CheckIfTrue$="((A*(4+B)=2 AND C=3) OR B=1 OR D=1) AND Z=2"
'Into:   ((EV=2 AND C=3) OR B=1 OR D=1) AND Z=2
'          ((S=EV AND C=3) OR B=1 OR D=1) AND Z=2
'          ((S=EV AND C=3) OR B=1 OR D=1) AND Z=2
'          ((S0 AND EV=3) OR B=1 OR D=1) AND Z=2
'          ((S0 AND S=EV) OR B=1 OR D=1) AND Z=2   ...

' Make sure CheckIfTrue$ has an operator, if not add <>0 to the end of CheckIfTrue$
FoundOperator = 0
I = 1
While I < Len(CheckIfTrue$)
    v = Asc(Mid$(CheckIfTrue$, I, 1)): I = I + 1
    If v > &HEF Then
        'We have a Token
        Select Case v
            Case &HF0, &HF1: ' Found a Numeric or String array
                I = I + 3
            Case &HF2, &HF3: ' Found a numeric or string variable
                I = I + 2
            Case &HF5 ' Found a special character
                I = I + 1
            Case &HFB: ' Found a DEF FN Function
                I = I + 2
            Case &HFC: ' Found an Operator
                ii = Asc(Mid$(CheckIfTrue$, I, 1))
                If ii > &H0F And ii < &H16 Then FoundOperator = 1 'we found an operator to deal with
                If ii > &H3B And ii < &H3F Then FoundOperator = 1 'we found an operator to deal with
                I = I + 1
            Case &HFD, &HFE, &HFF: 'Found String,Numeric or General command
                I = I + 2
        End Select
    End If
Wend
If FoundOperator = 0 Then
    ' No Operator so add "(" at the beginning and ")<>0" to the end
    CheckIfTrue$ = Chr$(&HF5) + Chr$(&H28) + CheckIfTrue$ + Chr$(&HF5) + Chr$(&H29) + Chr$(&HFC) + Chr$(&H3C) + Chr$(&HFC) + Chr$(&H3E) + Chr$(&H30)
End If

EC = 1 'Expression Counter
BracketCount = 0
NewString$ = ""
CheckIfTrue$ = CheckIfTrue$ + Chr$(&HFC) + Chr$(&H3D) + "   " ' Add fake last expression of = so it ends with something
I = 1
Temp$ = ""
bC$ = ""
ExpressionFound$(EC) = ""

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

Start = I
While I < Len(CheckIfTrue$)
    v = Asc(Mid$(CheckIfTrue$, I, 1)): I = I + 1
    'Keep track of brackets
    If v > &HEF Then
        'We have a Token
        Select Case v
            Case &HF0, &HF1: ' Found a Numeric or String array
                I = I + 3
            Case &HF2, &HF3: ' Found a numeric or string variable
                I = I + 2
            Case &HF5 ' Found a special character
                If Asc(Mid$(CheckIfTrue$, I, 1)) = Asc("(") Then BracketCount = BracketCount + 1
                If Asc(Mid$(CheckIfTrue$, I, 1)) = Asc(")") Then BracketCount = BracketCount - 1
                I = I + 1
            Case &HFB: ' Found a DEF FN Function
                I = I + 2
            Case &HFC: ' Found an Operator
                v1 = Asc(Mid$(CheckIfTrue$, I, 1))
                If v1 = &H10 Or v1 = &H11 Or v1 = &H13 Or v1 = &H14 Or v1 = &H3C Or v1 = &H3D Or v1 = &H3E Then
                    'we found an operator to deal with
                    GoSub AddNewExpression
                    ' Everything is now copied properly in Newstring$ and ExpressionFound$()
                    Op1 = Asc(Mid$(CheckIfTrue$, I, 1)): I = I + 1 ' Get the first operator, move index past the first operator
                    If Asc(Mid$(CheckIfTrue$, I, 1)) = &HFC Then ' Check for another operator
                        ' We have two operators, so let's combine them
                        Op2 = Asc(Mid$(CheckIfTrue$, I + 1, 1)): I = I + 2 ' get the 2nd operator and move the index past the 2nd operator
                        If Op2 = &H2D Then
                            ' it's a negative on the right side
                            I = I - 2
                            NewOp = Op1
                        End If
                        If Op1 = &H3E And Op2 = &H3D Then NewOp = &H62 '>=
                        If Op1 = &H3D And Op2 = &H3E Then NewOp = &H62 '>=
                        If Op1 = &H3C And Op2 = &H3E Then NewOp = &H60 '<>
                        If Op1 = &H3E And Op2 = &H3C Then NewOp = &H60 '<>
                        If Op1 = &H3C And Op2 = &H3D Then NewOp = &H61 '<=
                        If Op1 = &H3D And Op2 = &H3C Then NewOp = &H61 '<=
                    Else
                        NewOp = Op1
                    End If
                    NewString$ = NewString$ + Chr$(&HFC) + Chr$(NewOp)
                    Start = I
                End If
            Case &HFD, &HFE, &HFF: 'Found String,Numeric or General command
                I = I + 2
        End Select
    End If
Wend
'v = Asc(Mid$(CheckIfTrue$, i, 1)): i = i + 1
'GoSub AddNewExpression ' Add the end of the CheckIfTrue$ to NewString & Expression()
NewString$ = Left$(NewString$, Len(NewString$) - 2) 'remove fake $FC3D
Return

'We found an operator or end of CheckIfTrue$
AddNewExpression:
Select Case BracketCount
    Case 0:
        ' Copy everything from Start to i as is to ExpressionFound$()
        ExpressionFound$(EC) = ""
        NewString$ = NewString$ + Chr$(0) + Chr$(EC) ' Add the expression token to NewString$
        For ii = Start To I - 2 ' -2 because we don't want to include the operator
            ExpressionFound$(EC) = ExpressionFound$(EC) + Mid$(CheckIfTrue$, ii, 1)
        Next ii
        EC = EC + 1
    Case Is > 0:
        ' We have more open brackets than close brackets
        BC = BracketCount
        While BracketCount > 0
            NewString$ = NewString$ + "(": BracketCount = BracketCount - 1
        Wend
        ExpressionFound$(EC) = ""
        NewString$ = NewString$ + Chr$(0) + Chr$(EC) ' Add the expression token to NewString$
        For ii = Start + (BC * 2) To I - 2 ' -2 because we don't want to include the operator
            ExpressionFound$(EC) = ExpressionFound$(EC) + Mid$(CheckIfTrue$, ii, 1)
        Next ii
        EC = EC + 1
    Case Is < 0:
        ' We have more close brackets than open brackets
        BC = BracketCount
        ExpressionFound$(EC) = ""
        NewString$ = NewString$ + Chr$(0) + Chr$(EC) ' Add the expression token to NewString$
        For ii = Start To I + (BC * 2) - 2 ' -2 because we don't want to include the operator
            ExpressionFound$(EC) = ExpressionFound$(EC) + Mid$(CheckIfTrue$, ii, 1)
        Next ii
        EC = EC + 1
        While BracketCount < 0
            NewString$ = NewString$ + ")": BracketCount = BracketCount + 1
        Wend
End Select
Return

' This Evaluates NewString$ and returns with a LDD with the result, -1 is false so it will do an ELSE, if there is one otherwise do what is after the THEN
EvaluateNewString:
valueStackTop = 0
operatorStackTop = 0
Eval = 1
HandledV:
Do While Eval <= Len(NewString$)
    v = Asc(Mid$(NewString$, Eval, 1)): Eval = Eval + 1
    If v = 0 Then
        ' Compare Operand found
        v = Asc(Mid$(NewString$, Eval, 1)): Eval = Eval + 1 ' v is the pointer to the stored expression
        valueStackTop = valueStackTop + 1
        valueStack(valueStackTop) = v
        GoTo HandledV
    End If
    If v = &HFC Then
        ' Found an operator
        v = Asc(Mid$(NewString$, Eval, 1)): Eval = Eval + 1 ' v is the operator type
        Do While operatorStackTop > 0
            operator = operatorStack(operatorStackTop)
            GoSub GetOperatorPrecedence ' Input is operator, output OperatorPrecedence, depending on the value of "OR"=1, "AND"=2, "=<>"=3 return with value in OperatorPrecedence
            ' with # from 0 to 3 with 0 being any other operator
            GoSub GetTokenPrecedence ' Input v output TokenPrecedence, depending on the value of "OR"=1, "AND"=2, "=<>"=3
            ' 0 being any other Token
            If OperatorPrecedence >= TokenPrecedence Then
                vT = v ' v might be changed when processingTopOperator, so back it up
                GoSub ProcessTopOperator
                v = vT ' Restore v
            Else
                Exit Do
            End If
        Loop
        operatorStackTop = operatorStackTop + 1
        operatorStack(operatorStackTop) = v ' Save the type of operation to do
        GoTo HandledV
    End If
    If v = &H28 Or v = &H29 Then ' Is it an open or closed bracket?
        'Yes deal with them
        If v = Asc("(") Then
            'Found an Open Bracket
            operatorStackTop = operatorStackTop + 1
            operatorStack(operatorStackTop) = Asc("(")
        Else
            'Found a Closed Bracket
            Do While operatorStack(operatorStackTop) <> Asc("(")
                GoSub ProcessTopOperator
            Loop
            operatorStackTop = operatorStackTop - 1
        End If
    End If
Loop

Do While operatorStackTop > 0
    GoSub ProcessTopOperator
Loop
A$ = "LDD": B$ = ",S++": C$ = "Set the condition codes and fix the stack": GoSub AO
Return ' All done

ProcessTopOperator:
rightOperand = valueStack(valueStackTop)
valueStackTop = valueStackTop - 1
If rightOperand = 0 Then ' it's time to compare the value of the stack
    A$ = "PULS": B$ = "D": C$ = "Get the Right value off the stack": GoSub AO
    A$ = "STD": B$ = "_NumVar_IFRight": C$ = "Save the Right Operand value": GoSub AO
Else
    Expression$ = ExpressionFound$(rightOperand)
    FoundStringR = 0
    If Asc(Mid$(Expression$, 1, 1)) = &HF1 Then FoundStringR = 1 'First token a String Array?, if so it's a string expression
    If Asc(Mid$(Expression$, 1, 1)) = &HF3 Then FoundStringR = 1 'First token a String variable?, if so it's a string expression
    If Asc(Mid$(Expression$, 1, 1)) = &HFD Then FoundStringR = 1 'First token a String command?, if so it's a string expression
    If Asc(Mid$(Expression$, 1, 1)) = &HF5 Then
        If Asc(Mid$(Expression$, 2, 1)) = &H22 Then FoundStringR = 1 'First token a Quote so it's a String to compare with
    End If
    If FoundStringR = 1 Then
        ' Deal with a string expression
        GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
        ' Copy String from _StrVar_PF00 to _StrVar_IFRight
        Print #1, "; copying String from _StrVar_PF00 to _StrVar_IFRight"
        A$ = "LDU": B$ = "#_StrVar_PF00": C$ = "U points at the start of the source string": GoSub AO
        A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AO
        A$ = "LDX": B$ = "#_StrVar_IFRight": C$ = "X points at the length of the destination string": GoSub AO
        A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AO
        A$ = "BEQ": B$ = "Done@": C$ = "If B=0 then no need to copy the string": GoSub AO
        Z$ = "!"
        A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AO
        A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AO
        A$ = "DECB": C$ = "Decrement the counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AO
        Print #1, "Done@": Print #1,
        Print #1, "" ' Leave a space between sections so Done@ will work for each section
    Else
        'Handle Numeric Expression
        ExType = 0: GoSub ParseNumericExpression ' Parse the Numeric Expression, value will end up in D
        '  A$ = "PSHS": B$ = "D": C$ = "Save the Right Operand value on the stack": GoSub AO
        A$ = "STD": B$ = "_NumVar_IFRight": C$ = "Save the Right Operand value": GoSub AO
    End If
End If

leftOperand = valueStack(valueStackTop)
valueStackTop = valueStackTop - 1

If leftOperand = 0 Then ' it's time to compare the value of the stack
    A$ = "LDD": B$ = ",S++": C$ = "Get the Left value in D, fix the stack": GoSub AO
Else
    Expression$ = ExpressionFound$(leftOperand)
    FoundStringL = 0
    If Len(Expression$) = 0 Then
        If operatorStack(operatorStackTop) = 13 Then ' "NOT"
            A$ = "LDD": B$ = "_NumVar_IFRight": GoSub AO
            A$ = "COMA": C$ = "Flip the bits": GoSub AO
            A$ = "COMB": C$ = "Flip the bits": GoSub AO
            A$ = "PSHS": B$ = "D": C$ = "Save the NOT version on the stack": GoSub AO
            GoTo SkipLeft
        Else
            Print "Length of Left Operand is zero, something is wrong doing the IF on";: GoTo FoundError
        End If
    End If
    If Asc(Mid$(Expression$, 1, 1)) = &HF1 Then FoundStringL = 1 'First token a String Array?, if so it's a string expression
    If Asc(Mid$(Expression$, 1, 1)) = &HF3 Then FoundStringL = 1 'First token a String variable?, if so it's a string expression
    If Asc(Mid$(Expression$, 1, 1)) = &HFD Then FoundStringL = 1 'First token a String command?, if so it's a string expression
    If Asc(Mid$(Expression$, 1, 1)) = &HF5 Then
        If Asc(Mid$(Expression$, 2, 1)) = &H22 Then FoundStringL = 1 'First token a Quote so it's a String to compare with
    End If
    If FoundStringL <> FoundStringR Then Print "Error, the comparison of the IF values is comparing a string with a numeric on";: GoTo FoundError
    If FoundStringL = 1 Then
        ' Deal with a string expression
        GoSub ParseStringExpression ' Parse the String Expression, value will end up in _StrVar_PF00
        ' Copy String from _StrVar_PF00 to _StrVar_IFRight
        Print #1, "; String _StrVar_PF00 has the left value"
    Else
        'Handle Numeric Expression
        ExType = 0: GoSub ParseNumericExpression ' D now has the LeftOperand value
    End If
End If

If operatorStack(operatorStackTop) = &H10 Then ' "AND"
    result = leftOperand And rightOperand
    A$ = "ANDA": B$ = "_NumVar_IFRight": C$ = "A=A AND first byte off the Stack": GoSub AO
    A$ = "ANDB": B$ = "_NumVar_IFRight+1": C$ = "D now = D AND the stack": GoSub AO
    A$ = "PSHS": B$ = "D": C$ = "Save the Result on the stack": GoSub AO
End If
If operatorStack(operatorStackTop) = &H11 Then ' "OR"
    result = leftOperand Or rightOperand
    A$ = "ORA": B$ = "_NumVar_IFRight": C$ = "A=A OR first byte off the Stack": GoSub AO
    A$ = "ORB": B$ = "_NumVar_IFRight+1": C$ = "D now = D OR the stack": GoSub AO
    A$ = "PSHS": B$ = "D": C$ = "Save the Result on the stack": GoSub AO
End If

If operatorStack(operatorStackTop) = &H13 Then ' "XOR"
    result = leftOperand Or rightOperand
    A$ = "EORA": B$ = "_NumVar_IFRight": C$ = "A=A XOR first byte off the Stack": GoSub AO
    A$ = "EORB": B$ = "_NumVar_IFRight+1": C$ = "D now = D XOR the stack": GoSub AO
    A$ = "PSHS": B$ = "D": C$ = "Save the Result on the stack": GoSub AO
End If

If FoundStringL + FoundStringR = 0 Then
    'We are dealing with numeric expressions that is already in D and the Stack
    If (operatorStack(operatorStackTop) > &H3B And operatorStack(operatorStackTop) < &H3F) Or (operatorStack(operatorStackTop) > &H5F And operatorStack(operatorStackTop) < &H63) Then
        A$ = "LDX": B$ = "#$FFFF": C$ = "Default is Result = -1, True": GoSub AO
        '     A$ = "CMPD": B$ = ",S++": C$ = "Compare D with the value on the stack, fix the stack": GoSub AO
        A$ = "CMPD": B$ = "_NumVar_IFRight": C$ = "Compare D with the value on the right": GoSub AO
    End If
    If operatorStack(operatorStackTop) = &H3E Then ' ">" ' BGT
        A$ = "BGT": B$ = ">": C$ = "If Greater than, then skip ahead": GoSub AO
    End If
    If operatorStack(operatorStackTop) = &H3D Then ' "=" ' BEQ
        A$ = "BEQ": B$ = ">": C$ = "If They are Equal then skip ahead": GoSub AO
    End If
    If operatorStack(operatorStackTop) = &H3C Then ' "<" ' BLT
        A$ = "BLT": B$ = ">": C$ = "If Less than, then skip ahead": GoSub AO
    End If
    If operatorStack(operatorStackTop) = &H60 Then ' "<>" ' BNE
        A$ = "BNE": B$ = ">": C$ = "If They are Not Equal then skip ahead": GoSub AO
    End If
    If operatorStack(operatorStackTop) = &H61 Then ' "<=" ' BLE
        A$ = "BLE": B$ = ">": C$ = "If They are Less Than or Equal then skip ahead": GoSub AO
    End If
    If operatorStack(operatorStackTop) = &H62 Then ' ">=" ' BGE
        A$ = "BGE": B$ = ">": C$ = "If They are Greater than or Equal then skip ahead": GoSub AO
    End If
    ' PSHS    result
    If (operatorStack(operatorStackTop) > &H3B And operatorStack(operatorStackTop) < &H3F) Or (operatorStack(operatorStackTop) > &H5F And operatorStack(operatorStackTop) < &H63) Then
        A$ = "LDX": B$ = "#$0000": C$ = "Make the Result zero, False": GoSub AO
        Z$ = "!"
        A$ = "PSHS": B$ = "X": C$ = "Save the result on the stack": GoSub AO
    End If
Else
    '                         1   2   3   4   5    6    7    8   9   10  11 12  13  14                                   21   22   23
    ' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR   Extended for Evaluation code "<>","<=",">="

    '                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
    ' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

    If (operatorStack(operatorStackTop) > &H3B And operatorStack(operatorStackTop) < &H3F) Or (operatorStack(operatorStackTop) > &H5F And operatorStack(operatorStackTop) < &H63) Then
        ' We are comparing string values
        '   D=U= _StrVar_PF00         copare with X= _StrVar_IFRight
        A$ = "LDU": B$ = "#_StrVar_PF00": C$ = "U = the Left String": GoSub AO
        A$ = "LDX": B$ = "#_StrVar_IFRight": C$ = "X = the Right String": GoSub AO
        If operatorStack(operatorStackTop) = &H3E Then ' ">" ' BGT
            Print #1, "; Checking if Strings are >"
            A$ = "LDB": B$ = ",U": C$ = "Get the length of the left side": GoSub AO
            A$ = "ADDB": B$ = ",X": C$ = "Add the length of the right side": GoSub AO
            A$ = "BEQ": B$ = "@False": C$ = "If they are both empty they are the same, return with FALSE": GoSub AO
            A$ = "LDB": B$ = ",X": C$ = "Get the length of the Right side": GoSub AO
            A$ = "BEQ": B$ = "@True": C$ = "If only the right side is empty, then the left side is > so return with True": GoSub AO
            A$ = "LDB": B$ = ",U+": C$ = "Get the length of the left side, move pointer to the first byte of the string": GoSub AO
            A$ = "BEQ": B$ = "@False": C$ = "If only the left is empty it is not > so return with FALSE": GoSub AO
            ' We now know the size of both the left of the right > 0
            A$ = "CMPB": B$ = ",X+": C$ = "Compare the left size with the length of the right side, move pointer to the first byte of the string": GoSub AO
            A$ = "BLS": B$ = "@BLowest": C$ = "Use B size for compare": GoSub AO
            A$ = "LDB": B$ = "-1,X": C$ = "Use the size of the right side as the compare as it has less digits": GoSub AO
            Z$ = "@BLowest"
            A$ = "TFR": B$ = "D,Y": C$ = "Backup B (string size to check) in Y": GoSub AO
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AO
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AO
            A$ = "BLO": B$ = "@False": C$ = "If Left is < the right then it's FALSE": GoSub AO
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AO
            ' If we get here then the left are all Higher or the same, so check again and see if they are all the same and exit False if they are the same
            A$ = "LDU": B$ = "#_StrVar_PF00" + "+1": C$ = "U = the Left String": GoSub AO
            A$ = "LDX": B$ = "#_StrVar_IFRight" + "+1": C$ = "X = the Right String": GoSub AO
            A$ = "TFR": B$ = "Y,D": C$ = "Restore B (string size to check)": GoSub AO
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AO
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AO
            A$ = "BHI": B$ = "@True": C$ = "If Left is > the right then return TRUE": GoSub AO
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AO
            Print #1, "; If we get here then the strings are the same this far, so TRUE if Left is longer then the Right"
            A$ = "LDB": B$ = "_StrVar_PF00": C$ = "B= the Length of the Left String": GoSub AO
            A$ = "CMPB": B$ = "_StrVar_IFRight": C$ = "Compare it with the length of the Right String": GoSub AO
            A$ = "BLS": B$ = "@False": C$ = "If left is lower or the same size as the right then return FALSE": GoSub AO
        End If
        If operatorStack(operatorStackTop) = &H3D Then ' "="   -  If the coparison is an EQUALS then we can quickly check the length of both strings
            Print #1, "; Checking if Strings are ="
            A$ = "LDB": B$ = ",U+": C$ = "Get the length of the string, move pointer to the first byte of the string": GoSub AO
            A$ = "CMPB": B$ = ",X+": C$ = "Are they the same length? , move pointer to the first byte of the string": GoSub AO
            A$ = "BNE": B$ = "@False": C$ = "If They are Not Equal then return a false": GoSub AO
            Print #1, "; If we get here then the length is the same, check if all characters are the same"
            A$ = "TSTB": C$ = "Check if the strings are empty": GoSub AO
            A$ = "BEQ": B$ = "@True": C$ = "If they are both empty they are the same": GoSub AO
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AO
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the byte of the right string, move pointer forward": GoSub AO
            A$ = "BNE": B$ = "@False": C$ = "If They are Not Equal then return a false": GoSub AO
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AO
            Print #1, "; If we get here then the strings are the same"
        End If
        If operatorStack(operatorStackTop) = &H3C Then ' "<" ' BLT
            Print #1, "; Checking if Strings are <"
            A$ = "LDB": B$ = ",U": C$ = "Get the length of the left side": GoSub AO
            A$ = "ADDB": B$ = ",X": C$ = "Add the length of the right side": GoSub AO
            A$ = "BEQ": B$ = "@False": C$ = "If they are both empty they are the same, which is not < so return with FALSE": GoSub AO
            A$ = "LDB": B$ = ",X": C$ = "Get the length of the Right side": GoSub AO
            A$ = "BEQ": B$ = "@False": C$ = "If only the right side is empty, then the left side is > so return with FALSE": GoSub AO
            A$ = "LDB": B$ = ",U+": C$ = "Get the length of the left side, move pointer to the first byte of the string": GoSub AO
            A$ = "BEQ": B$ = "@True": C$ = "If only the left is empty it is < so return with TRUE": GoSub AO
            ' We now know the size of both the left of the right > 0
            A$ = "CMPB": B$ = ",X+": C$ = "Compare the left size with the length of the right side, move pointer to the first byte of the string": GoSub AO
            A$ = "BLS": B$ = "@BLowest": C$ = "Use B size for compare": GoSub AO
            A$ = "LDB": B$ = "-1,X": C$ = "Use the size of the right side as the compare as it has less digits": GoSub AO
            Z$ = "@BLowest"
            A$ = "TFR": B$ = "D,Y": C$ = "Backup B (string size to check) in Y": GoSub AO
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AO
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AO
            A$ = "BHI": B$ = "@False": C$ = "If Left is > the right then it's FALSE": GoSub AO
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AO
            ' If we get here then the right are all Higher or the same as the left, so check again and see if they are all the same and exit False if they are the same
            A$ = "LDU": B$ = "#_StrVar_PF00" + "+1": C$ = "U = the Left String": GoSub AO
            A$ = "LDX": B$ = "#_StrVar_IFRight" + "+1": C$ = "X = the Right String": GoSub AO
            A$ = "TFR": B$ = "Y,D": C$ = "Restore B (string size to check)": GoSub AO
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AO
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AO
            A$ = "BLO": B$ = "@True": C$ = "If Left is < the right then return TRUE": GoSub AO
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AO
            Print #1, "; If we get here then the strings are the same this far, so TRUE if Left is shorter then the Right"
            A$ = "LDB": B$ = "_StrVar_PF00": C$ = "B= the Length of the Left String": GoSub AO
            A$ = "CMPB": B$ = "_StrVar_IFRight": C$ = "Compare it with the length of the Right String": GoSub AO
            A$ = "BHS": B$ = "@False": C$ = "If left is higher or the same size as the right then return FALSE": GoSub AO
        End If
        If operatorStack(operatorStackTop) = &H60 Then ' "<>" ' BNE
            Print #1, "; Checking if Strings are <>"
            A$ = "LDB": B$ = ",U+": C$ = "Get the length of the string, move pointer to the first byte of the string": GoSub AO
            A$ = "CMPB": B$ = ",X+": C$ = "Are they the same length? , move pointer to the first byte of the string": GoSub AO
            A$ = "BNE": B$ = "@True": C$ = "If They are Not Equal then return True": GoSub AO
            Print #1, "; If we get here then the length is the same, check if all characters are the same"
            A$ = "TSTB": C$ = "Check if the strings are empty": GoSub AO
            A$ = "BEQ": B$ = "@False": C$ = "If they are both empty they are the same, return with FALSE": GoSub AO
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AO
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the byte of the right string, move pointer forward": GoSub AO
            A$ = "BNE": B$ = "@True": C$ = "If They are Not Equal then return True": GoSub AO
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AO
            Print #1, "; If we get here then the strings are the same"
            A$ = "BRA": B$ = "@False": C$ = "If They are Equal then return a False": GoSub AO
        End If
        If operatorStack(operatorStackTop) = &H61 Then ' "<=" ' BLE
            Print #1, "; Checking if Strings are <="
            A$ = "LDB": B$ = ",U": C$ = "Get the length of the left side": GoSub AO
            A$ = "ADDB": B$ = ",X": C$ = "Add the length of the right side": GoSub AO
            A$ = "BEQ": B$ = "@True": C$ = "If they are both empty they are the same, return with TRUE": GoSub AO
            A$ = "LDB": B$ = ",X": C$ = "Get the length of the Right side": GoSub AO
            A$ = "BEQ": B$ = "@False": C$ = "If only the right side is empty, then the left side is > so return with FALSE": GoSub AO
            A$ = "LDB": B$ = ",U+": C$ = "Get the length of the left side, move pointer to the first byte of the string": GoSub AO
            A$ = "BEQ": B$ = "@True": C$ = "If only the left is empty it is < so return with TRUE": GoSub AO
            ' We now know the size of both the left of the right > 0
            A$ = "CMPB": B$ = ",X+": C$ = "Compare the left size with the length of the right side, move pointer to the first byte of the string": GoSub AO
            A$ = "BLS": B$ = "@BLowest": C$ = "Use B size for compare": GoSub AO
            A$ = "LDB": B$ = "-1,X": C$ = "Use the size of the right side as the compare as it has less digits": GoSub AO
            Z$ = "@BLowest"
            A$ = "TFR": B$ = "D,Y": C$ = "Backup B (string size to check) in Y": GoSub AO
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AO
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AO
            A$ = "BHI": B$ = "@False": C$ = "If Left is > the right then it's FALSE": GoSub AO
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AO
            ' If we get here then the right are all Higher or the same as the left, so check again and see if they are all the same and exit False if they are the same
            A$ = "LDU": B$ = "#_StrVar_PF00" + "+1": C$ = "U = the Left String": GoSub AO
            A$ = "LDX": B$ = "#_StrVar_IFRight" + "+1": C$ = "X = the Right String": GoSub AO
            A$ = "TFR": B$ = "Y,D": C$ = "Restore B (string size to check)": GoSub AO
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AO
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AO
            A$ = "BLO": B$ = "@True": C$ = "If Left is < the right then return TRUE": GoSub AO
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AO
            Print #1, "; If we get here then the strings are the same this far, so TRUE if Left is shorter then the Right"
            A$ = "LDB": B$ = "_StrVar_PF00": C$ = "B= the Length of the Left String": GoSub AO
            A$ = "CMPB": B$ = "_StrVar_IFRight": C$ = "Compare it with the length of the Right String": GoSub AO
            A$ = "BHI": B$ = "@False": C$ = "If left is higher or the same size as the right then return FALSE": GoSub AO
        End If
        If operatorStack(operatorStackTop) = &H62 Then ' ">=" ' BGE
            Print #1, "; Checking if Strings are >="
            A$ = "LDB": B$ = ",U": C$ = "Get the length of the left side": GoSub AO
            A$ = "ADDB": B$ = ",X": C$ = "Add the length of the right side": GoSub AO
            A$ = "BEQ": B$ = "@True": C$ = "If they are both empty they are the same, return with TRUE": GoSub AO
            A$ = "LDB": B$ = ",X": C$ = "Get the length of the Right side": GoSub AO
            A$ = "BEQ": B$ = "@True": C$ = "If only the right side is empty, then the left side is > so return with True": GoSub AO
            A$ = "LDB": B$ = ",U+": C$ = "Get the length of the left side, move pointer to the first byte of the string": GoSub AO
            A$ = "BEQ": B$ = "@False": C$ = "If only the left is empty it is not > so return with FALSE": GoSub AO
            ' We now know the size of both the left of the right > 0
            A$ = "CMPB": B$ = ",X+": C$ = "Compare the left size with the length of the right side, move pointer to the first byte of the string": GoSub AO
            A$ = "BLS": B$ = "@BLowest": C$ = "Use B size for compare": GoSub AO
            A$ = "LDB": B$ = "-1,X": C$ = "Use the size of the right side as the compare as it has less digits": GoSub AO
            Z$ = "@BLowest"
            A$ = "TFR": B$ = "D,Y": C$ = "Backup B (string size to check) in Y": GoSub AO
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AO
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AO
            A$ = "BLO": B$ = "@False": C$ = "If Left is < the right then it's FALSE": GoSub AO
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AO
            ' If we get here then the left are all Higher or the same, so check again and see if they are all the same and exit False if they are the same
            A$ = "LDU": B$ = "#_StrVar_PF00" + "+1": C$ = "U = the Left String": GoSub AO
            A$ = "LDX": B$ = "#_StrVar_IFRight" + "+1": C$ = "X = the Right String": GoSub AO
            A$ = "TFR": B$ = "Y,D": C$ = "Restore B (string size to check)": GoSub AO
            Z$ = "!"
            A$ = "LDA": B$ = ",U+": C$ = "Get a byte of the left string, move pointer forward": GoSub AO
            A$ = "CMPA": B$ = ",X+": C$ = "Compare it with the same byte of the right side, moe the pointer forward": GoSub AO
            A$ = "BHI": B$ = "@True": C$ = "If Left is > the right then return TRUE": GoSub AO
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "BNE": B$ = "<": C$ = "Keep looping until we've compared all the bytes of both strings": GoSub AO
            Print #1, "; If we get here then the strings are the same this far, so TRUE if Left is longer then the Right"
            A$ = "LDB": B$ = "_StrVar_PF00": C$ = "B= the Length of the Left String": GoSub AO
            A$ = "CMPB": B$ = "_StrVar_IFRight": C$ = "Compare it with the length of the Right String": GoSub AO
            A$ = "BLO": B$ = "@False": C$ = "If left is lower than the right then return FALSE": GoSub AO
        End If
        ' Done all compares
        Z$ = "@True"
        A$ = "LDX": B$ = "#$FFFF": C$ = "Result = -1, True": GoSub AO
        A$ = "BRA": B$ = "@SaveX": C$ = "If They are Not Equal then return a false": GoSub AO
        Z$ = "@False"
        A$ = "LDX": B$ = "#$0000": C$ = "Make the Result zero, False": GoSub AO
        Z$ = "@SaveX"
        A$ = "PSHS": B$ = "X": C$ = "Save the result on the stack": GoSub AO
        Print #1, ""
    End If
End If
SkipLeft:
operatorStackTop = operatorStackTop - 1
valueStackTop = valueStackTop + 1
valueStack(valueStackTop) = 0
Return

' Input is operator, depending on the value of "OR"=1, "AND"=2, "=<>"=3 return with value in OperatorPrecedence
' with # from 0 to 3 with 0 being any other operator
'                         1   2   3   4   5    6    7    8   9   10  11 12  13  14                                   21   22   23
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR   Extended for Evaluation code "<>","<=",">="

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

GetOperatorPrecedence:
OperatorPrecedence = 0
If operator = &H13 Then OperatorPrecedence = 1 ' XOR
If operator = &H11 Then OperatorPrecedence = 2 ' "OR"
If operator = &H10 Then OperatorPrecedence = 3 '"AND"
If operator = &H14 Then OperatorPrecedence = 4 ' NOT
If (operator > &H3B And operator < &H3F) Or operator = &H12 Then OperatorPrecedence = 5 ' "=", "<", ">","MOD"
If operator > &H5F And operator < &H63 Then OperatorPrecedence = 5 ' "<>","<=",">="
If operator = &H15 Then OperatorPrecedence = 5 ' DIVR
Return

' Input Token(CurrentToken) output TokenPrecedence, depending on the value of "OR"=1, "AND"=2, "=<>"=3
' 0 being any other Token
GetTokenPrecedence:
TokenPrecedence = 0
If v = &H13 Then TokenPrecedence = 1 ' XOR
If v = &H11 Then TokenPrecedence = 2 ' "OR"
If v = &H10 Then TokenPrecedence = 3 '"AND"
If v = &H14 Then TokenPrecedence = 4 ' NOT
If (v > &H3B And v < &H3F) Or v = &H12 Then TokenPrecedence = 5 ' "=", "<", ">","MOD"
If v > &H5F And v < &H63 Then TokenPrecedence = 5 ' "<>","<=",">="
If v = &H15 Then TokenPrecedence = 5 ' DIVR
Return

' Get the value of a string expression
ParseStringExpression:
'show$ = Expression$: GoSub show
If Verbose > 2 Then Print "Going to parse String: "; Expression$
ExpressionCount = ExpressionCount + 1
Expression$(ExpressionCount) = Expression$ + "    "
index(ExpressionCount) = 1
GoSub ParseStringExpression0
ExpressionCount = ExpressionCount - 1
Return

' handle +
ParseStringExpression0:
GoSub ParseStringExpression10 ' Check for String Quotes, String Variables or String Commands
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC And (Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H2B)
    ' Check for +
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC Then
        'We found the operator token
        index(ExpressionCount) = index(ExpressionCount) + 1 ' point at the actual operator
        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H2B Then
            ' We found a +
            StrParseCount = StrParseCount + 1
            index(ExpressionCount) = index(ExpressionCount) + 1 ' Consume the +
            ' Do concatenation
            GoSub ParseStringExpression10 ' Result in Parse00_Term$
            num = StrParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            ' string at StrParseCount-1 = string at StrParseCount-1 + string at StrParseCount
            ' Leave blank so the assembler knows the Loop@ & Done@ are for this bit of code only
            Print #1,
            A$ = "LDX": B$ = "#_StrVar_PF" + Num$: C$ = "X points at the start of the old string (which is the final Destination)": GoSub AO
            A$ = "LDB": B$ = ",X+": C$ = "B = length of the old string, move X to the first location where data is stored": GoSub AO
            A$ = "ABX": C$ = "X now points at the location to start copying to (Destination is setup)": GoSub AO
            num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "ADDB": B$ = "_StrVar_PF" + Num$: C$ = "Add the length of the new string to the old string": GoSub AO
            A$ = "BEQ": B$ = "Done@": C$ = "Skip ahead if they are both empty": GoSub AO
            A$ = "LDU": B$ = "#_StrVar_PF" + Num$: C$ = "U points at the length of the source string": GoSub AO
            A$ = "LDA": B$ = ",U+": C$ = "A = the length of the source string, move U to the first byte of source data": GoSub AO
            A$ = "BEQ": B$ = "Done@": C$ = "Skip ahead if the source is empty": GoSub AO
            num = StrParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "STB": B$ = "_StrVar_PF" + Num$: C$ = "Update the size of the final Destination string": GoSub AO
            Z$ = "Loop@"
            A$ = "LDB": B$ = ",U+": C$ = "Get a source byte": GoSub AO
            A$ = "STB": B$ = ",X+": C$ = "Write the destination byte": GoSub AO
            A$ = "DECA": C$ = "Decrement the counter": GoSub AO
            A$ = "BNE": B$ = "Loop@": C$ = "Loop until all data is copied to the destination string": GoSub AO
            Print #1, "Done@"
            ' Leave blank so the assembler knows the Loop@ & Done@ are for this bit of code only
            Print #1,
            StrParseCount = StrParseCount - 1
        End If
    End If
Wend
Return

' Check for String Quotes, String Variables or String Commands
ParseStringExpression10:
PE10Count = PE10Count + 1
' Handle String values in quotes
' Print Start, Hex$(Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)))
If Mid$(Expression$(ExpressionCount), index(ExpressionCount), 2) = Chr$(&HF5) + Chr$(&H22) Then ' Is it a quote?
    ' We found a quote
    index(ExpressionCount) = index(ExpressionCount) + 2 ' move past the $F5 & quote
    x$ = "" ' Init the variable that will equal to what's in the quotes
    While Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1) <> Chr$(&HF5)
        x$ = x$ + Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)
        index(ExpressionCount) = index(ExpressionCount) + 1 'Move to the next characater in the quotes
    Wend
    index(ExpressionCount) = index(ExpressionCount) + 2 'consume the $F5 & the end quote
    'We exit and index pointer is now at the character after the quote
    If x$ = "" Then 'Is it an empty string?
        ' if it's an empty string then simply, write zero to the size
        num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If num < 10 Then Num$ = "0" + Num$
        A$ = "CLR": B$ = "_StrVar_PF" + Num$: C$ = "Set size of string as zero bytes": GoSub AO
    Else
        ' Copy the string to the temp string pointer
        A$ = "BSR": B$ = ">": C$ = "Skip over string value and save the string start on the stack": GoSub AO
        For ii = 1 To Len(x$)
            A$ = "FCB": B$ = "$" + Hex$(Asc(Mid$(x$, ii, 1))): C$ = Mid$(x$, ii, 1): GoSub AO 'write the quote text
        Next ii
        Z$ = "!"
        num = Len(x$): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDB": B$ = "#" + Num$: C$ = "Length of this string": GoSub AO
        num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If num < 10 Then Num$ = "0" + Num$
        A$ = "LDX": B$ = "#_StrVar_PF" + Num$: C$ = "X points at the Temp string variable start location ": GoSub AO ' X points at the Temp string variable start location
        A$ = "STB": B$ = ",X+": C$ = "store the length of the string data": GoSub AO
        A$ = "LDU": B$ = ",S++": C$ = "Stack points to the string start location, remove the return address off the stack": GoSub AO
        Z$ = "!"
        A$ = "LDA": B$ = ",U+": C$ = "Get the string data": GoSub AO
        A$ = "STA": B$ = ",X+": C$ = "write the string data": GoSub AO
        A$ = "DECB": C$ = "Decrement the counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "Loop until string is copied into _StrVar_PF" + Num$: GoSub AO
    End If
Else
    'Check for String variable
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HF3 Then ' F3 = Regular String Variable
        ' Regular String Variable
        index(ExpressionCount) = index(ExpressionCount) + 1
        x$ = StringVariable$(Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) * 256 + Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1))) ' String Array variable name
        '  Print "Found a String variable: "; x$; " need to deal with this"
        index(ExpressionCount) = index(ExpressionCount) + 2 'consume the string variable
        ' Copy String variable X$ to temp variable  "_StrVar_PF" + Num$
        A$ = "LDU": B$ = "#_StrVar_" + x$: C$ = "U points at the start of the source string": GoSub AO
        A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AO
        num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If num < 10 Then Num$ = "0" + Num$
        A$ = "LDX": B$ = "#_StrVar_PF" + Num$: C$ = "X points at the length of the destination string": GoSub AO
        A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AO
        A$ = "BEQ": B$ = "Done@": C$ = "If B=0 then no need to copy the string": GoSub AO
        Z$ = "!"
        A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AO
        A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AO
        A$ = "DECB": C$ = "Decrement the counter": GoSub AO
        A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AO
        Z$ = "Done@": GoSub AO
        Print #1, "" ' Leave a space between sections so Done@ will work for each section
    Else
        'Check for String Array variable
        ' String Array token is:
        ' 00  = &HF1 - The String Array identifier
        ' 01  = Pointer to the String Array Name in array StringArrayVariables$()
        ' 02  = Number of dimensions this array has

        '   StringArrayVariables$(200), StringArrayDimensions(200) As Integer, StringArrayDimensionsVal$(200)

        ' Offset = (x * Ny * Nz + y * Nz + z) * E
        ' Where:
        ' Nx = Number of elements in the x dimension (not used directly in calculation)
        ' Ny = Number of elements in the y dimension (10 in your case)
        ' Nz = Number of elements in the z dimension (10 in your case)
        ' E = Size of each element in bytes (2 bytes in your case)

        ' To understand this a little better, what if my array is A(2,3,6,5)
        ' where the first dimension is from 0 to 4 (5)
        ' the 2nd is 0 to 7 (8)
        ' the 3rd is 0 to 8 (9)
        ' and 4th is 0 to 11 (12)
        ' How to calculate the offset?
        ' Substitute Values: d1 = 2, d2 = 3, d3 = 6, d4 = 5
        ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)
        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HF1 Then ' F1 = String Array Variable
            ' String Array variable
            StrArrayParseNum = StrArrayParseNum + 1
            index(ExpressionCount) = index(ExpressionCount) + 1 ' Point at the String array name
            StrArrayNameParseNum$(StrArrayParseNum) = StringArrayVariables$(Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) * 256 + Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1))) ' String Array variable name
            '  Print "Found a String Array variable: "; StrArrayNameParseNum$(StrArrayParseNum); " need to deal with this"
            index(ExpressionCount) = index(ExpressionCount) + 2 ' Point at the number of dimensions this array has
            StrArrayNameParseNum(StrArrayParseNum) = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) ' Number of dimensions this array has
            index(ExpressionCount) = index(ExpressionCount) + 3 ' consume the # of dimension & the $F5 & open bracket "("
            If StrArrayNameParseNum(StrArrayParseNum) = 1 Then ' does it only have one dimension? if so it's simpler
                ' Yes just a single dimension array
                If Verbose > 3 Then Print "handling a one dimensional array"
                ' Print #1, "; Started handling the array here:"
                GoSub ParseExpression0FlagErase ' Recursively check the next value, this will return with the next value in D
                resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
                ' We only use B string arrays are 256 bytes each, we can't have more than 255 (actually way less)
                If StringArraySize = 255 Then
                    ' We only use B string arrays are 256 bytes each, we can't have more than 255 (actually way less)
                    A$ = "TFR": B$ = "B,A": C$ = "D = B * 256": GoSub AO
                    A$ = "CLRB": C$ = Chr$(&H22) + Chr$(&H22): GoSub AO
                Else
                    ' A little slower but saves RAM
                    num = StringArraySize: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "LDA": B$ = "#" + Num$ + "+1": C$ = "String Array size requested by the user +1 because first digit is the string length": GoSub AO
                    A$ = "MUL": C$ = "D = A * B": GoSub AO
                End If
                A$ = "ADDD": B$ = "#_ArrayStr_" + StrArrayNameParseNum$(StrArrayParseNum) + "+1": C$ = "D points at the start of the destination string": GoSub AO
                ' Copy String variable That D points at to temp variable  "_StrVar_PF" + Num$
                A$ = "TFR": B$ = "D,U": C$ = "U points at the start of the source string": GoSub AO
                A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AO
                num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDX": B$ = "#_StrVar_PF" + Num$: C$ = "X points at the length of the destination string": GoSub AO
                A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AO
                A$ = "BEQ": B$ = "Done@": C$ = "If B=0 then no need to copy the string": GoSub AO
                Z$ = "!"
                A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AO
                A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AO
                A$ = "DECB": C$ = "Decrement the counter": GoSub AO
                A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AO
                Z$ = "Done@": GoSub AO
                Print #1, "" ' Leave a space between sections so Done@ will work for each section
                index(ExpressionCount) = index(ExpressionCount) + 1 ' Skip the close bracket
            Else
                ' To understand this a little better, what if my array is A(2,3,6,5)
                ' where the first dimension is from 0 to 4 (5)
                ' the 2nd is 0 to 7 (8)
                ' the 3rd is 0 to 8 (9)
                ' and 4th is 0 to 11 (12)
                ' How to calculate the offset?
                ' Substitute Values: d1 = 2, d2 = 3, d3 = 6, d4 = 5
                ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)

                'We have a multidimensional array to deal with
                If Verbose > 3 Then Print "handling a multi dimensional array"
                A$ = "LDX": B$ = "#_ArrayStr_" + StrArrayNameParseNum$(StrArrayParseNum) + "+1": C$ = " X points at the 2nd array Element size": GoSub AO ' X points at the 2nd array Element size
                A$ = "PSHS": B$ = "X": C$ = "Save X on the stack, so we can point to it and just in case we have arrays inside arrays...": GoSub AO
                ' Get d1
                GoSub GetArrayElementB4Comma ' Get the value to parse that is before the &H2C = comma , Temp$ is the expression to parse
                Expression$ = Temp$ ' New expression to parse (dimension in the array before a comma)
                ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D
                A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AO ' D = d1
                If StrArrayNameParseNum(StrArrayParseNum) = 2 Then GoTo DoStrArrCloseBracket ' skip ahead if we only have 2 dimension in the array
                'Get NumElements2
                A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement2": GoSub AO
                A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO ' LSB of d1
                A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO ' D=d1* NumElements2
                A$ = "PSHS": B$ = "D": C$ = "Save the result on the stack": GoSub AO ' Save it on the stack
                A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AO
                A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AO
                A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AO
                Z$ = "!": GoSub AO ' Num Element Pointer is now pointing at NumElements3
                'Get d2
                GoSub GetArrayElementB4Comma ' Get the value to parse that is before the &H2C = comma , Temp$ is the expression to parse
                Expression$ = Temp$ ' New expression to parse (dimension in the array before a comma)
                ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D where the Value can never be larger than 255
                ' Add d2
                A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
                A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AO
                If Verbose > 3 Then Print "number of dimensions:"; StrArrayNameParseNum(StrArrayParseNum)
                If StrArrayNameParseNum(StrArrayParseNum) > 3 Then
                    For Temp1 = 3 To StrArrayNameParseNum(StrArrayParseNum) - 1 ' Number of dimensions in the array - 1 since last ont have a comma seperating it
                        ' Get NumElementsX
                        A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AO
                        A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO
                        A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO '                        Need 16bit muliply
                        A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AO
                        A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AO
                        A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AO
                        A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AO
                        Z$ = "!": GoSub AO
                        ' Add dX
                        Temp(StrArrayParseNum) = Temp1 ' Keep value, just incase we have arrays, inside arrays
                        GoSub GetArrayElementB4Comma ' Get the value to parse that is before the &H2C = comma , Temp$ is the expression to parse
                        Expression$ = Temp$ ' New expression to parse (dimension in the array before a comma)
                        ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D where the Value can never be larger than 255
                        Temp1 = Temp(StrArrayParseNum) ' restore value, just incase we have arrays, inside arrays
                        A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
                        A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AO
                    Next Temp1
                End If
                DoStrArrCloseBracket:
                ' Last dimension value ends with a close bracket
                ' Get NumElementsX
                A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AO
                A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO
                A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO '                                 Need 16bit multiply
                A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AO
                ' Add dX
                GoSub GetArrayElementB4Bracket ' Get the value to parse that is before the close bracket ")", Temp$ is the expression to parse
                Expression$ = Temp$ ' New expression to parse (dimension in the array before a close bracket)
                ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D where the Value can never be larger than 255
                A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
                A$ = "LEAS": B$ = "6,S": C$ = "Fix the stack": GoSub AO
                ' We only use B string arrays are 256 bytes each, we can't have more than 255 (actually way less)
                If StringArraySize = 255 Then
                    ' We only use B string arrays are 256 bytes each, we can't have more than 255 (actually way less)
                    A$ = "TFR": B$ = "B,A": C$ = "D = B * 256": GoSub AO
                    A$ = "CLRB": C$ = Chr$(&H22) + Chr$(&H22): GoSub AO
                Else
                    ' A little slower but saves RAM
                    num = StringArraySize: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    A$ = "LDA": B$ = "#" + Num$ + "+1": C$ = "String Array size requested by the user +1 because first digit is the string length": GoSub AO
                    A$ = "MUL": C$ = "D = A * B": GoSub AO
                End If

                ' Copy String variable That D points at to temp variable  "_StrVar_PF" + Num$
                num = StrArrayNameParseNum(StrArrayParseNum): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                A$ = "ADDD": B$ = "#_ArrayStr_" + StrArrayNameParseNum$(StrArrayParseNum) + "+" + Num$: C$ = "D = D + the the start of the source string": GoSub AO
                A$ = "TFR": B$ = "D,U": C$ = "U points at the start of the source string": GoSub AO
                A$ = "LDB": B$ = ",U+": C$ = "B = length of the source string, move U to the first location where source data is stored": GoSub AO
                num = StrParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDX": B$ = "#_StrVar_PF" + Num$: C$ = "X points at the start of the destination string": GoSub AO
                A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AO
                A$ = "BEQ": B$ = "Done@": C$ = "If B=0 then no need to copy the string": GoSub AO
                Z$ = "!"
                A$ = "LDA": B$ = ",U+": C$ = "Get a source byte": GoSub AO
                A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AO
                A$ = "DECB": C$ = "Decrement the counter": GoSub AO
                A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AO
                Z$ = "Done@": GoSub AO
                Print #1, "" ' Leave a space between sections so Done@ will work for each section
            End If
            StrArrayParseNum = StrArrayParseNum - 1
        Else
            'Check for String command  - should work similarly to a bracket
            If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFD Then ' FD = String Command
                ' FD = String Command
                index(ExpressionCount) = index(ExpressionCount) + 1
                v = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) * 256 + Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1))
                index(ExpressionCount) = index(ExpressionCount) + 4 ' Consume the String command and open bracket
                GoSub JumpToStringCommand ' Go do the string command
                If Mid$(Expression$(ExpressionCount), index(ExpressionCount), 2) <> Chr$(&HF5) + ")" Then
                    Print "Error1: Expected closing parenthesis in";: GoTo FoundError
                End If
                index(ExpressionCount) = index(ExpressionCount) + 2 ' move past the close brackets
            Else
                show$ = Expression$(ExpressionCount): GoSub show
                Print "I can't process part of the string expression on";: GoTo FoundError
            End If
        End If
    End If
End If
'Wend
Parse10_Term$ = resultP10$(PE10Count)
PE10Count = PE10Count - 1
Return

' Get the value of a numeric expression and return with the value in D
' If ExType = 1 then it can be replaced with an actual number that is in variable result
' If ExType = 2 then there are variables used in this expression so have to use it as it is.
'Start of new parsing of an expression, end result is numerical
ParseNumericExpression:
If Verbose > 2 Then Print "Going to parse Numeric Expression: "; Expression$
ExpressionCount = ExpressionCount + 1
' Make sure expression doesn't start with +
If Left$(Expression$, 2) = Chr$(&HFC) + Chr$(&H2B) Then Expression$ = Right$(Expression$, Len(Expression$) - 2) ' If so, ignore the first two bytes ($FC $2B) = +

' Check if Expression has a NOT in it which is &HFC &H14, if so we need to put a 1 in front of it
NewExpression$ = ""
For I = 1 To Len(Expression$) - 1
    If Asc(Mid$(Expression$, I, 1)) = &HFC And Asc(Mid$(Expression$, I + 1, 1)) = &H14 Then
        'We found a NOT
        NewExpression$ = NewExpression$ + "1"
    End If
    NewExpression$ = NewExpression$ + Mid$(Expression$, I, 1)
Next I
NewExpression$ = NewExpression$ + Mid$(Expression$, I, 1) 'copy the last byte
Expression$ = NewExpression$
Expression$(ExpressionCount) = Expression$ + "    "
index(ExpressionCount) = 1
GoSub ParseExpression0
Print #1, "*XX We can delete the line above XX*"
ExpressionCount = ExpressionCount - 1
Return

' Parse Numeric Expression and flag the last line as erasable
ParseExpression0FlagErase:
GoSub ParseExpression0
Print #1, "*XX We can delete the line above XX*"
Return

'                         1   2   3   4   5    6    7    8   9   10  11 12  13  14                                   21   22   23
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR   Extended for Evaluation code "<>","<=",">="

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

ParseExpression0:
' Do logical OR
GoSub ParseExpression02 ' Go check other more priority things first, then do OR
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
 And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H11
    ' Found an OR token
    NumParseCount = NumParseCount + 1
    index(ExpressionCount) = index(ExpressionCount) + 2 ' point past the actual operator
    'Do OR
    GoSub ParseExpression02 ' Result in Parse00_Term
    num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDX": B$ = "_Var_PF" + Num$: GoSub AO ' Changed to use X instead of D as the optimizer was killing it
    A$ = "PSHS": B$ = "X": C$ = "Save X on the Stack = The left value": GoSub AO ' Save the FIrst value    ' Changed to use X instead of D as the optimizer was killing it
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AO ' D = Parse10_Term
    A$ = "ORA": B$ = ",S+": C$ = "ORA": GoSub AO ' A = A OR Parse10_Term
    A$ = "ORB": B$ = ",S+": C$ = "ORB": GoSub AO ' B = B OR Parse10_Term
    NumParseCount = NumParseCount - 1
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO
Wend
Return

' Do logical AND
ParseExpression02:
GoSub ParseExpression03 ' Go check other more priority things first, then do AND
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
 And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H10
    ' Found an AND token
    NumParseCount = NumParseCount + 1
    index(ExpressionCount) = index(ExpressionCount) + 2 ' point past the actual operator
    'Do AND
    GoSub ParseExpression03 ' Result in Parse00_Term
    num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$ ' Changed to use X instead of D as the optimizer was killing it
    A$ = "LDX": B$ = "_Var_PF" + Num$: GoSub AO ' Changed to use X instead of D as the optimizer was killing it
    A$ = "PSHS": B$ = "X": C$ = "Save X on the Stack = The left value": GoSub AO ' Save the FIrst value    ' Changed to use X instead of D as the optimizer was killing it
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AO ' D = Parse10_Term
    A$ = "ANDA": B$ = ",S+": C$ = "ANDA": GoSub AO ' A = A AND Parse10_Term
    A$ = "ANDB": B$ = ",S+": C$ = "ANDB": GoSub AO ' B = B AND Parse10_Term
    NumParseCount = NumParseCount - 1
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO
Wend
Return

'                         1   2   3   4   5    6    7    8   9   10  11 12  13  14                                   21   22   23
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR   Extended for Evaluation code "<>","<=",">="

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

' Do <,=,>
ParseExpression03:
GoSub ParseExpression05 ' Go check other things before doing < = >
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
 And (Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) > &H3B and Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) < &H3F)
    ' Check for > = <
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC Then
        'We found the operator token
        index(ExpressionCount) = index(ExpressionCount) + 1 ' point at the actual operator
        ' Figure out if we have two operators and what they are
        F2 = 0
        F1 = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1))
        ' (J<=5) or (J<   =5) end up as 0A FC 09        , (J<5) ends up as 0A 35 29
        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &HFC Then
            ' We have two Operators
            F2 = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 2, 1))
            index(ExpressionCount) = index(ExpressionCount) + 2
        Else
            F2 = 0
        End If
        If F2 = 0 Then
            If F1 = &H3E Then BranchType$ = "BGT" '>
            If F1 = &H3D Then BranchType$ = "BEQ" '=
            If F1 = &H3C Then BranchType$ = "BLT" '<
        Else
            If F2 = &H3E Then '>
                If F1 = &H3E Then BranchType$ = "BGT"
                If F1 = &H3D Then BranchType$ = "BGE"
                If F1 = &H3C Then BranchType$ = "BNE"
            End If
            If F2 = &H3D Then '=
                If F1 = &H3E Then BranchType$ = "BGE"
                If F1 = &H3D Then BranchType$ = "BEQ"
                If F1 = &H3C Then BranchType$ = "BLE"
            End If
            If F2 = &H3C Then '<
                If F1 = &H3E Then BranchType$ = "BNE"
                If F1 = &H3D Then BranchType$ = "BLE"
                If F1 = &H3C Then BranchType$ = "BLT"
            End If
        End If
        ' We found the Branch type in BranchType$
        NumParseCount = NumParseCount + 1
        index(ExpressionCount) = index(ExpressionCount) + 1
        GoSub ParseExpression05 ' Result in Parse00_Term
        num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If num < 10 Then Num$ = "0" + Num$
        A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AO
        num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If num < 10 Then Num$ = "0" + Num$
        A$ = "CMPD": B$ = "_Var_PF" + Num$: GoSub AO
        A$ = BranchType$: B$ = "@IsTrue": C$ = "skip ahead if TRUE": GoSub AO
        A$ = "LDD": B$ = "#$0000": C$ = "False repsonse": GoSub AO
        A$ = "BRA": B$ = ">": C$ = "Skip ahead": GoSub AO
        Z$ = "@IsTrue": GoSub AO
        A$ = "LDD": B$ = "#$FFFF": C$ = "True repsonse": GoSub AO
        NumParseCount = NumParseCount - 1
        num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If num < 10 Then Num$ = "0" + Num$
        Z$ = "!": GoSub AO
        Print #1,
        A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO
    End If
Wend
Return
'                         1   2   3   4   5    6    7    8   9   10  11 12  13  14                                   21   22   23
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR   Extended for Evaluation code "<>","<=",">="

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

' Do + or -
ParseExpression05:
GoSub ParseExpression09 ' Go check everything else then do + or -
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
 And (Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H2B Or Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H2D)
    ' Check for + or -
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC Then
        'We found the operator token
        index(ExpressionCount) = index(ExpressionCount) + 1 ' point at the actual operator
        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H2B Or Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H2D Then
            ' We found a + or -
            NumParseCount = NumParseCount + 1
            index(ExpressionCount) = index(ExpressionCount) + 1
            If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) - 1, 1)) = &H2B Then
                ' Do addition
                GoSub ParseExpression09 ' Result in Parse00_Term
                num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AO
                num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "ADDD": B$ = "_Var_PF" + Num$: GoSub AO
            Else
                'Do subtraction
                GoSub ParseExpression09 ' Result in Parse00_Term
                num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AO
                num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "SUBD": B$ = "_Var_PF" + Num$: GoSub AO
            End If
            NumParseCount = NumParseCount - 1
            num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO
        End If
    End If
Wend
Return
'                         1   2   3   4   5    6    7    8   9  10  11  12  13  14
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

' MOD
ParseExpression09:
GoSub ParseExpression10 ' Go check other more priority things first, then do MOD
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
 And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H12
    ' Found a MOD token
    NumParseCount = NumParseCount + 1
    index(ExpressionCount) = index(ExpressionCount) + 2 ' point past the actual operator
    'Do MOD
    GoSub ParseExpression10 ' Result in Parse00_Term
    num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDX": B$ = "_Var_PF" + Num$: GoSub AO ' Changed to use X instead of D as the optimizer was killing it
    A$ = "PSHS": B$ = "X": C$ = "Save X on the Stack = The left value": GoSub AO ' Save the FIrst value    ' Changed to use X instead of D as the optimizer was killing it
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AO ' D = Parse10_Term
    A$ = "PULS": B$ = "X": C$ = "Get X off the Stack = The Numerator": GoSub AO ' Get the Numerator
    A$ = "JSR": B$ = "DIV16": C$ = "Do 16bit by 16bit division, result in D and Remainder (MOD) in X": GoSub AO
    A$ = "TFR": B$ = "X,D": C$ = "Transfer the Remainder into D": GoSub AO
    NumParseCount = NumParseCount - 1
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO
Wend
Return

'                         1   2   3   4   5    6    7    8   9  10  11  12  13  14
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

' Do * or / or DIVR (Divide with auto Rounding)
ParseExpression10:
PE10Count = PE10Count + 1
GoSub ParseExpression20 ' Go check everything other things before doing * or /
resultP10(PE10Count) = Parse20_Term
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC And _
(Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H2A Or Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H2F Or _
 Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H15 Or Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H5C)
    ' Check for * or /
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC Then
        'We found the operator token
        index(ExpressionCount) = index(ExpressionCount) + 1 ' point at the actual operator
        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H2A Or _
         Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H2F Or _
         Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H15 Or _
         Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H5C Then
            ' We found a * or /
            NumParseCount = NumParseCount + 1
            '    Print "PE10Count="; PE10Count, "Doing a "; op$; " ";
            index(ExpressionCount) = index(ExpressionCount) + 1
            If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) - 1, 1)) = &H2A Then
                ' Do multiplication
                GoSub ParseExpression20 ' Result in Parse20_Term
                num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AO
                num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDX": B$ = "_Var_PF" + Num$: GoSub AO
                A$ = "PSHS": B$ = "D,X": C$ = "Save the two 16 bit WORDS on the stack, to be multiplied": GoSub AO
                A$ = "JSR": B$ = "MUL16": C$ = "Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D": GoSub AO ' D = D * X
                A$ = "LEAS": B$ = "4,S": C$ = "Fix the Stack": GoSub AO
                resultP10(PE10Count) = resultP10(PE10Count) * Parse20_Term
                GoTo DoneMD
            End If
            If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) - 1, 1)) = &H2F Or _
               Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) - 1, 1)) = &H5C Then
                'Do division
                GoSub ParseExpression20 ' Result in Parse20_Term
                num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDX": B$ = "_Var_PF" + Num$: GoSub AO
                num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AO
                ' X = X/D, remainder in D
                A$ = "JSR": B$ = "DIV16": C$ = "Do 16 bit / 16 bit Division, D = X/D No rounding will occur": GoSub AO ' D = D * X
                resultP10(PE10Count) = resultP10(PE10Count) / Parse20_Term
                GoTo DoneMD
            End If
            If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) - 1, 1)) = &H15 Then
                ' Do DIVR (division that will round the value)
                GoSub ParseExpression20 ' Result in Parse20_Term
                num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDX": B$ = "_Var_PF" + Num$: GoSub AO
                num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AO
                ' D = X/D
                A$ = "JSR": B$ = "DIV16Rounding": C$ = "Do 16 bit / 16 bit Division, D = X/D rounds the result": GoSub AO ' D = D * X
                resultP10(PE10Count) = resultP10(PE10Count) / Parse20_Term
                GoTo DoneMD
            End If
            DoneMD:
            NumParseCount = NumParseCount - 1
            num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO ' Save new resultP10(PE10Count)
        End If
    End If
Wend
Parse10_Term = resultP10(PE10Count)
'Print "Parse10_Term="; Parse10_Term, "PE10Count="; PE10Count
PE10Count = PE10Count - 1
Return

'                         1   2   3   4   5    6    7    8   9  10  11  12  13  14
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

' Do Exponents
ParseExpression20:
PE20Count = PE20Count + 1
GoSub ParseExpression25 ' Go check everything else first, do exponent
resultP20(PE20Count) = Parse30_Term
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
    And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H5E
    ' Check for ^
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC Then
        'We found the operator token
        index(ExpressionCount) = index(ExpressionCount) + 1 ' point at the actual operator
        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &H5E Then
            ' We found a ^
            NumParseCount = NumParseCount + 1
            index(ExpressionCount) = index(ExpressionCount) + 1
            ' Do Exponent
            GoSub ParseExpression25 ' Result in Parse30_Term
            num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "LDD": B$ = "_Var_PF" + Num$: C$ = "D = the Base value": GoSub AO
            num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "LDX": B$ = "_Var_PF" + Num$: C$ = "X = the Exponent value": GoSub AO
            A$ = "PSHS": B$ = "D": C$ = "Save the base value": GoSub AO
            A$ = "PSHS": B$ = "D": C$ = "Save the base value": GoSub AO
            A$ = "BNE": B$ = ">": C$ = "If X <> zero then skip ahead": GoSub AO
            A$ = "LDD": B$ = "#1": C$ = "Exponent of zero results with 1": GoSub AO
            A$ = "BRA": B$ = "@GotD": C$ = "Done": GoSub AO
            Z$ = "!"
            A$ = "BPL": B$ = ">": C$ = "If it's a postive number skip ahead": GoSub AO
            A$ = "LDD": B$ = "#$FFFF": C$ = "can't do negative exponents, make value -1": GoSub AO
            A$ = "BRA": B$ = "@GotD": C$ = "Done": GoSub AO
            Z$ = "!"
            A$ = "CMPX": B$ = "#1": C$ = "Is the exponent > 1": GoSub AO
            A$ = "BGT": B$ = "@StartHere": C$ = "If so skip ahead, starting with Decrementing X": GoSub AO
            A$ = "LDD": B$ = "2,S": C$ = "D = the Base value": GoSub AO
            A$ = "BRA": B$ = "@GotD": C$ = "Done": GoSub AO
            Z$ = "!"
            A$ = "JSR": B$ = "MUL16": C$ = "Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D": GoSub AO
            A$ = "STD": B$ = ",S": C$ = "Save the result to be multiplied with the base number again": GoSub AO
            Z$ = "@StartHere": GoSub AO
            A$ = "LEAX": B$ = "-1,X": C$ = "Decremnt the number of times to multiply": GoSub AO
            A$ = "BNE": B$ = "<": C$ = "If X is <> zero keep looping": GoSub AO
            Z$ = "@GotD"
            A$ = "LEAS": B$ = "4,S": C$ = "fix the stack": GoSub AO
            Print #1,
            resultP20(PE20Count) = resultP20(PE20Count) ^ Parse30_Term
            NumParseCount = NumParseCount - 1
            num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO ' Save new resultP20(PE20Count)
        End If
    End If
Wend
Parse20_Term = resultP20(PE20Count)
'Print "Parse20_Term="; Parse20_Term, "PE20Count="; PE20Count
PE20Count = PE20Count - 1
Return
'                         1   2   3   4   5    6    7    8   9  10  11  12  13  14
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

' Do loginal XOR
ParseExpression25:
GoSub ParseExpression28 ' Go check other more priority things first, then do XOR
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
 And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H13
    ' Found an XOR token
    NumParseCount = NumParseCount + 1
    index(ExpressionCount) = index(ExpressionCount) + 2 ' point past the actual operator
    'Do XOR
    GoSub ParseExpression28 ' Result in Parse00_Term
    num = NumParseCount - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDX": B$ = "_Var_PF" + Num$: GoSub AO ' Changed to use X instead of D as the optimizer was killing it
    A$ = "PSHS": B$ = "X": C$ = "Save X on the Stack = The left value": GoSub AO ' Save the FIrst value    ' Changed to use X instead of D as the optimizer was killing it
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AO ' D = Parse10_Term
    A$ = "EORA": B$ = ",S+": C$ = "EORA MSB on the stack, move stack forward": GoSub AO
    A$ = "EORB": B$ = ",S+": C$ = "EORB LSB on the stack, stack is now back to normal": GoSub AO
    NumParseCount = NumParseCount - 1
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO
Wend
Return

' Do logical NOT
ParseExpression28:
GoSub ParseExpression30 ' Go check other more priority things first, then do NOT
' Check if we've got to the end of the expression at this level
While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC _
 And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H14
    ' Found a NOT token
    NumParseCount = NumParseCount + 1
    index(ExpressionCount) = index(ExpressionCount) + 2 ' point past the actual operator
    ' Do NOT
    GoSub ParseExpression30 ' Result in Parse00_Term
    num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If num < 10 Then Num$ = "0" + Num$
    A$ = "LDD": B$ = "_Var_PF" + Num$: GoSub AO
    A$ = "COMA": C$ = "Flip the bits": GoSub AO
    A$ = "COMB": C$ = "Flip the bits": GoSub AO
    A$ = "STD": B$ = "_Var_PF" + Num$: C$ = "Save the NOT version": GoSub AO
    NumParseCount = NumParseCount - 1 ' We can now use the left PFxx, place holder
Wend
Return
'                         1   2   3   4   5    6    7    8   9  10  11  12  13  14
' FC = Operator Command  "+","-","*","/","^","AND","OR",">","=","<",MOD,XOR,NOT,DIVR

'                   Hex - 10,11, 12, 13, 14,  15,    2A,2B,2D,2F     3C,3D,3E      5C,5E                                60 , 61 , 62
' FC = Operator Command  AND,OR,MOD,XOR,NOT,DIVR,..., *, +, -, /,..., <, =, >,...., \, ^  Extended for Evaluation code "<>","<=",">="

'Handle unary minus, Parenthesis, numbers and numeric variables
ParseExpression30:
PE30Count = PE30Count + 1
negative(PE30Count) = 0 ' Default state is not negative
If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFC Then ' Check for an operator token
    'We found the operator token
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)) = &H2D Then
        ' We found a -
        ' Should probably check for double or more negatives (just in case of typos)
        negative(PE30Count) = 1 ' Flag this factor as negative
        index(ExpressionCount) = index(ExpressionCount) + 2 ' Move past the unary minus
    End If
End If
' Now handle whether the factor is a number or a subexpression
If Mid$(Expression$(ExpressionCount), index(ExpressionCount), 2) = Chr$(&HF5) + "(" Then
    index(ExpressionCount) = index(ExpressionCount) + 2 ' Consume '$F5&('
    GoSub ParseExpression0 ' Recursively check the next value
    resultP30(PE30Count) = Parse00_Term ' this will return with the next value
    If negative(PE30Count) = 1 Then resultP30(PE30Count) = -resultP30(PE30Count)
    If Mid$(Expression$(ExpressionCount), index(ExpressionCount), 2) = Chr$(&HF5) + ")" Then
        index(ExpressionCount) = index(ExpressionCount) + 2 ' Consume '$F5&)'
    Else
        Print "ExpressionCount"; ExpressionCount
        show$ = Expression$(ExpressionCount): GoSub show
        Print "Error2: Expected closing parenthesis in";: GoTo FoundError
    End If
Else
    ' Handle numeric values
    Start = index(ExpressionCount)
    ' Print Start, Hex$(Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)))
    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) >= Asc("0") And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) <= Asc("9") Then
        'Numeric value
        If index(ExpressionCount) = Len(Expression$(ExpressionCount)) Then
            x$(ExpressionCount) = Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)
        Else
            While index(ExpressionCount) < Len(Expression$(ExpressionCount)) And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) >= Asc("0") And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) <= Asc("9")
                index(ExpressionCount) = index(ExpressionCount) + 1
            Wend
            x$(ExpressionCount) = Mid$(Expression$(ExpressionCount), Start, index(ExpressionCount) - Start)
            If index(ExpressionCount) = Len(Expression$(ExpressionCount)) Then x$(ExpressionCount) = x$(ExpressionCount) + Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)
        End If
        '   Print  x$(ExpressionCount), Expression$(ExpressionCount), Start, index(ExpressionCount), index(ExpressionCount) - Start
        ' Apply negation if flagged
        If negative(PE30Count) = 1 Then
            num = -Val(x$(ExpressionCount)):
            resultP30(PE30Count) = -Val(x$(ExpressionCount))
        Else
            num = Val(x$(ExpressionCount)):
            resultP30(PE30Count) = Val(x$(ExpressionCount))
        End If
        GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDD": B$ = "#" + Num$: GoSub AO ' D = Val( x$(ExpressionCount))
        num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If num < 10 Then Num$ = "0" + Num$
        A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO ' Save Temp_Var_NumParseCount
    Else
        ' Handle hex values
        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = Asc("&") Then
            ' number is in hex
            If index(ExpressionCount) + 1 >= Len(Expression$(ExpressionCount)) Then
                Print "Error: can't process the value of the &, on";: GoTo FoundError
            Else
                index(ExpressionCount) = index(ExpressionCount) + 2
                Start = index(ExpressionCount)
                While index(ExpressionCount) < Len(Expression$(ExpressionCount)) _
                And ((Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) >= Asc("0") _
                And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) <= Asc("9")) _
                Or (Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) >= Asc("A") _
                And Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) <= Asc("F")))
                    index(ExpressionCount) = index(ExpressionCount) + 1
                Wend
                x$(ExpressionCount) = Mid$(Expression$(ExpressionCount), Start, index(ExpressionCount) - Start)
                If index(ExpressionCount) = Len(Expression$(ExpressionCount)) Then x$(ExpressionCount) = x$(ExpressionCount) + Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)
            End If
            ' Apply negation if flagged
            If negative(PE30Count) = 1 Then
                num = -Val("&H" + x$(ExpressionCount))
                resultP30(PE30Count) = -Val(x$(ExpressionCount))
            Else
                num = Val("&H" + x$(ExpressionCount))
                resultP30(PE30Count) = Val(x$(ExpressionCount))
            End If
            '     Print "val(x$)="; Val("&H" +  x$(ExpressionCount))
            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            A$ = "LDD": B$ = "#" + Num$: C$ = "Converted &H" + x$(ExpressionCount) + " to" + Str$(num): GoSub AO ' D = Val(x$)
            num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num < 10 Then Num$ = "0" + Num$
            A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO ' Save Temp_Var_NumParseCount
        Else
            'Check for Numeric variable
            If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HF2 Then ' F2 = Regular Numeric Variable
                ' Regular Numeric Variable
                ExType = 2 'flag we have variables
                index(ExpressionCount) = index(ExpressionCount) + 1
                x$(ExpressionCount) = NumericVariable$(Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) * 256 + Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1)))
                '    Print "Found a numeric variable: ";  x$(ExpressionCount); " need to deal with this"
                '      resultP30(PE30Count) = GetVariableValue( x$(ExpressionCount)) ' You need to define how to retrieve variable values
                'Deal with a Numeric variable in the expression
                '   Print "Dealling with variable ";  x$(ExpressionCount); " here..."
                ' Apply negation if flagged
                If negative(PE30Count) = 1 Then
                    ' This is a negative
                    A$ = "LDD": B$ = "#$0000": C$ = "Clear D": GoSub AO
                    A$ = "SUBD": B$ = "_Var_" + x$(ExpressionCount): C$ = "Going to use the negative verison of " + x$(ExpressionCount): GoSub AO
                Else
                    A$ = "LDD": B$ = "_Var_" + x$(ExpressionCount): GoSub AO: StoreFlag = 0
                End If
                num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num < 10 Then Num$ = "0" + Num$
                A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO ' Save Temp_Var_NumParseCount
                index(ExpressionCount) = index(ExpressionCount) + 2
            Else
                'Check for Numeric Array variable
                ' Numeric Array token is:
                ' 00  = &HF0 - The Numeric Array identifier
                ' 01  = Pointer to the Numeric Array Name in array NumericArrayVariables$()
                ' 02  = Number of dimensions this array has

                ' Offset = (x * Ny * Nz + y * Nz + z) * E
                ' Where:
                ' Nx = Number of elements in the x dimension (not used directly in calculation)
                ' Ny = Number of elements in the y dimension (10 in your case)
                ' Nz = Number of elements in the z dimension (10 in your case)
                ' E = Size of each element in bytes (2 bytes in your case)

                ' To understand this a little better, what if my array is A(2,3,6,5)
                ' where the first dimension is from 0 to 4 (5)
                ' the 2nd is 0 to 7 (8)
                ' the 3rd is 0 to 8 (9)
                ' and 4th is 0 to 11 (12)
                ' How to calculate the offset?
                ' Substitute Values: d1 = 2, d2 = 3, d3 = 6, d4 = 5
                ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)

                If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HF0 Then ' F0 = Numeric Array Variable
                    ' Numeric Array variable
                    ExType = 2 'flag we have variables
                    NumArrayParseNum = NumArrayParseNum + 1
                    index(ExpressionCount) = index(ExpressionCount) + 1 ' Point at the numeric array name
                    NumArrayNameParseNum$(NumArrayParseNum) = NumericArrayVariables$(Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) * 256 + Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1))) ' Numeric Array variable name
                    '  Print "Found a Numeric Array variable: "; NumArrayNameParseNum$(NumArrayParseNum); " need to deal with this"
                    index(ExpressionCount) = index(ExpressionCount) + 2 ' Point at the number of dimensions this array has

                    NumArrayNameParseNum(NumArrayParseNum) = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) ' Number of dimensions this array has
                    index(ExpressionCount) = index(ExpressionCount) + 3 ' consume the # of dimension & the $F5 open bracket "("
                    If NumArrayNameParseNum(NumArrayParseNum) = 1 Then ' does it only have one dimension? if so it's simpler
                        ' Yes just a single dimension array
                        If Verbose > 3 Then Print "handling a one dimensional array"
                        Print #1, "; Started handling the array here:"
                        GoSub ParseExpression0FlagErase ' Recursively check the next value, this will return with the next value in D
                        resultP30(PE30Count) = Parse00_Term ' this will return with the next value in D
                        A$ = "LSLB": GoSub AO
                        A$ = "ROLA": C$ = "D=D*2, 16 bit integers in the numeric array": GoSub AO
                        A$ = "ADDD": B$ = "#_ArrayNum_" + NumArrayNameParseNum$(NumArrayParseNum) + "+1": GoSub AO
                        A$ = "TFR": B$ = "D,X": C$ = "X now points at the memory location for the array": GoSub AO
                        ' Apply negation if flagged
                        If negative(PE30Count) = 1 Then
                            ' This is a negative
                            A$ = "LDD": B$ = "#$0000": C$ = "Clear D": GoSub AO
                            A$ = "SUBD": B$ = ",X": C$ = "Going to use the negative verison of " + NumArrayNameParseNum$(NumArrayParseNum): GoSub AO
                        Else
                            A$ = "LDD": B$ = ",X": GoSub AO: StoreFlag = 0
                        End If
                        num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        If num < 10 Then Num$ = "0" + Num$
                        A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO ' Save Temp_Var_NumParseCount
                        index(ExpressionCount) = index(ExpressionCount) + 2 ' Skip the $F5 & close bracket
                    Else
                        ' To understand this a little better, what if my array is A(2,3,6,5)
                        ' where the first dimension is from 0 to 4 (5)
                        ' the 2nd is 0 to 7 (8)
                        ' the 3rd is 0 to 8 (9)
                        ' and 4th is 0 to 11 (12)
                        ' How to calculate the offset?
                        ' Substitute Values: d1 = 2, d2 = 3, d3 = 6, d4 = 5
                        ' Offset = (((d1 * NumElements2 + d2) * NumElements3 + d3) * NumElements4 + d4) * size of each element (2 for 16 bit integers) (256 for strings)

                        'We have a multidimensional array to deal with
                        If Verbose > 3 Then Print "handling a multi dimensional array"
                        A$ = "LDX": B$ = "#_ArrayNum_" + NumArrayNameParseNum$(NumArrayParseNum) + "+1": C$ = " X points at the 2nd array Element size  ": GoSub AO ' X points at the 2nd array Element size
                        A$ = "PSHS": B$ = "X": C$ = "Save X on the stack, so we can point to it and just in case we have arrays inside arrays...": GoSub AO
                        ' Get d1
                        GoSub GetArrayElementB4Comma ' Get the value to parse that is before the &H2C = comma , Temp$ is the expression to parse, move past it
                        Expression$ = Temp$ ' New expression to parse (dimension in the array before a comma)
                        ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D
                        A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AO ' D = d1
                        If NumArrayNameParseNum(NumArrayParseNum) = 2 Then GoTo DoNumArrCloseBracket ' skip ahead if we only have 2 dimension in the array
                        'Get NumElements2
                        A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement2": GoSub AO
                        A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO ' LSB of d1
                        A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO ' D=d1* NumElements2
                        A$ = "PSHS": B$ = "D": C$ = "Save the result on the stack": GoSub AO ' Save it on the stack
                        A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AO
                        A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AO
                        A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AO
                        Z$ = "!": GoSub AO ' Num Element Pointer is now pointing at NumElements3
                        'Get d2
                        GoSub GetArrayElementB4Comma ' Get the value to parse that is before the &H2C = comma , Temp$ is the expression to parse
                        Expression$ = Temp$ ' New expression to parse (dimension in the array before a comma)
                        ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D where the Value can never be larger than 255
                        ' Add d2
                        A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
                        A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AO
                        If Verbose > 3 Then Print "number of dimensions:"; NumArrayNameParseNum(NumArrayParseNum)
                        If NumArrayNameParseNum(NumArrayParseNum) > 3 Then
                            For Temp1 = 3 To NumArrayNameParseNum(NumArrayParseNum) - 1 ' Number of dimensions in the array - 1 since last ont have a comma seperating it
                                ' Get NumElementsX
                                A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AO
                                A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO
                                A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO '                        Need 16bit muliply
                                A$ = "STD": B$ = ",S": C$ = "Save the result on the stack": GoSub AO
                                A$ = "INC": B$ = "5,S": C$ = "Increment NumElement LSB pointer": GoSub AO
                                A$ = "BNE": B$ = ">": C$ = "If LSB <>0 then skip ahead": GoSub AO
                                A$ = "INC": B$ = "4,S": C$ = "If the LSB just became zero then Increment NumElement MSB pointer": GoSub AO
                                Z$ = "!": GoSub AO
                                ' Add dX
                                Temp(NumArrayParseNum) = Temp1 ' Keep value, just incase we have arrays, inside arrays
                                GoSub GetArrayElementB4Comma ' Get the value to parse that is before the &H2C = comma , Temp$ is the expression to parse
                                Expression$ = Temp$ ' New expression to parse (dimension in the array before a comma)
                                ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D where the Value can never be larger than 255
                                Temp1 = Temp(NumArrayParseNum) ' restore value, just incase we have arrays, inside arrays
                                A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
                                A$ = "STD": B$ = ",S": C$ = "Save New D on the stack": GoSub AO
                            Next Temp1
                        End If
                        DoNumArrCloseBracket:
                        ' Last dimension value ends with a close bracket
                        ' Get NumElementsX
                        A$ = "LDB": B$ = "[2,S]": C$ = "Get the NumElement": GoSub AO
                        A$ = "LDA": B$ = "1,S": C$ = "A = Low byte of the 16 bit number": GoSub AO
                        A$ = "MUL": C$ = "Multiply A * B, result in D": GoSub AO '                                 Need 16bit multiply
                        A$ = "PSHS": B$ = "D": C$ = "Save the Multiplicand": GoSub AO
                        ' Add dX
                        GoSub GetArrayElementB4Bracket ' Get the value to parse that is before the close bracket ")", Temp$ is the expression to parse
                        Expression$ = Temp$ ' New expression to parse (dimension in the array before a comma)
                        ExType = 0: GoSub ParseNumericExpression ' Go parse the new expression ' Value will end up in D where the Value can never be larger than 255
                        A$ = "ADDD": B$ = ",S": C$ = "D=D+ old D": GoSub AO
                        A$ = "LEAS": B$ = "6,S": C$ = "Fix the stack": GoSub AO
                        A$ = "LSLB": GoSub AO
                        A$ = "ROLA": C$ = "D=D*2, 16 bit integers in the numeric array": GoSub AO
                        num = NumArrayNameParseNum(NumArrayParseNum): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        A$ = "ADDD": B$ = "#_ArrayNum_" + NumArrayNameParseNum$(NumArrayParseNum) + "+" + Num$: C$ = "D points at the start of the destination string": GoSub AO
                        A$ = "TFR": B$ = "D,X": C$ = "X now points at the memory location for the array": GoSub AO
                        ' Apply negation if flagged
                        If negative(PE30Count) = 1 Then
                            ' This is a negative
                            A$ = "LDD": B$ = "#$0000": C$ = "Clear D": GoSub AO
                            A$ = "SUBD": B$ = ",X": C$ = "Going to use the negative verison of " + NumArrayNameParseNum$(NumArrayParseNum): GoSub AO
                        Else
                            A$ = "LDD": B$ = ",X": GoSub AO: StoreFlag = 0
                        End If
                        num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        If num < 10 Then Num$ = "0" + Num$
                        A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO ' Save Temp_Var_NumParseCount
                    End If
                    NumArrayParseNum = NumArrayParseNum - 1
                Else
                    'Check for Numeric command  - should work similarly to a bracket
                    If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFE Then ' FE = Numeric Command
                        ' FE = Numeric Command
                        index(ExpressionCount) = index(ExpressionCount) + 1
                        v = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) * 256 + Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1))
                        index(ExpressionCount) = index(ExpressionCount) + 4 ' Consume the Numeric command and open bracket
                        GoSub JumpToNumericCommand
                        If negative(PE30Count) = 1 Then resultP30(PE30Count) = -resultP30(PE30Count)
                        ' Make D a negative
                        If negative(PE30Count) = 1 Then
                            ' This is a negative
                            A$ = "PSHS": B$ = "D": C$ = "Save D on the stack": GoSub AO
                            A$ = "LDD": B$ = "#$0000": C$ = "Clear D": GoSub AO
                            A$ = "SUBD": B$ = ",S++": C$ = "D is now NEGD, restore the stack": GoSub AO
                        End If
                        num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                        If num < 10 Then Num$ = "0" + Num$
                        A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO ' Save Temp_Var_NumParseCount
                        If Mid$(Expression$(ExpressionCount), index(ExpressionCount), 2) <> Chr$(&HF5) + ")" Then
                            Print "Error3: Expected closing parenthesis in";: GoTo FoundError
                        End If
                        index(ExpressionCount) = index(ExpressionCount) + 2 ' move past the close brackets
                    Else
                        If Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) = &HFB Then ' FB = FN Command
                            ' FB = FN Command
                            index(ExpressionCount) = index(ExpressionCount) + 1
                            v = Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1)) * 256 + Asc(Mid$(Expression$(ExpressionCount), index(ExpressionCount) + 1, 1))
                            index(ExpressionCount) = index(ExpressionCount) + 4 ' Consume the FN command and open bracket
                            GoSub DoFN ' do the FN command
                            If negative(PE30Count) = 1 Then resultP30(PE30Count) = -resultP30(PE30Count)
                            ' Make D a negative
                            If negative(PE30Count) = 1 Then
                                ' This is a negative
                                A$ = "PSHS": B$ = "D": C$ = "Save D on the stack": GoSub AO
                                A$ = "LDD": B$ = "#$0000": C$ = "Clear D": GoSub AO
                                A$ = "SUBD": B$ = ",S++": C$ = "D is now NEGD, restore the stack": GoSub AO
                            End If
                            num = NumParseCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                            If num < 10 Then Num$ = "0" + Num$
                            A$ = "STD": B$ = "_Var_PF" + Num$: GoSub AO ' Save Temp_Var_NumParseCount
                            If Mid$(Expression$(ExpressionCount), index(ExpressionCount), 2) <> Chr$(&HF5) + ")" Then
                                Print "Error4: Expected closing parenthesis in";: GoTo FoundError
                            End If
                            index(ExpressionCount) = index(ExpressionCount) + 2 ' move past the close brackets
                        Else
                            Print "I can't process part of the numeric expression on";: GoTo FoundError
                        End If
                    End If
                End If
            End If
        End If
    End If
End If
'Wend
Parse30_Term = resultP30(PE30Count)
'Print "Parse30_Term="; Parse30_Term, "PE30Count="; PE30Count
PE30Count = PE30Count - 1
Return

' Get the value to parse that is before the &H2C = comma,   return with Temp$ = the expression to parse
GetArrayElementB4Comma:
BracketCount = 1
Temp$ = "" 'init new expression (inside array)
CommaLoop:
i$ = Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1) ' get a byte from inside the array
index(ExpressionCount) = index(ExpressionCount) + 1 ' Keep moving it
If i$ = Chr$(&HF5) Then
    Temp$ = Temp$ + i$
    i$ = Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1) ' get a byte from inside the array
    index(ExpressionCount) = index(ExpressionCount) + 1 ' Keep moving it
    If i$ = "(" Then BracketCount = BracketCount + 1 ' if it's an open bracket then there is probably an array or numeric command
    If i$ = ")" Then BracketCount = BracketCount - 1 ' just found a close bracket, maybe the end of another array or numeric command
    If i$ = "," And BracketCount = 1 Then GoTo DoneCommaLoop ' If we find a comma and it's inside our array level then we got everything inside it
End If
Temp$ = Temp$ + i$
GoTo CommaLoop
DoneCommaLoop: ' We got the expression before the comma in the array
Temp$ = Left$(Temp$, Len(Temp$) - 1)
Return

' Get the value to parse that is before the close bracket ")",  return with Temp$ = the expression to parse
GetArrayElementB4Bracket:
BracketCount = 1
Temp$ = "" 'init new expression (inside array)
BracketLoop:
i$ = Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1) ' get a byte from inside the array
index(ExpressionCount) = index(ExpressionCount) + 1 ' Keep moving it
If i$ = Chr$(&HF5) Then
    Temp$ = Temp$ + i$
    i$ = Mid$(Expression$(ExpressionCount), index(ExpressionCount), 1) ' get a byte from inside the array
    index(ExpressionCount) = index(ExpressionCount) + 1 ' Keep moving it
    If i$ = "(" Then BracketCount = BracketCount + 1 ' if it's an open bracket then there is probably an array or numeric command
    If i$ = ")" Then BracketCount = BracketCount - 1 ' just found a close bracket, maybe the end of another array or numeric command
    If i$ = ")" And BracketCount = 0 Then GoTo DoneBracketLoop ' If we find a bracket and it's inside our array level then we got everything inside it
End If
Temp$ = Temp$ + i$
GoTo BracketLoop
DoneBracketLoop: ' We got the expression before the bracket in the array
Temp$ = Left$(Temp$, Len(Temp$) - 1)
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

' Return with decoded command/variable in Temp$
' Tokens for variables type:
' &HF0 = Numeric Arrays           (4 Bytes)
' &HF1 = String Arrays            (3 Bytes)
' &HF2 = Regular Numeric Variable (3 Bytes)
' &HF3 = Regular String Variable  (3 Bytes)
' &HF4 = Floating Point Variable  (3 Bytes)
' &HF5 = Special characters like a EOL, colon, comma, semi colon, quote, brackets    (2 Bytes)

' &HFB = DEF FN Function
' &HFC = Operator Command (2 Bytes)
' &HFD = String Command  (3 Bytes)
' &HFE = Numeric Command (3 Bytes)
' &HFF = General Command (3 Bytes)

DecodeToken:
Temp$ = ""
If v = &HF0 Then 'Numeric Array Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = NumericArrayVariables$(v)
    v = Array(x): x = x + 1 'v= number of elements in the array
    Return
End If
If v = &HF1 Then 'String Array Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = StringArrayVariables$(v) + "$" ' add the $ back in to show it's a string
    v = Array(x): x = x + 1 'v= number of elements in the array
    Return
End If
If v = &HF2 Then 'Regular Numeric Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = NumericVariable$(v): Return
End If
If v = &HF3 Then 'Regular String Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = StringVariable$(v) + "$" ' add the $ back in to show it's a string
    Return
End If
If v = &HF4 Then 'Floating Point Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = FloatVariable$(v): Return
End If
If v = &HF5 Then ' Special Characters
    v = Array(x): x = x + 1
    If v = &H22 Then
        'We found a quote, copy everything inside the quotes to Temp$
        While v <> &HF5 ' keep copying until we get an end quote
            Temp$ = Temp$ + Chr$(v)
            v = Array(x): x = x + 1
        Wend
        v = Array(x): x = x + 1
    End If
    Temp$ = Temp$ + Chr$(v)
    Return
End If
If v = &HFB Then ' Pointer for the label of a DEF FN command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = DefLabel$(v): Return
    Return
End If
If v = &HFC Then 'Operator Command
    v = Array(x): x = x + 1
    Temp$ = OperatorCommands$(v): Return
End If
If v = &HFD Then 'String Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = StringCommands$(v): Return
End If
If v = &HFE Then 'Numeric Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = NumericCommands$(v): Return
End If
If v = &HFF Then 'General Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp$ = GeneralCommands$(v)
    If Temp$ = "'" Or Temp$ = "REM" Then
        Temp$ = Temp$ + " "
        Do Until v = &H0D And Array(x - 2) = &HF5 ' keep copying until we get an EOL
            GoSub DecodeInREMark
            Temp$ = Temp$ + Temp1$
        Loop
        Temp$ = Left$(Temp$, Len(Temp$) - 1) 'remove last $0D
        x = x - 2
    End If
    Return
End If
Print " Error decoding line, V= $"; Hex$(v), Hex$(x): System

DecodeInREMark:
Temp1$ = ""
v = Array(x): x = x + 1
If v = &HF0 Then 'Numeric Array Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = NumericArrayVariables$(v)
    v = Array(x): x = x + 1 'v= number of elements in the array
    Return
End If
If v = &HF1 Then 'String Array Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = StringArrayVariables$(v) + "$" ' add the $ back in to show it's a string
    v = Array(x): x = x + 1 'v= number of elements in the array
    Return
End If
If v = &HF2 Then 'Regular Numeric Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = NumericVariable$(v): Return
End If
If v = &HF3 Then 'Regular String Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = StringVariable$(v) + "$" ' add the $ back in to show it's a string
    Return
End If
If v = &HF4 Then 'Floating Point Variable
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = FloatVariable$(v): Return
End If
If v = &HF5 Then ' Special Characters
    v = Array(x): x = x + 1
    If v = &H22 Then
        'We found a quote, copy everything inside the quotes to Temp$
        While v <> &HF5 ' keep copying until we get an end quote
            Temp1$ = Temp1$ + Chr$(v)
            v = Array(x): x = x + 1
        Wend
        v = Array(x): x = x + 1
    End If
    Temp1$ = Temp1$ + Chr$(v)
    Return
End If
If v = &HFB Then ' Pointer for the label of a DEF FN command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = DefLabel$(v): Return
    Return
End If
If v = &HFC Then 'Operator Command
    v = Array(x): x = x + 1
    Temp1$ = OperatorCommands$(v): Return
End If
If v = &HFD Then 'String Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = StringCommands$(v): Return
End If
If v = &HFE Then 'Numeric Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = NumericCommands$(v): Return
End If
If v = &HFF Then 'General Command
    v = Array(x) * 256 + Array(x + 1): x = x + 2
    Temp1$ = GeneralCommands$(v) + " "
    Return
End If
Temp1$ = Temp1$ + Chr$(v)
Return

'Convert number in Num to a string without spaces as Num$
NumAsString:
If num = 0 Then
    Num$ = "0"
Else
    If num > 0 Then
        'Postive value remove the first space in the string
        Num$ = Right$(Str$(num), Len(Str$(num)) - 1)
    Else
        'Negative value we keep the minus sign
        Num$ = Str$(num)
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
    Print ii, Hex$(Asc(Mid$(show$, ii, 1)))
Next ii
Input q
If q = 1 Then System
Return

' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
NumToMSBLSBString:
MSB = Int(num / 256)
LSB = num - MSB * 256
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

' Gets the Numeric Command number, returns with number in ii, Found=1 if found and Found=0 if not found
FindNumCommandNumber:
Found = 0
For ii = 0 To NumericCommandsCount
    If NumericCommands$(ii) = Check$ Then
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

' Evaluate the Expression in NewExpression$ and return with the numerical value in D
EvaluateNewExpression:
Num$ = ""
Expression$ = NewExpression$
GoSub DirectTokenizeExpression
GoSub NewParseExpression
Return

' Tokenize the expression into operators and operands, handling hex values
DirectTokenizeExpression:
operators$ = "+-*/\^"
valueIndex = 0
opIndex = 0
length = Len(Expression$)
I = 1
Do While I <= length
    char$ = Mid$(Expression$, I, 1)

    ' Check for unary minus
    If char$ = "-" Then
        If I = 1 Or InStr(operators$ + "(", Mid$(Expression$, I - 1, 1)) Then
            ' It's a unary minus, so treat the next number as negative
            Num$ = "-"
            I = I + 1
            char$ = Mid$(Expression$, I, 1)
        End If
    End If

    If InStr("0123456789.", char$) Then
        Num$ = Num$ + char$
        Do While I < length And InStr("0123456789.", Mid$(Expression$, I + 1, 1))
            I = I + 1
            Num$ = Num$ + Mid$(Expression$, I, 1)
        Loop
        valueIndex = valueIndex + 1
        values(valueIndex) = Val(Num$)
        Num$ = "" ' Reset for the next number
    ElseIf Mid$(Expression$, I, 2) = "&H" Then
        Num$ = "&H"
        I = I + 2
        Do While I <= length And InStr("0123456789ABCDEFabcdef", Mid$(Expression$, I, 1))
            Num$ = Num$ + Mid$(Expression$, I, 1)
            I = I + 1
        Loop
        valueIndex = valueIndex + 1
        values(valueIndex) = Val(Num$)
        I = I - 1 ' Adjust for the next loop
    ElseIf InStr(operators$, char$) Then
        ' Handle operator precedence as before
        Precedence$ = ops(opIndex)
        GoSub Precedence
        currentPrecedence = Precedence

        Precedence$ = char$
        GoSub Precedence
        nextPrecedence = Precedence

        While opIndex > 0 And currentPrecedence >= nextPrecedence
            GoSub NewApplyOperator
            valueIndex = valueIndex - 1
            values(valueIndex) = result
            opIndex = opIndex - 1

            If opIndex > 0 Then
                Precedence$ = ops(opIndex)
                GoSub Precedence
                currentPrecedence = Precedence
            End If
        Wend
        opIndex = opIndex + 1
        ops(opIndex) = char$
    ElseIf char$ = "(" Then
        opIndex = opIndex + 1
        ops(opIndex) = char$
    ElseIf char$ = ")" Then
        While ops(opIndex) <> "("
            GoSub NewApplyOperator
            valueIndex = valueIndex - 1
            values(valueIndex) = result
            opIndex = opIndex - 1
        Wend
        opIndex = opIndex - 1 ' Remove the "(" from the stack
    End If
    I = I + 1
Loop

' Apply remaining operators after processing the expression
While opIndex > 0
    GoSub NewApplyOperator
    valueIndex = valueIndex - 1
    values(valueIndex) = result
    opIndex = opIndex - 1
Wend
Return

' Parse and evaluate the tokenized expression
NewParseExpression:
' The evaluation is now handled directly in the DirectTokenizeExpression subroutine
D = values(1)
Return

' Apply the operator to two operands
NewApplyOperator:
Select Case ops(opIndex)
    Case "+"
        result = values(valueIndex - 1) + values(valueIndex)
    Case "-"
        result = values(valueIndex - 1) - values(valueIndex)
    Case "*"
        result = values(valueIndex - 1) * values(valueIndex)
    Case "/"
        result = values(valueIndex - 1) / values(valueIndex)
    Case "\"
        result = values(valueIndex - 1) \ values(valueIndex)
    Case "^"
        result = values(valueIndex - 1) ^ values(valueIndex)
End Select
Return

' Determine the precedence of operators using GOSUB
Precedence:
Select Case Precedence$
    Case "+", "-"
        Precedence = 1
    Case "*", "/", "\"
        Precedence = 2
    Case "^"
        Precedence = 3
    Case Else
        Precedence = 0
End Select
Return

' Get General Expression
' Returns with single expression in GenExpression$
GetGenExpression:
v = Array(x): x = x + 1
GenExpression$ = Chr$(v)
If v < &HF0 Then Return ' Copy single byte, as is
'We have a Token
Select Case v
    Case &HF0, &HF1: ' Found a Numeric or String array
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of Array ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of Array ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy # of dimensions
    Case &HF2, &HF3: ' Found a numeric or string variable
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of variable ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of variable ID
    Case &HF5 ' Found a special character
        v = Array(x): x = x + 1
        GenExpression$ = GenExpression$ + Chr$(v) ' Copy special character
    Case &HFB: ' Found a DEF FN Function
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of FN ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of FN ID
    Case &HFC: ' Found an Operator
        v = Array(x): x = x + 1
        GenExpression$ = GenExpression$ + Chr$(v) ' Operator character
    Case &HFD, &HFE, &HFF: 'Found String,Numeric or General command
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy MSB of command ID
        GenExpression$ = GenExpression$ + Chr$(Array(x)): x = x + 1 ' Copy LSB of command ID
End Select
Return

' Get an Expression before a semi colon, a comma a quote, an &HF1,&HF3 or &HFD an EOL/Colon     (Makes sure to ignore commas inside brackets like a 2 or more dimension array)
GetExB4SemiComQ13D_EOL:
Expression$ = ""
InBracket = 0
GEB4SemiComQ13D_EOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = &H0D Or Sp = &H3A Or Sp = &H3B Or Sp = &H22 Then x = x - 2: Return ' IF EOL/Colon, semicolon, a comma or a quote then point at it again and return
    ' Make sure we are not inside brackets when we get a comma
    If Sp = &H2C And InBracket = 0 Then x = x - 2: Return ' If a comma point at it again and return
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
End If
If Left$(GenExpression$, 1) = Chr$(&HF1) And InBracket = 0 Then x = x - 4: Return 'Found a string array, point at it again and return
If Left$(GenExpression$, 1) = Chr$(&HF3) And InBracket = 0 Then x = x - 3: Return 'Found a string variable, point at it again and return
If Left$(GenExpression$, 1) = Chr$(&HFD) And InBracket = 0 Then x = x - 3: Return 'Found a string command, point at it again and return
Expression$ = Expression$ + GenExpression$
GoTo GEB4SemiComQ13D_EOL

'Handle an expression that ends with a comma or EOL, skip brackets
GetExpressionB4CommaEOL:
Expression$ = ""
InBracket = 0
GEB4CommaEOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If GenExpression$ = Chr$(&HF5) + Chr$(&H0D) Or GenExpression$ = Chr$(&HF5) + Chr$(&H3A) Then x = x - 2: Return ' IF EOL/Colon point at it again and return
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = &H0D Or Sp = &H3A Then x = x - 2: Return ' IF EOL/Colon, or a quote then point at it again and return
    If Sp = &H2C And InBracket = 0 Then x = x - 2: Return ' If a comma point at it again and return
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4CommaEOL

'Handle an expression that ends with a colon or End of a Line
GetExpressionB4EOL:
Expression$ = ""
GEB4EOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If GenExpression$ = Chr$(&HF5) + Chr$(&H0D) Or GenExpression$ = Chr$(&HF5) + Chr$(&H3A) Then x = x - 2: Return ' IF EOL/Colon point at it again and return
Expression$ = Expression$ + GenExpression$
GoTo GEB4EOL

'Handle an expression that ends with a comma skip brackets
GetExpressionB4Comma:
Expression$ = ""
InBracket = 0
GEB4Comma:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Asc(Right$(GenExpression$, 1)) = &H2C And InBracket = 0 Then x = x - 2: Return ' If a comma point at it again and return
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4Comma

'Handle an expression that ends with a close bracket
GetExpressionB4EndBracket:
Expression$ = ""
InBracket = 0
GEB4EndBracket:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = Asc(")") And InBracket < 1 Then x = x - 2: Return ' If last close bracket then point at it again and return
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4EndBracket

'Handle an expression that ends with a colon or End of a Line or a general command like TO or STEP
GetExpressionB4EOLOrCommand:
Expression$ = ""
GEB4EOLOrCommand:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HFF) Then x = x - 3: Return 'point at the command and return
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = &H0D Or Sp = &H3A Then x = x - 2: Return ' IF EOL/Colon then point at it again and return
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4EOLOrCommand

' Get an Expression before a semi colon, a plus, a comma a quote an EOL/Colon
GetExpressionB4SemiPlusComQ_EOL:
Expression$ = ""
GEB4SemiPlusComQ_EOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = &H0D Or Sp = &H3A Or Sp = &H3B Or Sp = &H2C Or Sp = &H22 Then x = x - 2: Return ' IF EOL/Colon, semicolon, a comma or a quote then point at it again and return
End If
If Left$(GenExpression$, 1) = Chr$(&HFC) And Right$(GenExpression$, 1) = Chr$(&H2B) Then x = x - 2: Return 'Found a plus point at it again and return
Expression$ = Expression$ + GenExpression$
GoTo GEB4SemiPlusComQ_EOL

' Get an Expression before a semi colon, a comma or an EOL
GetExpressionB4SemiComEOL:
Expression$ = ""
GEB4SemiComEOL:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = &H0D Or Sp = &H3A Or Sp = &H3B Or Sp = &H2C Then x = x - 2: Return ' IF EOL/Colon, semicolon, a comma or a quote then point at it again and return
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4SemiComEOL
'Handle an expression that ends with a comma or end bracket skipping extra brackets
GetExpressionB4CommaEndBracket:
Expression$ = ""
InBracket = 0
GEB4CommaEndBracket:
GoSub GetGenExpression ' Returns with single expression in GenExpression$
If Left$(GenExpression$, 1) = Chr$(&HF5) Then
    ' Found a special character
    Sp = Asc(Right$(GenExpression$, 1))
    If Sp = &H2C And InBracket = 0 Then x = x - 2: Return ' If a comma point at it again and return
    If Sp = Asc(")") And InBracket = 0 Then x = x - 2: Return ' If last close bracket then point at it again and return
    If Sp = Asc("(") Then InBracket = InBracket + 1
    If Sp = Asc(")") Then InBracket = InBracket - 1
End If
Expression$ = Expression$ + GenExpression$
GoTo GEB4CommaEndBracket

' All commands use: 'Commands.bas'
' Minimal commands use: 'CommandsMin.bas'
' $Include: 'Commands.bas'



