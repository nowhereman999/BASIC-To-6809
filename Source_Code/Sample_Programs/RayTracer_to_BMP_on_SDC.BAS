' Ray Tracer - Pretty much complete 
'
' Scene Data
' Render information:
' Scene Name (max 5 characters)
Data "CCRAY"
' Image Width (must be a multiple of 8)
Data 320
' Image Height
Data 200
'
' Animation Information:
' Frames per second (playback speed) used in the animation skip it generates
Data 15
' Generate Ping Pong animation
' 0 = No
' 1 = Yes genereate Ping Pong animation.  Animation will be genereated from the frames rendered then the frames will be added backwards
Data 0
'
' Sphere Data
' Number of spheres
Data 5
' RGB - Colour of each sphere
Data 255,0,255' Pink
Data 255,255,0' Yellow
Data 255,0,0' Red
Data 0,255,0' Green
Data 0,0,255' Blue
' --------------------------------------------------------------
' # of Frames, zero means end of anim, -1 means skip/ignore this section of sphere data and move on to the next
Data 18
' Frame start number (usually 0)  
' Could be changed if you stopped rendering at a certain frame
' and want to continue from somewhere other than the start again
Data 0
'Start x,y,z,Radius
Data -30,-50,0,20
Data -30,50,0,20
Data -10,0,-0,20
Data 30,50,0,20
Data 30,-50,0,20
' End x,y,z,Radius
Data -30,50,0,20
Data -30,-50,0,20
Data 0,0,0,20
Data 30,-50,0,20
Data 30,50,0,20
' From here you can keep adding more and more sphere movements to render by adding
' more and more data for each section.
' As above you must include:
' # of Frames, Start frame number, Start x,y,z,Radius for each sphere and the End x,y,z,Radius for each sphere
' --------------------------------------------------------------
' # of Frames, zero means end of anim, -1 means skip/ignore this section of sphere data and move on to the next
Data 0
' Frame start number (usually 0)  
' Could be changed if you stopped rendering at a certain frame
' and want to continue from somewhere other than the start again
Data 0
'Start x,y,z,Radius
Data -60,50,0,20
Data -30,-50,0,20
Data 0,0,0,20
Data 30,-50,0,20
Data 60,50,0,40
' End x,y,z,Radius
Data -60,50,0,40
Data -30,-50,0,20
Data 10,0,0,20
Data 30,-50,0,20
Data 60,50,0,20
' --------------------------------------------------------------
' # of Frames, zero means end of anim, -1 means skip/ignore this section of sphere data and move on to the next
Data 0

'----------------------------------------------------------------------------------
' Line equation is y=x, y=mx+c  (slope c is a change)
' Raytracing line equations for vectors
' Origin and direction = Ray description in vectors
' vector x,y origin, x,y direction
' t= distance/scaler  (amount to move)
' a+bt
' axy+bxyt
' a=2,2 b= 1,1 t=2 so Pxy=(2,2)+(1,1)(2)
'                        = 2*1*2 , 2*1*2 = (4,4)
' If t is negative then the movement or distance is backwards
' Px=ax + bxt
' Py=ay + byt       These are called paramtric equations   *** Important equations
' Pz=az + bzt

' Circle equation is
' (x-a)^2+(y-b)^2 = r^2
' x^2+y^2=r^2
' x^2+y^2=4 then y^2=r^2-x^2 then y=sqr(r^2-x^2) and y=-sqr(r^2-x^2)   (both halfs of the triangle)
' Sphere equation is
' (x-a)^2+(y-b)^2)+(z-c)^2 = r^2
' To see if a line intersects a circle use this formula we know a= origin(x,y) and b= destination(x,y), we need to find t
' ax^2+2axbxt+bx^2t^2+ay^2+2aYbYt+by^2t^2-4=0
' which resolves to a quadradic equation of
' (bx^2+by^2)*t^2 + (2axbx+2ayby)*t+(ax^2+ay^2-4)=0

' So if a=(-3,-3) ax=-3,ay=-3 and b=(1,1) bx=1,by=1 then we get
' (1^2+1^2)*t^2 + (2*(-3*1)+2*(1*-3))*t + (-3^2+-3^2-4)=0
' which is 2t^2-12t+14=0  using the quadrtic formula we can turn the quadratic equation into this formula -b +/- SQR(b2-4ac)/2a
' this gives us our formula where our formula will use a=2, b=-12, c=14
' First we use part of the quadratic formula (discriminant equation) inside the square of (-12)^2-4*(2*14) = 144-112 = 32
' This tells us if we have an intersection, if the result is >0 then we have 2 solutions, if it = 0 then we have 1 solution, if <0 then we have 0 solutions, solutions are intersections
' We do need to solve the equation completely though which would be -b +/- SQR(32)/2a which is 12 +/- sqr(32)/2a = 12 +/- sqr(32)/4  which is  (12+/-5.65685425)/4  = 4.415 and 1.585
' so t= 4.415 and t also = 1.585 (lowest result is the closest intersection so that what we want to use for 3D rendering
' we now use t in these formulas
' Px=ax + bxt
' Py=ay + byt       These are called paramtric equations   *** Important equations
' Pz=az + bzt
' Px=-3 + 1 * 4.415 and Px=-3 + 1 * 1.585  =-3+4.415 = 1.415 and =-3+1.585 = -1.415
' Py=-3 + 1 * 4.415 and Py=-3 + 1 * 1.585  =-3+4.415 = 1.415 and =-3+1.585 = -1.415
' So the sphere formula will be
' ax^2+2axbxt+bx^2t^2+ay^2+2aYbYt+by^2t^2-4=0
' which resolves to a quadradic equation of
' (bx^2 + by^2)*t^2 + (2axbx + 2ayby)*t + (ax^2 + ay^2 - r^2) = 0
' which is simplified a little as added the z axis for a line intersecting a sphere:
' /------- a --------\        /-------- b ---------\     /------ c -------\
' (bx^2 + by^2 + bz^2)*t^2 + (2(axbx + ayby + azbz))*t + (ax^2 + ay^2 +az^2 - r^2) = 0
' t is what we're solving for:
' a = ray origin
' b = ray direction
' r = radius
' t = hit distance
'
'----------------------------------------------------------------------------------
' Values will be divided by 100 to make the numbers smaller but stored as integers for now
Dim SphereRed(10), SphereGreen(10), SphereBlue(10)
Dim Sphere_x(10), Sphere_y(10), Sphere_z(10), Sphere_Radius(10) 'x,y,z,radius
Dim SphereStart_x(10), SphereStart_y(10), SphereStart_z(10), SphereStart_Radius(10) 'x,y,z,radius
Dim SphereEnd_x(10), SphereEnd_y(10), SphereEnd_z(10), SphereEnd_Radius(10) 'x,y,z,radius
DIM Sphere_Check_r(8), Sphere_Check_g(8), Sphere_Check_b(8)

' Camera location in 3D space
'rayStart_x = 0: rayStart_y = 0: rayStart_z = 2
FP_rayStart_x = 0: FP_rayStart_y = 0: FP_rayStart_z = 2

' Light in 3D space    (-1,-1,-1) Right, Above and in front of the Sphere
'Light1_x = -1: Light1_y = -1: Light1_z = -1
FP_Light1_x = -1: FP_Light1_y = -1: FP_Light1_z = -1

