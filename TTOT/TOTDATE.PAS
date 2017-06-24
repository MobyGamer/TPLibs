{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10                             }

Unit totDATE;
{$I TOTFLAGS.INC}

{
 Development Notes:
           1.00a   ??/??/??   Corrected calc of Year
           1.00b   06/01/91   Corrected 1.00a!
           1.00c   02/03/92   Changed Leap Year validation
           1.00d   02/27/92   Corrected DateFormat function
           1.00e   03/09/92   Changed 1900+ operation for 0..99 years
           1.10a   05/05/93   Changed ret value on JultoGreg and GregToStr
                              when 0 values passed.
}

INTERFACE

Uses DOS,totLOOK,totSTR;

Type

tDate = (MMDDYY,MMDDYYYY,MMYY,MMYYYY,DDMMYY,DDMMYYYY,YYMMDD,YYYYMMDD);
StrShort = string[20];

tMonths  = array[1..12] of StrShort;
tDays = array[0..6] of StrShort;

pDateOBJ = ^DateOBJ;
DateOBJ = object
   vLastYearNextCentury: byte;
   vSeparator: char;
   vMonths: tMonths;
   vDays: tDays;
   {methods...}
   constructor Init;
   procedure   SetLastYearNextCentury(Yr:byte);
   procedure   SetSeparator(Sep:char);
   procedure   SetMonths(Mth1,Mth2,Mth3,Mth4,Mth5,Mth6,Mth7,Mth8,Mth9,Mth10,Mth11,Mth12: strshort);
   procedure   SetDays(Day0,Day1,Day2,Day3,Day4,Day5,Day6:strshort);
   function    GetLastYearNextCentury: byte;
   function    GetSeparator: char;
   function    GetMonth(Mth:byte):string;
   function    GetDay(Day:byte):string;
   destructor  Done;
end; {DateOBJ}

function  GregtoJul(M,D,Y : longint): longint;
procedure JultoGreg(Jul:longint; var M,D,Y: longint);
function  Day(DStr:string;Format:tDate): word;
function  Month(DStr:string;Format:tDate): word;
function  Year(DStr:string;Format:tDate): word;
function  StrtoJul(DStr:string;Format:tDate):longint;
function  DOWStr(DStr:string;Format:tDate): byte;
function  DOWJul(Jul:longint): byte;
function  GregtoStr(M,D,Y:longint;Format:tDate): string;
function  JultoStr(Jul:longint;Format:tDate): string;
function  TodayinJul: longint;
function  ValidDate(M,D,Y:longint):boolean;
function  ValidDateStr(DStr:string;Format:tDate): boolean;
function  StripDateStr(DStr:string;Format:tDate):string;
function  FancyDateStr(Jul:longint; Long,Day:boolean): string;
function  RelativeDate(DStr:string;Format:tDate;Delta:longint):string;
function  StartOfYear(Jul:longint):longint;
function  EndOfYear(Jul:longint):longint;
function  DateFormat(Format:tDate):string;
procedure DateInit;

var

  DateTOT: ^DateOBJ;

IMPLEMENTATION

{|||||||||||||||||||||||||||||||||||||||}
{                                       }
{     D a t e O B J   M E T H O D S     }
{                                       }
{|||||||||||||||||||||||||||||||||||||||}
constructor DateOBJ.Init;
{}
begin
   vLastYearNextCentury := 20;
   vSeparator := '/';
   SetDays('Sunday','Monday','Tuesday','Wednesday',
           'Thursday','Friday','Saturday');
   SetMonths('January','February','March','April','May',
             'June','July','August','September',
             'October','November','December');
end; {DateOBJ.Init}

function DateOBJ.GetLastYearNextCentury: byte;
{}
begin
   GetLastYearNextCentury := vLastYearNextCentury;
end; {DateOBJ.GetLastYearNextCentury}

procedure DateOBJ.SetLastYearNextCentury(Yr:byte);
{}
begin
   {$IFDEF CHECK}
     if (Yr >= 0) and (Yr <= 99) then
        vLastYearNextCentury := Yr;
   {$ELSE}
     vLastYearNextCentury := Yr;
   {$ENDIF}
end; {DateOBJ.GetLastYearNextCentury}

function DateOBJ.GetSeparator: char;
{}
begin
   GetSeparator := vSeparator;
end; {DateOBJ.GetSeparator}

procedure DateOBJ.SetSeparator(Sep:char);
{}
begin
   vSeparator := Sep;
end; {DateOBJ.SetSeparator}

procedure DateOBJ.SetMonths(Mth1,Mth2,Mth3,Mth4,Mth5,Mth6,Mth7,Mth8,Mth9,Mth10,Mth11,Mth12: StrShort);
{}
begin
   vMonths[1] := Mth1;
   vMonths[2] := Mth2;
   vMonths[3] := Mth3;
   vMonths[4] := Mth4;
   vMonths[5] := Mth5;
   vMonths[6] := Mth6;
   vMonths[7] := Mth7;
   vMonths[8] := Mth8;
   vMonths[9] := Mth9;
   vMonths[10] := Mth10;
   vMonths[11] := Mth11;
   vMonths[12] := Mth12;
end; {DateOBJ.SetMonths}

procedure DateOBJ.SetDays(Day0,Day1,Day2,Day3,Day4,Day5,Day6:StrShort);
{}
begin
   vDays[0] := Day0;
   vDays[1] := Day1;
   vDays[2] := Day2;
   vDays[3] := Day3;
   vDays[4] := Day4;
   vDays[5] := Day5;
   vDays[6] := Day6;
end; {DateOBJ.SetDays}

function DateOBJ.GetMonth(Mth:byte):string;
{}
begin
   if Mth in [2..12] then
      GetMonth := vMonths[Mth]
   else
      GetMonth := vMonths[1];
end; {DateOBJ.GetMonth}

function DateOBJ.GetDay(Day:byte):string;
{}
begin
   if Day in [1..6] then
      GetDay := vDays[Day]
   else
      GetDay := vDays[0];
end; {DateOBJ.GetDay}

destructor DateOBJ.Done;
begin end;
{|||||||||||||||||||||||||||||||||||||||||||}
{                                           }
{     M i s c   P r o c   &   F u n c s     }
{                                           }
{|||||||||||||||||||||||||||||||||||||||||||}
function PadDateStr(DStr:string;Format:tDate):string;
{}
var
   Part1,Part2,Part3: string;
   L,P: byte;
   Sep1,Sep2:char;

     procedure PadOut(var S:string; width:byte);
     begin
        S := padright(S,width,'0');
     end;

begin
   if length(DStr) = length(DateFormat(Format)) then
   begin
      PadDateStr := DStr;
      exit;
   end;
   P := 0;
   L := length(DStr);
   repeat
      inc(P);
   until (not (DStr[P] in ['0'..'9'])) or (P > L);
   if P > L then
   begin
      PadDateStr := DStr;
      exit;
   end;
   Part1 := copy(DStr,1,pred(P));
   Sep1 := DStr[P];
   delete(DStr,1,P);
   P:= 0;
   repeat
      inc(P);
   until (not (DStr[P] in ['0'..'9'])) or (P > L);
   Part2 := copy(DStr,1,pred(P));
   Sep2 := DStr[P];
   Part3 := copy(DStr,succ(P),4);
   case Format of
      MMDDYY,YYMMDD,DDMMYY:begin
          PadOut(Part1,2);
          PadOut(Part2,2);
          PadOut(Part3,2);
          DStr := Part1+Sep1+Part2+Sep2+Part3;
      end;
      MMDDYYYY,DDMMYYYY:begin
          PadOut(Part1,2);
          PadOut(Part2,2);
          PadOut(Part3,4);
          DStr := Part1+Sep1+Part2+Sep2+Part3;
      end;
      YYYYMMDD:begin
          PadOut(Part1,4);
          PadOut(Part2,2);
          PadOut(Part3,2);
          DStr := Part1+Sep1+Part2+Sep2+Part3;
      end;
      MMYY:begin
          PadOut(Part1,2);
          PadOut(Part2,2);
          DStr := Part1+Sep1+Part2;
      end;
      MMYYYY:begin
          PadOut(Part1,2);
          PadOut(Part2,4);
          DStr := Part1+Sep1+Part2;
      end;
   end; {case}
   PadDateStr := DStr;
end; {PadDateStr}

function GregtoJul(M,D,Y:longint):longint;
{}
var Factor: integer;
begin
   if M < 3 then
      Factor := -1
   else
      Factor := 0;
   GregtoJul :=  (1461*(Factor+4800+Y) div 4)
               + ((M-2-(Factor*12))*367) div 12
               - (3*((Y+4900+Factor) div 100) div 4)
               + D
               - 32075;
end; {GregtoJul}

procedure JultoGreg(Jul:longint; var M,D,Y: longint);
{}
var U,V,W,X: longint;
begin
   if Jul = 0 then {1.10a}
   begin
      M := 0;
      D := 0;
      Y := 0;
   end
   else
   begin
      inc(Jul,68569);
      W := (Jul*4) div 146097;
      dec(Jul,((146097*W)+3) div 4);
      X := 4000*succ(Jul) div 1461001;
      dec(Jul,((1461*X) div 4) - 31);
      V := 80*Jul div 2447;
      U := V div 11;
      D := Jul - (2447*V div 80);
      M := V + 2 - (U*12);
      Y := X + U + (W-49)*100;
   end;
end; {JultoGreg}

function Day(DStr:string;Format:tDate): word;
{}
var
   DayStr: string;
begin
   DStr := PadDateStr(DStr,Format);
   case Format of
      MMDDYY,
      MMDDYYYY: DayStr := NthNumber(DStr,3)+NthNumber(DStr,4);
      DDMMYY,
      DDMMYYYY: DayStr := NthNumber(DStr,1)+NthNumber(DStr,2);
      YYMMDD:   DayStr := NthNumber(DStr,5)+NthNumber(DStr,6);
      YYYYMMDD: DayStr := NthNumber(DStr,7)+NthNumber(DStr,8);
      else     DayStr := '01';
   end; {case}
   Day := StrToInt(DayStr);
end; {Day}

function Month(DStr:string;Format:tDate): word;
{}
var
   MonStr: string;
begin
   DStr := PadDateStr(DStr,Format);
   case Format of
      MMDDYY,
      MMDDYYYY,
      MMYY,
      MMYYYY  :  MonStr := NthNumber(DStr,1)+NthNumber(DStr,2);
      YYMMDD,
      DDMMYY,
      DDMMYYYY:  MonStr := NthNumber(DStr,3)+NthNumber(DStr,4);
      YYYYMMDD:  MonStr := NthNumber(DStr,5)+NthNumber(DStr,6);
   end; {case}
   Month := StrToInt(MonStr);
end; {Month}

function Year(DStr:string;Format:tDate): word;
{}
var
   YrStr: string;
   TmpYr: word;
begin
   DStr := PadDateStr(DStr,Format);
   Case Format of
      MMDDYY,
      DDMMYY   : YrStr := NthNumber(DStr,5)+NthNumber(DStr,6);
      MMDDYYYY,
      DDMMYYYY : YrStr := NthNumber(DStr,5)+NthNumber(DStr,6)
                          + NthNumber(DStr,7)+NthNumber(DStr,8);
      MMYY     : YrStr := NthNumber(DStr,3)+NthNumber(DStr,4);
      MMYYYY   : YrStr := NthNumber(DStr,3)+NthNumber(DStr,4)
                          + NthNumber(DStr,5)+NthNumber(DStr,6);
      YYMMDD   : YrStr := NthNumber(DStr,1)+NthNumber(DStr,2);    {5.00a and b}
      YYYYMMDD : YrStr := NthNumber(DStr,1)+NthNumber(DStr,2)
                          + NthNumber(DStr,3)+NthNumber(DStr,4);
   end;
   TmpYr := StrToInt(YrStr);
   if (TmpYr >= 0) and (TmpYr <= 99) and (length(YrStr) <= 2) then {1.00e}
   begin
      if TmpYr < DateTOT^.GetLastYearNextCentury then
         TmpYr := 2000 + TmpYr
      else
         TmpYr := 1900 + TmpYr;
   end;
   Year := TmpYr;
end; {Year}

function GregtoStr(M,D,Y:longint;Format:tDate): string;  {1.10a}
{}
var
   PadChar : char;
   DD,MM: string[2];
   YY: string[4];
begin
   PadChar := DateTOT^.GetSeparator;
   if D < 1 then
      DD := 'שש'
   else
   begin
      DD := InttoStr(D);
      if D < 10 then
         DD := '0'+DD;
   end;
   if M < 1 then
      MM := 'שש'
   else
   begin
      MM := InttoStr(M);
      if M < 10 then
         MM := '0'+MM;
   end;
   if (Format in [MMDDYY,MMYY,DDMMYY,YYMMDD])
   and ((Y > 99) or (Y < -99)) then
      Y := Y Mod 100;
   if Y = 0 then
      YY := 'שש'
   else
   begin
      YY := InttoStr(Y);
      if Y < 10 then
         YY := '0'+YY;
   end;
   Case Format of
      MMDDYY,
      MMDDYYYY: GregtoStr := MM+PadChar+DD+Padchar+YY;
      MMYY,
      MMYYYY  : GregtoStr := MM+Padchar+YY;
      DDMMYY,
      DDMMYYYY: GregtoStr := DD+PadChar+MM+Padchar+YY;
      YYMMDD,
      YYYYMMDD: GregtoStr := YY+PadChar+MM+Padchar+DD;
   end; {case}
end; {GregtoStr}

function JultoStr(Jul:longint;Format:tDate): string;
{}
var M,D,Y:longint;
begin
   JultoGreg(Jul,M,D,Y);
   JultoStr := GregtoStr(M,D,Y,Format);
end; {JultoStr}

function TodayinJul: longint;
{}
var 
 M,D,Y,DOW: word;
begin
   GetDate(Y,M,D,DOW);
   TodayinJul := GregtoJul(M,D,Y);
end; {TodayinJul}

function LeapYear(Y:longint):boolean;
{}
begin
   LeapYear := (Y mod 4 = 0) and ((Y mod 400 = 0) or (Y mod 100 <> 0));
end; {LeapYear}

function ValidDate(M,D,Y:longint):boolean;
{}
begin
   if (D < 1)
   or (D > 31)
   or (M < 1)
   or (M > 12)
   then 
      ValidDate := False
   else
      Case M of
         4,6,9,11: ValidDate := (D <= 30);
         2:        ValidDate := (D <= 28)
                                or ( (D = 29) and LeapYear(Y)); {1.00c}
          else ValidDate := true;
      end; {case}
end; {ValidDate}

function  ValidDateStr(DStr:string;Format:tDate): boolean;
{}
var
 M,D,Y: word;
begin
   M := Month(DStr,Format);
   D := Day(DStr,Format);
   Y := Year(DStr,Format);
   ValidDateStr := ValidDate(M,D,Y);
end; {ValidDateStr}

function DOWJul(Jul:longint): byte;
var M,D,Y,N: longint;
begin
   JultoGreg(Jul,M,D,Y);
   if M <=2 then
     N := 1461 * (Y-1) div 4 + 153 * (M+13) div 5 + D
   else
     N := 1461 * Y div 4 + 153 * (M+1) div 5 + D;
   N:= abs((N - 621049)) mod 7;
   DOWJul := N;
end; {DayOfWeek}

function StrtoJul(DStr:string;Format:tDate):longint;
{}
var
  M,D,Y:longint;
begin
   M := Month(Dstr,Format);
   D := Day(Dstr,Format);
   Y := Year(Dstr,Format);
   StrtoJul := GregtoJul(M,D,Y);
end; {StrtoJul}

function DOWStr(DStr:string;Format:tDate): byte;
{}
begin
   DOWStr := DOWJul(StrtoJul(Dstr,Format));
end; {DOWStr}

function StripDateStr(DStr:string;Format:tDate):string;
{}
begin
   case Format of
      MMDDYY,
      MMDDYYYY,
      DDMMYY,
      DDMMYYYY,
      YYMMDD: begin
                 delete(Dstr,3,1);
                 delete(Dstr,5,1);
              end;
      MMYY,
      MMYYYY  : delete(DStr,3,1);
      YYYYMMDD: begin
                  delete(DStr,5,1);
                  delete(DStr,7,1);
                end;
   end; {case}
   StripDateStr := DStr;
end; {StripDateStr}

function FancyDateStr(Jul:longint; Long,Day:boolean): string;
{}
var 
  M,D,Y:longint;
  TheDay: byte;
  Str: string;
begin
   JultoGreg(Jul,M,D,Y);
   Str := ' '+InttoStr(D)+', '+IntToStr(Y);
   if Long then
      Str := dateTOT^.GetMonth(M) + Str
   else
      Str := copy(dateTOT^.GetMonth(M),1,3) + Str;
   if Day then
   begin
      TheDay := DOWJul(Jul);
      if Long then
         Str := dateTOT^.GetDay(TheDay) + ' ' + Str
      else
         Str := copy(dateTOT^.GetDay(TheDay),1,3) + ' ' + Str;
   end;
   FancyDateStr := Str;
end; {FancyDateStr}

function RelativeDate(DStr:string;Format:tDate;Delta:longint):string;
{}
begin
   RelativeDate := JultoStr(StrtoJul(DStr,Format)+Delta,Format);
end; {RelativeDate}

function EndOfMonth(Jul:longint):longint;
{}
var M,D,Y:longint;
begin
   JultoGreg(Jul,M,D,Y);
   case M of
      4,6,9,11: D := 30;
      2: if (Y mod 4 = 0) and (Y <> 0) and (Y <> 1900) then
            D := 29
         else
            D := 28;
      else D := 31;
   end; {case}
   EndOfMonth := GregtoJul(M,D,Y);
end; {EndOfMonth}

function StartOfMonth(Jul:longint):longint;
{}
var M,D,Y:longint;
begin
   JultoGreg(Jul,M,D,Y);
   StartOfMonth := GregtoJul(M,1,Y);
end; {StartOfMonth}

function StartOfYear(Jul:longint):longint;
{}
var M,D,Y:longint;
begin
   JultoGreg(Jul,M,D,Y);
   StartOfYear := GregtoJul(1,1,Y);
end; {StartOfYear}

function EndOfYear(Jul:longint):longint;
{}
var M,D,Y:longint;
begin
   JultoGreg(Jul,M,D,Y);
   EndOfYear := GregtoJul(12,31,Y);
end; {EndOfYear}

function DateFormat(Format:tDate):string;
{}
var Sep:char;
begin
   Sep := DateTOT^.GetSeparator;
   Case Format of
      MMDDYY: DateFormat := 'MM'+Sep+'DD'+Sep+'YY';
      MMDDYYYY: DateFormat := 'MM'+Sep+'DD'+Sep+'YYYY';
      MMYY: DateFormat := 'MM'+Sep+'YY';
      MMYYYY: DateFormat := 'MM'+Sep+'YYYY';
      DDMMYY: DateFormat := 'DD'+Sep+'MM'+Sep+'YY';   {1.00d}
      DDMMYYYY: DateFormat := 'DD'+Sep+'MM'+Sep+'YYYY';
      YYMMDD: DateFormat := 'YY'+Sep+'MM'+Sep+'DD';
      YYYYMMDD: DateFormat :=  'YYYY'+Sep+'MM'+Sep+'DD'; {1.00d}
   end; {case}
end; {DateFormat}
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}

procedure DateInit;
{initilizes objects and global variables}
begin
   new(DateTOT,Init);
end; {DateInit}

{end of unit - add initialization routines below}
{$IFNDEF OVERLAY}
begin
   DateInit;
{$ENDIF}
end.



