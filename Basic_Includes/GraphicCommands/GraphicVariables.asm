; To setup the graphics mode and screen location use the following:
;
; Example:  LDA   #Semi_graphic_4       ; A = the graphics mode requested (see list below)
;           JSR   SetGraphicModeA       ; Go setup the mode
;
; Example: Memlocation required is $E00 then A=$E00/$200 = $07
;       LDA     #$E00/$200              ; A = the location in RAM to start the graphics screen
;       JSR     SetGraphicsStartA       ; Go setup the screen start location
;
* Graphic Table Entries:
*                                               Mode                   VDG Settings         SAM
*                                                                A/G GM2 GM1 GM0 V2/V1/V0 Desc.      RAM used
*                                                                                           X x YxColours hex(dec)
Internal_Alphanumeric   EQU     %00000000 ;  Internal alphanumeric 0   X   X   0   0 0 0    32x 16   (5x7 pixel ch)
External_Alphanumeric   EQU     %00010000 ;  External alphanumeric 0   X   X   1   0 0 0    32x 16   (8x12 pixel ch)
Semi_graphic_4          EQU     %00000000 ;  Semi graphic-4        0   X   X   0   0 0 0    32x 16   ch, 64x32 pixels
Semi_graphic_4Hybrid    EQU     %00000010 ;  Semi graphic-8        0   X   X   0   0 1 0    64x 32x9 $800(2048)
Semi_graphic_6          EQU     %00010000 ;  Semi graphic-6        0   X   X   1   0 0 0    64x 48   pixels
Semi_graphic_6Hybrid    EQU     %00000100 ;  Semi graphic-12       0   X   X   0   1 0 0    64x 48x9 $C00(3072)
Semi_graphic_8          EQU     %00000010 ;  Semi graphic-8        0   X   X   0   0 1 0    64x 64x9 $800(2048)
Semi_graphic_12         EQU     %00000100 ;  Semi graphic-12       0   X   X   0   1 0 0    64x 96x9 $C00(3072)
Semi_graphic_24         EQU     %00000110 ;  Semi graphic-24       0   X   X   0   1 1 0    64x192x9 $1800(6144)
Full_graphic_1_C        EQU     %10000001 ;  Full graphic 1-C      1   0   0   0   0 0 1    64x 64x4 $400(1024)
Full_graphic_1_R        EQU     %10010001 ;  Full graphic 1-R      1   0   0   1   0 0 1   128x 64x2 $400(1024)
Full_graphic_2_C        EQU     %10100010 ;  Full graphic 2-C      1   0   1   0   0 1 0   128x 64x4 $800(2048)
Full_graphic_2_R        EQU     %10110011 ;  Full graphic 2-R      1   0   1   1   0 1 1   128x 96x2 $600(1536)
Full_graphic_3_C        EQU     %11000100 ;  Full graphic 3-C      1   1   0   0   1 0 0   128x 96x4 $C00(3072)
Full_graphic_3_R        EQU     %11010101 ;  Full graphic 3-R      1   1   0   1   1 0 1   128x192x2 $C00(3072)
Full_graphic_6_C        EQU     %11100110 ;  Full graphic 6-C      1   1   1   0   1 1 0   128x192x4 $1800(6144)
Full_graphic_6_R        EQU     %11110110 ;  Full graphic 6-R      1   1   1   1   1 1 0   256x192x2 $1800(6144)
DMAccess_graphics       EQU     %00000111 ;  Direct memory access  X   X   X   X   1 1 1
;
*****************************************************
* A/G, GNM2, GM1, GM0, are set in $FF22 as:
; Bit 7 VDG CONTROL A/G : Alphanum = 0, graphics =1
; Bit 6 " GM2
; Bit 5 " GM1 & invert
; Bit 4 VDG CONTROL GM0 & shift toggle
; Bit 3 RGB Monitor sensing (INPUT) CSS - Color Set Select 0,1
; Bit 2 RAM SIZE INPUT
; Bit 1 SINGLE BIT SOUND OUTPUT
; Bit 0 RS-232C DATA INPUT
;
* SAM Video Display - SAM_Vx CoCo 1/2/3
* $FFC0-$FFC5
* $FFC0/1 SAM_V0, or V0CLR/V0SET
* $FFC2/3 SAM_V1, or V1CLR/V1SET
* $FFC4/5 SAM_V2, or V2CLR/V1SET
* (1) This allows setting video modes on the CoCo 1 and 2
* (2) SAM_Vx are three pairs of addresses (V0-V2), and poking any value to
*  EVEN addresses sets bit Vx off (0) in Video Display Generator (VDG)
*  circuitry. Poking a value to ODD addresses sets bit on (1) in VDG circuit.
* (3) These registers work with $FF22 for setting modes, and should match up
* (4) Default screen mode is semigraphic-4
* (5) Mode correspondence between the SAM and the VDG:
*
*         Mode            VDG Settings         SAM
*                       A/G GM2 GM1 GM0 V2/V1/V0 Desc. RAM used
*                                                 X x YxColours hex(dec)
*  Internal alphanumeric 0   X   X   0   0 0 0    32x 16   (5x7 pixel ch)
*  External alphanumeric 0   X   X   1   0 0 0    32x 16   (8x12 pixel ch)
*  Semi graphic-4        0   X   X   0   0 0 0    32x 16   ch, 64x32 pixels
*  Semi graphic-6        0   X   X   1   0 0 0    64x 48   pixels
*  Semi graphic-8        0   X   X   0   0 1 0    64x 64x9 $800(2048)
*  Semi graphic-12       0   X   X   0   1 0 0    64x 96x9 $C00(3072)
*  Semi graphic-24       0   X   X   0   1 1 1    32x192x9 $1800(6144)
*  Full graphic 1-C      1   0   0   0   0 0 1    64x 64x4 $400(1024)
*  Full graphic 1-R      1   0   0   1   0 0 1   128x 64x2 $400(1024)
*  Full graphic 2-C      1   0   1   0   0 1 0   128x 64x4 $800(2048)
*  Full graphic 2-R      1   0   1   1   0 1 1   128x 96x2 $600(1536)
*  Full graphic 3-C      1   1   0   0   1 0 0   128x 96x4 $C00(3072)
*  Full graphic 3-R      1   1   0   1   1 0 1   128x192x2 $C00(3072)
*  Full graphic 6-C      1   1   1   0   1 1 0   128x192x4 $1800(6144)
*  Full graphic 6-R      1   1   1   1   1 1 0   256x192x2 $1800(6144)
*  Direct memory access  X   X   X   X   1 1 1
*
*  To setup the graphics mode:
*  Set A with the MS nibble with   A/G GM2 GM1 GM0 bits and the LS nibble with 0 + V2/V1/V0 bits
*  For example:  Full graphic 2-R   1   0   1   1
*                                                                              0     0 1 1   128x 96x2 $600(1536)
*  You would do a LDA  #%10110000 ; 4 MS bits match A/G GM2 GM1 GM0
*  You would do a LDB  #%00000011 ; 3 LS bits match V2/V1/V0
*  JSR   SetGraphicMode
*  
* Graphic Table Entries:
*                                                Mode                   VDG Settings         SAM
*                                                                 A/G GM2 GM1 GM0 V2/V1/V0 Desc.      RAM used
*                                                                                            X x YxColours hex(dec)
; Setup The proper graphics mode for the CoCo based on the value in A
; Enter with A with the high nibble matching the values (0,1) of A/G GM2 GM1 GM0
; and the low nibble of A matching the 0 + V2/V1/V0
; Example:  LDA   #Semi_graphic_6_R     ; A = the graphics mode requested
;           JSR   SetGraphicModeA
;
SetGraphicModeA:
        LDB     $FF22           ; Get PIA 1 side B data register - PIA1BD 
        ANDB    #%00000111      ; Keep the low bits, clear the hi bits
        PSHS    B               ; Save it on the stack
        TFR     A,B
        ANDB    #%11111000      ; Keep only A/G GM2 GM1 GM0 bits
        ORB     ,S+             ; Or with original value, and fix the stack
        STB     $FF22           ; Send to PIA 1 side B data register - PIA1BD 
        ANDA    #%00000111      ; Keep only V2/V1/V0 bits
        LDB     #3              ; 3 bits to send
        LDX     #SAM_Video_Display_Mode ; SAM VDG Mode registers
        BRA     SetSAMbits      ; Go set the SAM bits and return