' Normalizing a vector means scaling it to have a length of 1, making it a unit vector. This is done by dividing each component by the vector magnitude (length).
' Normalize the Light with the formula of (Magnitude = SQR(x^2+y^2+z^2), use the Magnitude on each x,y,z value as Normal_x = Light1_x/Magnitude
'Magnitude = Sqr(Light1_x ^ 2 + Light1_y ^ 2 + Light1_z ^ 2)
FP_Magnitude = FloatMul(FP_Light1_x, FP_Light1_x)
FP_Temp1 = FloatMul(FP_Light1_y, FP_Light1_y)
FP_Magnitude = FloatAdd(FP_Magnitude, FP_Temp1)
FP_Temp1 = FloatMul(FP_Light1_z, FP_Light1_z)
FP_Magnitude = FloatAdd(FP_Magnitude, FP_Temp1)
FP_Magnitude = FloatSqr(FP_Magnitude)

'LightDir1_x = Light1_x / Magnitude: LightDir1_y = Light1_y / Magnitude: LightDir1_z = Light1_z / Magnitude
FP_LightDir1_x = FloatDiv(FP_Light1_x, FP_Magnitude)
FP_LightDir1_y = FloatDiv(FP_Light1_y, FP_Magnitude)
FP_LightDir1_z = FloatDiv(FP_Light1_z, FP_Magnitude)

FP_rayDirection_z = -1  ' The camera looks straight into the scene along -Z axis      
'
'----------------------------------------------------------------------------------
' Program starts here:
' ADDASSEM:
    ORCC    #$50            ; No interupts, let's go as fast as we can
; Prepare for BREAK key tests
    LDB     #%11111011      ; strobe the keyboard column..
    STB     $FF02           ; $FF02 ..which contains the BREAK key
    CLR     DoubleSpeedFlag ; clear the double speed flag
    BRA     >
DoubleSpeedFlag RMB  1
!                           ; skip over the flag
' ENDASSEM:

' Order from most important to least important
sphereColour_r=0
sphereColour_g=0
sphereColour_b=0
PixelCheck=0
SphereCount=0
OutPos=0
xp=0
value=0
x=0
y=0
a=0

CLS:?"COCO 3D RAYTRACER - GLEN HEWLETT";
IF INT(PEEK(&HFFFE)) = &H8C AND INT(PEEK(&HFFFF)) = &H1B AND 1=1 THEN
ELSE
    ?@480," PRESS 2 TO EN/DISABLE 2X SPEED";
END IF

' Get Filename, Width and Height
Read BaseName$
Read Width
WidthHalf=Width/2
Read Height
HeightHalf=Height/2
' Get anim info
Read FramesPerSecond
Read PingPongFlag

' Initialize the spheres
Read NumSpheres
NumSpheres = NumSpheres - 1
' Get spheres RGB values
For T = 0 To NumSpheres
    Read SphereRed(T): Read SphereGreen(T): Read SphereBlue(T)
Next T
TotalFrames = 1000 ' Total frames actual number starts at 1000, this way we can ignore the other digits (limits us to frames from 0 to 999)
' Figure out and generate the frames for the animation
AnimSection=-1

NextTweenStart:
AnimSection=AnimSection+1
Read FrameCount
If FrameCount = 0 Then GOTO DoneRendering
IF FrameCount < -1 THEN
    ' User wants to skip this tween section
    ' Skip FrameStart + NumSpheres * 3 + NumSpheres * 3
    For T = 0 To 1+NumSpheres*6
        Read FrameCount ' ignored values
    Next T
    Goto NextTweenStart
END IF
Read FrameStart ' Get the frame number to start rendering for this section

IF BaseName$="" THEN 
    BaseName$="3DPIC"
ELSE
BaseName$=left$(BaseName$+"000000",5) ' pad the Filename to 5 chars
END IF

?@32,"USING BASENAME:";BaseName$
?"WIDTH:";Width,"HEIGHT:";Height
?"ANIM SECTION:";AnimSection+1
?"FRAMES:";FrameStart+1;"TO";FrameCount

' Get spheres Starting location and starting radius
For T = 0 To NumSpheres
    Read value: SphereStart_x(T) = value : Read value: SphereStart_y(T) = value : Read value: SphereStart_z(T) = value : Read value: SphereStart_Radius(T) = value
Next T
' Get spheres Ending location and starting radius
For T = 0 To NumSpheres
    Read value: SphereEnd_x(T) = value : Read value: SphereEnd_y(T) = value : Read value: SphereEnd_z(T) = value : Read value: SphereEnd_Radius(T) = value
Next T
' Generate the frames for the animation
For Frame = FrameStart To FrameCount - 1
    ' Setup frame positions and size
    For T = 0 To NumSpheres
        'Sphere x location
        value = SphereEnd_x(T) - SphereStart_x(T) ' Calculate Total movement for this anim
        value = value / (FrameCount - 1) ' Calculate the amount to move for each frame
        value = value * Frame
        value = SphereStart_x(T) + value
        Sphere_x(T) = value
        'Sphere y location
        value = SphereEnd_y(T) - SphereStart_y(T) ' Calculate Total movement for this anim
        value = value / (FrameCount - 1) ' Calculate the amount to move for each frame
        value = value * Frame
        value = SphereStart_y(T) + value
        Sphere_y(T) = value
        'Sphere z location
        value = SphereEnd_z(T) - SphereStart_z(T) ' Calculate Total movement for this anim
        value = value / (FrameCount - 1) ' Calculate the amount to move for each frame
        value = value * Frame
        value = SphereStart_z(T) + value
        Sphere_z(T) = value
        'Sphere Radius size
        value = SphereEnd_Radius(T) - SphereStart_Radius(T) ' Calculate Total movement for this anim
        value = value / (FrameCount - 1) ' Calculate the amount to move for each frame
        value = value * Frame
        value = SphereStart_Radius(T) + value
        Sphere_Radius(T) = value
    Next T
    ' Total frames actual number starts at 1000, this way we can ignore the other digits (limits us to frames from 0 to 999)
    FileName$=BaseName$+right$(str$(TotalFrames),3)+".BMP" ' add the frame number to the Filename
    SDC_Open FileName$,"W",0 ' open the file
    GOSUB WriteBMPHeader ' write the BMP header info
    Frame=Frame+1000 ' add 1000 to the frame number to get the actual frame number
    ?@160,"FRAME :";right$(str$(Frame-1000+1),3),"% COMPLETE:"
    Frame=Frame-1000 ' subtract 1000 to get the actual frame number back
    ' Generate the frame
    GoSub GenerateNewFrame
    SDC_Close(0) ' close the file
    TotalFrames = TotalFrames + 1
Next Frame
GoTo NextTweenStart ' go do next anim frame

' Done rendering all the frames
DoneRendering:
?@187,100
?:?"DONE"
Goto Cleanup

GenerateNewFrame:
 For y = 0 To Height-1
    FP_Temp=FloatMul(INT(y),100)
    FP_Temp=FloatDiv(FP_Temp,INT(Height))
    T=FP_Temp
    ?@187,T
    x = 0
    OutPos = 0
    Do While x < Width
        xp = x
        GoSub GetPixel ' get the color of the pixel x,y
        If sphereColour_r + sphereColour_g + sphereColour_b = 0 Then
            ' Pixel is black, start checking pixels to the right
            PixelCheck = 7
            Do
                x = xp + PixelCheck
                GoSub GetPixel
                If sphereColour_r + sphereColour_g + sphereColour_b = 0 Then Exit Do
            ' BMP format for 24 bit RGB colour is actually BGR
                Sphere_Check_b(PixelCheck) = sphereColour_b
                Sphere_Check_g(PixelCheck) = sphereColour_g
                Sphere_Check_r(PixelCheck) = sphereColour_r
                PixelCheck = PixelCheck - 1
            Loop While PixelCheck > 0

            PixelCheck = PixelCheck + 1 ' Adjust count for pixels found
            a = PixelCheck * 3
            GoSub WriteAZeros ' Write zeros
            While PixelCheck < 8
            ' BMP format for 24 bit RGB colour is actually BGR
                SDC_Putbyte0 Sphere_Check_b(PixelCheck)
                SDC_Putbyte0 Sphere_Check_g(PixelCheck)
                SDC_Putbyte0 Sphere_Check_r(PixelCheck)
                PixelCheck=PixelCheck+1
            WEND
            x=xp+8
        ELSE
            ' Pixel is not black
            ' BMP format for 24 bit RGB colour is actually BGR
            SDC_Putbyte0 sphereColour_b
            SDC_Putbyte0 sphereColour_g
            SDC_Putbyte0 sphereColour_r
            x=x+1
            ' Loop through the next 7 pixels
            For xp=1 to 7
            GoSub GetPixel ' get the color of the pixel
            ' BMP format for 24 bit RGB colour is actually BGR
            SDC_Putbyte0 sphereColour_b
            SDC_Putbyte0 sphereColour_g
            SDC_Putbyte0 sphereColour_r
            x=x+1
            Next xp
        END IF
