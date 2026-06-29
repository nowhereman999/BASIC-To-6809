Option _Explicit
$ScreenHide
$Console
_Dest _Console
ChDir _StartDir$

Const ProgramName$ = "MakeNTM"
Const VersionNumber$ = "1.10"
Const BYTES_PER_SECTOR = 512
Const HEADER_SECTOR_BYTES = 512

Dim Shared DitherType As Integer
Dim Shared OrderedArray(7, 7) As Integer
Dim Shared ColoursMatch(255, 2) As Integer
Dim Shared ColoursReal(255, 2) As Integer
Dim Shared CoCo64RGB(63, 2) As Integer

Dim Shared imageWidth As Integer, imageHeight As Integer
Dim Shared pixelR As _Unsigned _Byte
Dim Shared pixelG As _Unsigned _Byte
Dim Shared pixelB As _Unsigned _Byte
Dim Shared DitherOut As _Unsigned _Byte

Dim Shared R As Integer, G As Integer, B As Integer
Dim Shared bestIndex As Integer
Dim Shared bestDist As Long, dist As Long

Dim Shared AudioFH As Integer
Dim Shared audioLen As Long
Dim Shared audioPos As Long
Dim Shared TotalFramesForHeader As Long

Dim Shared FrameW As Integer
Dim Shared FrameH As Integer
Dim Shared FPS As Integer
Dim Shared GMode As Integer
Dim Shared GModeIndex As Integer
Dim Shared MemStart As Long
Dim Shared StartRow As Integer
Dim Shared UseStartRow As Integer
Dim Shared ScreenW As Integer
Dim Shared ScreenH As Integer
Dim Shared ScreenColors As Integer
Dim Shared ScreenBytesPerRow As Integer
Dim Shared StartByteX As Integer
Dim Shared PalMode As Integer
Dim Shared AudSectors As Integer
Dim Shared VidSectors As Integer
Dim Shared CoCo1VideoOnly As Integer
Dim Shared CoCo1ArtifactMode As Integer
Dim Shared CoCo1ArtifactModeSpecified As Integer
Dim Shared VideoBytesPerFrame As Long
Dim Shared AudioBytesPerFrame As Long
Dim Shared SampleRate As Long
Dim Shared FIRQDelay As Long
Dim Shared InitPalette(15) As Integer
Dim Shared GModeByte(165) As Integer
Dim Shared GModeDesc$(165)
Dim Shared PalettePickMethod As Integer
Dim Shared ShadowLumaGreyMode As Integer
Dim Shared ForceSP1Enabled As Integer
Dim Shared ForceSP1Value As Integer
Dim Shared ForceSPEnabled(15) As Integer
Dim Shared ForceSPValue(15) As Integer
Dim Shared NoPillar As Integer

Dim Shared TextMessage(279) As _Unsigned _Byte
Dim Shared Mess$
Dim Shared CompilerVersion$
Dim Shared RunningOnWindows As Integer

