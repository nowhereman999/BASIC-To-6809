
HandleStringVariable:
v = Array(x) * 256 + Array(x + 1): x = x + 2
StringVar$ = "_StrVar_" + StringVariable$(v)
DestStringVar$ = StringVar$
If Verbose > 3 Then Print "String variable is: "; StringVar$
v = Array(x): x = x + 1
If v <> &HFC Then Print "Syntax error14, looking for = sign in";: GoTo FoundError
v = Array(x): x = x + 1
If v <> &H3D Then Print "Syntax error15, looking for = sign in";: GoTo FoundError
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseStringExpression
Z$ = "; String is on the stack, deal with it here:": GoSub AO
A$ = "PULS": B$ = "B": C$ = "B = length of the source string": GoSub AO
A$ = "LDX": B$ = "#" + DestStringVar$: C$ = "X points at the length of the destination string": GoSub AO
A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AO
A$ = "BEQ": B$ = "@Done": C$ = "If the length of the string is zero then don't copy it (Skip ahead)": GoSub AO
Z$ = "!"
A$ = "LDA": B$ = ",S+": C$ = "Get a source byte": GoSub AO
A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AO
A$ = "DECB": C$ = "Decrement the counter": GoSub AO
A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AO
Z$ = "@Done": GoSub AO
Print #1, "" ' Leave a space between sections so @Done will work for each section
Return

HandleStringArray:
If Verbose > 3 Then Print "Going to deal with String array"
v = Array(x) * 256 + Array(x + 1): x = x + 2
NumBits = StringArrayBits(v)
InsideArrayType = StringArrayBits(v)
If NumBits = 8 Then
    InsideArrayType = NT_UByte ' use 8-bit unsigned indices
Else
    InsideArrayType = NT_UInt16 ' use 16-bit unsigned indices
End If
NV$ = StringArrayVariables$(v)
If Verbose > 3 Then Print "String array variable is: "; NV$
NumDims = Array(x): x = x + 1
x = x + 2 ' Consume the $F5 & open bracket
If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims
' Get all the dimensions
DimCounter = NumDims
While DimCounter > 1
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," and move past it
    GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
    NVT = InsideArrayType
    GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
    DimCounter = DimCounter - 1
Wend
GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
NVT = InsideArrayType
GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
' We now have:
' NV$=NumArrayName
' Value in brackets is on the stack
' NumBits = number of bits (8 or 16)
' NumDims = Number of dimensions

Num = StringArraySize + 1 ' Length of each string +1 for the first byte which is the length of the particular string, when stored
GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
Temp$ = Num$
If NumDims = 1 Then
    If NumBits = 8 Then
        ' Handle an array with 8 bit indices
        Z$ = "; Only 8 bit indices": GoSub AO
        A$ = "LDA": B$ = "#" + Temp$: C$ = "A = BytesPerEntry": GoSub AO
        A$ = "PULS": B$ = "B": C$ = "get d1, fix the stack": GoSub AO
        A$ = "MUL": C$ = "Multiply them": GoSub AO
        Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "ADDD": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save the location the array is pointing at on the stack": GoSub AO
    Else
        ' Handle an array with 16 bit indices
        Z$ = "; Only 1 16 bit element array": GoSub AO
        Z$ = "; d1 is already on the stack": GoSub AO
        A$ = "LDD": B$ = "#" + Temp$: C$ = "D = BytesPerEntry": GoSub AO
        A$ = "PSHS": B$ = "D": C$ = "Save BytesPerEntry as 16 bit on the stack": GoSub AO
        A$ = "JSR": B$ = "MUL16": C$ = "16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits": GoSub AO
        A$ = "LDD": B$ = ",S": C$ = "Get the low 16 bit result in D, fix the stack": GoSub AO
        Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "ADDD": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
        A$ = "STD": B$ = ",S": C$ = "Save the location the array is pointing at": GoSub AO
    End If
Else
    Num = NumDims - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    A$ = "LDD": B$ = "#" + Temp$ + "*$100+" + Num$: C$ = "A = BytesPerEntry, B = Dim count-1": GoSub AO
    If NumBits = 8 Then
        ' Handle an array with 8 bit values
        Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDU": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
        A$ = "JSR": B$ = "ArrayGetAddress8bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
    Else
        ' Handle an array with 16 bit values
        Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDU": B$ = "#_ArrayStr_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
        A$ = "JSR": B$ = "ArrayGetAddress16bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
    End If
End If
x = x + 1: v = Array(x): x = x + 1
If v <> &H3D Then Print "Syntax error13, looking for = sign in";: GoTo FoundError
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
' ,S now has the string we want to store
' After that is the location in memory to store the number
A$ = "PULS": B$ = "B": C$ = "B = length of the source string": GoSub AO
A$ = "CLRA": C$ = "Make D = 16 bit unsigned version of B": GoSub AO
A$ = "LDX": B$ = "D,S": C$ = "Get address to store value in the array off the stack": GoSub AO
A$ = "STB": B$ = ",X+": C$ = "Set the size of the destination string, X now points at the beginning of the destination data": GoSub AO
A$ = "BEQ": B$ = "Done@": C$ = "If the length of the string is zero then don't copy it (Skip ahead)": GoSub AO
Z$ = "!"
A$ = "LDA": B$ = ",S+": C$ = "Get a source byte": GoSub AO
A$ = "STA": B$ = ",X+": C$ = "Write the destination byte": GoSub AO
A$ = "DECB": C$ = "Decrement the counter": GoSub AO
A$ = "BNE": B$ = "<": C$ = "Loop until all data is copied to the destination string": GoSub AO
Z$ = "Done@": GoSub AO
A$ = "LEAS": B$ = "2,S": C$ = "Fix the stack": GoSub AO
Print #1, "" ' Leave a space between sections so Done@ will work for each section
Return

HandleNumericArray:
If Verbose > 3 Then Print "Going to deal with Numeric array"
v = Array(x) * 256 + Array(x + 1): x = x + 2
NumBits = NumericArrayBits(v)
Z$ = "; NumBits=" + Str$(NumBits): GoSub AO
InsideArrayType = NumericArrayBits(v)
If NumBits = 8 Then
    InsideArrayType = NT_UByte ' use 8-bit unsigned indices
Else
    InsideArrayType = NT_UInt16 ' use 16-bit unsigned indices
End If
NV$ = NumericArrayVariables$(v)
If Verbose > 3 Then Print "Numeric array variable is: "; NV$
NumDims = Array(x): x = x + 1
NVTArrayType = Array(x): x = x + 1 ' NVT1=Numeric Array Variable Type
x = x + 2 ' Consume the $F5 & open bracket
If Verbose > 3 Then Print "Number of dimensons with this array:"; NumDims
' Get all the dimensions
DimCounter = NumDims
Z$ = "; Before dims - InsideArrayType=" + Str$(InsideArrayType): GoSub AO
While DimCounter > 1
    GoSub GetExpressionB4Comma: x = x + 2 ' Get the value to parse that is before the comma "," and move past it
    GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
    NVT = InsideArrayType
    Z$ = "; InsideArrayType(NVT)=" + Str$(InsideArrayType): GoSub AO
    Z$ = "; LastType=" + Str$(LastType): GoSub AO
    GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
    DimCounter = DimCounter - 1
Wend
GoSub GetExpressionMidB4EndBracket: x = x + 2 ' Get the expression that ends with a close bracket & move past it
GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
NVT = InsideArrayType
GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
' We now have:
' NV$=NumArrayName
' Value in brackets is on the stack
' NumBits = number of bits (8 or 16)
' NumDims = Number of dimensions
If NumDims = 1 And NVTArrayType < 5 Then
    ' This is a quick and easy location to calc and store
    A$ = "PULS": B$ = "B": C$ = "Array pointer, Fix the stack": GoSub AO
    A$ = "LDX": B$ = "#_ArrayNum_" + NV$ + "+1": C$ = "The array starts here": GoSub AO
    A$ = "ABX": C$ = "Make X point at the array location": GoSub AO
    A$ = "PSHS": B$ = "X": C$ = "Save the location to store the value": GoSub AO
