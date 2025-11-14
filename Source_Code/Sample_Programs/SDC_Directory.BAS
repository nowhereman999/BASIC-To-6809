
cls:?"SDC ACCESS"
CD$="*.*" ' Start at the top folder on the SDC
'CD$="TEST1/*.*" ' Start at the folder TEST on the SDC
?"PATH:";CD$
' Set the initial directory location
x=SDC_INITDIR(CD$):GOSUB CheckForError
?"GETTING DIR"
SDC_DIRPAGE A$,B$,x:GOSUB CheckForError ' Get the directory listing & check for any errors
X$=A$:GOSUB ShowDirX
X$=B$:GOSUB ShowDirX

SDC_DIRPAGE A$,B$,x:GOSUB CheckForError ' Get the directory listing & check for any errors
X$=A$:GOSUB ShowDirX
X$=B$:GOSUB ShowDirX
END

ShowDirX:
P=1
WHILE asc(MID$(X$,P,1))<>0 and P<129
    FOR x=0 to 7:?MID$(X$,P+x,1);:NEXT x
    ?".";
    FOR x=8 to 10:?MID$(X$,P+x,1);:NEXT x
    ?
    P=P+16
WEND
RETURN

CheckForError:
if x<>0 then ?"ERROR NUMBER IS:";x:END
RETURN
' ADDASSEM:
' ENDASSEM:
