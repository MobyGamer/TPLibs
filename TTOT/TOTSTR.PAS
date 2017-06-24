{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10                             }

Unit totSTR;
{$I TOTFLAGS.INC}

{
 Development Notes:  1.00a  6/11/91   Corrected RealSciStr for 0.0
                     1.00b  2/03/92   Further corrections to RealToSciStr
                                      and ValidInt
                     1.00c  2/27/92   Remove double negative from RealtoSciStr
                     1.00d  3/09/92   Changed NthNumber routine
}

INTERFACE

Uses totREAL, totINPUT;

CONST
   MaxFixlength = 5;

TYPE
   tJust = (JustLeft,JustCenter,JustRight);
   tCase = (Lower,Upper,Proper,Leave);
   tSign = (plusminus, minus, brackets, dbcr);

   pFmtNumberOBJ = ^FmtNumberOBJ;
   FmtNumberOBJ = object
      vPrefix: string[Maxfixlength];
      vSuffix: string[Maxfixlength];
      vSign: tSign;
      vPad: char;
      vThousandsSep: char;
      vDecimalSep: char;
      vJustification: tJust;
      {...methods}
      constructor Init;
      procedure   SetPrefixSuffix(P,S:string);
      procedure   SetSign(S:tSign);
      procedure   SetSeparators(P,T,D:char);
      procedure   SetJustification(J:tJust);
      function    GetDecimal:char;
      function    FormattedStr(StrVal:string; Width:byte):string;
      function    FormattedLong(Val:longint; Width:byte):string;
      function    FormattedReal(Val:extended; DP:byte; Width:byte):string;
      destructor  Done;
   end; {FmtNumberOBJ}

CONST
   Floating = 255;
   Fmtchars: set of char = ['!','#','@','*'];

function PicFormat(Input,Picture:string;Pad:char): string;
function TruncFormat(Input:string;Start,Len:byte; Pad:char):string;
function Squeeze(L:char;Str:string;Width:byte): string;
function First_Capital_Pos(Str:string): byte;
function First_Capital(Str:string): char;
function Pad(PadJust:tJust;Str:string;Size:byte;ChPad:char):string;
function PadLeft(Str:string;Size:byte;ChPad:char):string;
function PadCenter(Str:string;Size:byte;ChPad:char):string;
function PadRight(Str:string;Size:byte;ChPad:char):string;
function Last(N:byte;Str:string):string;
function First(N:byte;Str:string):string;
function AdjCase(NewCase:tCase;Str:string):string;
function SetUpper(Str:string):string;
function SetLower(Str:string):string;
function SetProper(Str:string):string;
function OverType(N:byte;StrS,StrT:string):string;
function Strip(L,C:char;Str:string):string;
function LastPos(C:char;Str:string):byte;
function PosAfter(C:char;Str:string;Start:byte):byte;
function LastPosBefore(C:char;Str:string;Last:byte):byte;
function PosWord(Wordno:byte;Str:string):byte;
function WordCnt(Str:string):byte;
function ExtractWords(StartWord,NoWords:byte;Str:string):string;
function ValidInt(Str:string):boolean;
function ValidHEXInt(Str:string):boolean;
function ValidReal(Str:string):boolean;
function StrToInt(Str:string):integer;
function StrToLong(Str:string):Longint;
function HEXStrToLong(Str:string):longint;
function StrToReal(Str:string):extended;
function RealToStr(Number:extended;Decimals:byte):string;
function IntToStr(Number:longint):string;
function IntToHEXStr(Number:longint):string;
function Decimals (L:byte):byte;
function RealToSciStr(Number:extended; D:byte):string;
function NthNumber(InStr:string;Nth:byte) : char;

IMPLEMENTATION

function PicFormat(Input,Picture:string;Pad:char): string;
{}
var
   TempStr : string;
   I,J : byte;
begin
   J := 0;
   For I := 1 to length(Picture) do
   begin
       If not (Picture[I] in Fmtchars) then
       begin
           TempStr[I] := Picture[I] ;  {force any none format charcters into string}
           inc(J);
       end
       else    {format character}
       begin
           If I - J <= length(Input) then
              TempStr[I] := Input[I - J]
           else
              TempStr[I] := Pad;
       end;
   end;
   TempStr[0] := char(length(Picture));  {set initial byte to string length}
   PicFormat := Tempstr;
end; {PicFormat}

function TruncFormat(Input:string;Start,Len:byte; Pad:char):string;
{}
var
   L : byte;
begin
   if Start > 1 then
      Delete(Input,1,pred(Start));
   L := length(Input);
   if L = Len then
      TruncFormat := Input
   else if L > Len then
      TruncFormat := copy(Input,1,Len)
   else
      TruncFormat := Padleft(Input,Len,Pad);
end; {TruncFormat}

function Squeeze(L:char; Str:string;Width:byte): string;
{}
const more:string[1] = #26;
var temp : string;
begin
   if Width = 0 then
   begin
      Squeeze := '';
      exit;
   end;
   Fillchar(Temp[1],Width,' ');
   Temp[0] := chr(Width);
   if Length(Str) < Width then
      move(Str[1],Temp[1],length(Str))
   else
   begin
      if upcase(L) = 'L' then
      begin
         move(Str[1],Temp[1],pred(width));
         move(More[1],Temp[Width],1);
      end
      else
      begin
         move(More[1],Temp[1],1);
         move(Str[length(Str)-width+2],Temp[2],pred(width));
      end;
   end;
   Squeeze := Temp;
end; {Squeeze}

function First_Capital_Pos(Str : string): byte;
{}
var StrPos : byte;
begin
   StrPos := 1;
   while (StrPos <= length(Str))  and (AlphabetTOT^.IsUpper(ord(Str[StrPos])) = false) do
      StrPos := Succ(StrPos);
   if StrPos > length(Str) then
      First_Capital_Pos  := 0
   else
      First_Capital_Pos := StrPos;
end; {First_Capital_Pos}

function First_capital(Str : string): char;
{}
var B : byte;
begin
   B := First_Capital_Pos(Str);
   if B > 0 then
      First_Capital := Str[B]
   else
      First_Capital := #0;
end; {First_capital}

function Pad(PadJust:tJust;Str:string;Size:byte;ChPad:char):string;
{}
begin
   case PadJust of
      JustLeft:  Pad := PadLeft(Str,Size,ChPad);
      JustCenter:Pad := PadCenter(Str,Size,ChPad);
      JustRight: Pad := PadRight(Str,Size,ChPad);
   end; {case}
end; {Pad}

function PadLeft(Str:string;Size:byte;ChPad:char):string;
var temp : string;
begin
   fillchar(Temp[1],Size,ChPad);
   Temp[0] := chr(Size);
   if Length(Str) <= Size then
      move(Str[1],Temp[1],length(Str))
   else
      move(Str[1],Temp[1],size);
   PadLeft := Temp;
end;

function PadCenter(Str:string;Size:byte;ChPad:char):string;
var temp : string;
L : byte;
begin
   fillchar(Temp[1],Size,ChPad);
   Temp[0] := chr(Size);
   L := length(Str);
   if L <= Size then
      move(Str[1],Temp[((Size - L) div 2) + 1],L)
   else
      Temp := copy(Str,1,L);
   PadCenter := temp;
end; {center}

function PadRight(Str:string;Size:byte;ChPad:char):string;
var
  temp : string;
  L : integer;
begin
   fillchar(Temp[1],Size,ChPad);
   Temp[0] := chr(Size);
   L := length(Str);
   if L <= Size then
      move(Str[1],Temp[succ(Size - L)],L)
   else
      move(Str[1],Temp[1],size);
   PadRight := Temp;
end;

function Last(N:byte;Str:string):string;
var Temp : string;
begin
   if N > length(Str) then
      Temp := Str
   else
      Temp := copy(Str,succ(length(Str) - N),N);
   Last := Temp;
end;  {Last}

function First(N:byte;Str:string):string;
var Temp : string;
begin
   if N > length(Str) then
      Temp := Str
   else
      Temp := copy(Str,1,N);
   First := Temp;
end;  {First}

function AdjCase(NewCase:tCase;Str:string):string;
{}
begin
   case Newcase of
   Upper: Str := SetUpper(Str);
   Lower: Str := SetLower(Str);
   Proper: Str := SetProper(Str);
   Leave:{do nothing};
   end;
   AdjCase := Str;
end; {AdjCase}

function SetUpper(Str:string):string;
var
  I : integer;
begin
   for I := 1 to length(Str) do
      Str[I] := AlphabetTOT^.GetUpcase(Str[I]);
   SetUpper := Str;
end;  {Upper}

function SetLower(Str:string):string;
var
  I : integer;
begin
   for I := 1 to length(Str) do
      Str[I] := AlphabetTOT^.GetLocase(Str[I]);
   SetLower := Str;
end;  {Lower}

function SetProper(Str:string):string;
var
  I : integer;
  SpaceBefore: boolean;
begin
   SpaceBefore := true;
   Str := SetLower(Str);
   For I := 1 to length(Str) do
      if SpaceBefore and AlphabetTOT^.IsLower(ord(Str[I])) then
      begin
         SpaceBefore := False;
         Str[I] := AlphabetTOT^.GetUpcase(Str[I]);
      end
      else
         if (SpaceBefore = False) and (Str[I] = ' ') then
            SpaceBefore := true;
   SetProper := Str;
end;

function OverType(N:byte;StrS,StrT:string):string;
{Overlays StrS onto StrT at Pos N}
var
  L : byte;
  StrN : string;
begin
   L := N + pred(length(StrS));
   if L < length(StrT) then
      L := length(StrT);
   if L > 255 then
      Overtype := copy(StrT,1,pred(N)) + copy(StrS,1,255-N)
       else
   begin
      fillchar(StrN[1],L,' ');
      StrN[0] := chr(L);
      move(StrT[1],StrN[1],length(StrT));
      move(StrS[1],StrN[N],length(StrS));
      OverType := StrN;
   end;
end;  {OverType}

function Strip(L,C:char;Str:string):string;
{L is left,center,right,all,ends}
var I :  byte;
begin
   Case Upcase(L) of
   'L' : begin       {Left}
            while (Str[1] = C) and (length(Str) > 0) do
               Delete(Str,1,1);
         end;
   'R' : begin       {Right}
            while (Str[length(Str)] = C) and (length(Str) > 0) do
               Delete(Str,length(Str),1);
         end;
   'B' : begin       {Both left and right}
            while (Str[1] = C) and (length(Str) > 0) do
               Delete(Str,1,1);
            while (Str[length(Str)] = C) and (length(Str) > 0)  do
               Delete(Str,length(Str),1);
         end;
   'A' : begin       {All}
            I := 1;
            repeat
               if (Str[I] = C) and (length(Str) > 0) then
                  Delete(Str,I,1)
               else
                  I := succ(I);
            until (I > length(Str)) or (Str = '');
         end;
   end;
   Strip := Str;
end;  {Strip}

function LastPos(C:char;Str:string):byte;
{}
Var I : byte;
begin
   I := succ(Length(Str));
   repeat
      dec(I);
   until (I = 0) or (Str[I] = C);
   LastPos := I;
end;  {LastPos}

function PosAfter(C:char;Str:string;Start:byte):byte;
{}
Var I : byte;
begin
   I := length(Str);
   if (I = 0) or (Start > I) then
      PosAfter := 0
   else
   begin
      dec(Start);
      repeat
        inc(Start)
      until (Start > I) or (Str[Start] = C);
      if Start > I then
         PosAfter := 0
      else
         PosAfter := Start;
   end;
end; {PosAfter}

function LastPosBefore(C:char;Str:string;Last:byte):byte;
{}
begin
   Str := copy(Str,1,Last);
   LastPosBefore := LastPos(C,Str);
end; {LostPosBefore}

function LocWord(StartAT,Wordno:byte;Str:string):byte;
{local proc used by PosWord and Extract word}
var
  W,L: integer;
  Spacebefore: boolean;
begin
   if (Str = '') or (wordno < 1) or (StartAT > length(Str)) then
   begin
       LocWord := 0;
       exit;
   end;
   SpaceBefore := true;
   W := 0;
   L := length(Str);
   StartAT := pred(StartAT);
   while (W < Wordno) and (StartAT <= length(Str)) do
   begin
      StartAT := succ(StartAT);
      if SpaceBefore and (Str[StartAT] <> ' ') then
      begin
         W := succ(W);
         SpaceBefore := false;
      end
      else
         if (SpaceBefore = false) and (Str[StartAT] = ' ') then
            SpaceBefore := true;
   end;
   if W = Wordno then
      LocWord := StartAT
   else
      LocWord := 0;
end;

function PosWord(Wordno:byte;Str:string):byte;
begin
   PosWord := LocWord(1,wordno,Str);
end;  {Word}

function WordCnt(Str:string):byte;
var
  W,I: integer;
  SpaceBefore: boolean;
begin
   if Str = '' then
   begin
      WordCnt := 0;
      exit;
   end;
   SpaceBefore := true;
   W := 0;
   For  I :=  1 to length(Str) do
   begin
      if SpaceBefore and (Str[I] <> ' ') then
      begin
         W := succ(W);
         SpaceBefore := false;
      end
      else
         if (SpaceBefore = false) and (Str[I] = ' ') then
            SpaceBefore := true;
   end;
   WordCnt := W;
end;

function ExtractWords(StartWord,NoWords:byte;Str:string):string;
var Start, finish : integer;
begin
   if Str = '' then
   begin
      ExtractWords := '';
      exit;
   end;
   Start := LocWord(1,StartWord,Str);
   if Start <> 0 then
      finish := LocWord(Start,succ(NoWords),Str)
   else
   begin
      ExtractWords := '';
      exit;
   end;
   if finish = 0 then
      finish := succ(length(Str));
   repeat
      finish := pred(finish);
   until Str[finish] <> ' ';
   ExtractWords := copy(Str,Start,succ(finish-Start));
end;  {ExtractWords}

function ValidInt(Str:string):boolean;
{}
var 
  Temp : longint;
  Code : integer;

  function NoLetters:boolean;
  var 
    I:integer;
    Bad: boolean;
  begin
     NoLetters := true;
     for I := 1 to Length(Str) do
     begin
        if (Str[I] in ['0'..'9','+','-']) = false then  {1.00b}
           NoLetters := false;
     end;
  end;

begin
   if length(Str) = 0 then
      ValidInt := true
   else
   begin
      val(Str,temp,code);
      ValidInt := (Code = 0) and Noletters;
   end;
end; {ValidInt}

function ValidHEXInt(Str:string):boolean;
{}
var 
  Temp : longint;
  Code : integer;
begin
   if length(Str) = 0 then
      ValidHEXInt := true
   else
   begin
      val(Str,temp,code);
      ValidHEXInt := (Code = 0);
   end;
end; {ValidHEXInt}

function IntToStr(Number:longint):string;
{}
var Temp : string;
begin
   Str(Number,temp);
   IntToStr := temp;
end; {IntToStr}

function IntToHEXStr(Number:longint):string;
{}
const
   HEXChars: array [0..15] of char = '0123456789ABCDEF';
var
   I : integer;
   Str : string;
   BitsToShift: byte;
   Chr : char;
begin
   Str := '';
   for I := 7 downto 0 do
   begin
      BitsToShift := I*4;
      Chr := HEXChars[ (Number shr BitsToShift) and $F];
      if not ((Str = '') and (Chr = '0')) then
         Str := Str + Chr;
   end;
   IntToHEXStr := Str;
end; {IntToHEXStr}

function ValidReal(Str:string):boolean;
{}
var
  Code : integer;
  Temp : extended;
begin
   if length(Str) = 0 then
      ValidReal := true
   else
   begin
      if Copy(Str,1,1)='.' Then
         Str:='0'+Str;
      if (Copy(Str,1,1)='-') and (Copy(Str,2,1)='.') Then
         Insert('0',Str,2);
      if Str[length(Str)] = '.' then
         Delete(Str,length(Str),1);
      val(Str,temp,code);
      ValidReal := (Code = 0);
   end;
end; {ValidReal}

function StrToReal(Str:string):extended;
var
  code : integer;
  Temp : extended;
begin
   if length(Str) = 0 then
      StrToReal := 0
   else
   begin
      if Copy(Str,1,1)='.' Then
         Str:='0'+Str;
      if (Copy(Str,1,1)='-') and (Copy(Str,2,1)='.') Then
         Insert('0',Str,2);
      if Str[length(Str)] = '.' then
         Delete(Str,length(Str),1);
      val(Str,temp,code);
      if code = 0 then
         StrToReal := temp
      else
         StrToReal := 0;
   end;
end; {StrToReal}

function RealToStr(Number:extended;Decimals:byte):string;
var Temp : string;
begin
   Str(Number:20:Decimals,Temp);
   repeat
        if copy(Temp,1,1) = ' ' then delete(Temp,1,1);
   until copy(temp,1,1) <> ' ';
   if Decimals = Floating then
   begin
      Temp := Strip('R','0',Temp);
      if Temp[Length(temp)] = '.' then
         Delete(temp,Length(temp),1);
   end;
   RealToStr := Temp;
end; {RealToStr}

function StrToInt(Str:string):integer;
var temp,code : integer;
begin
   if length(Str) = 0 then
      StrToInt := 0
   else
   begin
      val(Str,temp,code);
      if code = 0 then
         StrToInt := temp
      else
         StrToInt := 0;
   end;
end; {StrToInt}

function StrToLong(Str:string):Longint;
var
  code : integer;
  Temp : longint;
begin
   if length(Str) = 0 then
      StrToLong := 0
   else
   begin
      val(Str,temp,code);
      if code = 0 then
         StrToLong := temp
      else
         StrToLong := 0;
   end;
end; {StrToLong}

function HEXStrToLong(Str:string):longint;
{}
begin
   if Str = '' then
      HEXStrToLong := 0
   else
   begin
      if Str[1] <> '$' then
         Str := '$'+Str;
      HEXStrtoLong := StrToLong(Str);
   end;
end; {HEXStrToLong}

function Decimals (L:byte):byte;
{}
var
  Expnt:byte;
  Temp :shortint;
begin
{$IFDEF FLOAT}
      Expnt := 4;
{$ELSE}
   {$IFDEF FLOATEM}
      Expnt := 4;
   {$ELSE}
      Expnt := 2;
   {$ENDIF}        
{$ENDIF}
   Temp := L-Expnt-5;
   if temp > 0 then
      Decimals := Temp
   else
      Decimals := 0;
end; {Decimals}

function RealToSciStr(Number:extended; D:byte):string;         {1.00b,1.00c}
{Credits: Michael Harris, Houston. 
          Peter Sands, Australia
          Frans van Capelle, Amsterdam
 Thanks!}
Const
    DamnNearUnity = 9.99999999E-01;
Var
    Temp : extended;
    Power: integer;
    Value: string;
    Sign : char;
    Expnt: byte;
begin
   if Number = 1.0 then
      RealToSciStr := '1.000'
   else if Number = 0.0 then   {1.00a}
      RealToSciStr := '0.000'
   else
   begin
      Temp := Number;
      Power := 0;
      if abs(Number) > 1.0 then
      begin
         while abs(Temp) >= 10.0 do
         begin
             Inc(Power);
             Temp := Temp/10.0;
         end;
         Sign := '+';
      end
      else
      begin
         while abs(Temp) < DamnNearUnity do
         begin
             Inc(Power);
             Temp := Temp * 10.0;
         end;
         Sign := '-';
      end;
      Value := RealToStr(Temp,D);
{$IFDEF FLOAT}
      Expnt := 4;
{$ELSE}
   {$IFDEF FLOATEM}
      Expnt := 4;
   {$ELSE}
      Expnt := 2;
   {$ENDIF}        
{$ENDIF}        
      RealToSciStr := Value+'E'+Sign+Padright(IntToStr(Power),Expnt,'0');
   end;
end; {RealToSciStr}

function NthNumber(InStr:string;Nth:byte) : char;
{Returns the nth number in an alphanumeric string}
var
   Counter : byte;
   B, Len : byte;
begin
    Counter := 0;
    B := 0;
    Len := Length(InStr);
    Repeat
         Inc(B);
         If InStr[B] in ['0'..'9'] then
            Inc(Counter);
    Until (Counter = Nth) or (B = Len);
    if counter = Nth then  {1.00}
       NthNumber := InStr[B]
    else
       NthNumber := #0;
end; {NthNumber}
{||||||||||||||||||||||||||||||||||||||||||||||||||}
{                                                  }
{   F O R M A T    O B J E C T    M E T H O D S    }
{                                                  }
{||||||||||||||||||||||||||||||||||||||||||||||||||}
constructor FmtNumberOBJ.Init;
{}
begin
   SetPrefixSuffix('','');
   SetSign(Minus);
   SetSeparators(' ',',','.');
   SetJustification(JustLeft);
end; {FmtNumberOBJ.Init}

procedure FmtNumberOBJ.SetPrefixSuffix(P,S:string);
{}
begin
   vPrefix := P;
   vSuffix := S;
end; {FmtNumberOBJ.SetPrefixSuffix}

procedure FmtNumberOBJ.SetSign(S:tSign);
{}
begin
   vSign := S;
end; {FmtNumberOBJ.SetSign}

procedure FmtNumberOBJ.SetSeparators(P,T,D:char);
{}
begin
   vPad := P;
   vThousandsSep := T;
   vDecimalSep := D;
end; {FmtNumberOBJ.SetSeparators}

procedure FmtNumberOBJ.SetJustification(J:tJust);
{}
begin
   vJustification := J;
end; {FmtNumberOBJ.SetJustification}

function FmtNumberOBJ.GetDecimal:char;
{}
begin
   GetDecimal := vDecimalSep;
end; {FmtNumberOBJ.GetDecimal}

function FmtNumberOBJ.FormattedStr(StrVal:string; Width:byte):string;
{}
var
   DP: integer;
   Neg: boolean;
   Temp,Unformatted: string;
begin
   Unformatted := StrVal;
   if StrVal <> '' then
   begin
      if (StrVal[1] = '-') then
      begin
         Neg := true;
         delete(StrVal,1,1);
      end
      else
         Neg := false;
      DP := pos('.',StrVal);
      if DP = 0 then
         DP := succ(length(StrVal))
      else
         if vDecimalSep <> '.' then
            StrVal[DP] := vDecimalSep;
      dec(DP,3);
      while (DP > 1) and (vThousandsSep <> #0) do    {add thousands separator}
      begin
         insert(vThousandsSep,StrVal,DP);
         dec(DP,3);
      end;
      if vPrefix <> '' then
         StrVal := vPrefix + StrVal;
      if vSuffix <> '' then
         StrVal := StrVal + vSuffix;
      if Neg then
         case vSign of
            PlusMinus, Minus:
               StrVal := '-'+StrVal;
            DbCr:
               StrVal := StrVal + 'DB';
            Brackets:
               StrVal := '('+StrVal + ')';
         end {case}
      else
         case vSign of
            PlusMinus:
               StrVal := '+'+StrVal;
            DbCr:
               StrVal := StrVal + 'CR';
         end; {case}
   end;
   {now see if there is room for the formatted string}
   Temp := Pad(JustRight,StrVal,succ(Width),vPad);
   if Temp[1] = vPad then {there was room}
      FormattedStr := Pad(vJustification,StrVal,Width,vPad)
   else
      FormattedStr := Pad(vJustification,Unformatted,Width,vPad);
end; {FmtNumberOBJ.FormattedStr}

function FmtNumberOBJ.FormattedLong(Val:longint; Width:byte):string;
{}
var
  Str:string;
begin
   Str := IntToStr(Val);
   FormattedLong := FormattedStr(Str,Width);
end; {FmtNumberOBJ.FormattedLong}

function FmtNumberOBJ.FormattedReal(Val:extended; DP:byte; Width:byte):string;
{}
var
  Str:string;
begin
   Str := RealToStr(Val,DP);
   FormattedReal := FormattedStr(Str,Width);
end; {FmtNumberOBJ.FormattedReal}

destructor FmtNumberOBJ.Done;
{}
begin end;
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}

procedure StrInit;
{initilizes objects and global variables}
begin
end;

{end of unit - add initialization routines below}
{$IFNDEF OVERLAY}
begin
   StrInit;
{$ENDIF}
end.
