; CoCoMP3 hardware interface Library for CoCo - Compiler version (Restores the CPU speed differently)
; Verison 1.7 by Glen Hewlett
; Assembly code written for the LWASM assembler
;
; This library will help you to communicate with the CoCoMP3
; Basically you setup your input values & pointers in B,X,Y (depending on the command)
; Then load A with the command # you want to send to the CoCoMP3
; Call the SendToCoCoMP3 routine which will return with a value in D
;
; A couple things to be aware of is the CoCo needs to be set to normal speed when using the serial port (as timing is critical)
; So the code below sets the CoCo to normal speed, sends and receives bytes through the serial port to the CoCoMP3 then
; it will restore the speed of the CoCo to the value set with the SET-CPU-MODE command.  It's important to call this command and
; set it to the speed you would like your program to run.  The default is running at normal speed.
;    LDA     #$85                    ; SET-CPU-MODE command
;    LDX     #$000F                  ; Set to triple speed+ (if a GIME-X/Z) and put 6309 in native mode (if it's installed)
;    JSR     SendToCoCoMP3           ; Send the command to the CoCoMP3
;
; The other thing to be aware of is the Audio Mode setting, it deafults to "AUDIO ON" which will send audio from the cassette
; interface to the CoCo's TV output.  If you don't want this to be set everytime you use this library you can set the AUDIO-MODE
; to not change the audio settings at all, that will be left to the programmer to handle.  Maybe you want the CoCoMP3 only to be
; used as background sound with external speakers through the 3.5mm jack.  That way the CoCo sounds will play through the TV
; speaker.
;    LDA     #$84                    ; AUDIO-MODE command
;    LDX     #$0000                  ; 0 = leave audio setting untouched, <> 0 Always keep AUDIO ON
;    JSR     SendToCoCoMP3           ; Send the command to the CoCoMP3
;
; Other Examples...
;
; To test if the CoCoMP3 is attached and ready to be used (No input values need to be set)
;    LDA     #$80                    ; $80 = the CoCoMP3_TEST command (See the list of commands below)
;    JSR     SendToCoCoMP3           ; Send the command to the CoCoMP3, response will be in D
; It will respond with:
;  0 = All good
; -1 = CoCoMP3 is not powered on or plugged in
; -2 = microSD card not detected
; -3 = no Tracks on microSD
;
; To set the EQ to mode 3
; Description: Set the EQ Mode to level in X
;CoCoMP3_SET_EQ:
;    LDA     #$1A                    ; Set EQ Mode setting command
;    LDX     #03                     ; Value of 3 = Jazz
;    JSR     SendToCoCoMP3           ; Send the command to the CoCoMP3, response will be in D
;
; To send a string command using the PLAY-TRACK command with a folder name of /FOLDER03/JUMP.MP3
;    BSR      Skip                   ; jump past the string, saves the start address on the stack
;    FCC     '/FOLDER03/JUMP.MP3'    ; Where the track is on the microSD
;Skip:
;    LDD     #Skip                   ; D = End address of string
;    SUBD    ,S                      ; B = Number of bytes to send to the CoCoMP3
;    LDX     ,S++                    ; X = String start address, Fix the stack
;    LDA     #$08                    ; $08 is the PLAY-TRACK command
;    JSR     SendToCoCoMP3           ; A = Command #, B = Length of String, X Points at the string
;
; Complete user guide for using this library can be found here:
;
;
; For more details of the hardware in the CoCoMP3 which uses the DY-SV5W MP3 Playing IC/Module
; https://grobotronics.com/images/companies/1/datasheets/DY-SV5W%20Voice%20Playback%20ModuleDatasheet.pdf
; The DY-SV5W MP3 Playing IC/Module serial interface uses 9600 baud (8N1)
;
; Constants
PIA1A_DATA      EQU $FF20           ; Port A Data/Direction
PIA1A_CTRL      EQU $FF21           ; Port A Control
PIA1B_DATA      EQU $FF22           ; Port B Data/Direction
PIA1B_CTRL      EQU $FF23           ; Port B Control
RetryCount      EQU 20              ; # of retries until we give up getting a good response
;
;    opt     c,ct,cc       * show cycle count, add the counts, clear the current count
;
;    ORG     $7984
; Enter with command in A, B,X & U should already be set to be used as per the command selected
; A = Command # (Ignored if you string starts with $AA - Sending all raw codes)
; B = Number of bytes to send to the CoCoMP3
; X = Pointer to the data to send to the CoCoMP3
; U = (Optional only for somce commands) - Secondary value
SendToCoCoMP3:
; Check for raw bytes
    PSHS    A                       ; Save A
    LDA     ,X                      ; A = first byte of the users string
    CMPA    #$AA                    ; If the first byte is $AA, we will send as raw bytes, not a command
    PULS    A                       ; Restore A
    BNE     NotRAWBytes             ; If not handle commands
;
; Description: Sends the users RAW data as is
; Entry:
; B = Number of bytes to send to the CoCoMP3
; X = Pointer to the data to send to the CoCoMP3
; Exit:
; D = Response values
CoCoMP3_SEND_RAW:
    LDA     #$FF                    ; Signify we will send the codes as they are
    LBRA    CoCoMP3Raw              ; Send the users codes and receive value in D

NotRAWBytes:
    TSTA
    BMI     >                       ; If it's a negative then it is a special command
    CMPA    #$20
    BHS     CoCoMP3_RETURN          ; Bad command, return with -1
    LEAY    CommandJumpTable,PCR    ; Y = start of the jump table
    BRA     DoCommand               ; Go jump to the command
!   ANDA    #%01111111              ; strip off the high bit of the special command value
    CMPA    #$06                    
    BHS     CoCoMP3_RETURN          ; Bad command, return with -1
    LEAY    SpecialCommandJumpTable,PCR    ; Y = start of the special command jump table
DoCommand:
    LSLA                            ; A = A * 2 as each address is a 16 bit value
    LEAY    A,Y                     ; Y = offset in the table
    PSHS    B                       ; Save B
    LDD     ,Y                      ; Get the Pointer value
    LEAY    CommandJumpTable,PCR    ; Y = start of the lookup table
    LEAY    D,Y                     ; Y = offset + start of the lookup table
    PULS    B                       ; Restore B
    JSR     ,Y                      ; Go do the users command
BackToUser:
    LDD     ReturnCode,PCR          ; D = return code value
BackToUserWithD:
    RTS                             ; Return to user

; If a command is given that is out of range, simply return to the user
CoCoMP3_RETURN
    LDD     #-1                     ; Return with an error
    BRA     BackToUserWithD         ; Return

; Test the CoCoMP3 is attached, powered on and a microSD card is inserted with Tracks on it
; It will respond with:
;  0 = All good
; -1 = CoCoMP3 is not powered on or plugged in
; -2 = microSD card not detected
; -3 = no Tracks on microSD
CoCoMP3_TEST:
    CLR     ,-S                     ; Clear a value on the stack
    BSR     CoCoMP3_ConnectTest     ; Test if the CoCoMP3 is connected and powered on, Carry bit is clear if good
    BCS     CoCoMP3_NotConnected
; GET-DRIVE-STATUS
    LDA     #$09                    ; Check device is online, 0 not online, 2 if it is online
    STA     CommandNumber,PCR       ; Save the Command Number
    CLRB                            ; Simple commands don't have any other bytes to send
    STB     RawBytes,PCR            ; Save the RAW flag
    LBSR    NormalSpeed             ; Put the CoCo into Normal speed
    LBSR    DoCoCoMP3               ; Go send string to the CoCoMP3
    LBSR    RestoreSpeed            ; Set the CoCo to the speed the user requested
    LDB     ReturnCode+1,PCR
    BEQ     CoCoMP3_No_microSD      ; If = 0 then No microSD installed
 ; GET-NUMBER-OF-TRACKS
    LDA     #$0C                    ; Get the number of tracks on the microSD card
    STA     CommandNumber,PCR       ; Save the Command Number
    CLRB                            ; Simple commands don't have any other bytes to send
    STB     RawBytes,PCR            ; Save the RAW flag
    LBSR    NormalSpeed             ; Put the CoCo into Normal speed
    LBSR    DoCoCoMP3               ; Go send string to the CoCoMP3
    LBSR    RestoreSpeed            ; Set the CoCo to the speed the user requested
    LDD     ReturnCode,PCR
    CMPD    #$0000                  ; Are there zero tracks?
    BEQ     CoCoMP3_No_Tracks
    CLRA                            ; A = 0
    BRA     >                       ; Get B = 0 off the stack, and fix the stack then return with the value of D
CoCoMP3_No_Tracks:
    DEC     ,S                      ; Decrement 1 from the current value
CoCoMP3_No_microSD:
    DEC     ,S                      ; Decrement 1 from the current value
CoCoMP3_NotConnected:
    DEC     ,S                      ; Decrement 1 from the current value
    LDA     #$FF                    ; Make D a negative value
!   LDB     ,S+                     ; Get value off the stack and fix the stack
    STD     ReturnCode,PCR          ; Save the return code
    RTS         

; Verify the CoCoMP3 is powered up, attached and responding to the CoCo
; Carry flag will be clear if the CoCoMP3 is powered up and responding to the CoCo.
; Carry flag will be set if the CoCoMP3 is not responding (not connected or powered on)
CoCoMP3_ConnectTest:
    LDA     #$01                    ; Check check play state, -1 if off/not connected 0 if connected
    STA     CommandNumber,PCR       ; Save the Command Number
    CLRB                            ; Simple commands don't have any other bytes to send
    STB     RawBytes,PCR            ; Save the RAW flag
    LBSR    NormalSpeed             ; Put the CoCo into Normal speed
    LBSR    DoCoCoMP3               ; Go send string to the CoCoMP3
    LBSR    RestoreSpeed            ; Set the CoCo to the speed the user requested
    LDD     ReturnCode,PCR
    CMPD    #$FFFF                  ; $FFFF signifies the CoCoMP3 is not responding
    BNE     CoCoMP3_Good            ; If it's not $FFFF then we are good
; We get here if the CoCoMP3 is not responding, it might be unplugged or not powered
    COMA                            ; Set the carry bit
    RTS                             ; Return
; We get here if the CoCoMP3 has repsonded :)
CoCoMP3_Good:
    CLRA                            ; Clear the carry bit
    RTS                             ; Return

; Fade the volume level to zero over X milliseconds (Max X value is 60000)
; Entry:
; X = # of milliseconds the fade should take
CoCoMP3_VOL_FADE:
    LDB     #30                     ; Max number of times to lower the volume
    PSHS    B,X                     ; Save 30 iterations & user's # of milliseconds to fade on the stack
FadeLoop1:
    LDA     #4                      ; Do this loop 4 times which is approximately what we need
FadeLoop2:
    LDX     1,S                     ; Get the delay number in X
!   LEAX    -1,X                    ; [5] CPU Cycles
    BNE     <                       ; [3] CPU cycles = Total of 8 cycles per loop iteration
    DECA
    BNE     FadeLoop2
    BSR     CoCoMP3_VOL_DOWN        ; Decrease the Volume 1 step
    DEC     ,S                      ; Decrement the counter
    BPL     FadeLoop1               ; Keep looping until we've done zero
    LEAS    3,S                     ; Fix the stack
    BRA     CoCoMP3_STOP            ; Do the Stop command and return to user

; Query Play Status
CoCoMP3_GET_PLAY_STATUS:
    LDA     #$01                    ; Query Play Status command
    BRA     SendCommand             ; Send command in A to the CoCoMP3 - Result is in D
; CoCoMP3 Play command
CoCoMP3_PLAY:
    LDA     #$02                    ; Play command
    BRA     SendCommand             ; Send command in A to the CoCoMP3
; CoCoMP3 Pause command
CoCoMP3_PAUSE:
    LDA     #$03                    ; Pause command
    BRA     SendCommand             ; Send command in A to the CoCoMP3
; CoCoMP3 Stop command
CoCoMP3_STOP:
    LDA     #$04                    ; Stop command
    BRA     SendCommand             ; Send command in A to the CoCoMP3
; CoCoMP3 Previous command
CoCoMP3_PREVIOUS:
    LDA     #$05                    ; Previous command
    BRA     SendCommand             ; Send command in A to the CoCoMP3
; CoCoMP3 Next command
CoCoMP3_NEXT:
    LDA     #$06                    ; Next command
    BRA     SendCommand             ; Send command in A to the CoCoMP3
; Query microSD card status
; Will return with the status in D, where it will be:
; 0 = no microSD card is detected
; 2 = microSD is installed
CoCoMP3_GET_DRIVE_STATUS:
    LDA     #$09                    ; Query microSD card status command
    BRA     SendCommand             ; Send command in A to the CoCoMP3 - Result is in Dlt is in D
; Query Current Play Drive
CoCoMP3_GET_CURRENT_PLAY_DRIVE:
    LDA     #$0A                    ; Query Current Play Drive command
    BRA     SendCommand             ; Send command in A to the CoCoMP3 - Result is in D
; Switch to selected device (CoCoMP3 only has device 1 microSD card)
CoCoMP3_SWITCH_TO_SELECTED_DEVICE:
    LDA     #$0B                    ; Query Folder Number of tracks command
    BRA     SendCommand             ; Send command in A to the CoCoMP3 - Result is in D
; Query Number of tracks
CoCoMP3_GET_NUMBER_OF_TRACKS:
    LDA     #$0C                    ; Query Number of TRACKs command
    BRA     SendCommand             ; Send command in A to the CoCoMP3 - Result is in D
; Query Current track
CoCoMP3_GET_CURRENT_TRACK:
    LDA     #$0D                    ; Query Current track command
    BRA     SendCommand             ; Send command in A to the CoCoMP3 - Result is in D
; CoCoMP3 Previous file command
CoCoMP3_PLAY_PREVIOUS_FOLDER:
    LDA     #$0E                    ; Previous file command
    BRA     SendCommand             ; Send command in A to the CoCoMP3
; CoCoMP3 Next file command
CoCoMP3_PLAY_NEXT_FOLDER:
    LDA     #$0F                    ; Next file command
    BRA     SendCommand             ; Send command in A to the CoCoMP3
; CoCoMP3 End Playing command
CoCoMP3_END_PLAYING:
    LDA     #$10                    ; End Playing command
    BRA     SendCommand             ; Send command in A to the CoCoMP3
; Query Folder Directory track
CoCoMP3_GET_FOLDER_DIR_TRACK:
    LDA     #$11                    ; Query Folder Directory track command
    BRA     SendCommand             ; Send command in A to the CoCoMP3 - Result is in D
; Query Folder Number of tracks
CoCoMP3_GET_TRACKS_IN_FOLDER:
    LDA     #$12                    ; Query Folder Number of tracks command
    BRA     SendCommand             ; Send command in A to the CoCoMP3 - Result is in D
; CoCoMP3 Volume Up command
CoCoMP3_VOL_UP:
    LDA     #$14                    ; Volume Up command
    BRA     SendCommand             ; Send command in A to the CoCoMP3
; CoCoMP3 Volume Down command
CoCoMP3_VOL_DOWN:
    LDA     #$15                    ; Volume Down command
    BRA     SendCommand             ; Send command in A to the CoCoMP3
; CoCoMP3 End Combination play command
CoCoMP3_END_COMBINATION_PLAY:
    LDA     #$1C                    ; End Combination play command
    BRA     SendCommand             ; Send command in A to the CoCoMP3

; Other commands
; Description: Set the volume to level in X
CoCoMP3_SET_VOL:
    LDA     #$13                    ; Set volume level command
    BRA     Command1                ; Send single byte

; Description: Set the Cycle Mode setting to level in X
CoCoMP3_CYCLE_MODE_SETTING:
    LDA     #$18                    ; Set Cycle Mode setting command
    BRA     Command1                ; Send single byte

; Description: Set the EQ Mode to level in X
CoCoMP3_SET_EQ:
    LDA     #$1A                    ; Set EQ Mode setting command
    BRA     Command1                ; Send single byte

; Set the CoCoMP3 volume level to max which is 30, which it defaults at startup
CoCoMP3_VOL_MAX:
    LDA     #$13                    ; Set Volume command
    LDX     #30                     ; X has the max volume setting
    BRA     Command1                ; Send single byte

; Play the specified track #, given in X
CoCoMP3_PLAY_TRACK_NUMBER:
    LDA     #$07                    ; Set Volume command
    BRA     Command2                ; Go send 2 bytes

; Set Cycle Times, given in X
CoCoMP3_SET_CYCLE_TIMES:
    LDA     #$19                    ; Set Cycle Times command
    BRA     Command2                ; Go send 2 bytes

; Select but no play, given in X
CoCoMP3_SELECT_BUT_NO_PLAY:
    LDA     #$1F                    ; Select but no play command
    BRA     Command2                ; Go send 2 bytes

; Send a simple command to the CoCoMP3
; Entry:
; A = Command to send
; Exit:
; D = Response from the CoCoMP3
SendCommand:
    STA     CommandNumber,PCR       ; Save the Command Number
    CLRB                            ; Simple commands don't have any other bytes to send
    BRA    CoCoMP3                 ; Go handle the CoCoMP3

; Setting command that has an 8 bit value for the setting
Command1:
    STA     CommandNumber,PCR       ; Save the Command Number
    TFR     X,D                     ; D = X, A=MSB of X, B=LSB of X
    STB     CommandString,PCR       ; Save the 8 bit value in temp buffer
    LDB     #1                      ; Number of bytes to send after the $AA & Command Number
    LEAX    CommandString,PCR       ; X points at the string
    BRA     CoCoMP3                 ; Send to CoCoMP3 and return to user
; Setting command that has an 16 bit value for the setting
Command2:
    STA     CommandNumber,PCR       ; Save the Command Number
    LDB     #2                      ; Number of bytes to send after the $AA & Command Number
    STX     CommandString,PCR       ; Save the 16 bit value in temp buffer
    LEAX    CommandString,PCR       ; X points at the string
    BRA     CoCoMP3                 ; Send to CoCoMP3 and return to user

; Set the CoCoMP3 file number to interlude, song number in X
; Setting command that has a device # & 16 bit values for the setting in X
CoCoMP3_SET_TRACK_INTERLUDE:
    LDA     #$16                    ; Set "Select specified file to interlude" command
    STA     CommandNumber,PCR       ; Save the Command Number
    LDB     #3                      ; Number of bytes to send after the $AA & Command Number
    LDA     #1                      ; Device number
    STA     CommandString,PCR       ; Save the 8 bit value in temp buffer
    STX     CommandString+1,PCR     ; Save the setting (of U) in temp buffer
    LEAX    CommandString,PCR       ; X points at the string
    BRA     CoCoMP3                 ; Send to CoCoMP3 and return to user

; Combination play setting, given in X & U
; Setting command that has an two 16 bit values for the setting
CoCoMP3_COMBINATION_PLAY_SETTING:
    LDA     #$1B                    ; Set Combination play setting command
    STA     CommandNumber,PCR       ; Save the Command Number
    LDB     #4                      ; Number of bytes to send after the $AA & Command Number
    STX     CommandString,PCR       ; Save the 16 bit value in temp buffer
    STU     CommandString+2,PCR     ; Save the setting (of U) in temp buffer
    LEAX    CommandString,PCR       ; X points at the string
    BRA     CoCoMP3                 ; Send to CoCoMP3 and return to user

; Play a specifc file on the CoCoMP3
; B = Length of the Folder Path string
; X = Pointer to the Folder Path string
CoCoMP3_PLAY_TRACK:
    LDA     #$08                    ; Command to play a file
    STA     CommandNumber,PCR
; Check string and if it ends with a .MP3 or .WAV change it to a *MP3 or *WAV as that's what the hardware requires from the name
    LBSR    DotToAsterisk           ; Change a ".MP3" to "*MP3" or ".WAV" to "*WAV" 
    BRA     CoCoMP3                 ; Send to CoCoMP3 and return to user

; Set the path for the folder to be played on the CoCoMP3
; B = Length of the Folder Path string
; X = Pointer to the Folder Path string
CoCoMP3_SET_PATH_INTERLUDE:
    LDA     #$17                    ; Command to set the path
    STA     CommandNumber,PCR
; Check string and if it ends with a .MP3 or .WAV change it to a *MP3 or *WAV as that's what the hardware requires from the name
    LBSR    DotToAsterisk           ; Change a ".MP3" to "*MP3" or ".WAV" to "*WAV" 
    BRA     CoCoMP3                 ; Send to CoCoMP3 and return to user

; Enter:
; B = Length of the string to send to the CoCoMP3
; X = Pointer to the string to be sent
CoCoMP3:
    CLRA                            ; Signify we are not sending RAW bytes, validate the command before sending
CoCoMP3Raw:
    STA     RawBytes,PCR            ; Save the RAW flag
    LBSR    NormalSpeed             ; Put the CoCo into Normal speed
    BSR     DoCoCoMP3               ; Go send string to the CoCoMP3
    LBSR    RestoreSpeed            ; Set the CoCo to the speed the user requested
    LBRA    BackToUser              ; return back to user with the ReturnCode
    
DoCoCoMP3:
    STB     LengthOfString,PCR      ; Save the length of the string
    LDA     #RetryCount             ; A = retry count
    STA     ResponseCheck,PCR       ; Save the retry count, to error out with
    CLR     ReturnLimit,PCR         ; Clear the bit retry counter
    CLR     ResponseBytes,PCR       ; Set the length of the return string
    LDB     Audio_ModeSetting,PCR   ; 0 = leave audio setting untouched, <> 0 Always keep AUDIO ON
    PSHS    CC,A,B,X                ; Save the CC, Audio On or Audio Ignore flag & the string start location
    ORCC    #$50                    ; Stop the Interrupts
;
; Initialize PIA1 for Serial
; Setup the direction      
    LDA     PIA1A_CTRL              ; Get current values
    ANDA    #%11111011              ; Direction mode bit 2 = 0
    STA     PIA1A_CTRL              ; Set Port A to direction mode ($FF21)
    LDA     PIA1B_CTRL              ; Get current values
    ANDA    #%11111011              ; Direction mode bit 2 = 0
    STA     PIA1B_CTRL              ; Set Port B to direction mode ($FF23)
;
; Now they are in direction mode, I can properly capture the original direction settings
    LDA     PIA1A_DATA              ; Get the original values for PIA1A ($FF20)
    LDB     PIA1B_DATA              ; Get the original values for PIA1B ($FF22)
    PSHS    D                       ; Save the PIA1A & PIA1B original values, so they can be restored before returning from this routine
;
    LDA     #%00000010              ; Bit 1=1 (output), others=0 (input or unused)
    STA     PIA1A_DATA              ; Set directions (only bit 1 output) ($FF20)
    LDA     #%11111110              ; Bit 0=0 (input), others=1 (output or unused)
    STA     PIA1B_DATA              ; Set directions (only bit 0 input) ($FF22)
    LDA     PIA1A_CTRL              ; Get current values
    ORA     #%00000100              ; Switch to Data mode bit 2 = 1
    STA     PIA1A_CTRL              ; Set Port A to Data mode ($FF21)
    LDA     PIA1B_CTRL              ; Get current values ($FF23)
    ORA     #%00000100              ; Switch to Data mode bit 2 = 1
    STA     PIA1B_CTRL              ; Set Port B to Data mode ($FF23)
;
; Test if the user wants to do an Audio ON 
    LDA     2+2,S                   ; Get the Audio ON/Ignore flag
    BEQ     DoneAudio               ; If the flag is zero then leave Audio settings as they are
; If we get here the user wants to do an AUDIO ON    
    LDA     $FF01                   ; Make the Muxer point at the cassette interface
    ORA     #%00001000
    STA     $FF01
    LDA     $FF03
    ANDA    #%11110111
    STA     $FF03
    LDA     PIA1B_CTRL              ; Get current values ($FF23)
    ORA     #%00001000              ; Enable analogue muxer
    STA     PIA1B_CTRL              ; Set Port B to Data mode ($FF23)
DoneAudio:
; Test if user wants to send their own RAW codes
    LDA     RawBytes,PCR            ; If this byte <> zero than the user is sending raw data
    BEQ     HandleNormal            ; If zero we will handle it normally
    LDD     ,X++
    STA     CodeByte,PCR            ; Save the Codebyte
    STB     CommandNumber,PCR       ; Save the Command number
    LDB     ,X+                     ; Get the length of the string
    STB     LengthOfString,PCR      ; Save the updated length of the string
    CLRA                            ; D = B
    LDA     D,X                     ; Must use D as a 16 bit value, get checksum from users string
    STA     Checksum,PCR            ; Save the users Checksum value
    BRA     ReadyToGo               ; Everything is ready to go
;
HandleNormal:
; Handle the checksum
    LDA     #$AA                    ; The Code byte
    STA     CodeByte,PCR            ; Save the Codebyte
    ADDA    CommandNumber,PCR       ; Add the command value to the checksum
    ADDA    LengthOfString,PCR      ; Add the length value to the checksum
;
    LDB     LengthOfString,PCR      ; Get Length of the string
    BEQ     GotChecksum             ; If the length is zero then we already have the checksum value
    DECB                            ; Length -1, pointer is zero based below
; Calc checksum
!   ADDA    B,X                     ; Calc checksum in A
    DECB                            ; Decrement the counter
    BPL     <                       ; Loop until zero
GotChecksum:
    STA     Checksum,PCR            ; Save the calculated checksum
; The string is now setup properly
ReadyToGo:
    DEC     ResponseCheck,PCR       ; Decrement the error retry count
    BNE     ResponseGood            ; If we didn't countdown to zero then we're still good
; If we get here then we retried to get a response too many times, return with Error
; Maybe the CoCoMP3 is not connected
    LDD     #$FFFF                  ; signify the CoCoMP3 is not responding
    STD     ReturnCode,PCR          ; Save as the return code value
    BRA     Done                    ; Exit
;
; We are now ready to send our string over the serial port
ResponseGood:
; Check if we are sending a users RAW data and if so don't verify the command sent
    LDA     CodeByte,PCR            ; A = First character (Always $AA, unless doing a RAW send "HACKING?" code)
    LBSR    Send_Byte               ; Send A to the serial port
    LDA     CommandNumber,PCR       ; Get the command number
    LBSR    Send_Byte               ; Send A to the serial port
;
;
; Check for special long string entries that aren't RAW, we need to add 2 to the checksum if not raw
    LDB     RawBytes,PCR            ; If this byte <> zero than the user is sending raw data
    BNE     SkipDevice                 ; If <> zero then RAW, leave as it is
;
; Check if we need to send device with this command
    LDB     CommandNumber,PCR       ; Get the command value
    LEAU    DY_SV5W_ResponseTable,PCR ; U = start of the Table of allowable responses
    LDB     B,U                     ; B = number of bytes to receieve
    BPL     SkipDevice              ; If positive then no device ID needed with this command
    INC     Checksum,PCR            ; Update the calculated Checksum value, one more byte to send (length+1)
    INC     Checksum,PCR            ; Update the calculated Checksum value, A byte of 1 will be sent (device ID)
    LDA     LengthOfString,PCR      ; Get Length of the string to send
    INCA                            ; With device number the length is one more byte longer
    LBSR    Send_Byte               ; Send A to the serial port
    LDA     #1                      ; Device number of the CoCoMP3 microSD card
    LBSR    Send_Byte               ; Send A to the serial port
    BRA     >                       ; Skip normal sending without a device
SkipDevice:
    LDA     LengthOfString,PCR      ; Get Length of the string to send
    LBSR    Send_Byte               ; Send A to the serial port
!   LDB     LengthOfString,PCR      ; Get Length of the string to send
    BEQ     SendChecksum            ; if it's zero then no other bytes to send, just the checksum
    LEAU    ,X                      ; U = string pointer
!   LDA     ,U+                     ; A = character, then point at the next character
    LBSR    Send_Byte               ; Send A to the serial port
    DECB                            ; Decrement the string length counter
    BNE     <                       ; If not zero keep looping
;
SendChecksum:
    LDA     Checksum,PCR            ; A = Checksum
    LBSR    Send_Last_Byte          ; Send A to the serial port, this is the last byte, so don't wait after sending
; Check if user wants to read the response from the CoCoMP3
    BRA     GetResponse             ; Get response to wait for
; If we get here then no response, make the string size zero
ReturnEmptyString:
    LDD     #$FFFE                  ; signify the CoCoMP3 is not supposed to respond with this command
    STD     ReturnCode,PCR          ; Save as the return code value
