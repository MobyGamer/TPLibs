{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10                             }

Unit totMISC;
{$I TOTFLAGS.INC}

{
 Development Notes: 1.00a  May 28 91  Added MiscInit to Interface
                    1.00b  Jul 10 91  Added directory check in ValidFilename
                    1.00c  Oct 9  91  Corrected FSize
                    1.00d  Nov 6  91  Improved ValidFilename
                    1.10   Dec 15 92  DPMI Update - changed ResetPrinter
}

INTERFACE

Uses DOS, CRT, totSTR, totFAST;

var
  LPTport:byte;     {0=lpt1, 1=lpt2, 2=lpt3}

procedure Swap(var A,B:longint);
function  WithinRange(Min,Max,Test: longint): boolean;
function  Exist(Filename:string):boolean;
function  CopyFile(SourceFile, TargetFile:string): shortint;
function  DeleteFile(Filename:string): shortint;
function  RenameFile(Oldname,NewName:string):shortint;
function  FSize(Filename:string): longint;
function  FileDrive(Full:string): string;
function  FileDirectory(Full:string): string;
function  FileName(Full:string): string;
function  FileExt(Full:string): string;
function  SlashedDirectory(Dir:string):string;
function  PrinterStatus:byte;
function  AlternatePrinterStatus:byte;
function  PrinterReady :boolean;
procedure ResetPrinter;
procedure PrintScreen;
procedure Beep;
function  CurrentTime: string;
function  ParamLine: String;
function  ParamVal(Marker:string): string;
function  Frequency(Match:string;Source:string): byte;
function  ValidFileName(FN:string): shortint;
procedure ResetStartUpMode;
function  RunAnything(Command: string):integer;
function  RunEXECOM(Progname, Params: string):integer;
function  RunDOS(Msg:string):integer;
procedure MiscInit;

IMPLEMENTATION
VAR
    StartTop,      {used to record initial screen state when program is run}
    StartBot   : Byte;
    StartMode  : word;

procedure Swap(var A,B:longint);
{}
var Temp: longint;
begin
   Temp := A;
   A := B;
   B := Temp;
end; {Swap}

function WithinRange(Min,Max,Test: longint): boolean;
{}
begin
   if Min > Max then
      Swap(Min,Max);
   WithinRange := (Test >= Min) and (Test <= Max);
end; {WithinRange}

function Exist(Filename:string):boolean;
{returns true if file exists}
var Inf: SearchRec;
begin
    findfirst(Filename,AnyFile,Inf);
    Exist := (DOSError = 0);
end;  {func Exist}

function CopyFile(SourceFile, TargetFile:string): shortint;
{return codes:  0 successful
                1 source and target the same
                2 cannot open source
                3 unable to create target
                4 error during copy
}
var
  Source,
  Target: file;
  BRead,
  Bwrite: word;
  FileBuf: array[1..2048] of char;
begin
   if SourceFile = TargetFile then
      CopyFile := 1
   else
   begin
      assign(Source,SourceFile);
      {$I-}
      reset(Source,1);
      {$I+}
      if IOResult <> 0 then
          CopyFile := 2
      else
      begin
         Assign(Target,TargetFile);
         {$I-}
         Rewrite(Target,1);
         {$I+}
         if IOResult <> 0 then
            CopyFile := 3
         else
         begin
            repeat
              blockread(Source,FileBuf,SizeOf(FileBuf),BRead);
              blockwrite(Target,FileBuf,Bread,Bwrite);
            until (Bread = 0) or (Bread <> BWrite);
            close(Source);
            close(Target);
            if Bread <> Bwrite then
               CopyFile := 4
            else
               CopyFile := 0;
         end;
      end;
   end;
end; {CopyFile}

function FSize(Filename:string): longint;                 {1.00c}
{returns  -1   if file not found}
var FileInfo: SearchRec;
begin
   Findfirst(Filename,anyfile,FileInfo);
   if DOSError = 0 then
      FSize := FileInfo.Size
   else
      FSize := -1;
end; {FSize}