;
; Set the memory location the VDG will use for the graphics screen use this code:
; Enter with A = Memlocation/$200       ($200=512 bytes)
; Example if Memlocation required is $E00 then A=$E00/$200 = $07
;       LDA     #$E00/$200
;       JSR     SetGraphicsStartA
;
 SetGraphicsStartA:
        LDB     #7               ; 7 bits to send
        LDX     #SAM_Page_Select ; Set the VDG start location
        BRA     SetSAMbits       ; Go set the SAM bits and return

* (6) Notes:
*  - The graphic modes with -C are 4 color, -R is 2 color.
*  - 2 color mode - 8 pixels per byte (each bit denotes on/off)
*    4 color mode - 4 pixels per byte (each 2 bits denotes color)
*  - CSS (in FF22) is the color select bit:
*  Color set 0: 0 = black,    1 = green for -R modes
*              00 = green,   01 = yellow for -C modes
*              10 = blue,    11 = red for -C modes
*  Color set 1: 0 = black,    1 = buff for -R modes
*              00 = buff,    01 = cyan, for -C modes
*              10 = magenta, 11 = orange for -C modes
*
*   In semigraphic-4 mode, each byte is a char or 4 pixels:
*   bit 7 = 0 -> text char in following 7 bits
*   bit 7 = 1 -> graphic: 3 bit color code, then 4 bits for 4 quads of color
*   colors 000-cyan, yellow, blue, red, buff, cyan, magenta, orange=111
*   quad bits orientation UL, UR, LL, LR
*
*   In semigraphic-6 mode, each byte is 6 pixels:
*   bit 7-6 = C1-C0 color from 4 color sets above
*   bit 5-0 = 6 pixels in 2x3 block, each on/off
*   TODO - orientation
*
*   Example: To set 6-C color set 0, lda #$E0, sta in $FF22, $FFC3, $FFC5
*   To return to text mode, clra, sta in $FF22, $FFC2, $FFC4
*
* $FFC0/1 SAM_V0, or V0CLR/V0SET
* $FFC2/3 SAM_V1, or V1CLR/V1SET
* $FFC4/5 SAM_V2, or V2CLR/V1SET
SAM_Video_Display_Mode      EQU $FFC0
SAM_Video_Display_V0_CLR    EQU SAM_Video_Display_Mode
SAM_Video_Display_V0_SET    EQU SAM_Video_Display_Mode+1
SAM_Video_Display_V1_CLR    EQU SAM_Video_Display_Mode+2
SAM_Video_Display_V1_SET    EQU SAM_Video_Display_Mode+3
SAM_Video_Display_V2_CLR    EQU SAM_Video_Display_Mode+4
SAM_Video_Display_V2_SET    EQU SAM_Video_Display_Mode+5
*****************************************************
* SAM Page Select Reg-SAM_Fx CoCo 1/2/3
* $FFC6-$FFD3
* $FFC6/7 SAM_F0, or F0CLR/F0SET
* $FFC8/9 SAM_F1, or F1CLR/F1SET
* $FFCA/B SAM_F2, or F2CLR/F2SET
* $FFCC/D SAM_F3, or F3CLR/F3SET
* $FFCE/F SAM_F4, or F4CLR/F4SET
* $FFD0/1 SAM_F5, or F5CLR/F5SET
* $FFD2/3 SAM_F6, or F6CLR/F6SET
* (1) These registers denote the start of the image in RAM to display in CoCo 1 and 2 text and
* graphics modes. The value in F0-F6 times 512 is the start of video RAM.
* (2) SAM_Fx are seven pairs of addresses ($F0-$F6), and poking any value to EVEN addresses
* sets bit Fx off (0) in Video Display Gen
SAM_Page_Select             EQU $FFC6
SAM_Page_Select_F0_CLR      EQU SAM_Page_Select
SAM_Page_Select_F0_SET      EQU SAM_Page_Select+1
SAM_Page_Select_F1_CLR      EQU SAM_Page_Select+2
SAM_Page_Select_F1_SET      EQU SAM_Page_Select+3
SAM_Page_Select_F2_CLR      EQU SAM_Page_Select+4
SAM_Page_Select_F2_SET      EQU SAM_Page_Select+5
SAM_Page_Select_F3_CLR      EQU SAM_Page_Select+6
SAM_Page_Select_F3_SET      EQU SAM_Page_Select+7
SAM_Page_Select_F4_CLR      EQU SAM_Page_Select+8
SAM_Page_Select_F4_SET      EQU SAM_Page_Select+9
SAM_Page_Select_F5_CLR      EQU SAM_Page_Select+10
SAM_Page_Select_F5_SET      EQU SAM_Page_Select+11
SAM_Page_Select_F6_CLR      EQU SAM_Page_Select+12
SAM_Page_Select_F6_SET      EQU SAM_Page_Select+13
*****************************************************
* SAM Page Select Reg-SAMPAG CoCo 1/2/3
* $FFD4-$FFD5
* $FFD4 Any write sets page #1 P1 control bit to 0, 0 = normal
* $FFD5 Any write sets page #1 P1 control bit to 1
* (1) page register MPU addresses $0000-$7FFF, apply page
SAM_Page_Select_Reg_P1_CLR  EQU $FFD4
SAM_Page_Select_Reg_P1_SET  EQU $FFD5
*****************************************************
SetSAMbits:
        RORA            ; Move bit 0 to the carry flag
        BCS     SetSAM  ; If it's a 1 then write to Set address
        STA     ,X      ; Write to Clear byte
        BRA     >       ; skip ahead
SetSAM  STA     1,X     ; Write to the Set byte
!       LEAX    2,X     ; move to the next byte set
        DECB            ; Decrement the counter
        BNE     SetSAMbits ; If not zero then keep looping
        RTS

* Code module vidset2.asm
* Setting CoCo 1/2 hires graphics modes
* Normal start of text screen 			$0400
* Preferred start of 1st graphics screen page	$0E00
*

;PMODE	  	RMB  1		* PMODE value
;Screen_Number	FCB  0		* Screen number to start at
;HORBYT		RMB  1		* Number of bytes per horizontal line
PageSize	RMB  1		* MSB of the Size of the screen page
GModePage       FCB  0		* Graphics mode page # (zero based, although BASIC uses 1 based)
;FORCOL		FCB  1		* Foreground color (default to 1)
;BAKCOL		RMB  1		* Background color
BEGGRP		RMB  2		* Start address of the screen page
;ENDGRP		RMB  2		* End address of the screen page
CSSVAL		RMB  1		* CSS value
LineColour      RMB  1          * Colour value for the Line command

; Variables
x0              RMB 2
y0              RMB 2
decision        RMB 2
x_Center        RMB 2
y_Center        RMB 2
radius          RMB 2

; LINE Variables
stepY      RMB    2
stepX      RMB    2
startX     RMB    2
startY     RMB    2
endX       RMB    2
endY       RMB    2
deltaX     RMB    2
deltaY     RMB    2
error0     RMB    2
error2     RMB    2