Done:
; Restore original settings for the PIA1A & PIA1B
    LDA     PIA1A_CTRL              ; Get current values
    ANDA    #%11111011              ; Direction mode bit 2 = 0
    STA     PIA1A_CTRL              ; Set Port A to direction mode ($FF21)
    LDA     PIA1B_CTRL              ; Get current values
    ANDA    #%11111011              ; Direction mode bit 2 = 0
    STA     PIA1B_CTRL              ; Set Port B to direction mode ($FF23)
;
    PULS    D
    STA     PIA1A_DATA              ; Set directions back as they were before the program was run ($FF20)
    STB     PIA1B_DATA              ; Set directions back as they were before the program was run ($FF22)
;
    LDA     PIA1A_CTRL              ; Get current values
    ORA     #%00000100              ; Switch to Data mode bit 2 = 1
    STA     PIA1A_CTRL              ; Set Port A to Data mode ($FF21)
    LDA     PIA1B_CTRL              ; Get current values
    ORA     #%00000100              ; Switch to Data mode bit 2 = 1
    STA     PIA1B_CTRL              ; Set Port B to Data mode ($FF23)
;
AllDone:
   PULS    CC,A,B,X,PC              ; Restore the Condition codes, fix stack and return
;
; If we get here user wants to get the response bytes
GetResponse:
; Check if this command should have a response
    LDA     CommandNumber,PCR       ; Get the command value
    CMPA    #$1F                    ; Is it higher than $1F?
    BLS     >
    LDD     #$FFFD                  ; signify the CoCoMP3 is not supposed to respond with this command
    STD     ReturnCode,PCR          ; Save as the return code value
    BRA     Done
!   LEAU    DY_SV5W_ResponseTable,PCR ; U = start of the Table of allowable responses
    LDB     A,U                     ; B = number of bytes to receieve
    ANDB    #%01111111              ; Strip off bit 7 which flags if it should send a device #1
    BEQ     ReturnEmptyString       ; If zero then No command, return with $FFFE
ReadBytes:
    LEAU    ResponseBytes,PCR       ; Save the response bytes here, so we can validate them
    STB     ,U+                     ; Save the string length, advance pointer
    CLR     ,-S                     ; Save initial Checksum value on the stack
ReadBytesLoop:
    BSR     Receive_Byte            ; Get a byte from the serial port in A, CC = 0 Good, CC = 1 then Error
    STA     ,U+                     ; Save the byte in the string
    DECB                            ; Decremnt the counter for how many bytes to receive
    BEQ     VerifyChecksum          ; We got the bytes go verify they are correct
    ADDA    ,S                      ; Add the value to the checksum on the stack
    STA     ,S                      ; Update the checksum on the stack
    BRA     ReadBytesLoop           ; Keep getting more bytes
VerifyChecksum:
!   CMPA    ,S+                     ; Test the last byte with the calculated checksum, Fix the stack
    LBNE    ReadyToGo               ; If they aren't the same then there was an Error receiving, go send and recieve again
; Check for all zeros (CoCoMP3 not powered or plugged in)
!   LDD     ResponseBytes+1,PCR     ; D = First two bytes of the response (A should always be $AA, B should always be > zero)
    BNE     >                       
; Get here if the first two bytes were zero = CoCoMP3 is not powered or plugged in to the CoCo
;
    LDD     #$FFFF                  ; Signify the CoCoMP3 is not responding
    STD     ReturnCode,PCR          ; Save as the return code value
    LBRA    Done                    ; Exit
!   LEAX    ResponseBytes,PCR       ; Save the response bytes here, so we can validate them
    LDB     ,X+                     ; Get the length of the response string
    ABX
    CMPB    #6                      ; Is it a 6 byte response?
    BEQ     >                       ; If so respond with a 16 bit value
    CLRA                            ; Otherwise get an 8 bit value ro respond with
    LDB     -2,X                    ; Get the 8 bit response value
    BRA     SaveReturnValue
!   LDD     -3,X                    ; Get the 16 bit response value
SaveReturnValue:
    STD     ReturnCode,PCR          ; Save the 16 bit return code
    LBRA    Done                    ; Otherwise all good return with received byte on the string
;
; Add cycle counts in assembly listing
;    opt     c,ct,cc       * show cycle count, add the counts, clear the current count
;
; Send a byte (A = byte to send)
; Each byte is transmitted as a sequence of 10 bits: 1 start bit (low), 8 data bits (LSB first), and 1 stop bit (high).
; This is the critical timing part.  
; Delays between characters is fine, you just have to make sure the timing of each character with start bit and stop bit is sent at
; 9600 bits per second.
Send_Byte:
    PSHS    A,B,X                   ; [10] Save regs
    LDA     PIA1A_DATA              ; [5] Get current Port A ($FF20)
    ANDA    #%11111101              ; [2] Start bit: TX low
    STA     PIA1A_DATA              ; [5] Output
; At this point we need to delay 93 CPU cycles until the next bit is sent ($FF20)
; From here to the next     STA     PIA1A_DATA is 33 CPU cycles
; 93 - 33 = 60 cycles to delay
;
    LDD     #11*$100+8              ; [3] Set A to 11 and B to 8, 8 data bits to count in the SEND_LOOP below
    BSR     DELAY_LOOP              ; [7] Delay is A * 5 + 5 = A * 5 + 5 = 11 * 5 + 5 = 60 cycles
;
SEND_LOOP:
    LSR     ,S                      ; [6] Shift Least significant bit to carry
    LDA     PIA1A_DATA              ; [5] Get Port A ($FF20)
    ANDA    #%11111101              ; [2] Clear TX bit
    BCC     >                       ; [3] If carry = 0, keep low
    ORA     #%00000010              ; [2] Set high
!   STA     PIA1A_DATA              ; [5] Output bit ($FF20)  93 - 36 CPU cyles to get here means the loop above must delay for 57 cpu cycles 
;
; At this point we need to delay 93 CPU cycles until the next bit is sent ($FF20)
; 93 - 37 = 56 cycles to delay
;
;    opt     cc       * show cycle count, add the counts, clear the current count
;
    LDA     #9                      ; [2] Set A to 9
    BSR     DELAY_LOOP              ; [7] Delay is A * 5 + 5 = A * 5 + 5 = 9 * 5 + 5 = 50 cycles
    TFR     A,A                     ; [6] Waste CPU cycles, two bytes = 56 cycle delay
    DECB                            ; [2] Next bit
    BNE     SEND_LOOP               ; [3] Loop
;
    FCB     $34,$00  	            ; [5] Same as PSHS #0, so delay will be 93 cycles below
    LDA     PIA1A_DATA              ; [5] Stop bit: TX high (5)
    ORA     #%00000010              ; [2]
    STA     PIA1A_DATA              ; [5]
    LDA     #15                     ; [2] Set A to 15
    BSR     DELAY_LOOP              ; [7] Delay is A * 5 + 5  = 15 * 5 + 5 = 80 cycles
    PULS    A,B,X,PC                ; [12] Restore and return
;
DELAY_LOOP:
    DECA                            ; [2] cycles
    BNE     DELAY_LOOP              ; [3] cycles
    RTS                             ; [5] cycles
;        
; Receive a byte (Returns A = received byte, Carry set if framing error)
; 
; When we get a 1 it signifies a start bit
; The start bit lasts for 104 micro seconds 
; Each bit after lasts for 104 micro seconds (measured 103.824111 microseconds)
;
Receive_Byte:
    LDA     #%00000001              ; [2] Test for bit 0
!   BITA    PIA1B_DATA              ; [5] Check $FF22 bit 0
    BNE     GotStartBit             ; [3] 
    DEC     ReturnLimit,PCR         ; Count = Count - 1
    BNE     <                       ; [3] Loop until counter is done
;
; Start bit has been sent, wait 93 - 25 cycles until the first bit will be received = 68 cycles to delay
; Real world tests show that a delay of 57 is perfect, so that's what I'm using
GotStartBit:
;    opt     cc       * show cycle count, add the counts, clear the current count
;
; Delay:
    LDA     #9                      ; [2] Set A to 9
    BSR     DELAY_LOOP              ; [7+55] Delay is A * 5 + 5 = 9 * 5 + 5 = 50 cycles
; End of Delay
    PSHS    B                       ; [7] Save B
    LDB     #%10000000              ; [2] 8 data bits to shift
    STB     ,-S                     ; [6] Push it on the stack
    LDY     #PIA1B_DATA             ; [4] Point at $FF22
; Receive loop takes 27 cycles
; 93 - 27 = 66 cycles to delay
RECV_LOOP:
; We received the start bit, get the 8 real bits, least significant bit first
;
;     opt     cc       * show cycle count, add the counts, clear the current count
;
; Sample the incoming bits 10 times
    CLRB                            ; [2] B = 0
    LDA     ,Y                      ; [4] Get the input serial bit on bit 0 of $FF22
    RORA                            ; [2] move bit zero to the carry bit
    ADCB    #$00                    ; [2] B = B + the carry
    LDA     ,Y                      ; [4] Get the input serial bit on bit 0 of $FF22
    RORA                            ; [2] move bit zero to the carry bit
    ADCB    #$00                    ; [2] B = B + the carry
    LDA     ,Y                      ; [4] Get the input serial bit on bit 0 of $FF22
    RORA                            ; [2] move bit zero to the carry bit
    ADCB    #$00                    ; [2] B = B + the carry
    LDA     ,Y                      ; [4] Get the input serial bit on bit 0 of $FF22
    RORA                            ; [2] move bit zero to the carry bit
    ADCB    #$00                    ; [2] B = B + the carry
    LDA     ,Y                      ; [4] Get the input serial bit on bit 0 of $FF22
    RORA                            ; [2] move bit zero to the carry bit
    ADCB    #$00                    ; [2] B = B + the carry
    LDA     ,Y                      ; [4] Get the input serial bit on bit 0 of $FF22
    RORA                            ; [2] move bit zero to the carry bit
    ADCB    #$00                    ; [2] B = B + the carry
    LDA     ,Y                      ; [4] Get the input serial bit on bit 0 of $FF22
    RORA                            ; [2] move bit zero to the carry bit
    ADCB    #$00                    ; [2] B = B + the carry
    LDA     ,Y                      ; [4] Get the input serial bit on bit 0 of $FF22
    RORA                            ; [2] move bit zero to the carry bit
    ADCB    #$00                    ; [2] B = B + the carry
    LDA     ,Y                      ; [4] Get the input serial bit on bit 0 of $FF22
    RORA                            ; [2] move bit zero to the carry bit
    ADCB    #$00                    ; [2] B = B + the carry
    LDA     ,Y                      ; [4] Get the input serial bit on bit 0 of $FF22
    RORA                            ; [2] move bit zero to the carry bit
    ADCB    #$00                    ; [2] B = B + the carry
; Finished taking 10 sample readings, if the count => 5 then it is a zero, otherwise it's one
; Compare below is the same as SUBB which sets our carry bit for us.
; In our case it is the inverse since CoCoMP3 transmits flipped bits
    CMPB    #5                      ; [2] A range is from 5 to 9 , B < 5 Carry is set, B => 5 Carry is clear
    ROR     ,S                      ; [6] Shift carry bit from CMPB above in negated bit
    BCC     RECV_LOOP               ; [3] Until the preset bit pops out
;
; Delay:
    LDA     #9                      ; [2] Set A to 9
    BSR     DELAY_LOOP              ; [7] Delay is A * 5 + 5 = A * 5 + 5 = 9 * 5 + 5 = 50 cycles
;
; Below is not needed as our checksum will catch any problems
; End of Delay
;    LDA     PIA1B_DATA              ; [5] Get the input bit serial receives from bit 0 of $FF22
;    ANDA    #%00000001              ; [2] Check bit 0
;    BEQ     FRAMING_ERR             ; [3] If low, error (set carry)
;    ANDCC   #$FE                    ; [3] Clear carry (success)
;    BRA     RECV_EXIT               ; [3] Exit
;FRAMING_ERR:
;    ORCC    #$01                    ; [3] Set carry for error
;RECV_EXIT:
    PULS    A,B,PC                  ; [9] A = byte received, restore B & Return 

;
; Send a byte (A = byte to send)
; Each byte is transmitted as a sequence of 10 bits: 1 start bit (low), 8 data bits (LSB first), and 1 stop bit (high).
; This is the critical timing part.  
; Delays between characters is fine, you just have to make sure the timing of each character with start bit and stop bit is sent at
; 9600 bits per second.
Send_Last_Byte:
    PSHS    A,B                     ; [8] Save regs
    LDA     PIA1A_DATA              ; [5] Get current Port A ($FF20)
    ANDA    #%11111101              ; [2] Start bit: TX low
    STA     PIA1A_DATA              ; [5] Output
; At this point we need to delay 93 CPU cycles until the next bit is sent ($FF20)
; From here to the next     STA     PIA1A_DATA is 33 CPU cycles
; 93 - 33 = 60 cycles to delay
;
    LDD     #11*$100+8              ; [3] Set A to 11 and B to 8, 8 data bits to count in the SEND_LOOP below
    BSR     DELAY_LOOP2             ; [7] Delay is A * 5 + 5 = A * 5 + 5 = 11 * 5 + 5 = 60 cycles
;
SEND_LOOP2:
    LSR     ,S                      ; Shift Least significant bit to carry (6)
    LDA     PIA1A_DATA              ; Get Port A (5) ($FF20)
    ANDA    #%11111101              ; Clear TX bit (2)
    BCC     SEND_ZERO               ; If carry=0, keep low (3)
    ORA     #%00000010              ; Set high (2)
SEND_ZERO:
    STA     PIA1A_DATA              ; Output bit (5) ($FF20)  93 - 36 CPU cyles to get here means the loop above must delay for 57 cpu cycles 
;
; At this point we need to delay 93 CPU cycles until the next bit is sent ($FF20)
; From here to the next     STA     PIA1A_DATA is 14+23 = 37 CPU cycles
; 93 - 37 = 56 cycles to delay
;
;    opt     cc       * show cycle count, add the counts, clear the current count
;
    LDA     #9                      ; [2] Set A to 9
    BSR     DELAY_LOOP2             ; [7] Delay is A * 5 + 5 = A * 5 + 5 = 9 * 5 + 5 = 50 cycles
    TFR     A,A                     ; [6] Waste CPU cycles, two bytes = 56 cycle delay
    DECB                            ; [2] Next bit
    BNE     SEND_LOOP2              ; [3] Loop
;
    FCB     $34,$00                 ; [5] Same as PSHS #0, so delay will be 93 cycles below
    LDA     PIA1A_DATA              ; [5] Stop bit: TX high (5)
    ORA     #%00000010              ; [2]
    STA     PIA1A_DATA              ; [5]
    PULS    A,B,PC                  ; [10] Restore and return
;
DELAY_LOOP2:
    DECA                            ; [2] cycles
    BNE     DELAY_LOOP2             ; [3] cycles
    RTS                             ; [5] cycles
;
; Table holds number of bytes the CoCoMP3 should respond with
DY_SV5W_ResponseTable:
    FCB     $00                     ; No command or response
    FCB     $05                     ; Check the play state              | AA   | 01   | 00     |            |            |            |            | AB   | AA 01 01 play state SM          | checkPlayState()
    FCB     $00                     ; Play                              | AA   | 02   | 00     |            |            |            |            | AC   | None                            | play()
    FCB     $00                     ; Pause                             | AA   | 03   | 00     |            |            |            |            | AD   | None                            | pause()
    FCB     $00                     ; Stop                              | AA   | 04   | 00     |            |            |            |            | AE   | None                            | stop()
    FCB     $00                     ; Previous music                    | AA   | 05   | 00     |            |            |            |            | AF   | None                            | previous()
    FCB     $00                     ; Next music                        | AA   | 06   | 00     |            |            |            |            | B0   | None                            | next()
    FCB     $00                     ; Play specified music              | AA   | 07   | 02     | High Byte  | Low Byte   |            |            |      | None                            | playSpecified(uint16_t number)
    FCB     $80                     ; Specified device and path play    | AA   | 08   | Length | Device     | Path       |            |            |      | None                            | playSpecifiedDevicePath(device_t device, char *path)
    FCB     $05                     ; Check Device Online               | AA   | 09   | 00     |            |            |            |            | B3   | AA 09 01 device SM              | getDevice()
    FCB     $05                     ; Check Current Playing Device      | AA   | 0A   | 00     |            |            |            |            | B4   | AA 0A 01 device SM              | 
    FCB     $80                     ; Switch to selected device         | AA   | 0B   | 01     | Device     |            |            |            |      | None                            | setDevice(device_t device)
    FCB     $06                     ; Check Number Of all Music         | AA   | 0C   | 00     |            |            |            |            | B6   | AA 0C 02 High Byte Low Byte SM  | soundCount()
    FCB     $06                     ; Check Current Music               | AA   | 0D   | 00     |            |            |            |            | B7   | AA 0D 02 High Byte Low Byte SM  | getPlayingSound()
    FCB     $00                     ; Previous folder directory         | AA   | 0E   | 00     |            |            |            |            | B8   | None                            | previousDir (playDirSound_t track)
    FCB     $00                     ; Previous folder directory         | AA   | 0F   | 00     |            |            |            |            | B9   | None                            | previousDir (playDirSound_t track)
    FCB     $00                     ; End playing / End interlude       | AA   | 10   | 00     |            |            |            |            | BA   | None                            | stopInterlude()
    FCB     $06                     ; Check the first music in folder   | AA   | 11   | 00     |            |            |            |            | BB   | AA 11 02 High Byte Low Byte SM  | firstInDir()
    FCB     $06                     ; Check Number of music in folder   | AA   | 12   | 00     |            |            |            |            | BC   | AA 12 02 High Byte Low Byte SM  | soundCountDir()
    FCB     $00                     ; Set Volume                        | AA   | 13   | 01     | VOL        |            |            |            |      | None                            | setVolume(uint8_t volume)
    FCB     $00                     ; Volume +                          | AA   | 14   | 00     |            |            |            |            | BE   | None                            | volumeIncrease()
    FCB     $00                     ; Volume -                          | AA   | 15   | 00     |            |            |            |            | BF   | None                            | volumeDecrease()
    FCB     $00                     ; Select specified file to interlude| AA   | 16   | 03     | Device     | High Byte  | Low Byte   |            |      | None                            | interludeSpecified(device_t device, uint16_t number)
    FCB     $80                     ; Select specified path to interlude| AA   | 17   | Length | Device     | Path       |            |            |      | None                            | interludeSpecifiedDevicePath(device_t device, char *path)
    FCB     $00                     ; Cycle mode setting                | AA   | 18   | 01     | mode       |            |            |            |      | None                            | setCycleMode(play_mode_t mode)
    FCB     $00                     ; Set Cycle times                   | AA   | 19   | 02     | High Byte  | Low Byte   |            |            |      | None                            | setCycleTimes(uint16_t cycles)
    FCB     $00                     ; Set EQ                            | AA   | 1A   | 01     | EQ         |            |            |            |      | None                            | setEq(eq_t eq)
    FCB     $00                     ; Combination play setting          | AA   | 1B   | 04     | High Byte  | Low Byte   | High Byte  | Low Byte   |      | None                            | 
    FCB     $00                     ; End Combination play              | AA   | 1C   | 00     |            |            |            |            | C6   | None                            | 
    FCB     $00                     ; No command or response    
    FCB     $00                     ; No command or response
    FCB     $00                     ; Select but no play                | AA   | 1F   | 02     | High Byte  | Low Byte   |            |            |      | None                            | select(uint16_t number)

; Change any .MP3 to *MP3 or .WAV to *WAV as the CoCoMP3 requires *MP3 or *WAV
; Enter
; B = Length of the string
; X = string start
DotToAsterisk:
    PSHS    B,X                     ; Save string start location
    ABX                             ; move to the end of the string
    LDD     -4,X                    ; Get the last four bytes of this string
    LDU     -2,X                    ; ""
; Test for .MP3
    CMPD    #'.'*$100+'M'           ; Is it ".M"
    BNE     NotDotMP3               ; If not check for ".WAV"
    CMPU    #'P'*$100+'3'           ; Is it "P3"
    BEQ     FixDot                  ; If so then we found a dot to change to an asterisk
; Test for .WAV
NotDotMP3:
    CMPD    #'.'*$100+'W'           ; Is it ".W"
    BNE     LeaveAsIs               ; If not leave the string as it is 
    CMPU    #'A'*$100+'V'           ; Is it "AV"
    BNE     LeaveAsIs               ; If not leave the string as it is
FixDot:
    LDA     #'*'                    ; A = "*"
    STA     -4,X                    ; change the "." to "*"
LeaveAsIs:
    PULS    B,X,PC                  ; Restore and return
; Convert DECIMAL number to binary:
; Entry
; X points at the string of numbers
; Exit:
; X = Converted value
Deciaml2Binary:
    LDU     #$0000          ; Start with a value of zero
    PSHS    A,B,U             ; Save the Number of digits & start with a value of Zero
!   LDA     ,X+             ; Get next digit
    CMPA    #$30
    BLO     DoneDigits
    CMPA    #$39
    BHI     DoneDigits
    SUBA    #'0'            ; MASK OFF ASCII
    STA     ,S              ; SAVE DIGIT IN VO1
    LDD     2,S             ; GET ACCUMULATED LINE NUMBER VALUE
    CMPA    #24             ; LARGEST NUMBER IS $F9FF (63999) -
; (24*256+255)*10+9
    BHI         NumTooBig   ; SYNTAX ERROR IF TOO BIG
; MULT ACCD X 10
    ASLB                    ;
    ROLA                    ; TIMES 2
    ASLB                    ;
    ROLA                    ; TIMES 4
    ADDD    2,S             ; ADD 1 = TIMES 5
    ASLB                    ;
    ROLA                    ; TIMES 10
    ADDB    ,S              ; ADD NEXT DIGIT
    ADCA    #0              ; PROPAGATE CARRY
    STD     2,S             ; SAVE NEW ACCUMULATED LINE NUMBER
    DEC     1,S
    BNE     <               ; LOOP - PROCESS NEXT DIGIT
DoneDigits:
    PULS    A,B,X,PC
NumTooBig:
    LDD     #63999
    STD     1,S
    BRA     DoneDigits

; Code to handle the AUDIO_MODE command
AUDIO_MODE:
    TFR     X,D                     ; D = X
    STB     Audio_ModeSetting,PCR   ; 0 = leave audio setting untouched, <> 0 Always keep AUDIO ON
; If it's an audio always on we might as well set it by checking the play status
    LBSR    CoCoMP3_GET_PLAY_STATUS
    CLRA
    LDB     Audio_ModeSetting,PCR   ; 0 = leave audio setting untouched, <> 0 Always keep AUDIO ON
    LBRA    BackToUserWithD         ; D will = B

RestoreSpeed:
    JMP     SetCPUSpeed             ; Set the CoCo back to the speed it was and return

NormalSpeed:
    PSHS    D,X
; Bit zero is set Speed up ROM reads, 
    LDA     #$5A                    ; Command for GIME-X & GIME-Z for triple speed mode On or Off
    STA     >$FFD6                  ; CoCo 1/2 Normal speed
    STA     >$FFD8                  ; Put CoCo 3 in Normal speed mode (even if GIME X is at triple speed)
; Let's detect the CPU type:"
    LDX     #$8000                  ; X = $8000
    TFR     X,A                     ; If it's 6809 then A will equal $00, if it's a 6309 then A will now equal $80
    TSTA
    BEQ     SpeedIsNormal           ; If A = 0 then it's a 6809, skip trying to put it in Emulation mode
    FCB     $11,$3D,%00000000       ; otherwise, put the 6309 in emulation mode.  This is LDMD  #%00000000
SpeedIsNormal:
    PULS    D,X,PC

; Command Jump Table
CommandJumpTable:
    FDB     CoCoMP3_RETURN-CommandJumpTable                         ; $00 Command doesn't exist, just return to the user
    FDB     CoCoMP3_GET_PLAY_STATUS-CommandJumpTable                ; $01 (reponse = 0 not playing, 1 if it is playing) 
    FDB     CoCoMP3_PLAY-CommandJumpTable                           ; $02
    FDB     CoCoMP3_PAUSE-CommandJumpTable                          ; $03
    FDB     CoCoMP3_STOP-CommandJumpTable                           ; $04
    FDB     CoCoMP3_PREVIOUS-CommandJumpTable                       ; $05
    FDB     CoCoMP3_NEXT-CommandJumpTable                           : $06
    FDB     CoCoMP3_PLAY_TRACK_NUMBER-CommandJumpTable              ; $07
    FDB     CoCoMP3_PLAY_TRACK-CommandJumpTable                     ; $08
    FDB     CoCoMP3_GET_DRIVE_STATUS-CommandJumpTable               ; $09
    FDB     CoCoMP3_GET_CURRENT_PLAY_DRIVE-CommandJumpTable         ; $0A
    FDB     CoCoMP3_SWITCH_TO_SELECTED_DEVICE-CommandJumpTable      ; $0B
    FDB     CoCoMP3_GET_NUMBER_OF_TRACKS-CommandJumpTable           ; $0C
    FDB     CoCoMP3_GET_CURRENT_TRACK-CommandJumpTable              ; $0D
    FDB     CoCoMP3_PLAY_PREVIOUS_FOLDER-CommandJumpTable           ; $0E
    FDB     CoCoMP3_PLAY_NEXT_FOLDER-CommandJumpTable               ; $0F
    FDB     CoCoMP3_END_PLAYING-CommandJumpTable                    ; $10
    FDB     CoCoMP3_GET_FOLDER_DIR_TRACK-CommandJumpTable           ; $11 - Get the song number of the first song in a directory
    FDB     CoCoMP3_GET_TRACKS_IN_FOLDER-CommandJumpTable           ; $12 - Get number of tracks in a folder
    FDB     CoCoMP3_SET_VOL-CommandJumpTable                        ; $13
    FDB     CoCoMP3_VOL_UP-CommandJumpTable                         ; $14
    FDB     CoCoMP3_VOL_DOWN-CommandJumpTable                       ; $15
    FDB     CoCoMP3_SET_TRACK_INTERLUDE-CommandJumpTable            ; $16
    FDB     CoCoMP3_SET_PATH_INTERLUDE-CommandJumpTable             ; $17
    FDB     CoCoMP3_CYCLE_MODE_SETTING-CommandJumpTable             ; $18
    FDB     CoCoMP3_SET_CYCLE_TIMES-CommandJumpTable                ; $19
    FDB     CoCoMP3_SET_EQ-CommandJumpTable                         ; $1A
    FDB     CoCoMP3_COMBINATION_PLAY_SETTING-CommandJumpTable       ; $1B
    FDB     CoCoMP3_END_COMBINATION_PLAY-CommandJumpTable           ; $1C
    FDB     CoCoMP3_RETURN-CommandJumpTable                         ; $1D Command doesn't exist, just return to the user
    FDB     CoCoMP3_RETURN-CommandJumpTable                         ; $1E Command doesn't exist, just return to the user
    FDB     CoCoMP3_SELECT_BUT_NO_PLAY-CommandJumpTable             ; $1F

SpecialCommandJumpTable:
    FDB     CoCoMP3_TEST-CommandJumpTable                    ; $80
    FDB     CoCoMP3_VOL_MAX-CommandJumpTable                 ; $81
    FDB     CoCoMP3_RETURN-CommandJumpTable                  ; $82  Compiler doesn't use the GET_CPU_SPEED command, just return
    FDB     CoCoMP3_VOL_FADE-CommandJumpTable                ; $83
    FDB     AUDIO_MODE-CommandJumpTable                      ; $84
    FDB     CoCoMP3_RETURN-CommandJumpTable                  ; $85  Compiler doesn't use the SET_CPU_SPEED command, just return

Audio_ModeSetting   FCB     $01     ; 0 = leave audio setting untouched, <> 0 Always keep AUDIO ON
CPU_Speed_Setting   FCB     $00     ; CPU Speed setting, deafult is set speed to normal
ResponseCheck   RMB 1               ; Count of Retries receiving good bytes
ResponseBytes   RMB 7               ; Max bytes it can receive is 6 + 1 for the length, store the response here
ReturnCode      RMB 2               ; 16 value returned to user when command is completed
ReturnLimit     RMB 1               ; Counter to try before receiving bits
;
CodeByte        RMB 1               ; Code byte must be $AA (unless Raw codes are sent "HACKING?")
CommandNumber   RMB 1               ; Save the command number
LengthOfString  RMB 1               ; Save the length of the users supplied string
CommandString   RMB 6               ; Save string to send (most commands)
Checksum        RMB 1               ; Checksum for the command
RawBytes        RMB 1               ; Zero means not Raw byte, otherwise sending raw bytes
EndHere         EQU *               ; End address
LoadAddress     EQU $8000-EndHere
