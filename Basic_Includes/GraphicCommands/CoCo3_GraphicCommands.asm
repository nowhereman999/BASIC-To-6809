; HSET a dot on CoCo 3 256x256, 16 colour screen
; Enter with:
; A = y coordinate
; B = x coordinate
;
HCursor RMB 2           * Y & X co-ordinates
Colour  RMB 1           * Colour to draw pixel

HSet256_16:
* Coco 3 Screen resolution is 256 x 192 x 16 colours, starting at $0000
* each row is 128 bytes
      PSHS  A           * Save the colour on the stack
      LDU   #$C000      * Screen start location
      LDD   HCursor     * D = address, A = y - co-ordinate, B = x - co-ordinate
      ANDA  #$3F        * Keep the bottom 6 bits (range of 0 to 63 for the Y)
      LSRA
      RORB              * 1/2 and move bit zero to the carry
      LEAU  D,U         * U has the screen location
      LDB   ,S          * B = colour
      BCS   >           * If carry is set then it is an odd number (right nibble used)

      LDA   #$0F        * Prepare to clear the left nibble and keep the right nibble as it is
      ANDA  ,U          * A = the original pixel value for the old nibble
      ANDB  #$F0        * Keep the left nibble colour
      STB   ,S          * Save it on the stack
      ORA   ,S          * A = A logical OR B
      STA   ,U          * Write the new value to the screen
      PULS  A,PC

!     LDA   #$F0        * Prepare to clear the right nibble and keep the left nibble as it is
      ANDA  ,U          * A = the original pixel value for the Even nibble
      ANDB  #$0F        * Keep the right nibble colour
      STB   ,S          * Save it on the stack
      ORA   ,S          * A = A logical OR with the colour
      STA   ,U          * Write the new value to the screen
      PULS  A,PC        * restore A and return