BoxStartY       RMB     2
BoxStartX       RMB     2
BoxEndY         RMB     2
BoxEndX         RMB     2

* Don't change the order of PaintY & currentX, keep them together as they get loaded as LDD at times
PaintY          RMB     2
currentX        RMB     2
Destination     RMB     1       ; New Colour to paint for the paint command
SourceColour    RMB     1       ; Border Colour for the Paint Command
PaintStack      RMB     2

FALSE           EQU     0
TRUE            EQU     -1
ScreenWidth     RMB     2
ScreenHeight    RMB     2
spanAbove       RMB     2
spanBelow       RMB     2

***********************************************************
* Set Hires Screen Resolution and the number of Colours
*
* Bit Pattern   Rows Displayed
*    x00xxxxx   192
*    x01xxxxx   200
*    x10xxxxx   *zero/infinite lines on screen (undefined)
*    x11xxxxx   225
* Bit Pattern   Bytes/Row (Graphics)
*    xxx000xx   16
*    xxx001xx   20
*    xxx010xx   32
*    xxx011xx   40
*    xxx100xx   64
*    xxx101xx   80   320 4 Colours 01
*    xxx110xx   128
*    xxx111xx   160
* Bit Pattern   Colours     Pixels/Byte
*    xxxxxx00   2           8
*    xxxxxx01   4           4
*    xxxxxxl0   16          2
*    xxxxxx11   Undefined   Undefined
***********************************************************
Hires_Graphic_100    EQU     %00000001    ;   64x192x 4, $0C00 (3072)	
Hires_Graphic_101    EQU     %00100001    ;   64x200x 4, $0C80 (3200)	
Hires_Graphic_102    EQU     %01100001    ;   64x225x 4, $0E10 (3600)	
Hires_Graphic_103    EQU     %00001010    ;   64x192x16, $1800 (6144)	
Hires_Graphic_104    EQU     %00101010    ;   64x200x16, $1900 (6400)	
Hires_Graphic_105    EQU     %01101010    ;   64x225x16, $1C20 (7200)	
Hires_Graphic_106    EQU     %00000101    ;   80x192x 4, $0F00 (3840)	
Hires_Graphic_107    EQU     %00100101    ;   80x200x 4, $0FA0 (4000)	
Hires_Graphic_108    EQU     %01100101    ;   80x225x 4, $1194 (4500)	
Hires_Graphic_109    EQU     %00001110    ;   80x192x16, $1E00 (7680)	
Hires_Graphic_110    EQU     %00101110    ;   80x200x16, $1F40 (8000)	
Hires_Graphic_111    EQU     %01101110    ;   80x225x16, $2328 (9000)	
Hires_Graphic_112    EQU     %00000000    ;  128x192x 2, $0C00 (3072)	
Hires_Graphic_113    EQU     %00100000    ;  128x200x 2, $0C80 (3200)	
Hires_Graphic_114    EQU     %01100000    ;  128x225x 2, $0E10 (3600)	
Hires_Graphic_115    EQU     %00001001    ;  128x192x 4, $1800 (6144)	
Hires_Graphic_116    EQU     %00101001    ;  128x200x 4, $1900 (6400)	
Hires_Graphic_117    EQU     %01101001    ;  128x225x 4, $1C20 (7200)	
Hires_Graphic_118    EQU     %00010010    ;  128x192x16, $3000 (12288)	
Hires_Graphic_119    EQU     %00110010    ;  128x200x16, $3200 (12800)	
Hires_Graphic_120    EQU     %01110010    ;  128x225x16, $3840 (14400)	
Hires_Graphic_121    EQU     %00000100    ;  160x192x 2 (viewable) really 128x192, $0C00 (3072)	* Special mode that repeats the left 4 bytes on the right side of the screen
Hires_Graphic_122    EQU     %00100100    ;  160x200x 2 (viewable) really 128x200, $0C80 (3200)	* Special mode that repeats the left 4 bytes on the right side of the screen
Hires_Graphic_123    EQU     %01100100    ;  160x225x 2 (viewable) really 128x225, $0E10 (3600)	* Special mode that repeats the left 4 bytes on the right side of the screen
Hires_Graphic_124    EQU     %00001101    ;  160x192x 4, $1E00 (7680)	
Hires_Graphic_125    EQU     %00101101    ;  160x200x 4, $1F40 (8000)	
Hires_Graphic_126    EQU     %01101101    ;  160x225x 4, $2328 (9000)	
Hires_Graphic_127    EQU     %00010110    ;  160x192x16, $3C00 (15360)	
Hires_Graphic_128    EQU     %00110110    ;  160x200x16, $3E80 (16000)	
Hires_Graphic_129    EQU     %01110110    ;  160x225x16, $4650 (18000)	
Hires_Graphic_130    EQU     %00001000    ;  256x192x 2, $1800 (6144)	
Hires_Graphic_131    EQU     %00101000    ;  256x200x 2, $1900 (6400)	
Hires_Graphic_132    EQU     %01101000    ;  256x225x 2, $1C20 (7200)	
Hires_Graphic_133    EQU     %00010001    ;  256x192x 4, $3000 (12288)	
Hires_Graphic_134    EQU     %00110001    ;  256x200x 4, $3200 (12800)	
Hires_Graphic_135    EQU     %01110001    ;  256x225x 4, $3840 (14400)	
Hires_Graphic_136    EQU     %00011010    ;  256x192x16, $6000 (24576)	
Hires_Graphic_137    EQU     %00111010    ;  256x200x16, $6400 (25600)	
Hires_Graphic_138    EQU     %01111010    ;  256x225x16, $7080 (28800)	
Hires_Graphic_139    EQU     %00001100    ;  320x192x 2, $1E00 (7680)	
Hires_Graphic_140    EQU     %00101100    ;  320x200x 2, $1F40 (8000)	
Hires_Graphic_141    EQU     %01101100    ;  320x225x 2, $2328 (9000)	
Hires_Graphic_142    EQU     %00010101    ;  320x192x 4, $3C00 (15360)	
Hires_Graphic_143    EQU     %00110101    ;  320x200x 4, $3E80 (16000)	
Hires_Graphic_144    EQU     %01110101    ;  320x225x 4, $4650 (18000)	
Hires_Graphic_145    EQU     %00011110    ;  320x192x16, $7800 (30720)	
Hires_Graphic_146    EQU     %00111110    ;  320x200x16, $7D00 (32000)	
Hires_Graphic_147    EQU     %01111110    ; 320x225x16, $8CA0 (36000)	
Hires_Graphic_148    EQU     %00010000    ;  512x192x 2, $3000 (12288)	
Hires_Graphic_149    EQU     %00110000    ;  512x200x 2, $3200 (12800)	
Hires_Graphic_150    EQU     %01110000    ;  512x225x 2, $3840 (14400)	
Hires_Graphic_151    EQU     %00011001    ;  512x192x 4, $6000 (24576)	
Hires_Graphic_152    EQU     %00111001    ;  512x200x 4, $6400 (25600)	
Hires_Graphic_153    EQU     %01111001    ;  512x225x 4, $7080 (28800)	
Hires_Graphic_154    EQU     %00010100    ;  640x192x 2, $3C00 (15360)	
Hires_Graphic_155    EQU     %00110100    ;  640x200x 2, $3E80 (16000)	
Hires_Graphic_156    EQU     %01110100    ;  640x225x 2, $4650 (18000)	
Hires_Graphic_157    EQU     %00011101    ;  640x192x 4, $7800 (30720)	
Hires_Graphic_158    EQU     %00111101    ;  640x200x 4, $7D00 (32000)	
Hires_Graphic_159    EQU     %01111101    ;  640x225x 4, $8CA0 (36000)	
Hires_Graphic_160    EQU     %00011000    ; 1024x192x 2, $6000 (24576)	
Hires_Graphic_161    EQU     %00111000    ; 1024x200x 2, $6400 (25600)	
Hires_Graphic_162    EQU     %01111000    ; 1024x225x 2, $7080 (28800)	
Hires_Graphic_163    EQU     %00011100    ; 1280x192x 2, $7800 (30720)	
Hires_Graphic_164    EQU     %00111100    ; 1280x200x 2, $7D00 (32000)	
Hires_Graphic_165    EQU     %01111100    ; 1280x225x 2, $8CA0 (36000)	