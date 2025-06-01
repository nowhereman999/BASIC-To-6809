




        PRAGMA  autobranchlength   ; Tell LWASM to automatically use long branches if the short branch is too small, see compiler docs for option -b1 to make this work properly
        ORG     $3E00         ; Program code starts here
        SETDP   $3E           ; Direct page is setup here
CoCoHardware    RMB     1     ; CoCoHardware Desriptor byte
; Bit 0 is the Computer Type, 0 = CoCo 1 or CoCo 2, 1 = CoCo 3
; Bit 7 is the CPU type,      0 = 6809, 1 = 6309
Seed1           RMB     1     ; Random number seed location
Seed2           RMB     1     ; Random number seed location
RNDC            RMB     1     ; Used by Random number generator
RNDX            RMB     1     ; Used by Random number generator
_Var_Timer      RMB     2     ; TIMER value
StartClearHere:
; Temporary Numbers:
_Var_PF00    RMB     2
_Var_PF01    RMB     2
_Var_PF02    RMB     2
_Var_PF03    RMB     2
_Var_PF04    RMB     2
_Var_PF05    RMB     2
_Var_PF06    RMB     2
_Var_PF07    RMB     2
_Var_PF08    RMB     2
_Var_PF09    RMB     2
_Var_PF10    RMB     2
Temp1           RMB     1     ; Temporary byte used for many routines
Temp2           RMB     1     ; Temporary byte used for many routines
Temp3           RMB     1     ; Temporary byte used for many routines
Temp4           RMB     1     ; Temporary byte used for many routines
Denominator     RMB     2     ; Denominator, used in division
Numerator       RMB     2     ; Numerator, used in division
DATAPointer     RMB     2     ; Variable that points to the current DATA location
_NumVar_IFRight RMB     2     ; Temp bytes for IF Compares
GraphicCURPOS   RMB     2     ; Reserve RAM for the Graphics Cursor
; Floating Point Variables Used: 0 
; Numeric Variables Used: 15 
_Var_HiScore    RMB     2
_Var_PlayerScore    RMB     2
_Var_Level    RMB     2
_Var_BallCount    RMB     2
_Var_BlockCount    RMB     2
_Var_y    RMB     2
_Var_x    RMB     2
_Var_PaddleX    RMB     2
_Var_PaddleY    RMB     2
_Var_BallX    RMB     2
_Var_BallY    RMB     2
_Var_BallXD    RMB     2
_Var_Speed    RMB     2
_Var_BallYD    RMB     2
EveryCasePointer  RMB   2     ; Pointer at the table to keep track of the CASE/EVERYCASE Flags
EveryCaseStack  RMB     10*2  ; Space Used for nested Cases
SoundTone       RMB     1     ; SOUND Tone value
SoundDuration   RMB     2     ; SOUND Command duration value
CASFLG          RMB     1     ; Case flag for keyboard output $FF=UPPER (normal), 0=LOWER
OriginalIRQ     RMB     3     ; We save the original branch and location of the IRQ here, restored before we exit
EndClearHere:
PLAYFIELD   EQU     0                              
Scrolling   EQU     0                              
VideoRamBlock           FCB     %00000000       ; Set default to 0 Meg to 0.5 Meg location                              
VerticalPosition        FDB     $0000           ; Offset                              
HorizontalPosition      FCB     %00000000       ; Bit 7 set = Horizontal scrolling enabled                              
; Sound and Timer 60hz IRQ                               
BASIC_IRQ:                              
        LDA     $FF03         ; CHECK FOR 60HZ INTERRUPT
        BPL     Not60Hz       ; RETURN IF 63.5 MICROSECOND INTERRUPT
        LDA     $FF02         ; RESET PIA0, PORT B INTERRUPT FLAG
        LDX     SoundDuration ; Get the new Sound duration value
        BEQ     >             ; RETURN IF TIMER = 0
        LEAX    -1,X          ; DECREMENT TIMER IF NOT = 0
        STX     SoundDuration ; Save the new Sound duration value
!       INC     _Var_Timer+1  ; Increment the LSB of the Timer Value
        BNE     Not60Hz       ; Skip ahead if not zero
        INC     _Var_Timer    ; Increment the MSB of the Timer Value
Not60Hz RTI                   ; RETURN FROM INTERRUPT
ClearHere2nd:
_StrVar_PF00    RMB     256     ; Temp String Variable
_StrVar_PF01    RMB     256     ; Temp String Variable
_StrVar_IFRight    RMB     256     ; Temp String Variable for IF Compares
; String Variables Used: 1 
_StrVar_i                              
        RMB     1             ; String Variable i length (0 to 255) initialized to 0
        RMB     255           ; 255 bytes available for string variable i
; Numeric Arrays Used: 0 
; String Arrays Used: 0 
EndClearHere2nd:
; General Commands Used: 29 
; '
; GMODE
; CPUSPEED
; SPRITE_LOAD
; GCLS
; SCREEN
; LINE
; GOSUB
; FOR
; TO
; STEP
; NEXT
; LOCATE
; PRINT
; IF
; THEN
; SOUND
; END
; GOTO
; SELECT
; CASE
; ELSE
; RETURN
; SPRITE
; BACKUP
; SHOW
; WAIT
; VBL
; ERASE
; Numeric Commands Used: 2 
; JOYSTK
; POINT
; String Commands Used: 3 
; TRIM$
; STR$
; INKEY$
; Section of necessary included code:
; Adding the Compiled Sprites and pointers...
GmodeBytesPerRow EQU     32        ; # of bytes per graphics row, used by the sprite rendering code                              
ScreenSize       EQU     6144        ; Size of a graphics screen                              
PixelsMaxX       EQU     127        ; Screen width Max from 0 to this value                              
NumberOfColours  EQU     4        ; Number of Colours on this screen                              
Artifacting      EQU     0         ; Not using Artifact colours                              
        INCLUDE     ./BreakOutBall.asm
        INCLUDE     ./BreakOutPaddle.asm
SpriteDrawTable:                              
        FDB     BreakOutBall_Draw   ; Points to the Sprite Drawing Table (in the compiled sprite.asm file)
        FDB     BreakOutPaddle_Draw   ; Points to the Sprite Drawing Table (in the compiled sprite.asm file)
SpriteBackupTable:                              
        FDB     Backup_BreakOutBall   ; Address of the Make Backup code
        FDB     Backup_BreakOutPaddle   ; Address of the Make Backup code
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
SpriteRestoreTable:                              
        FDB     Restore_BreakOutBall_0   ; Address of the restore code Buffer 0
        FDB     Restore_BreakOutBall_1   ; Address of the restore code Buffer 1
        FDB     Restore_BreakOutPaddle_0   ; Address of the restore code Buffer 0
        FDB     Restore_BreakOutPaddle_1   ; Address of the restore code Buffer 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        INCLUDE     ./Basic_Includes/GraphicCommands/GraphicVariables.asm
        INCLUDE     ./Basic_Includes/GraphicCommands/FG6C/FG6C_Main.asm
        INCLUDE     ./Basic_Includes/GraphicCommands/FG6C/FG6C_Line.asm
        INCLUDE     ./Basic_Includes/GraphicCommands/FG6C/FG6C_Print_Graphic_Screen.asm
        INCLUDE     ./Basic_Includes/GraphicCommands/FG6C/FG6C_Locate.asm
        INCLUDE     ./Basic_Includes/GraphicCommands/FG6C/Graphic_Screen_Fonts/CoCoT1_B0_F2.asm
        INCLUDE     ./Basic_Includes/Sound.asm
        INCLUDE     ./Basic_Includes/Audio_Muxer.asm
        INCLUDE     ./Basic_Includes/D_to_String.asm
        INCLUDE     ./Basic_Includes/Inkey.asm
        INCLUDE     ./Basic_Includes/Joystick.asm
        INCLUDE     ./Basic_Includes/Equates.asm
        INCLUDE     ./Basic_Includes/Print.asm
        INCLUDE     ./Basic_Includes/Print_Serial.asm
        INCLUDE     ./Basic_Includes/DHex_to_String.asm
        INCLUDE     ./Basic_Includes/Mulitply16x16.asm
        INCLUDE     ./Basic_Includes/Divide16with16.asm
        INCLUDE     ./Basic_Includes/SquareRoot.asm
        INCLUDE     ./Basic_Includes/CPUSpeed.asm
        INCLUDE     ./Basic_Includes/GraphicCommands/SpriteHandler.asm
* Main Program
START:
        PSHS    CC,D,DP,X,Y,U ; Save the original BASIC Register values
        STS     RestoreStack+2   ; save the original BASIC stack pointer value (try to Return at the end of the program) (self modify code)
        LDS     #$0400        ; Set up the stack pointer
        ORCC    #$50          ; Turn off the interrupts
        LDA     #$3E          
        TFR     A,DP          ; Setup the Direct page to use our variable location
* Enable 6 Bit DAC output                              
        LDA     $FF23         ; * PIA1_Byte_3_IRQ_Ct_Snd * $FF23 GET PIA
        ORA     #%00001000    ; * SET 6-BIT SOUND ENABLE
        STA     $FF23         ; * PIA1_Byte_3_IRQ_Ct_Snd * $FF23 STORE
        LDD     #128          ; Set D to the middle of the screen
        STD     endX          ; Save as previous end position
        LDD     #96           ; Set D to the middle of the screen
        STD     endY          ; Save as the previous end position
        LDD     #$0E00        ; Set D to the top left of the screen
        STD     GraphicCURPOS ; Set the graphics cursor to the top left corner
        BRA     SkipClear     ; On startup skip ahead and do a BSR to this section to clear the variables, as CLEAR will use this code
ClearVariables:                              
        LDX     #StartClearHere   ; Set the start address of the variables that will be cleared to zero when the program starts
        CLRA                  ; Clear Accumulator A
!       STA     ,X+           ; Clear the variable space, move pointer forward
        CMPX    #EndClearHere ; Compare the current address to the end of the variables that will be cleared to zero when the program starts
        BNE     <             ; Loop until all cleared
        LDX     #ClearHere2nd ; Set the start address of the variables that will be cleared to zero when the program starts
        CLRA                  ; Clear Accumulator A