' Check if break key or 2 is pressed
' ADDASSEM:
        LDB     $FF00           ; Get keyboard state
        BITB    #%01000000      ; Test row with the BREAK key
        BEQ     SDC_3DBreak     ; Exit if BREAK is pressed
        BITB    #%00010000      ; Test row with the 2 key
        BEQ     KeyPress2       ; If so handle it
NotBreak:
' ENDASSEM:
    Loop
Next y
RETURN ' Finished generating this frame

' ADDASSEM:
SDC_3DBreak:
' ENDASSEM:
?:?"SDC WRITING HAS BEEN TERMINATED"
SDC_Close(0) ' close the file

Cleanup:
' ADDASSEM:
    STA     $FFD8           ; Disable double speed
    JSR     SDCReset  * Reset the SD Controller
' ENDASSEM:
?"    PRESS ANY KEY TO REBOOT"
I$=INKEY$
InkeyLoop:
I$=INKEY$:IF I$=""THEN GOTO InkeyLoop
' ADDASSEM:
; Restart the computer
    LDD     $FFFE
    CMPD    #$8C1B
    BNE     >
    LDA     #$38
    STA     >$FFA0    * Set Block 0 to normal $38
!   STA     >$FFDE    * Make sure we are in ROM mode
    CLR     >$0071    * Make sure we do a cold reboot, so the user is confident things are back to normal
    JMP     [$FFFE]   * Jump back to the start of the BASIC ROM

; Break or 2 key has been pressed
KeyPress2:
        LDX     $FFFE           ; Get the current PC
        CMPX    #$8C1B          ; Check if we are using a CoCo 3
        BEQ     NotBreak        ; continue as we are, compiler code always checks for a coco 3 and sets it at double speed if so
        LDA     DoubleSpeedFlag ; Check if double speed is enabled
        EORA    #$FF            ; XOR A and $FF to toggle it
        STA     DoubleSpeedFlag ; Toggle double speed
        BNE     >               ; If not double speed, then make it double speed
        STA     $FFD8           ; Disable double speed
        BRA     NotBreak        ; Continue rendering
!       STA     $FFD9           ; Enable double speed
        BRA     NotBreak        ; Continue rendering
' ENDASSEM:

GetPixel:
'rayDirection_x = (x - WidthHalf) / 256: rayDirection_y = (-y + HeightHalf) / 256
'FP_rayDirection_x = FloatDiv(int(x-128), 256)
'FP_rayDirection_y = FloatDiv(int(-y+96), 256)
FP_rayDirection_x = FloatDiv(int(x-WidthHalf), int(Height))
FP_rayDirection_y = FloatDiv(int(-y+HeightHalf), int(Height))

