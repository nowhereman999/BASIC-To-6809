'$Include:'60_HelperRoutines.bas'
PrintInQuotes:
Return


DoInput:
PrintD$ = "PRINT_D": PrintA$ = "PrintA_On_Screen": PrintDev$ = " on screen" ' Make sure we are printing on the text screen
PrintCC3 = 0
v = Array(x): x = x + 1
ShowInputCount = ShowInputCount + 1
Num = ShowInputCount: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$
ShowInputText$ = "ShowInputText" + Num$
Print #1, ShowInputText$; ":"
If v = &HF5 And Array(x) = &H22 Then ' Printing characters in quotes, PRINT "HELLO"
    x = x + 1
    GoSub PrintInQuotes ' Prints in quotes, x points after the end quote
    x = x + 1: v = Array(x): x = x + 1 ' get the semi-colon
    If v <> Asc(";") Then Print "Error, should have a semi-colon after the text in";: GoTo FoundError
Else
    v = 0: x = x - 1
End If
' Figure out if we have commas for the user input so they can input them all on one line as 5,3,12 <ENTER>  or hit ENTER after each individual number
Start = x
count = 0
Brackets = 0
Do Until Array(x) = &HF5 And (Array(x + 1) = &H0D Or Array(x + 1) = &H3A) ' loop until the end of the line or colon
    If Array(x) = &HF5 And Array(x + 1) = Asc("(") Then Brackets = Brackets + 1: x = x + 1
    If Array(x) = &HF5 And Array(x + 1) = Asc(")") Then Brackets = Brackets - 1: x = x + 1
    If Array(x) = &HF5 And Array(x + 1) = Asc(",") Then
        x = x + 1
        If Brackets = 0 Then count = count + 1
    End If
    x = x + 1
Loop
Num = count: GoSub NumAsString 'Convert number in Num to a string without spaces as Num$
If Num < 10 Then Num$ = "0" + Num$
A$ = "LDA": B$ = "#" + Num$: C$ = "Save the number of commas needed": GoSub AO
A$ = "STA": B$ = "CommaCount": C$ = "Save the number of commas to look for": GoSub AO
x = Start

