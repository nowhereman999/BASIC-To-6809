* Enter with X pointing at HEX string
* B = length of the string (must be from 1 to 4)
* Returns with vaule in D
DforHexStringToD   RMB   2      * Save two bytes for the value that we are converting
HexStringToD:
        CLRA
        LDU     #DforHexStringToD
        STA     ,U+
        STA     ,U              * Clear the starting values of the converted number
        ABX                     * now points at the right most digit +1
        DECB                    * decrement B
        BMI     @ReturnZero     * If the value is <0 then we have a problem (B was not from 1 to 4)
@DoMore:
        LDA     ,-X             * x=x-1, A = right most digit
        SUBA    #'0             * A = A - asc value of '0' which is 48
        BLO     @ReturnZero     * If the value is <0 then we have a problem
        CMPA    #10             * Is a value > 9?
        BLO     >               * We are good to use it as is
* If it's higher than 9 then we need to cehck if it's a A-F
        SUBA    #17             * Subtract 17 to get the value in the range 0-5
        BLO     @ReturnZero     * If the value is <0 then we have a problem
        CMPA    #5              * Is a value > 5?
        BHI     @ReturnZero     * If the value is >5 then we have a problem
        ADDA    #10             * Add 10 to get the value in the range 10-15
!       STA     ,U              * Save the value @ U
        DECB                    * decrement B
        BMI     @Done           * If the value is was zero then we are done
        LDA     ,-X             * x=x-1, A = right most digit
        SUBA    #'0             * A = A - asc value of '0' which is 48
        BLO     @ReturnZero     * If the value is <0 then we have a problem
        CMPA    #10             * Is a value > 9?
        BLO     >               * We are good to use it as is
* If it's higher than 9 then we need to cehck if it's a A-F
        SUBA    #17             * Subtract 17 to get the value in the range 0-5
        BLO     @ReturnZero     * If the value is <0 then we have a problem
        CMPA    #5              * Is a value > 5?
        BHI     @ReturnZero     * If the value is >5 then we have a problem
        ADDA    #10             * Add 10 to get the value in the range 10-15
!       LSLA
        LSLA
        LSLA
        LSLA                    * Shift value to the left nibble
        ADDA      ,U            * Add it to the value of the stack
        STA       ,U            * Save it on the stack
        DECB                    * decrement B
        BMI     @Done           * If the value is was zero then we are done
        LEAU    -1,U            * move the U to the MSB location
        BRA     @DoMore         * Do some more
@ReturnZero:                    * We have a problem, return zero (DforHexStringToD will be zero at this point)
@Done:  LDD     DforHexStringToD  *
        RTS

