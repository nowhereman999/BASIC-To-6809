GMODE 16,9:GCLS 0
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

100 For s = 1 to Frames
GMODE 16,s
sound 10,5
next s
goto 100
999 goto 999
