$ScreenHide
$Console
_Dest _Console
Verbose = 0

Dim Array(270000) As _Unsigned _Byte
Dim INArray(270000) As _Unsigned _Byte

Dim LabelName$(100000)

Dim NumericVariable$(100000)
Dim NumericVariableCount As Integer
Dim NumericVarType(65535) As _Byte ' Holds the type of every variable

Dim FloatVariable$(100000)
Dim FloatVariableCount As Integer

Dim NumericArrayBits(100000) As Integer
Dim NumericArrayVariables$(100000), NumericArrayDimensions(100000) As Integer, NumericArrayDimensionsVal$(100000)
Dim NumericArrayType(65535) As _Byte ' Holds the type of every Numeric Array
Dim StringArrayBits(100000) As Integer
Dim StringArrayVariables$(100000), StringArrayDimensions(100000) As Integer, StringArrayDimensionsVal$(100000)
Dim StringVariable$(100000)
Dim StringVariableCounter As Integer

Dim ConstName$(20000)
Dim ConstValue$(20000)
Dim ConstCount As Integer


Dim CF_Val(1024) As Double
Dim CF_Op$(1024)
Dim CF_VSP As Integer
Dim CF_OSP As Integer
Dim CF_PrevTok As Integer
Dim CF_Error As Integer
Dim CF_Result As Double
Dim CF_FoldOK As Integer
Dim CF_Folded$
Dim CF_TempExpr$
Dim CF_RI64 As _Integer64
Dim CF_N64 As _Integer64
Dim CF_Eps As Double
Dim CF_r As Double
Dim CF_a As Double
Dim CF_b As Double
Dim CF_num As Double



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
Dim Sprite$(255)
Dim SpriteHeight(255)
Dim SpriteNumberOfFrames(255)
Dim SpriteLivesAt(255)
Dim Sample$(255)
Dim SampleStart(255)
Dim SampleStartBlock(255)
Dim SampleNumberOfBLKs(255)
Dim SampleLength(255)

Dim IncludeList$(10000)

Dim DefLabel$(10000)
Dim DefVar(1000) As Integer

Dim GModeLib(200) As Integer
Dim GModePageLib(200) As Integer

Dim DimType As _Unsigned _Byte

' Variable Type Constants
Const NT_Bit = 1
Const NT_UBit = 2
Const NT_Byte = 3
Const NT_UByte = 4
Const NT_Int16 = 5
Const NT_UInt16 = 6
Const NT_Int32 = 7
Const NT_UInt32 = 8
Const NT_Int64 = 9
Const NT_UInt64 = 10
Const NT_Single = 11
Const NT_Double = 12

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
GMode$(16) = "Full_graphic_6_R" '     Full graphic 6-R      1   1   1   1   1 1 0   256x192x2 $1800(6144)

GModeName$(0) = "IA": GModeMaxX$(0) = "31": GModeMaxY$(0) = "15": GModeStartAddress$(0) = "400": GModeScreenSize$(0) = "200": GModeColours$(0) = "2"
GModeName$(1) = "EA": GModeMaxX$(1) = "31": GModeMaxY$(1) = "15": GModeStartAddress$(1) = "400": GModeScreenSize$(1) = "200": GModeColours$(1) = "2"
GModeName$(2) = "SG4": GModeMaxX$(2) = "63": GModeMaxY$(2) = "31": GModeStartAddress$(2) = "400": GModeScreenSize$(2) = "200": GModeColours$(2) = "2"
GModeName$(3) = "SG4H": GModeMaxX$(3) = "63": GModeMaxY$(3) = "31": GModeStartAddress$(3) = "E00": GModeScreenSize$(3) = "800": GModeColours$(3) = "9"
GModeName$(4) = "SG6": GModeMaxX$(4) = "63": GModeMaxY$(4) = "47": GModeStartAddress$(4) = "400": GModeScreenSize$(4) = "200": GModeColours$(4) = "2"
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

Check$ = "SELECT": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_SELECT = ii
Check$ = "EVERYCASE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_EVERYCASE = ii

Check$ = "DIM": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_DIM = ii
Check$ = "AS": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_AS = ii
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
Check$ = "SPRITE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_SPRITE = ii
Check$ = "SAMPLE_LOAD": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_SAMPLE_LOAD = ii
Check$ = "PLAYFIELD": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_PLAYFIELD = ii


Check$ = "_BIT": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_UBIT = ii
Check$ = "_UNSIGNED": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_UNSIGNED = ii
Check$ = "_BYTE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_UBYTE = ii
Check$ = "INTEGER": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_INTEGER = ii
Check$ = "LONG": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_LONG = ii
Check$ = "_INTEGER64": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_INTEGER64 = ii
Check$ = "SINGLE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_SINGLE = ii
Check$ = "DOUBLE": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_DOUBLE = ii
Check$ = "_FLOAT": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_UFLOAT = ii
Check$ = "_SHORT": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_USHORT = ii
Check$ = "_SHORT512": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_USHORT512 = ii
Check$ = "_SHORT1024": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_USHORT1024 = ii
Check$ = "_SHORT2048": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_USHORT2048 = ii
Check$ = "_SHORT4096": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_USHORT4096 = ii
Check$ = "_SHORT8192": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_USHORT8192 = ii
Check$ = "_SHORT16384": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_USHORT16384 = ii
Check$ = "_SHORT32768": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_USHORT32768 = ii

WidthVal$ = "" ' default no width command
' Handle command line options
FI = 0
count = _CommandCount
If count = 0 Then
    Print "Compiler has no options given to it"
    System
End If
nt = 0: newp = 0: endp = 0: StringArraySize = 16: AutoStart = 0
Optimize = 2 ' Default to optimize level 2
For check = 1 To count
    N$ = Command$(check)
    If LCase$(Left$(N$, 2)) = "-c" Then BASICMode = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-s" Then StringArraySize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-o" Then Optimize = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-v" Then Verbose = Val(Right$(N$, Len(N$) - 2)): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-p" Then ProgramStart$ = Right$(N$, Len(N$) - 2): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-f" Then Font$ = Right$(N$, Len(N$) - 2): GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 2)) = "-a" Then AutoStart = 1: GoTo CheckNextCMDOption
    If LCase$(Left$(N$, 7)) = "-dragon" Then Dragon = 1: GoTo CheckNextCMDOption
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
' --- Normalize line endings: convert LF (0A) to CR (0D) ---
For ii = 0 To length - 1
    If Array(ii) = &H0A Then Array(ii) = &H0D
Next ii

Array(length) = &H0D: length = length + 1 ' add one last EOL

' Get the line Labels first so we can recognize them if there is a forward reference to a Label we haven't come across yet
NumericVariableCount = 0 ' Numeric variable name count
NumericVariable$(NumericVariableCount) = "Timer" ' Make the first variable the TIMER
NumericVarType(NumericVariableCount) = NT_UInt16
NumericVariableCount = NumericVariableCount + 1 ' Numeric variable name count

x = 0
INx = 0
lc = 0
LineCount = 0
FloatVariableCount = 0 ' Floating Point variable name count
StringVariableCounter = 0 ' String variable name count
ConstCount = 0 ' CONST name count
CommandsUsedCounter = 0 ' Counter for unique commmands used
NumArrayVarsUsedCounter = 0 ' Counter for number of NumericArrays used
StringArrayVarsUsedCounter = 0 ' Counter for number of String Array Variables used

Dim EveryCase(1000) As Integer
Dim EveryCaseCounter As Integer
EveryCaseCounter = 0
Dim SelectCounter As Single
SelectCounter = 0

Check$ = "REM": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_REM = ii
While x < length - 1 ' Loop until we've processed the entire BASIC program
    ' Start of new line
    ' Searching for Inline assembly -  read a full line
    y = x
    v = 0
    Temp$ = ""
    Do Until x >= length Or v = &H0D
        v = Array(x): x = x + 1
        Temp$ = Temp$ + Chr$(v)
    Loop
    p = InStr(Temp$, "ADDASSEM")
    If p > 0 Then
        ' We found the start of some inline assembly
        ' Ignore any labels found here...
        'copy lines unaltered until we get a ENDASSEM
        REM_AddCodeAlpha0:
        Temp$ = ""
        v = 0
        Do Until x >= length Or v = &H0D
            v = Array(x): x = x + 1
            Temp$ = Temp$ + Chr$(v)
        Loop
        ' Check if this line is the last
        If InStr(Temp$, "ENDASSEM") = 0 Then GoTo REM_AddCodeAlpha0
    Else
        x = y
    End If
    CheckLineSpaces0:
    v = Array(x): x = x + 1
    If v = &H20 Then GoTo CheckLineSpaces0 ' Skip spaces at the beginning of a line
    If v = &H0D Or v = &H0A Then GoTo GotLabel ' Skip to the bottom if we get a line feed or carriage return, this is an empty line
    Tokenized$ = ""
    CurrentLine$ = ""
    'Figure out if we have a line number or a label:
    If v >= Asc("0") And v <= Asc("9") Then ' Check if line starts with a number
        'Does start with a number
        LineCount = LineCount + 1
        While v >= Asc("0") And v <= Asc("9") ' is it a number?
            LabelName$(LineCount) = LabelName$(LineCount) + Chr$(v)
            v = Array(x): x = x + 1
        Wend
        If Verbose > 0 Then Print "Scanning line "; LabelName$(LineCount)
        CurrentLine$ = LabelName$(LineCount)
        If IsNumber(LabelName$(LineCount)) = 0 Then Print "Error: There's something wrong with the Line number or Label "; LabelName$(LineCount): System
        If v = &H0D Then
            ' this is a number line only
            GoTo GotLabel ' Skip to the bottom if we get a line feed or carriage return, this is an empty line
        End If
    Else
        'Not a line number, figure out if this line starts with a BASIC command
        T = Asc(UCase$(Chr$(v)))
        If T >= Asc("A") And T <= Asc("Z") Then
            'Maybe found a label
            Check$ = ""
            y = x - 1
            While v <> Asc(":") And v <> &H0D And v <> &H0A And v <> Asc(" ")
                Check$ = Check$ + Chr$(v)
                v = Array(x): x = x + 1
            Wend
            CheckLC$ = Check$
            If v = Asc(":") And Array(x) = &H0D Then
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
    v = Array(x): x = x + 1
    While v <> &H0D
        v = Array(x): x = x + 1
    Wend
    GotLabel:
Wend

' Get commands and variables used in program
' Tokenize the text version of the BASIC program to make it easier to handle parsing expressions
' ------------------------------------------------------------
' Pass 0: Collect CONST definitions (compile-time constants)
'   Supported (v1): CONST name = <numeric literal>  or  CONST name$ = "string literal"
'   The CONST lines themselves are removed from the token stream.
' ------------------------------------------------------------
If Verbose > 0 Then Print "Doing Pass 0 - Collecting CONST definitions..."
ConstCount = 0
x = 0
While x < length - 1
    TempLine$ = ""
    ' Read one full source line (without CR)
    Do
        v = Array(x): x = x + 1
        If x >= length Then Exit Do
        If v = &H0D Then Exit Do
        TempLine$ = TempLine$ + Chr$(v)
    Loop
    ' Remove leading spaces
    p = 1
    While p <= Len(TempLine$) And Mid$(TempLine$, p, 1) = " "
        p = p + 1
    Wend

    ' Ignore comment-only lines early
    If p <= Len(TempLine$) Then
        If Mid$(TempLine$, p, 1) = "'" Then GoTo Pass0_NextLine
    End If

    ' In Pass 0 we must NOT blindly skip the first token.
    ' Only skip it if it is a line number (all digits) or a label (token ends with ':').
    p0 = p
    t$ = ""
    While p <= Len(TempLine$) And Mid$(TempLine$, p, 1) <> " "
        t$ = t$ + Mid$(TempLine$, p, 1)
        p = p + 1
    Wend
    tU$ = UCase$(t$)

    IsDigits = -1
    If Len(tU$) = 0 Then IsDigits = 0
    For k = 1 To Len(tU$)
        ch$ = Mid$(tU$, k, 1)
        If ch$ < "0" Or ch$ > "9" Then IsDigits = 0
    Next k

    IsLabel = 0
    If Len(tU$) > 0 Then
        If Right$(tU$, 1) = ":" Then IsLabel = -1
    End If

    If IsDigits <> 0 Or IsLabel <> 0 Then
        While p <= Len(TempLine$) And Mid$(TempLine$, p, 1) = " "
            p = p + 1
        Wend
    Else
        p = p0
    End If

    Expression$ = Mid$(TempLine$, p)
    If Len(Expression$) > 0 Then
        If UCase$(Left$(LTrim$(Expression$), 5)) = "CONST" Then
            Expression$ = LTrim$(Expression$)
            GoSub ParseConstLine
        End If
    End If
    Pass0_NextLine:
Wend

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
    v = 0
    Temp$ = ""
    Do Until x >= length Or v = &H0D
        v = Array(x): x = x + 1
        Temp$ = Temp$ + Chr$(v)
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
        v = 0
        Temp$ = ""
        Do Until x >= length Or v = &H0D
            v = Array(x): x = x + 1
            Temp$ = Temp$ + Chr$(v)
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
    v = Array(x): x = x + 1
    If v = &H20 Then GoTo ScanNextLine ' Skip spaces at the beginning of a line
    If v = &H0D Then GoTo ScanNextLine ' Skip to the bottom if we get a line feed or carriage return, this is an empty line
    Tokenized$ = ""
    CurrentLine$ = ""
    'Figure out if we have a line number or a label:
    If v >= Asc("0") And v <= Asc("9") Then ' Check if line starts with a number
        'Does start with a number
        LineCountB = LineCountB + 1
        While v >= Asc("0") And v <= Asc("9") ' is it a number?
            '  LabelName$(LineCountB) = LabelName$(LineCountB) + Chr$(v)
            v = Array(x): x = x + 1
        Wend
        If Verbose > 0 Then Print "Scanning line "; LabelName$(LineCount)
        CurrentLine$ = LabelName$(LineCountB)
        If IsNumber(LabelName$(LineCountB)) = 0 Then
            Print "There's something wrong with the Line number or Label "; LabelName$(LineCountB): System
        End If
        If v = &H0D Then
            ' this is a number line only
            GoTo ScanNextLine ' Skip to the bottom if we get a line feed or carriage return, this is an empty line
        End If
    Else
        'Not a line number, figure out if this line starts with a BASIC command
        T = Asc(UCase$(Chr$(v)))
        If T >= Asc("A") And T <= Asc("Z") Then
            'Maybe found a label
            Check$ = ""
            Start = x - 1
            While v <> Asc(":") And v <> &H0D And v <> Asc(" ")
                Check$ = Check$ + Chr$(v)
                v = Array(x): x = x + 1
            Wend
            If v = Asc(":") And Array(x) = &H0D Then
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
            v = Array(x): x = x + 1
        End If
    End If
    ' Get the first argument/command
    ' No line number or label
    GetFirstArg:
    Expression$ = ""
    ColonCount = 0
    If v = &H20 Then v = Array(x): x = x + 1 ' skip past the first space on the line
    'Get the rest of this line as it is
    While v <> &H0D And x < length
        If v = &H22 Then ' is it a quote"
            Expression$ = Expression$ + Chr$(v)
            v = Array(x): x = x + 1
            ' Yes deal with text in quotes, copy all until we get an end quote or RETURN
            While v <> &H22 And v <> &H0D
                Expression$ = Expression$ + Chr$(v)
                v = Array(x): x = x + 1
            Wend
            If v = &H0D Then
                ' we got the end of the line without an end quote, let's add one
                Expression$ = Expression$ + Chr$(&H22)
                GoTo DoneGetFirstArg
            End If
            If v = &H22 Then ' did we get the end quote?
                'Yes got the end quote
                Expression$ = Expression$ + Chr$(v)
                GoTo GetMoreArgs
            End If
        Else
            ' Not inside a quote
            If v = Asc(":") Then
                Expression$ = Expression$ + Chr$(&HF5) ' flag colons as special characters $F53A
                While Array(x) = Asc(" ")
                    x = x + 1 ' skip the spaces after a ":"
                Wend
            End If
            If v = Asc("?") Then ' Change ? to a PRINT command
                Expression$ = Expression$ + "PRINT "
            Else
                Expression$ = Expression$ + Chr$(v)
            End If
        End If
        GetMoreArgs:
        v = Array(x): x = x + 1
    Wend
    DoneGetFirstArg:
    If InStr(0, Expression$, "THEN " + Chr$(&HF5) + ":") > 0 Then
        ' Fix THEN :ELSE to be THEN ELSE
        While InStr(0, Expression$, "THEN " + Chr$(&HF5) + ":") > 0
            Expression$ = Left$(Expression$, InStr(0, Expression$, "THEN " + Chr$(&HF5) + ":") + 4) + Right$(Expression$, Len(Expression$) - InStr(0, Expression$, "THEN " + Chr$(&HF5) + ":") - 6)
        Wend
    End If
    '   show$ = Expression$: GoSub show
    ' Handle CONST:
    '   - CONST lines are compile-time only and are removed from output.
    '   - Any previously defined constants are expanded before tokenization.
    If UCase$(Left$(LTrim$(Expression$), 5)) = "CONST" Then
        Tokenized$ = ""
        GoTo LabelOnlyLine
    End If
    GoSub ExpandConstsInExpression

    GoSub TokenizeExpression ' Go tokenize Expression$
    LabelOnlyLine:
    Tokenized$ = Chr$(Len(CurrentLine$)) + CurrentLine$ + Tokenized$ + Chr$(&HF5) + Chr$(&H0D) ' Line ends with $F50D
    '  show$ = Tokenized$: GoSub show
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
    v = Array(x): x = x + 1 ' get a byte
    INArray(c) = v: c = c + 1 'write byte to ouput array
    If v = &HFF And Array(x) * 256 + Array(x + 1) = C_IF Then
        'It is an IF command
        v = Array(x): x = x + 1 ' get the command to do
        INArray(c) = v: c = c + 1 ' write byte to ouput array
        v = Array(x): x = x + 1 ' get the command to do
        INArray(c) = v: c = c + 1 ' write byte to ouput array
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
        Do Until v = &HFF And (Array(x) * 256 + Array(x + 1) = C_THEN Or Array(x) * 256 + Array(x + 1) = C_GOTO) ' If we come across a GOTO instead of a THEN, make it a THEN
            v = Array(x): x = x + 1 ' get a byte
            INArray(c) = v: c = c + 1 ' write byte to ouput array
        Loop 'loop until we find a THEN or GOTO command
        ' Just in case we found a GOTO instead of a THEN, change it to a THEN
        ' Make it a THEN even if it was a GOTO
        Num = C_THEN: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
        INArray(c) = MSB: c = c + 1: INArray(c) = LSB: c = c + 1 ' write command to ouput array
        x = x + 2 ' skip forward past command number
        ' Print "Checking for stuff after the THEN"
        v = Array(x) ' get a byte
        If Array(x) = &HF5 And Array(x + 1) = &H3A Then
            While Array(x) = &HF5 And Array(x + 1) = &H3A: x = x + 2: Wend ' consume any colons directly after the THEN
            v = Array(x): x = x + 1
        Else
            x = x + 1
        End If
        If v = (&HF5 And Array(x) = &H0D) Or (v = &HFF And Array(x) * 256 + Array(x + 1) = C_REM) Or (v = &HFF And Array(x) * 256 + Array(x + 1) = C_REMApostrophe) Then ' After THEN do we have an EOL, or REMarks?
            ' if so this is already an IF/THEN/ELSE/ELSEIF/ENDIF so don't need to change it to be a multi line IF
            INArray(c) = v: c = c + 1 ' write byte to ouput array
            If v = &HF5 And Array(x) = &H0D Then INArray(c) = &H0D: c = c + 1: x = x + 1
        Else
            ' Print "not a multi line IF "; Hex$(V)
            ' This is a one line IF/THEN/ELSE command that ends with a $F5 $0D
            ' Make it a multi line IF THEN ELSE
            ' We've copied everything upto and including the THEN
            ' Make the byte after the THEN an EOL
            IfCounter = 1
            INArray(c) = &HF5: c = c + 1 ' Add EOL
            INArray(c) = &H0D: c = c + 1 ' Add EOL
            INArray(c) = 0: c = c + 1 ' start of next line - line label length of zero
            'Check for a number could be IF THEN 50
            If v >= Asc("0") And v <= Asc("9") Then
                ' Found first line number, change it to a new line with GOTO linenumber
                INArray(c) = &HFF: c = c + 1 ' General command
                Num = C_GOTO: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                INArray(c) = MSB: c = c + 1: INArray(c) = LSB: c = c + 1 ' write command to ouput array
                While v >= Asc("0") And v <= Asc("9")
                    INArray(c) = v: c = c + 1 ' write line number
                    v = Array(x): x = x + 1 ' copy the line number
                Wend
                INArray(c) = &HF5: c = c + 1 ' Add EOL
                INArray(c) = &H0D: c = c + 1 ' Add EOL
                INArray(c) = 0: c = c + 1 ' line label length of zero
            Else
                ' Could already be a GOTO, add and EOL after if so
                If v = &HFF And Array(x) * 256 + Array(x + 1) = C_GOTO Then
                    ' Found a GOTO
                    INArray(c) = v: c = c + 1 ' write byte to ouput array
                    v = Array(x): x = x + 1 ' get the GOTO command # MSB
                    INArray(c) = v: c = c + 1 ' write byte to ouput array
                    v = Array(x): x = x + 1 ' get the GOTO command # LSB
                    INArray(c) = v: c = c + 1 ' write byte to ouput array
                    ' Copy the line number
                    v = Array(x): x = x + 1 ' copy the line number
                    While v < &HF0
                        INArray(c) = v: c = c + 1 ' write line number
                        v = Array(x): x = x + 1 ' copy the line number
                    Wend
                    INArray(c) = &HF5: c = c + 1 ' Add EOL
                    INArray(c) = &H0D: c = c + 1 ' Add EOL
                    INArray(c) = 0: c = c + 1 ' line label length of zero
                End If
            End If
            x = x - 1: v = Array(x)
            Do Until v = &HF5 And Array(x) = &H0D
                v = Array(x): x = x + 1 ' get a byte
                If v = &HF5 And Array(x) = &H3A Then
                    ' We have a colon, remove duplicates & turn it into an EOL
                    x = x - 1
                    While Array(x) = &HF5 And Array(x + 1) = &H3A: x = x + 2: Wend ' consume any colons
                    INArray(c) = &HF5: c = c + 1 ' add EOL instead of the colon(s)
                    INArray(c) = &H0D: c = c + 1 ' add EOL
                    INArray(c) = &H00: c = c + 1 ' line label length of zero
                    v = Array(x): x = x + 1 ' get the next byte
                End If
                INArray(c) = v: c = c + 1 ' write byte to ouput array
                If v = &HFF Then
                    If Array(x) * 256 + Array(x + 1) = C_IF Then
                        ' Found another IF
                        IfCounter = IfCounter + 1
                        c = c - 1 ' Don't keep the &HFF it just wrote
                        INArray(c) = &HF5: c = c + 1 ' add EOL instead of the IF Command
                        INArray(c) = &H0D: c = c + 1 ' add EOL
                        INArray(c) = &H00: c = c + 1 ' line label length of zero
                        INArray(c) = &HFF: c = c + 1 ' Add the command Token
                        v = Array(x): x = x + 1 ' Get the IF Command #MSB
                        INArray(c) = v: c = c + 1 ' Write the IF Command #MSB
                        v = Array(x): x = x + 1 ' Get the IF Command #LSB
                        INArray(c) = v: c = c + 1 ' Write the IF Command #LSB
                    End If
                    If Array(x) * 256 + Array(x + 1) = C_THEN Or Array(x) * 256 + Array(x + 1) = C_ELSE Then
                        ' Found THEN or ELSE
                        c = c - 1
                        INArray(c) = &HF5: c = c + 1 ' add EOL
                        INArray(c) = &H0D: c = c + 1 ' add EOL
                        INArray(c) = 0: c = c + 1 ' line label length
                        INArray(c) = &HFF: c = c + 1 ' add Command
                        v = Array(x): x = x + 1 ' get the THEN or ELSE command # MSB
                        INArray(c) = v: c = c + 1 ' write byte to ouput array
                        v = Array(x): x = x + 1 ' get the THEN or ELSE command # LSB
                        INArray(c) = v: c = c + 1 ' write byte to ouput array
                        INArray(c) = &HF5: c = c + 1 ' add EOL
                        INArray(c) = &H0D: c = c + 1 ' add EOL
                        INArray(c) = 0: c = c + 1 ' line label length
                        'Check for a number could be IF THEN 50
                        If Array(x) >= Asc("0") And Array(x) <= Asc("9") Then
                            ' Found a line number, change it to a new line with GOTO linenumber
                            INArray(c) = &HFF: c = c + 1 ' General command
                            Num = C_GOTO: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                            INArray(c) = MSB: c = c + 1: INArray(c) = LSB: c = c + 1 ' write command to ouput array
                            v = Array(x): x = x + 1 ' copy the line number
                            While v >= Asc("0") And v <= Asc("9")
                                INArray(c) = v: c = c + 1 ' write line number
                                v = Array(x): x = x + 1 ' copy the line number
                            Wend
                            x = x - 1
                            INArray(c) = &HF5: c = c + 1 ' Add EOL
                            INArray(c) = &H0D: c = c + 1 ' Add EOL
                            INArray(c) = 0: c = c + 1 ' line label length of zero
                        Else
                            v = Array(x)
                            ' Could already be a GOTO, add and EOL after if so
                            If Array(x) = &HFF And Array(x + 1) * 256 + Array(x + 2) = C_GOTO Then
                                ' Found a GOTO
                                v = Array(x): x = x + 1 ' get the &HFF
                                INArray(c) = v: c = c + 1 ' write byte to ouput array
                                v = Array(x): x = x + 1 ' get the GOTO command # MSB
                                INArray(c) = v: c = c + 1 ' write byte to ouput array
                                v = Array(x): x = x + 1 ' get the GOTO command # LSB
                                INArray(c) = v: c = c + 1 ' write byte to ouput array
                                ' Copy the line number
                                v = Array(x): x = x + 1 ' copy the line number
                                While v < &HF0
                                    INArray(c) = v: c = c + 1 ' write line number
                                    v = Array(x): x = x + 1 ' copy the line number
                                Wend
                                x = x - 1
                                INArray(c) = &HF5: c = c + 1 ' Add EOL
                                INArray(c) = &H0D: c = c + 1 ' Add EOL
                                INArray(c) = 0: c = c + 1 ' line label length of zero
                            End If
                        End If
                    End If
                End If
            Loop
            FixedGoto:
            v = Array(x): x = x + 1 ' get a byte the $0D
            INArray(c) = v: c = c + 1 ' write byte to ouput array
            For i = 1 To IfCounter
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
            Next i
        End If
    End If
    PartOfENDIF:
Wend

' Tokens for variables type:
' &HF0 = Numeric Arrays           (5 Bytes)
' &HF1 = String Arrays            (4 Bytes)
' &HF2 = Regular Numeric Variable (4 Bytes)
' &HF3 = Regular String Variable  (3 Bytes)
' &HF5 = Special characters like a EOL, colon, comma, semi colon, quote, brackets    (2 Bytes)

' &HFB = DEF FN Function          (3 bytes)
' &HFC = Operator Command         (2 Bytes)
' &HFD = String Command           (3 Bytes)
' &HFE = Numeric Command          (3 Bytes)
' &HFF = General Command          (3 Bytes)

' Change Variable _Var_Timer = to command TIMER =

Check$ = "TIMER": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
C_TIMER = ii
CheckForTimer:
While OP <= filesize
    v = INArray(OP): OP = OP + 1
    If v < &HF0 Then GoTo CheckForTimer
    'We have a Token
    Select Case v
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
    v = Array(x): x = x + 1 ' get a byte
    INArray(c) = v: c = c + 1 'write byte to ouput array
    If v > &HEF Then
        'We have a Token
        Select Case v
            Case &HF0, &HF1: ' Found a Numeric or String array
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
            Case &HF2, &HF3, &HF4: ' Found a numeric or string or Floating point variable
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
            Case &HF5 ' Found a special character
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
            Case &HFB: ' Found a DEF FN Function
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
            Case &HFC: ' Found an Operator
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
            Case &HFD, &HFE: 'Found String or Numeric command
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
                v = Array(x): x = x + 1 ' get a byte
                INArray(c) = v: c = c + 1 'write byte to ouput array
            Case &HFF: ' Found a General command
                Temp1 = Array(x): x = x + 1 ' get a byte
                INArray(c) = Temp1: c = c + 1 'write byte to ouput array
                Temp2 = Array(x): x = x + 1 ' get a byte
                INArray(c) = Temp2: c = c + 1 'write byte to ouput array
                v = Temp1 * 256 + Temp2
                If v = C_ELSE Then
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

' Copy array INArray() to Array()
filesize = c - 1
c = 0
For OP = 0 To filesize
    Array(c) = INArray(OP): c = c + 1
Next OP

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

If Verbose > 0 Then Print "Doing Pass 3 - Figuring out Array sizes, within the DIM commands..."
x = 0
While x < filesize
    v = Array(x): x = x + 1 ' get the command to do
    If v = &HFF Then ' Found a command
        v = Array(x) * 256 + Array(x + 1): x = x + 2
        If v = C_DIM Then ' Is it the DIM command?
            ' Found a DIM command, go setup the array sizes and variable types
            GoSub DoDim
        End If
    End If
Wend
If Verbose > 0 Then Print "Doing Pass 4 - Assigning Numeric Variable & Numeric Array variable types"
' DIM command is used to assign variables types and space for arrays:
' Variable types are:
'   1 Dim a As _Bit '                 Min -1, Max 0
'   2 Dim b As _Unsigned _Bit '       Min 0 , Max 1
'   3 Dim c As _Byte '                Min -128, Max 127
'   4 Dim d As _Unsigned _Byte '      Min 0, Max 255
'   5 Dim e As Integer '              Min -32,768, Max 32,767
'   6 Dim f As _Unsigned Integer '    Min 0, Max 65,535
'   7 Dim g As Long '                 Min -2 Gig, +2 Gig
'   8 Dim h As _Unsigned Long '       Min 0, Max 4 Gig
'   9 Dim i As _Integer64 '           Min -(8 byte value), Max +(8 byte value)
'  10 Dim j As _Unsigned _Integer64 ' Min 0, Max (8 byte value)
'  11 Dim k As Single '(Default size) Min E-38, Max E+38 (New 3 byte FFP format)
'  12 Dim l As Double '               Min E-308, Max E+308
'  13 Dim m As _Float '               Min E-4932, Max E+4932
'  14 Dim n As _Short                 Min -128.996,  Max 127.996  (16 bit, fast float format, MSB is left of the decimal LSB is right of the decimal)
'  15 Dim o As _Unsigned _Short       Min 0,         Max 255.996  (16 bit, fast float format, MSB is left of the decimal LSB is right of the decimal)
'  16 Dim n As _Short512              Min -256.992,  Max 255.992  (16 bit, fast float format, 9  bits represent left of deciaml, 7 bits for the value right of the decimal)
'  17 Dim o As _Unsigned _Short512    Min 0,         Max 511.992  (16 bit, fast float format, 9  bits represent left of deciaml, 7 bits for the value right of the decimal)
'  18 Dim n As _Short1024             Min -512.984,  Max 511.984  (16 bit, fast float format, 10 bits represent left of deciaml, 6 bits for the value right of the decimal)
'  19 Dim o As _Unsigned _Short1024   Min 0,         Max 1023.984 (16 bit, fast float format, 10 bits represent left of deciaml, 6 bits for the value right of the decimal)
'  20 Dim n As _Short2048             Min -1024.968, Max 1023.968 (16 bit, fast float format, 11 bits represent left of deciaml, 5 bits for the value right of the decimal)
'  21 Dim o As _Unsigned _Short2048   Min 0,         Max 2047.968 (16 bit, fast float format, 11 bits represent left of deciaml, 5 bits for the value right of the decimal)
'  22 Dim n As _Short4096             Min -2048.938, Max 2047.938 (16 bit, fast float format, 12 bits represent left of deciaml, 4 bits for the value right of the decimal)
'  23 Dim o As _Unsigned _Short4096   Min 0,         Max 4095.938 (16 bit, fast float format, 12 bits represent left of deciaml, 4 bits for the value right of the decimal)
'  24 Dim n As _Short8192             Min -4096.875, Max 4095.875 (16 bit, fast float format, 13 bits represent left of deciaml, 3 bits for the value right of the decimal)
'  25 Dim o As _Unsigned _Short8192   Min 0,         Max 8191.875 (16 bit, fast float format, 13 bits represent left of deciaml, 3 bits for the value right of the decimal)
'  26 Dim n As _Short16384            Min -8192.75,  Max 8193.75  (16 bit, fast float format, 14 bits represent left of deciaml, 2 bits for the value right of the decimal)
'  27 Dim o As _Unsigned _Short16384  Min 0,         Max 16383.75 (16 bit, fast float format, 14 bits represent left of deciaml, 2 bits for the value right of the decimal)
'  28 Dim n As _Short32768            Min -16384.5,  Max 16383.5  (16 bit, fast float format, 15 bits represent left of deciaml, 1 bit  for the value right of the decimal)
'  29 Dim o As _Unsigned _Short32768  Min 0,         Max 32767.5  (16 bit, fast float format, 15 bits represent left of deciaml, 1 bit  for the value right of the decimal)

' Since at this point the commands & variables in the program have already been identified we need to change the numeric variable format from
' Numeric array    &HF0, MSB,LSB,# of Elements in the Array to &HF0, MSB,LSB,Type,# of Elements in the Array
' Numeric Variable &HF2, MSB,LSB to &HF2, MSB,LSB,Type

c = 0
x = 0
While x <= filesize
    v = Array(x): x = x + 1 ' get a byte
    INArray(c) = v: c = c + 1 'write byte to ouput array
    Select Case v
        Case &HF0
            'We found a numeric array variable, lets add the type
            MSB = Array(x): x = x + 1 ' get a MSB byte
            INArray(c) = MSB: c = c + 1 'write byte to ouput array
            LSB = Array(x): x = x + 1 ' get a LSB byte
            INArray(c) = LSB: c = c + 1 'write byte to ouput array
            ' COPY the # of Elements (dimensions)
            v = Array(x): x = x + 1 ' get a byte
            INArray(c) = v: c = c + 1 'write byte to ouput array
            ' Add the type
            If NumericArrayType(MSB * 256 + LSB) = 0 Then
                ' This variable hasn't been assigned a value, so we make it a Single which is the default
                INArray(c) = 11: c = c + 1 'write byte to ouput array
            Else
                ' Set the value type of this variable
                INArray(c) = NumericArrayType(MSB * 256 + LSB): c = c + 1 'write byte to ouput array
            End If
        Case &HF2
            'We found a numeric variable, lets add the type
            MSB = Array(x): x = x + 1 ' get a MSB byte
            INArray(c) = MSB: c = c + 1 'write byte to ouput array
            LSB = Array(x): x = x + 1 ' get a LSB byte
            INArray(c) = LSB: c = c + 1 'write byte to ouput array
            If NumericVarType(MSB * 256 + LSB) = 0 Then
                ' This variable hasn't been assigned a value, so we make it a Single which is the default
                INArray(c) = 11: c = c + 1 'write byte to ouput array
            Else
                ' Set the value type of this variable
                INArray(c) = NumericVarType(MSB * 256 + LSB): c = c + 1 'write byte to ouput array
            End If
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
    Array(c) = INArray(OP)
    LastOutArray(c) = INArray(OP): c = c + 1
Next OP
If _FileExists("BasicTokenized.bin") Then Kill "BasicTokenized.bin"
If Verbose > 0 Then Print "Writing to file "; "BasicTokenized.bin"
Open "BasicTokenized.bin" For Binary As #1
Put #1, , LastOutArray()
Close #1

' Find any direct variable or literal # types are used, if so make sure the library to handle these types are included
x = 0
While x <= filesize
    v = Array(x): x = x + 1 ' get a byte
    If v > &HEF Then
        'We have a Token
        Select Case v
            Case &HF0: ' Found a Numeric  array
                v = Array(x): x = x + 1 ' Skip MSB
                v = Array(x): x = x + 1 ' Skip LSB
                v = Array(x): x = x + 1 ' Skip # of Elements
                v = Array(x): x = x + 1 ' Skip Type
                ' Check for a special chars afterwards that indicate a Numeric Type change so we include necessary librarys
                GoSub CheckType
            Case &HF1: ' Found a String array
                v = Array(x): x = x + 1 ' Skip MSB
                v = Array(x): x = x + 1 ' Skip LSB
                v = Array(x): x = x + 1 ' Skip # of Elements
            Case &HF2: ' Found a Regular Numeric Variable
                v = Array(x): x = x + 1 ' Skip MSB
                v = Array(x): x = x + 1 ' Skip LSB
                v = Array(x): x = x + 1 ' Skip Type
                ' Check for a special chars afterwards that indicate a Numeric Type change so we include necessary librarys
                GoSub CheckType
            Case &HF3: ' Found a string Variable
                v = Array(x): x = x + 1 ' get a byte
                v = Array(x): x = x + 1 ' get a byte
            Case &HF5 ' Found a special character
                v = Array(x): x = x + 1 ' get a byte
                ' Find and ignore special characters in a quote
                If v = &H22 Then
                    ' We found a quote, ignore until an EOL/COLON or another quote
                    Do Until Array(x) = &HF5 And (Array(x + 1) = &H0D Or Array(x + 1) = &H3A Or Array(x + 1) = &H22)
                        x = x + 1
                    Loop
                Else
                    ' Not a quote
                    Select Case v
                        Case &H0D, &H3A ' Ignore CR or Colons
                        Case &H23 ' Found a #
                            If Array(x) = &HF5 And Array(x + 1) = Asc("#") Then ' #   _Float use Double
                                Temp$ = "Math_IEEE_754_Double_64bit": GoSub AddIncludeTemp ' Add code for Selecting the audio muxer and to turn it on or off
                                Temp$ = "Math_Integer64": GoSub AddIncludeTemp ' Add code for 64 bit math, some routines use integer 64 Add/Subtract
                                x = x + 2
                            End If
                        Case Else ' If unknown, probably should add a FFP
                            Temp$ = "Math_Fast_Floating_Point": GoSub AddIncludeTemp ' Add code for my 3 byte fast floating point math routines
                    End Select
                End If
            Case &HFB: ' Found a DEF FN Function
                v = Array(x): x = x + 1 ' get a byte
                v = Array(x): x = x + 1 ' get a byte
            Case &HFC: ' Found an Operator
                v = Array(x): x = x + 1 ' get a byte
            Case &HFD, &HFE: 'Found String or Numeric command
                v = Array(x): x = x + 1 ' get a byte
                v = Array(x): x = x + 1 ' get a byte
            Case &HFF: ' Found a General command
                Temp1 = Array(x): x = x + 1 ' get a byte
                Temp2 = Array(x): x = x + 1 ' get a byte
                If Temp1 * 256 + Temp2 = C_REM Or Temp1 * 256 + Temp2 = C_REMApostrophe Then
                    ' Found a remark, ignore this part
                    Do Until Array(x) = &HF5 And (Array(x + 1) = &H0D Or Array(x + 1) = &H3A)
                        x = x + 1
                    Loop
                End If
        End Select
    Else
        ' Might come across a literal number
        If v >= Asc("0") And v <= Asc("9") Then
            ' we have a number, find the end
            While Array(x) >= Asc("0") And Array(x) <= Asc("9"): x = x + 1: Wend
            ' Check for a special chars afterwards that indicate a Numeric Type change so we include necessary librarys
            GoSub CheckType
        End If
    End If
Wend








If Verbose > 0 Then Print "Doing Pass 5 - Finding special cases that will need other files to be included..."
x = 0
Gmode = -1 ' Flag no GMODE command found
ScollBackground = -1 ' Flag no Scrollable background found
While x < filesize
    v = Array(x): x = x + 1 ' get the command to do
    If v = &HFF Then ' Found a command
        v = Array(x) * 256 + Array(x + 1): x = x + 2
        Select Case v
            Case C_SELECT
                SelectCounter = SelectCounter + .5
            Case C_EVERYCASE
                EveryCaseCounter = EveryCaseCounter + 1
                EveryCase(EveryCaseCounter) = Int(SelectCounter + .5) ' Adjust since we will also include END SELECT
            Case C_PRINT 'This is the PRINT command
                ' Found a PRINT command, see if we have a print #-3, which will print to the graphics screen
                ' #-3, =  F5 23 FC 2D 33 F5 2C
                If Array(x) = &HF5 And Array(x + 1) = &H23 And Array(x + 2) = &HFC And Array(x + 3) = &H2D And Array(x + 4) = &H33 And Array(x + 5) = &HF5 And Array(x + 6) = &H2C Then
                    x = x + 7
                    PrintGraphicsText = 1
                End If
            Case C_GMODE
                ' Found a GMODE command
                If Gmode = -1 Then
                    ' This is the first GMODE command, the user should have entered the actual GMODE number used for the program here
                    Temp$ = ""
                    Tempx = x
                    While Array(x) < &HF0
                        Temp$ = Temp$ + Chr$(Array(x))
                        x = x + 1
                    Wend
                    Gmode = Val(Temp$)
                    x = Tempx 'Set things back to normal
                End If
            Case C_PLAYFIELD
                'Found a PLAYFIELD command, signify we will be scrolling the background and setup variables
                ScollBackground = 1 ' Using scrolling
                Tempx = x
                ' get the Playfield option
                N$ = ""
                While Array(x) < &HF0
                    N$ = N$ + Chr$(Array(x)): x = x + 1
                Wend
                ' Got the Playfield needed
                Playfield = Val(N$)
                If Playfield < 1 Or Playfield > 5 Then Print "Error: PLAYFIELD command, Must be an acutal number (not a variable) and can only handle values from 1 to 5";: GoTo FoundError
                x = Tempx 'Set things back to normal
            Case C_SPRITE
                Sprites = 1
            Case C_SPRITE_LOAD
                ' Found a Sprite Load command
                ' Get the address and name of the sprite to load
                If Array(x) = &HF5 And Array(x + 1) = &H22 Then
                    ' Found an open quote
                    x = x + 2 ' move past the open quote
                    Temp$ = ""
                    While Array(x) < &HF0
                        ' Get the path and filename of the compiled sprite
                        Temp$ = Temp$ + Chr$(Array(x))
                        x = x + 1
                    Wend
                    If Array(x) <> &HF5 And Array(x + 1) <> &H22 Then
                        ' Couldn't find an end quote for the compiled sprite name
                        Print "Error: SPRITE_LOAD Couldn't find an end quote for the compiled sprite name";: GoTo FoundError
                    End If
                    x = x + 2 ' move past the close quote
                    ' Check for a comma
                    If Array(x) = &HF5 And Array(x + 1) = &H2C Then
                        ' Found a comma
                        x = x + 2
                        ' get the sprite number
                        N$ = ""
                        While Array(x) < &HF0
                            N$ = N$ + Chr$(Array(x)): x = x + 1
                        Wend
                        ' Got the number of the sprite
                        n = Val(N$)
                        If n > 31 Then Print "Error: SPRITE_LOAD Can't use sprite number"; n; " must be 31 or lower";: GoTo FoundError
                        Sprite$(n) = Temp$
                        ' Find the sprite's height, needed for when to draw it on screen
                        Open "./" + Temp$ For Append As #1
                        If LOF(1) < 1 Then
                            Print "Error: SPRITE_LOAD file: "; Temp$; " doesn't exit.": System
                        End If
                        Close #1
                        Open "./" + Temp$ For Input As #1
                        While EOF(1) = 0
                            Line Input #1, i$
                            If InStr(i$, "; Height is: ") = 1 Then
                                hend = InStr(i$, " Rows")
                                h$ = Mid$(i$, 14, hend - 14)
                                h = Val(h$)
                                SpriteHeight(n) = h
                                Exit While
                            End If
                        Wend
                        Close #1
                        ' Check for a comma
                        If Array(x) = &HF5 And Array(x + 1) = &H2C Then
                            ' Found a comma
                            x = x + 2
                            ' get the sprite number
                            N$ = ""
                            While Array(x) < &HF0
                                N$ = N$ + Chr$(Array(x)): x = x + 1
                            Wend
                            ' Got the number of the sprite
                            AnimFrames = Val(N$)
                            If AnimFrames <= 0 Then AnimFrames = 1
                            SpriteNumberOfFrames(n) = AnimFrames - 1
                        Else
                            SpriteNumberOfFrames(n) = 0
                        End If
                    Else
                        Print "Error: SPRITE_LOAD Can't find a comma with the sprite number";: GoTo FoundError
                    End If
                Else
                    Print "Error: SPRITE_LOAD Can't find an open quote for the compiled sprite name";: GoTo FoundError
                End If
            Case C_SAMPLE_LOAD
                ' Found a Sample Load command
                ' Get the address and name of the sample to load
                If Array(x) = &HF5 And Array(x + 1) = &H22 Then
                    ' Found an open quote
                    x = x + 2 ' move past the open quote
                    Temp$ = ""
                    While Array(x) < &HF0
                        ' Get the path and filename of the sample
                        Temp$ = Temp$ + Chr$(Array(x))
                        x = x + 1
                    Wend
                    If Array(x) <> &HF5 And Array(x + 1) <> &H22 Then
                        ' Couldn't find an end quote for the sample name
                        Print "Error: SAMPLE_LOAD Couldn't find an end quote for the audio sample name";: GoTo FoundError
                    End If
                    x = x + 2 ' move past the close quote
                    ' Check for a comma
                    If Array(x) = &HF5 And Array(x + 1) = &H2C Then
                        ' Found a comma
                        x = x + 2
                        ' get the sample number
                        N$ = ""
                        While Array(x) < &HF0
                            N$ = N$ + Chr$(Array(x)): x = x + 1
                        Wend
                        ' Got the number of the sample
                        n = Val(N$)
                        If n > 31 Then Print "Error: SAMPLE_LOAD Can't use sample number"; n; " must be 31 or lower";: GoTo FoundError
                        Sample$(n) = Temp$
                        Open "./" + Temp$ For Append As #1
                        If LOF(1) < 1 Then
                            Print "Error: SAMPLE_LOAD file: "; Temp$; " doesn't exit.": System
                        End If
                        SampleLength(n) = LOF(1)
                        SampleStart(n) = &H7FFF - LOF(1) + 1
                        Close #1
                    Else
                        Print "Error: SAMPLE_LOAD Can't find a comma with the sample number";: GoTo FoundError
                    End If
                Else
                    Print "Error: SAMPLE_LOAD Can't find an open quote for the compiled sample name";: GoTo FoundError
                End If
        End Select
    End If
Wend

Open "NumericVariablesUsed.txt" For Output As #1
For i = 0 To NumericVariableCount - 1
    Print #1, NumericVariable$(i)
Next i
Close #1
Open "FloatingPointVariablesUsed.txt" For Output As #1
For i = 0 To FloatVariableCount - 1
    Print #1, FloatVariable$(i)
Next i
Close #1
Open "StringVariablesUsed.txt" For Output As #1
For i = 0 To StringVariableCounter - 1
    Print #1, StringVariable$(i)
Next i
Close #1
Open "GeneralCommandsFound.txt" For Output As #1
For i = 0 To GeneralCommandsFoundCount - 1
    Print #1, GeneralCommandsFound$(i)
Next i
Close #1
Open "StringCommandsFound.txt" For Output As #1
For i = 0 To StringCommandsFoundCount - 1
    Print #1, StringCommandsFound$(i)
Next i
Close #1
Open "NumericCommandsFound.txt" For Output As #1
For i = 0 To NumericCommandsFoundCount - 1
    Print #1, NumericCommandsFound$(i)
Next i
Close #1
Open "NumericArrayVarsUsed.txt" For Output As #1
For i = 0 To NumArrayVarsUsedCounter - 1
    Print #1, NumericArrayVariables$(i)
    Print #1, NumericArrayDimensions(i)
    Print #1, NumericArrayBits(i)
Next i
Close #1
Open "StringArrayVarsUsed.txt" For Output As #1
For i = 0 To StringArrayVarsUsedCounter - 1
    Print #1, StringArrayVariables$(i)
    Print #1, StringArrayDimensions(i)
    If StringArrayBits(i) = 0 Then StringArrayBits = 16
    Print #1, StringArrayBits(i)
Next i
Close #1
Open "DefFNUsed.txt" For Output As #1
For i = 0 To DefLabelCount - 1
    Print #1, DefLabel$(i)
Next i
Close #1
Open "DefVarUsed.txt" For Output As #1
For i = 0 To DefVarCount - 1
    Print #1, DefVar(i)
Next i
Close #1

CoCo3 = 0
If WidthVal$ <> "" Then CoCo3 = 1
For ii = 0 To 171
    If GModeLib(ii) = 1 Then
        If ii >= 100 Then
            CoCo3 = 1
        End If
    End If
Next ii

' Sprite setup stuff
For i = 0 To 31
    If Sprite$(i) <> "" Then Sprites = 1
Next i

Open "SpritesUsed.txt" For Output As #1
Print #1, CoCo3
Print #1, Sprites
For i = 0 To 31
    Print #1, Sprite$(i)
    Print #1, SpriteNumberOfFrames(i) ' Record the sprite height
    Print #1, SpriteHeight(i) ' Record the sprite height
Next i
Close #1

' Audio Sample setup stuff
Samples = 0
For i = 0 To 31
    If Sample$(i) <> "" Then Samples = 1
Next i

Open "SamplesUsed.txt" For Output As #1
Print #1, CoCo3
Print #1, Samples
Sample8KBlock = 0 ' First 8 k block to be used for audio samples
For i = 0 To 31
    If Sample$(i) <> "" Then
        SampleNumberOfBLKs(i) = Int(SampleLength(i) / &H2000) + 1
        SampleStartBlock(i) = Sample8KBlock
        Sample8KBlock = Sample8KBlock + SampleNumberOfBLKs(i)
    End If
    Print #1, Sample$(i)
    Print #1, SampleStart(i)
    Print #1, SampleStartBlock(i)
    Print #1, SampleNumberOfBLKs(i)
    Print #1, SampleLength(i)
Next i
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

' *** Start writing to the .asm file ***
T1$ = "    ": T2$ = T1$ + T1$
Open OutName$ For Output As #1

For ii = 0 To 171
    If GModeLib(ii) = 1 Then
        If ii < 100 Then
            ' CoCo 1 & 2 graphics mode, Check if ProgramStart should be changed
            '            If GModePageLib(ii) <> 0 Then
            ' the user wants to use multiple graphics pages
            PStart = Val("&H" + ProgramStart$) + Val("&H" + GModeScreenSize$(ii)) * (GModePageLib(ii) + 1)
            ProgramStart$ = Hex$(PStart)
            '            End If
        End If
    End If
