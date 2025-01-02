' Example of doing page animation
' Must always setup the number of pages you will use as the first GMODE command in your program
' With this many pages you will require 64k and will need to use the cc1sl program (see the Manual.pdf)
GMODE 16,9 ' Reserve space for 9 pages of 256x192x2 color screen, max a 64k CoCo can use, not much room for actual program data too
GCLS 0
Frames=9
SCREEN 1,1
x=20 ' CoCo3  256x200x16 color mode
for s=1 to Frames
GMODE 16,s:GCLS 0
circle(x,20),11,1
paint(x,20),0,1
LINE(x-8,14)-(x+8,27),6
x=x+10
next s
' Show the frames
100 For s = 1 to Frames
GMODE 16,s
sound 10,5 ' Play sound and delay for between frames
next s
goto 100
999 goto 999