Else
    ' A = BytesPerEntry
    ' B = Number of Array Dimensions
    ' X = Array starts here (points at the sizes of each dimension)
    Select Case NVTArrayType
        Case Is < 5
            Num = 1
        Case 5, 6
            Num = 2
        Case 7, 8
            Num = 4
        Case 9, 10
            Num = 8
        Case 11
            Num = 3
        Case 12
            Num = 10
    End Select
    GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    Temp$ = Num$
    If NumDims = 1 Then
        If NumBits = 8 Then
            ' Handle an array with 8 bit indices
            Z$ = "; Only 8 bit indices": GoSub AO
            A$ = "LDA": B$ = "#" + Temp$: C$ = "A = BytesPerEntry": GoSub AO
            A$ = "PULS": B$ = "B": C$ = "get d1, fix the stack": GoSub AO
            A$ = "MUL": C$ = "Multiply them": GoSub AO
            Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            A$ = "ADDD": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
            A$ = "PSHS": B$ = "D": C$ = "Save the location the array is pointing at on the stack": GoSub AO
        Else
            ' Handle an array with 16 bit indices
            Z$ = "; Only 1 16 bit element array": GoSub AO
            Z$ = "; d1 is already on the stack": GoSub AO
            A$ = "LDD": B$ = "#" + Temp$: C$ = "D = BytesPerEntry": GoSub AO
            A$ = "PSHS": B$ = "D": C$ = "Save BytesPerEntry as 16 bit on the stack": GoSub AO
            A$ = "JSR": B$ = "MUL16": C$ = "16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits": GoSub AO
            A$ = "LDD": B$ = ",S": C$ = "Get the low 16 bit result in D, fix the stack": GoSub AO
            Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            A$ = "ADDD": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "Add the array data start location": GoSub AO
            A$ = "STD": B$ = ",S": C$ = "Save the location the array is pointing at": GoSub AO
        End If
    Else
        Num = NumDims - 1: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
        A$ = "LDD": B$ = "#" + Temp$ + "*$100+" + Num$: C$ = "A = BytesPerEntry, B = Dim count-1": GoSub AO
        If NumBits = 8 Then
            ' Handle an array with 8 bit indices
            Num = NumDims: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            A$ = "LDU": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
            A$ = "JSR": B$ = "ArrayGetAddress8bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
        Else
            ' Handle an array with 16 bit indices
            Num = NumDims * 2: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
            A$ = "LDU": B$ = "#_ArrayNum_" + NV$ + "+" + Num$: C$ = "This array data starts here": GoSub AO
            A$ = "JSR": B$ = "ArrayGetAddress16bit": C$ = "Get the address to store the value and save it on the stack": GoSub AO
        End If
    End If
End If

x = x + 1: v = Array(x): x = x + 1
If v <> &H3D Then Print "Syntax error13, looking for = sign in";: GoTo FoundError
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
NVT = NVTArrayType
GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
' ,S now has the number we want to store
' After that is the location in memory to store the number
If NumDims = 1 And NVTArrayType < 5 Then
    ' This is a quick and easy location to calc and store
    A$ = "PULS": B$ = "B": C$ = "Number to store in array": GoSub AO
    A$ = "STB": B$ = "[,S++]": C$ = "Save the byte and fix the stack": GoSub AO
    Return
Else
    ' Calculate Number of bytes needed for this type of number on the stack
    Select Case NVTArrayType
        Case Is < 5
            Num = 1
        Case 5, 6
            Num = 2
        Case 7, 8
            Num = 4
        Case 9, 10
            Num = 8
        Case 11
            Num = 3
        Case 12
            Num = 10
    End Select
    GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
    A$ = "LDB": B$ = "#" + Num$: C$ = "B = Number of bytes to copy off the stack to location after the number": GoSub AO ' X points at the 2nd array Element size
    A$ = "LDX": B$ = "B,S": C$ = "Get address to store value in the array off the stack": GoSub AO
    Z$ = "!": A$ = "LDA": B$ = ",S+": C$ = "A = Source byte, move stack": GoSub AO
    A$ = "STA": B$ = ",X+": C$ = "Save byte into the array": GoSub AO
    A$ = "DECB": C$ = "Decrement the counter": GoSub AO
    A$ = "BNE": B$ = "<": C$ = "Loop": GoSub AO
    A$ = "LEAS": B$ = "2,S": C$ = "move past array store loaction": GoSub AO
    Return