Next ii
' If we are doing CoCo3 sprites load them first
' Add blocks needed per grapics screen if we are using a coco 3
If CoCo3 = 1 And Sprites = 1 Then
    For ii = 0 To 171
        If GModeLib(ii) = 1 Then
            If GModePageLib(ii) <> 0 Then
                ' the user wants to use multiple graphics pages
                '                Print "GModePageLib(ii)"; GModePageLib(ii), ii
                CC3BlocksPerScreen = Val("&H" + GModeScreenSize$(ii)) / &H2000
                '                Print "CC3BlocksPerScreen"; CC3BlocksPerScreen
                If CC3BlocksPerScreen <> Int(CC3BlocksPerScreen) Then CC3BlocksPerScreen = Int(CC3BlocksPerScreen) + 1
                '                Print "CC3BlocksPerScreen"; CC3BlocksPerScreen
                CC3SpritesStartAt = CC3BlocksPerScreen * GModePageLib(ii)
                '                Print "CC3SpritesStartAt"; CC3SpritesStartAt
            End If
        End If
    Next ii
    Select Case Val(GModeColours$(Gmode))
        Case 2
            ColourDiv = 8
        Case 4
            ColourDiv = 4
        Case 16
            ColourDiv = 2
    End Select
    Num = (Val(GModeMaxX$(Gmode)) + 1) / ColourDiv: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    z$ = "GmodeBytesPerRow EQU     " + num$ + "    ; # of bytes per graphics row, used by the sprite rendering code": GoSub AO
    Num = Val("&H" + GModeScreenSize$(Gmode)): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    z$ = "ScreenSize      EQU     " + num$ + "   ; Size of a graphics screen": GoSub AO
    Num = Val(GModeMaxX$(Gmode)): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    z$ = "PixelsMaxX      EQU     " + num$ + "     ; Screen width Max from 0 to this value": GoSub AO
    Num = Val(GModeColours$(Gmode)): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    z$ = "NumberOfColours EQU     " + num$ + "      ; Number of Colours on this screen": GoSub AO
    z$ = "Artifacting     EQU     0       ; Not using Artifact colours with a CoCo 3 GMODE": GoSub AO

    ' add code to save in the correct block for $FFA1 & $FFA2...  ($2000 & $4000)
    SpritePointer = -1
    i = 0
    While i <= 31
        If Sprite$(i) <> "" Then
            SpritePointer = i
            Exit While
        End If
        i = i + 1
    Wend
    If SpritePointer <> -1 Then
        Print #1, "; Loading Sprites into RAM"
        ' We have at least one sprite to handle
        Num = SpritePointer: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        num$ = Right$("00" + num$, 2)
        SpritePointerBlk$ = "Sprite" + num$ + "Blk"
        z$ = SpritePointerBlk$ + "     EQU     $40   ; First block used for sprites (CoCo 3 needs to have 2 Megs for sprites)": GoSub AO
        FirstBlk$ = SpritePointerBlk$
        For i = 0 To 31
            If Sprite$(i) <> "" Then
                ' Get the location after the last GMODE screen will be used
                A$ = "ORG": B$ = "$FFA1": C$ = "Address to control $2000 block": GoSub AO
                A$ = "FCB": B$ = FirstBlk$: C$ = "Block to use for this compiled sprite code, $2000-$3FFF": GoSub AO
                A$ = "FCB": B$ = FirstBlk$ + "+1": C$ = "Block to use for this compiled sprite code, $4000-$5FFF": GoSub AO
                A$ = "FCB": B$ = FirstBlk$ + "+2": C$ = "Block to use for this compiled sprite code, $6000-$7FFF": GoSub AO
                A$ = "FCB": B$ = FirstBlk$ + "+3": C$ = "Block to use for this compiled sprite code, $8000-$9FFF": GoSub AO
                A$ = "FCB": B$ = FirstBlk$ + "+4": C$ = "Block to use for this compiled sprite code, $A000-$BFFF": GoSub AO
                A$ = "FCB": B$ = FirstBlk$ + "+5": C$ = "Block to use for this compiled sprite code, $C000-$DFFF": GoSub AO
                A$ = "FCB": B$ = FirstBlk$ + "+6": C$ = "Block to use for this compiled sprite code, $E000-$FDFF": GoSub AO
                A$ = "ORG": B$ = "$2000": C$ = "Add the sprite at $2000": GoSub AO
                Print #1, T2$; "INCLUDE     ./"; Sprite$(i)
                SpriteEnd$ = "Sprite" + num$ + "End"
                z$ = SpriteEnd$ + "     EQU       *": GoSub AO
                ' Get next sprite #
                I2 = i + 1
                While I2 <= 31
                    If Sprite$(I2) <> "" Then
                        Exit While
                    End If
                    I2 = I2 + 1
                Wend
                If I2 <> 32 Then
                    'Not done yet, I2 has the next sprite
                    Num = I2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                    num$ = Right$("00" + num$, 2)
                    NextBlk$ = "Sprite" + num$ + "Blk"
                    z$ = NextBlk$ + "     EQU     " + FirstBlk$ + "+((" + SpriteEnd$ + "-$2000)/$2000)+1": GoSub AO
                    FirstBlk$ = NextBlk$
                End If
            End If
        Next i
    End If
End If
If CoCo3 = 1 And Samples = 1 Then
    ' add code to save in the correct block for $FFA1 & $FFA2...  ($2000 & $4000)
    SamplePointer = -1
    i = 0
    While i <= 31
        If Sample$(i) <> "" Then
            SamplePointer = i
            Exit While
        End If
        i = i + 1
    Wend
    If SamplePointer <> -1 Then
        ' We have at least one sample to handle
        Print #1, "; Loading Audio Samples into RAM"
        For i = 0 To 31
            If Sample$(i) <> "" Then
                Num = i: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                num$ = Right$("00" + num$, 2)
                SamplePointerBlk$ = "Sample" + num$ + "Blk"
                Num = SampleStartBlock(i): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                z$ = SamplePointerBlk$ + "     EQU     $" + Hex$(Val(num$)) + "  ; First block used for Sample" + Str$(i): GoSub AO
                A$ = "ORG": B$ = "$FFA1": C$ = "Address to control $0000 block": GoSub AO
                padding = 3 - SampleNumberOfBLKs(i)
                For BLK = SampleStartBlock(i) + SampleNumberOfBLKs(i) - 1 - padding To SampleStartBlock(i) + SampleNumberOfBLKs(i) - 1
                    v = BLK: If v < 0 Then v = 0
                    A$ = "FCB": B$ = "$" + Right$("00" + Hex$(v), 2): C$ = "Block to use for audio sample " + Sample$(i): GoSub AO
                Next BLK
                Num = SampleStart(i): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                A$ = "ORG": B$ = "$" + Hex$(Val(num$)): C$ = "Sample starting at $" + Hex$(Val(num$)): GoSub AO
                Print #1, T2$; "INCLUDEBIN  ./"; Sample$(i)
            End If
        Next i
    End If
End If
If CoCo3 = 1 And (SpritePointer <> -1 Or SamplePointer <> -1) Then
    A$ = "ORG": B$ = "$FFA1": C$ = "Address to control $2000 block": GoSub AO
    A$ = "FDB": B$ = "$393A": C$ = "Blocks are back to normal": GoSub AO
    A$ = "FDB": B$ = "$3B3C": C$ = "Blocks are back to normal": GoSub AO
    A$ = "FDB": B$ = "$3D3E": C$ = "Blocks are back to normal": GoSub AO
    A$ = "FCB": B$ = "$3F": C$ = "Blocks are back to normal": GoSub AO
End If

If Gmode > 99 Then
    ProgramStart$ = "E00" ' Force the CoCo 3 to start at $E00
End If

If WidthVal$ <> "" And WidthVal$ <> "32" Then
    TextRows = 28
    Select Case WidthVal$
        Case "40"
            ProgramStart$ = Hex$(Val("&H0E00") + 40 * 2 * (TextRows + 1)) ' 40 characters per line * 2 (attribute byte) * TextRows rows
            CC3Width$ = "0"
        Case "64"
            ProgramStart$ = Hex$(Val("&H0E00") + 64 * 2 * (TextRows + 1)) ' 64 characters per line * 2 (attribute byte) * TextRows rows
            CC3Width$ = "1"
        Case "80"
            ProgramStart$ = Hex$(Val("&H0E00") + 80 * 2 * (TextRows + 1)) ' 80 characters per line * 2 (attribute byte) * TextRows rows
            CC3Width$ = "2"
    End Select
End If

DirectPage$ = ProgramStart$
DirectPage = Val("&H" + DirectPage$)
DirectPage = DirectPage / 256
DirectPage$ = Hex$(DirectPage)

A$ = "ORG": B$ = "$" + ProgramStart$: C$ = "Program code starts here": GoSub AO
A$ = "SETDP": B$ = "$" + DirectPage$: C$ = "Direct page is setup here": GoSub AO
Print #1, "CoCoHardware    RMB     1     ; CoCoHardware Desriptor byte"
Print #1, "; Bit 0 is the Computer Type, 0 = CoCo 1 or CoCo 2, 1 = CoCo 3"
Print #1, "; Bit 7 is the CPU type,      0 = 6809, 1 = 6309"
Print #1, "Seed1           RMB     1     ; Random number seed location"
Print #1, "Seed2           RMB     1     ; Random number seed location"
Print #1, "Seed3           RMB     1     ; Used by Random number generator"
Print #1, "Seed4           RMB     1     ; Used by Random number generator"
If WidthVal$ <> "" And WidthVal$ <> "32" Then
    z$ = "CC3Width:": GoSub AO
    A$ = "FCB": B$ = CC3Width$: C$ = "0=Width 40, 1=Width 64, 2=Width 80": GoSub AO
End If
If PrintGraphicsText = 1 Then
    ' Found program uses PRINT #-3, to print to the graphics screen
    Print #1, "GraphicCURPOS   RMB     2     ; Reserve RAM for the Graphics Cursor"
End If

Print #1, "_Var_Timer      RMB     2     ; TIMER value"
Print #1, "StartClearHere:" ' This is the start address of variables that will all be cleared to zero when the program starts
' Save space for 10 temporary 16 bit numbers
Print #1, "; Temporary Numbers:"
For Num = 0 To 10
    GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If Num < 10 Then num$ = "0" + num$
    Print #1, "_Var_PF"; num$; T1$; "RMB "; T1$; "2"
Next Num
Print #1, "Temp1           RMB     1     ; Temporary byte used for many routines"
Print #1, "Temp2           RMB     1     ; Temporary byte used for many routines"
Print #1, "Temp3           RMB     1     ; Temporary byte used for many routines"
Print #1, "Temp4           RMB     1     ; Temporary byte used for many routines"
Print #1, "Denominator     RMB     2     ; Denominator, used in division"
Print #1, "Numerator       RMB     2     ; Numerator, used in division"
Print #1, "DATAPointer     RMB     2     ; Variable that points to the current DATA location"
'Print #1, "_NumVar_IFRight RMB     2     ; Temp bytes for IF Compares"

Print #1, "SwapTypes       RMB     8     ; Temp bytes for Numeric conversions"

' Reserve space for Numeric variables
Print #1, "; Numeric Variables Used:"; NumericVariableCount - 1
For ii = 1 To NumericVariableCount - 1 ' 0 is the Timer Variable, but we don't want to clear it so we mannually enter it above
    Select Case NumericVarType(ii)
        Case 0
            VSize = 3
            Temp$ = "Default size as a FastFloat"
            NumericVarType(ii) = 11
        Case 1 To 4 ' Variable size is 1 byte
            VSize = 1
            Temp$ = "Bit or Byte"
        Case 5, 6 ' Variable is 2 bytes
            VSize = 2
            Temp$ = "Integer"
        Case 7, 8 ' Variable is 4 bytes
            VSize = 4
            Temp$ = "Long"
        Case 9, 10 ' Variable is 8 bytes
            VSize = 8
            Temp$ = "Integer64"
        Case 11 ' Variable is 3 bytes
            VSize = 3
            Temp$ = "FastFloat"
        Case 12 ' Variable is 10 bytes
            VSize = 10
            Temp$ = "Double"
        Case 14 To 29 ' Variable is 2 bytes
            VSize = 2
            Temp$ = "Short"
    End Select
    Print #1, "_Var_"; NumericVariable$(ii); T1$; "RMB "; T1$; VSize; T1$; "Type of variable is: "; Temp$
Next ii
' Handle Everycase flags
If EveryCaseCounter > 0 Then
    For ii = 1 To EveryCaseCounter
        Num = EveryCase(ii)
        GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        If Num < 10 Then num$ = "0" + num$
        Print #1, "_Var___SelHit"; num$; " RMB     1     ; Flag for Everycase"
    Next ii
End If
Print #1, "SoundTone       RMB     1     ; SOUND Tone value"
Print #1, "SoundDuration   RMB     2     ; SOUND Command duration value"
Print #1, "CASFLG          RMB     1     ; Case flag for keyboard output $FF=UPPER (normal), 0=LOWER"
Print #1, "OriginalIRQ     RMB     3     ; We save the original branch and location of the IRQ here, restored before we exit"
Print #1, "EndClearHere:" ' This is the end address of variables that will all be cleared to zero when the program starts
Num = Playfield: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
z$ = "PLAYFIELD   EQU     " + num$: GoSub AO
If ScollBackground = 1 Then
    ' Add Scrolling Background code
    Temp$ = "GraphicCommands/CoCo3_ScrollingBackground": GoSub AddIncludeTemp
    If Playfield = 1 Then
        ' Calculating which row the sprite will be should be normal
        z$ = "Scrolling   EQU     0": GoSub AO
        z$ = "VideoRamBlock           FCB     %00000010       ; Set default to 1 Meg to 1.5 Meg location": GoSub AO
    Else
        ' Calculating which row the sprite will be needs to account for a 256 byte (512 pixel screen)
        z$ = "Scrolling   EQU     1": GoSub AO
        z$ = "VideoRamBlock           FCB     %00000010       ; Set default to 1 Meg to 1.5 Meg location": GoSub AO
    End If
Else
    z$ = "Scrolling   EQU     0": GoSub AO
    z$ = "VideoRamBlock           FCB     %00000000       ; Set default to 0 Meg to 0.5 Meg location": GoSub AO
End If
z$ = "VerticalPosition        FDB     $0000           ; Offset": GoSub AO
z$ = "HorizontalPosition      FCB     %00000000       ; Bit 7 set = Horizontal scrolling enabled": GoSub AO

If CoCo3 = 1 Then
    Print #1, T2$; "INCLUDE        ./Basic_Includes/CoCo3_Equates.asm" ' Include the CoCo 3 Equates
    If Disk = 1 Then
        ' DISK controller Interrupts
        '; NMI SERVICE
        z$ = "DNMISV:"
        A$ = "LDA": B$ = "NMIFLG": C$ = "GET NMI FLAG": GoSub AO
        A$ = "BEQ": B$ = "LD8AE": C$ = "RETURN IF NOT ACTIVE": GoSub AO
        A$ = "LDX": B$ = "DNMIVC": C$ = "GET NEW RETURN VECTOR": GoSub AO
        A$ = "STX": B$ = "10,S": C$ = "STORE AT STACKED PC SLOT ON STACK": GoSub AO
        A$ = "CLR": B$ = "NMIFLG": C$ = "RESET NMI FLAG": GoSub AO
        z$ = "LD8AE"
        A$ = "RTI": B$ = "": C$ = "RETURN FROM INTERRUPT": GoSub AO
        If Sprites = 0 And Samples = 0 Then
            ' Just add disk IRQ service, no special FIRQ or IRQ
            '; Disk IRQ SERVICE and Sound and Timer 60 Hz IRQ
            z$ = "BASIC_IRQ:": GoSub AO
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
            z$ = "LD8CD"
            A$ = "LDX": B$ = "SoundDuration": C$ = "Get the new Sound duration value": GoSub AO
            A$ = "BEQ": B$ = ">": C$ = "RETURN IF TIMER = 0": GoSub AO
            A$ = "LEAX": B$ = "-1,X": C$ = "DECREMENT TIMER IF NOT = 0": GoSub AO
            A$ = "STX": B$ = "SoundDuration": C$ = "Save the new Sound duration value": GoSub AO
            z$ = "!"
            A$ = "INC": B$ = "_Var_Timer+1": C$ = "Increment the LSB of the Timer Value": GoSub AO
            A$ = "BNE": B$ = "Not60Hz": C$ = "Skip ahead if not zero": GoSub AO
            A$ = "INC": B$ = "_Var_Timer": C$ = "Increment the MSB of the Timer Value": GoSub AO
            z$ = "Not60Hz"
            A$ = "RTI": B$ = "": C$ = "RETURN FROM INTERRUPT": GoSub AO
        Else
            If Sprites = 1 Then
                ' include the cc3 sprite drawing code here:
                ' Include the delay values for the scanline is on screen
                If Val(GModeMaxY$(Gmode)) = 191 Then
                    Print #1, T2$; "INCLUDE        ./Basic_Includes/CoCo3_FIRQ_Delay_192_Rows.asm"
                End If
                If Val(GModeMaxY$(Gmode)) = 199 Then
                    Print #1, T2$; "INCLUDE        ./Basic_Includes/CoCo3_FIRQ_Delay_200_Rows.asm"
                End If
                If Val(GModeMaxY$(Gmode)) = 224 Then
                    Print #1, T2$; "INCLUDE        ./Basic_Includes/CoCo3_FIRQ_Delay_225_Rows.asm"
                End If
                z$ = "**************** VSyncIRQ *************************": GoSub AO
                z$ = "BASIC_IRQ:": GoSub AO
                A$ = "LDA": B$ = "GIME_InterruptReqEnable_FF92": C$ = "Re enable the VSYNC IRQ": GoSub AO
                Print #1, T2$; "INCLUDE        ./Basic_Includes/CoCo3_IRQ_WithDisk.asm"
                Print #1, T2$; "INCLUDE        ./Basic_Includes/CoCo3_IRQandFIRQ_Sprites.asm" ' Sprites also includes FIRQ Sample playback handling
                Print #1, T2$; "INCLUDE        ./Basic_Includes/GraphicCommands/CoCo3_SpriteHandler.asm" 'Add the sprite handling code
            Else
                If Samples = 1 Then
                    ' include the cc3 sprite drawing code here:
                    z$ = "**************** VSyncIRQ *************************": GoSub AO
                    z$ = "BASIC_IRQ:": GoSub AO
                    A$ = "LDA": B$ = "GIME_InterruptReqEnable_FF92": C$ = "Re enable the VSYNC IRQ": GoSub AO
                    Print #1, T2$; "INCLUDE        ./Basic_Includes/CoCo3_IRQ_WithDisk.asm"
                    Print #1, T2$; "INCLUDE        ./Basic_Includes/CoCo3_IRQandFIRQ_SamplesOnly.asm" ' Sprites also includes FIRQ Sample playback handling
                End If
            End If
        End If
    Else
        ' No Disk
        If Sprites = 0 And Samples = 0 Then
            ' Keep the IRQ and FIRQ simple and as fast as possible
            ' Sound and Timer 60 Hz IRQ
            z$ = "; Sound and Timer 60hz IRQ ": GoSub AO
            z$ = "BASIC_IRQ:": GoSub AO
            A$ = "LDA": B$ = "$FF03": C$ = "CHECK FOR 60HZ INTERRUPT": GoSub AO
            A$ = "BPL": B$ = "Not60Hz": C$ = "RETURN IF 63.5 MICROSECOND INTERRUPT": GoSub AO
            A$ = "LDA": B$ = "$FF02": C$ = "RESET PIA0, PORT B INTERRUPT FLAG": GoSub AO
            A$ = "LDX": B$ = "SoundDuration": C$ = "Get the new Sound duration value": GoSub AO
            A$ = "BEQ": B$ = ">": C$ = "RETURN IF TIMER = 0": GoSub AO
            A$ = "LEAX": B$ = "-1,X": C$ = "DECREMENT TIMER IF NOT = 0": GoSub AO
            A$ = "STX": B$ = "SoundDuration": C$ = "Save the new Sound duration value": GoSub AO
            z$ = "!"
            A$ = "INC": B$ = "_Var_Timer+1": C$ = "Increment the LSB of the Timer Value": GoSub AO
            A$ = "BNE": B$ = "Not60Hz": C$ = "Skip ahead if not zero": GoSub AO
            A$ = "INC": B$ = "_Var_Timer": C$ = "Increment the MSB of the Timer Value": GoSub AO
            z$ = "Not60Hz"
            A$ = "RTI": B$ = "": C$ = "RETURN FROM INTERRUPT": GoSub AO
        Else
            If Sprites = 1 Then
                ' include the cc3 sprite drawing code here:
                ' Include the delay values for the scanline is on screen
                If Val(GModeMaxY$(Gmode)) = 191 Then
                    Print #1, T2$; "INCLUDE        ./Basic_Includes/CoCo3_FIRQ_Delay_192_Rows.asm"
                End If
                If Val(GModeMaxY$(Gmode)) = 199 Then
                    Print #1, T2$; "INCLUDE        ./Basic_Includes/CoCo3_FIRQ_Delay_200_Rows.asm"
                End If
                If Val(GModeMaxY$(Gmode)) = 224 Then
                    Print #1, T2$; "INCLUDE        ./Basic_Includes/CoCo3_FIRQ_Delay_225_Rows.asm"
                End If
                z$ = "**************** VSyncIRQ *************************": GoSub AO
                z$ = "BASIC_IRQ:": GoSub AO
                Print #1, T2$; "INCLUDE        ./Basic_Includes/CoCo3_IRQandFIRQ_Sprites.asm" ' Sprites also includes FIRQ Sample playback handling
                Print #1, T2$; "INCLUDE        ./Basic_Includes/GraphicCommands/CoCo3_SpriteHandler.asm" 'Add the sprite handling code
            Else
                If Samples = 1 Then
                    z$ = "**************** VSyncIRQ *************************": GoSub AO
                    z$ = "BASIC_IRQ:": GoSub AO
                    A$ = "LDA": B$ = "GIME_InterruptReqEnable_FF92": C$ = "Re enable the VSYNC IRQ": GoSub AO
                    Print #1, T2$; "INCLUDE        ./Basic_Includes/CoCo3_IRQandFIRQ_SamplesOnly.asm" ' Sprites also includes FIRQ Sample playback handling
                End If
            End If
        End If
    End If
Else
    ' Coco 1 or 2
    If Disk = 0 Then
        ' Sound and Timer 60 Hz IRQ
        z$ = "; Sound and Timer 60hz IRQ ": GoSub AO
        z$ = "BASIC_IRQ:": GoSub AO
        A$ = "LDA": B$ = "$FF03": C$ = "CHECK FOR 60HZ INTERRUPT": GoSub AO
        A$ = "BPL": B$ = "Not60Hz": C$ = "RETURN IF 63.5 MICROSECOND INTERRUPT": GoSub AO
        A$ = "LDA": B$ = "$FF02": C$ = "RESET PIA0, PORT B INTERRUPT FLAG": GoSub AO
        A$ = "LDX": B$ = "SoundDuration": C$ = "Get the new Sound duration value": GoSub AO
        A$ = "BEQ": B$ = ">": C$ = "RETURN IF TIMER = 0": GoSub AO
        A$ = "LEAX": B$ = "-1,X": C$ = "DECREMENT TIMER IF NOT = 0": GoSub AO
        A$ = "STX": B$ = "SoundDuration": C$ = "Save the new Sound duration value": GoSub AO
        z$ = "!"
        A$ = "INC": B$ = "_Var_Timer+1": C$ = "Increment the LSB of the Timer Value": GoSub AO
        A$ = "BNE": B$ = "Not60Hz": C$ = "Skip ahead if not zero": GoSub AO
        A$ = "INC": B$ = "_Var_Timer": C$ = "Increment the MSB of the Timer Value": GoSub AO
        z$ = "Not60Hz"
        A$ = "RTI": B$ = "": C$ = "RETURN FROM INTERRUPT": GoSub AO
    Else
        ' DISK controller Interrupts
        '; NMI SERVICE
        z$ = "DNMISV:"
        A$ = "LDA": B$ = "NMIFLG": C$ = "GET NMI FLAG": GoSub AO
        A$ = "BEQ": B$ = "LD8AE": C$ = "RETURN IF NOT ACTIVE": GoSub AO
        A$ = "LDX": B$ = "DNMIVC": C$ = "GET NEW RETURN VECTOR": GoSub AO
        A$ = "STX": B$ = "10,S": C$ = "STORE AT STACKED PC SLOT ON STACK": GoSub AO
        A$ = "CLR": B$ = "NMIFLG": C$ = "RESET NMI FLAG": GoSub AO
        z$ = "LD8AE"
        A$ = "RTI": B$ = "": C$ = "RETURN FROM INTERRUPT": GoSub AO
        '; Disk IRQ SERVICE and Sound and Timer 60 Hz IRQ
        z$ = "BASIC_IRQ:"
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
        z$ = "LD8CD"
        A$ = "LDX": B$ = "SoundDuration": C$ = "Get the new Sound duration value": GoSub AO
        A$ = "BEQ": B$ = ">": C$ = "RETURN IF TIMER = 0": GoSub AO
        A$ = "LEAX": B$ = "-1,X": C$ = "DECREMENT TIMER IF NOT = 0": GoSub AO
        A$ = "STX": B$ = "SoundDuration": C$ = "Save the new Sound duration value": GoSub AO
        z$ = "!"
        A$ = "INC": B$ = "_Var_Timer+1": C$ = "Increment the LSB of the Timer Value": GoSub AO
        A$ = "BNE": B$ = "Not60Hz": C$ = "Skip ahead if not zero": GoSub AO
        A$ = "INC": B$ = "_Var_Timer": C$ = "Increment the MSB of the Timer Value": GoSub AO
        z$ = "Not60Hz"
        A$ = "RTI": B$ = "": C$ = "RETURN FROM INTERRUPT": GoSub AO
    End If
End If
If PlayCommand = 1 Then
    ' Include special PLAY IRQ to jump to while playing notes
    z$ = "; Timer & Play 60hz IRQ ": GoSub AO
    z$ = "PLAY_IRQ:": GoSub AO
    A$ = "LDA": B$ = "$FF03": C$ = "CHECK FOR 60HZ INTERRUPT": GoSub AO
    A$ = "BPL": B$ = "Not60HzPlay": C$ = "RETURN IF 63.5 MICROSECOND INTERRUPT": GoSub AO
    A$ = "LDA": B$ = "$FF02": C$ = "RESET PIA0, PORT B INTERRUPT FLAG": GoSub AO
    A$ = "INC": B$ = "_Var_Timer+1": C$ = "Increment the LSB of the Timer Value": GoSub AO
    A$ = "BNE": B$ = ">": C$ = "Skip ahead if not zero": GoSub AO
    A$ = "INC": B$ = "_Var_Timer": C$ = "Increment the MSB of the Timer Value": GoSub AO
    z$ = "!"
    A$ = "LDD": B$ = "PLYTMR": C$ = "GET THE PLAY TIMER": GoSub AO
    A$ = "BEQ": B$ = ">": C$ = "Exit IRQ": GoSub AO
    A$ = "SUBD": B$ = "VD5": C$ = "SUBTRACT OUT PLAY INTERVAL": GoSub AO
    A$ = "STD": B$ = "PLYTMR": C$ = "SAVE THE NEW TIMER VALUE": GoSub AO
    A$ = "BHI": B$ = ">": C$ = "BRANCH IF PLAY COMMAND NOT DONE": GoSub AO
    A$ = "CLR": B$ = "PLYTMR": C$ = "RESET MSB OF PLAY TIMER IF DONE": GoSub AO
    A$ = "CLR": B$ = "PLYTMR+1": C$ = "RESET LSB OF PLAY TIMER": GoSub AO
    z$ = "PlayIRQExit:": GoSub AO
    A$ = "PULS": B$ = "A": C$ = "GET THE CONDITION CODE REG": GoSub AO
    z$ = "PlayStackPointer:": GoSub AO
    A$ = "LDS": B$ = "#$FFFF": C$ = "LOAD THE STACK POINTER WITH THE CONTENTS OF THE U REGISTER": GoSub AO
    Print #1, "; WHICH WAS STACKED WHEN THE INTERRUPT WAS HONORED."
    A$ = "ANDA": B$ = "#$7F": C$ = "CLEAR E FLAG - MAKE COMPUTER THINK THIS WAS AN FIRQ": GoSub AO
    A$ = "PSHS": B$ = "A": C$ = "Save Condition Code": GoSub AO
    Print #1, "; THE RTI WILL NOW NOT RETURN TO WHERE IT WAS"
    Print #1, "; INTERRUPTED FROM - IT WILL RETURN TO THE MAIN PLAY"
    Print #1, "; COMMAND INTERPRETATION LOOP."
    Print #1, "!"
    z$ = "Not60HzPlay"
    A$ = "RTI": B$ = "": C$ = "RETURN FROM INTERRUPT": GoSub AO
End If
Print #1, "ClearHere2nd:" ' This is the start address of variables that will all be cleared to zero when the program starts
' Add temp string space
For Num = 0 To 1
    GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    If Num < 10 Then num$ = "0" + num$
    Print #1, "_StrVar_PF"; num$; T1$; "RMB "; T1$; "256     ; Temp String Variable"
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
    z$ = "_StrVar_" + StringVariable$(ii): GoSub AO
    A$ = "RMB": B$ = "1": C$ = "String Variable " + StringVariable$(ii) + " length (0 to 255) initialized to 0": GoSub AO
    A$ = "RMB": B$ = "255": C$ = "255 bytes available for string variable " + StringVariable$(ii): GoSub AO
