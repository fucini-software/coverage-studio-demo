' @file Timesheet.vb
' @brief Overtime rules of the Visual Basic coverage sample.
' @author Mario Fucini
' @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
'            License; see the LICENSE file in the repository root.

''' <summary>What kind of day a shift was worked on.</summary>
Public Enum DayKind
    ''' <summary>Monday to Friday.</summary>
    Weekday
    ''' <summary>Saturday.</summary>
    Saturday
    ''' <summary>Sunday.</summary>
    Sunday
    ''' <summary>A public holiday, whatever day of the week it falls on.</summary>
    Holiday
End Enum

''' <summary>
''' Overtime rules of the Visual Basic coverage sample.
''' </summary>
''' <remarks>
''' The sample for what is Visual Basic's own: <c>Select Case</c> with ranges,
''' <c>AndAlso</c> beside <c>And</c>, and the <c>If()</c> operator beside the
''' <c>IIf</c> function. Each pair looks alike in the source and is not alike
''' to a coverage tool, and the members below say how.
''' </remarks>
Public Module Timesheet

    ''' <summary>Hours worked beyond the contract.</summary>
    ''' <param name="worked">Hours worked in the week.</param>
    ''' <param name="contract">Hours the contract asks for.</param>
    ''' <returns>The overtime, never below zero.</returns>
    ''' <remarks>Fully tested: a week over, a week under, a week exactly on the contract.</remarks>
    Public Function OvertimeHours(worked As Decimal, contract As Decimal) As Decimal
        If worked <= contract Then
            Return 0D
        End If
        Return worked - contract
    End Function

    ''' <summary>What an overtime hour is paid at, as a multiple of the hourly wage.</summary>
    ''' <param name="day">The kind of day.</param>
    ''' <param name="hour">The hour of the day the overtime hour began, 0 to 23.</param>
    ''' <returns>The multiplier.</returns>
    ''' <remarks>
    ''' A <c>Select Case</c> inside a <c>Select Case</c>, the inner one over ranges. The
    ''' suite works weekdays and one Saturday, never a Sunday or a holiday, and
    ''' never past ten in the evening.
    ''' </remarks>
    Public Function Multiplier(day As DayKind, hour As Integer) As Decimal
        Select Case day
            Case DayKind.Weekday
                Select Case hour
                    Case 6 To 19
                        Return 1.25D
                    Case 20 To 21
                        Return 1.5D
                    Case Else
                        Return 2D
                End Select
            Case DayKind.Saturday
                Return 1.5D
            Case DayKind.Sunday
                Return 2D
            Case Else
                Return 2.5D
        End Select
    End Function

    ''' <summary>Whether a shift counts as a night shift.</summary>
    ''' <param name="startHour">The hour the shift began, 0 to 23.</param>
    ''' <param name="endHour">The hour the shift ended, 0 to 23.</param>
    ''' <returns>True when it began late or ended early.</returns>
    ''' <remarks>
    ''' <c>OrElse</c> stops at the first operand that decides, and compiles to a
    ''' branch: the suite only ever starts late, so the second comparison never
    ''' runs and the line is half taken.
    ''' </remarks>
    Public Function IsNightShift(startHour As Integer, endHour As Integer) As Boolean
        Return startHour >= 22 OrElse endHour <= 6
    End Function

    ''' <summary>The same question as <see cref="IsNightShift"/>, asked with <c>Or</c>.</summary>
    ''' <param name="startHour">The hour the shift began, 0 to 23.</param>
    ''' <param name="endHour">The hour the shift ended, 0 to 23.</param>
    ''' <returns>True when it began late or ended early.</returns>
    ''' <remarks>
    ''' <c>Or</c> evaluates both operands always, and compiles to no branch at
    ''' all: the same tests leave this line fully covered. Nothing was tested
    ''' better; there is only less for a tool to see.
    ''' </remarks>
    Public Function IsNightShiftEager(startHour As Integer, endHour As Integer) As Boolean
        Return startHour >= 22 Or endHour <= 6
    End Function

    ''' <summary>The meal allowance for a shift.</summary>
    ''' <param name="hours">How long the shift was.</param>
    ''' <returns>The allowance, in the currency of the wage.</returns>
    ''' <remarks>
    ''' The <c>If()</c> operator is a branch, and the suite only ever works long
    ''' shifts: half taken.
    ''' </remarks>
    Public Function MealAllowance(hours As Decimal) As Decimal
        Return If(hours >= 8D, 12.5D, 0D)
    End Function

    ''' <summary>The same allowance as <see cref="MealAllowance"/>, written with <c>IIf</c>.</summary>
    ''' <param name="hours">How long the shift was.</param>
    ''' <returns>The allowance, in the currency of the wage.</returns>
    ''' <remarks>
    ''' <c>IIf</c> is a function: both results are computed before it chooses, so
    ''' there is no branch and the line is covered whichever way it went.
    ''' </remarks>
    Public Function MealAllowanceEager(hours As Decimal) As Decimal
        Return CDec(IIf(hours >= 8D, 12.5D, 0D))
    End Function

    ''' <summary>What a week pays before tax.</summary>
    ''' <param name="wage">The hourly wage.</param>
    ''' <param name="worked">Hours worked in the week.</param>
    ''' <param name="contract">Hours the contract asks for.</param>
    ''' <param name="day">The kind of day the overtime fell on.</param>
    ''' <param name="hour">The hour the overtime began.</param>
    ''' <returns>The gross pay.</returns>
    ''' <exception cref="ArgumentOutOfRangeException">The wage or the hours are negative.</exception>
    ''' <remarks>The guards are never tried: the suite pays nobody a negative wage.</remarks>
    Public Function Gross(wage As Decimal, worked As Decimal, contract As Decimal, day As DayKind, hour As Integer) As Decimal
        If wage < 0D Then
            Throw New ArgumentOutOfRangeException(NameOf(wage))
        End If
        If worked < 0D OrElse contract < 0D Then
            Throw New ArgumentOutOfRangeException(NameOf(worked))
        End If

        Dim overtime = OvertimeHours(worked, contract)
        Dim regular = worked - overtime
        Return regular * wage + overtime * wage * Multiplier(day, hour)
    End Function

    ''' <summary>One line of the export to the payroll office.</summary>
    ''' <param name="employee">The employee's number.</param>
    ''' <param name="gross">What the week pays.</param>
    ''' <returns>Number and amount, separated by a semicolon.</returns>
    ''' <remarks>Never called by any test, on purpose: the dead-code entry.</remarks>
    Public Function ExportLine(employee As Integer, gross As Decimal) As String
        Return employee.ToString("D6") & ";" & gross.ToString("F2", Globalization.CultureInfo.InvariantCulture)
    End Function

End Module