' Fill the KeyBuff from user input, it will be terminated with a comma
A$ = "JSR": B$ = "GetInput": C$ = "Show ? and get user input in _StrVar_PF00, U points to the end of the buffer, B has # of characters that were input": GoSub AO
A$ = "LDU": B$ = "#_StrVar_PF00": C$ = "U = source starts address": GoSub AO
If count = 0 Then
    ' No commas, just one entry for this INPUT command
    v = Array(x): x = x + 1 ' Get the type of variable
    If v < &HF0 And v > &HF3 Then Print "Error, can't figure out the INPUT variable in";: GoTo FoundError
    ' We got the Enter Key, figure out how to copy the number or string to the variable
    If v = &HF0 Or v = &HF2 Then ' We are getting a numeric value
        ' Make sure buffer is a numeric value between 0 and 65536
        ' Get our numeric variable location
        ' Convert buffer to a number
        Print #1, ' Leave a blank so @ labels work properly
        A$ = "LDX": B$ = "#DecNumber": C$ = "X points at the start of the table of data to grab each time": GoSub AO
        A$ = "CLRB": GoSub AO
        Z$ = "!"
        A$ = "INCB": GoSub AO
        A$ = "CMPB": B$ = "#7": C$ = "Check the number of decimal places": GoSub AO
        A$ = "BHI": B$ = "@NotANumber": C$ = "If more than 7 then we have a problem": GoSub AO
        A$ = "LDA": B$ = ",U+": GoSub AO
        A$ = "STA": B$ = ",X+": C$ = "Add it to the end of the buffer": GoSub AO
        A$ = "CMPA": B$ = "#',": C$ = "Did we find a comma?": GoSub AO
        A$ = "BNE": B$ = "<": GoSub AO
        A$ = "CLR": B$ = "-1,X": C$ = "flag last byte as 0, so we know that we have reached the end of the string": GoSub AO
        A$ = "JSR": B$ = "DecToD": C$ = "Convert the string in the buffer to a number": GoSub AO
        A$ = "BEQ": B$ = ">": C$ = "Skip forward if conversion went well": GoSub AO
        Z$ = "@NotANumber": GoSub AO
        A$ = "JSR": B$ = "ShowREDO": C$ = "Show ?REDO on screen": GoSub AO
        A$ = "BRA": B$ = ShowInputText$: C$ = "Show input text, if there was some and get the input again": GoSub AO
        Z$ = "!": C$ = "D now has the converted number :)": GoSub AO
        Print #1, ' Leave a blank so @ labels work properly
        If v = &HF2 Then
            ' We are inputting a numeric value
            v = Array(x) * 256 + Array(x + 1): x = x + 2
            NumType = Array(x): x = x + 1 ' Get the numeric Type
            Select Case NumType:
                Case 1, 2, 3, 4 ' 8 bit integer
                    A$ = "LDX": B$ = "#DecNumber": C$ = "X points at the start of the table of data to grab each time": GoSub AO
                    A$ = "CLRB": GoSub AO
                    Z$ = "!"
                    A$ = "INCB": GoSub AO
                    A$ = "CMPB": B$ = "#5": C$ = "Check the number of decimal places": GoSub AO
                    A$ = "BHI": B$ = "@NotANumber": C$ = "If more than 7 then we have a problem": GoSub AO
                    A$ = "LDA": B$ = ",U+": GoSub AO
                    A$ = "STA": B$ = ",X+": C$ = "Add it to the end of the buffer": GoSub AO
                    A$ = "CMPA": B$ = "#',": C$ = "Did we find a comma?": GoSub AO
                    A$ = "BNE": B$ = "<": GoSub AO
                    A$ = "CLR": B$ = "-1,X": C$ = "flag last byte as 0, so we know that we have reached the end of the string": GoSub AO
                    A$ = "JSR": B$ = "DecToD": C$ = "Convert the string in the buffer to a number": GoSub AO
                    A$ = "BEQ": B$ = ">": C$ = "Skip forward if conversion went well": GoSub AO
                    Z$ = "@NotANumber": GoSub AO
                    A$ = "JSR": B$ = "ShowREDO": C$ = "Show ?REDO on screen": GoSub AO
                    A$ = "BRA": B$ = ShowInputText$: C$ = "Show input text, if there was some and get the input again": GoSub AO
                    Z$ = "!": C$ = "D now has the converted number :)": GoSub AO
                    A$ = "STB": B$ = "_Var_" + NumericVariable$(v): C$ = "Save B in variable location": GoSub AO
                Case 5, 6 ' 16 bit integer
                    A$ = "LDX": B$ = "#DecNumber": C$ = "X points at the start of the table of data to grab each time": GoSub AO
                    A$ = "CLRB": GoSub AO
                    Z$ = "!"
                    A$ = "INCB": GoSub AO
                    A$ = "CMPB": B$ = "#7": C$ = "Check the number of decimal places": GoSub AO
                    A$ = "BHI": B$ = "@NotANumber": C$ = "If more than 7 then we have a problem": GoSub AO
                    A$ = "LDA": B$ = ",U+": GoSub AO
                    A$ = "STA": B$ = ",X+": C$ = "Add it to the end of the buffer": GoSub AO
                    A$ = "CMPA": B$ = "#',": C$ = "Did we find a comma?": GoSub AO
                    A$ = "BNE": B$ = "<": GoSub AO
                    A$ = "CLR": B$ = "-1,X": C$ = "flag last byte as 0, so we know that we have reached the end of the string": GoSub AO
                    A$ = "JSR": B$ = "DecToD": C$ = "Convert the string in the buffer to a number": GoSub AO
                    A$ = "BEQ": B$ = ">": C$ = "Skip forward if conversion went well": GoSub AO
                    Z$ = "@NotANumber": GoSub AO
                    A$ = "JSR": B$ = "ShowREDO": C$ = "Show ?REDO on screen": GoSub AO
                    A$ = "BRA": B$ = ShowInputText$: C$ = "Show input text, if there was some and get the input again": GoSub AO
                    Z$ = "!": C$ = "D now has the converted number :)": GoSub AO
                    A$ = "STD": B$ = "_Var_" + NumericVariable$(v): C$ = "Save D in variable location": GoSub AO
                Case 7, 8 ' 32 bit integer

                Case 9, 10 ' 64 bit integer

                Case 11 ' FFP format
                    A$ = "JSR": B$ = "ASCII_To_FFP": C$ = "Convert ASCII text @X to a FFP number @,S": GoSub AO
                    A$ = "PULS": B$ = "B,X": C$ = "pull 3 bytes off the stack": GoSub AO
                    A$ = "LDU": B$ = "#_Var_" + NumericVariable$(v) + "+3": C$ = "U points to Variable +3": GoSub AO
                    A$ = "PSHU": B$ = "B,X": C$ = "store B,X": GoSub AO
                Case 12 ' Double format

            End Select

        Else
            ' We are inputting a numeric array
            Print #1, "; Getting the numeric array memory location in X"
            GoSub MakeXPointAtNumericArray ' Enter array() pointing at the Numeric Array Name, Returns with X pointing at the memory location for the Numeric Array, D is unchanged
            A$ = "STD": B$ = ",X": C$ = "Store the number where X points": GoSub AO
            Print "Found something": System
        End If



    Else
        If v = &HF1 Or v = &HF3 Then ' We are getting a string value
            ' B = length of the string
            ' #KeyBuff = start of the keyboard input buffer
            If v = &HF3 Then
                ' We are inputting a string variable
                v = Array(x) * 256 + Array(x + 1): x = x + 2
                Print #1, ""
                A$ = "LDX": B$ = "#_StrVar_" + StringVariable$(v): C$ = "X = destination address": GoSub AO
            Else
                ' We are inputting a string array
                Print #1, "; Getting the String array memory location in X"
                GoSub MakeXPointAtStringArray ' Enter array() pointing at the String Array Name, Returns with X pointing at the memory location for the String Array, D is unchanged
            End If
            A$ = "PSHS": B$ = "X": C$ = "Save X on the stack": GoSub AO
            A$ = "LEAX": B$ = "1,X": C$ = "Move X so it starts at the correct location": GoSub AO
            A$ = "CLRB": C$ = "Clear the counter": GoSub AO
            Z$ = "!"
            A$ = "INCB": C$ = "Increment the counter": GoSub AO
            A$ = "LDA": B$ = ",U+": GoSub AO
            A$ = "STA": B$ = ",X+": C$ = "Add it to the end of the buffer": GoSub AO
            A$ = "CMPA": B$ = "#',": C$ = "Did we find a comma?": GoSub AO
            A$ = "BNE": B$ = "<": GoSub AO
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "STB": B$ = "[,S++]": C$ = "Save the length of the string and fix the stack": GoSub AO
        Else
            Print "Error, can't figure out the INPUT variable in";: GoTo FoundError
        End If
    End If
    ' Check for a comma or end of line $0D
    v = Array(x): x = x + 1
    If v <> &HF5 And Array(x) <> &H0D And Array(x) <> &H3A Then Print "Error, with the INPUT command, it didn't end properly in";: GoTo FoundError
    v = Array(x): x = x + 1
    Return 'Done with the INPUT command
