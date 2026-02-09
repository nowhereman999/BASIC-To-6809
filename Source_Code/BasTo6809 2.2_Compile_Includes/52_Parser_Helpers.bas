
' Parse Number and return with value as Signed value in B
ParseNumericExpression_Byte:
' Parse Number and return with value as Unsigned value in B
ParseNumericExpression_UByte:
GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable

Select Case LastType 'Already in the correct format
    Case Is < NT_Int16 ' value is an 8 bit number, get B, then return
        A$ = "PULS": B$ = "B": C$ = "Get value in B and Fix the stack": GoSub AO
        Return
    Case NT_Int16 ' Ignore MSB of 16 bit value
        A$ = "PULS": B$ = "D": C$ = "Get value in B and Fix the stack": GoSub AO
        Return
    Case NT_UInt16 ' Ignore MSB of 16 bit value
        A$ = "PULS": B$ = "D": C$ = "Get value in B and Fix the stack": GoSub AO
        Return
    Case NT_Int32 ' Use LSB
        A$ = "LDB": B$ = "3,S": C$ = "Get value in B and Fix the stack": GoSub AO
        A$ = "LEAS": B$ = "4,S": C$ = "Fix the stack": GoSub AO
        Return
    Case NT_UInt32 ' Use LSB
        A$ = "LDB": B$ = "3,S": C$ = "Get value in B and Fix the stack": GoSub AO
        A$ = "LEAS": B$ = "4,S": C$ = "Fix the stack": GoSub AO
        Return
    Case NT_Int64 ' Use LSB
        A$ = "LDB": B$ = "7,S": C$ = "Get value in B and Fix the stack": GoSub AO
        A$ = "LEAS": B$ = "8,S": C$ = "Fix the stack": GoSub AO
        Return
    Case NT_UInt64 ' Use LSB
        A$ = "LDB": B$ = "7,S": C$ = "Get value in B and Fix the stack": GoSub AO
        A$ = "LEAS": B$ = "8,S": C$ = "Fix the stack": GoSub AO
        Return
    Case NT_Single ' Convert a FP number to D
        A$ = "JSR": B$ = "FFP_TO_S16": C$ = "Convert FFP at ,S to Signed 16 bit integer @ ,S": GoSub AO
        A$ = "PULS": B$ = "D": C$ = "Get value in D and fix the stack": GoSub AO
        Return
    Case NT_Double ' Convert a Double FP number to D
        A$ = "JSR": B$ = "DB_TO_S16": C$ = "Convert the Double @ ,S to Signed 16-bit Integer @ ,S": GoSub AO
        A$ = "PULS": B$ = "D": C$ = "Get value in D and fix the stack": GoSub AO
        Return
End Select
Return

' Parse Number and return with value as Signed value in D
ParseNumericExpression_Int16:
GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
Select Case LastType
    Case Is < NT_Int16 ' value is an 8 bit number, CLRA and get B, then return
        A$ = "PULS": B$ = "B": C$ = "Get value in B and Fix the stack": GoSub AO
        A$ = "SEX": C$ = "Sign extend B into A": GoSub AO
        Return
    Case NT_Int16 'Already in the correct format
        A$ = "PULS": B$ = "D": C$ = "Get value in D and Fix the stack": GoSub AO
        Return
    Case NT_UInt16 'Already in the correct format
        A$ = "PULS": B$ = "D": C$ = "Get value in D and Fix the stack": GoSub AO
        Return
    Case NT_Int32 ' Use LSW
        A$ = "LDD": B$ = "2,S": C$ = "Get LSW of 32 bit value in D": GoSub AO
        A$ = "LEAS": B$ = "4,S": C$ = "Fix the stack": GoSub AO
        Return
    Case NT_UInt32 ' Use LSW
        A$ = "LDD": B$ = "2,S": C$ = "Get LSW of 32 bit value in D": GoSub AO
        A$ = "LEAS": B$ = "4,S": C$ = "Fix the stack": GoSub AO
        Return
    Case NT_Int64 ' Use LSW
        A$ = "LDD": B$ = "6,S": C$ = "Get LSW of 64 bit value in D": GoSub AO
        A$ = "LEAS": B$ = "8,S": C$ = "Fix the stack": GoSub AO
        Return
    Case NT_UInt64 ' Use LSW
        A$ = "LDD": B$ = "6,S": C$ = "Get LSW of 64 bit value in D": GoSub AO
        A$ = "LEAS": B$ = "8,S": C$ = "Fix the stack": GoSub AO
        Return
    Case NT_Single ' Convert a Single number to D
        A$ = "JSR": B$ = "FFP_TO_S16": C$ = "Convert FFP at ,S to Signed 16 bit integer @ ,S": GoSub AO
        A$ = "PULS": B$ = "D": C$ = "Get value in D and fix the stack": GoSub AO
        Return
    Case NT_Double ' Convert a Double FP number to D
        A$ = "JSR": B$ = "DB_TO_S16": C$ = "Convert the Double @ ,S to Signed 16-bit Integer @ ,S": GoSub AO
        A$ = "PULS": B$ = "D": C$ = "Get value in D and fix the stack": GoSub AO
        Return
End Select
Return

' Parse Number and return with value as Unsigned value in D
ParseNumericExpression_UInt16:
GoSub ParseNumericExpression ' Parse Expression$ and return with value at ,S & Variable LastType with the datatype of that variable
Select Case LastType
    Case Is < NT_Int16 ' value is an 8 bit number, CLRA and get B, then return
        A$ = "CLRA": C$ = "Clear MSB of D": GoSub AO
        A$ = "PULS": B$ = "B": C$ = "Get value in B and Fix the stack": GoSub AO
        Return
    Case NT_Int16 'Already in the correct format
        A$ = "PULS": B$ = "D": C$ = "Get value in D and Fix the stack": GoSub AO
        Return
    Case NT_UInt16 'Already in the correct format
        A$ = "PULS": B$ = "D": C$ = "Get value in D and Fix the stack": GoSub AO
        Return
    Case NT_Int32 ' Use LSW
        A$ = "LDD": B$ = "2,S": C$ = "Get LSW of 32 bit value in D": GoSub AO
        A$ = "LEAS": B$ = "4,S": C$ = "Fix the stack": GoSub AO
        Return
    Case NT_UInt32 ' Use LSW
        A$ = "LDD": B$ = "2,S": C$ = "Get LSW of 32 bit value in D": GoSub AO
        A$ = "LEAS": B$ = "4,S": C$ = "Fix the stack": GoSub AO
        Return
    Case NT_Int64 ' Use LSW
        A$ = "LDD": B$ = "6,S": C$ = "Get LSW of 64 bit value in D": GoSub AO
        A$ = "LEAS": B$ = "8,S": C$ = "Fix the stack": GoSub AO
        Return
    Case NT_UInt64 ' Use LSW
        A$ = "LDD": B$ = "6,S": C$ = "Get LSW of 64 bit value in D": GoSub AO
        A$ = "LEAS": B$ = "8,S": C$ = "Fix the stack": GoSub AO
        Return
    Case NT_Single ' Convert a Single number to D
        A$ = "JSR": B$ = "FFP_TO_U16": C$ = "Convert FFP at ,S to Unsigned 16 bit integer @ ,S": GoSub AO
        A$ = "PULS": B$ = "D": C$ = "Get value in D and fix the stack": GoSub AO
        Return
    Case NT_Double ' Convert a Double FP number to D
        A$ = "JSR": B$ = "DB_TO_U16": C$ = "Convert Double at ,S to Unsigned 16 bit integer @ ,S": GoSub AO
        A$ = "PULS": B$ = "D": C$ = "Get value in D and fix the stack": GoSub AO
        Return
End Select
Return
