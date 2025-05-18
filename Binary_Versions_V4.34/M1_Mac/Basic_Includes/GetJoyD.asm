
GetJoyD:
***********************************************************************************
* Joystick support
* Mux values bit 3 on PIA 0 Side A = $FF01 and Side B = $FF03
* $FF03   $FF01
* MSb 0 & LSb 0  = Joystick 0 (Right) Horizontal input
* MSb 0 & LSb 1  = Joystick 0 (Right) Vertical   input
* MSb 1 & LSb 0  = Joystick 1  (Left) Horizontal input
* MSb 1 & LSb 1  = Joystick 1  (Left) Vertical   input
***********************************************************
        opt     c,ct,cc       * show cycle count, add the counts, clear the current count
        LDX     #$FF00                  * PIA0_Byte_0_KeyRow_Joy	* $FF00 
        LDU     #$FF20                  * PIA1_Byte_0_IRQ		* $FF20
        LDA     $FF23                   * PIA1_Byte_3_IRQ_Ct_Snd	* $FF23
        ANDA    #%11110111              * clear bit 3 (disable audio)
        STA     $FF23                   * PIA1_Byte_3_IRQ_Ct_Snd	* $FF23
;        ORCC    #%01010000              * Disable interrupts so we don't mess this up when the sound/timer IRQ fires
        LDB     ,U                      * PIA1_Byte_0_IRQ         * save the original 6-bit audio output value   $FF20

* Right joystick Horizontal value (Right/Left movement) input
Joystick0_X:
	LDA	#$34		        * A = $34 which disables the VSYNC IRQ
        STA     $FF03           	* $FF03   - A = $34 = 0011 0100 Bit 3 is the MSb of the MUX line, value sets it to 0
        STA     $FF01           	* $FF01   - A = $34 = 0011 0100 Bit 3 is the LSb of the MUX line, value sets it to 0
* Above just selected MSb 0 & LSb 0 of Mux which selects Right joystick Horizontal value (Right left movement) input
	LDA	#$67
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        STA     ,U      		* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        NOP				* Wait to make sure the value is registered
        NOP				* ""
        NOP				* ""
        TST     ,X			* Check value in $FF00
        BPL     Joystick0_X_is_Left	* If bit 7 is a 0 then it is lower then this value, jump to set Joystick is in the left position
        LDA     #$9A                    * test for high value on selected axis = 1001 1010 6 bit range is 10 0110 = $26 = 38
        STA     ,U			* $FF20   - Store test for 38
        STA     ,U			* $FF20   - Store test for 38
        NOP				* Wait to make sure the value is registered
        NOP				* ""
        NOP			        * "" ""
        TST     ,X			* Check value in $FF00
        BPL     Joystick0_X_is_Middle	* If bit 7 is a 0 then it is lower then this value so skip to save as middle position, otherwise
					* Fall through and set it as the right position
Joystick0_X_is_Right:
        LDA     #63                     * X is in Right position
        BRA     GotJoystick0_X
Joystick0_X_is_Left:
        CLRA                            * X is in Left position
        BRA     GotJoystick0_X
Joystick0_X_is_Middle:			* If it's in the center then make it zero
	LDA     #31             	* If it's in the center then make it 31
GotJoystick0_X:
        STA     $015D                   * Save as the right joystick horizontal value

	LDA	#$34
        STA     $FF03			* $FF03   - A = $34 = 0011 0100 Bit 3 is the MSb of the MUX line, value sets it to 0
	LDA	#$3C
        STA     $FF01			* $FF01   - A = $3C = 0011 0100 Bit 3 is the LSb of the MUX line, value sets it to 1
* Above just selected MSb 0 & LSb 1 of Mux which selects Right joystick Vertical value (Up and Down movement) input
	LDA	#$67
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        NOP				* Wait to make sure the value is registered
        NOP				* ""
        NOP				* ""
        TST     ,X			* Check value in $FF00
        BPL     Joystick0_Y_is_Up	* If bit 7 is a 0 then it is lower then this value, jump to set Joystick is in the Up position
        LDA     #$9A                    * test for high value on selected axis = 1001 1010 6 bit range is 10 0110 = $26 = 38
        STA     ,U			* $FF20   - Store test for 38
        STA     ,U			* $FF20   - Store test for 38
        NOP				* Wait to make sure the value is registered
        NOP				* ""
        NOP				* ""
        TST     ,X			* Check value in $FF00
        BPL     Joystick0_Y_is_Middle	* If bit 7 is a 0 then it is lower then this value so skip to save as middle position, otherwise
					* Fall through and set it as the down position
