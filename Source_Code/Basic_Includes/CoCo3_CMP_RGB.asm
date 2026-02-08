; Setup the palette for CMP values
CoCo3_CMP:
      LDX   #PaletteCMP
      BRA   >
; Setup the palette for RGB values
CoCo3_RGB:
      LDX   #PaletteRGB
!     LDY   #$FFB0      ; Palette start
      TST   $FF02
!     TST   $FF03       ; Wait for vsync
      BPL   <
      LDB   #8
!     LDU   ,X++
      STU   ,Y++
      DECB
      BNE   <
      RTS

; Colours for the standard composite mode
PaletteCMP:
      FCB   $12,$24,$0B,$07,$3F,$1F,$09,$26,$00,$12,$00,$3F,$00,$12,$00,$26
; Colours for the standard RGB mode
PaletteRGB:
      FCB   $12,$36,$09,$24,$3F,$1B,$2D,$26,$00,$12,$00,$3F,$00,$12,$00,$26