' Quadratic equation coefficients
'a = rayDirection_x * rayDirection_x + rayDirection_y * rayDirection_y + rayDirection_z * rayDirection_z
FP_a = FloatMul(FP_rayDirection_x, FP_rayDirection_x)
FP_Temp1 = FloatMul(FP_rayDirection_y, FP_rayDirection_y)
FP_a = FloatAdd(FP_a, FP_Temp1)
FP_Temp1 = FloatMul(FP_rayDirection_z, FP_rayDirection_z)
FP_a = FloatAdd(FP_a, FP_Temp1)

For SphereCount = 0 To NumSpheres
' Define the sphere's center
FP_SphereCenter_x = FloatDiv(INT(Sphere_x(SphereCount)),100)
FP_SphereCenter_y = FloatDiv(INT(Sphere_y(SphereCount)),100)
FP_SphereCenter_z = FloatDiv(INT(Sphere_z(SphereCount)),100)

' Get Sphere Radius
FP_Sphere_Radius = FloatDiv(INT(Sphere_Radius(SphereCount)),100)

' Calculate the vector from the ray start to the sphere center
FP_sphere2Ray_x = FloatSub(FP_rayStart_x , FP_SphereCenter_x)
FP_sphere2Ray_y = FloatSub(FP_rayStart_y , FP_SphereCenter_y)
FP_sphere2Ray_z = FloatSub(FP_rayStart_z , FP_SphereCenter_z)

'a is calculated above based on the ray itself which doesn't change per sphere
'b = 2 * (sphere2Ray_x * rayDirection_x + sphere2Ray_y * rayDirection_y + sphere2Ray_z * rayDirection_z)
FP_b = FloatMul(FP_sphere2Ray_x, FP_rayDirection_x)
FP_Temp1 = FloatMul(FP_sphere2Ray_y, FP_rayDirection_y)
FP_b = FloatAdd(FP_b, FP_Temp1)
FP_Temp1 = FloatMul(FP_sphere2Ray_z, FP_rayDirection_z)
FP_b = FloatAdd(FP_b, FP_Temp1)
FP_b = FloatMul(2,FP_b)

'c = (sphere2Ray_x * sphere2Ray_x + sphere2Ray_y * sphere2Ray_y + sphere2Ray_z * sphere2Ray_z) - Sphere_Radius * Sphere_Radius
FP_c = FloatMul(FP_sphere2Ray_x, FP_sphere2Ray_x)
FP_Temp1 = FloatMul(FP_sphere2Ray_y, FP_sphere2Ray_y)
FP_c = FloatAdd(FP_c, FP_Temp1)
FP_Temp1 = FloatMul(FP_sphere2Ray_z, FP_sphere2Ray_z)
FP_c = FloatAdd(FP_c, FP_Temp1)
FP_Temp1 = FloatMul(FP_Sphere_Radius, FP_Sphere_Radius)
FP_c = FloatSub(FP_c, FP_Temp1)

' Quadratic formula discriminant:
' b^2 - 4ac
' discriminant = b * b - 4 * a * c
FP_discriminant = FloatMul(FP_b, FP_b)
FP_Temp1 = FloatMul(4, FP_a)
FP_Temp1 = FloatMul(FP_Temp1, FP_c)
FP_discriminant = FloatSub(FP_discriminant, FP_Temp1)

IF CMPGE(FP_discriminant, 0) THEN Goto HitObject ' If discriminant < 0 then we missed the sphere
Next SphereCount
' Black
sphereColour_r = 0
sphereColour_g = 0
sphereColour_b = 0
RETURN

HitObject:
' If we get here then we hit the sphere
'
' Quadratic formula:
' -b +/- SQR(discriminant)/2a
't0 = (-b - Sqr(discriminant)) / (2 * a) ' Always the closest hit point
't1 = (-b + Sqr(discriminant)) / (2 * a) ' we can ignore the ray that hits the back of the sphere & no reason to calc the hitpoint below of the back
' use t0 and t1 to solve for ax+bxt,ay+byt,az+bzt
' t0 will always be closest so we can ignore t1
' Compute the closest intersection point using the quadratic formula
FP_Temp1=FloatSqr(FP_discriminant)
FP_t0 = FloatSub(-FP_b, FP_Temp1)
FP_Temp1 = FloatMul(2, FP_a)
FP_t0 = FloatDiv(FP_t0, FP_Temp1)