!       STA     ,X+           ; Clear the variable space, move pointer forward
        CMPX    #EndClearHere2nd   ; Compare the current address to the end of the variables that will be cleared to zero when the program starts
        BNE     <             ; Loop until all cleared
        LDD     #DataStart    ; Get the Address where DATA starts
        STD     DATAPointer   ; Save it in the DATAPointer variable
        LDD     #EveryCaseStack-2   ; Table for nested CASE's, -2 because we add 2 everytime we come across a SELECT CASE/EVERYCASE
        STD     EveryCasePointer   ; Set the CASEpointer for keeping track of nested SELECT CASE commands
        RTS                   ; Return from clearing the variables
SkipClear:                              
        BSR     ClearVariables   ; Go clear the all the variables
        DEC     CASFLG        ; set the case flag to $FF = Normal uppercase
        LDD     >$0112        ; Get the Extended BASIC's TIMER value
        STD     _Var_Timer    ; Use Basic's Timer as a starting point for the TIMER value, just in case someone uses it for Randomness
        STD     Seed1         ; Save TIMER value as the Random number seed value
* Let's detect the CPU type:
        LDX     #$8000        ; X = $8000
        TFR     X,A           ; If it's 6809 then A will equal $00, if it's a 6309 then A will now equal $80
* Let's detect the CoCo version:
        LDX     $FFFE         ; Get the RESET location
        CMPX    #$8C1B        ; Check if it's a CoCo 3
        BNE     SaveCoCo1     ; Setup IRQ, using CoCo 1 IRQ Jump location
        ORA     #%00000001    ; If it's CoCo 3 then we set bit 0 of the CoCoHardware Desriptor byte
        LDX     #$FEF7        ; X = Address for the COCO 3 IRQ JMP
        LDY     #$FEFD        ; Y = Address for the COCO 3 NMI JMP
        BRA     >             ; Skip ahead
SaveCoCo1                              
        LDX     #$010C        ; X = Address for the COCO 1 IRQ JMP
        LDY     #$0109        ; Y = Address for the COCO 1 NMI JMP
!       STA     CoCoHardware  ; Save the CoCoHardware Desriptor byte
        LDU     #OriginalIRQ  ; U=Address of the IRQ
        LDA     ,X            ; A = Branch Instruction
        STA     ,U            ; Save Branch Instruction
        LDD     1,X           ; D = Address
        STD     1,U           ; Backup the Address of the IRQ
        CLRB                  ; B=0, make the CPU wus max speed
        JSR     SetCPUSpeedB  ; Save max speed and set the CPU to Max speed it can handle
        LDB     #$7E          ; JMP instruction
        STB     ,X            ; A = JMP Instruction
        LDU     #BASIC_IRQ    ; U=Address of our IRQ
        STU     1,X           ; U=Address of the IRQ
        LDA     #$3B          ; RTI instruction
        STA     $010F         ; Save instruction for the FIRQ CoCo1
* This is where we enable the IRQ                              
        ANDCC   #%11101111    ; = %11101111 this will Enable the IRQ to start
; *** User's Program code starts here ***                              
; '  compileoptions -fCoCoT1_B0_F2 -k -b0 
; '  -b1 optimize the bracnhes 
; GMODE 15,1'  128x192x4 - Set Max Graphics Pages 
        LDD     #1            
        STB     GModePage     ; Save the screen Page #
        BNE     >             ; If not the first page then go calc where to set the graphics page viewer
        LDD     #$0E00        ; A = the location in RAM to start the graphics screen
        BRA     @UpdateScreenStart   ; Go update the screen start location
!       LDX     #$1800        ; X = the screen size
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        ADDD    #$0E00        ; D = Screen Page + Screen start location
@UpdateScreenStart                      
        STD     BEGGRP        ; Update the Screen starting location

; GMODE 15,0'  128x192x4 
        LDD     #0            
        STB     GModePage     ; Save the screen Page #
        BNE     >             ; If not the first page then go calc where to set the graphics page viewer
        LDD     #$0E00        ; A = the location in RAM to start the graphics screen
        BRA     @UpdateScreenStart   ; Go update the screen start location
!       LDX     #$1800        ; X = the screen size
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        ADDD    #$0E00        ; D = Screen Page + Screen start location
@UpdateScreenStart                      
        STD     BEGGRP        ; Update the Screen starting location

; CPUSPEED 1'  CPU speed , if not 1 , 2 or 3 it is max speed 
        LDD     #1            
        JSR     SetCPUSpeedB  ; Go set the speed of the CPU to B
; SPRITE_LOAD "BreakOutBall.asm",0
; SPRITE_LOAD "BreakOutPaddle.asm",1
; HiScore=300
        LDD     #300          ; Since we don't have any variables or numeric commands, this is the calculated value
        STD     _Var_HiScore  ; Save Numeric variable
_LStartNewGame
; GCLS 0
        LDD     #0            
        JSR     GCLS_FG6C     ; Go colour the screen with the colour in B
; SCREEN 1,0
        LDB     $FF02         ; Reset Vsync flag
!       LDB     $FF03         ; See if Vsync has occurred yet
        BPL     <             ; If not then keep looping, until the Vsync occurs
        LDD     #1            
        PSHS    B             ; Save Screen Mode # on the stack
        LDD     #0            
        TSTB                  ; Test B
        BEQ     >             ; IF B = 0, use B as is
        LDB     #%00001000    ; ELSE make B = 8
!       STB     CSSVAL        ; Save the CSSVAL for setting the VDG CSS settings
        PULS    B             ; Get the Screen Mode off the stack
        TSTB                  ; Test B
        BNE     @DoGraphicMode   ; Skip ahead if graphics mode requested
        LDX     #$0400        ; Text screen starts here
        STX     BEGGRP        ; Update the Screen starting location
        LDA     #$0F          ; $0F Back to Text Mode for the CoCo 3
        STA     $FF9C         ; Neccesary for CoCo 3 GIME to use this mode
        LDA     #Internal_Alphanumeric   ; A = Text mode requested
        BRA     >             
@DoGraphicMode:                      
        CLRA                  ; D=B
        LDB     GModePage     ; Get the screen Page #
        BNE     @Skip1        ; If not the first page then go calc where to set the graphics page viewer
        LDD     #$E00         ; A = the location in RAM to start the graphics screen
@Skip1  LDX     #$1800        ; X = the screen size
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        ADDD    #$0E00        ; D = Screen Page + Screen start location
@UpdateScreenStart                      
        STD     BEGGRP        ; Update the Screen starting location
        LDA     #Full_graphic_6_C   ; A = Graphic mode requested
!       ORA     CSSVAL        ; Add in the colour select value into A
        JSR     SetGraphicModeA   ; Go setup the mode
        LDA     BEGGRP        ; Update the Screen starting location
        LSRA                  ; Divide by 2 - 512 bytes per start location
        JSR     SetGraphicsStartA   ; Go set the address of the screen
@Done                         

; PlayerScore=0
        LDD     #0            ; Since we don't have any variables or numeric commands, this is the calculated value
        STD     _Var_PlayerScore   ; Save Numeric variable
; Level=1
        LDD     #1            ; Since we don't have any variables or numeric commands, this is the calculated value
        STD     _Var_Level    ; Save Numeric variable
; BallCount=3
        LDD     #3            ; Since we don't have any variables or numeric commands, this is the calculated value
        STD     _Var_BallCount   ; Save Numeric variable
; '  Draw border lines 
; LINE (0,10)-(127,10),2,0,0
        LDD     #0            
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     #10           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #127          
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     #10           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #2            
        STB     LineColour    ; Save the Colour value
        JSR     LINE_FG6C     ; Go draw foreground colour line

; LINE (63,0)-(63,10),2,0,0
        LDD     #63           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     #0            
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #63           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     #10           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #2            
        STB     LineColour    ; Save the Colour value
        JSR     LINE_FG6C     ; Go draw foreground colour line

; LINE (0,11)-(0,191),2,0,0
        LDD     #0            
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     #11           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #0            
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     #191          
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #2            
        STB     LineColour    ; Save the Colour value
        JSR     LINE_FG6C     ; Go draw foreground colour line

; LINE (127,11)-(127,191),2,0,0
        LDD     #127          
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     #11           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #127          
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     #191          
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #2            
        STB     LineColour    ; Save the Colour value
        JSR     LINE_FG6C     ; Go draw foreground colour line

; GOSUB DrawScore
        BSR     _LDrawScore   ; GOSUB DrawScore
; '  Draw the bricks 
_LDrawBricks
; BlockCount=0
        LDD     #0            ; Since we don't have any variables or numeric commands, this is the calculated value
        STD     _Var_BlockCount   ; Save Numeric variable
; FOR y=40TO 40+Level*4STEP 4
        LDD     #40           ; Since we don't have any variables or numeric commands, this is the calculated value
        STD     _Var_y        ; Save Numeric variable
        ROLA                  ; Move sign bit to the carry
        ROL     ,-S           ; Save the Start sign bit on the stack
        LDD     #40           
        STD     _Var_PF00     
        LDD     _Var_Level    
        STD     _Var_PF01     
        LDD     #4            
        STD     _Var_PF02     
        LDD     _Var_PF01     
        LDX     _Var_PF02     
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        STD     _Var_PF01     
        LDD     _Var_PF00     
        ADDD    _Var_PF01     
        STD     FOR_Check_01+2   ; Save the value to compare with (self mod below)
        ROLA                  ; Move sign bit to the carry
        ROL     ,S            ; Save the End sign bit on the stack
        LDD     #4            
        STD     FOR_ADD_01+1  ; Save the value to ADDD for each FOR/NEXT loop (self mod below)
        ROLA                  ; Move sign bit to the carry
        LDA     ,S+           ; Get the sign bits into A and fix the stack
        ROLA                  ; Save the STEP sign bit in A
        ANDA    #%00000111    ; Get only the bits we care about
        BNE     >             ; If it's not zero thenskip ahead
        LDD     #$1022        ; opcode for LBHI - FOR X=10 to 1000 Step 1
        BRA     @ForSelfMod   ; Go save opcode in the FOR compare loop