Next ii
Print #1, "; Numeric Arrays Used:"; NumArrayVarsUsedCounter
If NumArrayVarsUsedCounter > 0 Then
    For ii = 0 To NumArrayVarsUsedCounter - 1
        Print #1, "_ArrayNum_"; NumericArrayVariables$(ii)
        Print #1, "; Reserve bytes per element size, set with the DIM command, Type:"; NumericArrayType(ii); "Dimensions:"; NumericArrayDimensions(ii);
        Print #1, "Size of each Dimension:";
        For D1 = 0 To NumericArrayDimensions(ii) - 1
            Print #1, Val("&H" + Mid$(NumericArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1; ","; ' + 1 because it is zero based
        Next D1
        Print #1,
        If NumericArrayBits(ii) = 8 Then StoreAs$ = "FCB" Else StoreAs$ = "FDB"
        Select Case NumericArrayType(ii)
            Case 0 ' Arraysize is 3 bytes - Default is FFP 3 byte fast floating point
                NumericArrayType(ii) = 11 ' force the type to FFP format
                Temp$ = "3*" ' Default is three bytes per element FFP
                Bytes$ = "3 bytes": Format$ = "Fast Floating Point"
            Case 1 To 4 ' Arraysize is 1 byte
                Temp$ = "" ' 1 byte per element
                Bytes$ = "1 byte": Format$ = "8 Bit Integer"
            Case 5, 6 ' Arraysize is 2 bytes
                Temp$ = "2*" ' Two bytes per element
                Bytes$ = "2 bytes": Format$ = "16 bit Integer"
            Case 7, 8 ' Arraysize is 4 bytes
                Temp$ = "4*" ' Four bytes per element
                Bytes$ = "4 bytes": Format$ = "32 bit Integer"
            Case 9, 10 ' Arraysize is 8 bytes
                Temp$ = "8*" ' Eight bytes per element
                Bytes$ = "8 bytes": Format$ = "64 bit Integer"
            Case 11 ' Arraysize is 3 bytes -  FFP 3 byte fast floating point
                Temp$ = "3*" ' Three bytes per element
                Bytes$ = "3 bytes": Format$ = "Fast Floating Point"
            Case 12 ' Arraysize is 8 bytes
                Temp$ = "10*" ' Eight bytes per element
                Bytes$ = "10 bytes": Format$ = "Double Floating Point"
        End Select
        For D1 = 0 To NumericArrayDimensions(ii) - 1
            Num = Val("&H" + Mid$(NumericArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 ' + 1 because it is zero based
            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            Temp$ = Temp$ + num$ + "*"
            A$ = StoreAs$: B$ = num$: C$ = "Size of each array element, set with the DIM command, Default is 10 zero based": GoSub AO
        Next D1
        Temp$ = Left$(Temp$, Len(Temp$) - 1) ' Remove the extra '*'
        A$ = "RMB": B$ = Temp$: C$ = "Reserve Space for the Array, " + Bytes$ + " per element, " + Format$: GoSub AO
    Next ii
End If

Print #1, "; String Arrays Used:"; StringArrayVarsUsedCounter
If StringArrayVarsUsedCounter > 0 Then
    For ii = 0 To StringArrayVarsUsedCounter - 1
        StringArrayReserveSize = StringArraySize + 1 ' Need an extra byte for the actual string size value
        Num = StringArrayReserveSize
        GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        'Temp$ = "256*" '256 bytes per element
        Temp$ = num$ + "*" '# of bytes per element
        For D1 = 0 To StringArrayDimensions(ii) - 1
            Num = Val("&H" + Mid$(StringArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 ' + 1 because it is zero based
            GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            Temp$ = Temp$ + num$ + "*"
        Next D1
        Temp$ = Left$(Temp$, Len(Temp$) - 1) ' Remove the extra '*'
        Print #1, "_ArrayStr_"; StringArrayVariables$(ii)
        Print #1, "; Reserve bytes per element size, set with the DIM command"
        If StringArrayBits(ii) = 8 Then
            ' Arraysize is 8 bits
            For D1 = 0 To StringArrayDimensions(ii) - 1
                Num = Val("&H" + Mid$(StringArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 ' + 1 because it is zero based
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                A$ = "FCB": B$ = num$: C$ = "Default size of each array element is 11 (0 to 10), changed with the DIM command": GoSub AO
            Next D1
        Else
            ' Arraysize is 16 bits
            For D1 = 0 To StringArrayDimensions(ii) - 1
                Num = Val("&H" + Mid$(StringArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 ' + 1 because it is zero based
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                A$ = "FDB": B$ = num$: C$ = "Use 16 bit values, changed with the DIM command": GoSub AO
            Next D1
        End If
        A$ = "RMB": B$ = Temp$: C$ = "String size+1 per element": GoSub AO
    Next ii
End If
Print #1, "EndClearHere2nd:" ' This is the end address of variables that will all be cleared to zero when the program starts

Print #1, "; General Commands Used:"; GeneralCommandsFoundCount
For ii = 0 To GeneralCommandsFoundCount - 1
    Print #1, "; " + GeneralCommandsFound$(ii)
Next ii

Print #1, "; Numeric Commands Used:"; NumericCommandsFoundCount
For ii = 0 To NumericCommandsFoundCount - 1
    Print #1, "; " + NumericCommandsFound$(ii)
    If NumericCommandsFound$(ii) = "POS" Then
        POSCommand = 1
        Print "Found a POS command"
    End If
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

If CoCo3 = 1 And Sprites = 1 Then
    ' include the CoCo3 Palette file:
    Print #1, T2$; "INCLUDE        ./CoCo3_Palette.asm" ' Add the CoCo3 Palette file that was generated by PNGtoCCSprite program
    For ii = 0 To 171
        If GModeLib(ii) = 1 Then
            v1 = Val("&H" + GModeScreenSize$(Gmode))
            TempVal = 0
            While (TempVal < v1): TempVal = TempVal + &H2000: Wend ' Get the number of bytes needed per screen at this resolution
            TempVal = TempVal / &H2000 ' Get the block numbers required
            Print #1, "CC3ScreenBlockSize EQU  $"; Right$("00" + Hex$(TempVal), 2); "        # of $2000 blocks required per screen"
        End If
    Next ii
    Print #1, "CC3SpritesStartBLKTable:"
    For c = 0 To 31
        If Sprite$(c) <> "" Then
            Num = c: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            num$ = Right$("00" + num$, 2)
            SpritePointerBlk$ = "Sprite" + num$ + "Blk"
            Num = SpriteLivesAt(c): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            If num$ = "" Then num$ = "00"
            A$ = "FCB": B$ = SpritePointerBlk$: C$ = "8k block # where Sprite #" + Str$(c) + " begins": GoSub AO
        Else
            A$ = "FCB": B$ = "$00": C$ = "No sprite, this will be ignored": GoSub AO
        End If
    Next c
End If
If CoCo3 = 1 And Samples = 1 Then
    Print #1, "CC3SamplesStartBLKTable:"
    For i = 0 To 31
        If Sample$(i) <> "" Then
            Num = SampleNumberOfBLKs(i) - 3 + SampleStartBlock(i)
            BlockZero$ = Right$(Hex$(Num), 2)
            If Len(BlockZero$) < 2 Then BlockZero$ = Right$("00" + BlockZero$, 2)
            Num = SampleNumberOfBLKs(i) - 3 + SampleStartBlock(i) + 1
            BlockOne$ = Right$(Hex$(Num), 2)
            If Len(BlockOne$) < 2 Then BlockOne$ = Right$("00" + BlockOne$, 2)
            A$ = "FDB": B$ = "$" + BlockZero$ + BlockOne$: C$ = "First & second of 4, 8k blocks with the audio sample data": GoSub AO
            Num = SampleStart(i): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            A$ = "FDB": B$ = "$" + Hex$(Val(num$)): C$ = "Sample Start address": GoSub AO
        Else
            A$ = "FQB": B$ = "$00": C$ = "No Sample, this will be ignored": GoSub AO
        End If
    Next i
End If
If CoCo3 = 1 Then
    GraphicVars = 1
    Temp$ = "GraphicCommands/GraphicVariables": GoSub AddIncludeTemp ' Add code for graphics variables
End If

If Verbose > 0 Then Print "Adding the required Libraries..."
' Add includes that are necessary
' Add graphics libraries that are needed depending on the GMODE used
For ii = 0 To 171
    If GModeLib(ii) = 1 Then
        GraphicVars = 1
        Temp$ = "GraphicCommands/GraphicVariables": GoSub AddIncludeTemp ' Add code for graphics variables
        If ii > 99 Then
            Temp$ = "GraphicCommands/CoCo3_Graphic_CodeJump": GoSub AddIncludeTemp ' Add code for CoCo3 graphics handling
        End If
        Temp$ = "GraphicCommands/" + GModeName$(ii) + "/" + GModeName$(ii) + "_Main": GoSub AddIncludeTemp
    End If
Next ii
' Make sure Grpahics commands are first to be included
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
For ii = 0 To GeneralCommandsFoundCount - 1
    Temp$ = UCase$(GeneralCommandsFound$(ii))
    If Temp$ = "SET" Then
        For i3 = 0 To 171
            If GModeLib(i3) = 1 Then
                Temp$ = "GraphicCommands/" + GModeName$(i3) + "/" + GModeName$(i3) + "_Line": GoSub AddIncludeTemp
            End If
        Next i3
    End If
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
        For i3 = 0 To 171
            If GModeLib(i3) = 1 Then
                Temp$ = "GraphicCommands/" + GModeName$(i3) + "/" + GModeName$(i3) + "_Draw": GoSub AddIncludeTemp
                Temp$ = "DecimalStringToD": GoSub AddIncludeTemp ' Add commands for converting decimal numbers to D
                Temp$ = "GraphicCommands/" + GModeName$(i3) + "/" + GModeName$(i3) + "_Line": GoSub AddIncludeTemp ' Draw uses the line command
            End If
        Next i3
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
' List of includes needing to be added, only if it's not already in the list
' Add numeric libraries based on the needed formats
For ii = 1 To NumericVariableCount - 1 ' 0 is the Timer Variable, but we don't want to clear it so we mannually enter it above
    Select Case NumericVarType(ii)
        Case 0 ' Deafult size is Single
            Temp$ = "Math_Fast_Floating_Point": GoSub AddIncludeTemp ' Add code for my 3 byte fast floating point math routines
        Case 1 To 4 ' Variable size is 1 byte
            ' 6809 can handle these pretty much directly
        Case 5, 6 ' Variable is 2 bytes
            Temp$ = "Math_Integer16": GoSub AddIncludeTemp ' Add code for 16 bit Mul, Div
        Case 7, 8 ' Variable is 4 bytes
            Temp$ = "Math_Integer32": GoSub AddIncludeTemp ' Add code for 32 bit math
        Case 9, 10 ' Variable is 8 bytes
            Temp$ = "Math_Integer64": GoSub AddIncludeTemp ' Add code for 64 bit math
        Case 11 ' Variable is 3 bytes
            Temp$ = "Math_Fast_Floating_Point": GoSub AddIncludeTemp ' Add code for my 3 byte fast floating point math routines
        Case 12 ' Variable is 8 bytes
            Temp$ = "Math_IEEE_754_Double_64bit": GoSub AddIncludeTemp ' Add code for Selecting the audio muxer and to turn it on or off
            Temp$ = "Math_Integer64": GoSub AddIncludeTemp ' Add code for 64 bit math, some routines use integer 64 Add/Subtract
        Case 14 To 29 ' Variable is 2 bytes
            ' Add library for these special short floats
    End Select
Next ii

' Add types that are assigned to numeric arrays
For ii = 0 To NumArrayVarsUsedCounter - 1
    Select Case NumericArrayType(ii)
        Case 0 ' Deafult size is Single
            Temp$ = "Math_Fast_Floating_Point": GoSub AddIncludeTemp ' Add code for my 3 byte fast floating point math routines
        Case 1 To 4 ' Variable size is 1 byte
            ' 6809 can handle these pretty much directly
        Case 5, 6 ' Variable is 2 bytes
            Temp$ = "Math_Integer16": GoSub AddIncludeTemp ' Add code for 16 bit Mul, Div
        Case 7, 8 ' Variable is 4 bytes
            Temp$ = "Math_Integer32": GoSub AddIncludeTemp ' Add code for 32 bit math
        Case 9, 10 ' Variable is 8 bytes
            Temp$ = "Math_Integer64": GoSub AddIncludeTemp ' Add code for 64 bit math
        Case 11 ' Variable is 3 bytes
            Temp$ = "Math_Fast_Floating_Point": GoSub AddIncludeTemp ' Add code for my 3 byte fast floating point math routines
        Case 12 ' Variable is 8 bytes
            Temp$ = "Math_IEEE_754_Double_64bit": GoSub AddIncludeTemp ' Add code for Selecting the audio muxer and to turn it on or off
            Temp$ = "Math_Integer64": GoSub AddIncludeTemp ' Add code for 64 bit math, some routines use integer 64 Add/Subtract
        Case 14 To 29 ' Variable is 2 bytes
            ' Add library for these special short floats
    End Select
Next ii


Print #1, "; Section of necessary included code:"
For ii = 0 To GeneralCommandsFoundCount - 1
    Temp$ = UCase$(GeneralCommandsFound$(ii))

    If Temp$ = "CMP" Or Temp$ = "RGB" Then
        Temp$ = "CoCo3_CMP_RGB": GoSub AddIncludeTemp ' The CMP & RGB routines
    End If
    If Temp$ = "LPOKE" Then
        Temp$ = "LPEEK_LPOKE": GoSub AddIncludeTemp ' The LPEEK & LPOKE routines
    End If
    If Temp$ = "AUDIO" Then
        Temp$ = "Audio_Muxer": GoSub AddIncludeTemp ' Add code for Selecting the audio muxer and to turn it on or off
    End If
    If Temp$ = "GETJOYD" Then
        Temp$ = "GetJoyD": GoSub AddIncludeTemp ' Add code to quickly get the Joystick values and set the values of 0,31 or 63
    End If
    If Temp$ = "DATA" Then
        Temp$ = "ASCIIToNumbers": GoSub AddIncludeTemp ' Inlcude code to convert ASCII numbers to other formats (Integer/ FFP...)
    End If
    If Temp$ = "INPUT" Then
        '        Temp$ = "KeyboardInput": GoSub AddIncludeTemp
        If Dragon = 1 Then
            Temp$ = "InkeyDragon": GoSub AddIncludeTemp ' Add the Dragon Inkey library
        Else
            Temp$ = "Inkey": GoSub AddIncludeTemp ' Add the CoCo Inkey library
        End If
        Temp$ = "INPUTCode": GoSub AddIncludeTemp
        Temp$ = "ASCIIToNumbers": GoSub AddIncludeTemp ' Inlcude code to convert ASCII numbers to other formats (Integer/ FFP...)
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
    If Temp$ = "SCREEN" Then
        GraphicVars = 1
        Temp$ = "GraphicCommands/GraphicVariables": GoSub AddIncludeTemp ' Add code for graphics variables
    End If
    If Temp$ = "SDC_PLAY" Or Temp$ = "SDC_PLAYORCL" Or Temp$ = "SDC_PLAYORCR" Or Temp$ = "SDC_PLAYORCS" Then
        If Temp$ = "SDC_PLAY" Then
            Temp$ = "SDC_Play": GoSub AddIncludeTemp
            Temp$ = "Audio_Muxer": GoSub AddIncludeTemp ' Add code for Selecting the audio muxer and to turn it on or off
        End If
        If Temp$ = "SDC_PLAYORCL" Then Temp$ = "SDC_PlayOrc90Left": GoSub AddIncludeTemp
        If Temp$ = "SDC_PLAYORCR" Then Temp$ = "SDC_PlayOrc90Right": GoSub AddIncludeTemp
        If Temp$ = "SDC_PLAYORCS" Then Temp$ = "SDC_PlayOrc90Stereo": GoSub AddIncludeTemp
        Temp$ = "SDC_Comm": GoSub AddIncludeTemp
        Temp$ = "SDC_CompilerCode": GoSub AddIncludeTemp
        Temp$ = "SDC_FileAccess": GoSub AddIncludeTemp
        Temp$ = "SDC_StreamFile_Library": GoSub AddIncludeTemp
    End If
    If Temp$ = "SDC_GETBYTE0" Or Temp$ = "SDC_GETBYTE1" Or Temp$ = "SDC_PUTBYTE0" Or Temp$ = "SDC_PUTBYTE1" Or Temp$ = "SDC_DIRPAGE" Or Temp$ = "SDC_SETPOS" Or Temp$ = "SDC_CLOSE" Or Temp$ = "SDC_OPEN" Then
        Temp$ = "SDC_Comm": GoSub AddIncludeTemp
        Temp$ = "SDC_CompilerCode": GoSub AddIncludeTemp
        Temp$ = "SDC_FileAccess": GoSub AddIncludeTemp
        '
    End If
    If Temp$ = "SDC_LOADM" Or Temp$ = "SDC_SAVEM" Then
        Temp$ = "SDC_Comm": GoSub AddIncludeTemp
        Temp$ = "SDC_CompilerCode": GoSub AddIncludeTemp
        Temp$ = "SDC_FileAccess": GoSub AddIncludeTemp
        Temp$ = "SDC_LoadmSavem": GoSub AddIncludeTemp
    End If
    If Temp$ = "SDC_BIGLOADM" Then
        Temp$ = "SDC_Comm": GoSub AddIncludeTemp
        Temp$ = "SDC_CompilerCode": GoSub AddIncludeTemp
        Temp$ = "SDC_StreamFile_Library": GoSub AddIncludeTemp
        Temp$ = "SDC_BigLoadm": GoSub AddIncludeTemp
    End If

    If Temp$ = "SOUND" Then
        Temp$ = "Sound": GoSub AddIncludeTemp ' Add code for the sound command
        Temp$ = "Audio_Muxer": GoSub AddIncludeTemp 'SOUND routine also requires the Muxer to be turned on
    End If
    If Temp$ = "COPYBLOCKS" Then
        Temp$ = "CoCo3_Copy8kBlocks": GoSub AddIncludeTemp ' Add code for the Copy8kBlocks command
    End If
Next ii

For ii = 0 To StringCommandsFoundCount - 1
    Temp$ = UCase$(StringCommandsFound$(ii))
    If Temp$ = "INKEY$" Then
        If Dragon = 1 Then
            Temp$ = "InkeyDragon": GoSub AddIncludeTemp ' Add the Dragon Inkey library
        Else
            Temp$ = "Inkey": GoSub AddIncludeTemp ' Add the CoCo Inkey library
        End If
    End If
    If Temp$ = "SDC_FILEINFO$" Or Temp$ = "SDC_GETCURDIR$" Then
        Temp$ = "SDC_Comm": GoSub AddIncludeTemp
        Temp$ = "SDC_CompilerCode": GoSub AddIncludeTemp
        Temp$ = "SDC_FileAccess": GoSub AddIncludeTemp
        '        Temp$ = "SDCVersionCheck": GoSub AddIncludeTemp
    End If
Next ii
For ii = 0 To NumericCommandsFoundCount - 1
    Temp$ = UCase$(NumericCommandsFound$(ii))

    If Temp$ = "LPEEK" Then
        Temp$ = "LPEEK_LPOKE": GoSub AddIncludeTemp ' The LPEEK & LPOKE routines
    End If
    If Temp$ = "BUTTON" Then
        Temp$ = "JoyButton": GoSub AddIncludeTemp 'Add code to handle reading the joystick buttons
    End If
    If Left$(Temp$, 8) = "COCOMP3_" Then
        Temp$ = "CoCoMP3_Compiler_Library": GoSub AddIncludeTemp ' Add code for handling the CoCoMP3
    End If
    If Temp$ = "SDC_GETBYTE" Or Temp$ = "SDC_MKDIR" Or Temp$ = "SDC_SETDIR" Or Temp$ = "SDC_INITDIR" Or Temp$ = "SDC_DELETE" Then
        Temp$ = "SDC_Comm": GoSub AddIncludeTemp
        Temp$ = "SDC_CompilerCode": GoSub AddIncludeTemp
        Temp$ = "SDC_FileAccess": GoSub AddIncludeTemp
        '        Temp$ = "SDCVersionCheck": GoSub AddIncludeTemp
    End If
    If Temp$ = "JOYSTK" Then
        Temp$ = "Joystick": GoSub AddIncludeTemp 'Add code to handle analog Joystick input
        Temp$ = "Audio_Muxer": GoSub AddIncludeTemp 'Joystick routine also requires the Muxer to be turned off
    End If
    If Temp$ = "VAL" Then
        Temp$ = "DecimalStringToD": GoSub AddIncludeTemp
        Temp$ = "HexStringToD": GoSub AddIncludeTemp
    End If
Next ii
If NumArrayVarsUsedCounter > 0 Or StringArrayVarsUsedCounter > 0 Then Temp$ = "ArrayHandler": GoSub AddIncludeTemp 'Add routines to handle Arrays

' Libraries always included, other libraries use them, so they are required
Temp$ = "Equates": GoSub AddIncludeTemp
Temp$ = "Print": GoSub AddIncludeTemp

If WidthVal$ <> "" And WidthVal$ <> "32" Then
    Temp$ = "CoCo3_PrintA_Width_" + WidthVal$: GoSub AddIncludeTemp ' Include the CoCo 3 TextMode print routines
    Temp$ = "CoCo3_TextMode": GoSub AddIncludeTemp ' Include the CoCo 3 TextMode data
Else
    Temp$ = "PrintA": GoSub AddIncludeTemp ' Include for printing A to the normal 32 width screen
End If
Temp$ = "Print_Serial": GoSub AddIncludeTemp
Temp$ = "Math_Integer16": GoSub AddIncludeTemp ' 16 bit MUL and DIV
Temp$ = "Math_Variables": GoSub AddIncludeTemp ' Math_Integer16 needs this
Temp$ = "SquareRoot": GoSub AddIncludeTemp
Temp$ = "CPUSpeed": GoSub AddIncludeTemp
Temp$ = "StringCommands": GoSub AddIncludeTemp ' Add general command library
Temp$ = "Random": GoSub AddIncludeTemp ' Add the code to do a Random number

If Sprites = 1 Then
    Print #1, "; Adding the Compiled Sprites and pointers..."
    Select Case Val(GModeColours$(Gmode))
        Case 2
            ColourDiv = 8
        Case 4
            ColourDiv = 4
        Case 16
            ColourDiv = 2
    End Select
    If CoCo3 <> 1 Then
        ' Do this for CoCo 1 & 2
        Num = (Val(GModeMaxX$(Gmode)) + 1) / ColourDiv: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        z$ = "GmodeBytesPerRow EQU     " + num$ + "        ; # of bytes per graphics row, used by the sprite rendering code": GoSub AO
        Num = Val("&H" + GModeScreenSize$(Gmode)): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        z$ = "ScreenSize       EQU     " + num$ + "        ; Size of a graphics screen": GoSub AO
        Num = Val(GModeMaxX$(Gmode)): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        z$ = "PixelsMaxX       EQU     " + num$ + "        ; Screen width Max from 0 to this value": GoSub AO
        Num = Val(GModeColours$(Gmode)): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        z$ = "NumberOfColours  EQU     " + num$ + "        ; Number of Colours on this screen": GoSub AO
        If Gmode = 18 Then
            ' We are going to use CoCo 1 & 2 Hi-res artifacting mode
            z$ = "Artifacting      EQU     1         ; Using Artifact colours": GoSub AO
        Else
            z$ = "Artifacting      EQU     0         ; Not using Artifact colours": GoSub AO
        End If
        For i = 0 To 31
            If Sprite$(i) <> "" Then
                Print #1, T2$; "INCLUDE     ./"; Sprite$(i)
            End If
        Next i
        Temp$ = "GraphicCommands/SpriteHandler": GoSub AddIncludeTemp

        z$ = "SpriteDrawTable:": GoSub AO
        For i = 0 To 31
            If Sprite$(i) <> "" Then
                ' Find the last backslash
                p = _InStrRev(Sprite$(i), "/")
                If p = 0 Then p = _InStrRev(Sprite$(i), "\")
                ' Extract the filename
                If p > 0 Then
                    SpriteName$ = Mid$(Sprite$(i), p + 1)
                Else
                    SpriteName$ = Sprite$(i) ' No backslash found, assume it's just a filename
                End If
                SpriteName$ = Left$(SpriteName$, Len(SpriteName$) - 4) ' remove the .asm
                A$ = "FDB": B$ = SpriteName$ + "_Draw": C$ = "Points to the Sprite Drawing Table (in the compiled sprite.asm file)": GoSub AO
            End If
        Next i
    End If
    z$ = "SpriteBackupTable:": GoSub AO
    For i = 0 To 31
        If Sprite$(i) <> "" Then
            ' Find the last backslash
            p = _InStrRev(Sprite$(i), "/")
            If p = 0 Then p = _InStrRev(Sprite$(i), "\")
            ' Extract the filename
            If p > 0 Then
                SpriteName$ = Mid$(Sprite$(i), p + 1)
            Else
                SpriteName$ = Sprite$(i) ' No backslash found, assume it's just a filename
            End If
            SpriteName$ = Left$(SpriteName$, Len(SpriteName$) - 4) ' remove the .asm
            A$ = "FDB": B$ = "Backup_" + SpriteName$: C$ = "Address of the Make Backup code": GoSub AO
        Else
            A$ = "FDB": B$ = "$0000": C$ = "No Sprite for this slot": GoSub AO
        End If
    Next i
    z$ = "SpriteRestoreTable:": GoSub AO ' For VSYNC 0
    For i = 0 To 31
        If Sprite$(i) <> "" Then
            ' Find the last backslash
            p = _InStrRev(Sprite$(i), "/")
            If p = 0 Then p = _InStrRev(Sprite$(i), "\")
            ' Extract the filename
            If p > 0 Then
                SpriteName$ = Mid$(Sprite$(i), p + 1)
            Else
                SpriteName$ = Sprite$(i) ' No backslash found, assume it's just a filename
            End If
            SpriteName$ = Left$(SpriteName$, Len(SpriteName$) - 4) ' remove the .asm
            A$ = "FDB": B$ = "Restore_" + SpriteName$ + "_0": C$ = "Address of the restore code Buffer 0": GoSub AO
            A$ = "FDB": B$ = "Restore_" + SpriteName$ + "_1": C$ = "Address of the restore code Buffer 1": GoSub AO
        Else
            A$ = "FDB": B$ = "$0000": C$ = "No Sprite for this slot 0": GoSub AO
            A$ = "FDB": B$ = "$0000": C$ = "No Sprite for this slot 1": GoSub AO
        End If
    Next i
End If

GoSub WriteIncludeListToFile ' Write all the INCLUDE files needed to the .ASM file
GoSub AO
If GraphicVars = 0 And POSCommand = 1 Then
    ' We need some variables for the POS command to work properly
    z$ = "BEGGRP           FDB     $0400      ; Needed by the POS command": GoSub AO
    z$ = "x0               FDB     $0000      ; Needed by the POS command": GoSub AO
End If
GoSub AO

Print #1, "* Main Program"
Print #1, "START:"
A$ = "PSHS": B$ = "CC,D,DP,X,Y,U": C$ = "Save the original BASIC Register values": GoSub AO
A$ = "STS": B$ = "RestoreStack+2": C$ = "save the original BASIC stack pointer value (try to Return at the end of the program) (self modify code)": GoSub AO
A$ = "LDS": B$ = "#$0400": C$ = "Set up the stack pointer": GoSub AO
A$ = "ORCC": B$ = "#$50": C$ = "Turn off the interrupts": GoSub AO
A$ = "LDA": B$ = "#$" + DirectPage$: GoSub AO
A$ = "TFR": B$ = "A,DP": C$ = "Setup the Direct page to use our variable location": GoSub AO

' Extra randomness
A$ = "TST": B$ = "$FF02": C$ = "Reset the VSYNC flag": GoSub AO
z$ = "!": A$ = "ADDD": B$ = "#$0001": C$ = "Increment the counter": GoSub AO
A$ = "TST": B$ = "$FF03": C$ = "Test for new Vsync": GoSub AO
A$ = "BPL": B$ = "<": C$ = "If bit 7 is not set (Vsync hasn't happened yet) keep looping": GoSub AO
A$ = "STD": B$ = ">Seed3": C$ = "Save 16 bit random seed, seed1 & 2 will use the timer": GoSub AO
'
If CoCo3 = 1 Then
    A$ = "LDA": B$ = "#$38": C$ = "Normal First Bank": GoSub AO
    A$ = "STA": B$ = "$FFA8": C$ = "Make first block in 2nd bank the same as the first bank, this is where the IRQs are": GoSub AO
    ' We are using CoCo 3 commands, So let's put it in CoCo 3 mode
    z$ = "* CoCo 3 commands were detected, Enabling CoCo3 mode and Hi Speed": GoSub AO
    A$ = "LDA": B$ = "#%01111100": C$ = "CoCo 3 Mode, MMU Enabled, GIME IRQ Enabled, GIME FIRQ Enabled, Vector RAM at FEXX enabled, Standard SCS Normal, ROM Map 16k Int, 16k Ext": GoSub AO
    A$ = "STA": B$ = "$FF90": C$ = "Make the changes": GoSub AO
    ' Set graphics mode to text
    Select Case WidthVal$
        Case Is = "32", Is = ""
            ' Use the regular 32 char text screen
            A$ = "LDX": B$ = "#$0400": C$ = "Text screen starts here": GoSub AO
            A$ = "STX": B$ = "BEGGRP": C$ = "Update the Screen starting location": GoSub AO
            A$ = "LDA": B$ = "#$0F": C$ = "$0F Back to Text Mode for the CoCo 3": GoSub AO
            A$ = "STA": B$ = "$FF9C": C$ = "Neccesary for CoCo 3 GIME to use this mode": GoSub AO
            ' Go to CoCo 3 Text mode
            A$ = "LDA": B$ = "#$CC": GoSub AO
            A$ = "STA": B$ = "$FF90": GoSub AO
            A$ = "LDD": B$ = "#$0000": GoSub AO
            A$ = "STD": B$ = "$FF98": GoSub AO
            A$ = "STD": B$ = "$FF9A": GoSub AO
            A$ = "STD": B$ = "$FF9E": GoSub AO
            A$ = "LDD": B$ = "#$0FE0": GoSub AO
            A$ = "STD": B$ = "$FF9C": GoSub AO
            A$ = "LDA": B$ = "#Internal_Alphanumeric": C$ = "A = Text mode requested": GoSub AO
            ' Update the Graphic mode and the screen viewer location
            A$ = "JSR": B$ = "SetGraphicModeA": C$ = "Go setup the mode": GoSub AO
            A$ = "LDA": B$ = "BEGGRP": C$ = "Get the MSB of the Screen starting location": GoSub AO
            A$ = "LSRA": C$ = "Divide by 2 - 512 bytes per start location": GoSub AO
            A$ = "JSR": B$ = "SetGraphicsStartA": C$ = "Go set the address of the screen": GoSub AO

            ' $FF98
            ' 0x00100010 - Text Mode,Extra Descenders,Colour,60 Hz,8 lines per character
            'WIDTH info:$FF99 (65433) Video resolution register - VRES CoCo 3
            'Width 32 = 0x01100001
            'Width 40 = 0x01100101
            'Width 64 = 0x01110001
            'Width 80 = 0x01110101

            'Attribute byte:
            'Bit 7 1 = Blink
            'Bit 6 1 = Underline
            'Bits 5-3 Foreground Palette 0-7 from $FFB0-$FFB7
            'Bits 2-0 Background Palette 0-7 from $FFB8-$FFBF

        Case "40"
            ' Use the CoCo 3 40 column text screen
            A$ = "LDX": B$ = "#$0E00": C$ = "Text screen starts here": GoSub AO
            A$ = "STX": B$ = "BEGGRP": C$ = "Update the Screen starting location": GoSub AO
            z$ = "; $FF98 = 0x00100011 - Text Mode,Extra Descenders,Colour,60 Hz,8 lines per character": GoSub AO
            z$ = "; $FF99 = 0x01100101 - 40 Column mode": GoSub AO
            ' A$ = "LDA": B$ = "#%00100011": GoSub AO
            ' A$ = "LDB": B$ = "#%01100101": GoSub AO
            A$ = "LDD": B$ = "#$2365": GoSub AO
            A$ = "STD": B$ = "$FF98": GoSub AO
            A$ = "LDD": B$ = "#$0000": GoSub AO
            A$ = "STD": B$ = "W_CURPOS": C$ = "Set the cursor to the top left corner, Width 40, 64 & 80 use x,y screen co-ordinates": GoSub AO
            A$ = "STD": B$ = "$FF9A": C$ = "Border color register - BRDR & 2 Meg Vertual 512k Bank": GoSub AO
            A$ = "STA": B$ = "$FF9C": C$ = "Vertical scroll register - VSC": GoSub AO
            A$ = "STA": B$ = "$FF9F": C$ = "Clear the Horizontal register": GoSub AO
            '$FF9D-$FF9E Vertical offset register
            A$ = "LDD": B$ = "#$" + Hex$((&H38 * &H2000 + &HE00) / 8): GoSub AO
            A$ = "STD": B$ = "$FF9D": C$ = "Vertical offset register": GoSub AO
        Case "64"
            ' Use the CoCo 3 64 column text screen
            A$ = "LDX": B$ = "#$0E00": C$ = "Text screen starts here": GoSub AO
            A$ = "STX": B$ = "BEGGRP": C$ = "Update the Screen starting location": GoSub AO
            z$ = "; $FF98 = 0x00100011 - Text Mode,Extra Descenders,Colour,60 Hz,8 lines per character": GoSub AO
            z$ = "; $FF99 = 0x01111001 - 64 Column mode": GoSub AO
            ' A$ = "LDA": B$ = "#%00100011": GoSub AO
            ' A$ = "LDB": B$ = "#%01100101": GoSub AO
            A$ = "LDD": B$ = "#$2371": GoSub AO
            A$ = "STD": B$ = "$FF98": GoSub AO
            A$ = "LDD": B$ = "#$0000": GoSub AO
            A$ = "STD": B$ = "W_CURPOS": C$ = "Set the cursor to the top left corner, Width 40, 64 & 80 use x,y screen co-ordinates": GoSub AO
            A$ = "STD": B$ = "$FF9A": C$ = "Border color register - BRDR & 2 Meg Vertual 512k Bank": GoSub AO
            A$ = "STA": B$ = "$FF9C": C$ = "Vertical scroll register - VSC": GoSub AO
            A$ = "STA": B$ = "$FF9F": C$ = "Clear the Horizontal register": GoSub AO
            '$FF9D-$FF9E Vertical offset register
            A$ = "LDD": B$ = "#$" + Hex$((&H38 * &H2000 + &HE00) / 8): GoSub AO
            A$ = "STD": B$ = "$FF9D": C$ = "Vertical offset register": GoSub AO
        Case "80"
            ' Use the CoCo 3 80 column text screen
            A$ = "LDX": B$ = "#$0E00": C$ = "Text screen starts here": GoSub AO
            A$ = "STX": B$ = "BEGGRP": C$ = "Update the Screen starting location": GoSub AO
            z$ = "; $FF98 = 0x00100011 - Text Mode,Extra Descenders,Colour,60 Hz,8 lines per character": GoSub AO
            z$ = "; $FF99 = 0x01110101 - 80 Column mode": GoSub AO
            ' A$ = "LDA": B$ = "#%00100011": GoSub AO
            ' A$ = "LDB": B$ = "#%01100101": GoSub AO
            A$ = "LDD": B$ = "#$2375": GoSub AO
            A$ = "STD": B$ = "$FF98": GoSub AO
            A$ = "LDD": B$ = "#$0000": GoSub AO
            A$ = "STD": B$ = "W_CURPOS": C$ = "Set the cursor to the top left corner, Width 40, 64 & 80 use x,y screen co-ordinates": GoSub AO
            A$ = "STD": B$ = "$FF9A": C$ = "Border color register - BRDR & 2 Meg Vertual 512k Bank": GoSub AO
            A$ = "STA": B$ = "$FF9C": C$ = "Vertical scroll register - VSC": GoSub AO
            A$ = "STA": B$ = "$FF9F": C$ = "Clear the Horizontal register": GoSub AO
            '$FF9D-$FF9E Vertical offset register
            A$ = "LDD": B$ = "#$" + Hex$((&H38 * &H2000 + &HE00) / 8): GoSub AO
            A$ = "STD": B$ = "$FF9D": C$ = "Vertical offset register": GoSub AO
    End Select
End If
z$ = "* Enable 6 Bit DAC output": GoSub AO
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

A$ = "JMP": B$ = "SkipClear": C$ = "On startup skip ahead and do a BSR to this section to clear the variables, as CLEAR will use this code": GoSub AO
' Clear variable RAM  (make this a routine as the CLEAR command will use it to erase all the variables
z$ = "ClearVariables:": GoSub AO
A$ = "LDX": B$ = "#StartClearHere": C$ = "Set the start address of the variables that will be cleared to zero when the program starts": GoSub AO
A$ = "CLRA": C$ = "Clear Accumulator A": GoSub AO
z$ = "!"
A$ = "STA": B$ = ",X+": C$ = "Clear the variable space, move pointer forward": GoSub AO
A$ = "CMPX": B$ = "#EndClearHere": C$ = "Compare the current address to the end of the variables that will be cleared to zero when the program starts": GoSub AO
A$ = "BNE": B$ = "<": C$ = "Loop until all cleared": GoSub AO

A$ = "LDX": B$ = "#ClearHere2nd": C$ = "Set the start address of the variables that will be cleared to zero when the program starts": GoSub AO
A$ = "CLRA": C$ = "Clear Accumulator A": GoSub AO
z$ = "!"
A$ = "STA": B$ = ",X+": C$ = "Clear the variable space, move pointer forward": GoSub AO
A$ = "CMPX": B$ = "#EndClearHere2nd": C$ = "Compare the current address to the end of the variables that will be cleared to zero when the program starts": GoSub AO
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
                If num$ <> Lastnum$ Then
                    A$ = "LDA": B$ = "#" + num$: C$ = "Element size set with the DIM command": GoSub AO
                    Lastnum$ = num$
                End If
                A$ = "STA": B$ = ",X+": GoSub AO
            Next D1
        Else
            ' 16 bit array
            For D1 = 0 To NumericArrayDimensions(ii) - 1
                Num = Val("&H" + Mid$(NumericArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 '+1 because it's zero based
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num$ <> Lastnum$ Then
                    A$ = "LDD": B$ = "#" + num$: C$ = "Element size set with the DIM command": GoSub AO
                    Lastnum$ = num$
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
                If num$ <> Lastnum$ Then
                    A$ = "LDA": B$ = "#" + num$: C$ = "Element size set with the DIM command": GoSub AO
                    Lastnum$ = num$
                End If
                A$ = "STA": B$ = ",X+": GoSub AO
            Next D1
        Else
            ' 16 bit array
            For D1 = 0 To StringArrayDimensions(ii) - 1
                Num = Val("&H" + Mid$(StringArrayDimensionsVal$(ii), 1 + D1 * 4, 4)) + 1 '+1 because it's zero based
                GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
                If num$ <> Lastnum$ Then
                    A$ = "LDD": B$ = "#" + num$: C$ = "Element size set with the DIM command": GoSub AO
                    Lastnum$ = num$
                End If
                A$ = "STD": B$ = ",X++": GoSub AO
            Next D1
        End If
    Next ii
End If
A$ = "LDD": B$ = "#DataStart": C$ = "Get the Address where DATA starts": GoSub AO
A$ = "STD": B$ = "DATAPointer": C$ = "Save it in the DATAPointer variable": GoSub AO
A$ = "RTS": C$ = "Return from clearing the variables": GoSub AO

z$ = "SkipClear:": GoSub AO
A$ = "JSR": B$ = "ClearVariables": C$ = "Go clear the all the variables": GoSub AO
A$ = "LDA": B$ = "#$FF": GoSub AO
A$ = "STA": B$ = "CASFLG": C$ = "set the case flag to $FF = Normal uppercase": GoSub AO
A$ = "LDD": B$ = ">$0112": C$ = "Get the Extended BASIC's TIMER value": GoSub AO
A$ = "STD": B$ = "_Var_Timer": C$ = "Use Basic's Timer as a starting point for the TIMER value, just in case someone uses it for Randomness": GoSub AO
A$ = "STD": B$ = "Seed1": C$ = "Save TIMER value as the Random number seed value": GoSub AO

If SDCPLAY = 1 Or SDCVersionCheck = 1 Then ' If we are doing any SDC streaming check the version as it must be V127 or higher
    A$ = "JSR": B$ = "CheckSDCFirmwareVersion": C$ = "Check the version of the SDC controller must be > v126": GoSub AO
End If

' Address    Interrupt    CoCo 2 Vector    CoCo 3 Vector
' $FFF2      SWI3         $100             $FEEE
' $FFF4      SWI2         $103             $FEF1
' $FFF6      FIRQ         $10F             $FEF4    * Make it an RTI ($3B)
' $FEF8      IRQ          $10C             $FEF7    * Go to our BASIC_IRQ
' $FFFA      SWI          $106             $FEFA
' $FFFC      NMI          $109             $FEFD    * Go to our Disk controller IRQ
' $FFFE      RESET        $A027            $8C1B

' Setup IRQ jump address

Print #1, "* Let's detect the CPU type:"
A$ = "LDX": B$ = "#$8000": C$ = "X = $8000": GoSub AO
A$ = "TFR": B$ = "X,A": C$ = "If it's 6809 then A will equal $00, if it's a 6309 then A will now equal $80": GoSub AO

Print #1, "* Let's detect the CoCo version:"
A$ = "LDX": B$ = "$FFFE": C$ = "Get the RESET location": GoSub AO
A$ = "CMPX": B$ = "#$8C1B": C$ = "Check if it's a CoCo 3": GoSub AO
A$ = "BNE": B$ = "SaveCoCo1": C$ = "Setup IRQ, using CoCo 1 IRQ Jump location": GoSub AO
A$ = "ORA": B$ = "#%00000001": C$ = "If it's CoCo 3 then we set bit 0 of the CoCoHardware Desriptor byte": GoSub AO
A$ = "LDX": B$ = "#$FEF7": C$ = "X = Address for the COCO 3 IRQ JMP": GoSub AO
A$ = "LDY": B$ = "#$FEFD": C$ = "Y = Address for the COCO 3 NMI JMP": GoSub AO
A$ = "BRA": B$ = ">": C$ = "Skip ahead": GoSub AO
z$ = "SaveCoCo1": GoSub AO
' reset the coco 1/2 interrupt jumps
A$ = "LDX": B$ = "#$010C": C$ = "X = Address for the COCO 1 IRQ JMP": GoSub AO
A$ = "LDY": B$ = "#$0109": C$ = "Y = Address for the COCO 1 NMI JMP": GoSub AO
z$ = "!"
A$ = "STA": B$ = "CoCoHardware": C$ = "Save the CoCoHardware Desriptor byte": GoSub AO

If PlayCommand = 1 Then
    A$ = "LEAU": B$ = "1,X": C$ = "U=X+1": GoSub AO
    A$ = "STU": B$ = "IRQAddress": C$ = "Save the IRQ address for the PLAY command to change/restore, points at the actual JMP location": GoSub AO
End If

' Save the original IRQ jump address so we can restore it once done
A$ = "LDU": B$ = "#OriginalIRQ": C$ = "U=Address of the IRQ": GoSub AO
A$ = "LDA": B$ = ",X": C$ = "A = Branch Instruction": GoSub AO
A$ = "STA": B$ = ",U": C$ = "Save Branch Instruction": GoSub AO
A$ = "LDD": B$ = "1,X": C$ = "D = Address": GoSub AO
A$ = "STD": B$ = "1,U": C$ = "Backup the Address of the IRQ": GoSub AO

' Set the CPU to the Max speed
A$ = "CLRB": C$ = "B=0, make the CPU max speed as default": GoSub AO
A$ = "JSR": B$ = "SetCPUSpeedB": C$ = "Save max speed and set the CPU to Max speed it can handle": GoSub AO

A$ = "LDB": B$ = "#$7E": C$ = "JMP instruction": GoSub AO
If Disk = 1 Then
    ' Add our NMI
    A$ = "STB": B$ = ",Y": C$ = "A = JMP Instruction": GoSub AO
    A$ = "LDU": B$ = "#DNMISV": C$ = "U=Address of our NMIRQ": GoSub AO
    A$ = "STU": B$ = "1,Y": C$ = "Save the Address of the NMIRQ": GoSub AO
Else
    ' Set NMI as RTI
    A$ = "LDA": B$ = "#$3B": C$ = "RTI instruction": GoSub AO
    A$ = "STA": B$ = ",Y": C$ = "Save RTI Instruction instead of NMI IRQ JMP": GoSub AO
End If

' Setup Sprite blocks
If CoCo3 = 1 And Sprites = 1 Then
    z$ = "* Setup which blocks the sprites are located at in RAM": GoSub AO
    For i = 0 To 31
        If Sprite$(i) <> "" Then
            ' This is a sprite
            Num = SpriteHeight(i): GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            num$ = Right$("00" + num$, 2)
            A$ = "LDA": B$ = "#" + num$: C$ = "Get the sprite height for sprite #" + Str$(i): GoSub AO
            Num = i * 8 + 6: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            A$ = "STA": B$ = "SpriteTable+" + num$: C$ = "Save the height of ths sprite": GoSub AO
        End If
    Next i
End If

' Start the IRQ
If CoCo3 = 1 Then
    ' Use our IRQ address
    A$ = "STB": B$ = ",X": C$ = "A = JMP Instruction": GoSub AO
    A$ = "LDU": B$ = "#BASIC_IRQ": C$ = "U=Address of our IRQ": GoSub AO
    A$ = "STU": B$ = "1,X": C$ = "U=Address of the IRQ": GoSub AO
    If Sprites = 1 Or Samples = 1 Then
        Print #1, T2$; "INCLUDE        ./Basic_Includes/CoCo3_FIRQ_Setup.asm"
    End If
    z$ = "* This is where we enable the FIRQ & IRQ": GoSub AO
    A$ = "ANDCC": B$ = "#%10101111": C$ = "= %10101111 this will Enable the FIRQ & IRQ to start": GoSub AO
Else
    ' Use our IRQ address
    A$ = "STB": B$ = ",X": C$ = "A = JMP Instruction": GoSub AO
    A$ = "LDU": B$ = "#BASIC_IRQ": C$ = "U=Address of our IRQ": GoSub AO
    A$ = "STU": B$ = "1,X": C$ = "U=Address of the IRQ": GoSub AO
    ' Make FIRQ an RTI
    A$ = "LDA": B$ = "#$3B": C$ = "RTI instruction": GoSub AO
    A$ = "STA": B$ = "$010F": C$ = "Save instruction for the FIRQ CoCo1": GoSub AO
    z$ = "* This is where we enable the IRQ": GoSub AO
    A$ = "ANDCC": B$ = "#%11101111": C$ = "= %11101111 this will Enable the IRQ to start": GoSub AO
End If
z$ = "; *** User's Program code starts here ***": GoSub AO

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
i = 1
GetNextToken:
While i <= Len(Expression$)
    i$ = Mid$(Expression$, i, 1)
    ' Check for  Special characters like a comma, semi colon, quote , brackets
    If i$ = Chr$(&H22) Then
        Tokenized$ = Tokenized$ + Chr$(&HF5) + i$ ' Tokenize the first quote
        i = i + 1 'Move past it
        i$ = Mid$(Expression$, i, 1)
        While i$ <> Chr$(&H22) ' keep copying until we get an end quote
            If i$ = Chr$(&H0D) Then Print "Error1: something is wrong getting the charcters in quotes at";: GoTo FoundError
            Tokenized$ = Tokenized$ + i$ ' Copy the data inside the quotes
            i = i + 1
            i$ = Mid$(Expression$, i, 1)
        Wend
        Tokenized$ = Tokenized$ + Chr$(&HF5) + i$ ' make the end quote also tokenized
        i = i + 1
        GoTo GetNextToken ' go handle stuff in quotes
    End If
    ' Check for a General command
    For c = 1 To GeneralCommandsCount
        Temp$ = UCase$(GeneralCommands$(c))
        BaseString$ = UCase$(Right$(Expression$, Len(Expression$) - i + 1))
        If Temp$ = "TIMER" Then Temp$ = "Ignore" ' Don't change TIMER commands to commands here, as they need to be left as variable names, they get fixed as TIMER= afterwards
        If InStr(BaseString$, Temp$) = 1 Then
            'Found a General Command
            If i > 1 Then
                ' Check for a space before the start of this command
                If Mid$(Expression$, i - 1, 1) = " " Or Mid$(Expression$, i - 1, 1) = ":" Then LeftSpace = 1 Else LeftSpace = 0
            Else
                LeftSpace = 1
            End If
            ' It could be a General command, check for a space after the found command
            If i + Len(Temp$) <= Len(Expression$) Then
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
                    p = i + 6
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
                If Temp$ = "WIDTH" Then
                    ' Find out which Width mode the user wants in their program
                    V$ = ""
                    p = i + 6
                    GettingWidth:
                    If p <= Len(Expression$) Then
                        If Asc(Mid$(Expression$, p, 1)) >= Asc("0") And Asc(Mid$(Expression$, p, 1)) <= Asc("9") Then
                            V$ = V$ + Mid$(Expression$, p, 1)
                            p = p + 1
                        Else
                            GoTo GotWidth
                        End If
                        GoTo GettingWidth
                    End If
                    GotWidth:
                    If V$ <> "32" And V$ <> "40" And V$ <> "64" And V$ <> "80" Then
                        Print "Width size must be 32,40,64 or 80 on";: GoTo FoundError
                    End If
                    WidthVal$ = V$
                End If
                GoSub AddToGeneralCommandList ' Add General Command Temp$ to the general command list
                Num = c: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                Tokenized$ = Tokenized$ + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB) 'Token &HFF is for General Commands
                ' Check for a REM or '
                If c = C_REM Or c = C_REMApostrophe Then
                    'We found a REM or ' - copy the rest of this line
                    i = i + Len(Temp$) ' move pointer forward
                    While i <= Len(Expression$)
                        i$ = Mid$(Expression$, i, 1)
                        Tokenized$ = Tokenized$ + i$
                        i = i + 1
                    Wend
                    GoTo TokenAdded0
                End If
                ' Find the DATA Token
                Check$ = "DATA": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
                ' Check for a DATA
                If c = ii Then
                    'We found a DATA command - copy the rest of this line
                    i = i + Len(Temp$) ' move pointer forward past "DATA" command
                    While i <= Len(Expression$) And i$ <> Chr$(&HF5)
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        If i$ = Chr$(&H22) Then
                            Tokenized$ = Tokenized$ + Chr$(&HF5) + i$ ' Tokenize the first quote
                            i$ = Mid$(Expression$, i, 1): i = i + 1
                            While i$ <> Chr$(&H22) ' keep copying until we get an end quote
                                Tokenized$ = Tokenized$ + i$ ' Copy the data inside the quotes
                                i$ = Mid$(Expression$, i, 1): i = i + 1
                            Wend
                            Tokenized$ = Tokenized$ + Chr$(&HF5) + i$ ' make the end quote also tokenized
                        Else
                            Tokenized$ = Tokenized$ + i$
                        End If
                    Wend
                    If i$ = Chr$(&HF5) Then
                        'Found a control Token, copy the next byte
                        i$ = Mid$(Expression$, i, 1)
                        Tokenized$ = Tokenized$ + i$
                        i = i + 1
                    End If
                    GoTo TokenAdded0
                End If
                ' Find the DEF Token
                Check$ = "DEF": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
                ' Check for a DEF
                If c = ii Then
                    'We found a DEF command, we need to handle the FNx()=...  part
                    i = i + Len(Temp$) + 3 ' move pointer forward so it now points at the FN label
                    Temp$ = ""
                    ' Get the FN variable name in Temp$
                    While i <= Len(Expression$)
                        i$ = Mid$(Expression$, i, 1)
                        If i$ = "(" Then Exit While
                        Temp$ = Temp$ + i$
                        i = i + 1
                    Wend
                    DefLabel$(DefLabelCount) = Temp$
                    Num = DefLabelCount: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
                    Tokenized$ = Tokenized$ + Chr$(&HFB) + Chr$(MSB) + Chr$(LSB) ' Flag this as an FN #, and the value of this FN label
                    DefLabelCount = DefLabelCount + 1
                    GoTo TokenAdded0
                End If
                i = i + Len(Temp$) ' move pointer forward
                GoTo TokenAdded0
            End If
        End If
    Next c
    ' Check for a Numeric command
    For c = 1 To NumericCommandsCount
        Temp$ = UCase$(NumericCommands$(c))
        BaseString$ = UCase$(Right$(Expression$, Len(Expression$) - i + 1))
        If InStr(BaseString$, Temp$) = 1 Then
            'Found a Numeric Command
            If i > 1 Then
                ' Check for stuff before the start of this command
                If Mid$(Expression$, I - 1, 1) = " " Or Mid$(Expression$, I - 1, 1) = "(" Or Mid$(Expression$, I - 1, 1) = "=" _
                   Or Mid$(Expression$, I - 1, 1) = "+" _
                   Or Mid$(Expression$, I - 1, 1) = "-" _
                   Or Mid$(Expression$, I - 1, 1) = "*" _
                   Or Mid$(Expression$, I - 1, 1) = "/" _
                   Or Mid$(Expression$, I - 1, 1) = "\" _
                   Or Mid$(Expression$, I - 1, 1) = "^" _
                   Or Mid$(Expression$, I - 1, 1) = "<" _
                   Or Mid$(Expression$, I - 1, 1) = ">" _
              Then LeftSpace = 1 Else LeftSpace = 0
            Else
                LeftSpace = 1
            End If
            ' It could be a General command, check for a space after the found command
            If i + Len(Temp$) <= Len(Expression$) Then
                ' check if we have a space or ( after the found command
                If Mid$(Expression$, i + Len(Temp$), 1) = " " Or Mid$(Expression$, i + Len(Temp$), 1) = "(" Then RightSpace = 1 Else RightSpace = 0
            Else
                RightSpace = 1
            End If
            ' Check for a FN
            If Temp$ = "FN" And LeftSpace = 1 Then
                'We found an FN command, ignore the variablename before the (
                Temp$ = ""
                i = i + 2 ' skip past FN
                While i <= Len(Expression$)
                    i$ = Mid$(Expression$, i, 1)
                    If i$ = "(" Then Exit While
                    Temp$ = Temp$ + i$
                    i = i + 1
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
                i = i + Len(Temp$) ' move pointer forward
                GoTo TokenAdded0
            End If
        End If
    Next c
    ' Check for a String command
    For c = 1 To StringCommandsCount
        Temp$ = UCase$(StringCommands$(c))
        BaseString$ = UCase$(Right$(Expression$, Len(Expression$) - i + 1))
        If InStr(BaseString$, Temp$) = 1 Then
            'Found a String Command
            GoSub AddToStringCommandList
            Num = c: GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSB
            Tokenized$ = Tokenized$ + Chr$(&HFD) + Chr$(MSB) + Chr$(LSB) 'Token $FD is for String Commands
            i = i + Len(Temp$) ' move pointer forward
            GoTo TokenAdded0
        End If
    Next c
    ' Check for an Operator command
    For c = 1 To OperatorCommandsCount
        Temp$ = UCase$(OperatorCommands$(c))
        BaseString$ = UCase$(Right$(Expression$, Len(Expression$) - i + 1))
        If InStr(BaseString$, Temp$) = 1 Then
            'Found an Operator Command
            If c > &H29 Then
                Tokenized$ = Tokenized$ + Chr$(&HFC) + Chr$(c) 'Token &HFC is for Operator Commands
                i = i + Len(Temp$) ' move pointer forward
                GoTo TokenAdded0
            Else
                If i > 1 Then
                    ' Check for a stuff before the start of this command
                    If Mid$(Expression$, i - 1, 1) = " " Then LeftSpace = 1 Else LeftSpace = 0
                Else
                    LeftSpace = 1
                End If
                ' It could be a General command, check for a space after the found command
                If i + Len(Temp$) < Len(Expression$) Then
                    ' check if we have a space after the found command
                    If Mid$(Expression$, i + Len(Temp$), 1) = " " Then RightSpace = 1 Else RightSpace = 0
                Else
                    RightSpace = 1
                End If
                If LeftSpace = 1 And RightSpace = 1 Then
                    Tokenized$ = Tokenized$ + Chr$(&HFC) + Chr$(c) 'Token &HFC is for Operator Commands
                    i = i + Len(Temp$) ' move pointer forward
                    GoTo TokenAdded0
                End If
            End If
        End If
    Next c
    AddTokenAsIs0:
    Tokenized$ = Tokenized$ + i$
    i = i + 1
    TokenAdded0:
    If Temp$ = "DRAW" Then ' Found a Draw command, change any X inside a quote to ":DRAW (whatever before the next semi colon" : DRAW" the rest
        Temp$ = Right$(Expression$, Len(Expression$) - i)
        Expression$ = Left$(Expression$, i)
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
        Temp$ = Right$(Expression$, Len(Expression$) - i)
        Expression$ = Left$(Expression$, i)
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
    For i = 1 To Len(Tokenized$)
        a = Asc(Mid$(Tokenized$, i, 1))
        If a < 16 Then Print "0";
        Print Hex$(Asc(Mid$(Tokenized$, i, 1)));
    Next i
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

' ATTR may or may not have ,B or ,U at the end which might get turned into variable below
' Change the Tokenized$ command so it will have
' ,0,0 - No Blink or Underline
' ,1,0 - Blink
' ,0,1 - Underline
' ,1,1 - Blink & Underline
Check$ = "ATTR": GoSub FindGenCommandNumber ' Gets the General Command number of Check$, returns with number in ii, Found=1 if found and Found=0 if not found
GoSub FixAttrCommand ' Find the ATTR Token and fix the formatting if found

' GET command, we must have an array pointer after the last last close bracket and comma
TempCOM$ = ""
i = 1
' Find the GET Token
Num = C_GET
GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
While InStr(i, Tokenized$, Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) > 0 ' See if we still have any GET commands to deal with
    Start = i
    ' This line of code has the GET command in it
    i = InStr(i, Tokenized$, Chr$(&H29) + Chr$(&H20) + Chr$(&H2C) + Chr$(&H20)) ' Find the ") , "
    If i = 0 Then Print "Error: GET command doesn't have Close bracket and comma on";: GoTo FoundError 'Can't find the ),
    i = i + 4 ' Move past the ), - Now point at the array name
    ArrayStart = i
    Temp$ = ""
    While i <= Len(Tokenized$)
        i$ = Mid$(Tokenized$, i, 1): i = i + 1
        If i$ = Chr$(&H20) Or i$ = Chr$(&HF5) Then i = i - 1: Exit While
        Temp$ = Temp$ + i$
    Wend
    If i$ = Chr$(&H20) Then
        ' Check for a , G after the array
        ANameEnd = InStr(i, Tokenized$, ", G") ' Find the ", G"
        If ANameEnd > 0 Then
            i = ANameEnd + 3
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
    Tokenized$ = TempCOM$ + Right$(Tokenized$, Len(Tokenized$) - i + 1)
End If

' PUT command, we must have an array pointer after the last last close bracket and comma
TempCOM$ = ""
i = 1
' Find the PUT Token
Num = C_PUT
GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
While InStr(i, Tokenized$, Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) > 0 ' See if we still have any PUT commands to deal with
    Start = i
    ' This line of code has the PUT command in it
    i = InStr(i, Tokenized$, Chr$(&H29) + Chr$(&H20) + Chr$(&H2C) + Chr$(&H20)) ' Find the ") , "
    If i = 0 Then Print "Error: PUT command doesn't have Close bracket and comma on";: GoTo FoundError 'Can't find the ),
    i = i + 4 ' Move past the ), - Now point at the array name
    ArrayStart = i
    Temp$ = ""
    While i <= Len(Tokenized$)
        i$ = Mid$(Tokenized$, i, 1): i = i + 1
        If i$ = Chr$(&H20) Or i$ = Chr$(&HF5) Then i = i - 1: Exit While
        Temp$ = Temp$ + i$
    Wend
    PUTPSET = 1 ' Default to ,PSET
    If i$ = Chr$(&H20) Then
        Num = C_PSET
        ' Extract the high byte (higher 8 bits)
        MSByte = Num \ 256 ' Integer division by 256
        ' Extract the low byte (lower 8 bits)
        LSByte = Num And 255 ' Equivalent to num MOD 256
        ANameEnd = InStr(i, Tokenized$, Chr$(&H2C) + Chr$(&H20) + Chr$(&HFF) + Chr$(MSByte) + Chr$(LSByte)) ' Find the " , PSET"
        If ANameEnd > 0 Then
            PUTPSET = 1
            PutType = 0
            i = ANameEnd + 5
        Else
            Num = C_PRESET
            ' Extract the high byte (higher 8 bits)
            MSByte = Num \ 256 ' Integer division by 256
            ' Extract the low byte (lower 8 bits)
            LSByte = Num And 255 ' Equivalent to num MOD 256
            ANameEnd = InStr(i, Tokenized$, Chr$(&H2C) + Chr$(&H20) + Chr$(&HFF) + Chr$(MSByte) + Chr$(LSByte)) ' Find the " , PRESET"
            If ANameEnd > 0 Then
                PUTPRESET = 1
                PutType = 1
                i = ANameEnd + 5
            Else
                ANameEnd = InStr(i, Tokenized$, Chr$(&H2C) + Chr$(&H20) + Chr$(&HFC) + Chr$(&H10)) ' Find the " , AND"
                If ANameEnd > 0 Then
                    PUTAND = 1
                    PutType = 2
                    i = ANameEnd + 4
                Else
                    ANameEnd = InStr(i, Tokenized$, Chr$(&H2C) + Chr$(&H20) + Chr$(&HFC) + Chr$(&H11)) ' Find the " , OR"
                    If ANameEnd > 0 Then
                        PUTOR = 1
                        PutType = 3
                        i = ANameEnd + 4
                    Else
                        ANameEnd = InStr(i, Tokenized$, Chr$(&H2C) + Chr$(&H20) + Chr$(&HFC) + Chr$(&H14)) ' Find the " , NOT"
                        If ANameEnd > 0 Then
                            PUTNOT = 1
                            PutType = 4
                            i = ANameEnd + 4
                        Else
                            ANameEnd = InStr(i, Tokenized$, Chr$(&H2C) + Chr$(&H20) + Chr$(&HFC) + Chr$(&H13)) ' Find the " , XOR"
                            If ANameEnd > 0 Then
                                PUTXOR = 1
                                PutType = 5
                                i = ANameEnd + 4
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
    Tokenized$ = TempCOM$ + Right$(Tokenized$, Len(Tokenized$) - i + 1)
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
i = 1
GetNextToken1:
While i <= Len(Expression$)
    i$ = Mid$(Expression$, i, 1): i = i + 1
    If Asc(i$) > &HEF Then
        ' We hit a token, copy it
        Tokenized$ = Tokenized$ + i$
        Select Case Asc(i$)
            Case &HF5:
                'We have a special character tokenized already
                i$ = Mid$(Expression$, i, 1): i = i + 1 ' Get the Special character
                Tokenized$ = Tokenized$ + i$ ' Copy it
                If i$ = Chr$(&H22) Then
                    ' Found a quote, so copy all until we get the end tokenized quote
                    i$ = Mid$(Expression$, i, 1): i = i + 1 ' Get a byte
                    While i$ <> Chr$(&H22) ' keep copying until we find the end quote
                        Tokenized$ = Tokenized$ + i$ ' Copy the byte
                        i$ = Mid$(Expression$, i, 1): i = i + 1 ' Get a byte
                    Wend
                    Tokenized$ = Tokenized$ + i$ ' Copy the end quote
                End If
                GoTo GetNextToken1
            Case &HFB:
                ' DEF FN Function?
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                GoTo GetNextToken1
            Case &HFC:
                ' Operator?
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                GoTo GetNextToken1
            Case &HFD:
                ' String Command?
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                GoTo GetNextToken1
            Case &HFE:
                ' Numeric Command?
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                'skip forward until after the open and close brackets
                GoTo GetNextToken1
            Case &HFF:
                ' General Command?
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                v = Asc(i$) * 256
                i$ = Mid$(Expression$, i, 1): i = i + 1: Tokenized$ = Tokenized$ + i$
                v = v + Asc(i$)
                If v = C_REM Then
                    ' Found a REM, copy the rest of the expression as is, no more tokenizing needed
                    While i <= Len(Expression$)
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        Tokenized$ = Tokenized$ + i$
                    Wend
                    GoTo GetNextToken1
                End If
                If v = C_REMApostrophe Then
                    ' Found an apostrophe ' copy the rest of the expression as is, no more tokenizing needed
                    While i <= Len(Expression$)
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        Tokenized$ = Tokenized$ + i$
                    Wend
                    GoTo GetNextToken1
                End If
                ' Check for a DATA
                If v = C_DATA Then
                    'We found a DATA command - copy the rest of this line upto a colon or the end
                    While i <= Len(Expression$)
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&HF5) Then
                            i$ = Mid$(Expression$, i, 1): i = i + 1
                            Tokenized$ = Tokenized$ + i$
                            If i$ = Chr$(&H3A) Then Exit While
                        End If
                    Wend
                End If
                If v = C_PUT Or v = C_GET Then ' Check for a PUT or GET command
                    'We found a PUT or GET command - copy the rest of this line upto a colon or the end
                    While i <= Len(Expression$)
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&HF5) Then
                            i$ = Mid$(Expression$, i, 1): i = i + 1
                            Tokenized$ = Tokenized$ + i$
                            If i$ = Chr$(&H3A) Then Exit While
                        End If
                    Wend
                End If
                GoTo GetNextToken1
        End Select
    End If
    CheckStart = i - 1 ' This is as far back as we can go looking for an array label
    ' Find an open bracket, which could be part of an array variable
    For ii = CheckStart + 1 To Len(Expression$)
        If Mid$(Expression$, ii, 1) = "=" Then Exit For ' This is not an array
        If Mid$(Expression$, ii, 1) = "(" Then
            ' Found an open bracket
            ' Might be the start of an array variable
            ' Test for $ or a letter before the "("
            Check$ = UCase$(Mid$(Expression$, ii - 1, 1))
            If Check$ = "$" Then
                ' It's a string array
                ' We found a string array to tokenize
                Start = ii - 2 ' start points at the character before the "$("
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
                LabelEnd = ii - 2
                If LabelStart <> CheckStart Then GoTo CopyOtherBytes 'We missed some bytes before this array, go deal with them first

                Temp$ = Mid$(Expression$, LabelStart, LabelEnd - LabelStart + 1) ' Temp$=the actual label
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
                i = Start ' Update i's position
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
                    i = Start ' Update i's position
                    GoTo GetNextToken1
                Else
                    ' Not an array break out of the FOR Next loop
                    GoTo CopyOtherBytes
                End If
            End If
        End If
    Next ii
    CopyOtherBytes:
    If i$ = "&" And i < Len(Expression$) Then
        Select Case Mid$(Expression$, i, 1)
            Case "H"
                ' Found an "&H"
                Temp$ = ""
                i = i + 1 ' skip the H
                While i <= Len(Expression$)
                    i$ = UCase$(Mid$(Expression$, i, 1)): i = i + 1
                    If (Asc(i$) >= Asc("A") And Asc(i$) <= Asc("F")) Or (Asc(i$) >= Asc("0") And Asc(i$) <= Asc("9")) Then
                        Temp$ = Temp$ + i$
                    Else
                        i = i - 1
                        Exit While
                    End If
                Wend
                Tokenized$ = Tokenized$ + Str$(Val("&H" + Temp$))
                GoTo GetNextToken1
            Case "O"
                ' Found an "&O"
                Temp$ = ""
                i = i + 1 ' skip the H
                While i <= Len(Expression$)
                    i$ = UCase$(Mid$(Expression$, i, 1)): i = i + 1
                    If Asc(i$) >= Asc("0") And Asc(i$) <= Asc("9") Then
                        Temp$ = Temp$ + i$
                    Else
                        i = i - 1
                        Exit While
                    End If
                Wend
                Tokenized$ = Tokenized$ + Str$(Val("&O" + Temp$))
                GoTo GetNextToken1
            Case "B"
                ' Found an "&B"
                Temp$ = ""
                i = i + 1 ' skip the H
                While i <= Len(Expression$)
                    i$ = UCase$(Mid$(Expression$, i, 1)): i = i + 1
                    If Asc(i$) = Asc("0") Or Asc(i$) = Asc("1") Then
                        Temp$ = Temp$ + i$
                    Else
                        i = i - 1
                        Exit While
                    End If
                Wend
                Tokenized$ = Tokenized$ + Str$(Val("&B" + Temp$))
                GoTo GetNextToken1
            Case Else
                Tokenized$ = Tokenized$ + i$ ' output the "&"
                i$ = Mid$(Expression$, i, 1): i = i + 1
        End Select

        ' Last CopyOtherBytes was:
        '        CopyOtherBytes:
        '        If i$ = "&" And i < Len(Expression$) Then
        '            ' Might be hex value "&H"
        '            Tokenized$ = Tokenized$ + i$ ' output the "&"
        '            i$ = Mid$(Expression$, i, 1): i = i + 1
        '            If i$ = "H" Then
        '                ' We found "&H"
        '                Tokenized$ = Tokenized$ + i$ ' copy the H to the output
        '                ' Get the first hex value
        '                While i <= Len(Expression$)
        '                    i$ = UCase$(Mid$(Expression$, i, 1)): i = i + 1
        '                    If (Asc(i$) >= Asc("A") And Asc(i$) <= Asc("F")) Or (Asc(i$) >= Asc("0") And Asc(i$) <= Asc("9")) Then
        '                        Tokenized$ = Tokenized$ + i$
        '                    Else
        '                        i = i - 1
        '                        Exit While
        '                    End If
        '                Wend
        '                GoTo GetNextToken1
        '            End If
        '        End If

    End If
    Tokenized$ = Tokenized$ + i$
Wend
If Verbose > 1 Then
    Print "2nd:"
    For i = 1 To Len(Tokenized$)
        a = Asc(Mid$(Tokenized$, i, 1))
        If a < 16 Then Print "0";
        Print Hex$(Asc(Mid$(Tokenized$, i, 1)));
    Next i
    Print
End If

' Tokenize Special Characters
Expression$ = Tokenized$
Tokenized$ = ""
i = 1
GetNextToken2:
While i <= Len(Expression$)
    v = Asc(Mid$(Expression$, i, 1)): i = i + 1
    If v < &HF0 Then
        If v = &H23 Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(v): GoTo GetNextToken2 ' Found #
        If v = &H28 Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(v): GoTo GetNextToken2 ' Found open bracket
        If v = &H29 Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(v): GoTo GetNextToken2 ' Found close bracket
        If v = &H2C Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(v): GoTo GetNextToken2 ' Found comma
        If v = &H3B Then Tokenized$ = Tokenized$ + Chr$(&HF5) + Chr$(v): GoTo GetNextToken2 ' Found semi colon
        Tokenized$ = Tokenized$ + Chr$(v)
        GoTo GetNextToken2 ' copy other values
    End If
    'We have a Token
    Tokenized$ = Tokenized$ + Chr$(v) 'copy the token
    Select Case v
        Case &HF0, &HF1: ' Found a Numeric or String array
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of Array ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of Array ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy # of dimensions
        Case &HF2, &HF3, &HF4: ' Found a numeric or string or floating point variable
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of variable ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of variable ID
        Case &HF5 ' Found a special character
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy Special character
            'We have a special character tokenized already
            If v = &H22 Then
                ' Found a quote, so copy all until we get the end tokenized quote
                i$ = Mid$(Expression$, i, 1) ' Get a byte
                While i$ <> Chr$(&H22) ' keep skipping until we find the end quote
                    Tokenized$ = Tokenized$ + i$ ' Copy the byte
                    i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get a byte
                Wend
            End If
        Case &HFB: ' Found a DEF FN Function
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of FN ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of FN ID
        Case &HFC: ' Found an Operator
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy Operator
        Case &HFD, &HFE: 'Found String,Numeric command
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of command ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of command ID
        Case &HFF: 'Found General command
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of command ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of command ID
            ' Check for a DATA command
            v = Asc(Mid$(Expression$, i - 2, 1)) * 256 + Asc(Mid$(Expression$, i - 1, 1))
            If v = C_DATA Then
                'We found a line with the DATA command, copy it all as it is, don't add extra control characters
                While i <= Len(Expression$)
                    i$ = Mid$(Expression$, i, 1): i = i + 1
                    Tokenized$ = Tokenized$ + i$
                    If i$ = Chr$(&HF5) Then
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&H3A) Then Exit While
                    End If
                Wend
                GoTo GetNextToken2
            End If
            If v = C_REM Or v = C_REMApostrophe Then
                'We found a line with the REM command, copy it all as it is, don't add extra control characters
                While i <= Len(Expression$)
                    i$ = Mid$(Expression$, i, 1): i = i + 1
                    Tokenized$ = Tokenized$ + i$
                    If i$ = Chr$(&HF5) Then
                        i$ = Mid$(Expression$, i, 1): i = i + 1
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
i = 1
GetNextToken3:
While i <= Len(Expression$)
    i$ = Mid$(Expression$, i, 1)
    If Asc(i$) > &HEF Then ' Test if we hit a token
        If i$ = Chr$(&HF5) Then
            Tokenized$ = Tokenized$ + i$ ' copy the &HF5
            'We have a special character tokenized already
            i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get the Special character
            Tokenized$ = Tokenized$ + i$ ' Copy it
            If i$ = Chr$(&H22) Then
                ' Found a quote, so copy all until we get the end tokenized quote
                i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get a byte
                While Mid$(Expression$, i, 1) <> Chr$(&H22) ' keep skipping until we find the end quote
                    Tokenized$ = Tokenized$ + i$ ' Copy the byte
                    i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get a byte
                Wend
                GoTo GetNextToken3
            End If
            i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get a byte
            GoTo GetNextToken3
        End If
        ' This needs to account for 16 bit numbers now
        If Asc(i$) = &HF0 Or Asc(i$) = &HF1 Then
            ' Copy the token plus 3 more values (array , # of dimensions)
            Tokenized$ = Tokenized$ + i$ ' copy the token
            i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get the array MSB
            Tokenized$ = Tokenized$ + i$ ' Copy
            i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get the array LSB
            Tokenized$ = Tokenized$ + i$ ' Copy
            i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get the # of dimensions in the array
            Tokenized$ = Tokenized$ + i$ ' Copy
            i = i + 1
            GoTo GetNextToken3
        Else
            ' Check for a REM or '
            Check$ = "REM": GoSub FindGenCommandInExpression 'Checks if position i in Expression$ has the command Check$, return Found=1 is found else Found=0
            If Found = 1 Then
                While i <= Len(Expression$)
                    i$ = Mid$(Expression$, i, 1)
                    Tokenized$ = Tokenized$ + i$
                    i = i + 1
                Wend
                GoTo GetNextToken3
            End If
            ' Check for a an apostrophe '
            Check$ = "'": GoSub FindGenCommandInExpression 'Checks if position i in Expression$ has the command Check$, return Found=1 is found else Found=0
            If Found = 1 Then
                While i <= Len(Expression$)
                    i$ = Mid$(Expression$, i, 1)
                    Tokenized$ = Tokenized$ + i$
                    i = i + 1
                Wend
                GoTo GetNextToken3
            End If
            ' Check for a DATA
            Check$ = "DATA": GoSub FindGenCommandInExpression 'Checks if position i in Expression$ has the command Check$, return Found=1 is found else Found=0
            If Found = 1 Then
                'We found a DATA command - copy the rest of this line
                While i <= Len(Expression$)
                    i$ = Mid$(Expression$, i, 1): i = i + 1
                    Tokenized$ = Tokenized$ + i$
                    If i$ = Chr$(&HF5) Then
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&H3A) Then Exit While
                    End If
                Wend
                GoTo GetNextToken3
            End If
            If Asc(i$) = &HFC Then
                ' Hit an operator, copy only one value after
                Tokenized$ = Tokenized$ + i$ ' copy the token
                i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get the operator
                Tokenized$ = Tokenized$ + i$ ' Copy
                i = i + 1
                GoTo GetNextToken3
            Else
                ' We hit a token, copy it
                Tokenized$ = Tokenized$ + i$ ' copy the token
                i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get the array MSB
                Tokenized$ = Tokenized$ + i$ ' Copy
                i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get the array LSB
                Tokenized$ = Tokenized$ + i$ ' Copy
                i = i + 1
                GoTo GetNextToken3
            End If
        End If
    Else
        If i$ = "&" And i < Len(Expression$) Then
            i = i + 1 ' Point at the next character
            Select Case Mid$(Expression$, i, 1)
                Case "H"
                    ' Found an "&H"
                    i = i + 1 ' skip the H
                    Temp$ = ""
                    While i <= Len(Expression$)
                        i$ = UCase$(Mid$(Expression$, i, 1)): i = i + 1
                        If (Asc(i$) >= Asc("A") And Asc(i$) <= Asc("F")) Or (Asc(i$) >= Asc("0") And Asc(i$) <= Asc("9")) Then
                            Temp$ = Temp$ + i$
                        Else
                            i = i - 1
                            Exit While
                        End If
                    Wend
                    Tokenized$ = Tokenized$ + Str$(Val("&H" + Temp$))
                Case "O"
                    ' Found an "&H"
                    i = i + 1 ' skip the O
                    Temp$ = ""
                    While i <= Len(Expression$)
                        i$ = UCase$(Mid$(Expression$, i, 1)): i = i + 1
                        If Asc(i$) >= Asc("0") And Asc(i$) <= Asc("7") Then
                            Temp$ = Temp$ + i$
                        Else
                            i = i - 1
                            Exit While
                        End If
                    Wend
                    Tokenized$ = Tokenized$ + Str$(Val("&O" + Temp$))
                Case "B"
                    ' Found an "&B"
                    i = i + 1 ' skip the B
                    Temp$ = ""
                    While i <= Len(Expression$)
                        i$ = UCase$(Mid$(Expression$, i, 1)): i = i + 1
                        If Asc(i$) = Asc("0") Or Asc(i$) = Asc("1") Then
                            Temp$ = Temp$ + i$
                        Else
                            i = i - 1
                            Exit While
                        End If
                    Wend
                    Tokenized$ = Tokenized$ + Str$(Val("&B" + Temp$))
                Case Else
                    Tokenized$ = Tokenized$ + i$ ' output the "&"
                    i$ = Mid$(Expression$, i, 1)
            End Select
        Else

            ' original &H handling:
            '            If i$ = "&" And i < Len(Expression$) Then
            '                ' Might be hex value "&H"
            '                Tokenized$ = Tokenized$ + i$ ' output the "&"
            '                i = i + 1 ' move past the "&"
            '                i$ = Mid$(Expression$, i, 1)
            '                If i$ = "H" Then
            '                    ' We found "&H"
            '                    Tokenized$ = Tokenized$ + i$ ' copy the H to the output
            '                    i = i + 1
            '                    ' Get the first hex value
            '                    i$ = UCase$(Mid$(Expression$, i, 1)): i = i + 1
            '                    While i <= Len(Expression$)
            '                        If (Asc(i$) >= Asc("A") And Asc(i$) <= Asc("F")) Or (Asc(i$) >= Asc("0") And Asc(i$) <= Asc("9")) Then
            '                            Tokenized$ = Tokenized$ + i$
            '                            i$ = UCase$(Mid$(Expression$, i, 1)): i = i + 1
            '                        Else
            '                            Exit While
            '                        End If
            '                    Wend
            '                    i = i - 1
            '                End If
            '            Else


            ' Check for a variable
            If Asc(UCase$(i$)) >= Asc("A") And Asc(UCase$(i$)) <= Asc("Z") Then ' Is it a letter?
                ' It is part of a variable name, we don't know if it's numeric or string at the moment
                ' Get the variable name
                Start = i ' start points at the 2nd character of the variable
                While Start <= Len(Expression$)
                    If Mid$(Expression$, Start, 1) = " " Or Mid$(Expression$, Start, 1) = Chr$(&HF5) Or Mid$(Expression$, Start, 1) = Chr$(&HFC) _
                    Or Mid$(Expression$, Start, 1) = "$" or Mid$(Expression$, Start, 1) = "=" Then Exit While
                    Start = Start + 1
                Wend
                If Mid$(Expression$, Start, 1) = "$" Then Start = Start + 1
                Temp$ = Mid$(Expression$, i, Start - i)
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
                    i = i + Len(Temp$) ' move pointer forward
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
                                GoSub CheckVarForSpecial ' If variable Temp$ ends with special tokens which temp change their Type, we must ignore them
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
                            GoSub CheckVarForSpecial ' If variable Temp$ ends with special tokens which temp change their Type, we must ignore them
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
                    i = i + Len(Temp$) ' move pointer forward
                    GoTo GetNextToken3
                End If
            End If
        End If
    End If
    Tokenized$ = Tokenized$ + i$
    i = i + 1
Wend
' Remove all spaces that aren't in a quote or DATA statement
Expression$ = Tokenized$
Tokenized$ = ""
i = 1

LoopFindSpaces:
While i <= Len(Expression$)
    v = Asc(Mid$(Expression$, i, 1)): i = i + 1
    If v < &HF0 Then
        If v <> &H20 Then Tokenized$ = Tokenized$ + Chr$(v) ' If not a space then copy it
        GoTo LoopFindSpaces
    End If
    'We have a Token
    Tokenized$ = Tokenized$ + Chr$(v) 'copy the token
    Select Case v
        Case &HF0, &HF1: ' Found a Numeric or String array
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of Array ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of Array ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy # of dimensions
        Case &HF2, &HF3, &HF4: ' Found a numeric or string or floating point variable
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of variable ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of variable ID
        Case &HF5 ' Found a special character
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy Special character
            'We have a special character tokenized already
            If v = &H22 Then
                ' Found a quote, so copy all until we get the end tokenized quote
                i$ = Mid$(Expression$, i, 1) ' Get a byte
                While i$ <> Chr$(&H22) ' keep skipping until we find the end quote
                    Tokenized$ = Tokenized$ + i$ ' Copy the byte
                    i = i + 1: i$ = Mid$(Expression$, i, 1) ' Get a byte
                Wend
            End If
        Case &HFB: ' Found a DEF FN Function
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of FN ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of FN ID
        Case &HFC: ' Found an Operator
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy Operator
        Case &HFD, &HFE: 'Found String,Numeric command
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of command ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of command ID
        Case &HFF: 'Found General command
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy MSB of command ID
            v = Asc(Mid$(Expression$, i, 1)): Tokenized$ = Tokenized$ + Chr$(v): i = i + 1 ' Copy LSB of command ID
            v = Asc(Mid$(Expression$, i - 2, 1)) * 256 + Asc(Mid$(Expression$, i - 1, 1))
            ' Check for a REM or '
            If v = C_REM Or v = C_REMApostrophe Then
                'We found a line with the REM command, copy it all as it is, don't add extra control characters
                While i <= Len(Expression$)
                    i$ = Mid$(Expression$, i, 1): i = i + 1
                    Tokenized$ = Tokenized$ + i$
                    If i$ = Chr$(&HF5) Then
                        i$ = Mid$(Expression$, i, 1): i = i + 1
                        Tokenized$ = Tokenized$ + i$
                        If i$ = Chr$(&H3A) Then Exit While
                    End If
                Wend
                GoTo LoopFindSpaces
            End If
            ' Check for a DATA command
            If v = C_DATA Then
                'We found a line with the DATA command
                MoreDataToCheck:
                If i > Len(Expression$) Then GoTo LoopFindSpaces ' we have reached the end of the expression
                v = Asc(Mid$(Expression$, i, 1)): i = i + 1 'Get the first byte after the command DATA or after a comma
                If v = Asc(" ") Then
                    If i <= Len(Expression$) Then
                        GoTo MoreDataToCheck ' skip extra spaces after a comma or after the command DATA
                    Else
                        GoTo LoopFindSpaces ' we have reached the end of the expression
                    End If
                End If
                If v = &H2C Then
                    'Found a comma, leave it as it is
                    Tokenized$ = Tokenized$ + Chr$(v) ' copy the comma
                    GoTo MoreDataToCheck ' check next value
                End If
                If (v >= Asc("0") And v <= Asc("9")) Then
                    'We have a number to copy, so we can erase any spaces we find until a comma or end of Expression$
                    Do Until v = &H2C Or i > Len(Expression$)
                        If v = &HF5 Then
                            If Asc(Mid$(Expression$, i, 1)) = &H3A Then
                                Exit Do
                            End If
                        End If
                        If v <> Asc(" ") Then Tokenized$ = Tokenized$ + Chr$(v)
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                    Loop
                    Tokenized$ = Tokenized$ + Chr$(v)
                    If v = &HF5 Then
                        ' We found a colon on this line
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                        Tokenized$ = Tokenized$ + Chr$(v) ' Copy the colon
                        GoTo LoopFindSpaces ' look for more commands after the colon
                    End If
                    If i > Len(Expression$) Then GoTo LoopFindSpaces ' we are at the end
                    GoTo MoreDataToCheck ' Handle more data
                End If
                If v = Asc("&") And Mid$(Expression$, i, 1) = "H" Then
                    'it's a hex number get it all and convert it to a number
                    Temp$ = ""
                    i = i + 1 ' skip past the "H"
                    v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                    Do Until v = &H2C Or i > Len(Expression$)
                        If v = &HF5 Then
                            If Asc(Mid$(Expression$, i, 1)) = &H3A Then
                                Exit Do
                            End If
                        End If
                        Temp$ = Temp$ + Chr$(v)
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                    Loop
                    If v = &HF5 Then
                        ' We found a colon on this line
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                        Tokenized$ = Tokenized$ + Chr$(v) ' Copy the colon
                        GoTo LoopFindSpaces ' look for more commands after the colon
                    End If
                    If v = &H2C Then
                        ' Not the end of the Expression yet
                        Signed16bit = Val("&H" + Temp$)
                        Temp$ = Str$(Signed16bit)
                        Tokenized$ = Tokenized$ + Temp$ + Chr$(v) ' add the converted number and the comma
                        GoTo MoreDataToCheck ' Handle more data
                    Else
                        Temp$ = Temp$ + Chr$(v)
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
                If v = &HF5 And Asc(Mid$(Expression$, i, 1)) = &H22 Then
                    ' Found a quote
                    Tokenized$ = Tokenized$ + Chr$(v) ' Copy &HF5
                    v = Asc(Mid$(Expression$, i, 1)): i = i + 1 ' Get the quote
                    ' inside quoted text ignore commas
                    Do Until (v = &HF5 And Asc(Mid$(Expression$, i, 1)) = &H22) Or i > Len(Expression$) ' copy until we get a close quote or End of line
                        If v = &HF5 Then
                            If Asc(Mid$(Expression$, i, 1)) = &H3A Then
                                Exit Do
                            End If
                        End If
                        Tokenized$ = Tokenized$ + Chr$(v)
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                    Loop
                    Tokenized$ = Tokenized$ + Chr$(v)
                    If v = &HF5 And Asc(Mid$(Expression$, i, 1)) = &H22 Then
                        ' We found an end quote
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                        Tokenized$ = Tokenized$ + Chr$(v)
                        GoTo MoreDataToCheck ' Handle more data
                    End If
                    If v = &HF5 And Asc(Mid$(Expression$, i, 1)) = &H3A Then
                        ' We found a colon on this line
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                        Tokenized$ = Tokenized$ + Chr$(v) ' Copy the colon
                        GoTo LoopFindSpaces ' look for more commands after the colon
                    End If
                    GoTo LoopFindSpaces ' look for more commands
                Else
                    ' Not a quote, copy as is until we get a comma, Colon or EOL
                    Do Until v = &H2C Or i > Len(Expression$)
                        If v = &HF5 Then
                            If Asc(Mid$(Expression$, i, 1)) = &H3A Then
                                Exit Do
                            End If
                        End If
                        Tokenized$ = Tokenized$ + Chr$(v)
                        v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                    Loop
                    ' Make sure right most byte is not a space
                    If i > Len(Expression$) Then
                        'Got to EOL
                        Tokenized$ = Tokenized$ + Chr$(v)
                        Tokenized$ = Left$(Tokenized$, Len(Tokenized$) - 1)
                        While Right$(Tokenized$, 1) = " ": Tokenized$ = Left$(Tokenized$, Len(Tokenized$) - 1): Wend ' make sure there isn't a space before the end
                        If Chr$(v) <> " " Then Tokenized$ = Tokenized$ + Chr$(v) ' Add last byte if it's not a space
                        GoTo MoreDataToCheck ' Handle more data
                    Else
                        While Right$(Tokenized$, 1) = " ": Tokenized$ = Left$(Tokenized$, Len(Tokenized$) - 1): Wend ' make sure there isn't a space before the end
                        Tokenized$ = Tokenized$ + Chr$(v) ' Write the &HF5 or comma
                        If v = &HF5 Then
                            ' We found a colon on this line
                            v = Asc(Mid$(Expression$, i, 1)): i = i + 1
                            Tokenized$ = Tokenized$ + Chr$(v) ' Copy the colon
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
    i = 1
    While i <= Len(Tokenized$)
        v = Asc(Mid$(Tokenized$, i, 1))
        If v = &HFF Then
            If Asc(Mid$(Tokenized$, i + 1, 1)) = MSB And Asc(Mid$(Tokenized$, i + 2, 1)) = LSB Then
                ' Found a DEF FN, let's get the Variable type and number
                DefVar(DefVarCount) = Asc(Mid$(Tokenized$, i + 9, 1)) * 256 + Asc(Mid$(Tokenized$, i + 10, 1))
                DefVarCount = DefVarCount + 1
            End If
        End If
        i = i + 1
    Wend
End If
DoneGettingExpression:
If Verbose > 1 Then
    Print "3rd:"
    For i = 1 To Len(Tokenized$)
        a = Asc(Mid$(Tokenized$, i, 1))
        If a < 16 Then Print "0";
        Print Hex$(Asc(Mid$(Tokenized$, i, 1)));
    Next i
    Print
End If
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
    Case &HF2, &HF3, &HF4: ' Found a numeric or string or floating point variable
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

' Set Variable Number in NumericVarType() to the requested value
' Set Numeric Array in NumericArrayType() to the requested value
' C_AS = command AS

' DIM command is used to assign variables types and space for arrays:
' Variable types are:
'   1 Dim a As _Bit '                 Min -1, Max 0
'   2 Dim b As _Unsigned _Bit '       Min 0 , Max 1
'   3 Dim c As _Byte '                Min -128, Max 127
'   4 Dim d As _Unsigned _Byte '      Min 0, Max 255
'   5 Dim e As Integer '              Min -32,768, Max 32,767
'   6 Dim f As _Unsigned Integer '    Min 0, Max 65,535
'   7 Dim g As Long '                 Min -2 Gig, +2 Gig
'   8 Dim h As _Unsigned Long '       Min 0, Max 4 Gig
'   9 Dim i As _Integer64 '           Min -(8 byte value), Max +(8 byte value)
'  10 Dim j As _Unsigned _Integer64 ' Min 0, Max (8 byte value)
'  11 Dim k As Single '(Default size) Min E-38, Max E+38
'  12 Dim l As Double '               Min E-308, Max E+308

' Since at this point the commands variables and in the program have already been identified we need to change the numeric variable format from
' Numeric array    &HF0, MSB,LSB,# of Elements in the Array to &HF0, MSB,LSB,Type,# of Elements in the Array
' Numeric Variable &HF2, MSB,LSB to &HF2, MSB,LSB,Type


' To calculate the maximum RAM required for an array:
' Default arrays are 0 to 10 = 11 elements
' 4 dimension, Numeric array would be calculated with
' Ram required = (11 * 11 * 11 * 11) * 2
' A 2 dimension, String array would be calculated with
' Ram required = (11 * 11) * 256







DoDim:
' -----------------------------------------------------------------------------
' Enhanced DIM parser:
' Supports BOTH styles:
'   DIM Var1 AS _UNSIGNED INTEGER
'   DIM Var1, Var2, Var3, Var4, Array1(15,3) AS _UNSIGNED INTEGER
'
' We collect all numeric variables/arrays in this DIM statement and apply the
' type once we encounter the AS clause.
' -----------------------------------------------------------------------------

DimList$ = "" ' packed triples: Kind, ID_MSB, ID_LSB  (Kind: 0=var, 1=num array)
DimType = 11 ' default type (Single) unless overridden by AS

DoDim_Loop:
v = Array(x): x = x + 1

' F0 = Numeric Arrays
' F1 = String Arrays
' F2 = Numeric Variables
' F5 = Special chars (comma, colon, EOL, etc)
' FF = Commands (AS, REM, etc)

If v = &HF5 Then
    ' Special char follows
    SpecialChar = Array(x): x = x + 1

    If SpecialChar = &H2C Then
        ' comma: another identifier in this DIM statement
        GoTo DoDim_Loop
    End If

    If SpecialChar = &H0D Or SpecialChar = &H3A Then
        ' end of statement (EOL or ":")
        Return
    End If

    ' Any other special char: ignore and keep scanning
    GoTo DoDim_Loop
End If

If v = &HFF Then
    ' Command follows (2-byte command id)
    Cmd16 = Array(x) * 256 + Array(x + 1): x = x + 2

    If Cmd16 = C_AS Then
        ' Found AS: parse the type and apply it to ALL collected numeric vars/arrays
        GoSub FoundAS

        ' Apply DimType to everything in DimList$
        p = 1
        Do While p <= Len(DimList$)
            Kind = Asc(Mid$(DimList$, p, 1))
            ii = Asc(Mid$(DimList$, p + 1, 1)) * 256 + Asc(Mid$(DimList$, p + 2, 1))

            If Kind = 0 Then
                NumericVarType(ii) = DimType
            Else
                NumericArrayType(ii) = DimType
            End If

            p = p + 3
        Loop

        ' IMPORTANT: clear list so a weird/invalid trailing token doesn't reuse it
        DimList$ = ""

        ' After AS <type>, we should be at end-of-statement or a REM comment.
        v = Array(x): x = x + 1
        If v = &HFF Then
            V2 = Array(x) * 256 + Array(x + 1): x = x + 2
            If V2 = C_REM Or V2 = C_REMApostrophe Then
                GoTo ConsumeCommentsAndEOL
            End If
        End If

        ' If we consumed something that isn't EOL/colon, back up and continue scanning
        x = x - 1
        GoTo DoDim_Loop
    End If

    If Cmd16 = C_REM Or Cmd16 = C_REMApostrophe Then
        GoTo ConsumeCommentsAndEOL
    End If

    ' Some other command inside DIM line: continue scanning
    GoTo DoDim_Loop
End If

If v = &HF1 Then
    ' Set the size of a string array
    ii = Array(x) * 256 + Array(x + 1): x = x + 2
    StringArrayDimensionsVal$(ii) = ""
    NumOfDims = Array(x): x = x + 1

    ' consume the $F5 & open bracket
    v = Array(x): x = x + 2
    ArrayElems = 1

    For T1 = 1 To NumOfDims
        Temp$ = ""
        v = Array(x): x = x + 1
        While v <> &HF5
            Temp$ = Temp$ + Chr$(v)
            v = Array(x): x = x + 1
        Wend
        ' consume special char value (comma or close paren)
        v = Array(x): x = x + 1

        DimN = Val(Temp$)
        ArrayElems = ArrayElems * (DimN + 1)
        DimVal$ = Hex$(DimN)
        DimVal$ = Right$("0000" + DimVal$, 4)
        StringArrayDimensionsVal$(ii) = StringArrayDimensionsVal$(ii) + DimVal$
    Next T1

    If ArrayElems > 254 Then
        StringArrayBits(ii) = 16
    Else
        StringArrayBits(ii) = 8
    End If

    GoTo DoDim_Loop
End If

If v = &HF0 Then
    ' Numeric array
    ii = Array(x) * 256 + Array(x + 1): x = x + 2
    NumOfDims = Array(x): x = x + 1
    NumericArrayBits(ii) = 8
    NumericArrayDimensionsVal$(ii) = ""

    ' consume the $F5 & open bracket
    v = Array(x): x = x + 2
    ArrayElems = 1

    For T1 = 1 To NumOfDims
        Temp$ = ""
        v = Array(x): x = x + 1
        While v <> &HF5
            Temp$ = Temp$ + Chr$(v)
            v = Array(x): x = x + 1
        Wend
        ' consume special char value (comma or close paren)
        v = Array(x): x = x + 1

        DimN = Val(Temp$)
        ArrayElems = ArrayElems * (DimN + 1)
        DimVal$ = Hex$(DimN)
        DimVal$ = Right$("0000" + DimVal$, 4)
        NumericArrayDimensionsVal$(ii) = NumericArrayDimensionsVal$(ii) + DimVal$
    Next T1

    If ArrayElems > 254 Then
        NumericArrayBits(ii) = 16
    Else
        NumericArrayBits(ii) = 8
    End If

    ' Add this array to the "apply AS type to all" list
    DimList$ = DimList$ + Chr$(1) + Chr$(ii \ 256) + Chr$(ii And 255)

    GoTo DoDim_Loop
End If

If v = &HF2 Then
    ' Numeric variable
    ii = Array(x) * 256 + Array(x + 1): x = x + 2

    ' Add this var to the "apply AS type to all" list
    DimList$ = DimList$ + Chr$(0) + Chr$(ii \ 256) + Chr$(ii And 255)

    GoTo DoDim_Loop
End If

' Unknown token in DIM line: keep scanning
GoTo DoDim_Loop










ConsumeCommentsAndEOL:
If v = &H0D Or v = &H3A Then Return
Do Until v = &HF5 And Array(x) = &H0D 'consume any comments and the EOL
    v = Array(x): x = x + 1
Loop
v = Array(x): x = x + 1
Return
' Get DimType (after AS command)
FoundAS:
v = Array(x): x = x + 1
If v <> &HFF Then
    ' First byte must be a command
    Print "Error: Unknown value after AS on";: GoTo FoundError
End If
Type1 = Array(x) * 256 + Array(x + 1): x = x + 2 ' Get the first type value
If Type1 <> C_UNSIGNED Then
    ' Type is not _UNSIGNED
    Select Case Type1
        Case C_UBIT
            ' _BIT
            DimType = 1
        Case C_UBYTE
            ' _BYTE
            DimType = 3
        Case C_INTEGER
            ' INTEGER
            DimType = 5
        Case C_LONG
            ' LONG
            DimType = 7
        Case C_INTEGER64
            ' _INTEGER64
            DimType = 9
        Case C_SINGLE
            ' SINGLE
            DimType = 11
        Case C_DOUBLE
            ' DOUBLE
            DimType = 12
        Case Else
            Print "Error: Unknown value after AS on";: GoTo FoundError
    End Select
Else
    ' First value is _UNSIGNED
    v = Array(x): x = x + 1
    If v <> &HFF Then
        ' First byte must be a command
        Print "Error: Unknown value after AS on";: GoTo FoundError
    End If
    Type2 = Array(x) * 256 + Array(x + 1): x = x + 2 ' Get the 2nd type value
    ' First type is _UNSIGNED
    Select Case Type2
        Case C_UBIT
            ' _BIT
            DimType = 2
        Case C_UBYTE
            ' _BYTE
            DimType = 4
        Case C_INTEGER
            ' INTEGER
            DimType = 6
        Case C_LONG
            ' LONG
            DimType = 8
        Case C_INTEGER64
            ' _INTEGER64
            DimType = 10
        Case Else
            Print "Error: Unknown value after AS on";: GoTo FoundError
    End Select
End If
Return
' Send assembly instructions out to .asm file
AO:
'Print z$ at the beginning of the line
If Len(z$) < 8 Then
    Print #1, Left$(z$ + "        ", 8); Left$(A$ + "        ", 8);
Else
    Print #1, z$; T2$; Left$(A$ + "        ", 8);
End If
If Len(B$) > 13 Then Print #1, B$; "   "; Else Print #1, Left$(B$ + "              ", 14);
If C$ <> "" Then Print #1, "; "; C$ Else Print #1,
z$ = "": A$ = "": B$ = "": C$ = "" 'Clear the strings so next entry won't be repeated
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
    num$ = "0"
Else
    If Num > 0 Then
        'Postive value remove the first space in the string
        num$ = Right$(Str$(Num), Len(Str$(Num)) - 1)
    Else
        'Negative value we keep the minus sign
        num$ = Str$(Num)
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
If Asc(Mid$(Expression$, i, 1)) = &HFF Then
    For ii = 0 To GeneralCommandsCount
        If GeneralCommands$(ii) = Check$ Then
            Exit For
        End If
    Next ii
    If Asc(Mid$(Expression$, i + 1, 1)) * 256 + Asc(Mid$(Expression$, i + 2, 1)) = ii Then
        Found = 1
    End If
End If
Return

' LINE may or may not have ,B or BF at the end which might get turned into variable below
' Change the Tokenized$ command so it will have
' after ,PSET or ,PRESET we will have
' ,0,0 - No Box or Box Fill
' ,1,0 - Draw a Box
' ,1,1 - Draw a box and fill it
FixLineCommand:
Temp$ = ""
i = 1
Num = ii
GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
While InStr(i, Tokenized$, Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) > 0
    i = InStr(i, Tokenized$, Chr$(&HFF) + Chr$(MSB) + Chr$(LSB))
    StartLine = i ' Start of the line
    ' Does this command end with a Colon?
    EndLine = InStr(i, Tokenized$, Chr$(&HF5) + Chr$(&H3A))
    If EndLine = 0 Then
        FoundREM = 0
        ' no colon found at the end of the line, check for a REM or an apostrophe
        Num = C_REM
        GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
        If InStr(i, Tokenized$, " " + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) > 0 Then
            EndLine = InStr(i, Tokenized$, " " + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) - 1
            FoundREM = 1
        End If
        Num = C_REMApostrophe
        GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
        If InStr(i, Tokenized$, " " + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) > 0 Then
            EndLine = InStr(i, Tokenized$, " " + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) - 1
            FoundREM = 1
        End If
    End If
    If FoundREM = 1 Then
        FoundColon$ = ""
    Else
        If EndLine = 0 Then
            ' No other LINE commands after colons, this is the last
            EndLine = Len(Tokenized$)
            FoundColon$ = ""
        Else
            EndLine = EndLine - 1
            FoundColon$ = Chr$(&HF5)
        End If
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
    i = EndLine + 2
Wend
If Temp$ <> "" Then
    ' We found a LINE command
    Tokenized$ = Temp$ + Right$(Tokenized$, Len(Tokenized$) - i + 1)
End If
Return


' ATTR may or may not have ,B or ,U at the end which might get turned into variable below
' Change the Tokenized$ command so it will have
' ,0,0 - No Blink or Underline
' ,1,0 - Blink
' ,0,1 - Underline
' ,1,1 - Blink & Underline
FixAttrCommand:
Temp$ = ""
i = 1
Num = ii 'ii = ATTR command number
GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
While InStr(i, Tokenized$, Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) > 0
    i = InStr(i, Tokenized$, Chr$(&HFF) + Chr$(MSB) + Chr$(LSB))
    StartLine = i ' Start of the ATTR
    ' Does this command end with a Colon?
    EndLine = InStr(i, Tokenized$, Chr$(&HF5) + Chr$(&H3A))
    If EndLine = 0 Then
        FoundREM = 0
        ' no colon found at the end of the line, check for a REM or an apostrophe
        Num = C_REM
        GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
        If InStr(i, Tokenized$, " " + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) > 0 Then
            EndLine = InStr(i, Tokenized$, " " + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) - 1
            FoundREM = 1
        End If
        Num = C_REMApostrophe
        GoSub NumToMSBLSBString ' Convert number in num to 16 bit value in MSB$ & LSB$ and MSB & LSBs
        If InStr(i, Tokenized$, " " + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) > 0 Then
            EndLine = InStr(i, Tokenized$, " " + Chr$(&HFF) + Chr$(MSB) + Chr$(LSB)) - 1
            FoundREM = 1
        End If
    End If
    If FoundREM = 1 Then
        FoundColon$ = ""
    Else
        If EndLine = 0 Then
            ' No other LINE commands after colons, this is the last
            EndLine = Len(Tokenized$)
            FoundColon$ = ""
        Else
            EndLine = EndLine - 1
            FoundColon$ = Chr$(&HF5)
        End If
    End If
    BUTemp$ = ",0,0"
    If Mid$(Tokenized$, EndLine - 6, 7) = ", B , U" Then
        BUTemp$ = ",1,1"
        Temp$ = Temp$ + Mid$(Tokenized$, StartLine, EndLine - StartLine - 7) + BUTemp$
        GoTo FoundBU
    End If
    If Mid$(Tokenized$, EndLine - 6, 7) = ", U , B" Then
        BUTemp$ = ",1,1"
        Temp$ = Temp$ + Mid$(Tokenized$, StartLine, EndLine - StartLine - 7) + BUTemp$
        GoTo FoundBU
    End If
    If Mid$(Tokenized$, EndLine - 2, 3) = ", B" Then
        BUTemp$ = ",1,0"
        Temp$ = Temp$ + Mid$(Tokenized$, StartLine, EndLine - StartLine - 3) + BUTemp$
        GoTo FoundBU
    End If
    If Mid$(Tokenized$, EndLine - 2, 3) = ", U" Then
        BUTemp$ = ",0,1"
        Temp$ = Temp$ + Mid$(Tokenized$, StartLine, EndLine - StartLine - 3) + BUTemp$
        GoTo FoundBU
    End If
    If BUTemp$ = ",0,0" Then
        ' No B or U found at the end of this line
        Temp$ = Temp$ + Mid$(Tokenized$, StartLine, EndLine - StartLine + 1) + BUTemp$
    End If
    FoundBU:
    i = EndLine + 2
Wend
If Temp$ <> "" Then
    ' We found a ATTR command
    Tokenized$ = Temp$ + Right$(Tokenized$, Len(Tokenized$) - i + 1)
End If
Return

CheckType:
' # are encoded as $F523, so they are checked and handled elsewhere
If Array(x) = Asc("&") Or Array(x) = Asc("~") Or Array(x) = Asc("!") Then
    ' Looks like we have a special type assignment
    If Array(x) = Asc("~") And Array(x + 1) = Asc("&") And Array(x + 2) = Asc("&") Then ' ~&&  _Unsigned _Integer64
        Temp$ = "Math_Integer64": GoSub AddIncludeTemp ' Add code for 64 bit math, some routines use integer 64 Add/Subtract
        x = x + 3
        GoTo DoneCheckType
    End If
    If Array(x) = Asc("&") And Array(x + 1) = Asc("&") Then ' ~&   _Unsigned Long
        Temp$ = "Math_Integer32": GoSub AddIncludeTemp ' Add code for 32 bit math
        x = x + 2
        GoTo DoneCheckType
    End If
    If Array(x) = Asc("&") And Array(x + 1) = Asc("&") Then ' &&   _Integer64
        Temp$ = "Math_Integer64": GoSub AddIncludeTemp ' Add code for 64 bit math, some routines use integer 64 Add/Subtract
        x = x + 2
        GoTo DoneCheckType
    End If
    If Array(x) = Asc("~") And Array(x + 1) = Asc("~") Then ' ~~   _Unsigned _Short
        x = x + 2
        GoTo DoneCheckType
    End If
    If Array(x) = Asc("&") Then ' &   Long
        Temp$ = "Math_Integer32": GoSub AddIncludeTemp ' Add code for 32 bit math
        x = x + 1
        GoTo DoneCheckType
    End If
    If Array(x) = Asc("!") Then ' !(None) Single '(Default size)
        '        Temp$ = "Math_FloatingPointLB": GoSub AddIncludeTemp ' Add code for Lennart Benschop's Floating point math routines
        Temp$ = "Math_Fast_Floating_Point": GoSub AddIncludeTemp ' Add code for my Fast Floating Point math routines
        x = x + 1
        GoTo DoneCheckType
    End If
    If Array(x) = Asc("~") Then ' ~   _Short
        x = x + 1
    End If
Else
    ' Might be a #
    If Array(x) = &HF5 And Array(x + 1) = Asc("#") Then ' #    use Double
        Temp$ = "Math_IEEE_754_Double_64bit": GoSub AddIncludeTemp ' Add code for Selecting the audio muxer and to turn it on or off
        Temp$ = "Math_Integer64": GoSub AddIncludeTemp ' Add code for 64 bit math, some routines use integer 64 Add/Subtract
        x = x + 2
    End If
End If
DoneCheckType:
Return

' If variable Temp$ ends with special tokens which temp change their Type, we must ignore them' ------------------------------------------------------------
' CONST support (compile-time constants)
'   CONST name = <literal>
'   CONST name$ = "literal"
'
' Notes:
'   - Names are stored case-insensitively (uppercased).
'   - Names are normalized with CheckVarForSpecial (so type-suffixes are ignored like normal vars).
'   - Values are stored as text and expanded into Expression$ before TokenizeExpression runs.
'   - v1 intentionally keeps RHS simple (literal number or quoted string). If you write
'     CONST A = 100+100 it will be expanded textually (and will tokenize fine), but it won't
'     be folded/evaluated at compile time unless your expression engine already does it.
' ------------------------------------------------------------

ParseConstLine:
' Expression$ begins with "CONST ..."
TempLine$ = LTrim$(Mid$(Expression$, 6)) ' drop "CONST "
TempLine$ = LTrim$(TempLine$)

' Get name up to space or '='
p = 1
Temp$ = ""
While p <= Len(TempLine$)
    ch$ = Mid$(TempLine$, p, 1)
    If ch$ = " " Or ch$ = "=" Then Exit While
    Temp$ = Temp$ + ch$
    p = p + 1
Wend
If Len(Temp$) = 0 Then
    Print "Error: CONST missing name in line:"; Expression$
    Return
End If
GoSub CheckVarForSpecial
ConstNameU$ = UCase$(Temp$)

' Find '='
While p <= Len(TempLine$) And Mid$(TempLine$, p, 1) <> "="
    p = p + 1
Wend
If p > Len(TempLine$) Then
    Print "Error: CONST missing '=' in line:"; Expression$
    Return
End If
p = p + 1 ' skip '='
While p <= Len(TempLine$) And Mid$(TempLine$, p, 1) = " "
    p = p + 1
Wend

' RHS value (strip trailing apostrophe comment, outside quotes)
ConstValueU$ = RTrim$(Mid$(TempLine$, p))
out$ = ""
inQ = 0
For k = 1 To Len(ConstValueU$)
    ch$ = Mid$(ConstValueU$, k, 1)
    If ch$ = Chr$(&H22) Then
        If inQ = 0 Then inQ = 1 Else inQ = 0
    End If
    If inQ = 0 And ch$ = "'" Then Exit For
    out$ = out$ + ch$
Next k
ConstValueU$ = RTrim$(out$)

' Try constant expansion + numeric constant folding (compile-time evaluation)
CF_FoldOK = 0
CF_Folded$ = ""
If Len(ConstValueU$) > 0 Then
    If Left$(LTrim$(ConstValueU$), 1) <> Chr$(&H22) Then
        ' Expand any earlier CONSTs inside this RHS first (allows: CONST B = A+1)
        CF_TempExpr$ = ConstValueU$
        Expression$ = CF_TempExpr$: GoSub ExpandConstsInExpression: CF_TempExpr$ = Expression$
        GoSub TryFoldNumericConst
        If CF_FoldOK <> 0 Then ConstValueU$ = CF_Folded$
    End If
End If


' Store / update
Found = 0
For ii = 0 To ConstCount - 1
    If ConstName$(ii) = ConstNameU$ Then
        ConstValue$(ii) = ConstValueU$
        Found = 1
        Exit For
    End If
Next ii
If Found = 0 Then
    ConstName$(ConstCount) = ConstNameU$
    ConstValue$(ConstCount) = ConstValueU$
    ConstCount = ConstCount + 1
End If

If Verbose > 1 Then Print "CONST "; ConstNameU$; " = "; ConstValueU$
Return


ExpandConstsInExpression:
If ConstCount <= 0 Then Return

src$ = Expression$
out$ = ""
inQ = 0
i = 1
While i <= Len(src$)
    ch$ = Mid$(src$, i, 1)

    If ch$ = Chr$(&H22) Then
        If inQ = 0 Then inQ = 1 Else inQ = 0
        out$ = out$ + ch$
        i = i + 1
        GoTo ExpandNextChar
    End If

    If inQ = 0 Then
        a = Asc(ch$)
        If (a >= 65 And a <= 90) Or (a >= 97 And a <= 122) Or ch$ = "_" Then
            ' Grab identifier
            word$ = ""
            j = i
            While j <= Len(src$)
                ch2$ = Mid$(src$, j, 1)
                a2 = Asc(ch2$)
                If (a2 >= 65 And a2 <= 90) Or (a2 >= 97 And a2 <= 122) Or (a2 >= 48 And a2 <= 57) Or ch2$ = "_" Or ch2$ = "$" Then
                    word$ = word$ + ch2$
                    j = j + 1
                Else
                    Exit While
                End If
            Wend

            ' Normalize and check const table
            Temp$ = word$
            GoSub CheckVarForSpecial
            base$ = UCase$(Temp$)

            repl$ = ""
            For ii = 0 To ConstCount - 1
                If ConstName$(ii) = base$ Then
                    repl$ = ConstValue$(ii)
                    Exit For
                End If
            Next ii

            If repl$ <> "" Then
                ' Insert CONST replacement (avoid wrapping simple numeric literals so PRINT/args stay simple)
                EC_T$ = LTrim$(repl$)
                If Left$(EC_T$, 1) = Chr$(&H22) Then
                    out$ = out$ + repl$
                Else
                    ' Decide if repl$ is a simple numeric literal (decimal or &Hhex, optional leading sign).
                    EC_SimpleNum = -1
                    EC_k = 1
                    If EC_k <= Len(EC_T$) Then
                        EC_c$ = Mid$(EC_T$, EC_k, 1)
                        If EC_c$ = "+" Or EC_c$ = "-" Then EC_k = EC_k + 1
                    End If

                    If EC_k <= Len(EC_T$) - 1 Then
                        If UCase$(Mid$(EC_T$, EC_k, 2)) = "&H" Then
                            EC_k = EC_k + 2
                            If EC_k > Len(EC_T$) Then EC_SimpleNum = 0
                            While EC_k <= Len(EC_T$) And EC_SimpleNum <> 0
                                EC_c$ = Mid$(EC_T$, EC_k, 1)
                                EC_a = Asc(UCase$(EC_c$))
                                If (EC_a >= 48 And EC_a <= 57) Or (EC_a >= 65 And EC_a <= 70) Then
                                    EC_k = EC_k + 1
                                Else
                                    EC_SimpleNum = 0
                                End If
                            Wend
                        Else
                            EC_seenDigit = 0
                            While EC_k <= Len(EC_T$) And EC_SimpleNum <> 0
                                EC_c$ = Mid$(EC_T$, EC_k, 1)
                                EC_a = Asc(EC_c$)
                                If EC_a >= 48 And EC_a <= 57 Then
                                    EC_seenDigit = -1
                                    EC_k = EC_k + 1
                                ElseIf EC_c$ = "." Then
                                    EC_k = EC_k + 1
                                ElseIf EC_c$ = "E" Or EC_c$ = "e" Then
                                    EC_k = EC_k + 1
                                    If EC_k <= Len(EC_T$) Then
                                        EC_c$ = Mid$(EC_T$, EC_k, 1)
                                        If EC_c$ = "+" Or EC_c$ = "-" Then EC_k = EC_k + 1
                                    End If
                                Else
                                    EC_SimpleNum = 0
                                End If
                            Wend
                            If EC_seenDigit = 0 Then EC_SimpleNum = 0
                        End If
                    Else
                        ' Single char after optional sign: must be a digit
                        If EC_k > Len(EC_T$) Then
                            EC_SimpleNum = 0
                        Else
                            EC_a = Asc(Mid$(EC_T$, EC_k, 1))
                            If EC_a < 48 Or EC_a > 57 Then EC_SimpleNum = 0
                        End If
                    End If

                    If EC_SimpleNum <> 0 Then
                        out$ = out$ + repl$
                    Else
                        out$ = out$ + "(" + repl$ + ")"
                    End If
                End If
            Else
                out$ = out$ + word$
            End If

            i = j
            GoTo ExpandNextChar
        End If
    End If

    out$ = out$ + ch$
    i = i + 1
    ExpandNextChar:
Wend

Expression$ = out$
Return




TryFoldNumericConst:
' Input: CF_TempExpr$ = expression text
' Output: CF_FoldOK = -1 if folded, CF_Folded$ = folded literal text
CF_FoldOK = 0
CF_Folded$ = ""
CF_Error = 0
src$ = LTrim$(RTrim$(CF_TempExpr$))
If Len(src$) = 0 Then Return

' Quick validity scan: allow only numeric expression characters (no identifiers)
inQ = 0
For ii = 1 To Len(src$)
    ch$ = Mid$(src$, ii, 1)
    a = Asc(ch$)
    If ch$ = Chr$(&H22) Then
        ' strings not foldable here
        CF_Error = 1: Exit For
    End If
    ' allowed: digits, space, dot, + - * / ^ ( ) , E/e, &H hex
    If (a >= 48 And a <= 57) Or ch$ = " " Or ch$ = "." Or ch$ = "+" Or ch$ = "-" Or ch$ = "*" Or ch$ = "/" Or ch$ = "^" Or ch$ = "(" Or ch$ = ")" Or ch$ = "E" Or ch$ = "e" Or ch$ = "&" Or ch$ = "H" Or ch$ = "h" Then
        ' ok
    Else
        ' Any other char means identifiers/functions/etc -> don't fold
        CF_Error = 1: Exit For
    End If
Next ii
If CF_Error <> 0 Then
    CF_Error = 0
    Return
End If

GoSub CF_EvalExpression
If CF_Error <> 0 Then
    CF_Error = 0
    Return
End If

' Format result back to a BASIC numeric literal.
' If it's an integer (within tiny epsilon), output as integer text.
CF_Eps = 0.000000001#
CF_r = CF_Result
If CF_r >= 0 Then
    CF_RI64 = Fix(CF_r + 0.5)
Else
    CF_RI64 = -Fix((-CF_r) + 0.5)
End If
If Abs(CF_r - CDbl(CF_RI64)) < CF_Eps Then
    CF_Folded$ = LTrim$(Str$(CF_RI64))
Else
    ' Use STR$ and trim leading space; keep enough precision for DOUBLE.
    CF_Folded$ = LTrim$(Str$(CF_r))
    ' Ensure we have a decimal point if STR$ produced scientific without dot? (STR$ can do 1E+06)
    ' That's still a valid BASIC literal, so leave it.
End If

CF_FoldOK = -1
Return

CF_EvalExpression:
' Shunting-yard evaluator: supports + - * / ^, unary +/-, parentheses, decimals, and &Hxxxx hex.
CF_VSP = 0
CF_OSP = 0
CF_PrevTok = 0 ' 0=start, 1=number/), 2=operator, 3='('
CF_Error = 0

s$ = LTrim$(RTrim$(CF_TempExpr$))
i = 1
CF_EvalNext:
' skip spaces
While i <= Len(s$) And Mid$(s$, i, 1) = " "
    i = i + 1
Wend
If i > Len(s$) Then GoTo CF_EvalFinish

ch$ = Mid$(s$, i, 1)

' Parentheses
If ch$ = "(" Then
    CF_OSP = CF_OSP + 1
    CF_Op$(CF_OSP) = "("
    CF_PrevTok = 3
    i = i + 1
    GoTo CF_EvalNext
End If
If ch$ = ")" Then
    ' Pop until '('
    While CF_OSP > 0 And CF_Op$(CF_OSP) <> "("
        GoSub CF_ApplyTopOp
        If CF_Error <> 0 Then Return
    Wend
    If CF_OSP = 0 Then CF_Error = 1: Return
    CF_OSP = CF_OSP - 1 ' pop '('
    CF_PrevTok = 1
    i = i + 1
    GoTo CF_EvalNext
End If

' Number (decimal or hex)
a = Asc(ch$)
If (a >= 48 And a <= 57) Or ch$ = "." Or ch$ = "&" Then
    GoSub CF_ReadNumber
    If CF_Error <> 0 Then Return
    CF_VSP = CF_VSP + 1
    CF_Val(CF_VSP) = CF_num
    CF_PrevTok = 1
    GoTo CF_EvalNext
End If

' Operator
If ch$ = "+" Or ch$ = "-" Or ch$ = "*" Or ch$ = "/" Or ch$ = "^" Then
    op$ = ch$

    ' Unary +/-
    If (op$ = "+" Or op$ = "-") Then
        If CF_PrevTok = 0 Or CF_PrevTok = 2 Or CF_PrevTok = 3 Then
            If op$ = "-" Then op$ = "u" Else op$ = "p" ' unary minus / unary plus
        End If
    End If

    curPrec = 0
    curRightAssoc = 0
    GoSub CF_GetOpInfo
    curPrec = prec
    curRightAssoc = rightAssoc

    ' Pop higher precedence ops (or equal if left-assoc)
    While CF_OSP > 0
        top$ = CF_Op$(CF_OSP)
        If top$ = "(" Then Exit While
        op$ = top$: GoSub CF_GetOpInfo
        topPrec = prec
        topRight = rightAssoc

        If topPrec > curPrec Or (topPrec = curPrec And curRightAssoc = 0) Then
            GoSub CF_ApplyTopOp
            If CF_Error <> 0 Then Return
        Else
            Exit While
        End If
    Wend

    CF_OSP = CF_OSP + 1
    CF_Op$(CF_OSP) = Mid$(s$, i, 1)
    If CF_Op$(CF_OSP) = "-" And (CF_PrevTok = 0 Or CF_PrevTok = 2 Or CF_PrevTok = 3) Then CF_Op$(CF_OSP) = "u"
    If CF_Op$(CF_OSP) = "+" And (CF_PrevTok = 0 Or CF_PrevTok = 2 Or CF_PrevTok = 3) Then CF_Op$(CF_OSP) = "p"
    CF_PrevTok = 2
    i = i + 1
    GoTo CF_EvalNext
End If

' Unknown char
CF_Error = 1
Return

CF_EvalFinish:
While CF_OSP > 0
    If CF_Op$(CF_OSP) = "(" Then CF_Error = 1: Return
    GoSub CF_ApplyTopOp
    If CF_Error <> 0 Then Return
Wend
If CF_VSP <> 1 Then CF_Error = 1: Return
CF_Result = CF_Val(1)
Return

CF_ReadNumber:
' Reads a number at position i in s$
' Outputs: CF_num
ch$ = Mid$(s$, i, 1)
If ch$ = "&" Then
    ' Expect &H...
    If i + 1 > Len(s$) Then CF_Error = 1: Return
    If UCase$(Mid$(s$, i + 1, 1)) <> "H" Then CF_Error = 1: Return
    j = i + 2
    If j > Len(s$) Then CF_Error = 1: Return
    CF_N64 = 0
    digCount = 0
    While j <= Len(s$)
        ch2$ = Mid$(s$, j, 1)
        a2 = Asc(UCase$(ch2$))
        If a2 >= 48 And a2 <= 57 Then
            v = a2 - 48
        ElseIf a2 >= 65 And a2 <= 70 Then
            v = a2 - 55
        Else
            Exit While
        End If
        CF_N64 = CF_N64 * 16 + v
        digCount = digCount + 1
        j = j + 1
    Wend
    If digCount = 0 Then CF_Error = 1: Return
    CF_num = CDbl(CF_N64)
    i = j
    Return
End If

' Decimal / scientific
j = i
hasE = 0
While j <= Len(s$)
    ch2$ = Mid$(s$, j, 1)
    a2 = Asc(ch2$)
    If (a2 >= 48 And a2 <= 57) Or ch2$ = "." Then
        j = j + 1
    ElseIf (ch2$ = "E" Or ch2$ = "e") Then
        If hasE <> 0 Then Exit While
        hasE = -1
        j = j + 1
        ' optional sign right after E
        If j <= Len(s$) Then
            ch3$ = Mid$(s$, j, 1)
            If ch3$ = "+" Or ch3$ = "-" Then j = j + 1
        End If
    Else
        Exit While
    End If
Wend

tok$ = Mid$(s$, i, j - i)
If Len(tok$) = 0 Then CF_Error = 1: Return
CF_num = Val(tok$)
i = j
Return

CF_GetOpInfo:
' Input: op$ ; Output: prec, rightAssoc
prec = 0
rightAssoc = 0
Select Case op$
    Case "p", "u"
        prec = 4: rightAssoc = -1
    Case "^"
        prec = 3: rightAssoc = -1
    Case "*", "/"
        prec = 2: rightAssoc = 0
    Case "+", "-"
        prec = 1: rightAssoc = 0
    Case Else
        prec = 0: rightAssoc = 0
End Select
Return

CF_ApplyTopOp:
top$ = CF_Op$(CF_OSP)
CF_OSP = CF_OSP - 1

If top$ = "u" Or top$ = "p" Then
    If CF_VSP < 1 Then CF_Error = 1: Return
    CF_a = CF_Val(CF_VSP)
    If top$ = "u" Then CF_a = -CF_a
    CF_Val(CF_VSP) = CF_a
    Return
End If

If CF_VSP < 2 Then CF_Error = 1: Return
CF_b = CF_Val(CF_VSP): CF_VSP = CF_VSP - 1
CF_a = CF_Val(CF_VSP)

Select Case top$
    Case "+"
        CF_a = CF_a + CF_b
    Case "-"
        CF_a = CF_a - CF_b
    Case "*"
        CF_a = CF_a * CF_b
    Case "/"
        If CF_b = 0 Then CF_Error = 1: Return
        CF_a = CF_a / CF_b
    Case "^"
        CF_a = CF_a ^ CF_b
    Case Else
        CF_Error = 1: Return
End Select

CF_Val(CF_VSP) = CF_a
Return



CheckVarForSpecial:
' Check for a single special symbol at the end of the variable
Select Case Asc(Right$(Temp$, 1))
    Case Asc("`"), Asc("%"), Asc("&"), Asc("!"), Asc("#")
        Temp$ = Left$(Temp$, Len(Temp$) - 1)
        Return
End Select
Select Case Right$(Temp$, 2)
    Case "`n", "~`", "%%", "~%", "~&", "&&", "##", "%&"
        Temp$ = Left$(Temp$, Len(Temp$) - 2)
        Return
End Select
Select Case Right$(Temp$, 3)
    Case "~%%", "~&&", "~%&"
        Temp$ = Left$(Temp$, Len(Temp$) - 3)
        Return
End Select
Return ' leave it as is

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




