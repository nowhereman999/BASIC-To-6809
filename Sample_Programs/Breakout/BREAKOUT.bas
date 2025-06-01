' compileoptions -fCoCoT1_B0_F2 -k -b0
' -b1 optimize the bracnhes
Gmode 15, 1 ' 128x192x4 - Set Max Graphics Pages
Gmode 15, 0 ' 128x192x4
CPUSpeed 1 ' CPU speed, if not 1,2 or 3 it is max speed

Sprite_Load "BreakOutBall.asm", 0
Sprite_Load "BreakOutPaddle.asm", 1

HiScore = 300
StartNewGame:
GCls 0
Screen 1, 0
PlayerScore = 0
Level = 1
BallCount = 3
' Draw border lines
Line (0, 10)-(127, 10), 2
Line (63, 0)-(63, 10), 2
Line (0, 11)-(0, 191), 2
Line (127, 11)-(127, 191), 2
GoSub DrawScore

' Draw the bricks
DrawBricks:
BlockCount = 0
For y = 40 To 40 + Level * 4 Step 4
    For x = 1 To 126 Step 9
        Line (x, y)-(x + 8, y + 2), 1, BF
        BlockCount = BlockCount + 1
    Next x
Next y

' Print the current Level
Locate 0, 0: Print #-3, "L"; Trim$(Str$(Level));

StartLevel:
' Init Player Paddle
PaddleX = 60
PaddleY = 185

' Init Ball position and movement
BallX = 63
BallY = 180
BallXD = &H100 + Speed
BallYD = 0 - (&H100 + Speed)

' Main Game loop
MainLoop:
GoSub UpdateSprites
' Move the ball
MoveBall:
BallX = BallX + (BallXD / &H100)
BallY = BallY + (BallYD / &H100)

' Handle Player's Paddle
PaddleX = JoyStk(0) * 2
If PaddleX < 2 Then PaddleX = 1
If PaddleX > 120 Then PaddleX = 120

If BallX < 2 Or BallX > 124 Then
    ' ball has hit the edge, change X direction
    BallXD = BallXD * -1
    Sound 150, 1
End If
If BallY < 12 Then
    ' ball has hit the top, change Y direction
    BallYD = BallYD * -1
    Sound 150, 1
End If

' Testing never die
'If BallY > 180 Then
'    BallYD = BallYD * -1
'End If

If BallY > 189 Then
    ' Ball has reached the bottom of the screen
    If BallCount = 0 Then GoTo GameOver
    BallCount = BallCount - 1
    GoSub DrawScore
    GoTo StartLevel
End If

' Test for paddle hit
If Point(BallX, BallY) = 2 Or Point(BallX + 1, BallY) = 2 Then
    ' The ball has hit the paddle
    ' Lets change the x direction based on where the ball hit the paddle
    Select Case BallX - PaddleX
        Case 0:
            BallXD = 0 - &H180 + Speed
        Case 1:
            BallXD = 0 - &H100 + Speed
        Case 2:
            BallXD = 0 - &H80 + Speed
        Case 3:
            BallXD = &H80 + Speed
        Case 4:
            BallXD = &H100 + Speed
        Case 5:
            BallXD = &H180 + Speed
    End Select
    ' Make ball go up
    BallYD = BallYD * -1
    Sound 150, 1
    GoTo MainLoop
End If

' Test for brick hit
If BallYD > 0 Then
    ' Ball is moving down the screen, check the bottom of the ball
    If BallXD > 0 Then
        ' Ball is moving right
        If Point(BallX + 1, BallY + 1) = 1 Then
            ' Bottom right of the ball hit
            x = (BallX + 1 - 1) / 9 * 9 + 1
            y = ((BallY + 1) - 40) / 4 * 4 + 40
            GoSub BallHit
        End If
    Else
        ' Ball is moving left
        If Point(BallX, BallY + 1) = 1 Then
            ' Bottom left of the ball hit
            x = (BallX - 1) / 9 * 9 + 1
            y = ((BallY + 1) - 40) / 4 * 4 + 40
            GoSub BallHit
        End If
    End If
Else
    ' Ball is moving up the screen, check the top of the ball
    If BallXD > 0 Then
        ' Ball is moving right
        If Point(BallX + 1, BallY) = 1 Then
            ' Top left of the ball hit
            x = (BallX + 1 - 1) / 9 * 9 + 1
            y = (BallY - 40) / 4 * 4 + 40
            GoSub BallHit
        End If
    Else
        ' Ball is moving left
        If Point(BallX, BallY) = 1 Then
            ' Top left of the ball hit
            x = (BallX - 1) / 9 * 9 + 1
            y = (BallY - 40) / 4 * 4 + 40
            GoSub BallHit
        End If
    End If
End If
If BlockCount = 0 Then
    Line (1, 11)-(126, 191), 0, BF ' Clear playfield area
    Locate 5, 40
    Print #-3, "You cleared";
    Locate 7, 50
    Print #-3, "Level:"; Level;
    Locate 3, 70
    Print #-3, "Press any key";
    Locate 7, 80
    Print #-3, "to Start";
    Locate 1, 90
    Print #-3, "the Next Level";
    GoSub GetKey
    Line (1, 11)-(126, 191), 0, BF ' Clear playfield area
    Level = Level + 1 ' Increment the level
    BallCount = BallCount + 1 ' Extra Ball for clearing a level
    GoSub DrawScore
    Speed = Speed + &H80 ' Increase the ball speed
    GoTo DrawBricks
End If
GoTo MainLoop

GameOver:
Line (1, 11)-(126, 191), 0, BF ' Clear playfield area
Locate 7, 40
Print #-3, "Game Over";
Locate 7, 60
Print #-3, "Level:"; Level;
Locate 3, 70
Print #-3, "With a Score";
Locate 7, 80
Print #-3, "of"; PlayerScore;
Locate 3, 120
Print #-3, "Press any key";
Locate 7, 130
Print #-3, "to Start";
Locate 1, 140
Print #-3, "the Next Level";
GoSub GetKey
GoTo StartNewGame

GetKey:
i$ = InKey$
InkeyLoop:
i$ = InKey$
If i$ = "" Then
    GoTo InkeyLoop
End If
Return

DrawScore:
' Players score
Locate 6, 0: Print #-3, "B"; Trim$(Str$(BallCount));
Locate 12, 0: Print #-3, Trim$(Str$(HiScore));
Locate 22, 0: Print #-3, Trim$(Str$(PlayerScore));
Return

' Normal Sprite usage loop:
UpdateSprites:
Sprite LOCATE 0, BallX, BallY
Sprite BACKUP 0
Sprite SHOW 0, 0
Sprite LOCATE 1, PaddleX, PaddleY
Sprite BACKUP 1
Sprite SHOW 1, 0
Wait VBL ' This is when the actual sprite updates occur
Sprite ERASE 1
Sprite ERASE 0
Return

BallHit:
Wait VBL 'Do the actual erase of the ball, so next time it will backup the empty brick location
Line (x, y)-(x + 8, y + 2), 0, BF ' Erase the brick
Sound 200, 1
BallYD = BallYD * -1 ' change direction
PlayerScore = PlayerScore + 10 ' Give the player some points
If PlayerScore > HiScore Then HiScore = PlayerScore
GoSub DrawScore 'update the scores and return
BlockCount = BlockCount - 1
Return



