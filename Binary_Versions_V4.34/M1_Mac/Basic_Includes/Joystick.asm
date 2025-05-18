; Entry with B = 0 to 3
; If B=0 then read all joysticks (just like regular BASIC)
; Return with value of Joystick in ACCB
JOYSTK:         TSTB                        ;  SET FLAGS
                BNE         LA9D4           ; GET NEW DATA ONLY IF JOYSTK(0)
                PSHS        B               ; SAVE ACCB
                BSR         GETJOY          ; GET NEW DATA FOR ALL JOYSTICKS
                PULS        B               ; WHICH JOYSTICK DID YOU WANT?
LA9D4           LDX         #$015A          ; POINT X TO JOYSTICK DATA BUFFER
                LDB         B,X             ; PUT ITS DATA INTO ACCB   
                CLRA
                RTS

; JOYSTK DATA AT:
; $15A $15B $15C $15D
; LEFT LEFT RIGHT RIGHT
; VERT HORIZ VERT HORIZ
; THIS IS A 6 BIT SOFTWARE A/D CONVERSION ROUTINE
GETJOY          BSR         AnalogMuxOff    ; TURN OFF AUDIO
                LDX         #$015E          ; POINT X TO JOYSTICK DATA BUFFER
                LDB         #3              ; GET FOUR SETS OF DATA (4 JOYSTICKS)
LA9E5           LDA         #10             ; 10 TRIES TO GET STABLE READING
                STD         ,--S            ; STORE JOYSTICK NUMBER AND TRY NUMBER ON THE STACK
                BSR         Select_AnalogMuxer ; SET THE SELECT INPUTS ON ANALOG MULTIPLEXER
LA9EB           LDD         #$4080          ; ACCA IS A SHIFT COUNTER OF HOW MANY BITS TO CONVERT
; AND WIlL BE $40 (6 BITS) FOR THE COLOR
; COMPUTER. ACCB CONTAINS A VALUE EQUAL TO 1/2
; THE CURRENT TRIAL DIFFERENCE. INITIALLY =$80 (2.5 VOLTS).
LA9EE           STA         ,-S             ; TEMP STORE SHIFT COUNTER ON STACK
                ORB         #2              ; KEEP RS 232 SERIAL OUT MARKING
                STB         $FF20           ; STORE IN D/A CONVERTER
                EORB        #2              ; PUT R5232 OUTPUT BIT BACK TO ZERO
                LDA         $FF00           ; HIGH BIT IS FROM COMPARATOR
                BMI         LA9FF           ; BRANCH IF COMPARATOR OUTPUT IS HIGH
                SUBB        ,S              ; SUBTRACT 1/2 THE CURRENT TRIAL DIFFERENCE
                FCB         $8C            ; SKIP NEXT TWO BYTES
LA9FF           ADDB        ,S              ; ADD 1/2 OF THE CURRENT TRIAL DIFFERENCE
                LDA         ,S+             ; PULL SHIFT COUNTER OFF THE STACK
                LSRA                        ;  SHIFT IT RIGHT ONCE
                CMPA        #1              ; HAVE ALL THE SHIFTS BEEN DONE?
                BNE         LA9EE           ; NO
                LSRB                        ;  YES - THE DATA IS IN THE TOP 6 BYTES OF ACCB
                LSRB                        ;  PUT IT INTO THE BOTTOM SIX
                CMPB        -1,X            ; IS THIS VALUE EQUAL TO THE LAST TRY?
                BEQ         LAA12           ; YES - GO SAVE THE VALUE
                DEC         ,S              ; NO-DECREMENT TRIES COUNTER
                BNE         LA9EB           ; BRANCH IF YOU HAVENT TRIED 10 TIMES
; IF YOU FALL THROUGH HERE YOU HAVE TRIED TO GET THE SAME READING
; 10 TIMES AND NEVER GOTTEN A MATCH. AS A RESULT YOU JUST FALL
; THROUGH AND USE THE LAST VALUE READ IN.
LAA12           STB         ,-X             ; SAVE THE DIGITIZED VALUE
                LDD         ,S++            ; GET THE NUMBER OF THE JOYSTICK JUST DONE
                DECB                        ; DECR JOYSTK NUMBER
                BPL         LA9E5           ; BRANCH IF THE LAST ONE DONE WASNT NUMBER 0
                RTS
             