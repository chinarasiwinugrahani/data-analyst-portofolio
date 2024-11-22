Attribute VB_Name = "Module1"
Sub ageinput()
Dim answer As String
Dim age As Variant 'Allow age to handle both text and numeric values
Dim lastRow As Long 'Allow lastRow to handle long range

'Display a message box with yes or no options
answer = MsgBox("Do you want to enter an age?", vbYesNo + vbQuestion, "Age Information")
lastRow = Cells(Rows.Count, "C").End(xlUp).Row

'Check the user's response
If answer = vbYes Then
   age = InputBox("Please enter your age:", "Age Input")
   'Ensure no non-numeric or empty inputs
   If Trim(age) = "" Or Not IsNumeric(age) Then
      MsgBox "Invalid input. Please enter a numeric value.", vbExclamation, "Age Confirmation"
   'Convert value to integer
   Else
      Range("C" & lastRow + 1).Value = CInt(age)
   End If
End If
End Sub