Joystick0_Y_is_Down:
        LDA     #63                     * Y is in Down position
        BRA     GotJoystick0_Y
Joystick0_Y_is_Up:
        CLRA                            * Y is in Up position
        BRA     GotJoystick0_Y
Joystick0_Y_is_Middle:
        LDA     #31             	* If it's in the center then make it 31
GotJoystick0_Y:
        STA     $015C                   * Save as the right joystick vertical value

* Left joystick Horizontal value (Right/Left movement) input
Joystick1_X:
	LDA	#$3C
        STA     $FF03			* $FF03   - A = $3C = 0011 1100 Bit 3 is the MSb of the MUX line, value sets it to 1
	LDA	#$34
        STA     $FF01			* $FF01   - A = $34 = 0011 0100 Bit 3 is the LSb of the MUX line, value sets it to 0
* Above just selected MSb 1 & LSb 0 of Mux which selects Left joystick Horizontal value (Right left movement) input
	LDA	#$67
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        NOP				* Wait to make sure the value is registered
        NOP				* ""
        NOP				* ""
        TST     ,X			* Check value in $FF00
        BPL     Joystick1_X_is_Left	* If bit 7 is a 0 then it is lower then this value, jump to set Joystick is in the left position
        LDA     #$9A                    * test for high value on selected axis = 1001 1010 6 bit range is 10 0110 = $26 = 38
        STA     ,U			* $FF20   - Store test for 38
        STA     ,U			* $FF20   - Store test for 38
        NOP				* Wait to make sure the value is registered
        NOP				* ""
        NOP			        * "" ""
        TST     ,X			* Check value in $FF00
        BPL     Joystick1_X_is_Middle	* If bit 7 is a 0 then it is lower then this value so skip to save as middle position, otherwise
					* Fall through and set it as the Right position
Joystick1_X_is_Right:
        LDA     #63                     * X is in Right position
        BRA     DoneJoystick1_X
Joystick1_X_is_Left:
        CLRA                            * X is in Left position
        BRA     DoneJoystick1_X
Joystick1_X_is_Middle:
        LDA     #31             	* If it's in the center then make it 31
DoneJoystick1_X:
        STA     $015B                   * Save as the left joystick horizontal value

* Left joystick Horizontal value (Right/Left movement) input
Joystick1_Y:
	LDA	#$3C
        STA     $FF03			* $FF03   - A = $3C = 0011 1100 Bit 3 is the MSb of the MUX line, value sets it to 1
        STA     $FF01			* $FF01   - A = $3C = 0011 1100 Bit 3 is the LSb of the MUX line, value sets it to 1
* Above just selected MSb 1 & LSb 1 of Mux which selects Left joystick Vertical value (Up and down movement) input
	LDA	#$67
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        STA     ,U			* $FF20   -  A = $67 test for low value on selected axis = 0110 0111 6 bit range is 01 1001 = $19 = 25
        NOP				* Wait to make sure the value is registered
        NOP				* ""
        NOP				* ""
        NOP	        		* ""
        TST     ,X			* Check value in $FF00
        BPL     Joystick1_Y_is_Up       * If bit 7 is a 0 then it is lower then this value, jump to set Joystick is in the left position
        LDA     #$9A                    * test for high value on selected axis = 1001 1010 6 bit range is 10 0110 = $26 = 38
        STA     ,U			* $FF20   - Store test for 38
        STA     ,U			* $FF20   - Store test for 38
        NOP				* Wait to make sure the value is registered
        NOP				* ""
        NOP				* ""
        TST     ,X			* Check value in $FF00
        BPL     Joystick1_Y_is_Middle	* If bit 7 is a 0 then it is lower then this value so skip to save as middle position, otherwise
					* Fall through and set it as the Right position
Joystick1_Y_is_Down:
        LDA     #63                     * Y is in Down position
        BRA     DoneJoystick1_Y
Joystick1_Y_is_Up:
        CLRA                            * Y is in Up position
        BRA     DoneJoystick1_Y
Joystick1_Y_is_Middle:
        LDA     #31             	* If it's in the center then make it 31
DoneJoystick1_Y:
        STA     $015A                   * Save as the left joystick vertical value

* Exit Joystick reading routine
        STB     ,U                      * PIA1_Byte_0_IRQ         * restore the previous DAC value (for audio)
* DAC6 mode: re-enable audio output
        LDA     $FF23                   * PIA1_Byte_3_IRQ_Ct_Snd	* $FF23
        ORA     #%00001000              * Set bit 3 (enable audio)
        STA     $FF23                   * PIA1_Byte_3_IRQ_Ct_Snd	* $FF23
        RTS