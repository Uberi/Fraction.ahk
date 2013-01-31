#NoEnv

/*
Copyright 2013 Anthony Zhang <azhang9@gmail.com>

This file is part of Fraction.ahk. Source code is available at <https://github.com/Uberi/Fraction.ahk>.

Fraction.ahk is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

;wip: make a system to work with fractions that have bigint components

class Fraction
{
    __New(Numerator = 0,Denominator = "")
    {
        this.Set(Numerator,Denominator)
    }

    Set(Numerator,Denominator = "")
    {
        If (Denominator = "")
        {
            If Numerator Is Number
                this.FromNumber(Numerator)
            Else
                this.FromString(Numerator)
        }
        Else
        {
            If Numerator Is Not Integer
                throw Exception("Invalid numerator: " . Numerator)
            If Denominator Is Not Integer
                throw Exception("Invalid denominator: " . Denominator)
            If Denominator = 0
                throw Exception("Invalid denominator: " . Denominator)
            this.Numerator := Numerator
            this.Denominator := Denominator
        }
        Return, this.Reduce()
    }

    FromNumber(Value,Error = 0.0001)
    {
        Loop
        {
            this.Denominator := A_Index
            this.Numerator := Round(Value * A_Index)
            If Abs((this.Numerator / this.Denominator) - Value) <= Error
                Break
        }
        Return, this
    }

    FromString(Value)
    {
        If !RegExMatch(Value,"S)^\s*(-?\d+)\s*/\s*(-?\d+)\s*$",Field)
            throw Exception("Invalid fraction string: " . Value)
        If Field2 = 0
            throw Exception("Invalid denominator: " . Field2)
        this.Numerator := Field1
        this.Denominator := Field2
        Return, this.Reduce()
    }

    Fast(Flag = True)
    {
        If Flag ;enable fast mode
        {
            If !this.HasKey("Fast")
            {
                StubReduce := this.StubReduce
                this.StubReduce := this.Reduce
                this.Reduce := StubReduce
                this.Fast := True
            }
        }
        Else ;disable fast mode
        {
            If this.HasKey("Fast")
            {
                Reduce := this.StubReduce
                this.StubReduce := this.Reduce
                this.Reduce := Reduce
                this.Remove("Fast")
            }
        }
        Return, this
    }

    StubReduce()
    {
        Return, this
    }

    GCD(Number1,Number2) ;greatest common denominator
    {
        While, Number2 != 0
        {
            Remainder := Mod(Number1,Number2)
            Temp1 := Abs(Remainder - Number2)
            Number1 := Number2, Number2 := (Remainder > Temp1) ? Temp1 : Remainder
        }
        Return, Number1
    }

    Reduce() ;reduce fraction to simplest form
    {
        Value := Abs(this.GCD(this.Numerator,this.Denominator))
        this.Numerator //= Value
        this.Denominator //= Value
        Return, this
    }

    ToNumber()
    {
        Return, this.Numerator / this.Denominator
    }

    ToString()
    {
        Return, this.Numerator . "/" . this.Denominator
    }

    Equal(Value)
    {
        Return, (this.Numerator * Value.Denominator) = (Value.Numerator * this.Denominator)
    }

    Less(Value)
    {
        If (this.Denominator < 0) ^ (Value.Denominator < 0) ;difference has negative denominator
            Return, (this.Numerator * Value.Denominator) > (Value.Numerator * this.Denominator)
        Else
            Return, (this.Numerator * Value.Denominator) < (Value.Numerator * this.Denominator)
    }

    LessOrEqual(Value)
    {
        If (this.Denominator < 0) ^ (Value.Denominator < 0) ;difference has negative denominator
            Return, (this.Numerator * Value.Denominator) >= (Value.Numerator * this.Denominator)
        Else
            Return, (this.Numerator * Value.Denominator) <= (Value.Numerator * this.Denominator)
    }

    Greater(Value)
    {
        If (this.Denominator < 0) ^ (Value.Denominator < 0) ;difference has negative denominator
            Return, (this.Numerator * Value.Denominator) < (Value.Numerator * this.Denominator)
        Else
            Return, (this.Numerator * Value.Denominator) > (Value.Numerator * this.Denominator)
    }

    GreaterOrEqual(Value)
    {
        If (this.Denominator < 0) ^ (Value.Denominator < 0) ;difference has negative denominator
            Return, (this.Numerator * Value.Denominator) <= (Value.Numerator * this.Denominator)
        Else
            Return, (this.Numerator * Value.Denominator) >= (Value.Numerator * this.Denominator)
    }

    Sign()
    {
        If this.Numerator = 0
            Return, 0
        If ((this.Numerator < 0) ^ (this.Denominator < 0))
            Return, -1
        Return, 1
    }

    Abs()
    {
        this.Numerator := Abs(this.Numerator)
        this.Denominator := Abs(this.Denominator)
        Return, this
    }

    Add(Value)
    {
        this.Numerator := (this.Numerator * Value.Denominator) + (Value.Numerator * this.Denominator)
        this.Denominator *= Value.Denominator
        Return, this.Reduce()
    }

    Subtract(Value)
    {
        this.Numerator := (this.Numerator * Value.Denominator) - (Value.Numerator * this.Denominator)
        this.Denominator *= Value.Denominator
        Return, this.Reduce()
    }

    Multiply(Value)
    {
        this.Numerator *= Value.Numerator
        this.Denominator *= Value.Denominator
        Return, this.Reduce()
    }

    Divide(Value)
    {
        this.Numerator *= Value.Denominator
        this.Denominator *= Value.Numerator
        Return, this.Reduce()
    }

    Remainder(Value)
    {
        IntegerQuotient := (this.Numerator * Value.Denominator) // (this.Denominator * Value.Numerator) ;floor divide the two values
        Numerator := Value.Numerator * IntegerQuotient
        this.Numerator := (this.Numerator * Value.Denominator) - (Numerator * this.Denominator)
        this.Denominator *= Value.Denominator
        Return, this.Reduce()
    }
}