function FileSplit(Part:byte;Full:string): string;
{used internally}
var
   D : DirStr;
   N : NameStr;
   E : ExtStr;
begin
   FSplit(Full,D,N,E);
   Case Part of
   1 : FileSplit := D;
   2 : FileSplit := N;
   3 : FileSplit := E;
   end;
end; {FileSplit}

function FileDrive(Full:string): string;
{}
var
  Temp : string;
  P : byte;
begin
   Temp := FileSplit(1,Full);
   P := Pos(':',Temp);
   if P <> 2 then
      FileDrive := ''
   else
      FileDrive := upcase(Temp[1]);
end; {FileDrive}

function FileDirectory(Full:string): string;
{}
var
  Temp : string;
  P : byte;
begin
   Temp := FileSplit(1,Full);
   P := Pos(':',Temp);
   if P = 2 then
      Delete(Temp,1,2);                 {remove drive}
   if (Temp[length(Temp)]  ='\') and (temp <> '\') then
      Delete(temp,length(Temp),1);      {remove last backslash}
   FileDirectory := Temp;
end; {FileDirectory}

function FileName(Full:string): string;
{}
begin
   FileName := FileSplit(2,Full);
end; {FileName}

function FileExt(Full:string): string;
{}
var
  Temp : string;
begin
   Temp := FileSplit(3,Full);
   if (Temp = '') or (Temp = '.') then
      FileExt := temp
   else
      FileExt := copy(Temp,2,3);
end; {FileExt}

function SlashedDirectory(Dir:string):string;
{}
begin
   if (Dir = '') or (Dir[length(Dir)] in [':','\']) then
      SlashedDirectory := Dir
   else
      SlashedDirectory := Dir + '\';
end; {SlashedDirectory}

function PrinterStatus:byte;
{Credits: Robert W. Lewis, VA thanks! Special masking employed for non-
          standard printers, e.g. daisy wheels!!! }
var Recpack : registers;
begin
   with Recpack do
   begin
      Ah := 2;
      Dx := LPTport;
      intr($17,recpack);
      if (Ah and $B8) = $90 then
         PrinterStatus := 0        {all's well}
      else if (Ah and $20) = $20 then
         PrinterStatus := 1        {no Paper}
      else if (Ah and $10) = $00 then
         PrinterStatus := 2        {off line}
      else if (Ah and $80) = $00 then
         PrinterStatus := 3        {busy}
      else if (Ah and $08) = $08 then
         PrinterStatus := 4;       {undetermined error}
   end;
end; {PrinterStatus}

function AlternatePrinterStatus:byte;
var Recpack : registers;
begin
   with recpack do
   begin
      Ah := 2;
      Dx := LPTport;
      intr($17,recpack);
      if (Ah and $20) = $20 then
            AlternatePrinterStatus := 1  {no Paper}
      else if (Ah and $10) = $00 then
            AlternatePrinterStatus := 2  {off line}
      else if (Ah and $80) = $00 then
            AlternatePrinterStatus := 3  {busy}
      else if (Ah and $08) = $08 then
            AlternatePrinterStatus := 4  {undetermined error}
      else
          AlternatePrinterStatus := 0    {all's well}
   end;
end; {AlternatePrinterStatus}

function PrinterReady :boolean;
begin
    PrinterReady := (PrinterStatus = 0);
end; {PrinterReady}

procedure ResetPrinter; {1.1}
var
  address: ^integer;
  portno,delay : integer;
begin
{$IFDEF DPMI}
   address := ptr(seg0040,$0008);
{$ELSE}
   address := ptr($0040,$0008);
{$ENDIF}
   portno := address^ + 2;
   port[portno] := 232;
   for delay := 1 to 2000 do {nothing};
   port[portno] := 236;
end; {ResetPrinter}

function CurrentTime: string;
var
  hour,min,sec:     string[2];
  H,M,S,T : word;
begin
  GetTime(H,M,S,T);
  Str(H,Hour);
  Str(M,Min);
  Str(S,Sec);
  if S < 10 then        {pad a leading zero if sec is < 10 }
     sec := '0'+sec;
  if M < 10 then        {pad a leading zero if min is < 10 }
     min := '0'+min;
  if H > 12 then        { assign an a.m. or p.m. string }
  begin
     str(H - 12,hour);
     if length(hour) = 1 then Hour := ' '+hour;
     CurrentTime := hour+':'+min+':'+sec+' p.m.'
  end
  else if H < 1 then
     CurrentTime := '12'+':'+min+':'+sec+' a.m.'
  else
     CurrentTime := hour+':'+min+':'+sec+' a.m.';
end; {CurrentTime}

procedure PrintScreen;
var Regpack : registers;
begin
   intr($05,regpack);
end; {PrintScreen}

procedure Beep;
begin
    sound(800);Delay(150);
    sound(600);Delay(100);
    Nosound;
end; {Beep}

function ParamLine: String;
{returns the command line as a space delimited string}
var 
 I : integer;
 P : integer;
 Line : string;
begin
   Line := '';
   P := ParamCount;
   if P > 0 then
      for I := 1 to P do
          Line := Line + ParamStr(I) + ' ';
   ParamLine := Line;
end; {ParamLine}

function ParamVal(Marker:string): string;
{searches for Marker in string and returns the characters following}
var
   ValStr,
   Line : string;
   Loc1, Loc2 : integer;
begin
   Line := ParamLine;
   ValStr := '';
   if Line <> '' then
   begin
      Loc1 := pos(SetUpper(Marker),SetUpper(Line));
      if Loc1 = 0 then {not found}
         ValStr := ''
      else
      begin
         Loc1 := Loc1 + length(Marker);
         if (Loc1 > Length(Line)) 
         or (Line[Loc1] = Marker[1]) then
            ValStr := ''
         else
         begin
            Loc2 := Loc1;
            repeat
               inc(Loc2)
            until (Line[Loc2] = Marker[1])
               or (Loc2 > length(Line));
            ValStr := Copy(Line,Loc1,Loc2-Loc1);
         end;
      end;
   end;
   ParamVal := ValStr;
end; {ParamVal}

function Frequency(Match:string;Source:string): byte;
{returns the number of times that Match occurs in SOURCE}
var
  Len,Loc, Counter : byte;
begin
   Counter := 0;
   Len := Length(match);
   if (Len <> 0) and (length(Source) > 0) then
      repeat 
         Loc := pos(Match,Source);
         if Loc <> 0 then
         begin
            inc(Counter);
            delete(Source,Loc,length(Match));
         end;
      until Loc = 0;
   Frequency := Counter;
end; {Frequency}

function ValidFileName(FN:string): shortint;
{Validates a file path and name and returns following
 codes:
          -2     Valid path, but no file specified
          -1     Path and name OK but file does not exist
           0     Path and name OK and file exists
           1     Illegal drive specifier
           2     Illegal characters in path
           3     Invalid Path
           4     No file specified
           5     Illegal Characters in name
           6     Name longer than eight characters
           7     Extension longer than three characters
}
const
   Illegal:string[16] = ' +=/[]":;,?*<>|.';
var
   ECode: shortint;
   OldDIR,D,P,F,E: string;
   Loc: byte;
   Inf: SearchRec;                                {1.00b}

   function Legal(Str:string;AllowSlash:boolean): boolean;
   {}
   var I : integer;
   begin
      Legal := true;
      for I := 1 to 16 do
         if pos(Illegal[I],Str) <> 0 then
         begin
            Legal := false;
            exit;
         end;
      if not AllowSlash then
         if pos('\',Str) > 0 then
            legal := false;
   end;

begin
   ECode := 0;
   Loc := pos(':',FN);
   if Loc = 0 then
   begin
      D := '';
      P := FN;
   end
   else
   begin
      D := SetUpper(copy(FN,1,Loc));
      P := copy(FN,succ(Loc),255);
      if (Loc <> 2) or ((D[1] in ['A'..'Z'])=false) then
      begin
         ValidFileName := 1;
         exit;
      end;
   end;
   Loc := LastPos('\',P);
   if Loc = 0 then
   begin
      F := P;
      P := '';
   end
   else
   begin
      F := copy(P,succ(Loc),255);
      P := copy(P,1,pred(Loc));
   end;
   Loc := pos('.',F);
   if Loc = 0 then
      E := ''
   else
   begin
      E := copy(F,succ(Loc),255);
      F := copy(F,1,pred(Loc));
   end;
   if not legal(P,true) then
      Ecode := 2
   else
   begin
      if D+P <> '' then
      begin
         GetDir(0,OldDir);
         {$I-}
         ChDir(D+P);
         {$I+}
         if IOResult <> 0 then
         begin
            ValidFileName := 3;
            ChDir(OldDir);  {1.00d}
            exit;
         end
         else
            ChDir(OldDir);
      end;
      if (F='') and (E='') then
         Ecode := 4
      else
      begin
         if not Legal(F+E,false) then
            Ecode := 5
         else
         begin
            if length(F) > 8 then
               Ecode := 6
            else if length(E) > 3 then
               Ecode := 7;
         end;
      end;
   end;
   if Ecode = 0 then
   begin
      if not Exist(FN) then
         ECode := -1
      else
      begin                                {1.00b}
         findfirst(FN,Directory,Inf);
         if (DOSError <> 0) or ((DOSError = 0) and (Inf.Attr = Directory)) then
            ECode := -2;
      end
   end;
   ValidFileName := Ecode;
end; {ValidFileName}

function DeleteFile(Filename:string): shortint;
{Return codes:   -1    File not found
                  0    File deleted
                  1    Error - file not deleted.

}
var F: file;
begin
   if not Exist(Filename) then
      DeleteFile := -1
   else
   begin
      assign(F,Filename);
      {$I-}
      Erase(F);
      {$I+}
      if ioresult = 0 then
         DeleteFile := 0
      else
         DeleteFile := 1;
   end;
end; {DeleteFile}

function RenameFile(Oldname,NewName:string):shortint;
{Retcodes:     0 file renamed
               1 file not found
               2 rename failed
}
var F:file;
begin
   if not exist(OldName) then
      RenameFile := 1
   else
   begin
      assign(F,Oldname);
      {$I-}
      Rename(F,Newname);
      {$I+}
      if ioresult = 0 then
         RenameFile := 0
      else
         RenameFile := 2;
   end;
end; {RenameFile}

procedure ResetStartUpMode;
{resets monitor mode and cursor settings to the state they
 were in at program startup}
begin
   TextMode(StartMode);
   Screen.CursSize(StartTop,StartBot);
end; {ResetStartUpMode}

{IMPORTANT NOTE: You must use the $M compiler directive to instruct Turbo
Pascal to leave some memory for the spawned or child program, e.g. 
$M $8192,$8192,$8192. The precise values depend on the size of your program
..experiment. If the child process runs OK, try smaller values.}

function RunEXECOM(Progname, Params: string): integer;
{}
begin
   swapvectors;
   exec(Progname,Params);
   swapvectors;
   RunEXECOM := doserror;
end; {RunEXECOM}

function RunAnything(command: string):integer;
{}
var Comspec:string;
begin
   Comspec := GetEnv('COMSPEC');
   swapvectors;
   exec(comspec,'/C '+command);
   SwapVectors;
   RunAnything := doserror;
end; {RunAnything}

function RunDOS(Msg:string):integer;
{}
var Comspec:string;
begin
   Comspec := GetEnv('COMSPEC');
   swapvectors;
   writeln;
   writeln(Msg);
   exec(comspec,'');
   SwapVectors;
   RunDOS := doserror;
end; {RunDOS}
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
procedure MiscInit;
{initilizes objects and global variables}
begin
   LPTport := 0;  {LPT1}
   StartMode := LastMode; {record the initial state of screen when program was executed}
   Screen.CursSave;
   StartTop := Screen.vCursTop;
   StartBot := Screen.vCursBot;
end; {MiscInit}

{end of unit - add initialization routines below}
{$IFNDEF OVERLAY}
begin
   MiscInit;
{$ENDif}
end.



