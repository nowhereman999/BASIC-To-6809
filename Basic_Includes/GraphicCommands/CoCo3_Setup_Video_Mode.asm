* Enter with value in A for the graphics mode requested
* See list of most of the modes below:
HSCREEN:
* Put the CoCo 3 in the correct mode
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
*    xxxxxx10   16          2
*    xxxxxx11   Undefined   Undefined
***********************************************************
* Most Common used settings (Uncomment the one you want to use)
*       LDA     #%01110010            	* 128 x 192 x 16 Colours requires 12,288 bytes = $3000 RAM
*       LDA     #%01110010            	* 128 x 200 x 16 Colours requires 12,800 bytes = $3200 RAM
*       LDA     #%01110010            	* 128 x 225 x 16 Colours requires 14,400 bytes = $3840 RAM
*       LDA     #%00001000            	* 256 x 192 x 2 Colours  requires 6,144  bytes = $1800 RAM
*       LDA     #%00101000            	* 256 x 200 x 2 Colours  requires 6,400  bytes = $1900 RAM
*       LDA     #%01101000            	* 256 x 225 x 2 Colours  requires 7,200  bytes = $1C20 RAM
*       LDA     #%00010001            	* 256 x 192 x 4 Colours  requires 12,288 bytes = $3000 RAM
*       LDA     #%00110001            	* 256 x 200 x 4 Colours  requires 12,800 bytes = $3200 RAM
*       LDA     #%01110001            	* 256 x 225 x 4 Colours  requires 14,400 bytes = $3840 RAM
*       LDA     #%00011010            	* 256 x 192 x 16 Colours requires 24,576 bytes = $6000 RAM
*       LDA     #%00111010            	* 256 x 200 x 16 Colours requires 25,600 bytes = $6400 RAM
*       LDA     #%01111010            	* 256 x 225 x 16 Colours requires 28,800 bytes = $7080 RAM
*       LDA     #%00001100            	* 320 x 192 x 2 Colours  requires 7,680  bytes = $1E00 RAM
*       LDA     #%00101100            	* 320 x 200 x 2 Colours  requires 8,000  bytes = $1F40 RAM
*       LDA     #%01101100            	* 320 x 225 x 2 Colours  requires 10,240 bytes = $2800 RAM
*       LDA     #%00010101            	* 320 x 192 x 4 Colours  requires 15,360 bytes = $3C00 RAM
*       LDA     #%00110101            	* 320 x 200 x 4 Colours  requires 16,000 bytes = $3E80 RAM
*       LDA     #%01110101            	* 320 x 225 x 4 Colours  requires 18,000 bytes = $4650 RAM
*       LDA     #%00011110            	* 320 x 192 x 16 Colours requires 30,720 bytes = $7800 RAM
*       LDA     #%00111110            	* 320 x 200 x 16 Colours requires 32,000 bytes = $7D00 RAM
*       LDA     #%01111110            	* 320 x 225 x 16 Colours requires 36,000 bytes = $8CA0 RAM
*       LDA     #%00010100            	* 640 x 192 x 2 Colours  requires 15,360 bytes = $3C00 RAM
*       LDA     #%00110100            	* 640 x 200 x 2 Colours  requires 16,000 bytes = $3E80 RAM
*       LDA     #%01110100            	* 640 x 225 x 2 Colours  requires 18,000 bytes = $4650 RAM
*       LDA     #%00011101            	* 640 x 192 x 4 Colours  requires 30,720 bytes = $7800 RAM
*       LDA     #%00111101            	* 640 x 200 x 4 Colours  requires 32,000 bytes = $7D00 RAM
*       LDA     #%01111101            	* 640 x 225 x 4 Colours  requires 36,000 bytes = $8CA0 RAM
*
* Wait for VSync, so the user doesn't see any flickering on the screen
        TST     $FF02                   * Tickle the Data register, this clears bit 7 of the Control Register
!       TST     $FF03                   * Is Bit 7 set of the Control Register?
        BPL    <                        * If not, keep looping, until the vertical sync occurs

        LDA     #%01111100              *
        STA     $FF90                   * CoCo 3 Mode, MMU Enabled, GIME IRQ Enabled, GIME FIRQ Enabled, Vector RAM at FEXX enabled, Standard SCS Normal, ROM Map 16k Int, 16k Ext
        LDA     #%00100000              *
        STA     $FF91                   * Mem Type 64k chips, 279.365 nsec timer, MMU Task 0 - $FFA0-$FFA7

        STB     $FF99                   * Send to the video resolution register
        LDA     #%10000000              *
        STA     $FF98                   * Graphics mode, Colour output, 60 hz, max vertical res
***********************************************************
        LDD     #ScreenTop*$400         * Bank # * $0400 to start video display at that bank
        STD     $FF9D              	* Update video Pointer
        CLR     $FF9F                   * Don't use a Horizontal offset
        RTS