'hitpoint_x = rayStart_x + rayDirection_x * t0
FP_hitpoint_x = FloatMul(FP_rayDirection_x, FP_t0)
FP_hitpoint_x = FloatAdd(FP_rayStart_x, FP_hitpoint_x)

'hitpoint_y = rayStart_y + rayDirection_y * t0
FP_hitpoint_y = FloatMul(FP_rayDirection_y, FP_t0)
FP_hitpoint_y = FloatAdd(FP_rayStart_y, FP_hitpoint_y)

'hitpoint_z = rayStart_z + rayDirection_z * t0
FP_hitpoint_z = FloatMul(FP_rayDirection_z, FP_t0)
FP_hitpoint_z = FloatAdd(FP_rayStart_z, FP_hitpoint_z)

' Figure out the Normal vector (which is the direction that is perpendicular to the 3d face, shooting outwards)
' Take the hit point and subtract it from the center point (origin/start)
' Since the sphere is in the center of the universe the hitpoint is our Normal vector
' If sphere wasn't in the center we would need to use
' Normalize = hitpoint - sphereOrigin (for x,y,z)
' Normal_x = hitpoint_x ' (a Normal will range from -1 to 1)
FP_Temp1 = FloatDiv(INT(Sphere_x(SphereCount)),100)
FP_Normal_x = FloatSub(FP_hitpoint_x,FP_Temp1)

'Normal_y = hitpoint_y
FP_Temp1 = FloatDiv(INT(Sphere_y(SphereCount)),100)
FP_Normal_y = FloatSub(FP_hitpoint_y,FP_Temp1)

'Normal_z = hitpoint_z
FP_Temp1 = FloatDiv(INT(Sphere_z(SphereCount)),100)
FP_Normal_z = FloatSub(FP_hitpoint_z,FP_Temp1)

'Normalize the Normals
'Magnitude = Sqr(Normal_x ^ 2 + Normal_y ^ 2 + Normal_z ^ 2)
FP_Magnitude = FloatMul(FP_Normal_x, FP_Normal_x)
FP_Temp1 = FloatMul(FP_Normal_y, FP_Normal_y)
FP_Magnitude = FloatAdd(FP_Magnitude, FP_Temp1)
FP_Temp1 = FloatMul(FP_Normal_z, FP_Normal_z)
FP_Magnitude = FloatAdd(FP_Magnitude, FP_Temp1)
FP_Magnitude = FloatSqr(FP_Magnitude) ' Works but let's try INT SQR

'Normalized1_x = Normal_x / Magnitude: Normalized1_y = Normal_y / Magnitude: Normalized1_z = Normal_z / Magnitude
FP_Normalized1_x = FloatDiv(FP_Normal_x, FP_Magnitude): FP_Normalized1_y = FloatDiv(FP_Normal_y, FP_Magnitude): FP_Normalized1_z = FloatDiv(FP_Normal_z, FP_Magnitude)

' The dot product formula is a mathematical operation that takes two vectors and returns a single scalar value
' The formula is A . B = Ax * Bx + Ay * By + az * Bz
'd = Normalized1_x * -LightDir1_x + Normalized1_y * -LightDir1_y + Normalized1_z * -LightDir1_z ' = cos(angle) with a value of -1 to 1  (this is the scale of how much light is hitting this point)
FP_d = FloatMul(FP_Normalized1_x, -FP_LightDir1_x)
FP_Temp1 = FloatMul(FP_Normalized1_y, -FP_LightDir1_y)
FP_d = FloatAdd(FP_d, FP_Temp1)
FP_Temp1 = FloatMul(FP_Normalized1_z, -FP_LightDir1_z)
FP_d = FloatAdd(FP_d, FP_Temp1)

'If d < 0 Then d = 0 ' this makes sure the lowest value of the light can only be zero
IF CMPLT(FP_d, 0) THEN 
    sphereColour_r = 0
    sphereColour_g = 0
    sphereColour_b = 0
ELSE
    FP_Temp1=FloatMul(FP_d,INT(SphereRed(SphereCount))
    sphereColour_r = FP_Temp1
    FP_Temp1=FloatMul(FP_d,INT(SphereGreen(SphereCount))
    sphereColour_g = FP_Temp1
    FP_Temp1=FloatMul(FP_d,INT(SphereBlue(SphereCount))
    sphereColour_b = FP_Temp1
    'colour = _RGB(sphereColour_r, sphereColour_g, sphereColour_b): Return
END IF
RETURN

WriteBMPHeader:
SDC_Putbyte0 ASC("B")
SDC_Putbyte0 ASC("M")
FP_Size=FloatMul(INT(Width),INT(Height))
FP_Size=FloatAdd(FP_Size,54) ' Add the header size of 54
' ADDASSEM:
    LDU     #_FPVar_FP_Size+5
    LDX     #_StrVar_PF01       ; Store converted number here
    STX     _Var_x              ; variable points to the 32 bit unsigned int
    JSR     UINT                ; convert Float at U-5 to 32 bit unsigned INT
' ENDASSEM:
' Write the BMP header
SDC_Putbyte0 PEEK(x+3)
SDC_Putbyte0 PEEK(x+2)
SDC_Putbyte0 PEEK(x+1)
SDC_Putbyte0 PEEK(x)
a=4:GOSUB WriteAZeros
SDC_Putbyte0 &H36
a=3:GOSUB WriteAZeros
' DIB Header
SDC_Putbyte0 40
a=3:GOSUB WriteAZeros
SDC_Putbyte0 Width-(Width/256)*256
SDC_Putbyte0 Width/256
a=2:GOSUB WriteAZeros
'SDC_Putbyte0 Height-(Height/256)*256
'SDC_Putbyte0 Height/256
'a=2:GOSUB WriteAZeros
a=-Height
' ADDASSEM:
    LDX     #_Var_a             ; Store converted number here
    STX     _Var_x              ; variable points to the 32 bit unsigned int
' ENDASSEM:
SDC_Putbyte0 PEEK(x+1)
SDC_Putbyte0 PEEK(x)
SDC_Putbyte0 &HFF
SDC_Putbyte0 &HFF

SDC_Putbyte0 1
SDC_Putbyte0 0
SDC_Putbyte0 24
SDC_Putbyte0 0
a=6*4:GOSUB WriteAZeros
RETURN
WriteAZeros:
'    SDC_Putbyte0 0
'    a=a-1
'    IF a<>0 THEN GOTO WriteAZeros
' ADDASSEM:
        LDA     _Var_a+1      ; Get number in A
        CLRB                  ; Clear B
!       JSR     SDCPutByteB0  ; Send byte B to file 0
        DECA                  ; Decrement A
        BNE     <             ; Loop until A is 0
' ENDASSEM:
RETURN
' ADDASSEM:
; Fast SQR method will half the exponent of the 5 byte Floating point number
; Get the most significant bytes of the mantissa and
; use a lookup table to get the square root of the Most significant bits of the mantissa
; maybe we can use the code below for the exponent, or maybe that will need a lookup table of it's own...
    LDA   -5,U             ; Load exponent byte
    SUBA  #$80             ; Convert to signed exponent (centered at 0)
    ASRA                   ; Arithmetic shift right to halve the exponent
    ADDA  #$80             ; Re-bias the exponent
    STA   -5,U             ; Store back the adjusted exponent
' ENDASSEM:

