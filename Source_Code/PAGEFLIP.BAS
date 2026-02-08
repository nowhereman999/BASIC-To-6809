' compileoptions -s16

' Example of doing page animation
' Must always setup the number of pages you will use as the
' first GMODE command in your program
' With this many pages you will require 64k and will need to use
' the cc1sl (CoCo Super Loader program) see the Manual.pdf

DIM S AS _BYTE ' Range of -128 to 127
DIM X AS _UNSIGNED _BYTE ' Range from 0 to 255
DIM Frames AS _UNSIGNED _BYTE ' RANGE 0 to 255

' First GMODE sets graphic mode and reserves 7 pages 0 to 6
GMODE 16, 6
GMODE , 0 ' Set the active graphics page to 0
GCLS 0 ' Colour the screen colour 0 which is black
Frames = 6 ' Number of frames to use
FOR X = 1 TO 2000 ' Draw some dots on the screen
    SET (RND(256) - 1, RND(192) - 1, 1)
NEXT X

FOR X = 1 TO Frames ' Copy page 0 to all the other pages
    40 GCOPY 0, X
NEXT X

' Draw and fill a circle on the screen
50 X = 20
FOR S = 0 TO Frames
    GMODE , S
    CIRCLE (X, 20), 11, 1
    PAINT (X, 20), 0, 1
    X = X + 10
NEXT S
' Ping Pong animation frames (Loops forever)
100 FOR S = 0 TO Frames
    GMODE , S: SCREEN 1, 1 ' Screen shows the selected page
    SOUND 10, 5
NEXT S
FOR S = Frames - 1 TO 1 STEP -1
    GMODE , S: SCREEN 1, 1 ' Screen shows the selected page
    SOUND 10, 5
NEXT S
GOTO 100

