' compileoptions -s20

' Print length of a file on the CoCo SDC

DIM FileLength AS _UNSIGNED LONG ' LONG is a 32 bit number

CLS
PRINT "ENTER THE FILENAME TO GET"
INPUT "THE SIZE OF"; Filename$

SDC_OPEN Filename$, "R", 1 ' Open file for reading
A$ = SDC_FILEINFO$(1) ' Get fileinfo in A$
SDC_CLOSE (1) 'close file

PRINT: PRINT "RAW HEX CODES OF FILE INFO:"
FOR I = 1 TO LEN(A$)
    PRINT RIGHT$("0" + HEX$(ASC(MID$(A$, I, 1))), 2);
NEXT I
PRINT
' Size is stored LSB first
FileLength = ASC(MID$(A$, 29, 1)) + ASC(MID$(A$, 30, 1)) * 256 + ASC(MID$(A$, 31, 1)) * 65536 + ASC(MID$(A$, 32, 1)) * 16777216

PRINT "LENGTH OF FILE: "; Filename$
PRINT "IS:"; FileLength; " BYTES"

Finished:
GOTO Finished

