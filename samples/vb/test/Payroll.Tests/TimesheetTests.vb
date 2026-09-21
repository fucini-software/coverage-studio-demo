' @file TimesheetTests.vb
' @brief The test suite of the Visual Basic sample.
' @author Mario Fucini
' @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
'            License; see the LICENSE file in the repository root.

Imports Xunit

''' <summary>
''' The test suite of the Visual Basic sample. What it leaves untested is
''' deliberate, and is documented on the member it belongs to, in Timesheet.vb.
''' </summary>
Public Class TimesheetTests

    ''' <summary>A week over the contract, a week under it, a week exactly on it.</summary>
    <Theory>
    <InlineData(45, 40, 5)>
    <InlineData(32, 40, 0)>
    <InlineData(40, 40, 0)>
    Public Sub Overtime_is_what_exceeds_the_contract(worked As Integer, contract As Integer, expected As Integer)
        Assert.Equal(CDec(expected), OvertimeHours(worked, contract))
    End Sub

    ''' <summary>Weekdays by day and in the evening, and one Saturday. Never a Sunday, a holiday or a night.</summary>
    <Fact>
    Public Sub Multiplier_follows_the_day_and_the_hour()
        Assert.Equal(1.25D, Multiplier(DayKind.Weekday, 17))
        Assert.Equal(1.5D, Multiplier(DayKind.Weekday, 20))
        Assert.Equal(1.5D, Multiplier(DayKind.Saturday, 10))
    End Sub

    ''' <summary>Only ever a shift that starts late: the first operand always decides.</summary>
    <Fact>
    Public Sub A_shift_that_starts_late_is_a_night_shift()
        Assert.True(IsNightShift(22, 6))
        Assert.True(IsNightShiftEager(22, 6))
    End Sub

    ''' <summary>Only ever a long shift.</summary>
    <Fact>
    Public Sub A_long_shift_earns_a_meal()
        Assert.Equal(12.5D, MealAllowance(9))
        Assert.Equal(12.5D, MealAllowanceEager(9))
    End Sub

    ''' <summary>One honest week: forty hours and five more on a weekday evening.</summary>
    <Fact>
    Public Sub Gross_pays_overtime_at_its_multiplier()
        ' 40 h at 20.00, and 5 h at 20.00 x 1.5
        Assert.Equal(950D, Gross(20D, 45D, 40D, DayKind.Weekday, 20))
    End Sub

End Class