End If

' There are commas on the INPUT line handle it a little differently
v = Array(x)
Do Until v = &HF5 And (Array(x) = &H0D Or Array(x) = &H3A)
    v = Array(x): x = x + 1 ' Get the type of variable
    If v < &HF0 And v > &HF3 Then Print "Error, can't figure out the INPUT variable in";: GoTo FoundError
    ' We got the Enter Key, figure out how to copy the number or string to the variable
    If v = &HF0 Or v = &HF2 Then ' We are getting a numeric value
        ' Make sure buffer is a numeric value between 0 and 65536
        ' Get our numeric variable location
        ' Convert buffer to a number
        ' Check if input number has too many digits
        Print #1, ' Leave a blank so @ labels work properly
        A$ = "LDX": B$ = "#DecNumber": C$ = "X points at the start of the table of data to grab each time": GoSub AO
        A$ = "CLRB": GoSub AO
        Z$ = "!"
        A$ = "INCB": GoSub AO
        A$ = "CMPB": B$ = "#7": C$ = "Check the number of decimal places": GoSub AO
        A$ = "BHI": B$ = "@NotANumber": C$ = "If more than 7 then we have a problem": GoSub AO
        A$ = "LDA": B$ = ",U+": GoSub AO
        A$ = "STA": B$ = ",X+": C$ = "Add it to the end of the buffer": GoSub AO
        A$ = "CMPA": B$ = "#',": C$ = "Did we find a comma?": GoSub AO
        A$ = "BNE": B$ = "<": GoSub AO
        A$ = "CLR": B$ = "-1,X": C$ = "flag last byte as 0, so we know that we have reached the end of the string": GoSub AO
        A$ = "JSR": B$ = "DecToD": C$ = "Convert the string in the buffer to a number": GoSub AO
        A$ = "BEQ": B$ = ">": C$ = "Skip forward if conversion went well": GoSub AO
        Z$ = "@NotANumber": GoSub AO
        A$ = "JSR": B$ = "ShowREDO": C$ = "Show ?REDO on screen": GoSub AO
        A$ = "BRA": B$ = ShowInputText$: C$ = "Show input text, if there was some and get the input again": GoSub AO
        Z$ = "!"
        C$ = "D now has the converted number :)": GoSub AO
        Print #1, ' Leave a blank so @ labels work properly
        If v = &HF2 Then
            ' We are inputting a numeric value
            v = Array(x) * 256 + Array(x + 1): x = x + 2
            A$ = "STD": B$ = "_Var_" + NumericVariable$(v): C$ = "Save D in variable location": GoSub AO
        Else
            ' We are inputting a numeric array
            Print #1, "; Getting the numeric array memory location in X"
            GoSub MakeXPointAtNumericArray ' Enter array() pointing at the Numeric Array Name, Returns with X pointing at the memory location for the Numeric Array, D is unchanged
            A$ = "STD": B$ = ",X": C$ = "Store the number where X points": GoSub AO
        End If
    Else
        If v = &HF1 Or v = &HF3 Then ' We are getting a string value
            ' B = length of the string
            ' #KeyBuff = start of the keyboard input buffer
            If v = &HF3 Then
                ' We are inputting a string variable
                v = Array(x) * 256 + Array(x + 1): x = x + 2
                A$ = "LDX": B$ = "#_StrVar_" + StringVariable$(v): C$ = "X = destination address": GoSub AO
            Else
                ' We are inputting a string array
                Print #1, "; Getting the String array memory location in X"
                GoSub MakeXPointAtStringArray ' Enter array() pointing at the String Array Name, Returns with X pointing at the memory location for the String Array, D is unchanged
            End If
            A$ = "PSHS": B$ = "X": C$ = "Save X on the stack": GoSub AO
            A$ = "LEAX": B$ = "1,X": C$ = "Move X so it starts at the correct location": GoSub AO
            A$ = "CLRB": C$ = "Clear the counter": GoSub AO
            Z$ = "!"
            A$ = "INCB": C$ = "Increment the counter": GoSub AO
            A$ = "LDA": B$ = ",U+": GoSub AO
            A$ = "STA": B$ = ",X+": C$ = "Add it to the end of the buffer": GoSub AO
            A$ = "CMPA": B$ = "#',": C$ = "Did we find a comma?": GoSub AO
            A$ = "BNE": B$ = "<": GoSub AO
            A$ = "DECB": C$ = "Decrement the counter": GoSub AO
            A$ = "STB": B$ = "[,S++]": C$ = "Save the length of the string and fix the stack": GoSub AO
        Else
            Print "Error, can't figure out the INPUT variable in";: GoTo FoundError
        End If
    End If
    ' Check for a comma or end of line $0D
    v = Array(x): x = x + 1 ' get the &HF5
    If Array(x) = &H2C Then v = Array(x): x = x + 1 ' if found then consume the comma
Loop
v = Array(x): x = x + 1
Return

' Returns with X pointing at the memory location for the Numeric Array, D is unchanged
MakeXPointAtNumericArray:
Z$ = "; Numeric Array": GoSub AO
Return

' Returns with X pointing at the memory location for the String Array, D is unchanged
MakeXPointAtStringArray:
Z$ = "; String Array": GoSub AO
Return

