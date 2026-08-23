' compileoptions -s20

Dim i As _Byte

10 Gmode 16: GCls: Screen 1, 0

For i = 0 To 96
    Print #-4, Chr$(i);
Next i

999 GoTo 999

