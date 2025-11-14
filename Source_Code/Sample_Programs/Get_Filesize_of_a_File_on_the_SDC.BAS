' Print length of a file on the CoCo SDC
INPUT"FILENAME TO GET THE SIZE OF";Filename$
SDC_OPEN Filename$,"R",1
A$=SDC_FileInfo$(1)
SDC_Close(1)
FOR I=1 TO LEN(A$)
PRINT right$("0"+HEX$(ASC(MID$(A$,I,1))),2);
NEXT I
?
FP_Length=FloatMul(INT(ASC(MID$(A$,32,1))),256)
FP_Length=FloatAdd(FP_Length,INT(ASC(MID$(A$,31,1))))
FP_Length=FloatMul(FP_Length,65536)
FP_Temp=FloatMul(INT(Asc(MID$(A$,30,1))),256)
FP_Temp=FloatAdd(FP_Temp,INT(ASC(MID$(A$,29,1))))
FP_Length=FloatAdd(FP_Length,FP_Temp)
FP$=FloatToStr(FP_Length)
' Get the sign of the number
S$=LEFT$(FP$,1) 
' Get the numbers without the decimal
N$=MID$(FP$,2,1)+MID$(FP$,4,8) 
' Get the Exponent + 1
E=VAL(RIGHT$(FP$,3))+1
SELECT CASE E
    CASE IS <1
        V$=S$+"0."+STRING$(-E,"0")+N$
    CASE 1 TO 8
        V$=S$+LEFT$(N$,E)+"."+RIGHT$(N$,9-E)
    CASE IS >8
        V$=S$+N$+STRING$(E-9,"0")
End Select
?"FP$=";FP$
?"V$=";V$
END