Declare Function BuildJumpSectorRateNum& (FPS As Integer, VideoSectors As Integer, AudioSectors As Integer, PalMode As Integer)
Declare Sub ShowUsage
Declare Sub SetDefaultPalette
Declare Sub InitGModeTable
Declare Function ResolveGModeArg% (n As Integer)
Declare Function ParseResolution% (txt$, outW As Integer, outH As Integer)
Declare
Declare Function ByteToBin$ (v As Integer)
Declare Function GetModeInfo% (modeIndex As Integer, modeW As Integer, modeH As Integer, modeColors As Integer)
Declare Function ParsePaletteList% (txt$)
Declare Sub WriteHeaderSector (fh As Integer)
Declare Sub WriteStackBlastedSector (fh As Integer, sectorData() As _Unsigned _Byte)
Declare Sub WritePaletteSector (fh As Integer, groupPalettes() As _Unsigned _Byte, groupCount As Integer)
Declare Sub WriteStatusLine (row As Integer, msg$)
Declare Sub ReportLine (label$, value$)
Declare Sub ConvertOneFrame (frameFile$, frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
Declare Sub BuildMuxedFrame (frameVideo() As _Unsigned _Byte, muxedFrame() As _Unsigned _Byte)
Declare Function ExpandFramePattern$ (pat$, index As Long)
Declare Sub InitOrderedDither
Declare Sub InitPaletteData
Declare Sub InitCoCo64Palette
Declare Sub BuildBest16CoCoPalette (framePalette() As _Unsigned _Byte)
Declare Sub PackFrameTo4Bit (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
Declare Function FindClosestCoCo64Color% (r As Integer, g As Integer, b As Integer)
Declare Function FindClosestPaletteSlotRGB% (r As Integer, g As Integer, b As Integer, framePalette() As _Unsigned _Byte)
Declare Function ClampByte% (n As Integer)
Declare Sub DoFindClosestColor
Declare Sub FindClosestColorInFramePalette (srcIndex As Integer, framePalette() As _Unsigned _Byte, bestSlot As Integer)
Declare Sub BuildPaletteFromDither (framePalette() As _Unsigned _Byte)
Declare Sub RemapDitherToFramePalette (framePalette() As _Unsigned _Byte)
Declare Sub ConvertFrameToGMode151Grey (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
Declare Sub ConvertFrameTo1BitBW (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
Declare Sub ConvertFrameToCoCo1SG24 (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
Declare Sub ConvertFrameToCoCo1GMode15 (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
Declare Sub ConvertFrameToCoCo1SolidBW (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
Declare Sub ConvertFrameToCoCo1Artifact4Color (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
Declare Sub ConvertFrameToCoCo1Artifact2x2 (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
Declare Sub PackDitherOutTo1Bit (frameVideo() As _Unsigned _Byte)
Declare Function QuantizeGrey2Bit% (grey As Integer)
Declare Function QuantizeBW1Bit% (grey As Integer)
Declare Sub Gosub_DoNoDither
Declare Sub Gosub_DoOrderDither
Declare Sub Gosub_DoFloydDither
Declare Sub Gosub_DoBlueNoiseTexture

Declare Function HasMovieInputMode% ()
Declare Sub PrepareMovieInputMode (count As Integer, ResArg$, AudSectors As Integer, FramePattern$, AudioFile$, OutFile$, haveRes As Integer, haveAudioSectors As Integer, havePattern As Integer, haveAudio As Integer, haveOutput As Integer, MovieName$)
Declare Function ShellQuote$ (s$)
Declare Function CaptureCommandOutput$ (cmd$)
Declare Function GetFFProbeValue$ (blob$, key$)
Declare Function NormalizeTimeArg$ (t$)
Declare Function TimeToSeconds# (t$)
Declare Function SecondsToTime$ (s#)
Declare Function DetectCrop$ (ffmpeg$, inputFile$, sampleStart$, sampleDur$)
Declare Function ComputeScaledRes$ (screenW As Integer, screenH As Integer, scaleTxt$)
Declare Function BuildVideoFilter$ (ffmpeg$, ffprobe$, inputFile$, fps As Integer, screenW As Integer, screenH As Integer, movieW As Integer, movieH As Integer, frameOutW As Integer, frameOutH As Integer, srcW As Integer, srcH As Integer, cropInfo$, hdrInfo$, scaleTxt$, resTxt$, autoCrop As Integer, startTime$, noPillar As Integer, forceFullFrame As Integer)
Declare Function ExtractRawOptValue$ (rawCmd$, optA$, optB$)
Declare Sub EnsureSilentAudio (audioFile$, fps As Integer, audSectors As Integer)
Declare Sub DeleteIfExists (f$)
Declare Sub ChooseBestAudioStreamInfo (ffprobe$, inputFile$, audioPref$, samplerate As Long, audioIndex$, audioChannels As Integer, audioLayout$, audioCodec$, audioLanguage$, audioTitle$, audioKind$, audioFilter$, audioStrategy$)
Declare Function ClassifyAudioKind$ (layout$, channels As Integer)
Declare Function CommentaryPenalty% (txt$)
Declare Function AudioPreferenceBonus% (kind$, pref$)
Declare Function ScoreAudioStream& (kind$, channels As Integer, sampleRate As Long, bitRate As Long, isDefault As Integer, isOriginal As Integer, isComment As Integer, txt$, pref$)
Dim count As Integer
Dim check As Integer
Dim copyPos As Long
Dim arg$, FramePattern$, AudioFile$, OutFile$, ResArg$
Dim havePattern As Integer, haveAudio As Integer, haveOutput As Integer
Dim haveRes As Integer, haveAudioSectors As Integer
Dim frameIndex As Long
Dim frameFile$
Dim frameCount As Long
Dim outFH As Integer
Dim PosArg$(20)
Dim PosCount As Integer
Dim processedInGroup As Integer
Dim headerWritten As Integer
Dim groupCount As Integer
Dim groupIndex As Integer
Dim groupFrameFiles(0 To 31) As String
Dim groupPalettes As _Unsigned _Byte
Dim tempPalette(0 To 15) As _Unsigned _Byte
Dim tempVideo As _Unsigned _Byte
Dim muxedFrame As _Unsigned _Byte
Dim groupVideo As _Unsigned _Byte
Dim videoFrameBytes As Long
Dim basePos As Long

Dim MovieName$
Dim tempPal(0 To 15) As _Unsigned _Byte
Dim i As Integer
Dim spIdx As Integer, eqPos2 As Integer

CompilerVersion$ = _OS$
RunningOnWindows = (InStr(UCase$(CompilerVersion$), "WINDOWS") > 0)
For i = 0 To 15
    tempPal(i) = tempPal(i)
Next i
tempPal(0) = 0
If ForceSP1Enabled Then
    tempPal(1) = ForceSP1Value And 63
End If

Randomize Timer
InitOrderedDither
InitPaletteData
InitCoCo64Palette
InitGModeTable
SetDefaultPalette

DitherType = 1
FPS = 10
GMode = &H19
GModeIndex = 0
MemStart = &H8000 + 128 * 167
StartRow = 0
UseStartRow = 0
PalMode = 0
CoCo1VideoOnly = 0
CoCo1ArtifactMode = 2
CoCo1ArtifactModeSpecified = 0
PalettePickMethod = 0
ShadowLumaGreyMode = 0
ForceSP1Enabled = 0
ForceSP1Value = 63
For i = 0 To 15
    ForceSPEnabled(i) = 0
    ForceSPValue(i) = 0
Next i
ForceSPValue(1) = 63

count = _CommandCount
If HasMovieInputMode Then
    PrepareMovieInputMode count, ResArg$, AudSectors, FramePattern$, AudioFile$, OutFile$, haveRes, haveAudioSectors, havePattern, haveAudio, haveOutput, MovieName$
    GoTo AfterOldParse
End If

If count < 3 Then
    ShowUsage
    System
End If

For check = 1 To count
    arg$ = Command$(check)
    If LCase$(Left$(arg$, 2)) = "-d" Then
        DitherType = Val(Mid$(arg$, 3))
    ElseIf LCase$(Left$(arg$, 4)) = "-fps" Then
        FPS = Val(Mid$(arg$, 5))
    ElseIf LCase$(Left$(arg$, 2)) = "-f" Then
        FPS = Val(Mid$(arg$, 3))
    ElseIf LCase$(Left$(arg$, 2)) = "-g" Then
        GModeIndex = ParseNum(Mid$(arg$, 3))
        GMode = ResolveGModeArg(GModeIndex)
    ElseIf LCase$(Left$(arg$, 2)) = "-y" Then
        StartRow = Val(Mid$(arg$, 3))
        UseStartRow = -1
    ElseIf LCase$(Left$(arg$, 2)) = "-m" Then
        MemStart = ParseNum(Mid$(arg$, 3))
        UseStartRow = 0
    ElseIf LCase$(Left$(arg$, 2)) = "-p" Then
        PalMode = Val(Mid$(arg$, 3))
    ElseIf LCase$(Left$(arg$, 2)) = "-t" Then
        CoCo1ArtifactMode = Val(Mid$(arg$, 3))
        CoCo1ArtifactModeSpecified = -1
    ElseIf LCase$(Left$(arg$, 3)) = "-sp" Then
        eqPos2 = InStr(arg$, "=")
        If eqPos2 > 4 Then
            spIdx = Val(Mid$(arg$, 4, eqPos2 - 4))
            If spIdx >= 1 And spIdx <= 15 Then
                ForceSPEnabled(spIdx) = -1
                ForceSPValue(spIdx) = Val(Mid$(arg$, eqPos2 + 1)) And 63
                If spIdx = 1 Then
                    ForceSP1Enabled = -1
                    ForceSP1Value = ForceSPValue(1)
                End If
            End If
        End If
    ElseIf LCase$(Left$(arg$, 2)) = "-c" Then
        PalettePickMethod = Val(Mid$(arg$, 3))
    ElseIf LCase$(Left$(arg$, 2)) = "-l" Then
        ShadowLumaGreyMode = Val(Mid$(arg$, 3))
    ElseIf LCase$(Left$(arg$, 6)) = "-name=" Then
        MovieName$ = Mid$(arg$, 7)
    ElseIf LCase$(Left$(arg$, 3)) = "-i=" Then
        If ParsePaletteList(Mid$(arg$, 4)) = 0 Then
            Print "Error: bad palette list in "; arg$
            System
        End If
    Else
        PosCount = PosCount + 1
        If PosCount <= 20 Then PosArg$(PosCount) = arg$
    End If
Next

AfterOldParse:

CoCo1VideoOnly = (GModeIndex = 8 Or GModeIndex = 15 Or GModeIndex = 16)

If PosCount > 0 Then
    If CoCo1VideoOnly Then
        If PosCount = 3 Then
            ResArg$ = PosArg$(1): haveRes = -1
            AudSectors = 2: haveAudioSectors = -1
            FramePattern$ = PosArg$(2): havePattern = -1
            AudioFile$ = "": haveAudio = -1
            OutFile$ = PosArg$(3): haveOutput = -1
        ElseIf PosCount = 4 Then
            ResArg$ = PosArg$(1): haveRes = -1
            AudSectors = 2: haveAudioSectors = -1
            FramePattern$ = PosArg$(2): havePattern = -1
            AudioFile$ = PosArg$(3): haveAudio = -1
            OutFile$ = PosArg$(4): haveOutput = -1
        ElseIf PosCount >= 5 Then
            ResArg$ = PosArg$(1): haveRes = -1
            AudSectors = 2: haveAudioSectors = -1
            FramePattern$ = PosArg$(3): havePattern = -1
            AudioFile$ = PosArg$(4): haveAudio = -1
            OutFile$ = PosArg$(5): haveOutput = -1
        End If
    ElseIf PosCount >= 5 Then
        ResArg$ = PosArg$(1): haveRes = -1
        AudSectors = Val(PosArg$(2)): haveAudioSectors = -1
        FramePattern$ = PosArg$(3): havePattern = -1
        AudioFile$ = PosArg$(4): haveAudio = -1
        OutFile$ = PosArg$(5): haveOutput = -1
    End If
End If

If CoCo1VideoOnly Then
    AudSectors = 2
    haveAudioSectors = -1
    haveAudio = -1
    PalMode = 0
    FPS = 12
    If GModeIndex = 8 Then
        If CoCo1ArtifactModeSpecified = 0 Then CoCo1ArtifactMode = 0
        If CoCo1ArtifactMode < 0 Or CoCo1ArtifactMode > 1 Then
            Print "Error: GMODE 8 SG24 conversion mode must be -t0 or -t1"
            System
        End If
    ElseIf GModeIndex = 15 Then
        If CoCo1ArtifactModeSpecified = 0 Then CoCo1ArtifactMode = 0
        If CoCo1ArtifactMode < 0 Or CoCo1ArtifactMode > 1 Then
            Print "Error: GMODE 15 colour set must be -t0 or -t1"
            System
        End If
    Else
        If CoCo1ArtifactMode < 0 Or CoCo1ArtifactMode > 3 Then
            Print "Error: GMODE 16 artifact mode must be -t0, -t1, -t2, or -t3"
            System
        End If
    End If
End If

If haveRes = 0 Or haveAudioSectors = 0 Or havePattern = 0 Or haveAudio = 0 Or haveOutput = 0 Then
    ShowUsage
    System
End If

If ParseResolution(ResArg$, FrameW, FrameH) = 0 Then
    Print "Error: bad resolution: "; ResArg$
    System
End If

If FrameW < 1 Or FrameH < 1 Or FrameH > 255 Then
    Print "Error: width must be >= 1 and height must be 1..255"
    System
End If

If CoCo1VideoOnly = 0 And (AudSectors < 1 Or AudSectors > 255) Then
    Print "Error: AudioSectors must be 1..255"
    System
End If

If CoCo1VideoOnly <> 0 And AudSectors <> 2 Then
    Print "Error: GMODE 8/15/16 CoCo 1 output uses two audio buffer sectors per frame"
    System
End If

If FPS < 1 Or FPS > 255 Then
    Print "Error: FPS must be 1..255"
    System
End If

If CoCo1VideoOnly Then
    If GModeIndex = 8 Then
        ScreenW = 64
        ScreenColors = 9
    ElseIf GModeIndex = 15 Then
        ScreenW = 128
        ScreenColors = 4
    Else
        ScreenW = 256
        ScreenColors = 2
    End If
    ScreenH = 192
    If FrameW <> ScreenW Or FrameH <> 192 Then
        Print "Error: GMODE"; GModeIndex; " CoCo 1 output must be"; ScreenW; "x192"
        System
    End If
ElseIf GModeIndex >= 100 And GModeIndex <= 165 Then
    If GetModeInfo(GModeIndex, ScreenW, ScreenH, ScreenColors) = 0 Then
        Print "Error: could not decode CoCo mode "; GModeIndex
        System
    End If
Else
    ScreenW = FrameW
    ScreenH = FrameH
    If PalMode <> 0 Then
        ScreenColors = 16
    Else
        ScreenColors = 256
    End If
End If

If ScreenColors = 2 Then
    PalMode = 0
ElseIf ScreenColors = 4 Then
    PalMode = 0
ElseIf ScreenColors = 9 Then
    PalMode = 0
ElseIf GModeIndex >= 160 Then
    PalMode = 0
End If

Select Case ScreenColors
    Case 2
        ScreenBytesPerRow = (ScreenW + 7) \ 8
    Case 4
        ScreenBytesPerRow = (ScreenW + 3) \ 4
    Case 9
        ScreenBytesPerRow = (ScreenW + 1) \ 2
    Case 16
        ScreenBytesPerRow = (ScreenW + 1) \ 2
    Case Else
        ScreenBytesPerRow = ScreenW
End Select

If UseStartRow = 0 Then
    StartRow = (ScreenH - FrameH) \ 2
End If

If StartRow < 0 Then
    Print "Error: video height is larger than the selected screen mode"
    Print "Screen rows:"; ScreenH; "  video height:"; FrameH
    System
End If

If StartRow + FrameH > ScreenH Then
    Print "Error: video height at start row goes past bottom of screen"
    Print "Screen rows:"; ScreenH; "  start row:"; StartRow; "  video height:"; FrameH
    System
End If

Dim FrameBytesPerRow As Integer
Select Case ScreenColors
    Case 2
        FrameBytesPerRow = (FrameW + 7) \ 8
    Case 4
        FrameBytesPerRow = (FrameW + 3) \ 4
    Case 9
        FrameBytesPerRow = (FrameW + 1) \ 2
    Case 16
        FrameBytesPerRow = (FrameW + 1) \ 2
    Case Else
        FrameBytesPerRow = FrameW
End Select

StartByteX = (ScreenBytesPerRow - FrameBytesPerRow) \ 2
If StartByteX < 0 Then
    Print "Error: video width is larger than the selected screen mode"
    Print "Screen bytes/row:"; ScreenBytesPerRow; "  video bytes/row:"; FrameBytesPerRow
    System
End If

MemStart = &H8000 + CLng(ScreenBytesPerRow) * CLng(StartRow + FrameH - 1) + StartByteX

VideoBytesPerFrame = CLng(FrameBytesPerRow) * CLng(FrameH)
VidSectors = (VideoBytesPerFrame + BYTES_PER_SECTOR - 1) \ BYTES_PER_SECTOR
AudioBytesPerFrame = CLng(AudSectors) * BYTES_PER_SECTOR
Dim BytesPerSecond As Long
If CoCo1VideoOnly Then
    BytesPerSecond = CLng(FPS) * (VidSectors + AudSectors) * BYTES_PER_SECTOR
Else
    BytesPerSecond = CLng(FPS) * (VideoBytesPerFrame + AudioBytesPerFrame)
End If
If PalMode <> 0 Then BytesPerSecond = BytesPerSecond + CLng(FPS) * 16
SampleRate = CLng(FPS) * AudioBytesPerFrame
If SampleRate > 0 Then
    If CoCo1VideoOnly Then
        FIRQDelay = 0
    Else
        FIRQDelay = CLng(1000000# / (SampleRate * 0.279365#) + .5)
    End If
Else
    FIRQDelay = 0
End If

ReDim Shared pixelR(0 To FrameW - 1, 0 To FrameH - 1) As _Unsigned _Byte
ReDim Shared pixelG(0 To FrameW - 1, 0 To FrameH - 1) As _Unsigned _Byte
ReDim Shared pixelB(0 To FrameW - 1, 0 To FrameH - 1) As _Unsigned _Byte
ReDim Shared DitherOut(0 To FrameW - 1, 0 To FrameH - 1) As _Unsigned _Byte
videoFrameBytes = VidSectors * BYTES_PER_SECTOR
ReDim tempVideo(0 To videoFrameBytes - 1) As _Unsigned _Byte
If CoCo1VideoOnly Then
    ReDim muxedFrame(0 To (AudSectors + VidSectors) * BYTES_PER_SECTOR - 1) As _Unsigned _Byte
Else
    ReDim muxedFrame(0 To (AudSectors + VidSectors) * BYTES_PER_SECTOR - 1) As _Unsigned _Byte
End If

If AudSectors > 0 And AudioFile$ <> "" Then
    If _FileExists(AudioFile$) = 0 Then
        Print "Error: audio file not found: "; AudioFile$
        System
    End If

    AudioFH = FreeFile
    Open AudioFile$ For Binary As #AudioFH
    audioLen = LOF(AudioFH)
    If audioLen < 1 Then
        Print "Error: audio file is empty: "; AudioFile$
        Close #AudioFH
        System
    End If
Else
    AudioFH = 0
    audioLen = 0
End If
audioPos = 1

If _FileExists(OutFile$) Then Kill OutFile$
outFH = FreeFile
Open OutFile$ For Binary As #outFH

Cls
Print "MakeNTM v"; VersionNumber$; " by Glen Hewlett"
Print
ReportLine "Resolution", _Trim$(Str$(FrameW)) + " x " + _Trim$(Str$(FrameH))
ReportLine "Dither type", _Trim$(Str$(DitherType))
ReportLine "Graphics mode", _Trim$(Str$(GMode)) + "   %" + ByteToBin$(GMode)
ReportLine "FPS", _Trim$(Str$(FPS))
If CoCo1VideoOnly Then
    If GModeIndex = 8 Then
        ReportLine "CoCo mode", "GMODE 8  64x192 SG24 audio-buffer stream"
        If CoCo1ArtifactMode = 0 Then
            ReportLine "SG24 mode", "0 pair colour matching"
        Else
            ReportLine "SG24 mode", "1 3-pixel look-ahead matching"
        End If
    ElseIf GModeIndex = 15 Then
        ReportLine "CoCo mode", "GMODE 15  128x192x4 audio-buffer stream"
        If CoCo1ArtifactMode = 0 Then
            ReportLine "Colour set", "0 green/yellow/blue/red"
        Else
            ReportLine "Colour set", "1 buff/cyan/magenta/orange"
        End If
    Else
        ReportLine "CoCo mode", "GMODE 16  256x192x2 audio-buffer stream"
        Select Case CoCo1ArtifactMode
            Case 0
                ReportLine "Artifact mode", "0 current 1-bit B/W"
            Case 1
                ReportLine "Artifact mode", "1 solid 2-pixel B/W"
            Case 2
                ReportLine "Artifact mode", "2 black/red/blue/white artifact"
            Case 3
                ReportLine "Artifact mode", "3 2x2 artifact colour"
        End Select
    End If
ElseIf GModeIndex >= 100 And GModeIndex <= 165 Then
    ReportLine "CoCo mode index", _Trim$(Str$(GModeIndex)) + "   " + GModeDesc$(GModeIndex)
End If
ReportLine "Screen size", _Trim$(Str$(ScreenW)) + " x " + _Trim$(Str$(ScreenH))
ReportLine "Screen bytes/row", _Trim$(Str$(ScreenBytesPerRow))
ReportLine "Video start row", _Trim$(Str$(StartRow))
ReportLine "Video start byte", _Trim$(Str$(StartByteX))
ReportLine "Video bytes/frame", _Trim$(Str$(VideoBytesPerFrame))
ReportLine "Video sectors", _Trim$(Str$(VidSectors))
ReportLine "Audio sectors", _Trim$(Str$(AudSectors))
ReportLine "Audio bytes/frame", _Trim$(Str$(AudioBytesPerFrame))
ReportLine "Sample rate", _Trim$(Str$(SampleRate))
ReportLine "Bytes/second", _Trim$(Str$(BytesPerSecond))
ReportLine "FIRQ delay", _Trim$(Str$(FIRQDelay))
ReportLine "Mem start", "$" + Hex$(MemStart And &HFFFF)
ReportLine "Palette mode", _Trim$(Str$(PalMode))
ReportLine "Palette chooser", _Trim$(Str$(PalettePickMethod))
ReportLine "Shadow luma/grey", _Trim$(Str$(ShadowLumaGreyMode))
ReportLine "Frame pattern", FramePattern$
If AudSectors > 0 Then ReportLine "Audio file", AudioFile$
ReportLine "Output file", OutFile$
Print

'Dim I As Integer
Dim I2 As Integer
Dim MessCount As Integer
Dim Mess$(6)
Dim Mode$

If MovieName$ = "" Then
    MovieName$ = Left$(OutFile$, Len(OutFile$) - 4)
End If
Mess$(0) = MovieName$
If CoCo1VideoOnly Then
    If GModeIndex = 8 Then
        Mode$ = "CoCo 1 GMODE 8 A/V"
    ElseIf GModeIndex = 15 Then
        Mode$ = "CoCo 1 GMODE 15 A/V"
    Else
        Mode$ = "CoCo 1 GMODE 16 A/V"
    End If
ElseIf GModeIndex > 159 Then
    Mode$ = "NTSC"
Else
    Mode$ = "RGB"
End If
Mess$(1) = "Resolution: " + _Trim$(Str$(FrameW)) + " x " + _Trim$(Str$(FrameH)) + ", FPS: " + _Trim$(Str$(FPS)) + ", " + Mode$
'Mess$(2) = "Video Bytes Per Frame: " + _Trim$(Str$(VideoBytesPerFrame))
If AudSectors > 0 Then
    Mess$(2) = "Audio Sample Rate: " + _Trim$(Str$(SampleRate))
Else
    Mess$(2) = "Video Only"
End If
Mess$(3) = "Bytes/second: " + _Trim$(Str$(BytesPerSecond))

Mess$(5) = ProgramName$ + " " + VersionNumber$
Mess$(6) = "Options: -g" + _Trim$(Str$(GModeIndex)) + " -d" + _Trim$(Str$(DitherType)) + " -p" + _Trim$(Str$(PalMode)) + " -c" + _Trim$(Str$(PalettePickMethod))
Mess$(6) = Mess$(6) + " -l" + _Trim$(Str$(ShadowLumaGreyMode))
If CoCo1VideoOnly Then
    Mess$(6) = Mess$(6) + " -t" + _Trim$(Str$(CoCo1ArtifactMode))
ElseIf AudSectors > 0 Then
    Mess$(6) = Mess$(6) + " -a" + _Trim$(Str$(AudSectors))
End If

For I2 = 0 To 279
    TextMessage(I2) = &H20 ' Fill is with spaces
Next I2
For i = 0 To 6
    MessCount = i * 40
    For I2 = 1 To Len(Mess$(i))
        TextMessage(MessCount) = Asc(Mid$(Mess$(i), I2, 1))
        MessCount = MessCount + 1
    Next I2
Next i

Dim totalFrames As Single
frameIndex = 0
frameCount = 0
processedInGroup = 0
headerWritten = 0
totalFrames = 0

Do
    frameFile$ = ExpandFramePattern$(FramePattern$, totalFrames)
    If _FileExists(frameFile$) = 0 Then Exit Do
    totalFrames = totalFrames + 1
Loop

TotalFramesForHeader = CLng(totalFrames)
If totalFrames > 0 Then
    WriteStatusLine 18, "Frame 0 of " + LTrim$(Str$(totalFrames)) + " (0%)"
Else
    WriteStatusLine 18, "Frame 0 of 0 (0%)"
End If
WriteStatusLine 19, Space$(79)

frameIndex = 0
Do
    groupCount = 0
    For groupIndex = 0 To 31
        frameFile$ = ExpandFramePattern$(FramePattern$, frameIndex + groupIndex)
        If _FileExists(frameFile$) = 0 Then Exit For
        groupFrameFiles(groupIndex) = frameFile$
        groupCount = groupCount + 1
    Next groupIndex

    If groupCount = 0 Then Exit Do

    ReDim groupVideo(0 To groupCount * videoFrameBytes - 1) As _Unsigned _Byte
    ReDim groupPalettes(0 To groupCount * 16 - 1) As _Unsigned _Byte

    For groupIndex = 0 To groupCount - 1
        ConvertOneFrame groupFrameFiles(groupIndex), tempVideo(), tempPalette()

        basePos = groupIndex * videoFrameBytes
        For copyPos = 0 To videoFrameBytes - 1
            groupVideo(basePos + copyPos) = tempVideo(copyPos)
        Next copyPos

        basePos = groupIndex * 16
        For check = 0 To 15
            groupPalettes(basePos + check) = tempPalette(check)
        Next check

        groupPalettes(basePos + 0) = 0
        tempPalette(0) = 0
        For check = 1 To 15
            If ForceSPEnabled(check) Then
                groupPalettes(basePos + check) = ForceSPValue(check) And 63
                tempPalette(check) = ForceSPValue(check) And 63
            End If
        Next check
    Next groupIndex

    If headerWritten = 0 Then
        If ScreenColors = 2 Then
            PalMode = 0
            InitPalette(0) = &H00
            InitPalette(1) = &H3F
            For check = 2 To 15
                InitPalette(check) = 0
            Next check
        ElseIf ScreenColors = 4 Then
            PalMode = 0
            InitPalette(0) = &H00
            InitPalette(1) = &H07
            InitPalette(2) = &H38
            InitPalette(3) = &H3F
            For check = 4 To 15
                InitPalette(check) = 0
            Next check
        ElseIf ScreenColors = 9 Then
            PalMode = 0
            InitPalette(0) = &H00
            For check = 1 To 15
                InitPalette(check) = 0
            Next check
        ElseIf GModeIndex >= 160 Then
            PalMode = 0
            InitPalette(0) = &H00
            InitPalette(1) = &H10
            InitPalette(2) = &H20
            InitPalette(3) = &H30
            For check = 4 To 15
                InitPalette(check) = 0
            Next check
        ElseIf PalMode <> 0 And groupCount > 0 Then
            For check = 0 To 15
                InitPalette(check) = groupPalettes(check)
            Next check
        End If
        WriteStatusLine 19, "Writing header..."
        WriteHeaderSector outFH
        headerWritten = -1
    End If

    If PalMode <> 0 Then
        WritePaletteSector outFH, groupPalettes(), groupCount
    End If

    Dim progressPercent As Single

    For groupIndex = 0 To groupCount - 1
        basePos = groupIndex * videoFrameBytes
        For copyPos = 0 To videoFrameBytes - 1
            tempVideo(copyPos) = groupVideo(basePos + copyPos)
        Next copyPos
        BuildMuxedFrame tempVideo(), muxedFrame()
        Put #outFH, , muxedFrame()
        frameCount = frameCount + 1
        If totalFrames > 0 Then
            progressPercent = CInt((frameCount * 100#) / totalFrames)
            If progressPercent > 100 Then progressPercent = 100
            WriteStatusLine 18, "Frame " + LTrim$(Str$(frameCount)) + " of " + LTrim$(Str$(totalFrames)) + " (" + LTrim$(Str$(progressPercent)) + "%)"
        Else
            WriteStatusLine 18, "Frame " + LTrim$(Str$(frameCount)) + " of 0 (0%)"
        End If
    Next groupIndex

    frameIndex = frameIndex + groupCount
Loop

If headerWritten = 0 Then
    If ScreenColors = 2 Then
        PalMode = 0
        InitPalette(0) = &H00
        InitPalette(1) = &H3F
        For check = 2 To 15
            InitPalette(check) = 0
        Next check
    ElseIf ScreenColors = 4 Then
        PalMode = 0
        InitPalette(0) = &H00
        InitPalette(1) = &H07
        InitPalette(2) = &H38
        InitPalette(3) = &H3F
        For check = 4 To 15
            InitPalette(check) = 0
        Next check
    ElseIf ScreenColors = 9 Then
        PalMode = 0
        InitPalette(0) = &H00
        For check = 1 To 15
            InitPalette(check) = 0
        Next check
    ElseIf GModeIndex >= 160 Then
        PalMode = 0
        InitPalette(0) = &H00
        InitPalette(1) = &H10
        InitPalette(2) = &H20
        InitPalette(3) = &H30
        For check = 4 To 15
            InitPalette(check) = 0
        Next check
    End If
    WriteStatusLine 19, "Writing header..."
    WriteHeaderSector outFH
End If

Close #outFH
If AudioFH <> 0 Then Close #AudioFH
WriteStatusLine 18, Space$(79)
WriteStatusLine 19, Space$(79)
Locate 20, 1
Print "Done."
If AudioFile$ <> "" Then ReportLine "Input file", AudioFile$
ReportLine "Frames written", _Trim$(Str$(frameCount))
If AudSectors > 0 Then ReportLine "Audio bytes used", _Trim$(Str$(audioPos - 1))
ReportLine "Output file", OutFile$
System

OrderedDitherData:
Data 0,2,8,0,2,0,10,0
Data 3,1,0,0,0,0,0,0
Data 3,1,4,0,14,0,6,0
Data 0,0,0,0,0,0,0,0
Data 3,0,11,0,1,0,9,0
Data 0,0,0,0,0,0,0,0
Data 15,0,7,0,13,0,5,0
Data 0,0,0,0,0,0,0,0


' All Colours values from real GIME scanned on a 1084S monitor
' Raw RGB values as they were scanned
' Measured CoCo 3 composite monitor colours - raw scanned values
' Captured with ColorMunki Display and ArgyllCMS spotread

RawPaletteData:
' Colour 0
Data 3,2,5
' Colour 1
Data 3,11,9
' Colour 2
Data 10,52,54
' Colour 3
Data 35,135,69
' Colour 4
Data 1,5,66
' Colour 5
Data 1,19,80
' Colour 6
Data 2,58,125
' Colour 7
Data 31,141,144
' Colour 8
Data 13,19,135
' Colour 9
Data 0,26,154
' Colour 10
Data 0,61,200
' Colour 11
Data 21,136,221
' Colour 12
Data 26,45,255
' Colour 13
Data 0,63,255
' Colour 14
Data 0,93,255
' Colour 15
Data 0,150,255
' Colour 16
Data 26,3,16
' Colour 17
Data 9,6,25
' Colour 18
Data 8,47,72
' Colour 19
Data 35,134,87
' Colour 20
Data 33,8,81
' Colour 21
Data 12,15,97
' Colour 22
Data 0,56,142
' Colour 23
Data 31,139,161
' Colour 24
Data 61,24,147
' Colour 25
Data 39,28,165
' Colour 26
Data 8,60,211
' Colour 27
Data 15,135,236
' Colour 28
Data 81,48,255
' Colour 29
Data 57,62,255
' Colour 30
Data 25,93,255
' Colour 31
Data 0,153,255
' Colour 32
Data 75,7,5
' Colour 33
Data 58,9,11
' Colour 34
Data 37,50,57
' Colour 35
Data 37,138,73
' Colour 36
Data 85,12,69
' Colour 37
Data 67,18,83
' Colour 38
Data 45,56,129
' Colour 39
Data 31,143,147
' Colour 40
Data 117,26,137
' Colour 41
Data 96,31,154
' Colour 42
Data 71,60,201
' Colour 43
Data 39,137,223
' Colour 44
Data 135,49,255
' Colour 45
Data 114,64,255
' Colour 46
Data 88,94,255
' Colour 47
Data 47,154,255
' Colour 48
Data 155,25,43
' Colour 49
Data 148,25,52
' Colour 50
Data 135,45,99
' Colour 51
Data 96,129,115
' Colour 52
Data 164,32,115
' Colour 53
Data 154,34,124
' Colour 54
Data 143,53,162
' Colour 55
Data 104,134,188
' Colour 56
Data 191,44,183
' Colour 57
Data 185,45,188
' Colour 58
Data 174,64,226
' Colour 59
Data 131,131,255
' Colour 60
Data 231,63,255
' Colour 61
Data 212,71,255
' Colour 62
Data 188,93,255
' Colour 63
Data 147,151,255
' Colour 64
Data 5,3,1
' Colour 65
Data 10,43,0
' Colour 66
Data 22,86,6
' Colour 67
Data 45,170,15
' Colour 68
Data 9,5,25
' Colour 69
Data 11,48,33
' Colour 70
Data 19,90,79
' Colour 71
Data 44,174,95
' Colour 72
Data 34,14,105
' Colour 73
Data 18,42,119
' Colour 74
Data 8,84,164
' Colour 75
Data 39,169,178
' Colour 76
Data 51,48,235
' Colour 77
Data 27,77,251
' Colour 78
Data 0,112,255
' Colour 79
Data 22,179,255
' Colour 80
Data 41,4,1
' Colour 81
Data 25,37,0
' Colour 82
Data 21,80,23
' Colour 83
Data 46,167,36
' Colour 84
Data 50,7,42
' Colour 85
Data 33,42,51
' Colour 86
Data 24,84,97
' Colour 87
Data 44,171,114
' Colour 88
Data 79,19,117
' Colour 89
Data 59,41,131
' Colour 90
Data 35,80,179
' Colour 91
Data 37,166,193
' Colour 92
Data 98,50,245
' Colour 93
Data 78,76,255
' Colour 94
Data 53,110,255
' Colour 95
Data 29,175,255
' Colour 96
Data 92,11,0
' Colour 97
Data 74,40,0
' Colour 98
Data 54,82,8
' Colour 99
Data 46,170,17
' Colour 100
Data 101,15,28
' Colour 101
Data 83,45,36
' Colour 102
Data 63,86,82
' Colour 103
Data 49,173,102
' Colour 104
Data 127,26,111
' Colour 105
Data 114,43,123
' Colour 106
Data 90,81,168
' Colour 107
Data 59,166,180
' Colour 108
Data 152,53,236
' Colour 109
Data 132,77,254
' Colour 110
Data 106,111,255
' Colour 111
Data 69,178,255
' Colour 112
Data 175,29,2
' Colour 113
Data 165,44,5
' Colour 114
Data 152,73,49
' Colour 115
Data 114,161,65
' Colour 116
Data 179,36,69
' Colour 117
Data 177,50,78
' Colour 118
Data 162,78,123
' Colour 119
Data 122,164,141
' Colour 120
Data 206,44,152
' Colour 121
Data 199,53,160
' Colour 122
Data 189,80,199
' Colour 123
Data 148,158,216
' Colour 124
Data 241,65,255
' Colour 125
Data 228,81,255
' Colour 126
Data 205,111,255
' Colour 127
Data 164,173,255
' Colour 128
Data 17,55,0
' Colour 129
Data 29,98,0
' Colour 130
Data 38,137,0
' Colour 131
Data 56,216,0
' Colour 132
Data 20,60,0
' Colour 133
Data 27,102,0
' Colour 134
Data 39,140,17
' Colour 135
Data 58,219,34
' Colour 136
Data 41,52,54
' Colour 137
Data 34,93,63
' Colour 138
Data 35,133,111
' Colour 139
Data 53,213,123
' Colour 140
Data 55,75,207
' Colour 141
Data 38,109,221
' Colour 142
Data 28,146,255
' Colour 143
Data 46,217,255
' Colour 144
Data 44,49,1
' Colour 145
Data 34,91,0
' Colour 146
Data 39,130,0
' Colour 147
Data 56,211,0
' Colour 148
Data 53,54,1
' Colour 149
Data 42,95,0
' Colour 150
Data 40,134,36
' Colour 151
Data 57,214,54
' Colour 152
Data 82,46,71
' Colour 153
Data 65,87,80
' Colour 154
Data 49,128,126
' Colour 155
Data 53,208,140
' Colour 156
Data 100,73,219
' Colour 157
Data 82,105,236
' Colour 158
Data 58,140,255
' Colour 159
Data 46,215,255
' Colour 160
Data 94,53,0
' Colour 161
Data 78,94,0
' Colour 162
Data 61,133,0
' Colour 163
Data 57,213,0
' Colour 164
Data 105,57,0
' Colour 165
Data 87,98,0
' Colour 166
Data 69,136,18
' Colour 167
Data 59,216,35
' Colour 168
Data 134,51,55
' Colour 169
Data 117,90,64
' Colour 170
Data 96,129,113
' Colour 171
Data 69,207,124
' Colour 172
Data 150,74,205
' Colour 173
Data 133,107,224
' Colour 174
Data 110,143,255
' Colour 175
Data 78,218,255
' Colour 176
Data 185,52,0
' Colour 177
Data 175,83,0
' Colour 178
Data 153,120,0
' Colour 179
Data 115,201,0
' Colour 180
Data 194,57,12
' Colour 181
Data 185,87,19
' Colour 182
Data 162,123,66
' Colour 183
Data 125,204,86
' Colour 184
Data 217,59,100
' Colour 185
Data 210,85,108
' Colour 186
Data 192,119,153
' Colour 187
Data 151,200,168
' Colour 188
Data 236,80,238
' Colour 189
Data 228,106,248
' Colour 190
Data 204,138,255
' Colour 191
Data 164,208,255
' Colour 192
Data 48,127,0
' Colour 193
Data 46,162,0
' Colour 194
Data 51,195,0
' Colour 195
Data 67,255,0
' Colour 196
Data 54,129,0
' Colour 197
Data 51,165,0
' Colour 198
Data 50,196,0
' Colour 199
Data 68,255,0
' Colour 200
Data 79,120,0
' Colour 201
Data 66,158,0
' Colour 202
Data 59,190,0
' Colour 203
Data 65,255,0
' Colour 204
Data 98,130,112
' Colour 205
Data 83,167,122
' Colour 206
Data 68,199,165
' Colour 207
Data 64,255,175
' Colour 208
Data 82,118,0
' Colour 209
Data 69,153,0
' Colour 210
Data 60,187,0
' Colour 211
Data 66,255,0
' Colour 212
Data 92,121,0
' Colour 213
Data 78,158,0
' Colour 214
Data 66,190,0
' Colour 215
Data 65,255,0
' Colour 216
Data 120,113,0
' Colour 217
Data 102,150,0
' Colour 218
Data 87,183,0
' Colour 219
Data 71,255,17
' Colour 220
Data 141,123,128
' Colour 221
Data 122,157,136
' Colour 222
Data 103,189,179
' Colour 223
Data 78,255,190
' Colour 224
Data 130,117,0
' Colour 225
Data 114,153,0
' Colour 226
Data 97,186,0
' Colour 227
Data 75,254,0
' Colour 228
Data 141,121,0
' Colour 229
Data 123,157,0
' Colour 230
Data 105,189,0
' Colour 231
Data 81,255,0
' Colour 232
Data 171,114,0
' Colour 233
Data 153,150,0
' Colour 234
Data 134,183,0
' Colour 235
Data 102,255,0
' Colour 236
Data 191,124,113
' Colour 237
Data 172,159,121
' Colour 238
Data 151,191,166
' Colour 239
Data 116,255,175
' Colour 240
Data 224,106,0
' Colour 241
Data 206,141,0
' Colour 242
Data 185,172,0
' Colour 243
Data 147,245,0
' Colour 244
Data 234,110,0
' Colour 245
Data 216,143,0
' Colour 246
Data 196,175,0
' Colour 247
Data 156,247,0
' Colour 248
Data 255,108,0
' Colour 249
Data 242,136,0
' Colour 250
Data 223,167,43
' Colour 251
Data 185,241,58
' Colour 252
Data 255,120,150
' Colour 253
Data 255,150,159
' Colour 254
Data 235,178,199
' Colour 255
Data 196,245,208

' Pre colour balanced/Gamma corrected

' Measured CoCo 3 composite monitor colours - scaled values
' Captured with ColorMunki Display and ArgyllCMS spotread
' Scaled using composite grayscale anchors:
' Black=3,2,6  Dark=98,136,118  Mid=125,168,144  Light=152,200,169  White=202,255,214
ScaledPaletteData:
' Colour 0
Data 0,0,0
' Colour 1
Data 0,4,2
' Colour 2
Data 5,24,27
' Colour 3
Data 22,64,36
' Colour 4
Data 0,1,34
' Colour 5
Data 0,8,42
' Colour 6
Data 0,27,81
' Colour 7
Data 19,74,128
' Colour 8
Data 7,8,106
' Colour 9
Data 0,11,154
' Colour 10
Data 0,28,235
' Colour 11
Data 12,64,255
' Colour 12
Data 15,21,255
' Colour 13
Data 0,29,255
' Colour 14
Data 0,43,255
' Colour 15
Data 0,92,255
' Colour 16
Data 15,0,6
' Colour 17
Data 4,2,11
' Colour 18
Data 3,21,38
' Colour 19
Data 22,63,46
' Colour 20
Data 20,3,43
' Colour 21
Data 6,6,52
' Colour 22
Data 0,26,123
' Colour 23
Data 19,70,172
' Colour 24
Data 39,11,136
' Colour 25
Data 24,12,182
' Colour 26
Data 3,28,251
' Colour 27
Data 8,64,255
' Colour 28
Data 53,22,255
' Colour 29
Data 36,29,255
' Colour 30
Data 15,43,255
' Colour 31
Data 0,98,255
' Colour 32
Data 49,2,0
' Colour 33
Data 37,3,3
' Colour 34
Data 23,23,29
' Colour 35
Data 23,68,38
' Colour 36
Data 55,5,36
' Colour 37
Data 43,8,44
' Colour 38
Data 28,26,91
' Colour 39
Data 19,78,136
' Colour 40
Data 109,11,111
' Colour 41
Data 63,14,154
' Colour 42
Data 46,28,237
' Colour 43
Data 24,66,255
' Colour 44
Data 152,22,255
' Colour 45
Data 102,30,255
' Colour 46
Data 57,44,255
' Colour 47
Data 30,100,255
' Colour 48
Data 196,11,21
' Colour 49
Data 183,11,26
' Colour 50
Data 152,21,53
' Colour 51
Data 63,61,62
' Colour 52
Data 207,14,62
' Colour 53
Data 195,15,79
' Colour 54
Data 171,24,174
' Colour 55
Data 78,63,219
' Colour 56
Data 241,20,212
' Colour 57
Data 234,21,219
' Colour 58
Data 220,30,255
' Colour 59
Data 142,62,255
' Colour 60
Data 255,29,255
' Colour 61
Data 255,33,255
' Colour 62
Data 237,43,255
' Colour 63
Data 180,94,255
' Colour 64
Data 1,0,0
' Colour 65
Data 5,20,0
' Colour 66
Data 13,40,0
' Colour 67
Data 28,132,5
' Colour 68
Data 4,1,11
' Colour 69
Data 5,22,15
' Colour 70
Data 11,42,42
' Colour 71
Data 28,140,51
' Colour 72
Data 21,6,57
' Colour 73
Data 10,19,66
' Colour 74
Data 3,39,179
' Colour 75
Data 24,130,205
' Colour 76
Data 32,22,255
' Colour 77
Data 16,36,255
' Colour 78
Data 0,53,255
' Colour 79
Data 13,150,255
' Colour 80
Data 26,1,0
' Colour 81
Data 15,17,0
' Colour 82
Data 12,37,10
' Colour 83
Data 29,126,17
' Colour 84
Data 32,2,21
' Colour 85
Data 20,19,26
' Colour 86
Data 14,39,52
' Colour 87
Data 28,134,62
' Colour 88
Data 51,8,63
' Colour 89
Data 38,19,96
' Colour 90
Data 22,37,206
' Colour 91
Data 23,124,226
' Colour 92
Data 64,23,255
' Colour 93
Data 51,35,255
' Colour 94
Data 34,52,255
' Colour 95
Data 18,142,255
' Colour 96
Data 60,4,0
' Colour 97
Data 48,18,0
' Colour 98
Data 34,38,1
' Colour 99
Data 29,132,6
' Colour 100
Data 71,6,13
' Colour 101
Data 54,21,17
' Colour 102
Data 40,40,43
' Colour 103
Data 31,138,55
' Colour 104
Data 133,11,60
' Colour 105
Data 102,20,76
' Colour 106
Data 59,38,189
' Colour 107
Data 38,124,207
' Colour 108
Data 192,24,255
' Colour 109
Data 145,36,255
' Colour 110
Data 83,52,255
' Colour 111
Data 44,148,255
' Colour 112
Data 221,13,0
' Colour 113
Data 208,20,0
' Colour 114
Data 192,34,25
' Colour 115
Data 102,114,34
' Colour 116
Data 226,16,36
' Colour 117
Data 224,23,41
' Colour 118
Data 205,36,76
' Colour 119
Data 121,120,121
' Colour 120
Data 255,20,148
' Colour 121
Data 251,24,169
' Colour 122
Data 239,37,234
' Colour 123
Data 183,108,255
' Colour 124
Data 255,30,255
' Colour 125
Data 255,38,255
' Colour 126
Data 255,52,255
' Colour 127
Data 207,138,255
' Colour 128
Data 9,25,0
' Colour 129
Data 18,46,0
' Colour 130
Data 24,66,0
' Colour 131
Data 36,210,0
' Colour 132
Data 11,28,0
' Colour 133
Data 16,48,0
' Colour 134
Data 24,72,6
' Colour 135
Data 37,214,16
' Colour 136
Data 26,24,27
' Colour 137
Data 21,43,33
' Colour 138
Data 22,63,60
' Colour 139
Data 34,207,76
' Colour 140
Data 35,35,245
' Colour 141
Data 24,51,255
' Colour 142
Data 17,84,255
' Colour 143
Data 29,211,255
' Colour 144
Data 28,22,0
' Colour 145
Data 21,43,0
' Colour 146
Data 24,61,0
' Colour 147
Data 36,205,0
' Colour 148
Data 34,25,0
' Colour 149
Data 26,44,0
' Colour 150
Data 25,63,17
' Colour 151
Data 36,208,27
' Colour 152
Data 53,21,37
' Colour 153
Data 42,41,42
' Colour 154
Data 31,60,84
' Colour 155
Data 34,201,118
' Colour 156
Data 69,34,255
' Colour 157
Data 53,49,255
' Colour 158
Data 37,72,255
' Colour 159
Data 29,209,255
' Colour 160
Data 61,24,0
' Colour 161
Data 51,44,0
' Colour 162
Data 39,63,0
' Colour 163
Data 36,207,0
' Colour 164
Data 81,26,0
' Colour 165
Data 57,46,0
' Colour 166
Data 44,64,7
' Colour 167
Data 38,210,17
' Colour 168
Data 149,23,28
' Colour 169
Data 109,42,33
' Colour 170
Data 63,61,61
' Colour 171
Data 44,200,79
' Colour 172
Data 187,34,242
' Colour 173
Data 147,50,255
' Colour 174
Data 92,78,255
' Colour 175
Data 51,213,255
' Colour 176
Data 234,24,0
' Colour 177
Data 221,39,0
' Colour 178
Data 193,56,0
' Colour 179
Data 104,193,0
' Colour 180
Data 245,26,3
' Colour 181
Data 234,41,7
' Colour 182
Data 205,58,34
' Colour 183
Data 128,197,46
' Colour 184
Data 255,27,54
' Colour 185
Data 255,40,58
' Colour 186
Data 242,56,151
' Colour 187
Data 190,192,189
' Colour 188
Data 255,37,255
' Colour 189
Data 255,50,255
' Colour 190
Data 255,68,255
' Colour 191
Data 207,201,255
' Colour 192
Data 30,60,0
' Colour 193
Data 29,116,0
' Colour 194
Data 32,182,0
' Colour 195
Data 43,255,0
' Colour 196
Data 34,61,0
' Colour 197
Data 32,122,0
' Colour 198
Data 32,184,0
' Colour 199
Data 44,255,0
' Colour 200
Data 51,56,0
' Colour 201
Data 42,108,0
' Colour 202
Data 38,172,0
' Colour 203
Data 42,255,0
' Colour 204
Data 64,61,61
' Colour 205
Data 54,126,74
' Colour 206
Data 44,190,182
' Colour 207
Data 41,255,200
' Colour 208
Data 53,55,0
' Colour 209
Data 44,98,0
' Colour 210
Data 38,166,0
' Colour 211
Data 42,255,0
' Colour 212
Data 60,57,0
' Colour 213
Data 51,108,0
' Colour 214
Data 42,172,0
' Colour 215
Data 42,255,0
' Colour 216
Data 116,53,0
' Colour 217
Data 73,92,0
' Colour 218
Data 57,158,0
' Colour 219
Data 46,255,6
' Colour 220
Data 166,58,89
' Colour 221
Data 121,106,108
' Colour 222
Data 76,170,206
' Colour 223
Data 51,255,221
' Colour 224
Data 140,55,0
' Colour 225
Data 102,98,0
' Colour 226
Data 63,164,0
' Colour 227
Data 49,254,0
' Colour 228
Data 166,57,0
' Colour 229
Data 123,106,0
' Colour 230
Data 81,170,0
' Colour 231
Data 53,255,0
' Colour 232
Data 216,53,0
' Colour 233
Data 193,92,0
' Colour 234
Data 149,158,0
' Colour 235
Data 73,255,0
' Colour 236
Data 241,58,61
' Colour 237
Data 217,110,71
' Colour 238
Data 190,174,184
' Colour 239
Data 107,255,200
' Colour 240
Data 255,50,0
' Colour 241
Data 255,74,0
' Colour 242
Data 234,136,0
' Colour 243
Data 180,244,0
' Colour 244
Data 255,52,0
' Colour 245
Data 255,78,0
' Colour 246
Data 247,142,0
' Colour 247
Data 197,246,0
' Colour 248
Data 255,51,0
' Colour 249
Data 255,64,0
' Colour 250
Data 255,126,21
' Colour 251
Data 234,239,30
' Colour 252
Data 255,56,143
' Colour 253
Data 255,92,166
' Colour 254
Data 255,148,234
' Colour 255
Data 247,244,247




Declare

Function BuildJumpSectorRateNum& (FPS As Integer, VideoSectors As Integer, AudioSectors As Integer, PalMode As Integer)
    Dim B As _Unsigned Integer

    B = VideoSectors + AudioSectors

    If PalMode <> 0 Then
        BuildJumpSectorRateNum& = 1 + 32 * B
    Else
        BuildJumpSectorRateNum& = FPS * B
    End If
End Function

Declare Function BuildJumpSectorForPercent& (Percent As Integer, TotalFrames As Long, VideoSectors As Integer, AudioSectors As Integer, PalMode As Integer)
Sub ConvertOneFrame (frameFile$, frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
    Dim img As Long
    Dim tempImg As Long
    Dim x As Integer, y As Integer
    Dim p As Long
    Dim PixVal As _Unsigned Long

    img = _LoadImage(frameFile$, 32)
    If img = 0 Then
        Print "Error: could not load image: "; frameFile$
        System
    End If

    If _Width(img) <> FrameW Or _Height(img) <> FrameH Then
        Print "Error: frame must be exactly "; FrameW; "x"; FrameH; " : "; frameFile$
        _FreeImage img
        System
    End If

    imageWidth = FrameW
    imageHeight = FrameH

    tempImg = _NewImage(FrameW, FrameH, 32)
    _Dest tempImg
    _PutImage (0, 0), img
    _Dest _Console

    _Source tempImg
    For y = 0 To imageHeight - 1
        For x = 0 To imageWidth - 1
            PixVal = Point(x, y)
            pixelR(x, y) = _Red32(PixVal)
            pixelG(x, y) = _Green32(PixVal)
            pixelB(x, y) = _Blue32(PixVal)
        Next x
    Next y
    _Source 0
    _Dest _Console

    _FreeImage img
    _FreeImage tempImg

    If ScreenColors = 9 Then
        ConvertFrameToCoCo1SG24 frameVideo(), framePalette()
    ElseIf ScreenColors = 2 Then
        If CoCo1VideoOnly And CoCo1ArtifactMode = 1 Then
            ConvertFrameToCoCo1SolidBW frameVideo(), framePalette()
        ElseIf CoCo1VideoOnly And CoCo1ArtifactMode = 2 Then
            ConvertFrameToCoCo1Artifact4Color frameVideo(), framePalette()
        ElseIf CoCo1VideoOnly And CoCo1ArtifactMode = 3 Then
            ConvertFrameToCoCo1Artifact2x2 frameVideo(), framePalette()
        Else
            ConvertFrameTo1BitBW frameVideo(), framePalette()
        End If
    ElseIf ScreenColors = 4 Then
        If CoCo1VideoOnly Then
            ConvertFrameToCoCo1GMode15 frameVideo(), framePalette()
        Else
            ConvertFrameToGMode151Grey frameVideo(), framePalette()
        End If
    ElseIf PalMode <> 0 Then
        BuildBest16CoCoPalette framePalette()
        PackFrameTo4Bit frameVideo(), framePalette()
    Else
        Select Case DitherType
            Case 0
                Gosub_DoNoDither
            Case 1
                Gosub_DoFloydDither
            Case 2
                Gosub_DoBlueNoiseTexture
            Case 3
                Gosub_DoOrderDither
            Case Else
                Print "Error: bad dither type "; DitherType
                System
        End Select

        For x = 0 To 15
            framePalette(x) = InitPalette(x)
        Next x

        If ScreenColors = 16 Then
            PackFrameTo4Bit frameVideo(), framePalette()
        Else
            p = 0
            For y = 0 To FrameH - 1
                For x = 0 To FrameW - 1
                    frameVideo(p) = DitherOut(x, y)
                    p = p + 1
                Next x
            Next y
            While p <= UBound(frameVideo)
                frameVideo(p) = 0
                p = p + 1
            Wend
        End If
    End If

    ' Final guarantee: keep locked slots fixed in the logical palette for every frame.
    framePalette(0) = 0
    If ForceSP1Enabled Then
        framePalette(1) = ForceSP1Value And 63
    End If
End Sub

Sub InitCoCo64Palette
    Dim c As Integer
    Dim r2 As Integer, g2 As Integer, b2 As Integer

    For c = 0 To 63
        r2 = 0
        If (c And 32) <> 0 Then r2 = r2 + 2
        If (c And 4) <> 0 Then r2 = r2 + 1
        g2 = 0
        If (c And 16) <> 0 Then g2 = g2 + 2
        If (c And 2) <> 0 Then g2 = g2 + 1
        b2 = 0
        If (c And 8) <> 0 Then b2 = b2 + 2
        If (c And 1) <> 0 Then b2 = b2 + 1

        CoCo64RGB(c, 0) = r2 * 85
        CoCo64RGB(c, 1) = g2 * 85
        CoCo64RGB(c, 2) = b2 * 85
    Next c
End Sub

Function FindClosestCoCo64Color% (r As Integer, g As Integer, b As Integer)
    Dim c As Integer
    Dim dr As Integer, dg As Integer, db As Integer
    Dim dd As Long
    Dim best As Long
    Dim bestIdx As Integer

    best = &H7FFFFFFF
    bestIdx = 0
    For c = 0 To 63
        dr = r - CoCo64RGB(c, 0)
        dg = g - CoCo64RGB(c, 1)
        db = b - CoCo64RGB(c, 2)
        dd = CLng(dr) * dr + CLng(dg) * dg + CLng(db) * db
        If dd < best Then
            best = dd
            bestIdx = c
        End If
    Next c
    FindClosestCoCo64Color = bestIdx
End Function

Sub BuildBest16CoCoPalette (framePalette() As _Unsigned _Byte)
    Dim counts(0 To 63) As Long
    Dim used(0 To 63) As Integer
    Dim selected(0 To 15) As Integer
    Dim slotReserved(0 To 15) As Integer
    Dim x As Integer, y As Integer
    Dim idx As Integer
    Dim slot As Integer
    Dim bestCount As Long
    Dim bestIdx As Integer
    Dim score As Double
    Dim bestScore As Double
    Dim minDist As Long
    Dim d As Long
    Dim sIdx As Integer
    Dim dr As Integer, dg As Integer, db As Integer
    Dim anyLocked As Integer
    Dim seen(0 To 63) As Integer
    Dim replIdx As Integer
    Dim prevSlot As Integer

    For y = 0 To imageHeight - 1
        For x = 0 To imageWidth - 1
            idx = FindClosestCoCo64Color(pixelR(x, y), pixelG(x, y), pixelB(x, y))
            counts(idx) = counts(idx) + 1
        Next x
    Next y

    framePalette(0) = 0
    selected(0) = 0
    used(0) = -1
    slotReserved(0) = -1

    anyLocked = 0
    For slot = 1 To 15
        If ForceSPEnabled(slot) Then
            framePalette(slot) = ForceSPValue(slot) And 63
            selected(slot) = framePalette(slot)
            used(framePalette(slot)) = -1
            slotReserved(slot) = -1
            anyLocked = -1
        End If
    Next slot

    If anyLocked = 0 Then
        framePalette(1) = 7
        framePalette(2) = 56
        framePalette(3) = 63
        selected(1) = 7
        selected(2) = 56
        selected(3) = 63
        used(7) = -1
        used(56) = -1
        used(63) = -1
        slotReserved(1) = -1
        slotReserved(2) = -1
        slotReserved(3) = -1
    End If

    If PalettePickMethod = 0 Then
        For slot = 1 To 15
            If slotReserved(slot) = 0 Then
                bestCount = -1
                bestIdx = 1
                For idx = 1 To 63
                    If used(idx) = 0 Then
                        If counts(idx) > bestCount Then
                            bestCount = counts(idx)
                            bestIdx = idx
                        End If
                    End If
                Next idx
                framePalette(slot) = bestIdx And 63
                selected(slot) = bestIdx
                used(bestIdx) = -1
                slotReserved(slot) = -1
            End If
        Next slot
    Else
        For slot = 1 To 15
            If slotReserved(slot) = 0 Then
                bestScore = -1
                bestIdx = 1
                For idx = 1 To 63
                    If used(idx) = 0 Then
                        If counts(idx) > 0 Then
                            minDist = &H7FFFFFFF
                            For sIdx = 0 To 15
                                If slotReserved(sIdx) <> 0 Then
                                    dr = CoCo64RGB(idx, 0) - CoCo64RGB(selected(sIdx), 0)
                                    dg = CoCo64RGB(idx, 1) - CoCo64RGB(selected(sIdx), 1)
                                    db = CoCo64RGB(idx, 2) - CoCo64RGB(selected(sIdx), 2)
                                    d = CLng(dr) * dr + CLng(dg) * dg + CLng(db) * db
                                    If d < minDist Then minDist = d
                                End If
                            Next sIdx
                            score = CDbl(counts(idx)) * (CDbl(minDist) + 1#)
                            If score > bestScore Then
                                bestScore = score
                                bestIdx = idx
                            End If
                        End If
                    End If
                Next idx

                If bestScore < 0 Then
                    bestCount = -1
                    bestIdx = 1
                    For idx = 1 To 63
                        If used(idx) = 0 Then
                            If counts(idx) > bestCount Then
                                bestCount = counts(idx)
                                bestIdx = idx
                            End If
                        End If
                    Next idx
                End If

                framePalette(slot) = bestIdx And 63
                selected(slot) = bestIdx
                used(bestIdx) = -1
                slotReserved(slot) = -1
            End If
        Next slot
    End If
    framePalette(0) = 0
    For slot = 1 To 15
        If ForceSPEnabled(slot) Then
            framePalette(slot) = ForceSPValue(slot) And 63
        End If
    Next slot

    ' Final cleanup: keep locked slots fixed, and remove duplicates from unlocked slots.
    For idx = 0 To 63
        seen(idx) = 0
    Next idx

    For slot = 0 To 15
        idx = framePalette(slot) And 63
        If seen(idx) = 0 Then
            seen(idx) = -1
        ElseIf slot > 0 And ForceSPEnabled(slot) = 0 Then
            bestCount = -1
            replIdx = idx
            For prevSlot = 1 To 63
                If seen(prevSlot) = 0 Then
                    If counts(prevSlot) > bestCount Then
                        bestCount = counts(prevSlot)
                        replIdx = prevSlot
                    End If
                End If
            Next prevSlot
            framePalette(slot) = replIdx And 63
            seen(replIdx And 63) = -1
        End If
    Next slot
End Sub

Function FindClosestPaletteSlotRGB% (r As Integer, g As Integer, b As Integer, framePalette() As _Unsigned _Byte)
    Dim slot As Integer
    Dim c As Integer
    Dim dr As Integer, dg As Integer, db As Integer
    Dim dd As Long
    Dim best As Long
    Dim bestSlot As Integer

    best = &H7FFFFFFF
    bestSlot = 0
    For slot = 0 To 15
        c = framePalette(slot)
        dr = r - CoCo64RGB(c, 0)
        dg = g - CoCo64RGB(c, 1)
        db = b - CoCo64RGB(c, 2)
        dd = CLng(dr) * dr + CLng(dg) * dg + CLng(db) * db
        If dd < best Then
            best = dd
            bestSlot = slot
        End If
    Next slot
    FindClosestPaletteSlotRGB = bestSlot
End Function

Function ClampByte% (n As Integer)
    If n < 0 Then
        ClampByte = 0
    ElseIf n > 255 Then
        ClampByte = 255
    Else
        ClampByte = n
    End If
End Function

Function QuantizeGrey2Bit% (grey As Integer)
    If grey < 43 Then
        QuantizeGrey2Bit = 0
    ElseIf grey < 128 Then
        QuantizeGrey2Bit = 1
    ElseIf grey < 213 Then
        QuantizeGrey2Bit = 2
    Else
        QuantizeGrey2Bit = 3
    End If
End Function

Sub ConvertFrameToCoCo1SG24 (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
    Dim x As Integer, y As Integer
    Dim p As Long
    Dim c As Integer, mask As Integer
    Dim palR(0 To 8) As Integer, palG(0 To 8) As Integer, palB(0 To 8) As Integer
    Dim testR0 As Single, testG0 As Single, testB0 As Single
    Dim testR1 As Single, testG1 As Single, testB1 As Single
    Dim testR2 As Single, testG2 As Single, testB2 As Single
    Dim outR0 As Integer, outG0 As Integer, outB0 As Integer
    Dim outR1 As Integer, outG1 As Integer, outB1 As Integer
    Dim errR As Single, errG As Single, errB As Single
    Dim er As Single, eg As Single, eb As Single
    Dim dr As Long, dg As Long, db As Long
    Dim dist As Long, bestDist As Long
    Dim bestColor As Integer, bestMask As Integer
    Dim threshold As Integer
    Dim lowNibble As Integer
    Dim lum0 As Integer, lum1 As Integer
    Dim forceBlack0 As Integer, forceBlack1 As Integer
    Dim forceWhite0 As Integer, forceWhite1 As Integer
    Dim candidateValid As Integer
    Dim avgR As Long, avgG As Long, avgB As Long

    palR(0) = 0: palG(0) = 0: palB(0) = 0
    palR(1) = 0: palG(1) = 255: palB(1) = 0       ' green
    palR(2) = 255: palG(2) = 255: palB(2) = 0     ' yellow
    palR(3) = 0: palG(3) = 0: palB(3) = 255       ' blue
    palR(4) = 255: palG(4) = 0: palB(4) = 0       ' red
    palR(5) = 255: palG(5) = 245: palB(5) = 200   ' buff / white
    palR(6) = 0: palG(6) = 255: palB(6) = 255     ' cyan
    palR(7) = 255: palG(7) = 0: palB(7) = 255     ' magenta
    palR(8) = 255: palG(8) = 128: palB(8) = 0     ' orange

    For c = 0 To 15
        framePalette(c) = 0
    Next c

    If DitherType = 1 Then
        ReDim errR(0 To FrameW + 1, 0 To FrameH + 1) As Single
        ReDim errG(0 To FrameW + 1, 0 To FrameH + 1) As Single
        ReDim errB(0 To FrameW + 1, 0 To FrameH + 1) As Single
    ElseIf DitherType = 2 Then
        Randomize 1
    End If

    p = 0
    For y = 0 To FrameH - 1
        For x = 0 To FrameW - 1 Step 2
            testR0 = pixelR(x, y)
            testG0 = pixelG(x, y)
            testB0 = pixelB(x, y)
            If x + 1 < FrameW Then
                testR1 = pixelR(x + 1, y)
                testG1 = pixelG(x + 1, y)
                testB1 = pixelB(x + 1, y)
            Else
                testR1 = 0
                testG1 = 0
                testB1 = 0
            End If
            If x + 2 < FrameW Then
                testR2 = pixelR(x + 2, y)
                testG2 = pixelG(x + 2, y)
                testB2 = pixelB(x + 2, y)
            Else
                testR2 = testR1
                testG2 = testG1
                testB2 = testB1
            End If

            If DitherType = 1 Then
                testR0 = testR0 + errR(x, y)
                testG0 = testG0 + errG(x, y)
                testB0 = testB0 + errB(x, y)
                If x + 1 < FrameW Then
                    testR1 = testR1 + errR(x + 1, y)
                    testG1 = testG1 + errG(x + 1, y)
                    testB1 = testB1 + errB(x + 1, y)
                End If
                If x + 2 < FrameW Then
                    testR2 = testR2 + errR(x + 2, y)
                    testG2 = testG2 + errG(x + 2, y)
                    testB2 = testB2 + errB(x + 2, y)
                End If
            ElseIf DitherType = 2 Then
                testR0 = testR0 + Int(Rnd * 65) - 32
                testG0 = testG0 + Int(Rnd * 65) - 32
                testB0 = testB0 + Int(Rnd * 65) - 32
                testR1 = testR1 + Int(Rnd * 65) - 32
                testG1 = testG1 + Int(Rnd * 65) - 32
                testB1 = testB1 + Int(Rnd * 65) - 32
                If x + 2 < FrameW Then
                    testR2 = testR2 + Int(Rnd * 65) - 32
                    testG2 = testG2 + Int(Rnd * 65) - 32
                    testB2 = testB2 + Int(Rnd * 65) - 32
                End If
            ElseIf DitherType = 3 Then
                threshold = (OrderedArray(x And 7, y And 7) - 128) \ 3
                testR0 = testR0 + threshold
                testG0 = testG0 + threshold
                testB0 = testB0 + threshold
                If x + 1 < FrameW Then threshold = (OrderedArray((x + 1) And 7, y And 7) - 128) \ 3
                testR1 = testR1 + threshold
                testG1 = testG1 + threshold
                testB1 = testB1 + threshold
                If x + 2 < FrameW Then
                    threshold = (OrderedArray((x + 2) And 7, y And 7) - 128) \ 3
                    testR2 = testR2 + threshold
                    testG2 = testG2 + threshold
                    testB2 = testB2 + threshold
                End If
            End If

            If testR0 < 0 Then testR0 = 0
            If testR0 > 255 Then testR0 = 255
            If testG0 < 0 Then testG0 = 0
            If testG0 > 255 Then testG0 = 255
            If testB0 < 0 Then testB0 = 0
            If testB0 > 255 Then testB0 = 255
            If testR1 < 0 Then testR1 = 0
            If testR1 > 255 Then testR1 = 255
            If testG1 < 0 Then testG1 = 0
            If testG1 > 255 Then testG1 = 255
            If testB1 < 0 Then testB1 = 0
            If testB1 > 255 Then testB1 = 255
            If testR2 < 0 Then testR2 = 0
            If testR2 > 255 Then testR2 = 255
            If testG2 < 0 Then testG2 = 0
            If testG2 > 255 Then testG2 = 255
            If testB2 < 0 Then testB2 = 0
            If testB2 > 255 Then testB2 = 255

            lum0 = (77 * CInt(testR0) + 150 * CInt(testG0) + 29 * CInt(testB0)) \ 256
            lum1 = (77 * CInt(testR1) + 150 * CInt(testG1) + 29 * CInt(testB1)) \ 256
            forceBlack0 = (lum0 < 48)
            forceBlack1 = (lum1 < 48)
            forceWhite0 = (lum0 > 220)
            forceWhite1 = (lum1 > 220)

            bestDist = 2147483647
            bestColor = 0
            bestMask = 0

            For c = 0 To 8
                If c = 0 Then
                    mask = 0
                    If forceWhite0 = 0 And forceWhite1 = 0 Then
                        outR0 = 0: outG0 = 0: outB0 = 0
                        outR1 = 0: outG1 = 0: outB1 = 0
                        dr = CLng(testR0) - outR0: dg = CLng(testG0) - outG0: db = CLng(testB0) - outB0
                        dist = dr * dr + dg * dg + db * db
                        dr = CLng(testR1) - outR1: dg = CLng(testG1) - outG1: db = CLng(testB1) - outB1
                        dist = dist + dr * dr + dg * dg + db * db
                        If dist < bestDist Then
                            bestDist = dist
                            bestColor = c
                            bestMask = mask
                        End If
                    End If
                Else
                    For mask = 1 To 3
                        candidateValid = -1
                        If forceBlack0 <> 0 And ((mask And 1) <> 0) Then candidateValid = 0
                        If forceBlack1 <> 0 And ((mask And 2) <> 0) Then candidateValid = 0
                        If forceWhite0 Then
                            If c <> 5 Or (mask And 1) = 0 Then candidateValid = 0
                        End If
                        If forceWhite1 Then
                            If c <> 5 Or (mask And 2) = 0 Then candidateValid = 0
                        End If
                        If candidateValid = 0 Then GoTo NextSG24Mask

                        If (mask And 1) <> 0 Then
                            outR0 = palR(c): outG0 = palG(c): outB0 = palB(c)
                        Else
                            outR0 = 0: outG0 = 0: outB0 = 0
                        End If
                        If (mask And 2) <> 0 Then
                            outR1 = palR(c): outG1 = palG(c): outB1 = palB(c)
                        Else
                            outR1 = 0: outG1 = 0: outB1 = 0
                        End If
                        dr = CLng(testR0) - outR0: dg = CLng(testG0) - outG0: db = CLng(testB0) - outB0
                        dist = dr * dr + dg * dg + db * db
                        dr = CLng(testR1) - outR1: dg = CLng(testG1) - outG1: db = CLng(testB1) - outB1
                        dist = dist + dr * dr + dg * dg + db * db
                        If CoCo1ArtifactMode = 1 And mask = 3 And x + 2 < FrameW Then
                            avgR = (CLng(testR0) + CLng(testR1) + CLng(testR2)) \ 3
                            avgG = (CLng(testG0) + CLng(testG1) + CLng(testG2)) \ 3
                            avgB = (CLng(testB0) + CLng(testB1) + CLng(testB2)) \ 3
                            dr = avgR - palR(c): dg = avgG - palG(c): db = avgB - palB(c)
                            dist = (dist \ 2) + 2 * (dr * dr + dg * dg + db * db)
                        End If
                        If dist < bestDist Then
                            bestDist = dist
                            bestColor = c
                            bestMask = mask
                        End If
NextSG24Mask:
                    Next mask
                End If
            Next c

            If DitherType = 1 Then
                If (bestMask And 1) <> 0 Then
                    outR0 = palR(bestColor): outG0 = palG(bestColor): outB0 = palB(bestColor)
                Else
                    outR0 = 0: outG0 = 0: outB0 = 0
                End If
                If (bestMask And 2) <> 0 Then
                    outR1 = palR(bestColor): outG1 = palG(bestColor): outB1 = palB(bestColor)
                Else
                    outR1 = 0: outG1 = 0: outB1 = 0
                End If

                er = testR0 - outR0: eg = testG0 - outG0: eb = testB0 - outB0
                If x < FrameW - 1 Then
                    errR(x + 1, y) = errR(x + 1, y) + er * 7! / 16!
                    errG(x + 1, y) = errG(x + 1, y) + eg * 7! / 16!
                    errB(x + 1, y) = errB(x + 1, y) + eb * 7! / 16!
                End If
                If y < FrameH - 1 Then
                    If x > 0 Then
                        errR(x - 1, y + 1) = errR(x - 1, y + 1) + er * 3! / 16!
                        errG(x - 1, y + 1) = errG(x - 1, y + 1) + eg * 3! / 16!
                        errB(x - 1, y + 1) = errB(x - 1, y + 1) + eb * 3! / 16!
                    End If
                    errR(x, y + 1) = errR(x, y + 1) + er * 5! / 16!
                    errG(x, y + 1) = errG(x, y + 1) + eg * 5! / 16!
                    errB(x, y + 1) = errB(x, y + 1) + eb * 5! / 16!
                    If x < FrameW - 1 Then
                        errR(x + 1, y + 1) = errR(x + 1, y + 1) + er * 1! / 16!
                        errG(x + 1, y + 1) = errG(x + 1, y + 1) + eg * 1! / 16!
                        errB(x + 1, y + 1) = errB(x + 1, y + 1) + eb * 1! / 16!
                    End If
                End If

                If x + 1 < FrameW Then
                    er = testR1 - outR1: eg = testG1 - outG1: eb = testB1 - outB1
                    If x + 2 < FrameW Then
                        errR(x + 2, y) = errR(x + 2, y) + er * 7! / 16!
                        errG(x + 2, y) = errG(x + 2, y) + eg * 7! / 16!
                        errB(x + 2, y) = errB(x + 2, y) + eb * 7! / 16!
                    End If
                    If y < FrameH - 1 Then
                        errR(x, y + 1) = errR(x, y + 1) + er * 3! / 16!
                        errG(x, y + 1) = errG(x, y + 1) + eg * 3! / 16!
                        errB(x, y + 1) = errB(x, y + 1) + eb * 3! / 16!
                        errR(x + 1, y + 1) = errR(x + 1, y + 1) + er * 5! / 16!
                        errG(x + 1, y + 1) = errG(x + 1, y + 1) + eg * 5! / 16!
                        errB(x + 1, y + 1) = errB(x + 1, y + 1) + eb * 5! / 16!
                        If x + 2 < FrameW Then
                            errR(x + 2, y + 1) = errR(x + 2, y + 1) + er * 1! / 16!
                            errG(x + 2, y + 1) = errG(x + 2, y + 1) + eg * 1! / 16!
                            errB(x + 2, y + 1) = errB(x + 2, y + 1) + eb * 1! / 16!
                        End If
                    End If
                End If
            End If

            lowNibble = 0
            If (bestMask And 1) <> 0 Then lowNibble = lowNibble Or &H0A
            If (bestMask And 2) <> 0 Then lowNibble = lowNibble Or &H05
            If bestColor = 0 Then
                frameVideo(p) = &H80
            Else
                frameVideo(p) = (&H80 + (bestColor - 1) * &H10) Or lowNibble
            End If
            p = p + 1
        Next x
    Next y

    While p <= UBound(frameVideo)
        frameVideo(p) = &H80
        p = p + 1
    Wend
End Sub

Sub ConvertFrameToCoCo1GMode15 (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
    Dim x As Integer, y As Integer
    Dim p As Long
    Dim q0 As Integer, q1 As Integer, q2 As Integer, q3 As Integer
    Dim palR(0 To 3) As Integer, palG(0 To 3) As Integer, palB(0 To 3) As Integer
    Dim testR As Single, testG As Single, testB As Single
    Dim errR As Single, errG As Single, errB As Single
    Dim er As Single, eg As Single, eb As Single
    Dim dr As Long, dg As Long, db As Long
    Dim best As Integer, check As Integer, bestDist As Long, dist As Long
    Dim threshold As Integer
    Dim lum As Integer

    If CoCo1ArtifactMode = 0 Then
        ' PMODE 3 / GMODE 15 colour set 0: green, yellow, blue, red.
        palR(0) = 0: palG(0) = 255: palB(0) = 0
        palR(1) = 255: palG(1) = 255: palB(1) = 0
        palR(2) = 0: palG(2) = 0: palB(2) = 255
        palR(3) = 255: palG(3) = 0: palB(3) = 0
    Else
        ' PMODE 3 / GMODE 15 colour set 1: buff, cyan, magenta, orange.
        palR(0) = 255: palG(0) = 245: palB(0) = 200
        palR(1) = 0: palG(1) = 255: palB(1) = 255
        palR(2) = 255: palG(2) = 0: palB(2) = 255
        palR(3) = 255: palG(3) = 128: palB(3) = 0
    End If

    For check = 0 To 3
        framePalette(check) = check
    Next check
    For check = 4 To 15
        framePalette(check) = 0
    Next check

    If DitherType = 1 Then
        ReDim errR(0 To FrameW + 1, 0 To FrameH + 1) As Single
        ReDim errG(0 To FrameW + 1, 0 To FrameH + 1) As Single
        ReDim errB(0 To FrameW + 1, 0 To FrameH + 1) As Single
    ElseIf DitherType = 2 Then
        Randomize 1
    End If

    For y = 0 To FrameH - 1
        For x = 0 To FrameW - 1
            testR = pixelR(x, y)
            testG = pixelG(x, y)
            testB = pixelB(x, y)

            If DitherType = 1 Then
                testR = testR + errR(x, y)
                testG = testG + errG(x, y)
                testB = testB + errB(x, y)
            ElseIf DitherType = 2 Then
                testR = testR + Int(Rnd * 65) - 32
                testG = testG + Int(Rnd * 65) - 32
                testB = testB + Int(Rnd * 65) - 32
            ElseIf DitherType = 3 Then
                threshold = (OrderedArray(x And 7, y And 7) - 128) \ 3
                testR = testR + threshold
                testG = testG + threshold
                testB = testB + threshold
            End If

            If testR < 0 Then testR = 0
            If testR > 255 Then testR = 255
            If testG < 0 Then testG = 0
            If testG > 255 Then testG = 255
            If testB < 0 Then testB = 0
            If testB > 255 Then testB = 255

            lum = (77 * CInt(testR) + 150 * CInt(testG) + 29 * CInt(testB)) \ 256
            If CoCo1ArtifactMode = 0 And lum < 64 Then
                best = 2
            ElseIf CoCo1ArtifactMode = 0 And lum > 192 Then
                best = 1
            Else
                best = 0
                bestDist = 2147483647
                For check = 0 To 3
                    dr = CLng(testR) - palR(check)
                    dg = CLng(testG) - palG(check)
                    db = CLng(testB) - palB(check)
                    dist = dr * dr + dg * dg + db * db
                    If dist < bestDist Then
                        bestDist = dist
                        best = check
                    End If
                Next check
            End If
            DitherOut(x, y) = best

            If DitherType = 1 Then
                er = testR - palR(best)
                eg = testG - palG(best)
                eb = testB - palB(best)
                If x < FrameW - 1 Then
                    errR(x + 1, y) = errR(x + 1, y) + er * 7! / 16!
                    errG(x + 1, y) = errG(x + 1, y) + eg * 7! / 16!
                    errB(x + 1, y) = errB(x + 1, y) + eb * 7! / 16!
                End If
                If y < FrameH - 1 Then
                    If x > 0 Then
                        errR(x - 1, y + 1) = errR(x - 1, y + 1) + er * 3! / 16!
                        errG(x - 1, y + 1) = errG(x - 1, y + 1) + eg * 3! / 16!
                        errB(x - 1, y + 1) = errB(x - 1, y + 1) + eb * 3! / 16!
                    End If
                    errR(x, y + 1) = errR(x, y + 1) + er * 5! / 16!
                    errG(x, y + 1) = errG(x, y + 1) + eg * 5! / 16!
                    errB(x, y + 1) = errB(x, y + 1) + eb * 5! / 16!
                    If x < FrameW - 1 Then
                        errR(x + 1, y + 1) = errR(x + 1, y + 1) + er * 1! / 16!
                        errG(x + 1, y + 1) = errG(x + 1, y + 1) + eg * 1! / 16!
                        errB(x + 1, y + 1) = errB(x + 1, y + 1) + eb * 1! / 16!
                    End If
                End If
            End If
        Next x
    Next y

    p = 0
    For y = 0 To FrameH - 1
        For x = 0 To FrameW - 1 Step 4
            q0 = DitherOut(x, y) And 3
            If x + 1 < FrameW Then q1 = DitherOut(x + 1, y) And 3 Else q1 = 0
            If x + 2 < FrameW Then q2 = DitherOut(x + 2, y) And 3 Else q2 = 0
            If x + 3 < FrameW Then q3 = DitherOut(x + 3, y) And 3 Else q3 = 0
            frameVideo(p) = (q0 * 64) Or (q1 * 16) Or (q2 * 4) Or q3
            p = p + 1
        Next x
    Next y

    While p <= UBound(frameVideo)
        frameVideo(p) = 0
        p = p + 1
    Wend
End Sub

Sub ConvertFrameToGMode151Grey (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
    Dim x As Integer, y As Integer
    Dim p As Long
    Dim grey As Integer
    Dim q0 As Integer, q1 As Integer, q2 As Integer, q3 As Integer
    Dim levels(0 To 3) As Integer
    Dim errGrey As Single
    Dim thisGrey As Single
    Dim quantGrey As Integer
    Dim e As Single
    Dim threshold As Integer

    framePalette(0) = &H00
    framePalette(1) = &H07
    framePalette(2) = &H38
    framePalette(3) = &H3F
    For x = 4 To 15
        framePalette(x) = 0
    Next x

    levels(0) = 0
    levels(1) = 85
    levels(2) = 170
    levels(3) = 255
    p = 0

    Select Case DitherType
        Case 1
            ReDim errGrey(0 To FrameW + 1, 0 To FrameH + 1) As Single
            For y = 0 To FrameH - 1
                For x = 0 To FrameW - 1
                    grey = (77 * pixelR(x, y) + 150 * pixelG(x, y) + 29 * pixelB(x, y)) \ 256
                    thisGrey = grey + errGrey(x, y)
                    If thisGrey < 0 Then thisGrey = 0
                    If thisGrey > 255 Then thisGrey = 255
                    DitherOut(x, y) = QuantizeGrey2Bit(thisGrey)
                    quantGrey = levels(DitherOut(x, y))
                    e = thisGrey - quantGrey
                    If x < FrameW - 1 Then errGrey(x + 1, y) = errGrey(x + 1, y) + e * 7! / 16!
                    If y < FrameH - 1 Then
                        If x > 0 Then errGrey(x - 1, y + 1) = errGrey(x - 1, y + 1) + e * 3! / 16!
                        errGrey(x, y + 1) = errGrey(x, y + 1) + e * 5! / 16!
                        If x < FrameW - 1 Then errGrey(x + 1, y + 1) = errGrey(x + 1, y + 1) + e * 1! / 16!
                    End If
                Next x
            Next y
        Case 2
            Randomize 1
            For y = 0 To FrameH - 1
                For x = 0 To FrameW - 1
                    grey = (77 * pixelR(x, y) + 150 * pixelG(x, y) + 29 * pixelB(x, y)) \ 256
                    grey = grey + Int(Rnd * 65) - 32
                    If grey < 0 Then grey = 0
                    If grey > 255 Then grey = 255
                    DitherOut(x, y) = QuantizeGrey2Bit(grey)
                Next x
            Next y
        Case 3
            For y = 0 To FrameH - 1
                For x = 0 To FrameW - 1
                    grey = (77 * pixelR(x, y) + 150 * pixelG(x, y) + 29 * pixelB(x, y)) \ 256
                    threshold = OrderedArray(x And 7, y And 7) - 128
                    grey = grey + (threshold \ 4)
                    If grey < 0 Then grey = 0
                    If grey > 255 Then grey = 255
                    DitherOut(x, y) = QuantizeGrey2Bit(grey)
                Next x
            Next y
        Case Else
            For y = 0 To FrameH - 1
                For x = 0 To FrameW - 1
                    grey = (77 * pixelR(x, y) + 150 * pixelG(x, y) + 29 * pixelB(x, y)) \ 256
                    DitherOut(x, y) = QuantizeGrey2Bit(grey)
                Next x
            Next y
    End Select

    For y = 0 To FrameH - 1
        For x = 0 To FrameW - 1 Step 4
            q0 = DitherOut(x, y) And 3
            If x + 1 < FrameW Then q1 = DitherOut(x + 1, y) And 3 Else q1 = 0
            If x + 2 < FrameW Then q2 = DitherOut(x + 2, y) And 3 Else q2 = 0
            If x + 3 < FrameW Then q3 = DitherOut(x + 3, y) And 3 Else q3 = 0
            frameVideo(p) = (q0 * 64) Or (q1 * 16) Or (q2 * 4) Or q3
            p = p + 1
        Next x
    Next y

    While p <= UBound(frameVideo)
        frameVideo(p) = 0
        p = p + 1
    Wend
End Sub

Sub PackFrameTo4Bit (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
    Dim p As Long
    Dim x As Integer, y As Integer
    Dim leftSlot As Integer, rightSlot As Integer
    Dim rr As Integer, gg As Integer, bb As Integer
    Dim t As Integer, noise As Integer
    Dim errR As Single, errG As Single, errB As Single
    Dim thisR As Single, thisG As Single, thisB As Single
    Dim er As Single, eg As Single, eb As Single
    Dim lum As Single, lumErr As Single, darkMix As Single
    Dim darkThresh As Integer, channelThresh As Integer
    Dim srcR As Integer, srcG As Integer, srcB As Integer
    Dim srcMax As Integer, srcMin As Integer, srcSat As Integer
    Dim lowSatThresh As Integer, neutralOnly As Integer
    Dim testSlot As Integer, testDist As Long, bestDist As Long

    p = 0

    If DitherType = 1 Then
        darkThresh = 52
        channelThresh = 64
        lowSatThresh = 26

        ReDim errR(0 To FrameW + 1, 0 To FrameH + 1) As Single
        ReDim errG(0 To FrameW + 1, 0 To FrameH + 1) As Single
        ReDim errB(0 To FrameW + 1, 0 To FrameH + 1) As Single

        For y = 0 To FrameH - 1
            For x = 0 To FrameW - 1 Step 2
                srcR = pixelR(x, y)
                srcG = pixelG(x, y)
                srcB = pixelB(x, y)
                srcMax = srcR: If srcG > srcMax Then srcMax = srcG
                If srcB > srcMax Then srcMax = srcB
                srcMin = srcR: If srcG < srcMin Then srcMin = srcG
                If srcB < srcMin Then srcMin = srcB
                srcSat = srcMax - srcMin

                thisR = srcR + errR(x, y)
                thisG = srcG + errG(x, y)
                thisB = srcB + errB(x, y)

                neutralOnly = 0
                If ShadowLumaGreyMode <> 0 Then
                    lum = (srcR * 77! + srcG * 150! + srcB * 29!) / 256!
                    If lum <= darkThresh And srcMax <= channelThresh And srcSat <= lowSatThresh Then neutralOnly = 1
                End If

                If neutralOnly Then
                    bestDist = 2147483647
                    leftSlot = 0
                    For testSlot = 0 To 3
                        testDist = (ClampByte(thisR) - CoCo64RGB(framePalette(testSlot), 0)) ^ 2 + (ClampByte(thisG) - CoCo64RGB(framePalette(testSlot), 1)) ^ 2 + (ClampByte(thisB) - CoCo64RGB(framePalette(testSlot), 2)) ^ 2
                        If testDist < bestDist Then
                            bestDist = testDist
                            leftSlot = testSlot
                        End If
                    Next testSlot
                Else
                    leftSlot = FindClosestPaletteSlotRGB(ClampByte(thisR), ClampByte(thisG), ClampByte(thisB), framePalette())
                End If

                er = thisR - CoCo64RGB(framePalette(leftSlot), 0)
                eg = thisG - CoCo64RGB(framePalette(leftSlot), 1)
                eb = thisB - CoCo64RGB(framePalette(leftSlot), 2)

                If ShadowLumaGreyMode <> 0 Then
                    If neutralOnly Then
                        lumErr = (er * 77! + eg * 150! + eb * 29!) / 256!
                        er = lumErr
                        eg = lumErr
                        eb = lumErr
                    Else
                        lum = (thisR * 77! + thisG * 150! + thisB * 29!) / 256!
                        If lum <= darkThresh And thisR <= channelThresh And thisG <= channelThresh And thisB <= channelThresh And srcSat <= lowSatThresh * 2 Then
                            lumErr = (er * 77! + eg * 150! + eb * 29!) / 256!
                            darkMix = (darkThresh - lum) / darkThresh
                            If darkMix < 0! Then darkMix = 0!
                            If darkMix > 1! Then darkMix = 1!
                            darkMix = darkMix * ((lowSatThresh * 2 - srcSat) / (lowSatThresh * 2))
                            If darkMix < 0! Then darkMix = 0!
                            If darkMix > 1! Then darkMix = 1!
                            er = er * (1! - darkMix) + lumErr * darkMix
                            eg = eg * (1! - darkMix) + lumErr * darkMix
                            eb = eb * (1! - darkMix) + lumErr * darkMix
                        End If
                    End If
                End If

                errR(x + 1, y) = errR(x + 1, y) + er * 7 / 16
                errG(x + 1, y) = errG(x + 1, y) + eg * 7 / 16
                errB(x + 1, y) = errB(x + 1, y) + eb * 7 / 16
                errR(x, y + 1) = errR(x, y + 1) + er * 5 / 16
                errG(x, y + 1) = errG(x, y + 1) + eg * 5 / 16
                errB(x, y + 1) = errB(x, y + 1) + eb * 5 / 16
                If x > 0 Then
                    errR(x - 1, y + 1) = errR(x - 1, y + 1) + er * 3 / 16
                    errG(x - 1, y + 1) = errG(x - 1, y + 1) + eg * 3 / 16
                    errB(x - 1, y + 1) = errB(x - 1, y + 1) + eb * 3 / 16
                End If
                errR(x + 1, y + 1) = errR(x + 1, y + 1) + er * 1 / 16
                errG(x + 1, y + 1) = errG(x + 1, y + 1) + eg * 1 / 16
                errB(x + 1, y + 1) = errB(x + 1, y + 1) + eb * 1 / 16

                If x + 1 < FrameW Then
                    srcR = pixelR(x + 1, y)
                    srcG = pixelG(x + 1, y)
                    srcB = pixelB(x + 1, y)
                    srcMax = srcR: If srcG > srcMax Then srcMax = srcG
                    If srcB > srcMax Then srcMax = srcB
                    srcMin = srcR: If srcG < srcMin Then srcMin = srcG
                    If srcB < srcMin Then srcMin = srcB
                    srcSat = srcMax - srcMin

                    thisR = srcR + errR(x + 1, y)
                    thisG = srcG + errG(x + 1, y)
                    thisB = srcB + errB(x + 1, y)

                    neutralOnly = 0
                    If ShadowLumaGreyMode <> 0 Then
                        lum = (srcR * 77! + srcG * 150! + srcB * 29!) / 256!
                        If lum <= darkThresh And srcMax <= channelThresh And srcSat <= lowSatThresh Then neutralOnly = 1
                    End If

                    If neutralOnly Then
                        bestDist = 2147483647
                        rightSlot = 0
                        For testSlot = 0 To 3
                            testDist = (ClampByte(thisR) - CoCo64RGB(framePalette(testSlot), 0)) ^ 2 + (ClampByte(thisG) - CoCo64RGB(framePalette(testSlot), 1)) ^ 2 + (ClampByte(thisB) - CoCo64RGB(framePalette(testSlot), 2)) ^ 2
                            If testDist < bestDist Then
                                bestDist = testDist
                                rightSlot = testSlot
                            End If
                        Next testSlot
                    Else
                        rightSlot = FindClosestPaletteSlotRGB(ClampByte(thisR), ClampByte(thisG), ClampByte(thisB), framePalette())
                    End If

                    er = thisR - CoCo64RGB(framePalette(rightSlot), 0)
                    eg = thisG - CoCo64RGB(framePalette(rightSlot), 1)
                    eb = thisB - CoCo64RGB(framePalette(rightSlot), 2)

                    If ShadowLumaGreyMode <> 0 Then
                        If neutralOnly Then
                            lumErr = (er * 77! + eg * 150! + eb * 29!) / 256!
                            er = lumErr
                            eg = lumErr
                            eb = lumErr
                        Else
                            lum = (thisR * 77! + thisG * 150! + thisB * 29!) / 256!
                            If lum <= darkThresh And thisR <= channelThresh And thisG <= channelThresh And thisB <= channelThresh And srcSat <= lowSatThresh * 2 Then
                                lumErr = (er * 77! + eg * 150! + eb * 29!) / 256!
                                darkMix = (darkThresh - lum) / darkThresh
                                If darkMix < 0! Then darkMix = 0!
                                If darkMix > 1! Then darkMix = 1!
                                darkMix = darkMix * ((lowSatThresh * 2 - srcSat) / (lowSatThresh * 2))
                                If darkMix < 0! Then darkMix = 0!
                                If darkMix > 1! Then darkMix = 1!
                                er = er * (1! - darkMix) + lumErr * darkMix
                                eg = eg * (1! - darkMix) + lumErr * darkMix
                                eb = eb * (1! - darkMix) + lumErr * darkMix
                            End If
                        End If
                    End If

                    errR(x + 2, y) = errR(x + 2, y) + er * 7 / 16
                    errG(x + 2, y) = errG(x + 2, y) + eg * 7 / 16
                    errB(x + 2, y) = errB(x + 2, y) + eb * 7 / 16
                    errR(x + 1, y + 1) = errR(x + 1, y + 1) + er * 5 / 16
                    errG(x + 1, y + 1) = errG(x + 1, y + 1) + eg * 5 / 16
                    errB(x + 1, y + 1) = errB(x + 1, y + 1) + eb * 5 / 16
                    errR(x + 2, y + 1) = errR(x + 2, y + 1) + er * 1 / 16
                    errG(x + 2, y + 1) = errG(x + 2, y + 1) + eg * 1 / 16
                    errB(x + 2, y + 1) = errB(x + 2, y + 1) + eb * 1 / 16
                    errR(x, y + 1) = errR(x, y + 1) + er * 3 / 16
                    errG(x, y + 1) = errG(x, y + 1) + eg * 3 / 16
                    errB(x, y + 1) = errB(x, y + 1) + eb * 3 / 16
                Else
                    rightSlot = 0
                End If

                frameVideo(p) = leftSlot * 16 + rightSlot
                p = p + 1
            Next x
        Next y
    Else
        For y = 0 To FrameH - 1
            For x = 0 To FrameW - 1 Step 2
                rr = pixelR(x, y)
                gg = pixelG(x, y)
                bb = pixelB(x, y)

                If DitherType = 2 Then
                    noise = ((x * 13 + y * 17) And 15) - 8
                    rr = ClampByte(rr + noise)
                    gg = ClampByte(gg + noise)
                    bb = ClampByte(bb + noise)
                ElseIf DitherType = 3 Then
                    t = OrderedArray(x And 7, y And 7) \ 16 - 8
                    rr = ClampByte(rr + t)
                    gg = ClampByte(gg + t)
                    bb = ClampByte(bb + t)
                End If

                leftSlot = FindClosestPaletteSlotRGB(rr, gg, bb, framePalette())

                If x + 1 < FrameW Then
                    rr = pixelR(x + 1, y)
                    gg = pixelG(x + 1, y)
                    bb = pixelB(x + 1, y)
                    If DitherType = 2 Then
                        noise = (((x + 1) * 13 + y * 17) And 15) - 8
                        rr = ClampByte(rr + noise)
                        gg = ClampByte(gg + noise)
                        bb = ClampByte(bb + noise)
                    ElseIf DitherType = 3 Then
                        t = OrderedArray((x + 1) And 7, y And 7) \ 16 - 8
                        rr = ClampByte(rr + t)
                        gg = ClampByte(gg + t)
                        bb = ClampByte(bb + t)
                    End If
                    rightSlot = FindClosestPaletteSlotRGB(rr, gg, bb, framePalette())
                Else
                    rightSlot = 0
                End If

                frameVideo(p) = leftSlot * 16 + rightSlot
                p = p + 1
            Next x
        Next y
    End If

    While p <= UBound(frameVideo)
        frameVideo(p) = 0
        p = p + 1
    Wend
End Sub

Sub BuildMuxedFrame (frameVideo() As _Unsigned _Byte, muxedFrame() As _Unsigned _Byte)
    Dim outPos As Long
    Dim startPos As Long
    Dim ii2 As Integer
    Dim ii3 As Integer
    Dim audioPosInFrame As Integer
    Dim audioSample As Long
    Dim audioEnd As Long
    Dim groupLast As Long
    Dim a As _Unsigned _Byte
    Dim frameAudio As _Unsigned _Byte

    If CoCo1VideoOnly Then
        ReDim frameAudio(0 To AudSectors * BYTES_PER_SECTOR - 1) As _Unsigned _Byte
        For ii2 = 0 To UBound(frameAudio)
            If AudioFH <> 0 And audioPos <= audioLen Then
                Get #AudioFH, audioPos, a
                audioPos = audioPos + 1
            Else
                a = 128
            End If
            frameAudio(ii2) = a
        Next ii2

        outPos = 0
        ' The CoCo 1 player now starts the audio-buffer load with:
        '   LDD <$4A / STA <$20 / LDY #AudioBufferEnd+1 / STB -1,Y
        ' The first LDD must therefore read audio byte 0 into A and byte 1
        ' into B.  The following bytes are written with PSHS in normal
        ' stack-blast order, and the final two bytes match the final
        ' LDD <$4A / PSHS D at the end of the audio-buffer fill.
        audioEnd = AudSectors * BYTES_PER_SECTOR - 1
        muxedFrame(outPos) = frameAudio(0): outPos = outPos + 1
        muxedFrame(outPos) = frameAudio(1): outPos = outPos + 1

        audioSample = 2
        Do While audioSample <= audioEnd - 2
            groupLast = audioSample + 5
            For ii3 = groupLast To audioSample Step -1
                muxedFrame(outPos) = frameAudio(ii3)
                outPos = outPos + 1
            Next ii3
            audioSample = groupLast + 1
        Loop

        muxedFrame(outPos) = frameAudio(audioEnd): outPos = outPos + 1
        muxedFrame(outPos) = frameAudio(audioEnd - 1): outPos = outPos + 1

        startPos = VidSectors * BYTES_PER_SECTOR - 1
        For ii2 = 1 To VidSectors
            For ii3 = 1 To 12 * 7 + 1
                muxedFrame(outPos) = frameVideo(startPos - 5): outPos = outPos + 1
                muxedFrame(outPos) = frameVideo(startPos - 4): outPos = outPos + 1
                muxedFrame(outPos) = frameVideo(startPos - 3): outPos = outPos + 1
                muxedFrame(outPos) = frameVideo(startPos - 2): outPos = outPos + 1
                muxedFrame(outPos) = frameVideo(startPos - 1): outPos = outPos + 1
                muxedFrame(outPos) = frameVideo(startPos): outPos = outPos + 1
                startPos = startPos - 6
            Next ii3
            muxedFrame(outPos) = frameVideo(startPos - 1): outPos = outPos + 1
            muxedFrame(outPos) = frameVideo(startPos): outPos = outPos + 1
            startPos = startPos - 2
        Next ii2
        While outPos <= UBound(muxedFrame)
            muxedFrame(outPos) = 0
            outPos = outPos + 1
        Wend
        Exit Sub
    End If

    If AudSectors = 0 Then
        outPos = 0
        startPos = VidSectors * BYTES_PER_SECTOR - 1
        For ii2 = 1 To VidSectors
            For ii3 = 1 To 12 * 7 + 1
                muxedFrame(outPos) = frameVideo(startPos - 5): outPos = outPos + 1
                muxedFrame(outPos) = frameVideo(startPos - 4): outPos = outPos + 1
                muxedFrame(outPos) = frameVideo(startPos - 3): outPos = outPos + 1
                muxedFrame(outPos) = frameVideo(startPos - 2): outPos = outPos + 1
                muxedFrame(outPos) = frameVideo(startPos - 1): outPos = outPos + 1
                muxedFrame(outPos) = frameVideo(startPos): outPos = outPos + 1
                startPos = startPos - 6
            Next ii3
            muxedFrame(outPos) = frameVideo(startPos - 1): outPos = outPos + 1
            muxedFrame(outPos) = frameVideo(startPos): outPos = outPos + 1
            startPos = startPos - 2
        Next ii2
        Exit Sub
    End If

    ReDim frameAudio(0 To AudSectors * BYTES_PER_SECTOR - 1) As _Unsigned _Byte

    outPos = 0
    For ii2 = 0 To UBound(frameAudio)
        If audioPos <= audioLen Then
            Get #AudioFH, audioPos, a
            audioPos = audioPos + 1
        Else
            a = 128
        End If
        frameAudio(ii2) = a
    Next ii2

    startPos = UBound(frameAudio)
    For ii2 = 1 To AudSectors
        For ii3 = 1 To 12 * 7 + 1
            muxedFrame(outPos) = frameAudio(startPos - 5): outPos = outPos + 1
            muxedFrame(outPos) = frameAudio(startPos - 4): outPos = outPos + 1
            muxedFrame(outPos) = frameAudio(startPos - 3): outPos = outPos + 1
            muxedFrame(outPos) = frameAudio(startPos - 2): outPos = outPos + 1
            muxedFrame(outPos) = frameAudio(startPos - 1): outPos = outPos + 1
            muxedFrame(outPos) = frameAudio(startPos): outPos = outPos + 1
            startPos = startPos - 6
        Next ii3
        muxedFrame(outPos) = frameAudio(startPos - 1): outPos = outPos + 1
        muxedFrame(outPos) = frameAudio(startPos): outPos = outPos + 1
        startPos = startPos - 2
    Next ii2

    startPos = VidSectors * BYTES_PER_SECTOR - 1
    For ii2 = 1 To VidSectors
        For ii3 = 1 To 12 * 7 + 1
            muxedFrame(outPos) = frameVideo(startPos - 5): outPos = outPos + 1
            muxedFrame(outPos) = frameVideo(startPos - 4): outPos = outPos + 1
            muxedFrame(outPos) = frameVideo(startPos - 3): outPos = outPos + 1
            muxedFrame(outPos) = frameVideo(startPos - 2): outPos = outPos + 1
            muxedFrame(outPos) = frameVideo(startPos - 1): outPos = outPos + 1
            muxedFrame(outPos) = frameVideo(startPos): outPos = outPos + 1
            startPos = startPos - 6
        Next ii3
        muxedFrame(outPos) = frameVideo(startPos - 1): outPos = outPos + 1
        muxedFrame(outPos) = frameVideo(startPos): outPos = outPos + 1
        startPos = startPos - 2
    Next ii2
End Sub

Function ExpandFramePattern$ (pat$, index As Long)
    Dim pct As Integer
    Dim i As Integer
    Dim digits$
    Dim width As Integer
    Dim num$

    pct = InStr(pat$, "%")
    If pct = 0 Then
        ExpandFramePattern$ = pat$
        Exit Function
    End If

    i = pct + 1
    digits$ = ""
    Do While i <= Len(pat$)
        If Mid$(pat$, i, 1) >= "0" And Mid$(pat$, i, 1) <= "9" Then
            digits$ = digits$ + Mid$(pat$, i, 1)
            i = i + 1
        Else
            Exit Do
        End If
    Loop

    If i > Len(pat$) Then
        ExpandFramePattern$ = pat$
        Exit Function
    End If
    If Mid$(pat$, i, 1) <> "d" And Mid$(pat$, i, 1) <> "D" Then
        ExpandFramePattern$ = pat$
        Exit Function
    End If

    If digits$ = "" Then
        width = 0
    Else
        width = Val(digits$)
    End If

    num$ = LTrim$(Str$(index))
    If width > 0 Then num$ = Right$(String$(width, "0") + num$, width)
    ExpandFramePattern$ = Left$(pat$, pct - 1) + num$ + Mid$(pat$, i + 1)
End Function

Sub InitOrderedDither
    Dim x As Integer, y As Integer

    ' 2x2 ordered dither values copied from your original
    Restore OrderedDitherData
    For y = 0 To 7
        For x = 0 To 7
            Read OrderedArray(x, y)
            OrderedArray(x, y) = Int((OrderedArray(x, y) * 255) / 63)
        Next x
    Next y
End Sub


Sub InitPaletteData
    Dim x As Integer

    Restore RawPaletteData
    For x = 0 To 255
        Read ColoursReal(x, 0), ColoursReal(x, 1), ColoursReal(x, 2)
    Next x

    Restore ScaledPaletteData
    For x = 0 To 255
        Read ColoursMatch(x, 0), ColoursMatch(x, 1), ColoursMatch(x, 2)
    Next x
End Sub


' ============================================================================
' Reused colour-match and dithering logic
' ============================================================================

Sub BuildPaletteFromDither (framePalette() As _Unsigned _Byte)
    Dim counts(0 To 255) As Long
    Dim used(0 To 255) As Integer
    Dim x As Integer, y As Integer
    Dim idx As Integer
    Dim slot As Integer
    Dim bestCount As Long
    Dim bestIdx As Integer

    For y = 0 To imageHeight - 1
        For x = 0 To imageWidth - 1
            idx = DitherOut(x, y)
            counts(idx) = counts(idx) + 1
        Next x
    Next y

    For slot = 0 To 15
        bestCount = -1
        bestIdx = 0
        For idx = 0 To 255
            If used(idx) = 0 Then
                If counts(idx) > bestCount Then
                    bestCount = counts(idx)
                    bestIdx = idx
                End If
            End If
        Next idx

        If bestCount <= 0 Then
            bestIdx = InitPalette(slot)
        End If

        framePalette(slot) = bestIdx And 255
        used(bestIdx) = -1
    Next slot
End Sub


Sub FindClosestColorInFramePalette (srcIndex As Integer, framePalette() As _Unsigned _Byte, bestSlot As Integer)
    Dim slot As Integer
    Dim palIndex As Integer
    Dim dR As Integer, dG As Integer, dB As Integer
    Dim best As Long
    Dim dd As Long

    best = &H7FFFFFFF
    bestSlot = 0

    For slot = 0 To 15
        palIndex = framePalette(slot)
        dR = ColoursReal(srcIndex, 0) - ColoursReal(palIndex, 0)
        dG = ColoursReal(srcIndex, 1) - ColoursReal(palIndex, 1)
        dB = ColoursReal(srcIndex, 2) - ColoursReal(palIndex, 2)
        dd = CLng(dR) * dR + CLng(dG) * dG + CLng(dB) * dB
        If dd < best Then
            best = dd
            bestSlot = slot
        End If
    Next slot
End Sub


Sub RemapDitherToFramePalette (framePalette() As _Unsigned _Byte)
    Dim x As Integer, y As Integer
    Dim slot As Integer

    For y = 0 To imageHeight - 1
        For x = 0 To imageWidth - 1
            FindClosestColorInFramePalette DitherOut(x, y), framePalette(), slot
            DitherOut(x, y) = slot
        Next x
    Next y
End Sub


Sub DoFindClosestColor
    Dim srcY As Integer, srcU As Integer, srcV As Integer
    Dim srcSat As Integer
    Dim i As Integer
    Dim Ri As Integer, Gi As Integer, Bi As Integer
    Dim palY As Integer, palU As Integer, palV As Integer
    Dim dY As Integer, dU As Integer, dV As Integer
    Dim palSat As Integer

    srcY = (77 * R + 150 * G + 29 * B) \ 256
    srcU = B - srcY
    srcV = R - srcY

    bestDist = &H7FFFFFFF
    bestIndex = 0

    srcSat = Abs(R - G) + Abs(R - B) + Abs(G - B)

    For i = 0 To 255
        Ri = ColoursMatch(i, 0)
        Gi = ColoursMatch(i, 1)
        Bi = ColoursMatch(i, 2)

        palY = (77 * Ri + 150 * Gi + 29 * Bi) \ 256
        palU = Bi - palY
        palV = Ri - palY

        dY = srcY - palY
        dU = srcU - palU
        dV = srcV - palV

        dist = dY * dY * 4 + dU * dU * 2 + dV * dV * 2

        If srcSat < 24 Then
            palSat = Abs(Ri - Gi) + Abs(Ri - Bi) + Abs(Gi - Bi)
            dist = dist + palSat * 8
        End If

        If dist < bestDist Then
            bestDist = dist
            bestIndex = i
        End If
    Next i
End Sub


Sub Gosub_DoNoDither
    Dim x As Integer, y As Integer
    For y = 0 To imageHeight - 1
        For x = 0 To imageWidth - 1
            R = pixelR(x, y)
            G = pixelG(x, y)
            B = pixelB(x, y)
            DoFindClosestColor
            DitherOut(x, y) = bestIndex
        Next x
    Next y
End Sub


Sub Gosub_DoOrderDither
    Dim x As Integer, y As Integer
    Dim threshold As Integer
    For y = 0 To imageHeight - 1
        For x = 0 To imageWidth - 1
            R = pixelR(x, y)
            G = pixelG(x, y)
            B = pixelB(x, y)

            threshold = OrderedArray(x And 1, y And 1)

            R = R + threshold - 2
            G = G + threshold - 2
            B = B + threshold - 2

            If R < 0 Then R = 0 Else If R > 255 Then R = 255
            If G < 0 Then G = 0 Else If G > 255 Then G = 255
            If B < 0 Then B = 0 Else If B > 255 Then B = 255

            DoFindClosestColor
            DitherOut(x, y) = bestIndex
        Next x
    Next y
End Sub


Sub Gosub_DoFloydDither
    Dim errorR As Integer, errorG As Integer, errorB As Integer
    Dim x As Integer, y As Integer
    Dim chosenR As Integer, chosenG As Integer, chosenB As Integer
    Dim errR As Integer, errG As Integer, errB As Integer

    ReDim errorR(0 To imageWidth, 0 To imageHeight) As Integer
    ReDim errorG(0 To imageWidth, 0 To imageHeight) As Integer
    ReDim errorB(0 To imageWidth, 0 To imageHeight) As Integer

    For y = 0 To imageHeight - 1
        For x = 0 To imageWidth - 1
            R = pixelR(x, y) + errorR(x, y)
            G = pixelG(x, y) + errorG(x, y)
            B = pixelB(x, y) + errorB(x, y)

            If R < 0 Then R = 0 Else If R > 255 Then R = 255
            If G < 0 Then G = 0 Else If G > 255 Then G = 255
            If B < 0 Then B = 0 Else If B > 255 Then B = 255

            DoFindClosestColor
            DitherOut(x, y) = bestIndex

            chosenR = ColoursReal(bestIndex, 0)
            chosenG = ColoursReal(bestIndex, 1)
            chosenB = ColoursReal(bestIndex, 2)

            errR = R - chosenR
            errG = G - chosenG
            errB = B - chosenB

            If x < imageWidth - 1 Then
                errorR(x + 1, y) = errorR(x + 1, y) + errR * 7 / 16
                errorG(x + 1, y) = errorG(x + 1, y) + errG * 7 / 16
                errorB(x + 1, y) = errorB(x + 1, y) + errB * 7 / 16
            End If

            If y < imageHeight - 1 Then
                If x > 0 Then
                    errorR(x - 1, y + 1) = errorR(x - 1, y + 1) + errR * 3 / 16
                    errorG(x - 1, y + 1) = errorG(x - 1, y + 1) + errG * 3 / 16
                    errorB(x - 1, y + 1) = errorB(x - 1, y + 1) + errB * 3 / 16
                End If

                errorR(x, y + 1) = errorR(x, y + 1) + errR * 5 / 16
                errorG(x, y + 1) = errorG(x, y + 1) + errG * 5 / 16
                errorB(x, y + 1) = errorB(x, y + 1) + errB * 5 / 16

                If x < imageWidth - 1 Then
                    errorR(x + 1, y + 1) = errorR(x + 1, y + 1) + errR * 1 / 16
                    errorG(x + 1, y + 1) = errorG(x + 1, y + 1) + errG * 1 / 16
                    errorB(x + 1, y + 1) = errorB(x + 1, y + 1) + errB * 1 / 16
                End If
            End If
        Next x
    Next y
End Sub


Sub Gosub_DoBlueNoiseTexture
    Dim BlueNoise As _Unsigned Long
    Dim x As Integer, y As Integer
    Dim i As Integer
    Dim minNoise As Long, maxNoise As Long
    Dim dx As Integer, dy2 As Integer
    Dim swapChance As Single
    Dim noise As Single
    Dim Brightness As Integer
    Dim adjustedNoise As Single

    ReDim BlueNoise(0 To imageWidth - 1, 0 To imageHeight - 1) As _Unsigned Long

    For y = 0 To imageHeight - 1
        For x = 0 To imageWidth - 1
            BlueNoise(x, y) = Int(Rnd * 256)
        Next x
    Next y

    minNoise = 255
    maxNoise = 0
    For y = 0 To imageHeight - 1
        For x = 0 To imageWidth - 1
            If BlueNoise(x, y) < minNoise Then minNoise = BlueNoise(x, y)
            If BlueNoise(x, y) > maxNoise Then maxNoise = BlueNoise(x, y)
        Next x
    Next y

    For i = 1 To 100
        x = Int(Rnd * imageWidth)
        y = Int(Rnd * imageHeight)

        dx = Int(Rnd * 3) - 1
        dy2 = Int(Rnd * 3) - 1

        If x + dx >= 0 And x + dx < imageWidth And y + dy2 >= 0 And y + dy2 < imageHeight Then
            swapChance = Abs(BlueNoise(x, y) - 128) / 128
            If Rnd < swapChance Then Swap BlueNoise(x, y), BlueNoise(x + dx, y + dy2)
        End If
    Next i

    For y = 0 To imageHeight - 1
        For x = 0 To imageWidth - 1
            R = pixelR(x, y)
            G = pixelG(x, y)
            B = pixelB(x, y)

            noise = BlueNoise(x, y)
            noise = 2 * ((noise - minNoise) / (maxNoise - minNoise)) - 1

            Brightness = (R + G + B) \ 3
            adjustedNoise = noise * (10.0 + (Brightness / 255) * 10.0)

            If R > G And R > B Then
                R = R + adjustedNoise
            ElseIf G > R And G > B Then
                G = G + adjustedNoise
            Else
                B = B + adjustedNoise
            End If

            If R < 0 Then R = 0 Else If R > 255 Then R = 255
            If G < 0 Then G = 0 Else If G > 255 Then G = 255
            If B < 0 Then B = 0 Else If B > 255 Then B = 255

            DoFindClosestColor
            DitherOut(x, y) = bestIndex
        Next x
    Next y
End Sub


Sub ShowUsage
    Print
    Print "MakeNTM v"; VersionNumber$; " by Glen Hewlett"
    Print
    Print "Creates CoCo .NTM movie files from PNG frames and unsigned 8-bit audio."
    Print "Supports CoCo 1 GMODE 8/15/16 movies with audio-buffer stream playback."
    Print "It can also call ffprobe/ffmpeg directly to extract frames and audio from a movie source."
    Print
    Print "Usage:"
    Print "  MakeNTM [options] WxH AudioSectors FramePattern AudioFile OutputFile"
    Print "  MakeNTM -g8 [options] WxH FramePattern OutputFile"
    Print "  MakeNTM -g8 [options] WxH FramePattern AudioFile OutputFile"
    Print "  MakeNTM -g15 [options] WxH FramePattern OutputFile"
    Print "  MakeNTM -g15 [options] WxH FramePattern AudioFile OutputFile"
    Print "  MakeNTM -g16 [options] WxH FramePattern OutputFile"
    Print "  MakeNTM -g16 [options] WxH FramePattern AudioFile OutputFile"
    Print "  MakeNTM -i=input.mkv -o=movie.ntm -g136 -f12 -a2 [movie options]"
    Print "  MakeNTM -i=input.mkv -o=movie.ntm -g8 [movie options]"
    Print "  MakeNTM -i=input.mkv -o=movie.ntm -g15 [movie options]"
    Print "  MakeNTM -i=input.mkv -o=movie.ntm -g16 [movie options]"
    Print
    Print "PNG/audio input arguments:"
    Print "  WxH           Input frame size, for example 128x107 or 256x192"
    Print "                -g8 requires 64x192; -g15 requires 128x192;"
    Print "                -g16 requires 256x192"
    Print "                You may also use the multiplication symbol instead of x."
    Print "  AudioSectors  Number of 512-byte audio sectors per frame"
    Print "                Example: 2 gives FPS * 1024 audio bytes/second"
    Print "                -g8/-g15/-g16 ignore this and always use two audio sectors"
    Print "  FramePattern  PNG filename pattern such as frames/frame%06d.png"
    Print "  AudioFile     Raw unsigned 8-bit mono audio file, usually .u8"
    Print "                Optional for -g8/-g15/-g16; omitted audio is filled with silence"
    Print "  OutputFile    Output .NTM movie file to create"
    Print
    Print "Movie-source input arguments:"
    Print "  -i=file       Input movie file.  This switches to ffmpeg/ffprobe mode."
    Print "                In this mode, -i= is not the initial-palette option."
    Print "                Example: -i=tears_of_steel_720p.mov"
    Print "  -o=file       Output .NTM movie file"
    Print "                Example: -o=TEST16.NTM"
    Print "  -n=pattern    Optional extracted PNG frame pattern"
    Print "                Default: frames/frame%06d.png"
    Print "                Example: -n=tmp/frame%05d.png"
    Print
    Print "Common options:"
    Print "  -d#           Dither mode used by the frame converter"
    Print "                -d0 = none"
    Print "                -d1 = Floyd-Steinberg"
    Print "                -d2 = blue-noise style"
    Print "                -d3 = ordered"
    Print "                Example: -d1"
    Print
    Print "  -f# or -fps#  Frames per second written into the .NTM header"
    Print "                Also used to calculate extracted audio sample rate"
    Print "                -g8/-g15/-g16 always force 12 fps regardless of this value"
    Print "                Example: -f10"
    Print
    Print "  -g#           Graphics mode selection"
    Print "                -g8 selects CoCo 1 GMODE 8 / SG24, 64x192x9 stream"
    Print "                -g15 selects CoCo 1 GMODE 15, 128x192x4 audio-buffer stream"
    Print "                -g16 selects CoCo 1 GMODE 16, 256x192x2 audio-buffer stream"
    Print "                It writes 14-sector frames: two 512-byte audio buffers,"
    Print "                followed by twelve 512-byte stack-blasted video sectors."
    Print "                With -g15, -t# selects PMODE 3 colour set:"
    Print "                  -t0 = colour set 0, green/yellow/blue/red (default)"
    Print "                  -t1 = colour set 1, buff/cyan/magenta/orange"
    Print "                With -g16, -t# selects artifact conversion mode:"
    Print "                  -t0 = current 1-bit black/white conversion"
    Print "                  -t1 = solid black/white with two-pixel white pairs"
    Print "                  -t2 = black/red/blue/white artifact matching (default)"
    Print "                  -t3 = 2x2 CoCo artifact colour matching"
    Print "                If # is 100..165, the built-in mode table is used"
    Print "                Example: -g145 selects CoCo mode 145 = %00011110"
    Print "                If # is outside 100..165, it is used as the raw header byte"
    Print "                Example: -g30 writes %00011110 directly"
    Print "                Common table entries:"
    Print "                  -g118 = 128x192x16   byte 18   %00010010"
    Print "                  -g136 = 256x192x16   byte 26   %00011010"
    Print "                  -g145 = 320x192x16   byte 30   %00011110"
    Print "                  -g151 = 512x192x4    byte 25   %00011001"
    Print "                  -g164 = 640x200x4    byte 61   %00111101"
    Print
    Print "  -name=text    Movie title stored in the .NTM header"
    Print "                Also accepted as --name=text in movie-source mode"
    Print "                Example: -name=""GMODE 16 Test"""
    Print
    Print "Screen placement options:"
    Print "  -y#           Top row on screen where the video should start"
    Print "                If omitted, the movie is vertically centred on the screen"
    Print "                The program calculates the stack-blast start address for you"
    Print "                using the selected CoCo mode row size"
    Print "                Formula: $8000 + screen bytes/row * (start row + video height - 1)"
    Print "                Example: -y24"
    Print
    Print "  -maddr        Optional manual override for the stack-blast start address"
    Print "                Decimal, $hex, or &Hhex are accepted"
    Print "                This overrides -y# if both are supplied later on the command line"
    Print "                Example: -m$E000"
    Print
    Print "GMODE 8/15/16 options:"
    Print "  -t#           Colour/artifact conversion mode"
    Print "                For -g8:"
    Print "                  -t0 = SG24 pair colour matching (default)"
    Print "                  -t1 = SG24 3-pixel look-ahead matching"
    Print "                For -g15:"
    Print "                  -t0 = colour set 0, green/yellow/blue/red (default)"
    Print "                  -t1 = colour set 1, buff/cyan/magenta/orange"
    Print "                For -g16:"
    Print "                  -t0 = current 1-bit black/white conversion"
    Print "                  -t1 = solid black/white with two-pixel white pairs"
    Print "                  -t2 = black/red/blue/white artifact matching (default)"
    Print "                  -t3 = 2x2 CoCo artifact colour matching"
    Print "                Examples: -g8 -t1, -g15 -t0, -g16 -t2"
    Print
    Print "Audio and CoCo 3 palette options:"
    Print "  -a#           Audio sectors per frame in movie-source mode"
    Print "                In PNG/audio mode this is the positional AudioSectors argument"
    Print "                Ignored by -g8/-g15/-g16, which always use two audio sectors"
    Print "                Example: -a2"
    Print
    Print "  -p0           No per-frame palette sectors"
    Print "                Video is written using the non-palette path"
    Print "  -p1           Enable per-frame palette sectors"
    Print "                Ignored for -g151 grayscale mode and forced off for -g8/-g15/-g16"
    Print "                For CoCo 3 16-colour RGB modes this will:"
    Print "                  * reserve palette slot 0 for black ($00)"
    Print "                  * choose the best 15 remaining CoCo RGB colours"
    Print "                  * pack pixels as 2 pixels per byte"
    Print "                One 512-byte palette sector stores 32 frame palettes"
    Print
    Print "  -c0           Palette chooser method 0 (default)"
    Print "                Choose the 15 most frequent non-black colours"
    Print "  -c1           Palette chooser method 1"
    Print "                Choose 15 non-black colours using a frequency-weighted"
    Print "                diversity score so the palette spreads out more"
    Print "                Used with -p1 RGB 16-colour output"
    Print
    Print "  -l#           Shadow luma/grey Floyd mode for -p1 RGB 16-colour output"
    Print "                -l0 = off, use classic RGB Floyd in dark areas"
    Print "                -l1 = on, prefer luminance/grey handling in neutral shadows"
    Print "                Example: -l1"
    Print
    Print "  -i=v0,v1,...  Set the 16 initial palette bytes stored in the header"
    Print "                PNG/audio input mode only; -i=file means movie input"
    Print "                Supply exactly 16 values from 0 to 63"
    Print "                Example:"
    Print "                  -i=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15"
    Print
    Print "  -sp#=value    Force one initial palette slot value in the header"
    Print "                # must be 1..15, value is 0..63"
    Print "                Palette slot 0 is reserved for black"
    Print "                Example: -sp1=63"
    Print
    Print "Movie-source options:"
    Print "  -r=WxH        Force active movie size before padding/placement"
    Print "                Example: -r=256x144"
    Print
    Print "  -s=factor     Scale active movie size by factor 0 < factor <= 1"
    Print "                Example: -s=.75"
    Print
    Print "  -pillar       Pad movie-source output to the selected screen width"
    Print "                This is the default when needed"
    Print "  -nopillar     Do not add side pillar bars in movie-source mode"
    Print "                Example: -nopillar"
    Print
    Print "  -b0           Disable automatic ffmpeg crop detection"
    Print "                Default is automatic crop detection"
    Print "                Example: -b0"
    Print
    Print "  -k            Keep extracted frames/audio files after conversion"
    Print "                Example: -k"
    Print
    Print "  --start=time  Start trim point for movie-source input"
    Print "  --end=time    End trim point"
    Print "  --length=time Duration to encode"
    Print "                Short forms -start=, -end=, and -length= also work"
    Print "                Times may be HH:MM:SS or seconds"
    Print "                Examples: --start=00:05:00 --length=00:01:00"
    Print
    Print "  --audio-track=choice"
    Print "                Audio stream preference: auto, mono, stereo, surround,"
    Print "                a1/a2/... for ordinal audio track, or a stream index"
    Print "                Example: --audio-track=a2"
    Print
    Print "  --audio-normalize=on|off"
    Print "                Enables ffmpeg loudnorm/alimiter before resampling"
    Print "                Default: on"
    Print "                Example: --audio-normalize=off"
    Print
    Print "  --ffmpeg=path    Override ffmpeg executable"
    Print "  --ffprobe=path   Override ffprobe executable"
    Print "                   Example: --ffmpeg=/opt/homebrew/bin/ffmpeg"
    Print
    Print "Calculated values:"
    Print "  Video sectors = ceiling(video bytes per frame / 512)"
    Print "  Audio rate    = FPS * AudioSectors * 512"
    Print "  FIRQ delay    = 1000000 / (SampleRate * 0.279365), unused by -g8/-g15/-g16"
    Print
    Print "Video byte count:"
    Print "  Normal path   = Width * Height"
    Print "  -g8 SG24 path = ((Width + 1) \ 2) * Height"
    Print "                because SG24 stores 2 chunky pixels per byte"
    Print "  -p1 path      = ((Width + 1) \ 2) * Height"
    Print "                because 16-colour mode stores 2 pixels per byte"
    Print
    Print "Examples:"
    Print "  MakeNTM -d1 -f10 -g151 -p0 512x144 1 frames/frame%06d.png audio.u8 movie.ntm"
    Print "  MakeNTM -d1 -f10 -g151 -y24 -p0 512x144 1 frames/frame%06d.png audio.u8 movie.ntm"
    Print "  MakeNTM -d1 -f10 -g136 -y0 -p1 -c0 256x192 2 frames/frame%06d.png audio.u8 movie.ntm"
    Print "  MakeNTM -d1 -f10 -g136 -p1 -c1 256x107 2 frames/frame%06d.png audio.u8 movie.ntm"
    Print "  MakeNTM -d1 -g8 64x192 frames/frame%06d.png movie.ntm"
    Print "  MakeNTM -i=input.mp4 -o=movie.ntm -g8 --length=00:01:00"
    Print "  MakeNTM -d1 -g15 -t0 128x192 frames/frame%06d.png movie.ntm"
    Print "  MakeNTM -i=input.mp4 -o=movie.ntm -g15 -t1 --length=00:01:00"
    Print "  MakeNTM -d1 -g16 -t2 256x192 frames/frame%06d.png movie.ntm"
    Print "  MakeNTM -d1 -g16 -t0 256x192 frames/frame%06d.png audio.u8 movie.ntm"
    Print "  MakeNTM -i=input.mp4 -o=movie.ntm -g16 -t2 --start=00:05:00 --length=00:01:00"
    Print "  MakeNTM -i=input.mov -o=movie.ntm -g136 -f12 -a2 -p1 -c1 -r=256x144"
    Print
    Print "Notes:"
    Print "  - The program writes a 512-byte .NTM header sector first."
    Print "  - Palette sectors are written every 32 frames when -p1 is used."
    Print "  - -g8/-g15/-g16 always force 12 fps, -p0, and two audio sectors."
    Print "  - -g151 always forces -p0 and uses fixed grey palette 00,07,38,3F."
    Print "  - -g100..-g165 use the built-in CoCo 3 graphics mode table."
    Print "  - In -p1 mode, the header initial palette is taken from the first frame."
End Sub

Sub InitGModeTable
    Dim i As Integer
    For i = 0 To 165
        GModeByte(i) = -1
        GModeDesc$(i) = ""
    Next i

    GModeByte(100) = 1: GModeDesc$(100) = "64x192x4"
    GModeByte(101) = 33: GModeDesc$(101) = "64x200x4"
    GModeByte(102) = 97: GModeDesc$(102) = "64x225x4"
    GModeByte(103) = 10: GModeDesc$(103) = "64x192x16"
    GModeByte(104) = 42: GModeDesc$(104) = "64x200x16"
    GModeByte(105) = 106: GModeDesc$(105) = "64x225x16"
    GModeByte(106) = 5: GModeDesc$(106) = "80x192x4"
    GModeByte(107) = 37: GModeDesc$(107) = "80x200x4"
    GModeByte(108) = 101: GModeDesc$(108) = "80x225x4"
    GModeByte(109) = 14: GModeDesc$(109) = "80x192x16"
    GModeByte(110) = 46: GModeDesc$(110) = "80x200x16"
    GModeByte(111) = 110: GModeDesc$(111) = "80x225x16"
    GModeByte(112) = 0: GModeDesc$(112) = "128x192x2"
    GModeByte(113) = 32: GModeDesc$(113) = "128x200x2"
    GModeByte(114) = 96: GModeDesc$(114) = "128x225x2"
    GModeByte(115) = 9: GModeDesc$(115) = "128x192x4"
    GModeByte(116) = 41: GModeDesc$(116) = "128x200x4"
    GModeByte(117) = 105: GModeDesc$(117) = "128x225x4"
    GModeByte(118) = 18: GModeDesc$(118) = "128x192x16"
    GModeByte(119) = 50: GModeDesc$(119) = "128x200x16"
    GModeByte(120) = 114: GModeDesc$(120) = "128x225x16"
    GModeByte(121) = 4: GModeDesc$(121) = "160x192x2"
    GModeByte(122) = 36: GModeDesc$(122) = "160x200x2"
    GModeByte(123) = 100: GModeDesc$(123) = "160x225x2"
    GModeByte(124) = 13: GModeDesc$(124) = "160x192x4"
    GModeByte(125) = 45: GModeDesc$(125) = "160x200x4"
    GModeByte(126) = 109: GModeDesc$(126) = "160x225x4"
    GModeByte(127) = 22: GModeDesc$(127) = "160x192x16"
    GModeByte(128) = 54: GModeDesc$(128) = "160x200x16"
    GModeByte(129) = 118: GModeDesc$(129) = "160x225x16"
    GModeByte(130) = 8: GModeDesc$(130) = "256x192x2"
    GModeByte(131) = 40: GModeDesc$(131) = "256x200x2"
    GModeByte(132) = 104: GModeDesc$(132) = "256x225x2"
    GModeByte(133) = 17: GModeDesc$(133) = "256x192x4"
    GModeByte(134) = 49: GModeDesc$(134) = "256x200x4"
    GModeByte(135) = 113: GModeDesc$(135) = "256x225x4"
    GModeByte(136) = 26: GModeDesc$(136) = "256x192x16"
    GModeByte(137) = 58: GModeDesc$(137) = "256x200x16"
    GModeByte(138) = 122: GModeDesc$(138) = "256x225x16"
    GModeByte(139) = 12: GModeDesc$(139) = "320x192x2"
    GModeByte(140) = 44: GModeDesc$(140) = "320x200x2"
    GModeByte(141) = 108: GModeDesc$(141) = "320x225x2"
    GModeByte(142) = 21: GModeDesc$(142) = "320x192x4"
    GModeByte(143) = 53: GModeDesc$(143) = "320x200x4"
    GModeByte(144) = 117: GModeDesc$(144) = "320x225x4"
    GModeByte(145) = 30: GModeDesc$(145) = "320x192x16"
    GModeByte(146) = 62: GModeDesc$(146) = "320x200x16"
    GModeByte(147) = 126: GModeDesc$(147) = "320x225x16"
    GModeByte(148) = 16: GModeDesc$(148) = "512x192x2"
    GModeByte(149) = 48: GModeDesc$(149) = "512x200x2"
    GModeByte(150) = 112: GModeDesc$(150) = "512x225x2"
    GModeByte(151) = 25: GModeDesc$(151) = "512x192x4"
    GModeByte(152) = 57: GModeDesc$(152) = "512x200x4"
    GModeByte(153) = 121: GModeDesc$(153) = "512x225x4"
    GModeByte(154) = 20: GModeDesc$(154) = "640x192x2"
    GModeByte(155) = 52: GModeDesc$(155) = "640x200x2"
    GModeByte(156) = 116: GModeDesc$(156) = "640x225x2"
    GModeByte(157) = 29: GModeDesc$(157) = "640x192x4"
    GModeByte(158) = 61: GModeDesc$(158) = "640x200x4"
    GModeByte(159) = 125: GModeDesc$(159) = "640x225x4"
    GModeByte(160) = 25: GModeDesc$(160) = "512x192x4 NTSC"
    GModeByte(161) = 57: GModeDesc$(161) = "512x200x4 NTSC"
    GModeByte(162) = 121: GModeDesc$(162) = "512x225x4 NTSC"
    GModeByte(163) = 29: GModeDesc$(163) = "640x192x4 NTSC"
    GModeByte(164) = 61: GModeDesc$(164) = "640x200x4 NTSC"
    GModeByte(165) = 125: GModeDesc$(165) = "640x225x4 NTSC"
End Sub

Function ResolveGModeArg% (n As Integer)
    If n >= 100 And n <= 165 Then
        If GModeByte(n) >= 0 Then
            ResolveGModeArg% = GModeByte(n)
        Else
            ResolveGModeArg% = n And 255
        End If
    Else
        ResolveGModeArg% = n And 255
    End If
End Function

Function ParseResolution% (txt$, outW As Integer, outH As Integer)
    Dim s$, i As Integer, p As Integer
    s$ = LCase$(txt$)
    For i = 1 To Len(s$)
        If Asc(Mid$(s$, i, 1)) = 215 Then Mid$(s$, i, 1) = "x"
    Next i
    p = InStr(s$, "x")
    If p < 2 Or p >= Len(s$) Then
        ParseResolution = 0
        Exit Function
    End If
    outW = Val(Left$(s$, p - 1))
    outH = Val(Mid$(s$, p + 1))
    If outW < 1 Or outH < 1 Then
        ParseResolution = 0
    Else
        ParseResolution = -1
    End If
End Function


Function ByteToBin$ (v As Integer)
    Dim i As Integer
    Dim s As String
    v = v And 255
    s = ""
    For i = 7 To 0 Step -1
        If (v And (2 ^ i)) <> 0 Then
            s = s + "1"
        Else
            s = s + "0"
        End If
    Next i
    ByteToBin$ = s
End Function

Function GetModeInfo% (modeIndex As Integer, modeW As Integer, modeH As Integer, modeColors As Integer)
    Dim d$, p1 As Integer, p2 As Integer, p3 As Integer
    modeW = 0: modeH = 0: modeColors = 0
    If modeIndex = 16 Then
        modeW = 256
        modeH = 192
        modeColors = 2
        GetModeInfo = -1
        Exit Function
    End If
    If modeIndex < 100 Or modeIndex > 165 Then
        GetModeInfo = 0
        Exit Function
    End If
    d$ = GModeDesc$(modeIndex)
    p1 = InStr(d$, "x")
    If p1 = 0 Then
        GetModeInfo = 0
        Exit Function
    End If
    p2 = InStr(p1 + 1, d$, "x")
    If p2 = 0 Then
        GetModeInfo = 0
        Exit Function
    End If
    p3 = InStr(p2 + 1, d$, " ")
    If p3 = 0 Then p3 = Len(d$) + 1
    modeW = Val(Left$(d$, p1 - 1))
    modeH = Val(Mid$(d$, p1 + 1, p2 - p1 - 1))
    modeColors = Val(Mid$(d$, p2 + 1, p3 - p2 - 1))
    If modeW > 0 And modeH > 0 And modeColors > 0 Then
        GetModeInfo = -1
    Else
        GetModeInfo = 0
    End If
End Function

Function ParseNum& (txt$)
    Dim s$
    s$ = UCase$(txt$)
    If Left$(s$, 1) = "$" Then
        ParseNum = Val("&H" + Mid$(s$, 2))
    ElseIf Left$(s$, 2) = "&H" Then
        ParseNum = Val(s$)
    Else
        ParseNum = Val(s$)
    End If
End Function

Sub SetDefaultPalette
    Dim i As Integer
    For i = 0 To 15
        InitPalette(i) = i
    Next i

    If ScreenColors = 2 Then
        InitPalette(0) = &H00
        InitPalette(1) = &H3F
        For i = 2 To 15
            InitPalette(i) = 0
        Next i
    ElseIf ScreenColors = 4 Then
        InitPalette(0) = &H00
        InitPalette(1) = &H07
        InitPalette(2) = &H38
        InitPalette(3) = &H3F
        For i = 4 To 15
            InitPalette(i) = 0
        Next i
    Else
        ' Set default ready for an NTSC 256 colour video
        InitPalette(0) = &H00
        InitPalette(1) = &H10
        InitPalette(2) = &H20
        InitPalette(3) = &H30
        For i = 1 To 15
            If ForceSPEnabled(i) Then InitPalette(i) = ForceSPValue(i) And 63
        Next i
    End If
End Sub
Function ParsePaletteList% (txt$)
    Dim s$, token$, i As Integer, p As Integer, n As Integer
    s$ = txt$
    For i = 0 To 15
        p = InStr(s$, ",")
        If p > 0 Then
            token$ = Left$(s$, p - 1)
            s$ = Mid$(s$, p + 1)
        Else
            token$ = s$
            s$ = ""
        End If
        If Len(SafeTrim$(token$)) = 0 Then
            ParsePaletteList = 0
            Exit Function
        End If
        n = ParseNum(SafeTrim$(token$))
        If n < 0 Or n > 255 Then
            ParsePaletteList = 0
            Exit Function
        End If
        InitPalette(i) = n
    Next i
    If Len(SafeTrim$(s$)) <> 0 Then
        ParsePaletteList = 0
    Else
        ParsePaletteList = -1
    End If
End Function

Function SafeTrim$ (s$)
    Dim firstPos As Integer
    Dim lastPos As Integer
    Dim ch$

    firstPos = 1
    Do While firstPos <= Len(s$)
        ch$ = Mid$(s$, firstPos, 1)
        If ch$ <> " " And ch$ <> Chr$(9) Then Exit Do
        firstPos = firstPos + 1
    Loop

    If firstPos > Len(s$) Then
        SafeTrim$ = ""
        Exit Function
    End If

    lastPos = Len(s$)
    Do While lastPos >= firstPos
        ch$ = Mid$(s$, lastPos, 1)
        If ch$ <> " " And ch$ <> Chr$(9) Then Exit Do
        lastPos = lastPos - 1
    Loop

    SafeTrim$ = Mid$(s$, firstPos, lastPos - firstPos + 1)
End Function

Sub WriteHeaderSector (fh As Integer)
    Dim header(0 To HEADER_SECTOR_BYTES - 1) As _Unsigned _Byte
    Dim i As Integer
    Dim JumpSectorRateNum As _Unsigned Integer
    Dim pct As Integer
    Dim jumpSector As _Unsigned Long
    Dim jumpPos As Integer

    If ScreenColors = 2 Then
        InitPalette(0) = &H00
        InitPalette(1) = &H3F
        For i = 2 To 15
            InitPalette(i) = 0
        Next i
    ElseIf ScreenColors = 4 Then
        InitPalette(0) = &H00
        InitPalette(1) = &H07
        InitPalette(2) = &H38
        InitPalette(3) = &H3F
        For i = 4 To 15
            InitPalette(i) = 0
        Next i
    Else
        InitPalette(0) = &H00
        For i = 1 To 15
            If ForceSPEnabled(i) Then InitPalette(i) = ForceSPValue(i) And 63
        Next i
    End If

    For i = 0 To HEADER_SECTOR_BYTES - 1
        header(i) = 0
    Next i

    ' Header layout:
    ' 0-1   Version (word)
    ' 2     GMode (byte)
    ' 3-6   EndFrame / number of frames (32-bit)
    ' 7-8   Width (word)
    ' 9     Height (byte)
    ' 10    FPS (byte)
    ' 11    VidSectors (byte)
    ' 12-13 MemStart (word)
    ' 14    PalMode (byte)
    ' 15-30 InitPalette (16 bytes)
    ' 31-32 SampleRate (word)
    ' 33-34 FIRQDelay (word)
    ' 35    AudSectors (byte)
    ' 36-37 JumpSectorRateNum (word)
    ' 38-64 Jump sectors for 10%,20%,30%,40%,50%,60%,70%,80%,90% (9 x 24-bit values, big endian)

    header(0) = 0
    header(1) = 1
    header(2) = GMode And 255

    header(3) = (TotalFramesForHeader \ 16777216) And 255
    header(4) = (TotalFramesForHeader \ 65536) And 255
    header(5) = (TotalFramesForHeader \ 256) And 255
    header(6) = TotalFramesForHeader And 255

    header(7) = (FrameW \ 256) And 255
    header(8) = FrameW And 255
    header(9) = FrameH And 255
    header(10) = FPS And 255
    header(11) = VidSectors And 255
    header(12) = (MemStart \ 256) And 255
    header(13) = MemStart And 255
    header(14) = PalMode And 255

    For i = 0 To 15
        header(15 + i) = InitPalette(i) And 255
    Next i

    header(31) = (SampleRate \ 256) And 255
    header(32) = SampleRate And 255
    header(33) = (FIRQDelay \ 256) And 255
    header(34) = FIRQDelay And 255
    header(35) = AudSectors And 255

    JumpSectorRateNum = BuildJumpSectorRateNum&(FPS, VidSectors, AudSectors, PalMode)
    header(36) = (JumpSectorRateNum \ 256) And 255
    header(37) = JumpSectorRateNum And 255

    jumpPos = 38
    For pct = 10 To 90 Step 10
        jumpSector = BuildJumpSectorForPercent&(pct, TotalFramesForHeader, VidSectors, AudSectors, PalMode)
        header(jumpPos) = (jumpSector \ 65536) And 255
        header(jumpPos + 1) = (jumpSector \ 256) And 255
        header(jumpPos + 2) = jumpSector And 255
        jumpPos = jumpPos + 3
    Next pct

    For i = 0 To 279
        header(232 + i) = TextMessage(i) And 255
    Next i

    Put #fh, , header()
End Sub

Sub WritePaletteSector (fh As Integer, groupPalettes() As _Unsigned _Byte, groupCount As Integer)
    Dim palSector(0 To BYTES_PER_SECTOR - 1) As _Unsigned _Byte
    Dim i As Integer, j As Integer, p As Integer
    p = 0
    For i = 0 To 31
        For j = 0 To 15
            If i < groupCount Then
                palSector(p) = groupPalettes(i * 16 + j)
            ElseIf groupCount > 0 Then
                palSector(p) = groupPalettes((groupCount - 1) * 16 + j)
            Else
                palSector(p) = InitPalette(j)
            End If
            p = p + 1
        Next j
    Next i
    WriteStackBlastedSector fh, palSector()
End Sub


Sub WriteStackBlastedSector (fh As Integer, sectorData() As _Unsigned _Byte)
    Dim blasted(0 To BYTES_PER_SECTOR - 1) As _Unsigned _Byte
    Dim outPos As Integer
    Dim startPos As Integer
    Dim ii2 As Integer
    Dim ii3 As Integer

    outPos = 0
    startPos = BYTES_PER_SECTOR - 1

    For ii2 = 1 To 1
        For ii3 = 1 To 12 * 7 + 1
            blasted(outPos) = sectorData(startPos - 5): outPos = outPos + 1
            blasted(outPos) = sectorData(startPos - 4): outPos = outPos + 1
            blasted(outPos) = sectorData(startPos - 3): outPos = outPos + 1
            blasted(outPos) = sectorData(startPos - 2): outPos = outPos + 1
            blasted(outPos) = sectorData(startPos - 1): outPos = outPos + 1
            blasted(outPos) = sectorData(startPos): outPos = outPos + 1
            startPos = startPos - 6
        Next ii3
        blasted(outPos) = sectorData(startPos - 1): outPos = outPos + 1
        blasted(outPos) = sectorData(startPos): outPos = outPos + 1
        startPos = startPos - 2
    Next ii2

    Put #fh, , blasted()
End Sub

Sub WriteStatusLine (row As Integer, msg$)
    Locate row, 1
    Print Left$(msg$ + Space$(79), 79);
End Sub

Sub ReportLine (label$, value$)
    Print Left$(label$ + Space$(18), 18); value$
End Sub

Function BuildJumpSectorForPercent& (Percent As Integer, TotalFrames As Long, VideoSectors As Integer, AudioSectors As Integer, PalMode As Integer)
    Dim B As _Unsigned Integer
    Dim targetFrame As Long
    Dim groupSize As _Unsigned Long
    Dim groupIndex As _Unsigned Long

    If TotalFrames <= 0 Then
        BuildJumpSectorForPercent& = 1
        Exit Function
    End If

    B = VideoSectors + AudioSectors

    targetFrame = (TotalFrames * Percent) \ 100
    If targetFrame < 0 Then targetFrame = 0
    If targetFrame >= TotalFrames Then targetFrame = TotalFrames - 1

    If PalMode <> 0 Then
        groupSize = 1 + 32 * B
        groupIndex = targetFrame \ 32
        BuildJumpSectorForPercent& = 1 + groupIndex * groupSize
    Else
        BuildJumpSectorForPercent& = 1 + targetFrame * B
    End If
End Function




Function HasMovieInputMode%
    Dim i As Integer, a$
    For i = 1 To _CommandCount
        a$ = LCase$(Command$(i))
        If Left$(a$, 3) = "-i=" Then
            HasMovieInputMode = -1
            Exit Function
        End If
    Next i
    HasMovieInputMode = 0
End Function

Sub DeleteIfExists (f$)
    If _FileExists(f$) Then Kill f$
End Sub

Sub ChooseBestAudioStreamInfo (ffprobe$, inputFile$, audioPref$, samplerate As Long, audioIndex$, audioChannels As Integer, audioLayout$, audioCodec$, audioLanguage$, audioTitle$, audioKind$, audioFilter$, audioStrategy$)
    Dim blob$, lines As String, line$, k$, v$
    Dim i As Long, n As Long
    Dim curIndex$, curCodec$, curLanguage$, curTitle$, curHandler$, curLayout$, txt$, kind$, pref$
    Dim curChannels As Integer, curDefault As Integer, curOriginal As Integer, curComment As Integer
    Dim curSampleRate As Long, curBitRate As Long, bestScore As Long, curScore As Long, forced As Integer
    Dim bestIndex$, bestCodec$, bestLanguage$, bestTitle$, bestKind$, bestLayout$, bestFilter$, bestStrategy$
    Dim bestChannels As Integer
    blob$ = CaptureCommandOutput$(ShellQuote$(ffprobe$) + " -v error -select_streams a -show_entries stream=index,codec_name,channels,channel_layout,sample_rate,bit_rate:stream_disposition=default,original,comment:stream_tags=language,title,handler_name -of default=noprint_wrappers=0:nokey=0 " + ShellQuote$(inputFile$))
    If _Trim$(blob$) = "" Then Exit Sub
    pref$ = LCase$(_Trim$(audioPref$))
    blob$ = StripCR$(blob$)
    n = 0
    For i = 1 To Len(blob$)
        If Mid$(blob$, i, 1) = Chr$(10) Then n = n + 1
    Next i
    ReDim lines(1 To n + 2) As String
    n = 0
    line$ = ""
    For i = 1 To Len(blob$)
        If Mid$(blob$, i, 1) = Chr$(10) Then
            n = n + 1
            lines(n) = line$
            line$ = ""
        Else
            line$ = line$ + Mid$(blob$, i, 1)
        End If
    Next i
    If line$ <> "" Then n = n + 1: lines(n) = line$
    bestScore = -2147483647
    For i = 1 To n + 1
        line$ = ""
        If i <= n Then line$ = _Trim$(lines(i))
        If line$ = "[STREAM]" Then
            curIndex$ = "": curCodec$ = "": curLanguage$ = "und": curTitle$ = "": curHandler$ = "": curLayout$ = ""
            curChannels = 0: curDefault = 0: curOriginal = 0: curComment = 0: curSampleRate = 0: curBitRate = 0
        ElseIf line$ = "[/STREAM]" Or i = n + 1 Then
            If curIndex$ <> "" Then
                kind$ = ClassifyAudioKind$(curLayout$, curChannels)
                txt$ = LCase$(_Trim$(curTitle$ + " " + curHandler$ + " " + curLanguage$))
                forced = 0
                If pref$ <> "" And pref$ <> "auto" And pref$ <> "mono" And pref$ <> "stereo" And pref$ <> "surround" Then
                    If Left$(pref$, 1) = "a" Then
                        If Val(Mid$(pref$, 2)) >= 1 Then
                            Static trackNum As Integer
                        End If
                    ElseIf Val(pref$) = Val(curIndex$) And _Trim$(pref$) <> "" Then
                        forced = -1
                        curScore = 2000000
                    End If
                End If
                If forced = 0 Then curScore = ScoreAudioStream(kind$, curChannels, curSampleRate, curBitRate, curDefault, curOriginal, curComment, txt$, pref$)
                If curScore > bestScore Then
                    bestScore = curScore
                    bestIndex$ = curIndex$
                    bestCodec$ = curCodec$
                    bestLanguage$ = curLanguage$
                    If _Trim$(curTitle$) <> "" Then
                        bestTitle$ = curTitle$
                    Else
                        bestTitle$ = curHandler$
                    End If
                    bestKind$ = kind$
                    bestLayout$ = UCase$(curLayout$)
                    bestChannels = curChannels
                End If
            End If
        Else
            If InStr(line$, "=") > 0 Then
                k$ = LCase$(Left$(line$, InStr(line$, "=") - 1))
                v$ = Mid$(line$, InStr(line$, "=") + 1)
                Select Case k$
                    Case "index": curIndex$ = v$
                    Case "codec_name": curCodec$ = v$
                    Case "channels": curChannels = Val(v$)
                    Case "channel_layout": curLayout$ = v$
                    Case "sample_rate": curSampleRate = Val(v$)
                    Case "bit_rate": curBitRate = Val(v$)
                    Case "tag:language": curLanguage$ = v$
                    Case "tag:title": curTitle$ = v$
                    Case "tag:handler_name": curHandler$ = v$
                    Case "disposition:default": curDefault = Val(v$)
                    Case "disposition:original": curOriginal = Val(v$)
                    Case "disposition:comment": curComment = Val(v$)
                End Select
            End If
        End If
    Next i
    ' Handle aN audio track numbering preference by ordinal position among audio streams.
    If Left$(pref$, 1) = "a" And Val(Mid$(pref$, 2)) >= 1 Then
        Dim wanted As Integer, ordinal As Integer
        wanted = Val(Mid$(pref$, 2))
        ordinal = 0
        For i = 1 To n
            line$ = _Trim$(lines(i))
            If line$ = "[STREAM]" Then curIndex$ = ""
            If LCase$(Left$(line$, 6)) = "index=" Then
                ordinal = ordinal + 1
                If ordinal = wanted Then
                    bestIndex$ = Mid$(line$, 7)
                    Exit For
                End If
            End If
        Next i
        ' Re-read selected stream details if aN forced one.
        If bestIndex$ <> "" Then
            bestScore = -2147483647
            curIndex$ = "": curCodec$ = "": curLanguage$ = "und": curTitle$ = "": curHandler$ = "": curLayout$ = "": curChannels = 0
            For i = 1 To n + 1
                line$ = ""
                If i <= n Then line$ = _Trim$(lines(i))
                If line$ = "[STREAM]" Then
                    curIndex$ = "": curCodec$ = "": curLanguage$ = "und": curTitle$ = "": curHandler$ = "": curLayout$ = "": curChannels = 0
                ElseIf line$ = "[/STREAM]" Or i = n + 1 Then
                    If curIndex$ = bestIndex$ Then
                        bestCodec$ = curCodec$
                        bestLanguage$ = curLanguage$
                        If _Trim$(curTitle$) <> "" Then bestTitle$ = curTitle$ Else bestTitle$ = curHandler$
                        bestKind$ = ClassifyAudioKind$(curLayout$, curChannels)
                        bestLayout$ = UCase$(curLayout$)
                        bestChannels = curChannels
                        Exit For
                    End If
                ElseIf InStr(line$, "=") > 0 Then
                    k$ = LCase$(Left$(line$, InStr(line$, "=") - 1))
                    v$ = Mid$(line$, InStr(line$, "=") + 1)
                    Select Case k$
                        Case "index": curIndex$ = v$
                        Case "codec_name": curCodec$ = v$
                        Case "channels": curChannels = Val(v$)
                        Case "channel_layout": curLayout$ = v$
                        Case "tag:language": curLanguage$ = v$
                        Case "tag:title": curTitle$ = v$
                        Case "tag:handler_name": curHandler$ = v$
                    End Select
                End If
            Next i
        End If
    End If
    audioIndex$ = bestIndex$
    audioChannels = bestChannels
    audioLayout$ = bestLayout$
    audioCodec$ = bestCodec$
    audioLanguage$ = bestLanguage$
    audioTitle$ = bestTitle$
    audioKind$ = bestKind$
    If bestKind$ = "mono" Then
        audioFilter$ = "anull"
        audioStrategy$ = "mono passthrough"
    ElseIf bestKind$ = "stereo" Then
        audioFilter$ = "pan=mono|c0=0.5*FL+0.5*FR"
        audioStrategy$ = "stereo fold-down to mono"
    Else
        audioFilter$ = "pan=mono|c0<0.90*FC+0.60*FL+0.60*FR+0.35*BL+0.35*BR+0.30*SL+0.30*SR+0.28*BC+0.12*LFE"
        audioStrategy$ = "surround-aware mono fold-down prioritizing center/dialogue"
    End If
End Sub

Function ClassifyAudioKind$ (layout$, channels As Integer)
    Dim l$
    l$ = LCase$(layout$)
    If channels <= 1 Then ClassifyAudioKind$ = "mono": Exit Function
    If InStr(l$, "5.1") Or InStr(l$, "5.0") Or InStr(l$, "6.1") Or InStr(l$, "7.1") Or InStr(l$, "7.0") Or InStr(l$, "quad") Or InStr(l$, "surround") Then ClassifyAudioKind$ = "surround": Exit Function
    If InStr(l$, "stereo") Or channels = 2 Then ClassifyAudioKind$ = "stereo": Exit Function
    If channels >= 3 Then ClassifyAudioKind$ = "surround" Else ClassifyAudioKind$ = "stereo"
End Function

Function CommentaryPenalty% (txt$)
    Dim t$, penalty As Integer
    t$ = LCase$(txt$)
    penalty = 0
    If InStr(t$, "commentary") Then penalty = penalty + 220
    If InStr(t$, "director") Then penalty = penalty + 80
    If InStr(t$, "producer") Then penalty = penalty + 60
    If InStr(t$, "writer") Then penalty = penalty + 60
    If InStr(t$, "cast") Then penalty = penalty + 50
    If InStr(t$, "descriptive") Or InStr(t$, "description") Or InStr(t$, "described") Then penalty = penalty + 180
    If InStr(t$, "visual impaired") Or InStr(t$, "visually impaired") Then penalty = penalty + 180
    If InStr(t$, "narration") Then penalty = penalty + 70
    If InStr(t$, "isolated score") Then penalty = penalty + 90
    CommentaryPenalty% = penalty
End Function

Function AudioPreferenceBonus% (kind$, pref$)
    Select Case LCase$(_Trim$(pref$))
        Case "surround"
            If kind$ = "surround" Then
                AudioPreferenceBonus% = 220
            ElseIf kind$ = "stereo" Then
                AudioPreferenceBonus% = 40
            End If
        Case "stereo"
            If kind$ = "stereo" Then
                AudioPreferenceBonus% = 220
            ElseIf kind$ = "surround" Then
                AudioPreferenceBonus% = 30
            End If
        Case "mono"
            If kind$ = "mono" Then
                AudioPreferenceBonus% = 220
            ElseIf kind$ = "stereo" Then
                AudioPreferenceBonus% = 20
            End If
    End Select
End Function

Function ScoreAudioStream& (kind$, channels As Integer, sampleRate As Long, bitRate As Long, isDefault As Integer, isOriginal As Integer, isComment As Integer, txt$, pref$)
    Dim sc As Long
    If isDefault Then sc = sc + 140
    If isOriginal Then sc = sc + 30
    If isComment Then sc = sc - 220
    If kind$ = "surround" Then
        sc = sc + 55
    ElseIf kind$ = "stereo" Then
        sc = sc + 40
    Else
        sc = sc + 15
    End If
    sc = sc + channels * 2
    If sampleRate > 96000 Then sampleRate = 96000
    sc = sc + (sampleRate \ 1000) \ 4
    If bitRate > 1500000 Then bitRate = 1500000
    sc = sc + (bitRate \ 1000) \ 32
    txt$ = LCase$(txt$)
    If InStr(txt$, "stereo") Then sc = sc + 4
    If InStr(txt$, "surround") Or InStr(txt$, "5.1") Or InStr(txt$, "7.1") Or InStr(txt$, "atmos") Then sc = sc + 8
    sc = sc + AudioPreferenceBonus%(kind$, pref$)
    sc = sc - CommentaryPenalty%(txt$)
    ScoreAudioStream& = sc
End Function

Function ShellQuote$ (s$)
    Dim i As Integer, ch$, t$
    t$ = Chr$(34)
    For i = 1 To Len(s$)
        ch$ = Mid$(s$, i, 1)
        If ch$ = Chr$(34) Then
            t$ = t$ + Chr$(92) + Chr$(34)
        Else
            t$ = t$ + ch$
        End If
    Next i
    ShellQuote$ = t$ + Chr$(34)
End Function

Function CaptureCommandOutput$ (cmd$)
    Dim tmp$, cmdLine$, ff As Integer, line$, out$
    Randomize Timer
    tmp$ = "_capt_" + LTrim$(Str$(CLng(Timer * 1000))) + "_" + LTrim$(Str$(Int(Rnd * 100000))) + ".txt"
    If RunningOnWindows Then
        ' Windows needs CMD /C for output redirection.
        ' Wrap the whole command after /C in quotes so quoted ffmpeg/ffprobe paths still work.
        cmdLine$ = "CMD /C " + Chr$(34) + cmd$ + " > " + ShellQuote$(tmp$) + " 2>&1" + Chr$(34)
    Else
        cmdLine$ = cmd$ + " > " + ShellQuote$(tmp$) + " 2>&1"
    End If
    Shell _Hide cmdLine$
    If _FileExists(tmp$) Then
        ff = FreeFile
        Open tmp$ For Input As #ff
        Do Until EOF(ff)
            Line Input #ff, line$
            out$ = out$ + line$ + Chr$(10)
        Loop
        Close #ff
        Kill tmp$
    End If
    CaptureCommandOutput$ = out$
End Function

Function GetFFProbeValue$ (blob$, key$)
    Dim p As Long, e As Long, look$
    look$ = key$ + "="
    p = InStr(blob$, look$)
    If p = 0 Then Exit Function
    p = p + Len(look$)
    e = InStr(p, blob$, Chr$(10))
    If e = 0 Then e = Len(blob$) + 1
    GetFFProbeValue$ = _Trim$(Mid$(blob$, p, e - p))
End Function

Function NormalizeTimeArg$ (t$)
    Dim h As Long, m As Long, s As Double
    Dim p1 As Long, p2 As Long, body$
    t$ = _Trim$(t$)
    If t$ = "" Then Exit Function
    If Left$(t$, 1) = Chr$(34) And Right$(t$, 1) = Chr$(34) Then
        If Len(t$) >= 2 Then t$ = Mid$(t$, 2, Len(t$) - 2)
    End If
    body$ = t$
    p1 = InStr(body$, ":")
    If p1 > 0 Then
        p2 = InStr(p1 + 1, body$, ":")
    Else
        p2 = 0
    End If
    If p1 > 0 And p2 > 0 Then
        h = Val(Left$(body$, p1 - 1))
        m = Val(Mid$(body$, p1 + 1, p2 - p1 - 1))
        s = Val(Mid$(body$, p2 + 1))
    ElseIf p1 > 0 Then
        h = 0
        m = Val(Left$(body$, p1 - 1))
        s = Val(Mid$(body$, p1 + 1))
    Else
        h = 0
        m = 0
        s = Val(body$)
    End If
    If h < 0 Then h = 0
    If m < 0 Then m = 0
    If s < 0 Then s = 0
    NormalizeTimeArg$ = Right$("00" + LTrim$(Str$(h)), 2) + ":" + Right$("00" + LTrim$(Str$(m)), 2) + ":" + Right$("00" + LTrim$(Str$(Int(s))), 2)
End Function

Function TimeToSeconds# (t$)
    Dim n As Integer, a$(1 To 3), h As Double, m As Double, s As Double
    t$ = _Trim$(t$)
    If t$ = "" Then Exit Function
    n = 0
    Do While InStr(t$, ":")
        n = n + 1
        a$(n) = Left$(t$, InStr(t$, ":") - 1)
        t$ = Mid$(t$, InStr(t$, ":") + 1)
    Loop
    n = n + 1
    a$(n) = t$
    If n = 3 Then
        h = Val(a$(1)): m = Val(a$(2)): s = Val(a$(3))
    ElseIf n = 2 Then
        h = 0: m = Val(a$(1)): s = Val(a$(2))
    Else
        h = 0: m = 0: s = Val(a$(1))
    End If
    TimeToSeconds = h * 3600# + m * 60# + s
End Function

Function SecondsToTime$ (s#)
    Dim h As Long, m As Long, sec As Long
    If s# < 0 Then s# = 0
    h = Int(s# / 3600#)
    s# = s# - h * 3600#
    m = Int(s# / 60#)
    s# = s# - m * 60#
    sec = Int(s# + .5)
    SecondsToTime$ = Right$("00" + LTrim$(Str$(h)), 2) + ":" + Right$("00" + LTrim$(Str$(m)), 2) + ":" + Right$("00" + LTrim$(Str$(sec)), 2)
End Function

Function DetectCrop$ (ffmpeg$, inputFile$, sampleStart$, sampleDur$)
    Dim cmd$, out$, p As Long, lastp As Long, e As Long
    cmd$ = ShellQuote$(ffmpeg$) + " -hide_banner -ss " + ShellQuote$(NormalizeTimeArg$(sampleStart$)) + " -t " + ShellQuote$(NormalizeTimeArg$(sampleDur$)) + " -i " + ShellQuote$(inputFile$) + " -vf " + ShellQuote$("cropdetect=limit=0.08:round=2:reset=0") + " -an -sn -dn -f null -"
    out$ = CaptureCommandOutput$(cmd$)
    lastp = 0
    p = InStr(out$, "crop=")
    Do While p > 0
        lastp = p
        p = InStr(p + 1, out$, "crop=")
    Loop
    If lastp > 0 Then
        e = InStr(lastp, out$, Chr$(10))
        If e = 0 Then e = Len(out$) + 1
        DetectCrop$ = _Trim$(Mid$(out$, lastp + 5, e - (lastp + 5)))
    End If
End Function

Function ComputeScaledRes$ (screenW As Integer, screenH As Integer, scaleTxt$)
    Dim f As Double, ww As Integer, hh As Integer
    f = Val(scaleTxt$)
    If f <= 0 Or f > 1 Then
        ComputeScaledRes$ = ""
        Exit Function
    End If
    ww = Int(screenW * f + .5)
    hh = Int(screenH * f + .5)
    If ww < 1 Then ww = 1
    If hh < 1 Then hh = 1
    If ww > 1 And (ww Mod 2) <> 0 Then ww = ww - 1
    If hh > 1 And (hh Mod 2) <> 0 Then hh = hh - 1
    ComputeScaledRes$ = LTrim$(Str$(ww)) + "x" + LTrim$(Str$(hh))
End Function

Function ExtractRawOptValue$ (rawCmd$, optA$, optB$)
    Dim p As Long, startPos As Long, i As Long
    Dim ch$, out$, activeOpt$
    out$ = ""
    p = InStr(rawCmd$, optA$)
    activeOpt$ = optA$
    If p = 0 And optB$ <> "" Then
        p = InStr(rawCmd$, optB$)
        activeOpt$ = optB$
    End If
    If p = 0 Then
        ExtractRawOptValue$ = ""
        Exit Function
    End If
    startPos = p + Len(activeOpt$)
    If startPos > Len(rawCmd$) Then
        ExtractRawOptValue$ = ""
        Exit Function
    End If
    If Mid$(rawCmd$, startPos, 1) = Chr$(34) Then
        startPos = startPos + 1
        For i = startPos To Len(rawCmd$)
            ch$ = Mid$(rawCmd$, i, 1)
            If ch$ = Chr$(34) Then Exit For
            out$ = out$ + ch$
        Next i
    Else
        For i = startPos To Len(rawCmd$)
            ch$ = Mid$(rawCmd$, i, 1)
            If ch$ = " " Then Exit For
            out$ = out$ + ch$
        Next i
    End If
    ExtractRawOptValue$ = out$
End Function

Function BuildVideoFilter$ (ffmpeg$, ffprobe$, inputFile$, fps As Integer, screenW As Integer, screenH As Integer, movieW As Integer, movieH As Integer, frameOutW As Integer, frameOutH As Integer, srcW As Integer, srcH As Integer, cropInfo$, hdrInfo$, scaleTxt$, resTxt$, autoCrop As Integer, startTime$, noPillar As Integer, forceFullFrame As Integer)
    Dim filter$
    Dim info$, srcTransfer$, srcPrimaries$, srcColorSpace$
    filter$ = ""
    Dim logicalW As Integer, cropW As Integer, cropH As Integer, cropX As Integer, cropY As Integer
    Dim cropRes$, p1 As Long, p2 As Long, p3 As Long, useW As Integer, useH As Integer
    Dim fitSrcW As Integer, fitSrcH As Integer, fitScale As Double
    Dim fitLogicalW As Integer, movieDisplayW As Integer, pixelAspectDivisor As Integer
    info$ = CaptureCommandOutput$(ShellQuote$(ffprobe$) + " -v error -select_streams v:0 -show_entries stream=width,height,color_transfer,color_primaries,color_space -of default=noprint_wrappers=1:nokey=0 " + ShellQuote$(inputFile$))
    srcW = Val(GetFFProbeValue$(info$, "width"))
    srcH = Val(GetFFProbeValue$(info$, "height"))
    srcTransfer$ = LCase$(GetFFProbeValue$(info$, "color_transfer"))
    srcPrimaries$ = LCase$(GetFFProbeValue$(info$, "color_primaries"))
    srcColorSpace$ = LCase$(GetFFProbeValue$(info$, "color_space"))
    If srcW < 1 Or srcH < 1 Then Exit Function
    fitSrcW = srcW
    fitSrcH = srcH
    logicalW = 256
    If resTxt$ = "" Then
        movieW = screenW
        If movieW > 128 And screenW >= 512 Then movieW = screenW
        movieH = Int((logicalW * srcH / srcW) + .5)
        If movieH > screenH Then movieH = screenH
        If movieH > 1 And (movieH Mod 2) <> 0 Then movieH = movieH - 1
    Else
        movieW = Val(resTxt$)
        movieH = Val(Mid$(resTxt$, InStr(resTxt$, "x") + 1))
    End If
    If autoCrop <> 0 Then
        If startTime$ <> "" Then
            cropRes$ = DetectCrop$(ffmpeg$, inputFile$, startTime$, "00:00:20")
        Else
            cropRes$ = DetectCrop$(ffmpeg$, inputFile$, "00:05:00", "00:00:20")
        End If
        cropInfo$ = cropRes$
        If cropRes$ <> "" Then
            p1 = InStr(cropRes$, ":")
            p2 = InStr(p1 + 1, cropRes$, ":")
            p3 = InStr(p2 + 1, cropRes$, ":")
            If p1 > 0 And p2 > 0 And p3 > 0 Then
                cropW = Val(Left$(cropRes$, p1 - 1))
                cropH = Val(Mid$(cropRes$, p1 + 1, p2 - p1 - 1))
                cropX = Val(Mid$(cropRes$, p2 + 1, p3 - p2 - 1))
                cropY = Val(Mid$(cropRes$, p3 + 1))
                fitSrcW = cropW
                fitSrcH = cropH
                If resTxt$ = "" Then
                    movieH = Int((logicalW * cropH / cropW) + .5)
                    If movieH > screenH Then movieH = screenH
                    If movieH > 1 And (movieH Mod 2) <> 0 Then movieH = movieH - 1
                End If
                filter$ = "crop=" + LTrim$(Str$(cropW)) + ":" + LTrim$(Str$(cropH)) + ":" + LTrim$(Str$(cropX)) + ":" + LTrim$(Str$(cropY)) + ","
            End If
        End If
    End If
    If forceFullFrame <> 0 And resTxt$ = "" Then
        fitLogicalW = screenW
        pixelAspectDivisor = 1
        If screenW = 128 And screenH = 192 Then pixelAspectDivisor = 2
        If screenW = 64 And screenH = 192 Then pixelAspectDivisor = 4
        fitLogicalW = screenW * pixelAspectDivisor
        fitScale = fitLogicalW / fitSrcW
        If screenH / fitSrcH < fitScale Then fitScale = screenH / fitSrcH
        movieDisplayW = Int(fitSrcW * fitScale + .5)
        movieW = Int(movieDisplayW / pixelAspectDivisor + .5)
        movieH = Int(fitSrcH * fitScale + .5)
        If movieW < 1 Then movieW = 1
        If movieH < 1 Then movieH = 1
        If movieW > 1 And (movieW Mod 2) <> 0 Then movieW = movieW - 1
        If movieH > 1 And (movieH Mod 2) <> 0 Then movieH = movieH - 1
    End If
    If forceFullFrame <> 0 And (movieW > screenW Or movieH > screenH) Then
        fitScale = screenW / movieW
        If screenH / movieH < fitScale Then fitScale = screenH / movieH
        movieW = Int(movieW * fitScale + .5)
        movieH = Int(movieH * fitScale + .5)
        If movieW < 1 Then movieW = 1
        If movieH < 1 Then movieH = 1
        If movieW > 1 And (movieW Mod 2) <> 0 Then movieW = movieW - 1
        If movieH > 1 And (movieH Mod 2) <> 0 Then movieH = movieH - 1
    End If
    If srcTransfer$ = "smpte2084" Or srcTransfer$ = "arib-std-b67" Or srcPrimaries$ = "bt2020" Or srcColorSpace$ = "bt2020nc" Or srcColorSpace$ = "bt2020c" Then
        hdrInfo$ = "HDR"
    Else
        hdrInfo$ = "SDR"
    End If
    useW = movieW: useH = movieH
    frameOutW = movieW: frameOutH = movieH
    If forceFullFrame <> 0 Then
        frameOutW = screenW
        frameOutH = screenH
        filter$ = filter$ + "fps=" + LTrim$(Str$(fps)) + ","
        If hdrInfo$ = "HDR" Then
            filter$ = filter$ + "zscale=transfer=linear:npl=100,format=gbrpf32le,tonemap=tonemap=mobius:desat=2:peak=100,zscale=primaries=bt709:transfer=bt709:matrix=bt709:range=full,"
        End If
        filter$ = filter$ + "scale=" + LTrim$(Str$(useW)) + ":" + LTrim$(Str$(useH)) + ":flags=lanczos+accurate_rnd+full_chroma_int,pad=" + LTrim$(Str$(screenW)) + ":" + LTrim$(Str$(screenH)) + ":(ow-iw)/2:(oh-ih)/2:black,setsar=1,format=rgb24"
        BuildVideoFilter$ = filter$
        Exit Function
    End If
    If scaleTxt$ <> "" Then
        filter$ = filter$ + "fps=" + LTrim$(Str$(fps)) + ","
        If hdrInfo$ = "HDR" Then
            filter$ = filter$ + "zscale=transfer=linear:npl=100,format=gbrpf32le,tonemap=tonemap=mobius:desat=2:peak=100,zscale=primaries=bt709:transfer=bt709:matrix=bt709:range=full,"
        End If
        If noPillar <> 0 Then
            frameOutW = movieW
            frameOutH = movieH
            filter$ = filter$ + "scale=" + LTrim$(Str$(useW)) + ":" + LTrim$(Str$(useH)) + ":flags=lanczos+accurate_rnd+full_chroma_int,setsar=1,format=rgb24"
        Else
            frameOutW = screenW
            frameOutH = movieH
            filter$ = filter$ + "scale=" + LTrim$(Str$(useW)) + ":" + LTrim$(Str$(useH)) + ":flags=lanczos+accurate_rnd+full_chroma_int,pad=" + LTrim$(Str$(screenW)) + ":" + LTrim$(Str$(useH)) + ":(ow-iw)/2:0:black,setsar=1,format=rgb24"
        End If
    Else
        filter$ = filter$ + "fps=" + LTrim$(Str$(fps)) + ","
        If hdrInfo$ = "HDR" Then
            filter$ = filter$ + "zscale=transfer=linear:npl=100,format=gbrpf32le,tonemap=tonemap=mobius:desat=2:peak=100,zscale=primaries=bt709:transfer=bt709:matrix=bt709:range=full,"
        End If
        filter$ = filter$ + "scale=" + LTrim$(Str$(useW)) + ":" + LTrim$(Str$(useH)) + ":flags=lanczos+accurate_rnd+full_chroma_int,setsar=1,format=rgb24"
    End If
    BuildVideoFilter$ = filter$
End Function

Sub EnsureSilentAudio (audioFile$, fps As Integer, audSectors As Integer)
    Dim ff As Integer, i As Long, total As Long, b As _Unsigned _Byte
    If _FileExists(audioFile$) Then Exit Sub
    total = CLng(fps) * CLng(audSectors) * 512
    b = 128
    ff = FreeFile
    Open audioFile$ For Binary As #ff
    For i = 1 To total
        Put #ff, , b
    Next i
    Close #ff
End Sub

Sub PrepareMovieInputMode (count As Integer, ResArg$, AudSectors As Integer, FramePattern$, AudioFile$, OutFile$, haveRes As Integer, haveAudioSectors As Integer, havePattern As Integer, haveAudio As Integer, haveOutput As Integer, MovieName$)
    Dim i As Integer, a$, inputMovie$, ffmpeg$, ffprobe$, startTime$, endTime$, lengthTime$, scaleTxt$, resTxt$, rawCmd$, rawStart$, rawEnd$, rawLength$
    Dim keepFiles As Integer, autoCrop As Integer, gm As Integer, reqFPS As Integer, pal As Integer, chooser As Integer, shadow As Integer
    Dim screenW As Integer, screenH As Integer, colors As Integer, movieW As Integer, movieH As Integer, outW As Integer, outH As Integer
    Dim srcW As Integer, srcH As Integer, filter$, cropInfo$, hdrInfo$, cmd$, hasAudio As Integer, audioInfo$, yrow As Integer
    Dim durSeconds As Double, startSeconds As Double, endSeconds As Double, effectiveLen$, trimStart$, modeIndex As Integer
    Dim audioCh As Integer, audioLayout$, audioFilter$, audioPref$, audioNormalize$, audioIndex$, audioCodec$, audioLanguage$, audioTitle$, audioKind$, audioStrategy$
    Dim sampleRate As Long
    ffmpeg$ = "ffmpeg"
    ffprobe$ = "ffprobe"
    FramePattern$ = "frames/frame%06d.png"
    AudioFile$ = "audio.u8"
    autoCrop = 1
    keepFiles = 0
    audioPref$ = "auto"
    audioNormalize$ = "on"
    Dim aLower$, eqPos As Integer, spIdx As Integer
    For i = 1 To count
        a$ = Command$(i)
        aLower$ = LCase$(a$)
        eqPos = InStr(a$, "=")
        If Left$(aLower$, 3) = "-i=" Then inputMovie$ = Mid$(a$, 4)
        If Left$(aLower$, 3) = "-o=" Then OutFile$ = Mid$(a$, 4)
        If Left$(aLower$, 2) = "-g" Then gm = Val(Mid$(a$, 3))
        If Left$(aLower$, 4) = "-fps" Then
            reqFPS = Val(Mid$(a$, 5))
        ElseIf Left$(aLower$, 2) = "-f" Then
            reqFPS = Val(Mid$(a$, 3))
        End If
        If Left$(aLower$, 2) = "-a" Then
            AudSectors = Val(Mid$(a$, 3))
        End If
        If Left$(aLower$, 2) = "-t" Then
            CoCo1ArtifactMode = Val(Mid$(a$, 3))
            CoCo1ArtifactModeSpecified = -1
        End If
        If Left$(aLower$, 2) = "-d" Then DitherType = Val(Mid$(a$, 3))
        If Left$(aLower$, 3) = "-sp" Then
            eqPos = InStr(a$, "=")
            If eqPos > 4 Then
                spIdx = Val(Mid$(a$, 4, eqPos - 4))
                If spIdx >= 1 And spIdx <= 15 Then
                    ForceSPEnabled(spIdx) = -1
                    ForceSPValue(spIdx) = Val(Mid$(a$, eqPos + 1)) And 63
                    If spIdx = 1 Then
                        ForceSP1Enabled = -1
                        ForceSP1Value = ForceSPValue(1)
                    End If
                End If
            End If
        End If
        If Left$(aLower$, 2) = "-c" Then PalettePickMethod = Val(Mid$(a$, 3))
        If Left$(aLower$, 2) = "-l" Then ShadowLumaGreyMode = Val(Mid$(a$, 3))
        If aLower$ = "-nopillar" Then
            NoPillar = -1
        ElseIf aLower$ = "-pillar" Then
            NoPillar = 0
        ElseIf Left$(aLower$, 2) = "-p" Then
            PalMode = Val(Mid$(a$, 3))
        End If
        If Left$(aLower$, 2) = "-y" Then StartRow = Val(Mid$(a$, 3)): UseStartRow = -1
        If Left$(aLower$, 3) = "-r=" Then resTxt$ = Mid$(a$, 4)
        If Left$(aLower$, 3) = "-s=" Then scaleTxt$ = Mid$(a$, 4)
        If Left$(aLower$, 9) = "--ffmpeg=" And eqPos > 0 Then ffmpeg$ = Mid$(a$, eqPos + 1)
        If Left$(aLower$, 10) = "--ffprobe=" And eqPos > 0 Then ffprobe$ = Mid$(a$, eqPos + 1)
        If Left$(aLower$, 14) = "--audio-track=" And eqPos > 0 Then audioPref$ = Mid$(a$, eqPos + 1)
        If Left$(aLower$, 18) = "--audio-normalize=" And eqPos > 0 Then audioNormalize$ = Mid$(a$, eqPos + 1)
        If Left$(aLower$, 8) = "--start=" And eqPos > 0 Then startTime$ = Mid$(a$, eqPos + 1)
        If Left$(aLower$, 6) = "--end=" And eqPos > 0 Then endTime$ = Mid$(a$, eqPos + 1)
        If Left$(aLower$, 9) = "--length=" And eqPos > 0 Then lengthTime$ = Mid$(a$, eqPos + 1)
        If Left$(aLower$, 3) = "-n=" Then FramePattern$ = Mid$(a$, 4)
        If aLower$ = "-k" Then keepFiles = -1
        If Left$(aLower$, 3) = "-b0" Then autoCrop = 0
        If Left$(aLower$, 7) = "--name=" And eqPos > 0 Then MovieName$ = Mid$(a$, eqPos + 1)
        If Left$(aLower$, 6) = "-name=" Then MovieName$ = Mid$(a$, 7)
    Next i
    rawCmd$ = Command$
    rawStart$ = ExtractRawOptValue$(rawCmd$, "--start=", "-start=")
    rawEnd$ = ExtractRawOptValue$(rawCmd$, "--end=", "-end=")
    rawLength$ = ExtractRawOptValue$(rawCmd$, "--length=", "-length=")
    If rawStart$ <> "" Then startTime$ = rawStart$
    If rawEnd$ <> "" Then endTime$ = rawEnd$
    If rawLength$ <> "" Then lengthTime$ = rawLength$
    If gm = 8 Or gm = 15 Or gm = 16 Then
        AudSectors = 2
        reqFPS = 12
    End If
    If inputMovie$ = "" Or OutFile$ = "" Or gm = 0 Or reqFPS = 0 Or (gm <> 8 And gm <> 15 And gm <> 16 And AudSectors = 0) Then
        ShowUsage
        System
    End If
    GModeIndex = gm
    GMode = ResolveGModeArg(gm)
    FPS = reqFPS
    If gm = 8 Then
        screenW = 64
        screenH = 192
        colors = 9
    ElseIf gm = 15 Then
        screenW = 128
        screenH = 192
        colors = 4
    ElseIf gm = 16 Then
        screenW = 256
        screenH = 192
        colors = 2
    Else
        If GetModeInfo(gm, screenW, screenH, colors) = 0 Then
            Print "Error: could not decode CoCo mode "; gm
            System
        End If
    End If
    If scaleTxt$ <> "" Then
        resTxt$ = ComputeScaledRes$(screenW, screenH, scaleTxt$)
        If resTxt$ = "" Then
            Print "Error: -s must be > 0 and <= 1"
            System
        End If
    End If
    filter$ = BuildVideoFilter$(ffmpeg$, ffprobe$, inputMovie$, reqFPS, screenW, screenH, movieW, movieH, outW, outH, srcW, srcH, cropInfo$, hdrInfo$, scaleTxt$, resTxt$, autoCrop, startTime$, NoPillar, gm = 8 Or gm = 15 Or gm = 16)
    If filter$ = "" Then
        Print "Error: could not build ffmpeg video filter"
        System
    End If
    Print "Preparing movie input with ffmpeg/ffprobe..."
    Print "Input movie       "; inputMovie$
    Print "Source size       "; srcW; "x"; srcH
    Print "Output frame size "; outW; "x"; outH
    Print "Active movie size "; movieW; "x"; movieH
    If scaleTxt$ <> "" Then Print "Scale factor      "; scaleTxt$
    If NoPillar <> 0 Then Print "No pillar bars    "; 1
    If cropInfo$ <> "" Then Print "Auto crop         "; cropInfo$
    Print "HDR handling      "; hdrInfo$
    DeleteIfExists AudioFile$
    If _FileExists(OutFile$) Then Kill OutFile$
    If RunningOnWindows Then
        Shell _Hide "rmdir /s /q frames"
        Shell _Hide "mkdir frames"
    Else
        Shell _Hide "rm -rf frames"
        Shell _Hide "mkdir -p frames"
    End If
    trimStart$ = ""
    If startTime$ <> "" Then trimStart$ = " -ss " + ShellQuote$(NormalizeTimeArg$(startTime$))
    effectiveLen$ = ""
    If lengthTime$ <> "" Then
        effectiveLen$ = " -t " + ShellQuote$(NormalizeTimeArg$(lengthTime$))
    ElseIf endTime$ <> "" Then
        startSeconds = TimeToSeconds(startTime$)
        endSeconds = TimeToSeconds(endTime$)
        effectiveLen$ = " -t " + ShellQuote$(SecondsToTime$(endSeconds - startSeconds))
    End If
    If rawStart$ <> "" Then Print "Raw start arg     "; rawStart$
    If rawLength$ <> "" Then Print "Raw length arg    "; rawLength$
    If startTime$ <> "" Then Print "Trim start        "; NormalizeTimeArg$(startTime$)
    If effectiveLen$ <> "" Then Print "Trim length       "; Mid$(effectiveLen$, 5)
    cmd$ = ShellQuote$(ffmpeg$) + " -y" + trimStart$ + effectiveLen$ + " -i " + ShellQuote$(inputMovie$) + " -map 0:v:0 -vf " + ShellQuote$(filter$) + " -start_number 0 " + ShellQuote$(FramePattern$)
    sampleRate = CLng(reqFPS) * CLng(AudSectors) * 512
    ChooseBestAudioStreamInfo ffprobe$, inputMovie$, audioPref$, sampleRate, audioIndex$, audioCh, audioLayout$, audioCodec$, audioLanguage$, audioTitle$, audioKind$, audioFilter$, audioStrategy$
    If _Trim$(audioIndex$) <> "" Then
        If LCase$(_Trim$(audioNormalize$)) = "on" Then
            audioFilter$ = audioFilter$ + ",loudnorm=I=-20:LRA=10:TP=-2:linear=false,alimiter=limit=0.92"
        End If
        audioFilter$ = audioFilter$ + ",aresample=" + LTrim$(Str$(sampleRate)) + ":dither_method=triangular_hp"
        Print "Audio stream index "; audioIndex$
        Print "Audio codec        "; audioCodec$
        Print "Audio language     "; audioLanguage$
        Print "Audio layout       "; audioLayout$; " ("; LTrim$(Str$(audioCh)); " ch, "; audioKind$; ")"
        If _Trim$(audioTitle$) <> "" Then Print "Audio title        "; audioTitle$
        Print "Audio strategy     "; audioStrategy$
        Print "Audio normalize    "; LCase$(_Trim$(audioNormalize$))
        Print "Audio ffmpeg filter"; audioFilter$
        cmd$ = cmd$ + " -map 0:" + audioIndex$ + " -af " + ShellQuote$(audioFilter$) + " -ac 1 -ar " + LTrim$(Str$(sampleRate)) + " -c:a pcm_u8 -f u8 " + ShellQuote$(AudioFile$)
    End If
    Print "Running ffmpeg..."
    Print cmd$
    Shell cmd$
    EnsureSilentAudio AudioFile$, reqFPS, AudSectors
    ResArg$ = LTrim$(Str$(outW)) + "x" + LTrim$(Str$(outH))
    haveRes = -1: haveAudioSectors = -1: havePattern = -1: haveAudio = -1: haveOutput = -1
    If keepFiles = 0 Then
        ' Existing program can still clean up externally later if desired.
    End If
End Sub

Function StripCR$ (s$)
    Dim i As Long, out$
    out$ = ""
    For i = 1 To Len(s$)
        If Mid$(s$, i, 1) <> Chr$(13) Then out$ = out$ + Mid$(s$, i, 1)
    Next i
    StripCR$ = out$
End Function


Function QuantizeBW1Bit% (grey As Integer)
    If grey < 128 Then
        QuantizeBW1Bit% = 0
    Else
        QuantizeBW1Bit% = 1
    End If
End Function

Sub ConvertFrameTo1BitBW (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
    Dim x As Integer, y As Integer
    Dim p As Long
    Dim grey As Integer
    Dim q0 As Integer, q1 As Integer, q2 As Integer, q3 As Integer
    Dim q4 As Integer, q5 As Integer, q6 As Integer, q7 As Integer
    Dim levels(0 To 1) As Integer
    Dim errGrey As Single
    Dim thisGrey As Single
    Dim quantGrey As Integer
    Dim e As Single
    Dim threshold As Integer

    framePalette(0) = 0
    framePalette(1) = 63
    For x = 2 To 15
        framePalette(x) = 0
    Next x

    levels(0) = 0
    levels(1) = 255
    p = 0

    Select Case DitherType
        Case 1
            ReDim errGrey(0 To FrameW + 1, 0 To FrameH + 1) As Single
            For y = 0 To FrameH - 1
                For x = 0 To FrameW - 1
                    grey = (77 * pixelR(x, y) + 150 * pixelG(x, y) + 29 * pixelB(x, y)) \ 256
                    thisGrey = grey + errGrey(x, y)
                    If thisGrey < 0 Then thisGrey = 0
                    If thisGrey > 255 Then thisGrey = 255
                    DitherOut(x, y) = QuantizeBW1Bit%(CInt(thisGrey))
                    quantGrey = levels(DitherOut(x, y))
                    e = thisGrey - quantGrey
                    If x < FrameW - 1 Then errGrey(x + 1, y) = errGrey(x + 1, y) + e * 7! / 16!
                    If y < FrameH - 1 Then
                        If x > 0 Then errGrey(x - 1, y + 1) = errGrey(x - 1, y + 1) + e * 3! / 16!
                        errGrey(x, y + 1) = errGrey(x, y + 1) + e * 5! / 16!
                        If x < FrameW - 1 Then errGrey(x + 1, y + 1) = errGrey(x + 1, y + 1) + e * 1! / 16!
                    End If
                Next x
            Next y

        Case 2
            Randomize 1
            For y = 0 To FrameH - 1
                For x = 0 To FrameW - 1
                    grey = (77 * pixelR(x, y) + 150 * pixelG(x, y) + 29 * pixelB(x, y)) \ 256
                    grey = grey + Int(Rnd * 65) - 32
                    If grey < 0 Then grey = 0
                    If grey > 255 Then grey = 255
                    DitherOut(x, y) = QuantizeBW1Bit%(grey)
                Next x
            Next y

        Case 3
            For y = 0 To FrameH - 1
                For x = 0 To FrameW - 1
                    grey = (77 * pixelR(x, y) + 150 * pixelG(x, y) + 29 * pixelB(x, y)) \ 256
                    threshold = OrderedArray(x And 7, y And 7) - 128
                    grey = grey + threshold
                    If grey < 0 Then grey = 0
                    If grey > 255 Then grey = 255
                    DitherOut(x, y) = QuantizeBW1Bit%(grey)
                Next x
            Next y

        Case Else
            For y = 0 To FrameH - 1
                For x = 0 To FrameW - 1
                    grey = (77 * pixelR(x, y) + 150 * pixelG(x, y) + 29 * pixelB(x, y)) \ 256
                    DitherOut(x, y) = QuantizeBW1Bit%(grey)
                Next x
            Next y
    End Select

    For y = 0 To FrameH - 1
        For x = 0 To FrameW - 1 Step 8
            q0 = DitherOut(x, y) And 1
            If x + 1 < FrameW Then q1 = DitherOut(x + 1, y) And 1 Else q1 = 0
            If x + 2 < FrameW Then q2 = DitherOut(x + 2, y) And 1 Else q2 = 0
            If x + 3 < FrameW Then q3 = DitherOut(x + 3, y) And 1 Else q3 = 0
            If x + 4 < FrameW Then q4 = DitherOut(x + 4, y) And 1 Else q4 = 0
            If x + 5 < FrameW Then q5 = DitherOut(x + 5, y) And 1 Else q5 = 0
            If x + 6 < FrameW Then q6 = DitherOut(x + 6, y) And 1 Else q6 = 0
            If x + 7 < FrameW Then q7 = DitherOut(x + 7, y) And 1 Else q7 = 0
            frameVideo(p) = (q0 * 128) Or (q1 * 64) Or (q2 * 32) Or (q3 * 16) Or (q4 * 8) Or (q5 * 4) Or (q6 * 2) Or q7
            p = p + 1
        Next x
    Next y

    While p <= UBound(frameVideo)
        frameVideo(p) = 0
        p = p + 1
    Wend
End Sub

Sub PackDitherOutTo1Bit (frameVideo() As _Unsigned _Byte)
    Dim x As Integer, y As Integer
    Dim p As Long
    Dim q0 As Integer, q1 As Integer, q2 As Integer, q3 As Integer
    Dim q4 As Integer, q5 As Integer, q6 As Integer, q7 As Integer

    p = 0
    For y = 0 To FrameH - 1
        For x = 0 To FrameW - 1 Step 8
            q0 = DitherOut(x, y) And 1
            If x + 1 < FrameW Then q1 = DitherOut(x + 1, y) And 1 Else q1 = 0
            If x + 2 < FrameW Then q2 = DitherOut(x + 2, y) And 1 Else q2 = 0
            If x + 3 < FrameW Then q3 = DitherOut(x + 3, y) And 1 Else q3 = 0
            If x + 4 < FrameW Then q4 = DitherOut(x + 4, y) And 1 Else q4 = 0
            If x + 5 < FrameW Then q5 = DitherOut(x + 5, y) And 1 Else q5 = 0
            If x + 6 < FrameW Then q6 = DitherOut(x + 6, y) And 1 Else q6 = 0
            If x + 7 < FrameW Then q7 = DitherOut(x + 7, y) And 1 Else q7 = 0
            frameVideo(p) = (q0 * 128) Or (q1 * 64) Or (q2 * 32) Or (q3 * 16) Or (q4 * 8) Or (q5 * 4) Or (q6 * 2) Or q7
            p = p + 1
        Next x
    Next y

    While p <= UBound(frameVideo)
        frameVideo(p) = 0
        p = p + 1
    Wend
End Sub

Sub ConvertFrameToCoCo1SolidBW (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
    Dim x As Integer, y As Integer
    Dim grey As Integer
    Dim pairGrey As Integer
    Dim q As Integer
    Dim threshold As Integer
    Dim errGrey As Single
    Dim thisGrey As Single
    Dim quantGrey As Integer
    Dim e As Single

    framePalette(0) = 0
    framePalette(1) = 63
    For x = 2 To 15
        framePalette(x) = 0
    Next x

    Select Case DitherType
        Case 1
            ReDim errGrey(0 To (FrameW \ 2) + 1, 0 To FrameH + 1) As Single
            For y = 0 To FrameH - 1
                For x = 0 To FrameW - 1 Step 2
                    grey = (77 * pixelR(x, y) + 150 * pixelG(x, y) + 29 * pixelB(x, y)) \ 256
                    If x + 1 < FrameW Then
                        grey = grey + ((77 * pixelR(x + 1, y) + 150 * pixelG(x + 1, y) + 29 * pixelB(x + 1, y)) \ 256)
                        pairGrey = grey \ 2
                    Else
                        pairGrey = grey
                    End If
                    thisGrey = pairGrey + errGrey(x \ 2, y)
                    If thisGrey < 0 Then thisGrey = 0
                    If thisGrey > 255 Then thisGrey = 255
                    q = QuantizeBW1Bit%(CInt(thisGrey))
                    quantGrey = q * 255
                    e = thisGrey - quantGrey
                    DitherOut(x, y) = q
                    If x + 1 < FrameW Then DitherOut(x + 1, y) = q
                    If x < FrameW - 2 Then errGrey((x \ 2) + 1, y) = errGrey((x \ 2) + 1, y) + e * 7! / 16!
                    If y < FrameH - 1 Then
                        If x > 0 Then errGrey((x \ 2) - 1, y + 1) = errGrey((x \ 2) - 1, y + 1) + e * 3! / 16!
                        errGrey(x \ 2, y + 1) = errGrey(x \ 2, y + 1) + e * 5! / 16!
                        If x < FrameW - 2 Then errGrey((x \ 2) + 1, y + 1) = errGrey((x \ 2) + 1, y + 1) + e * 1! / 16!
                    End If
                Next x
            Next y

        Case 2
            Randomize 1
            For y = 0 To FrameH - 1
                For x = 0 To FrameW - 1 Step 2
                    grey = (77 * pixelR(x, y) + 150 * pixelG(x, y) + 29 * pixelB(x, y)) \ 256
                    If x + 1 < FrameW Then
                        grey = grey + ((77 * pixelR(x + 1, y) + 150 * pixelG(x + 1, y) + 29 * pixelB(x + 1, y)) \ 256)
                        pairGrey = grey \ 2
                    Else
                        pairGrey = grey
                    End If
                    pairGrey = pairGrey + Int(Rnd * 65) - 32
                    If pairGrey < 0 Then pairGrey = 0
                    If pairGrey > 255 Then pairGrey = 255
                    q = QuantizeBW1Bit%(pairGrey)
                    DitherOut(x, y) = q
                    If x + 1 < FrameW Then DitherOut(x + 1, y) = q
                Next x
            Next y

        Case 3
            For y = 0 To FrameH - 1
                For x = 0 To FrameW - 1 Step 2
                    grey = (77 * pixelR(x, y) + 150 * pixelG(x, y) + 29 * pixelB(x, y)) \ 256
                    If x + 1 < FrameW Then
                        grey = grey + ((77 * pixelR(x + 1, y) + 150 * pixelG(x + 1, y) + 29 * pixelB(x + 1, y)) \ 256)
                        pairGrey = grey \ 2
                    Else
                        pairGrey = grey
                    End If
                    threshold = OrderedArray((x \ 2) And 7, y And 7) - 128
                    pairGrey = pairGrey + threshold
                    If pairGrey < 0 Then pairGrey = 0
                    If pairGrey > 255 Then pairGrey = 255
                    q = QuantizeBW1Bit%(pairGrey)
                    DitherOut(x, y) = q
                    If x + 1 < FrameW Then DitherOut(x + 1, y) = q
                Next x
            Next y

        Case Else
            For y = 0 To FrameH - 1
                For x = 0 To FrameW - 1 Step 2
                    grey = (77 * pixelR(x, y) + 150 * pixelG(x, y) + 29 * pixelB(x, y)) \ 256
                    If x + 1 < FrameW Then
                        grey = grey + ((77 * pixelR(x + 1, y) + 150 * pixelG(x + 1, y) + 29 * pixelB(x + 1, y)) \ 256)
                        pairGrey = grey \ 2
                    Else
                        pairGrey = grey
                    End If
                    q = QuantizeBW1Bit%(pairGrey)
                    DitherOut(x, y) = q
                    If x + 1 < FrameW Then DitherOut(x + 1, y) = q
                Next x
            Next y
    End Select

    PackDitherOutTo1Bit frameVideo()
End Sub

Sub ConvertFrameToCoCo1Artifact4Color (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
    Dim x As Integer, y As Integer
    Dim srcR As Single, srcG As Single, srcB As Single
    Dim testR As Single, testG As Single, testB As Single
    Dim er As Single, eg As Single, eb As Single
    Dim dr As Long, dg As Long, db As Long
    Dim best As Integer, chosen As Integer, dist As Long, bestDist As Long
    Dim cR(0 To 3) As Integer, cG(0 To 3) As Integer, cB(0 To 3) As Integer
    Dim errR As Single, errG As Single, errB As Single
    Dim threshold As Integer

    framePalette(0) = 0
    framePalette(1) = 63
    For x = 2 To 15
        framePalette(x) = 0
    Next x

    For y = 0 To FrameH - 1
        For x = 0 To FrameW - 1
            DitherOut(x, y) = 0
        Next x
    Next y

    ' Standard CoCo 3 power-up artifact phase on composite CoCo 1/2:
    ' 00 = black, 01 = red, 10 = blue, 11 = white.
    cR(0) = 0: cG(0) = 0: cB(0) = 0
    cR(1) = 255: cG(1) = 45: cB(1) = 35
    cR(2) = 40: cG(2) = 75: cB(2) = 255
    cR(3) = 255: cG(3) = 255: cB(3) = 255

    If DitherType = 1 Then
        ReDim errR(0 To (FrameW \ 2) + 1, 0 To FrameH + 1) As Single
        ReDim errG(0 To (FrameW \ 2) + 1, 0 To FrameH + 1) As Single
        ReDim errB(0 To (FrameW \ 2) + 1, 0 To FrameH + 1) As Single
    ElseIf DitherType = 2 Then
        Randomize 1
    End If

    For y = 0 To FrameH - 1
        For x = 0 To FrameW - 2 Step 2
            srcR = (pixelR(x, y) + pixelR(x + 1, y)) / 2!
            srcG = (pixelG(x, y) + pixelG(x + 1, y)) / 2!
            srcB = (pixelB(x, y) + pixelB(x + 1, y)) / 2!

            If DitherType = 1 Then
                testR = srcR + errR(x \ 2, y)
                testG = srcG + errG(x \ 2, y)
                testB = srcB + errB(x \ 2, y)
            Else
                testR = srcR
                testG = srcG
                testB = srcB
            End If

            If DitherType = 2 Then
                testR = testR + Int(Rnd * 41) - 20
                testG = testG + Int(Rnd * 41) - 20
                testB = testB + Int(Rnd * 41) - 20
            ElseIf DitherType = 3 Then
                threshold = (OrderedArray((x \ 2) And 7, y And 7) - 128) \ 3
                testR = testR + threshold
                testG = testG + threshold
                testB = testB + threshold
            End If

            If testR < 0 Then testR = 0
            If testR > 255 Then testR = 255
            If testG < 0 Then testG = 0
            If testG > 255 Then testG = 255
            If testB < 0 Then testB = 0
            If testB > 255 Then testB = 255

            best = 0
            chosen = 0
            bestDist = 2147483647
            For best = 0 To 3
                dr = CLng(testR) - cR(best)
                dg = CLng(testG) - cG(best)
                db = CLng(testB) - cB(best)
                dist = dr * dr + dg * dg + db * db
                If dist < bestDist Then
                    bestDist = dist
                    chosen = best
                End If
            Next best
            DitherOut(x, y) = (chosen \ 2) And 1
            DitherOut(x + 1, y) = chosen And 1

            If DitherType = 1 Then
                er = testR - cR(chosen)
                eg = testG - cG(chosen)
                eb = testB - cB(chosen)
                If x < FrameW - 2 Then
                    errR((x \ 2) + 1, y) = errR((x \ 2) + 1, y) + er * 7! / 16!
                    errG((x \ 2) + 1, y) = errG((x \ 2) + 1, y) + eg * 7! / 16!
                    errB((x \ 2) + 1, y) = errB((x \ 2) + 1, y) + eb * 7! / 16!
                End If
                If y < FrameH - 1 Then
                    If x > 0 Then
                        errR((x \ 2) - 1, y + 1) = errR((x \ 2) - 1, y + 1) + er * 3! / 16!
                        errG((x \ 2) - 1, y + 1) = errG((x \ 2) - 1, y + 1) + eg * 3! / 16!
                        errB((x \ 2) - 1, y + 1) = errB((x \ 2) - 1, y + 1) + eb * 3! / 16!
                    End If
                    errR(x \ 2, y + 1) = errR(x \ 2, y + 1) + er * 5! / 16!
                    errG(x \ 2, y + 1) = errG(x \ 2, y + 1) + eg * 5! / 16!
                    errB(x \ 2, y + 1) = errB(x \ 2, y + 1) + eb * 5! / 16!
                    If x < FrameW - 2 Then
                        errR((x \ 2) + 1, y + 1) = errR((x \ 2) + 1, y + 1) + er * 1! / 16!
                        errG((x \ 2) + 1, y + 1) = errG((x \ 2) + 1, y + 1) + eg * 1! / 16!
                        errB((x \ 2) + 1, y + 1) = errB((x \ 2) + 1, y + 1) + eb * 1! / 16!
                    End If
                End If
            End If
        Next x
    Next y

    PackDitherOutTo1Bit frameVideo()
End Sub

Sub ConvertFrameToCoCo1Artifact2x2 (frameVideo() As _Unsigned _Byte, framePalette() As _Unsigned _Byte)
    Dim x As Integer, y As Integer, i As Integer
    Dim bx As Integer, by As Integer
    Dim srcR As Single, srcG As Single, srcB As Single
    Dim testR As Single, testG As Single, testB As Single
    Dim er As Single, eg As Single, eb As Single
    Dim dr As Long, dg As Long, db As Long
    Dim best As Integer, dist As Long, bestDist As Long
    Dim pat As Integer
    Dim errR As Single, errG As Single, errB As Single
    Dim bitTL As Integer, bitTR As Integer, bitBL As Integer, bitBR As Integer
    Dim rowCode As Integer
    Dim rowR(0 To 3) As Integer, rowG(0 To 3) As Integer, rowB(0 To 3) As Integer
    Dim patR(0 To 15) As Integer, patG(0 To 15) As Integer, patB(0 To 15) As Integer
    Dim threshold As Integer

    framePalette(0) = 0
    framePalette(1) = 63
    For x = 2 To 15
        framePalette(x) = 0
    Next x

    For y = 0 To FrameH - 1
        For x = 0 To FrameW - 1
            DitherOut(x, y) = 0
        Next x
    Next y

    ' Standard CoCo 3 power-up artifact phase on composite CoCo 1/2:
    ' 01 = red, 10 = blue.  A 2x2 block blends the two row colours.
    rowR(0) = 0: rowG(0) = 0: rowB(0) = 0
    rowR(1) = 255: rowG(1) = 45: rowB(1) = 35
    rowR(2) = 40: rowG(2) = 75: rowB(2) = 255
    rowR(3) = 255: rowG(3) = 255: rowB(3) = 255

    For pat = 0 To 15
        bitTL = (pat \ 8) And 1
        bitTR = (pat \ 4) And 1
        bitBL = (pat \ 2) And 1
        bitBR = pat And 1
        rowCode = bitTL * 2 + bitTR
        patR(pat) = rowR(rowCode)
        patG(pat) = rowG(rowCode)
        patB(pat) = rowB(rowCode)
        rowCode = bitBL * 2 + bitBR
        patR(pat) = (patR(pat) + rowR(rowCode)) \ 2
        patG(pat) = (patG(pat) + rowG(rowCode)) \ 2
        patB(pat) = (patB(pat) + rowB(rowCode)) \ 2
    Next pat

    If DitherType = 1 Then
        ReDim errR(0 To (FrameW \ 2) + 1, 0 To (FrameH \ 2) + 1) As Single
        ReDim errG(0 To (FrameW \ 2) + 1, 0 To (FrameH \ 2) + 1) As Single
        ReDim errB(0 To (FrameW \ 2) + 1, 0 To (FrameH \ 2) + 1) As Single
    ElseIf DitherType = 2 Then
        Randomize 1
    End If

    For y = 0 To FrameH - 1 Step 2
        by = y \ 2
        For x = 0 To FrameW - 2 Step 2
            bx = x \ 2
            srcR = 0: srcG = 0: srcB = 0
            For i = 0 To 3
                If x + (i And 1) < FrameW And y + (i \ 2) < FrameH Then
                    srcR = srcR + pixelR(x + (i And 1), y + (i \ 2))
                    srcG = srcG + pixelG(x + (i And 1), y + (i \ 2))
                    srcB = srcB + pixelB(x + (i And 1), y + (i \ 2))
                End If
            Next i
            srcR = srcR / 4!
            srcG = srcG / 4!
            srcB = srcB / 4!

            If DitherType = 1 Then
                testR = srcR + errR(bx, by)
                testG = srcG + errG(bx, by)
                testB = srcB + errB(bx, by)
            Else
                testR = srcR
                testG = srcG
                testB = srcB
            End If

            If DitherType = 2 Then
                testR = testR + Int(Rnd * 41) - 20
                testG = testG + Int(Rnd * 41) - 20
                testB = testB + Int(Rnd * 41) - 20
            ElseIf DitherType = 3 Then
                threshold = (OrderedArray(bx And 7, by And 7) - 128) \ 3
                testR = testR + threshold
                testG = testG + threshold
                testB = testB + threshold
            End If

            If testR < 0 Then testR = 0
            If testR > 255 Then testR = 255
            If testG < 0 Then testG = 0
            If testG > 255 Then testG = 255
            If testB < 0 Then testB = 0
            If testB > 255 Then testB = 255

            best = 0
            bestDist = 2147483647
            For pat = 0 To 15
                dr = CLng(testR) - patR(pat)
                dg = CLng(testG) - patG(pat)
                db = CLng(testB) - patB(pat)
                dist = dr * dr + dg * dg + db * db
                If dist < bestDist Then
                    bestDist = dist
                    best = pat
                End If
            Next pat

            bitTL = (best \ 8) And 1
            bitTR = (best \ 4) And 1
            bitBL = (best \ 2) And 1
            bitBR = best And 1
            DitherOut(x, y) = bitTL
            If x + 1 < FrameW Then DitherOut(x + 1, y) = bitTR
            If y + 1 < FrameH Then
                DitherOut(x, y + 1) = bitBL
                If x + 1 < FrameW Then DitherOut(x + 1, y + 1) = bitBR
            End If

            If DitherType = 1 Then
                er = testR - patR(best)
                eg = testG - patG(best)
                eb = testB - patB(best)
                If x < FrameW - 2 Then
                    errR(bx + 1, by) = errR(bx + 1, by) + er * 7! / 16!
                    errG(bx + 1, by) = errG(bx + 1, by) + eg * 7! / 16!
                    errB(bx + 1, by) = errB(bx + 1, by) + eb * 7! / 16!
                End If
                If y < FrameH - 2 Then
                    If bx > 0 Then
                        errR(bx - 1, by + 1) = errR(bx - 1, by + 1) + er * 3! / 16!
                        errG(bx - 1, by + 1) = errG(bx - 1, by + 1) + eg * 3! / 16!
                        errB(bx - 1, by + 1) = errB(bx - 1, by + 1) + eb * 3! / 16!
                    End If
                    errR(bx, by + 1) = errR(bx, by + 1) + er * 5! / 16!
                    errG(bx, by + 1) = errG(bx, by + 1) + eg * 5! / 16!
                    errB(bx, by + 1) = errB(bx, by + 1) + eb * 5! / 16!
                    If x < FrameW - 2 Then
                        errR(bx + 1, by + 1) = errR(bx + 1, by + 1) + er * 1! / 16!
                        errG(bx + 1, by + 1) = errG(bx + 1, by + 1) + eg * 1! / 16!
                        errB(bx + 1, by + 1) = errB(bx + 1, by + 1) + eb * 1! / 16!
                    End If
                End If
            End If
        Next x
    Next y

    PackDitherOutTo1Bit frameVideo()
End Sub
