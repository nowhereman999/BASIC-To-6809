; Do a SDC_LOADM command
; File must already be Initialized
; *** Enter with: Y pointing at the FATBLx associated with the drive DCDRV
; * Loads a  Machine Language file from the SDC
; Adds the 16 bit value stored in _Var_PF10 to the Load Address and the EXEC address
; File is setup to start reading from the disk using the following for an ML file
; BYTE        PREAMBLE                POSTAMBLE
; 0           ØØ Preamble flag        $FF Post-amble flag
; 1, 2        Length of data block    Two zero bytes
; 3, 4        Load address            EXEC address

SDCLoadM0:
        CLRA                    ; Read mode
        JSR     SDCOpenFile     ; Open the file, A = File read mode (0) or write mode (1), B = File number (0 or 1)
SDC_GetMLBlock0:
        BSR     SDCGetByteB0    ; Get the next byte in file 0 and return with it in B
        TSTB
        BEQ     SDC_DoPREAMBLE0  ; Skip ahead if it's a PREAMBLE
; If we get here then we have reached the end of the file
; Postamble
        CMPB    #$FF            ; Make sure it's the post-amble flag
        BNE     SDC_DiskErrorBadMLFile     ; Bad file format if not
        BSR     SDC_GetWordD0    ; Read next two bytes into D
        CMPD    #$0000          ; Make sure it's two zero bytes
        BNE     SDC_DiskErrorBadMLFile     ; Bad file format if not
        BSR     SDC_GetWordD0    ; Read next two bytes into D
        ADDD    _Var_PF10       ; D = D + LOADM Offset amount    
        JMP     SDC_CloseFile0  ; File has been LOADMed into memory, Close the file 0 & return

SDC_DoPREAMBLE0:
        BSR     SDC_GetWordD0    ; Read next two bytes into D    
        TFR     D,X             ; X = Length of data block
        BSR     SDC_GetWordD0    ; Read next two bytes into D
        ADDD    _Var_PF10       ; D = D + LOADM Offset amount    
        TFR     D,U             ; U = Load address
!       BSR     SDCGetByteB0   ; Get a byte from the file in B
        STB     ,U+             ; Save the byte to memory
        LEAX    -1,X            ; Decrement the counter
        BNE     <               ; Keep looping until we've copied all the bytes
        BRA     SDC_GetMLBlock0 ; Go read the next block

; Read next two bytes from the open file into D
SDC_GetWordD0:
        BSR     SDCGetByteB0    ; Get the next byte in file 0 and return with it in B
        TFR     B,A             ; Move B to MSB of D
        BRA     SDCGetByteB0    ; Get the next byte in file 0 in B and return, D now has the WORD from the file

SDCLoadM1:
        CLRA                    ; Read mode
        JSR     SDCOpenFile     ; Open the file, A = File read mode (0) or write mode (1), B = File number (0 or 1)
SDC_GetMLBlock1:
        BSR     SDCGetByteB1    ; Get the next byte in file 1 and return with it in B
        TSTB
        BEQ     SDC_DoPREAMBLE1 ; Skip ahead if it's a PREAMBLE
; If we get here then we have reached the end of the file
; Postamble
        CMPB    #$FF            ; Make sure it's the post-amble flag
        BNE     SDC_DiskErrorBadMLFile     ; Bad file format if not
        BSR     SDC_GetWordD1   ; Read next two bytes into D
        CMPD    #$0000          ; Make sure it's two zero bytes
        BNE     SDC_DiskErrorBadMLFile     ; Bad file format if not
        BSR     SDC_GetWordD1   ; Read next two bytes into D
        ADDD    _Var_PF10       ; D = D + LOADM Offset amount    
        STD     EXECAddress     ; Save the EXEC address
        JMP     SDC_CloseFile1  ; File has been LOADMed into memory, Close the file 1 & return

SDC_DoPREAMBLE1:
        BSR     SDC_GetWordD1   ; Read next two bytes into D  
        TFR     D,X             ; X = Length of data block
        BSR     SDC_GetWordD1   ; Read next two bytes into D
        ADDD    _Var_PF10       ; D = D + LOADM Offset amount    
        TFR     D,U             ; U = Load address
!       BSR     SDCGetByteB1    ; Get a byte from the file in B
        STB     ,U+             ; Save the byte to memory
        LEAX    -1,X            ; Decrement the counter
        BNE     <               ; Keep looping until we've copied all the bytes
        BRA     SDC_GetMLBlock1 ; Go read the next block

; Read next two bytes from the open file into D
SDC_GetWordD1:
        BSR     SDCGetByteB1    ; Get the next byte in file 1 and return with it in B
        TFR     B,A             ; Move B to MSB of D
        BRA     SDCGetByteB1    ; Get the next byte in file 1 in B and return, D now has the WORD from the file

; SDC still busy - too long to respond
SDC_DiskErrorBadMLFile:
        BSR     >               ; Skip over string value
        FCC     "LOADM ERROR: BAD FILE FORMAT"
        FCB     $0D,00          ; CR and end string
!       LDU     ,S++            ; Load U with the string start location off the stack and fix the stack
        BRA     SDCShowError    ; Show Error message and halt program

; Do an SDC_SaveM command
; File must already be Initialized
; *** Enter with: Y pointing at the FATBLx associated with the drive DCDRV
; * Loads a  Machine Language file from the SDC
; Adds the 16 bit value stored in _Var_PF10 to the Load Address and the EXEC address
; File is setup to start reading from the disk using the following for an ML file
; BYTE        PREAMBLE                POSTAMBLE
; 0           ØØ Preamble flag        $FF Post-amble flag
; 1, 2        Length of data block    Two zero bytes
; 3, 4        Load address            EXEC address
;
; 6,S = Start Address
; 4,S = End Address
; 2,S = EXECute Address
SDCSaveM0:
        LDA     #$01            ; Open the file in write mode
        JSR     SDCOpenFile     ; Open the file, A = File read mode (0) or write mode (1), B = File number (0 or 1)
; Write Preamble
        CLRB
        JSR     SDCPutByteB0    ; Send B to the SDC file 0 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        LDD     4,S             ; D = End Address
        SUBD    6,S             ; D = End address - Start address = length
        ADDD    #$0001
        TFR     D,X             ; Save the length in X
        EXG     A,B             ; B = MSB of length
        JSR     SDCPutByteB0    ; Send B to the SDC file 0 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        TFR     A,B             ; B = LSB of the length
        JSR     SDCPutByteB0    ; Send B to the SDC file 0 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        LDB     6,S             ; Get MSB of Start address
        JSR     SDCPutByteB0    ; Send B to the SDC file 0 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        LDB     7,S             ; Get LSB of the Start address
        JSR     SDCPutByteB0    ; Send B to the SDC file 0 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        LDX     6,S             ; Get the Start address
!       LDB     ,X+             ; Get the byte from memory
        JSR     SDCPutByteB0    ; Send B to the SDC file 0 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        CMPX    4,S             ; Compare to the End address
        BLS     <               ; Loop until we've copied all the bytes

; Write Postamble
        LDB     #$FF            ; Load the postamble flag
        JSR     SDCPutByteB0    ; Send B to the SDC file 0 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        CLRB
        JSR     SDCPutByteB0    ; Send B to the SDC file 0 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        JSR     SDCPutByteB0    ; Send B to the SDC file 0 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        LDB     2,S             ; Get the MSB of the EXEC address
        JSR     SDCPutByteB0    ; Send B to the SDC file 0 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        LDB     3,S             ; Get the LSB of the EXEC address
        JSR     SDCPutByteB0    ; Send B to the SDC file 0 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        JMP     SDC_CloseFile0  ; Close the file 0 and return

SDCSaveM1:
        LDA     #$01            ; Open the file in write mode
        JSR     SDCOpenFile     ; Open the file, A = File read mode (0) or write mode (1), B = File number (0 or 1)
; Write Preamble
        CLRB
        JSR     SDCPutByteB1    ; Send B to the SDC file 1 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        LDD     4,S             ; D = End Address
        SUBD    6,S             ; D = End address - Start address = length
        ADDD    #$0001
        TFR     D,X             ; Save the length in X
        EXG     A,B             ; B = MSB of length
        JSR     SDCPutByteB1    ; Send B to the SDC file 1 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        TFR     A,B             ; B = LSB of the length
        JSR     SDCPutByteB1    ; Send B to the SDC file 1 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        LDB     6,S             ; Get MSB of Start address
        JSR     SDCPutByteB1    ; Send B to the SDC file 1 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        LDB     7,S             ; Get LSB of the Start address
        JSR     SDCPutByteB1    ; Send B to the SDC file 1 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        LDX     6,S             ; Get the Start address
!       LDB     ,X+             ; Get the byte from memory
        JSR     SDCPutByteB1    ; Send B to the SDC file 1 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        CMPX    4,S             ; Compare to the End address
        BLS     <               ; Loop until we've copied all the bytes

; Write Postamble
        LDB     #$FF            ; Load the postamble flag
        JSR     SDCPutByteB1    ; Send B to the SDC file 1 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        CLRB
        JSR     SDCPutByteB1    ; Send B to the SDC file 1 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        JSR     SDCPutByteB1    ; Send B to the SDC file 1 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        LDB     2,S             ; Get the MSB of the EXEC address
        JSR     SDCPutByteB1    ; Send B to the SDC file 1 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        LDB     3,S             ; Get the LSB of the EXEC address
        JSR     SDCPutByteB1    ; Send B to the SDC file 1 buffer, when the buffer reaches 256 bytes, it will be written to the SDC
        JMP     SDC_CloseFile1  ; Close the file 0 and return
        