End If

' Load a numeric variable with the value
HandleNumericVariable:
v = Array(x) * 256 + Array(x + 1): x = x + 2
NV$ = "_Var_" + NumericVariable$(v)
If Verbose > 3 Then Print "Numeric variable is: "; NV$
NVT1 = Array(x): x = x + 1 ' NVT1=Numeric Variable Type
v = Array(x): x = x + 1
If v <> TK_OperatorCommand Then Print "Syntax error12, looking for = sign in";: GoTo FoundError
v = Array(x): x = x + 1
If v <> &H3D Then Print "Syntax error13, looking for = sign in";: GoTo FoundError
GoSub GetExpressionB4EOL ' Get the expression before an End of Line in Expression$
GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
NVT = NVT1
GoSub ConvertLastType2NVT ' Convert LastType @,S to (Numeric Variable Type) NVT @S, will only change it, if they differ
Select Case NVT
    Case Is < 5 ' One byte variable
        A$ = "PULS": B$ = "B": C$ = "Get value off the stack, fix the stack": GoSub AO
        A$ = "STB": B$ = NV$: C$ = "Save Numeric variable": GoSub AO
    Case 5, 6 ' Two byte variable
        A$ = "PULS": B$ = "D": C$ = "Get value off the stack, fix the stack": GoSub AO
        A$ = "STD": B$ = NV$: C$ = "Save Numeric variable": GoSub AO
    Case 7, 8 ' 4 byte variable
        A$ = "PULS": B$ = "D,X": C$ = "Get the 4 byte value off the stack, fix the stack": GoSub AO
        A$ = "STD": B$ = NV$: C$ = "Save Numeric variable": GoSub AO
        A$ = "STX": B$ = NV$ + "+2": C$ = "Save Numeric variable": GoSub AO
    Case 9, 10 ' 8 byte variable
        A$ = "PULS": B$ = "D,X,Y,U": C$ = "Get the 8 byte value off the stack, fix the stack": GoSub AO
        A$ = "STU": B$ = NV$ + "+6": C$ = "Save Numeric variable": GoSub AO
        A$ = "LDU": B$ = "#" + NV$ + "+6": C$ = "Address to save variable": GoSub AO
        A$ = "PSHU": B$ = "D,X,Y": C$ = "Blast Numeric variable": GoSub AO
    Case 11 ' 3 byte variable
        A$ = "PULS": B$ = "B,X": C$ = "Get the 3 byte Fast Float value off the stack, fix the stack": GoSub AO
        A$ = "STB": B$ = NV$: C$ = "Save Numeric variable": GoSub AO
        A$ = "STX": B$ = NV$ + "+1": C$ = "Save Numeric variable": GoSub AO
    Case 12 ' 10 byte variable
        A$ = "PULS": B$ = "D,X,Y,U": C$ = "Pull the first 8 bytes off the stack": GoSub AO
        A$ = "STU": B$ = NV$ + "+6": C$ = "Save U at destination address + 6": GoSub AO
        A$ = "LDU": B$ = "#" + NV$ + "+6": C$ = "U points at the start of the destination location": GoSub AO
        A$ = "PSHU": B$ = "D,X,Y": C$ = "Save the 6 bytes of data at the start of destination": GoSub AO
        A$ = "PULS": B$ = "D": C$ = "Pull the last 2 bytes off the stack": GoSub AO
        A$ = "STD": B$ = "8,U": C$ = "Save the last bytes at the destination": GoSub AO
End Select
Return
