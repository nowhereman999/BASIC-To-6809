* Code needed for the input command
* Get the users input into the buffer KeyBuff
CommaCount   RMB     1          ; Number of commas found
GetInput:
        LDA     #'?             ; Load A with a ?
        JSR     PrintA_On_Screen   ; Go print A on screen @ Cursor Position
        LDA     #$20            ; Load A with a space
        JSR     PrintA_On_Screen   ; Go print A on screen @ Cursor Position
; Get keyboard input into a buffer   
        LDU     #KeyBuff        ; U = keyboard buffer start
        CLRB                    ; Clear buffer size counter
@Loop1  LDA     #$CF            ; White cursor
        JSR     PrintA_On_Screen   ; Go print A on screen @ Cursor Position
        DEC     CURPOS+1        ; Set next position to print on screen on top of the cursor
        BNE     >               ; ""
        DEC     CURPOS          ; ""
!       JSR     InKey           ; Get input
        TSTA                    ; was a key pressed?
        BEQ     <               ; If not then get some more
        CMPA    #$03            ; Was the Break key pressed?
        BEQ     EXITProgram     ; If so then leave the program
        CMPA    #$08            ; Was the Backspace key pressed?
        BNE     >               ; Skip forword if not
        TSTB                    ; Check buffer size counter
        BEQ     @Loop1          ; If it's zero then ignore Backspace key press
        DECB                    ; Decrement the buffer size counter
        LEAU    -1,U            ; Decrement the buffer pointer
        JSR     PrintA_On_Screen   ; Go print A on screen @ Cursor Position
        LDA     #$60            ; Load A with a space
        LDX     CURPOS          ; X = current cursor position
        STA     1,X             ; Save the space in the buffer
        BRA     @Loop1          ; Go get another keypress
!       JSR     PrintA_On_Screen   ; Go print A on screen @ Cursor Position
        CMPA    #$0D            ; Was the Enter key pressed?
        BEQ     @CheckCommas    ; Skip forword if it was ENTER
        STA     ,U+             ; Save keypress in the buffer
        INCB                    ; Increment the buffer size counter
        BNE     @Loop1          ; Keep going as long as we haven't reached 256 bytes for the input
        DECB                    ; Set B back to 255 for the buffer size counter
        LEAU    -1,U            ; Decrement the buffer pointer
        BRA     @Loop1          ; Go get another keypress
* User hit <ENTER>
; Check to see if we got enough commas or entries yet
@CheckCommas:         
        PSHS    B               ; Save B = buffer size on the stack
        PSHS    B               ; Save B = buffer size on the stack this time for a counter check
        LDU     #KeyBuff        ; U points at the start of the Input buffer + 1
        CLRA                    ; Clear A so D = B and our comma counter is zero
@CheckCommaLoop:
        LDB     ,U+             ; Get the value in the buffer
        CMPB    #',             ; Did we find a comma?
        BNE     >               ; No, check if we're at the beginning of the buffer
        INCA                    ; Otherwise if we did find a comma Increment the comma counter
!       DEC     ,S              ; Decrement buffer size check
        BNE     @CheckCommaLoop ; If not keep looping
        PULS    B               ; fix stack, we don't need the buffer counter anymore
* A = comma count
        CMPA    CommaCount      ; Do we have more commas than we need?
        BHI     @FixCommas      ; If so then print '?EXTRA IGNORED' and use only the number of comma's we need
        BEQ     @CommasGood     ; If we have the correct amount of Comma's then we're good exit, put a ","
; Otherwise we have to print ?? and get more input
        BSR     >               ; Go print '??'
        FCC     '?? '            ; Print??
!       LDX     ,S++            ; X points at the string to print
        LDB     #2              ; B = number of characters to print
!       LDA     ,X++            ; Get the next character to print
        JSR     PrintA_On_Screen   ; Go print A on screen @ Cursor Position
        DECB                    ; Decrement the number of characters to print
        BNE     <               ; Keep going if there are more characters to print
        PULS    B               ; Restore B from the stack
        LDU     #KeyBuff        ; U points at the start of the Input buffer
        CLRA
        LEAU    D,U             ; U points at the correct posisiton to carry on getting more input
        LDA     #',             ; Add a semi-colon here
        STA     ,U+             ; buffer now ends with a semi-colon
        INCB                    ; Increment the buffer size counter
        BRA     @Loop1          ; Go get some more input
* We have too many commas
@FixCommas:
        INC     CommaCount      ; Increment the number of commas, so our dec CommaCount works properly below
; Check and keep only the required characters, print '?EXTRA IGNORED' if there are too many commas
        LDB     ,S              ; B=Buffer size
        BEQ     @SkipCommaCheck ; If the buffer is zero then skip checking for a comma
        CLRB                    ; Clear our new buffer size counter
        LDU     #KeyBuff        ; U points at the start of the Input buffer
@KeepGoing:
        INCB                    ; Incrment the buffer size counter
        LDA     ,U+             ; Get the next value in the buffer
        CMPA    #',             ; Did we find a comma?
        BEQ     >               ; Found a comma go print '?EXTRA IGNORED' and use only the value before the comma
        BNE     @KeepGoing      ; Keep going until we find a comma or reach the end of the buffer
        BRA     @CommasGood     ; If we get here then we found the end of the string, leave as is
!       DEC     CommaCount      ; Decrement the comma counter
        BNE     @KeepGoing      ; if not zero then keep checking for more commas
        STB     ,S              ; Save the new length of the string on the stack
        BSR     >               ; Print '?EXTRA IGNORED'
        FCC     '?EXTRA IGNORED'   
        FCB     $0D             ; Add ENTER
!       LDX     ,S++            ; Get the new start address of the string to print
        LDB     #15             ; Set B to 15, the length of the string to print
!       LDA     ,X+             ; Get a character to print
        JSR     PrintA_On_Screen   ; Go print A on screen @ Cursor Position
        DECB                    ; Decrement the length counter
        BNE     <               ; Keep going until we've printed the entire string
@CommasGood:
        LDB     ,S              ; Restore B, get the buffer size
        LDU     #KeyBuff        ; U = keyboard buffer start
        CLRA                    ; Clear A
        LEAU    D,U             ; U = keyboard buffer start + B
        LDA     #',             ; Add a comma to the end of the string
        STA     ,U              ; Add the comma to the end of the string as a terminator
@SkipCommaCheck  
        PULS    B,PC            ; Restore the buffer size (fix the stack) and return

ShowREDO:                      ; If we get here, then the numeric value contains characters other then a number
        BSR     >             
        FCC     '?REDO'       
!       LDX     ,S++          
        LDB     #$05          
!       LDA     ,X+           
        JSR     PrintA_On_Screen   ; Go print A on screen @ Cursor Position
        DECB                  
        BNE     <             
        LDA     #$0D          ; A=ENTER
        JMP     PrintA_On_Screen   ; Go print A on screen @ Cursor Position and return        