!       LDB     #$2E          ; Default is BGT opcode
        RORA                  ; Move step sign into the carry bit
        SBCB    #$00          ; B=B- carry bit, if carry is a 1 then opcode will be BLT
        LDA     #$10          ; Make the opcode a Long branch
@ForSelfMod                      
        STD     FOR_Check_01+4   ; Save the BRANCH opcode (self mod below)
        BRA     @SkipFirst    ; Skip past the check, the first time
ForLoop_01                      ; Start of FOR Loop
        LDD     _Var_y        ; Get the varible needed for this NEXT command
FOR_ADD_01                      
        ADDD    #$FFFF        ; Add this amount each iteration of the FOR loop (self modded when the FOR is setup)
        STD     _Var_y        ; Save the updated value of the numeric varible needed for this NEXT command
FOR_Check_01                      
        CMPD    #$FFFF        ; This value will be self modded to compare with when the FOR is setup
        LBGT    >NEXTDone_01  ; Branch type (LBLE/LBGE) will be changed depending on a add or subtract with each loop
@SkipFirst                      

; FOR x=1TO 126STEP 9
        LDD     #1            ; Since we don't have any variables or numeric commands, this is the calculated value
        STD     _Var_x        ; Save Numeric variable
        ROLA                  ; Move sign bit to the carry
        ROL     ,-S           ; Save the Start sign bit on the stack
        LDD     #126          
        STD     FOR_Check_02+2   ; Save the value to compare with (self mod below)
        ROLA                  ; Move sign bit to the carry
        ROL     ,S            ; Save the End sign bit on the stack
        LDD     #9            
        STD     FOR_ADD_02+1  ; Save the value to ADDD for each FOR/NEXT loop (self mod below)
        ROLA                  ; Move sign bit to the carry
        LDA     ,S+           ; Get the sign bits into A and fix the stack
        ROLA                  ; Save the STEP sign bit in A
        ANDA    #%00000111    ; Get only the bits we care about
        BNE     >             ; If it's not zero thenskip ahead
        LDD     #$1022        ; opcode for LBHI - FOR X=10 to 1000 Step 1
        BRA     @ForSelfMod   ; Go save opcode in the FOR compare loop
!       LDB     #$2E          ; Default is BGT opcode
        RORA                  ; Move step sign into the carry bit
        SBCB    #$00          ; B=B- carry bit, if carry is a 1 then opcode will be BLT
        LDA     #$10          ; Make the opcode a Long branch
@ForSelfMod                      
        STD     FOR_Check_02+4   ; Save the BRANCH opcode (self mod below)
        BRA     @SkipFirst    ; Skip past the check, the first time
ForLoop_02                      ; Start of FOR Loop
        LDD     _Var_x        ; Get the varible needed for this NEXT command
FOR_ADD_02                      
        ADDD    #$FFFF        ; Add this amount each iteration of the FOR loop (self modded when the FOR is setup)
        STD     _Var_x        ; Save the updated value of the numeric varible needed for this NEXT command
FOR_Check_02                      
        CMPD    #$FFFF        ; This value will be self modded to compare with when the FOR is setup
        LBGT    >NEXTDone_02  ; Branch type (LBLE/LBGE) will be changed depending on a add or subtract with each loop
@SkipFirst                      

; LINE (x,y)-(x+8,y+2),1,1,1
        LDD     _Var_x        
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     _Var_y        
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     _Var_x        
        ADDD    #8           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     _Var_y        
        ADDD    #2           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #1            
        STB     LineColour    ; Save the Colour value
        JSR     BoxFill_FG6C  ; Go draw foreground colour box

; BlockCount=BlockCount+1
        LDD     _Var_BlockCount   
        ADDD    #1           
        STD     _Var_BlockCount   ; Save Numeric variable
; NEXT x
        BRA     ForLoop_02    ; Goto the FOR loop
NEXTDone_02                      ; End of FOR/NEXT loop
; NEXT y
        BRA     ForLoop_01    ; Goto the FOR loop
NEXTDone_01                      ; End of FOR/NEXT loop
; '  Print the current Level 
; LOCATE 0,0
        LDD     #0            
        STD     x0            ; Save the x location
        LDD     #0            
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,"L";TRIM$(STR$(Level));
        LDA     #$4C          ; A = Byte to print, L
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        LDD     _Var_Level    
        LDX     #_StrVar_PF00 ; X points at the string we want to save our converted value of D in _StrVar_PF00
        JSR     D_to_String_at_X   ; Convert value in D to a string where X points
        LDX     #_StrVar_PF00+1   ; X points at the copy of the string we want to trim00
        LDA     -1,X          ; A = the size of original string
!       TSTA                  ; Is A zero?
        BEQ     @Done         ; If the string is blank we are done
        LDB     ,X+           ; Get a byte, and move pointer to the right
        DECA                  ; Decrement the counter
        CMPB    #$20          ; Is the byte a space?
        BEQ     <             ; Loop if so
        INCA                  ; Fix the counter
        CMPA    _StrVar_PF00  ; Compare A to the original size
        BEQ     >             ; Skip ahead if it's the same (no blanks on the left)
        LDX     #_StrVar_PF00+1   ; X points at the copy of the string we want to trim00
        LDB     _StrVar_PF00  ; B = the original size
        STA     -1,X          ; Set the size of string
        SUBB    _StrVar_PF00  ; B=B-new size
        ABX                   ; X=X+B
        LDB     _StrVar_PF00  ; B = the new size
        LDU     #_StrVar_PF00+1   ; U points at the start of the string we want to trim00
!       LDA     ,X+           ; Get a byte, and move pointer to the right
        STA     ,U+           ; Put a byte, and move pointer to the right
        DECB                  ; Decrement the counter
        BNE     <             ; Keep copying if not zero
        LDX     #_StrVar_PF00+1   ; X points at the copy of the string we want to trim00
        LDB     -1,X          ; B = the size of original string
        ABX                   ; X points at the end of the string
!       LDA     ,-X           ; Move left and Get a byte
        DECB                  ; Decrement the counter
        CMPA    #$20          ; Is the byte a space?
        BEQ     <             ; Loop if so
        INCB                  ; Fix the counter
@Done   STB     _StrVar_PF00  ; Update the new size as B

        LDU     #_StrVar_PF00 ; U points at the start of the source string
        LDB     ,U+           ; B = length of the source string, move U to the first location where source data is stored
        BEQ     Done@         ; If the length of the string is zero then don't print it (Skip ahead)
!       LDA     ,U+           ; Get a source byte
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; Decrement the counter
        BNE     <             ; Loop until all data is copied to the destination string
Done@                         

_LStartLevel
; '  Init Player Paddle 
; PaddleX=60
        LDD     #60           ; Since we don't have any variables or numeric commands, this is the calculated value
        STD     _Var_PaddleX  ; Save Numeric variable
; PaddleY=185
        LDD     #185          ; Since we don't have any variables or numeric commands, this is the calculated value
        STD     _Var_PaddleY  ; Save Numeric variable
; '  Init Ball position and movement 
; BallX=63
        LDD     #63           ; Since we don't have any variables or numeric commands, this is the calculated value
        STD     _Var_BallX    ; Save Numeric variable
; BallY=180
        LDD     #180          ; Since we don't have any variables or numeric commands, this is the calculated value
        STD     _Var_BallY    ; Save Numeric variable
; BallXD=&H100+Speed
        LDD     #256          ; Converted &H100 to 256
        ADDD    _Var_Speed   
        STD     _Var_BallXD   ; Save Numeric variable
; BallYD=0-(&H100+Speed)
        LDD     #0            
        STD     _Var_PF00     
        LDD     #256          ; Converted &H100 to 256
        STD     _Var_PF01     
        LDD     _Var_Speed    
        STD     _Var_PF02     
        LDD     _Var_PF01     
        ADDD    _Var_PF02     
        STD     _Var_PF01     
        LDD     _Var_PF00     
        SUBD    _Var_PF01     
        STD     _Var_BallYD   ; Save Numeric variable
; '  Main Game loop 
_LMainLoop
; GOSUB UpdateSprites
        BSR     _LUpdateSprites   ; GOSUB UpdateSprites
; '  Move the ball 
_LMoveBall
; BallX=BallX+(BallXD/&H100)
        LDD     _Var_BallX    
        STD     _Var_PF00     
        LDD     _Var_BallXD   
        STD     _Var_PF01     
        LDD     #256          ; Converted &H100 to 256
        STD     _Var_PF02     
        LDX     _Var_PF01     
        LDD     _Var_PF02     
        JSR     DIV16         ; Do 16 bit / 16 bit Division, D = X/D No rounding will occur
        STD     _Var_PF01     
        LDD     _Var_PF00     
        ADDD    _Var_PF01     
        STD     _Var_BallX    ; Save Numeric variable
; BallY=BallY+(BallYD/&H100)
        LDD     _Var_BallY    
        STD     _Var_PF00     
        LDD     _Var_BallYD   
        STD     _Var_PF01     
        LDD     #256          ; Converted &H100 to 256
        STD     _Var_PF02     
        LDX     _Var_PF01     
        LDD     _Var_PF02     
        JSR     DIV16         ; Do 16 bit / 16 bit Division, D = X/D No rounding will occur
        STD     _Var_PF01     
        LDD     _Var_PF00     
        ADDD    _Var_PF01     
        STD     _Var_BallY    ; Save Numeric variable
; '  Handle Player ' s Paddle 
; PaddleX=JOYSTK(0)*2
        LDD     #0            
        CMPD    #0            ; Check if the value with zero
        BGE     >             ; Check if the value is >= to 0
        CLRB                  ; Make B = 0
        BRA     @JoyNumGood   ; We have a good value for joystick number, skip ahead
!       CMPD    #3            ; Check if the value is higher than 3
        BLE     @JoyNumGood   ; If the number is <= 3 skip ahead
        LDB     #3            ; Make B = 3
@JoyNumGood                      
        JSR     JOYSTK        ; Go handle analog joystick reading return with result in D

        STD     _Var_PF00     
        LDD     #2            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        LDX     _Var_PF01     
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        STD     _Var_PaddleX  ; Save Numeric variable
; IF PaddleX<2THEN 
        LDD     #2            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_PaddleX  
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BLT     >             ; If Less than, then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _IFDone_01    ; If result is zero = FALSE then jump to END IF line
; PaddleX=1
        LDD     #1            ; Since we don't have any variables or numeric commands, this is the calculated value
        STD     _Var_PaddleX  ; Save Numeric variable
; END IF 
_IFDone_01                      ; Label: END IF
; IF PaddleX>120THEN 
        LDD     #120          
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_PaddleX  
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BGT     >             ; If Greater than, then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _IFDone_02    ; If result is zero = FALSE then jump to END IF line
; PaddleX=120
        LDD     #120          ; Since we don't have any variables or numeric commands, this is the calculated value
        STD     _Var_PaddleX  ; Save Numeric variable
; END IF 
_IFDone_02                      ; Label: END IF
; IF BallX<2ORBallX>124THEN 
        LDD     #2            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallX    
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BLT     >             ; If Less than, then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     #124          
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallX    
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BGT     >             ; If Greater than, then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        PULS    D             ; Get the Right value off the stack
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     ,S++          ; Get the Left value in D, fix the stack
        ORA     _NumVar_IFRight   ; A=A OR first byte off the Stack
        ORB     _NumVar_IFRight+1   ; D now = D OR the stack
        PSHS    D             ; Save the Result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _IFDone_03    ; If result is zero = FALSE then jump to END IF line
; '  ball has hit the edge , change X direction 
; BallXD=BallXD*-1
        LDD     _Var_BallXD   
        LDX    #-1          
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        STD     _Var_BallXD   ; Save Numeric variable
; SOUND 150,1
        LDD     #150          
        STB     SoundTone     ; Save the Tone Value
        LDD     #1            
        LDA     #$04          ; Match timing of Color BASIC
        MUL                   ; D now has the proper length
        STD     SoundDuration ; Save the length of the sound
        JSR     PlaySound     ; Go play the SOUND
; END IF 
_IFDone_03                      ; Label: END IF
; IF BallY<12THEN 
        LDD     #12           
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallY    
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BLT     >             ; If Less than, then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _IFDone_04    ; If result is zero = FALSE then jump to END IF line
; '  ball has hit the top , change Y direction 
; BallYD=BallYD*-1
        LDD     _Var_BallYD   
        LDX    #-1          
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        STD     _Var_BallYD   ; Save Numeric variable
; SOUND 150,1
        LDD     #150          
        STB     SoundTone     ; Save the Tone Value
        LDD     #1            
        LDA     #$04          ; Match timing of Color BASIC
        MUL                   ; D now has the proper length
        STD     SoundDuration ; Save the length of the sound
        JSR     PlaySound     ; Go play the SOUND
; END IF 
_IFDone_04                      ; Label: END IF
; '  Testing never die 
; '  If BallY > 180 Then 
; '  BallYD = BallYD * -1 
; '  End If 
; IF BallY>189THEN 
        LDD     #189          
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallY    
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BGT     >             ; If Greater than, then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _IFDone_05    ; If result is zero = FALSE then jump to END IF line
; '  Ball has reached the bottom of the screen 
; IF BallCount=0THEN 
        LDD     #0            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallCount   
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BEQ     >             ; If They are Equal then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _IFDone_06    ; If result is zero = FALSE then jump to END IF line
; GOTO GameOver
        BRA     _LGameOver    ; GOTO GameOver
; END IF 
_IFDone_06                      ; Label: END IF
; BallCount=BallCount-1
        LDD     _Var_BallCount   
        SUBD    #1           
        STD     _Var_BallCount   ; Save Numeric variable
; GOSUB DrawScore
        BSR     _LDrawScore   ; GOSUB DrawScore
; GOTO StartLevel
        BRA     _LStartLevel  ; GOTO StartLevel
; END IF 
_IFDone_05                      ; Label: END IF
; '  Test for paddle hit 
; IF POINT(BallX,BallY)=2ORPOINT(BallX+1,BallY)=2THEN 
        LDD     #2            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallX    
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     _Var_BallY    
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 TFR     B,A           ; Copy the Y co-ordinate to A
        PULS    B             ; Get the loction of the X co-ordinate in B
        JSR     POINT_FG6C    ; Get the Point on the FG6C screen in B
        CLRA                  ; Fix value in D so it equals B

        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BEQ     >             ; If They are Equal then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     #2            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallX    
        ADDD    #1           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     _Var_BallY    
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 TFR     B,A           ; Copy the Y co-ordinate to A
        PULS    B             ; Get the loction of the X co-ordinate in B
        JSR     POINT_FG6C    ; Get the Point on the FG6C screen in B
        CLRA                  ; Fix value in D so it equals B

        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BEQ     >             ; If They are Equal then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        PULS    D             ; Get the Right value off the stack
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     ,S++          ; Get the Left value in D, fix the stack
        ORA     _NumVar_IFRight   ; A=A OR first byte off the Stack
        ORB     _NumVar_IFRight+1   ; D now = D OR the stack
        PSHS    D             ; Save the Result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _IFDone_07    ; If result is zero = FALSE then jump to END IF line
; '  The ball has hit the paddle 
; '  Lets change the x direction based on where the ball hit the paddle 
; SELECT CASE BallX-PaddleX
        LDD     EveryCasePointer   ; Get the Flag pointer in D
        ADDD    #2            ; D=D+2, move the pointer to the next flag
        STD     EveryCasePointer   ; Save the new pointer in EveryCasePointer
        LDD     #00*$100      ; A = The flag if this is an EveryCase=1 or a CASE=0 and clear B
        STD     [EveryCasePointer]   ; Save the value pointer in the EveryCaseStack
; CASE 0
_CaseCheck_01_01                      ; Start of the next CASE
        LDD     #0            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallX    
        SUBD    _Var_PaddleX 
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BEQ     >             ; If They are Equal then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _CaseCheck_01_02   ; If result is zero = False then jump to the next case/ELSE Case or END Select
;  BallXD=0-&H180+Speed
; BallXD=0-&H180+Speed
        LDD     #0            
        SUBD    #384          ; Converted &H180 to 38
        STD     _Var_PF00     
        LDD     _Var_Speed    
        STD     _Var_PF01     
        LDD     _Var_PF00     
        ADDD    _Var_PF01     
        STD     _Var_BallXD   ; Save Numeric variable
; CASE 1
        BRA     _EndSelect_01 ; Last Case code is complete so ignore the other CASEs
_CaseCheck_01_02                      ; Start of the next CASE
        LDD     #1            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallX    
        SUBD    _Var_PaddleX 
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BEQ     >             ; If They are Equal then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _CaseCheck_01_03   ; If result is zero = False then jump to the next case/ELSE Case or END Select
;  BallXD=0-&H100+Speed
; BallXD=0-&H100+Speed
        LDD     #0            
        SUBD    #256          ; Converted &H100 to 25
        STD     _Var_PF00     
        LDD     _Var_Speed    
        STD     _Var_PF01     
        LDD     _Var_PF00     
        ADDD    _Var_PF01     
        STD     _Var_BallXD   ; Save Numeric variable
; CASE 2
        BRA     _EndSelect_01 ; Last Case code is complete so ignore the other CASEs
_CaseCheck_01_03                      ; Start of the next CASE
        LDD     #2            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallX    
        SUBD    _Var_PaddleX 
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BEQ     >             ; If They are Equal then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _CaseCheck_01_04   ; If result is zero = False then jump to the next case/ELSE Case or END Select
;  BallXD=0-&H80+Speed
; BallXD=0-&H80+Speed
        LDD     #0            
        SUBD    #128          ; Converted &H80 to 12
        STD     _Var_PF00     
        LDD     _Var_Speed    
        STD     _Var_PF01     
        LDD     _Var_PF00     
        ADDD    _Var_PF01     
        STD     _Var_BallXD   ; Save Numeric variable
; CASE 3
        BRA     _EndSelect_01 ; Last Case code is complete so ignore the other CASEs
_CaseCheck_01_04                      ; Start of the next CASE
        LDD     #3            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallX    
        SUBD    _Var_PaddleX 
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BEQ     >             ; If They are Equal then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _CaseCheck_01_05   ; If result is zero = False then jump to the next case/ELSE Case or END Select
;  BallXD=&H80+Speed
; BallXD=&H80+Speed
        LDD     #128          ; Converted &H80 to 128
        ADDD    _Var_Speed   
        STD     _Var_BallXD   ; Save Numeric variable
; CASE 4
        BRA     _EndSelect_01 ; Last Case code is complete so ignore the other CASEs
_CaseCheck_01_05                      ; Start of the next CASE
        LDD     #4            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallX    
        SUBD    _Var_PaddleX 
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BEQ     >             ; If They are Equal then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _CaseCheck_01_06   ; If result is zero = False then jump to the next case/ELSE Case or END Select
;  BallXD=&H100+Speed
; BallXD=&H100+Speed
        LDD     #256          ; Converted &H100 to 256
        ADDD    _Var_Speed   
        STD     _Var_BallXD   ; Save Numeric variable
; CASE 5
        BRA     _EndSelect_01 ; Last Case code is complete so ignore the other CASEs
_CaseCheck_01_06                      ; Start of the next CASE
        LDD     #5            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallX    
        SUBD    _Var_PaddleX 
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BEQ     >             ; If They are Equal then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _CaseCheck_01_07   ; If result is zero = False then jump to the next case/ELSE Case or END Select
;  BallXD=&H180+Speed
; BallXD=&H180+Speed
        LDD     #384          ; Converted &H180 to 384
        ADDD    _Var_Speed   
        STD     _Var_BallXD   ; Save Numeric variable
; END SELECT 
_CaseCheck_01_07                      ; No more CASEs
_EndSelect_01                      ; This is the end of Select 01
        LDD     EveryCasePointer   ; Get the Flag pointer in D
        SUBD    #2            ; D=D+2, move the pointer to the next flag
        STD     EveryCasePointer   ; Save the new pointer in EveryCasePointer
; '  Make ball go up 
; BallYD=BallYD*-1
        LDD     _Var_BallYD   
        LDX    #-1          
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        STD     _Var_BallYD   ; Save Numeric variable
; SOUND 150,1
        LDD     #150          
        STB     SoundTone     ; Save the Tone Value
        LDD     #1            
        LDA     #$04          ; Match timing of Color BASIC
        MUL                   ; D now has the proper length
        STD     SoundDuration ; Save the length of the sound
        JSR     PlaySound     ; Go play the SOUND
; GOTO MainLoop
        BRA     _LMainLoop    ; GOTO MainLoop
; END IF 
_IFDone_07                      ; Label: END IF
; '  Test for brick hit 
; IF BallYD>0THEN 
        LDD     #0            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallYD   
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BGT     >             ; If Greater than, then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _ELSE_08      ; If result is zero = FALSE then jump to ELSE/Next line
; '  Ball is moving down the screen , check the bottom of the ball 
; IF BallXD>0THEN 
        LDD     #0            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallXD   
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BGT     >             ; If Greater than, then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _ELSE_09      ; If result is zero = FALSE then jump to ELSE/Next line
; '  Ball is moving right 
; IF POINT(BallX+1,BallY+1)=1THEN 
        LDD     #1            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallX    
        ADDD    #1           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     _Var_BallY    
        ADDD    #1           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 TFR     B,A           ; Copy the Y co-ordinate to A
        PULS    B             ; Get the loction of the X co-ordinate in B
        JSR     POINT_FG6C    ; Get the Point on the FG6C screen in B
        CLRA                  ; Fix value in D so it equals B

        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BEQ     >             ; If They are Equal then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _IFDone_10    ; If result is zero = FALSE then jump to END IF line
; '  Bottom right of the ball hit 
; x=(BallX+1-1)/9*9+1
        LDD     _Var_BallX    
        ADDD    #1           
        STD     _Var_PF00     
        LDD     #1            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        SUBD    _Var_PF01     
        STD     _Var_PF00     
        LDD     #9            
        STD     _Var_PF01     
        LDX     _Var_PF00     
        LDD     _Var_PF01     
        JSR     DIV16         ; Do 16 bit / 16 bit Division, D = X/D No rounding will occur
        STD     _Var_PF00     
        LDD     #9            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        LDX     _Var_PF01     
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        STD     _Var_PF00     
        LDD     #1            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        ADDD    _Var_PF01     
        STD     _Var_x        ; Save Numeric variable
; y=((BallY+1)-40)/4*4+40
        LDD     _Var_BallY    
        ADDD    #1           
        STD     _Var_PF00     
        LDD     #40           
        STD     _Var_PF01     
        LDD     _Var_PF00     
        SUBD    _Var_PF01     
        STD     _Var_PF00     
        LDD     #4            
        STD     _Var_PF01     
        LDX     _Var_PF00     
        LDD     _Var_PF01     
        JSR     DIV16         ; Do 16 bit / 16 bit Division, D = X/D No rounding will occur
        STD     _Var_PF00     
        LDD     #4            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        LDX     _Var_PF01     
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        STD     _Var_PF00     
        LDD     #40           
        STD     _Var_PF01     
        LDD     _Var_PF00     
        ADDD    _Var_PF01     
        STD     _Var_y        ; Save Numeric variable
; GOSUB BallHit
        BSR     _LBallHit     ; GOSUB BallHit
; END IF 
_IFDone_10                      ; Label: END IF
; ELSE 
        BRA     _IFDone_09    ; Jump to END IF line
_ELSE_09                      ; If result is zero = FALSE then jump to ELSE/Next line
; '  Ball is moving left 
; IF POINT(BallX,BallY+1)=1THEN 
        LDD     #1            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallX    
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     _Var_BallY    
        ADDD    #1           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 TFR     B,A           ; Copy the Y co-ordinate to A
        PULS    B             ; Get the loction of the X co-ordinate in B
        JSR     POINT_FG6C    ; Get the Point on the FG6C screen in B
        CLRA                  ; Fix value in D so it equals B

        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BEQ     >             ; If They are Equal then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _IFDone_11    ; If result is zero = FALSE then jump to END IF line
; '  Bottom left of the ball hit 
; x=(BallX-1)/9*9+1
        LDD     _Var_BallX    
        SUBD    #1           
        STD     _Var_PF00     
        LDD     #9            
        STD     _Var_PF01     
        LDX     _Var_PF00     
        LDD     _Var_PF01     
        JSR     DIV16         ; Do 16 bit / 16 bit Division, D = X/D No rounding will occur
        STD     _Var_PF00     
        LDD     #9            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        LDX     _Var_PF01     
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        STD     _Var_PF00     
        LDD     #1            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        ADDD    _Var_PF01     
        STD     _Var_x        ; Save Numeric variable
; y=((BallY+1)-40)/4*4+40
        LDD     _Var_BallY    
        ADDD    #1           
        STD     _Var_PF00     
        LDD     #40           
        STD     _Var_PF01     
        LDD     _Var_PF00     
        SUBD    _Var_PF01     
        STD     _Var_PF00     
        LDD     #4            
        STD     _Var_PF01     
        LDX     _Var_PF00     
        LDD     _Var_PF01     
        JSR     DIV16         ; Do 16 bit / 16 bit Division, D = X/D No rounding will occur
        STD     _Var_PF00     
        LDD     #4            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        LDX     _Var_PF01     
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        STD     _Var_PF00     
        LDD     #40           
        STD     _Var_PF01     
        LDD     _Var_PF00     
        ADDD    _Var_PF01     
        STD     _Var_y        ; Save Numeric variable
; GOSUB BallHit
        BSR     _LBallHit     ; GOSUB BallHit
; END IF 
_IFDone_11                      ; Label: END IF
; END IF 
_IFDone_09                      ; Label: END IF
; ELSE 
        BRA     _IFDone_08    ; Jump to END IF line
_ELSE_08                      ; If result is zero = FALSE then jump to ELSE/Next line
; '  Ball is moving up the screen , check the top of the ball 
; IF BallXD>0THEN 
        LDD     #0            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallXD   
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BGT     >             ; If Greater than, then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _ELSE_12      ; If result is zero = FALSE then jump to ELSE/Next line
; '  Ball is moving right 
; IF POINT(BallX+1,BallY)=1THEN 
        LDD     #1            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallX    
        ADDD    #1           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     _Var_BallY    
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 TFR     B,A           ; Copy the Y co-ordinate to A
        PULS    B             ; Get the loction of the X co-ordinate in B
        JSR     POINT_FG6C    ; Get the Point on the FG6C screen in B
        CLRA                  ; Fix value in D so it equals B

        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BEQ     >             ; If They are Equal then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _IFDone_13    ; If result is zero = FALSE then jump to END IF line
; '  Top left of the ball hit 
; x=(BallX+1-1)/9*9+1
        LDD     _Var_BallX    
        ADDD    #1           
        STD     _Var_PF00     
        LDD     #1            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        SUBD    _Var_PF01     
        STD     _Var_PF00     
        LDD     #9            
        STD     _Var_PF01     
        LDX     _Var_PF00     
        LDD     _Var_PF01     
        JSR     DIV16         ; Do 16 bit / 16 bit Division, D = X/D No rounding will occur
        STD     _Var_PF00     
        LDD     #9            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        LDX     _Var_PF01     
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        STD     _Var_PF00     
        LDD     #1            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        ADDD    _Var_PF01     
        STD     _Var_x        ; Save Numeric variable
; y=(BallY-40)/4*4+40
        LDD     _Var_BallY    
        SUBD    #40          
        STD     _Var_PF00     
        LDD     #4            
        STD     _Var_PF01     
        LDX     _Var_PF00     
        LDD     _Var_PF01     
        JSR     DIV16         ; Do 16 bit / 16 bit Division, D = X/D No rounding will occur
        STD     _Var_PF00     
        LDD     #4            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        LDX     _Var_PF01     
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        STD     _Var_PF00     
        LDD     #40           
        STD     _Var_PF01     
        LDD     _Var_PF00     
        ADDD    _Var_PF01     
        STD     _Var_y        ; Save Numeric variable
; GOSUB BallHit
        BSR     _LBallHit     ; GOSUB BallHit
; END IF 
_IFDone_13                      ; Label: END IF
; ELSE 
        BRA     _IFDone_12    ; Jump to END IF line
_ELSE_12                      ; If result is zero = FALSE then jump to ELSE/Next line
; '  Ball is moving left 
; IF POINT(BallX,BallY)=1THEN 
        LDD     #1            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BallX    
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     _Var_BallY    
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 TFR     B,A           ; Copy the Y co-ordinate to A
        PULS    B             ; Get the loction of the X co-ordinate in B
        JSR     POINT_FG6C    ; Get the Point on the FG6C screen in B
        CLRA                  ; Fix value in D so it equals B

        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BEQ     >             ; If They are Equal then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _IFDone_14    ; If result is zero = FALSE then jump to END IF line
; '  Top left of the ball hit 
; x=(BallX-1)/9*9+1
        LDD     _Var_BallX    
        SUBD    #1           
        STD     _Var_PF00     
        LDD     #9            
        STD     _Var_PF01     
        LDX     _Var_PF00     
        LDD     _Var_PF01     
        JSR     DIV16         ; Do 16 bit / 16 bit Division, D = X/D No rounding will occur
        STD     _Var_PF00     
        LDD     #9            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        LDX     _Var_PF01     
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        STD     _Var_PF00     
        LDD     #1            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        ADDD    _Var_PF01     
        STD     _Var_x        ; Save Numeric variable
; y=(BallY-40)/4*4+40
        LDD     _Var_BallY    
        SUBD    #40          
        STD     _Var_PF00     
        LDD     #4            
        STD     _Var_PF01     
        LDX     _Var_PF00     
        LDD     _Var_PF01     
        JSR     DIV16         ; Do 16 bit / 16 bit Division, D = X/D No rounding will occur
        STD     _Var_PF00     
        LDD     #4            
        STD     _Var_PF01     
        LDD     _Var_PF00     
        LDX     _Var_PF01     
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        STD     _Var_PF00     
        LDD     #40           
        STD     _Var_PF01     
        LDD     _Var_PF00     
        ADDD    _Var_PF01     
        STD     _Var_y        ; Save Numeric variable
; GOSUB BallHit
        BSR     _LBallHit     ; GOSUB BallHit
; END IF 
_IFDone_14                      ; Label: END IF
; END IF 
_IFDone_12                      ; Label: END IF
; END IF 
_IFDone_08                      ; Label: END IF
; IF BlockCount=0THEN 
        LDD     #0            
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_BlockCount   
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BEQ     >             ; If They are Equal then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _IFDone_15    ; If result is zero = FALSE then jump to END IF line
; LINE (1,11)-(126,191),0,1,1'  Clear playfield area,0,0 
        LDD     #1            
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     #11           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #126          
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     #191          
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #0            
        STB     LineColour    ; Save the Colour value
        JSR     BoxFill_FG6C  ; Go draw foreground colour box

; LOCATE 5,40
        LDD     #5            
        STD     x0            ; Save the x location
        LDD     #40           
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,"You cleared";
        BSR     >             ; Skip over string value
        FCB     $59           ; Y
        FCB     $6F           ; o
        FCB     $75           ; u
        FCB     $20           ;  
        FCB     $63           ; c
        FCB     $6C           ; l
        FCB     $65           ; e
        FCB     $61           ; a
        FCB     $72           ; r
        FCB     $65           ; e
        FCB     $64           ; d
!       LDB     #11           ; Length of this string
        LDU     ,S++          ; Load U with the string start location off the stack and fix the stack
!       LDA     ,U+           ; Get the string data
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; decrement the string length counter
        BNE     <             ; If not counted down to zero then loop
; LOCATE 7,50
        LDD     #7            
        STD     x0            ; Save the x location
        LDD     #50           
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,"Level:";Level;
        BSR     >             ; Skip over string value
        FCB     $4C           ; L
        FCB     $65           ; e
        FCB     $76           ; v
        FCB     $65           ; e
        FCB     $6C           ; l
        FCB     $3A           ; :
!       LDB     #6            ; Length of this string
        LDU     ,S++          ; Load U with the string start location off the stack and fix the stack
!       LDA     ,U+           ; Get the string data
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; decrement the string length counter
        BNE     <             ; If not counted down to zero then loop
        LDD     _Var_Level    
        JSR     PRINT_D_Graphics_Screen_FG6C   ; Go print D to graphic screen
; LOCATE 3,70
        LDD     #3            
        STD     x0            ; Save the x location
        LDD     #70           
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,"Press any key";
        BSR     >             ; Skip over string value
        FCB     $50           ; P
        FCB     $72           ; r
        FCB     $65           ; e
        FCB     $73           ; s
        FCB     $73           ; s
        FCB     $20           ;  
        FCB     $61           ; a
        FCB     $6E           ; n
        FCB     $79           ; y
        FCB     $20           ;  
        FCB     $6B           ; k
        FCB     $65           ; e
        FCB     $79           ; y
!       LDB     #13           ; Length of this string
        LDU     ,S++          ; Load U with the string start location off the stack and fix the stack
!       LDA     ,U+           ; Get the string data
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; decrement the string length counter
        BNE     <             ; If not counted down to zero then loop
; LOCATE 7,80
        LDD     #7            
        STD     x0            ; Save the x location
        LDD     #80           
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,"to Start";
        BSR     >             ; Skip over string value
        FCB     $74           ; t
        FCB     $6F           ; o
        FCB     $20           ;  
        FCB     $53           ; S
        FCB     $74           ; t
        FCB     $61           ; a
        FCB     $72           ; r
        FCB     $74           ; t
!       LDB     #8            ; Length of this string
        LDU     ,S++          ; Load U with the string start location off the stack and fix the stack
!       LDA     ,U+           ; Get the string data
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; decrement the string length counter
        BNE     <             ; If not counted down to zero then loop
; LOCATE 1,90
        LDD     #1            
        STD     x0            ; Save the x location
        LDD     #90           
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,"the Next Level";
        BSR     >             ; Skip over string value
        FCB     $74           ; t
        FCB     $68           ; h
        FCB     $65           ; e
        FCB     $20           ;  
        FCB     $4E           ; N
        FCB     $65           ; e
        FCB     $78           ; x
        FCB     $74           ; t
        FCB     $20           ;  
        FCB     $4C           ; L
        FCB     $65           ; e
        FCB     $76           ; v
        FCB     $65           ; e
        FCB     $6C           ; l
!       LDB     #14           ; Length of this string
        LDU     ,S++          ; Load U with the string start location off the stack and fix the stack
!       LDA     ,U+           ; Get the string data
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; decrement the string length counter
        BNE     <             ; If not counted down to zero then loop
; GOSUB GetKey
        BSR     _LGetKey      ; GOSUB GetKey
; LINE (1,11)-(126,191),0,1,1'  Clear playfield area,0,0 
        LDD     #1            
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     #11           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #126          
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     #191          
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #0            
        STB     LineColour    ; Save the Colour value
        JSR     BoxFill_FG6C  ; Go draw foreground colour box

; Level=Level+1'  Increment the level 
        LDD     _Var_Level    
        ADDD    #1           
        STD     _Var_Level    ; Save Numeric variable
; BallCount=BallCount+1'  Extra Ball for clearing a level 
        LDD     _Var_BallCount   
        ADDD    #1           
        STD     _Var_BallCount   ; Save Numeric variable
; GOSUB DrawScore
        BSR     _LDrawScore   ; GOSUB DrawScore
; Speed=Speed+&H80'  Increase the ball speed 
        LDD     _Var_Speed    
        ADDD    #128          ; Converted &H80 to 12
        STD     _Var_Speed    ; Save Numeric variable
; GOTO DrawBricks
        BRA     _LDrawBricks  ; GOTO DrawBricks
; END IF 
_IFDone_15                      ; Label: END IF
; GOTO MainLoop
        BRA     _LMainLoop    ; GOTO MainLoop
_LGameOver
; LINE (1,11)-(126,191),0,1,1'  Clear playfield area,0,0 
        LDD     #1            
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     #11           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #126          
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     #191          
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #0            
        STB     LineColour    ; Save the Colour value
        JSR     BoxFill_FG6C  ; Go draw foreground colour box

; LOCATE 7,40
        LDD     #7            
        STD     x0            ; Save the x location
        LDD     #40           
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,"Game Over";
        BSR     >             ; Skip over string value
        FCB     $47           ; G
        FCB     $61           ; a
        FCB     $6D           ; m
        FCB     $65           ; e
        FCB     $20           ;  
        FCB     $4F           ; O
        FCB     $76           ; v
        FCB     $65           ; e
        FCB     $72           ; r
!       LDB     #9            ; Length of this string
        LDU     ,S++          ; Load U with the string start location off the stack and fix the stack
!       LDA     ,U+           ; Get the string data
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; decrement the string length counter
        BNE     <             ; If not counted down to zero then loop
; LOCATE 7,60
        LDD     #7            
        STD     x0            ; Save the x location
        LDD     #60           
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,"Level:";Level;
        BSR     >             ; Skip over string value
        FCB     $4C           ; L
        FCB     $65           ; e
        FCB     $76           ; v
        FCB     $65           ; e
        FCB     $6C           ; l
        FCB     $3A           ; :
!       LDB     #6            ; Length of this string
        LDU     ,S++          ; Load U with the string start location off the stack and fix the stack
!       LDA     ,U+           ; Get the string data
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; decrement the string length counter
        BNE     <             ; If not counted down to zero then loop
        LDD     _Var_Level    
        JSR     PRINT_D_Graphics_Screen_FG6C   ; Go print D to graphic screen
; LOCATE 3,70
        LDD     #3            
        STD     x0            ; Save the x location
        LDD     #70           
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,"With a Score";
        BSR     >             ; Skip over string value
        FCB     $57           ; W
        FCB     $69           ; i
        FCB     $74           ; t
        FCB     $68           ; h
        FCB     $20           ;  
        FCB     $61           ; a
        FCB     $20           ;  
        FCB     $53           ; S
        FCB     $63           ; c
        FCB     $6F           ; o
        FCB     $72           ; r
        FCB     $65           ; e
!       LDB     #12           ; Length of this string
        LDU     ,S++          ; Load U with the string start location off the stack and fix the stack
!       LDA     ,U+           ; Get the string data
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; decrement the string length counter
        BNE     <             ; If not counted down to zero then loop
; LOCATE 7,80
        LDD     #7            
        STD     x0            ; Save the x location
        LDD     #80           
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,"of";PlayerScore;
        LDA     #$6F          ; A = Byte to print, o
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        LDA     #$66          ; A = Byte to print, f
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        LDD     _Var_PlayerScore   
        JSR     PRINT_D_Graphics_Screen_FG6C   ; Go print D to graphic screen
; LOCATE 3,120
        LDD     #3            
        STD     x0            ; Save the x location
        LDD     #120          
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,"Press any key";
        BSR     >             ; Skip over string value
        FCB     $50           ; P
        FCB     $72           ; r
        FCB     $65           ; e
        FCB     $73           ; s
        FCB     $73           ; s
        FCB     $20           ;  
        FCB     $61           ; a
        FCB     $6E           ; n
        FCB     $79           ; y
        FCB     $20           ;  
        FCB     $6B           ; k
        FCB     $65           ; e
        FCB     $79           ; y
!       LDB     #13           ; Length of this string
        LDU     ,S++          ; Load U with the string start location off the stack and fix the stack
!       LDA     ,U+           ; Get the string data
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; decrement the string length counter
        BNE     <             ; If not counted down to zero then loop
; LOCATE 7,130
        LDD     #7            
        STD     x0            ; Save the x location
        LDD     #130          
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,"to Start";
        BSR     >             ; Skip over string value
        FCB     $74           ; t
        FCB     $6F           ; o
        FCB     $20           ;  
        FCB     $53           ; S
        FCB     $74           ; t
        FCB     $61           ; a
        FCB     $72           ; r
        FCB     $74           ; t
!       LDB     #8            ; Length of this string
        LDU     ,S++          ; Load U with the string start location off the stack and fix the stack
!       LDA     ,U+           ; Get the string data
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; decrement the string length counter
        BNE     <             ; If not counted down to zero then loop
; LOCATE 1,140
        LDD     #1            
        STD     x0            ; Save the x location
        LDD     #140          
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,"the Next Level";
        BSR     >             ; Skip over string value
        FCB     $74           ; t
        FCB     $68           ; h
        FCB     $65           ; e
        FCB     $20           ;  
        FCB     $4E           ; N
        FCB     $65           ; e
        FCB     $78           ; x
        FCB     $74           ; t
        FCB     $20           ;  
        FCB     $4C           ; L
        FCB     $65           ; e
        FCB     $76           ; v
        FCB     $65           ; e
        FCB     $6C           ; l
!       LDB     #14           ; Length of this string
        LDU     ,S++          ; Load U with the string start location off the stack and fix the stack
!       LDA     ,U+           ; Get the string data
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; decrement the string length counter
        BNE     <             ; If not counted down to zero then loop
; GOSUB GetKey
        BSR     _LGetKey      ; GOSUB GetKey
; GOTO StartNewGame
        BRA     _LStartNewGame   ; GOTO StartNewGame
_LGetKey
; i$=INKEY$
        LDX     #_StrVar_PF00 ; X is now pointing at the size of this string
        JSR     KEYIN         ; This routine Polls the keyboard to see if a key is pressed, returns with value in A, A=0 if no key is pressed
        BEQ     >             ; Write zero for the size of the string if A is zero
        LDB     #1            ; We have a keypress so set the string length to 1
        STB     ,X+           ; Save 1 for the size and move X forward to point at data
!       STA     ,X            ; Save A at X
        LDU     #_StrVar_PF00 ; U points at the start of the source string
        LDB     ,U+           ; B = length of the source string, move U to the first location where source data is stored
        LDX     #_StrVar_i    ; X points at the length of the destination string
        STB     ,X+           ; Set the size of the destination string, X now points at the beginning of the destination data
        BEQ     Done@         ; If the length of the string is zero then don't print it (Skip ahead)
!       LDA     ,U+           ; Get a source byte
        STA     ,X+           ; Write the destination byte
        DECB                  ; Decrement the counter
        BNE     <             ; Loop until all data is copied to the destination string
Done@                         

_LInkeyLoop
; i$=INKEY$
        LDX     #_StrVar_PF00 ; X is now pointing at the size of this string
        JSR     KEYIN         ; This routine Polls the keyboard to see if a key is pressed, returns with value in A, A=0 if no key is pressed
        BEQ     >             ; Write zero for the size of the string if A is zero
        LDB     #1            ; We have a keypress so set the string length to 1
        STB     ,X+           ; Save 1 for the size and move X forward to point at data
!       STA     ,X            ; Save A at X
        LDU     #_StrVar_PF00 ; U points at the start of the source string
        LDB     ,U+           ; B = length of the source string, move U to the first location where source data is stored
        LDX     #_StrVar_i    ; X points at the length of the destination string
        STB     ,X+           ; Set the size of the destination string, X now points at the beginning of the destination data
        BEQ     Done@         ; If the length of the string is zero then don't print it (Skip ahead)
!       LDA     ,U+           ; Get a source byte
        STA     ,X+           ; Write the destination byte
        DECB                  ; Decrement the counter
        BNE     <             ; Loop until all data is copied to the destination string
Done@                         

; IF i$=""THEN 
        CLR     _StrVar_PF00  ; Set size of string as zero bytes
; copying String from _StrVar_PF00 to _StrVar_IFRight
        LDU     #_StrVar_PF00 ; U points at the start of the source string
        LDB     ,U+           ; B = length of the source string, move U to the first location where source data is stored
        LDX     #_StrVar_IFRight   ; X points at the length of the destination string
        STB     ,X+           ; Set the size of the destination string, X now points at the beginning of the destination data
        BEQ     Done@         ; If B=0 then no need to copy the string
!       LDA     ,U+           ; Get a source byte
        STA     ,X+           ; Write the destination byte
        DECB                  ; Decrement the counter
        BNE     <             ; Loop until all data is copied to the destination string
Done@


        LDU     #_StrVar_i    ; U points at the start of the source string
        LDB     ,U+           ; B = length of the source string, move U to the first location where source data is stored
        LDX     #_StrVar_PF00 ; X points at the length of the destination string
        STB     ,X+           ; Set the size of the destination string, X now points at the beginning of the destination data
        BEQ     Done@         ; If B=0 then no need to copy the string
!       LDA     ,U+           ; Get a source byte
        STA     ,X+           ; Write the destination byte
        DECB                  ; Decrement the counter
        BNE     <             ; Loop until all data is copied to the destination string
Done@                         

; String _StrVar_PF00 has the left value
        LDU     #_StrVar_PF00 ; U = the Left String
        LDX     #_StrVar_IFRight   ; X = the Right String
; Checking if Strings are =
        LDB     ,U+           ; Get the length of the string, move pointer to the first byte of the string
        CMPB    ,X+           ; Are they the same length? , move pointer to the first byte of the string
        BNE     @False        ; If They are Not Equal then return a false
; If we get here then the length is the same, check if all characters are the same
        TSTB                  ; Check if the strings are empty
        BEQ     @True         ; If they are both empty they are the same
!       LDA     ,U+           ; Get a byte of the left string, move pointer forward
        CMPA    ,X+           ; Compare it with the byte of the right string, move pointer forward
        BNE     @False        ; If They are Not Equal then return a false
        DECB                  ; Decrement the counter
        BNE     <             ; Keep looping until we've compared all the bytes of both strings
; If we get here then the strings are the same
@True   LDX     #$FFFF        ; Result = -1, True
        BRA     @SaveX        ; If They are Not Equal then return a false
@False  LDX     #$0000        ; Make the Result zero, False
@SaveX  PSHS    X             ; Save the result on the stack

        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _IFDone_16    ; If result is zero = FALSE then jump to END IF line
; GOTO InkeyLoop
        BRA     _LInkeyLoop   ; GOTO InkeyLoop
; END IF 
_IFDone_16                      ; Label: END IF
; RETURN 
        RTS                   ; RETURN
_LDrawScore
; '  Players score 
; LOCATE 6,0
        LDD     #6            
        STD     x0            ; Save the x location
        LDD     #0            
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,"B";TRIM$(STR$(BallCount));
        LDA     #$42          ; A = Byte to print, B
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        LDD     _Var_BallCount   
        LDX     #_StrVar_PF00 ; X points at the string we want to save our converted value of D in _StrVar_PF00
        JSR     D_to_String_at_X   ; Convert value in D to a string where X points
        LDX     #_StrVar_PF00+1   ; X points at the copy of the string we want to trim00
        LDA     -1,X          ; A = the size of original string
!       TSTA                  ; Is A zero?
        BEQ     @Done         ; If the string is blank we are done
        LDB     ,X+           ; Get a byte, and move pointer to the right
        DECA                  ; Decrement the counter
        CMPB    #$20          ; Is the byte a space?
        BEQ     <             ; Loop if so
        INCA                  ; Fix the counter
        CMPA    _StrVar_PF00  ; Compare A to the original size
        BEQ     >             ; Skip ahead if it's the same (no blanks on the left)
        LDX     #_StrVar_PF00+1   ; X points at the copy of the string we want to trim00
        LDB     _StrVar_PF00  ; B = the original size
        STA     -1,X          ; Set the size of string
        SUBB    _StrVar_PF00  ; B=B-new size
        ABX                   ; X=X+B
        LDB     _StrVar_PF00  ; B = the new size
        LDU     #_StrVar_PF00+1   ; U points at the start of the string we want to trim00
!       LDA     ,X+           ; Get a byte, and move pointer to the right
        STA     ,U+           ; Put a byte, and move pointer to the right
        DECB                  ; Decrement the counter
        BNE     <             ; Keep copying if not zero
        LDX     #_StrVar_PF00+1   ; X points at the copy of the string we want to trim00
        LDB     -1,X          ; B = the size of original string
        ABX                   ; X points at the end of the string
!       LDA     ,-X           ; Move left and Get a byte
        DECB                  ; Decrement the counter
        CMPA    #$20          ; Is the byte a space?
        BEQ     <             ; Loop if so
        INCB                  ; Fix the counter
@Done   STB     _StrVar_PF00  ; Update the new size as B

        LDU     #_StrVar_PF00 ; U points at the start of the source string
        LDB     ,U+           ; B = length of the source string, move U to the first location where source data is stored
        BEQ     Done@         ; If the length of the string is zero then don't print it (Skip ahead)
!       LDA     ,U+           ; Get a source byte
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; Decrement the counter
        BNE     <             ; Loop until all data is copied to the destination string
Done@                         

; LOCATE 12,0
        LDD     #12           
        STD     x0            ; Save the x location
        LDD     #0            
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,TRIM$(STR$(HiScore));
        LDD     _Var_HiScore  
        LDX     #_StrVar_PF00 ; X points at the string we want to save our converted value of D in _StrVar_PF00
        JSR     D_to_String_at_X   ; Convert value in D to a string where X points
        LDX     #_StrVar_PF00+1   ; X points at the copy of the string we want to trim00
        LDA     -1,X          ; A = the size of original string
!       TSTA                  ; Is A zero?
        BEQ     @Done         ; If the string is blank we are done
        LDB     ,X+           ; Get a byte, and move pointer to the right
        DECA                  ; Decrement the counter
        CMPB    #$20          ; Is the byte a space?
        BEQ     <             ; Loop if so
        INCA                  ; Fix the counter
        CMPA    _StrVar_PF00  ; Compare A to the original size
        BEQ     >             ; Skip ahead if it's the same (no blanks on the left)
        LDX     #_StrVar_PF00+1   ; X points at the copy of the string we want to trim00
        LDB     _StrVar_PF00  ; B = the original size
        STA     -1,X          ; Set the size of string
        SUBB    _StrVar_PF00  ; B=B-new size
        ABX                   ; X=X+B
        LDB     _StrVar_PF00  ; B = the new size
        LDU     #_StrVar_PF00+1   ; U points at the start of the string we want to trim00
!       LDA     ,X+           ; Get a byte, and move pointer to the right
        STA     ,U+           ; Put a byte, and move pointer to the right
        DECB                  ; Decrement the counter
        BNE     <             ; Keep copying if not zero
        LDX     #_StrVar_PF00+1   ; X points at the copy of the string we want to trim00
        LDB     -1,X          ; B = the size of original string
        ABX                   ; X points at the end of the string
!       LDA     ,-X           ; Move left and Get a byte
        DECB                  ; Decrement the counter
        CMPA    #$20          ; Is the byte a space?
        BEQ     <             ; Loop if so
        INCB                  ; Fix the counter
@Done   STB     _StrVar_PF00  ; Update the new size as B

        LDU     #_StrVar_PF00 ; U points at the start of the source string
        LDB     ,U+           ; B = length of the source string, move U to the first location where source data is stored
        BEQ     Done@         ; If the length of the string is zero then don't print it (Skip ahead)
!       LDA     ,U+           ; Get a source byte
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; Decrement the counter
        BNE     <             ; Loop until all data is copied to the destination string
Done@                         

; LOCATE 22,0
        LDD     #22           
        STD     x0            ; Save the x location
        LDD     #0            
        STD     y0            ; Save the y location
        JSR     LOCATE_FG6C   ; Setup the location to print text on the graphics screen
; PRINT #-3,TRIM$(STR$(PlayerScore));
        LDD     _Var_PlayerScore   
        LDX     #_StrVar_PF00 ; X points at the string we want to save our converted value of D in _StrVar_PF00
        JSR     D_to_String_at_X   ; Convert value in D to a string where X points
        LDX     #_StrVar_PF00+1   ; X points at the copy of the string we want to trim00
        LDA     -1,X          ; A = the size of original string
!       TSTA                  ; Is A zero?
        BEQ     @Done         ; If the string is blank we are done
        LDB     ,X+           ; Get a byte, and move pointer to the right
        DECA                  ; Decrement the counter
        CMPB    #$20          ; Is the byte a space?
        BEQ     <             ; Loop if so
        INCA                  ; Fix the counter
        CMPA    _StrVar_PF00  ; Compare A to the original size
        BEQ     >             ; Skip ahead if it's the same (no blanks on the left)
        LDX     #_StrVar_PF00+1   ; X points at the copy of the string we want to trim00
        LDB     _StrVar_PF00  ; B = the original size
        STA     -1,X          ; Set the size of string
        SUBB    _StrVar_PF00  ; B=B-new size
        ABX                   ; X=X+B
        LDB     _StrVar_PF00  ; B = the new size
        LDU     #_StrVar_PF00+1   ; U points at the start of the string we want to trim00
!       LDA     ,X+           ; Get a byte, and move pointer to the right
        STA     ,U+           ; Put a byte, and move pointer to the right
        DECB                  ; Decrement the counter
        BNE     <             ; Keep copying if not zero
        LDX     #_StrVar_PF00+1   ; X points at the copy of the string we want to trim00
        LDB     -1,X          ; B = the size of original string
        ABX                   ; X points at the end of the string
!       LDA     ,-X           ; Move left and Get a byte
        DECB                  ; Decrement the counter
        CMPA    #$20          ; Is the byte a space?
        BEQ     <             ; Loop if so
        INCB                  ; Fix the counter
@Done   STB     _StrVar_PF00  ; Update the new size as B

        LDU     #_StrVar_PF00 ; U points at the start of the source string
        LDB     ,U+           ; B = length of the source string, move U to the first location where source data is stored
        BEQ     Done@         ; If the length of the string is zero then don't print it (Skip ahead)
!       LDA     ,U+           ; Get a source byte
        JSR     AtoGraphics_Screen_FG6C   ; Go print A to graphic screen
        DECB                  ; Decrement the counter
        BNE     <             ; Loop until all data is copied to the destination string
Done@                         

; RETURN 
        RTS                   ; RETURN
; '  Normal Sprite usage loop: 
_LUpdateSprites
; SPRITE LOCATE 0,BallX,BallY
        LDD     #0            
        PSHS    B             ; Save the sprite #
        LDD     _Var_BallX    
        PSHS    D             ; Save the x co-ordinate
        LDD     _Var_BallY    
        PSHS    D             ; Save the y co-ordinate
        JSR     SpriteLocate  ; Change the screen location of the sprite
        LEAS    5,S           ; Fix the Stack
; SPRITE BACKUP 0
        LDD     #0            
        JSR     BackupSpriteB ; Jump to code to Backup Sprite B
; SPRITE SHOW 0,0
        LDD     #0            
        PSHS    B             ; Save the Sprite #
        LDD     #0            
        PSHS    B             ; Save the frame #
        JSR     ShowSpriteFrame   ; Jump to code to change the sprite frame #
        LEAS    2,S           ; Fix the Stack
; SPRITE LOCATE 1,PaddleX,PaddleY
        LDD     #1            
        PSHS    B             ; Save the sprite #
        LDD     _Var_PaddleX  
        PSHS    D             ; Save the x co-ordinate
        LDD     _Var_PaddleY  
        PSHS    D             ; Save the y co-ordinate
        JSR     SpriteLocate  ; Change the screen location of the sprite
        LEAS    5,S           ; Fix the Stack
; SPRITE BACKUP 1
        LDD     #1            
        JSR     BackupSpriteB ; Jump to code to Backup Sprite B
; SPRITE SHOW 1,0
        LDD     #1            
        PSHS    B             ; Save the Sprite #
        LDD     #0            
        PSHS    B             ; Save the frame #
        JSR     ShowSpriteFrame   ; Jump to code to change the sprite frame #
        LEAS    2,S           ; Fix the Stack
; WAIT VBL '  This is when the actual sprite updates occur 
        JSR     DoWaitVBL     ; Wait for Vertical Blank then update the sprites
; SPRITE ERASE 1
        LDD     #1            
        JSR     EraseSpriteB  ; Jump to code to Erase SpriteB and restore it's background
; SPRITE ERASE 0
        LDD     #0            
        JSR     EraseSpriteB  ; Jump to code to Erase SpriteB and restore it's background
; RETURN 
        RTS                   ; RETURN
_LBallHit
; WAIT VBL '  Do the actual erase of the ball , so next time it will backup the empty brick location 
        JSR     DoWaitVBL     ; Wait for Vertical Blank then update the sprites
; LINE (x,y)-(x+8,y+2),0,1,1'  Erase the brick,0,0 
        LDD     _Var_x        
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     _Var_y        
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     _Var_x        
        ADDD    #8           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 127
        CLRB                  ; Make value zero
        BRA     @SaveB0       ; Save B on the stack
!       CMPB    #127          ; Check if B is > than 127
        BLS     @SaveB0       ; If value is 127 or < then skip ahead
        LDB     #127          ; Make the max size 127
@SaveB0 PSHS    B             ; Save the loction of the X co-ordinate
        LDD     _Var_y        
        ADDD    #2           
        TSTA                  ; Check if D is a negative
        BPL     >             ; If value is 0 or more then check if we are > 191
        CLRB                  ; Make value zero
        BRA     @SaveB1       ; Save B on the stack
!       CMPB    #191          ; Check if B is > than 191
        BLS     @SaveB1       ; If value is 191 or < then skip ahead
        LDB     #191          ; Make the max size 191
@SaveB1 PSHS    B             ; Save the y coordinate on the stack

        LDD     #0            
        STB     LineColour    ; Save the Colour value
        JSR     BoxFill_FG6C  ; Go draw foreground colour box

; SOUND 200,1
        LDD     #200          
        STB     SoundTone     ; Save the Tone Value
        LDD     #1            
        LDA     #$04          ; Match timing of Color BASIC
        MUL                   ; D now has the proper length
        STD     SoundDuration ; Save the length of the sound
        JSR     PlaySound     ; Go play the SOUND
; BallYD=BallYD*-1'  change direction 
        LDD     _Var_BallYD   
        LDX    #-1          
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; Do 16 bit x 16 bit Multiply, D = WORD on Stack ,S * WORD on stack 2,S, lowest 16 bit result will be in D
        LEAS    4,S           ; Fix the Stack
        STD     _Var_BallYD   ; Save Numeric variable
; PlayerScore=PlayerScore+10'  Give the player some points 
        LDD     _Var_PlayerScore   
        ADDD    #10          
        STD     _Var_PlayerScore   ; Save Numeric variable
; IF PlayerScore>HiScoreTHEN 
        LDD     _Var_HiScore  
        STD     _NumVar_IFRight   ; Save the Right Operand value
        LDD     _Var_PlayerScore   
        LDX     #$FFFF        ; Default is Result = -1, True
        CMPD    _NumVar_IFRight   ; Compare D with the value on the right
        BGT     >             ; If Greater than, then skip ahead
        LDX     #$0000        ; Make the Result zero, False
!       PSHS    X             ; Save the result on the stack
        LDD     ,S++          ; Set the condition codes and fix the stack
        BEQ     _IFDone_17    ; If result is zero = FALSE then jump to END IF line
; HiScore=PlayerScore
        LDD     _Var_PlayerScore   
        STD     _Var_HiScore  ; Save Numeric variable
; END IF 
_IFDone_17                      ; Label: END IF
; GOSUB DrawScore'  update the scores and return 
        BSR     _LDrawScore   ; GOSUB DrawScore
; BlockCount=BlockCount-1
        LDD     _Var_BlockCount   
        SUBD    #1           
        STD     _Var_BlockCount   ; Save Numeric variable
; RETURN 
        RTS                   ; RETURN
EXITProgram:
        ORCC    #$50          ; Turn off the interrupts
        STA     $FFD8         ; Put Coco back in normal speed
        LDX     $FFFE         ; Get the RESET location
        CMPX    #$8C1B        ; Check if it's a CoCo 3
        BNE     RestoreCoCo1  ; Setup IRQ, using CoCo 1 IRQ Jump location
        LDX     #$FEF7        ; X = Address for the COCO 3 IRQ JMP
        BRA     >             ; Skip ahead
RestoreCoCo1                      
        LDX     #$010C        ; X = Address for the COCO 1 IRQ JMP
!       LDU     #OriginalIRQ  ; U = Address of the original IRQ
        LDA     ,U            ; A = Branch Instruction
        STA     ,X            ; Save Branch Instruction
        LDD     1,U           ; D = address
        STD     1,X           ; Restore the Address of the IRQ
RestoreStack:
        LDS     #$0000        ; Selfmodified when this programs starts - this restores S just how BASIC had it
        PULS    CC,D,DP,X,Y,U,PC   ; Restore the original BASIC Register values and return to BASIC, if it can
DataStart:
        END     START         
