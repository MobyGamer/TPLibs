{               Copyright 1991 TechnoJock Software, Inc.               }
{                          All Rights Reserved                         }
{                         Restricted by License                        }

{                             Build # 1.10                             }

Unit totSYS;
{$I TOTFLAGS.INC}

{
 Development History:
             03/15/91  1.00a   Changed DesqView checks
             02/03/92  1.00b   Changed tDate to tOSDate (conflicted with TotDate)
             12/15/92  1.10    DPMI update
             03/13/17  trixfix TP 7.0 object stuff
}

INTERFACE

uses DOS, CRT, objects;

TYPE
tVideo = (UnKnown,Mono,CGA,MCGAMono,MCGACol,EGAMono,EGACol,VGAMono,VGACol);

tOSDate = (USA,Europe,Japan);

pDisplayOBJ = ^DisplayOBJ;
DisplayOBJ = object(TObject)
   vSnowProne : boolean;     {does system suffer from snow}
   vWidth : byte;            {no. of characters of display}
   vDepth: byte;             {no. of lines of display}
   vBaseOfScreen: pointer;   {location of video memory}   {5.00a}
   vDisplayType: tVideo;     {video display type}
   vForceBW: boolean;        {uses monochrome color schemes}
   {methods...}
   constructor Init;
   function    TestVideo: tVideo;
   function    SnowProne: boolean;
   function    GetMode: byte;
   function    ColorOn: boolean;
   function    Width: byte;
   function    Depth: byte;
   function    DisplayType: tVideo;
   procedure   SetCondensed;
   procedure   SetBW(on:boolean);
   procedure   Set25;
   function    BaseOfScreen:pointer;        {returns ptr to video memory}
   destructor  Done; VIRTUAL;
end; {DisplayOBJ}

pEquipOBJ = ^EquipOBJ;
EquipOBJ = object
   vMainInfo: word;
   vComputerID: byte;
   vRomDate: string[8];
   {methods...}
   constructor Init;
   function    ComputerID: byte;
   function    ParallelPorts: byte;
   function    SerialPorts: byte;
   function    FloppyDrives: byte;
   function    ROMDate: string;
   function    GameAdapter: boolean;
   function    SerialPrinter: boolean;
   function    MathChip: boolean;
   destructor  Done;
end; {EquipOBJ}

pMemOBJ = ^MemOBJ;
MemOBJ = object
   vMemInfo: word;
   vMaxExtMem: word;
   vMaxExpMem: word;
   vEMMInstalled: boolean;
   vEMMmajor: byte;
   vEMMminor: byte;
   {methods...}
   constructor Init;
   function    BaseMemory: integer;
   function    EMMInstalled: boolean;
   function    EMMVersionMajor: byte;
   function    EMMVersionMinor: byte;
   function    EMMVersion: string;
   function    MaxExtMem: word;
   function    MaxExpMem: word;
   function    ExtMemAvail: word;
   function    ExpMemAvail: word;
   destructor  Done;
end; {MemOBJ}

pOSOBJ = ^OSOBJ;
OSOBJ = object  {Operating System}
   vMajor: byte;
   vMinor: byte;
   vCountry: word;
   vDateFmt: tOSDate;
   vCurrency: string[5];
   vThousands: byte;
   vDecimal: byte;
   vDateSeparator: byte;
   vTimeSeparator: byte;
   vTimeFmt: byte;
   vCurrencyFmt: byte;
   vCurrencyDecPlaces: byte;
   {methods...}
   constructor Init;
   function OSVersionMajor: byte;
   function OSVersionMinor: byte;
   function OSVersion: string;
   function Country: word;
   function Currency: string;
   function DateFmt: tOSDate;
   function TimeFmt: byte;
   function ThousandsSep: char;
   function DecimalSep: char;
   function DateSep: char;
   function TimeSep: char;
   function CurrencyFmt: byte;
   function CurrencyDecPlaces: byte;
   destructor  Done;
end; {OSOBJ}

procedure sysINIT;

VAR
  Monitor: ^DisplayObj;

IMPLEMENTATION
{||||||||||||||||||||||||||||||||||||}
{                                    }
{     D I S P L A Y    S T U F F     }
{                                    }
{||||||||||||||||||||||||||||||||||||}
constructor DisplayObj.Init;
{This entire section reformatted, bugfixed, and expanded by trixter}
var
  Mode,b:byte;
  Regs:Registers;
begin
  Inherited Init;
  vDisplayType := TestVideo;
(* Disabled due to driver conflicts
   with Regs do
   begin
      AX := $2B01;       {1.00a DesqViewTest}
      CX := $4445;
      DX := $5351;
      intr($21,Regs);
      if Al <> $FF then {DesqView present}
      begin
         Ah := $FE;
         Intr($10,Regs);
         vBaseOfScreen := ptr(ES,DI);
      end
      else
      begin
         Mode := GetMode;
         if Mode = 7 then
            vBaseOfScreen := ptr($B000,0)  {Mono}
         else
            vBaseOfScreen := ptr($B800,0); {Color}
      end;
   end;
*)
  Mode := GetMode;
  if Mode = 7
    then vBaseOfScreen := ptr(segB000,0)  {Mono}
    else vBaseOfScreen := ptr(segB800,0); {Color}
   vSnowProne := (vDisplayType = CGA);
   vWidth := 80;
   {trixfix} {Let's get the *actual* number of columns.}
   asm
        mov     ah,0fh
        int     10h
        les     di,self
        mov     es:[di.vWidth],ah
   end;
   {trixfix} {40-column mode doesn't need snow checking on any adapter}
   if vWidth<=40 then vSnowProne:=false;
   {trixfix} {PCjr and Tandy don't need snow checking either}
   if vDisplayType=CGA then begin
     b:=0;
     asm
        mov     ax,$FFFF
        mov     es,ax
        mov     di,$000E                {second to last byte PCjr/Tandy BIOS info area }
        cmp     byte ptr es:[di],$FD    {ends up $FD only on the Jr. }
        jne     @notJr
        mov     b,1                     {1 = PCjr}
        jmp     @done
@notJr:                                 {not PCjr; test for tandy series}
        cmp     byte ptr es:[di],$FF    {all Tandys have $FF here}
        jne     @notTandy
        mov     ax,$FC00
        mov     es,ax
        xor     di,di
        mov     al,$21
        cmp     byte ptr es:[di],$21
        jne     @notTandy
        mov     ah,$C0
        int     $15                     {get system environment}
        jnc     @tandySLTL              {early Tandys don't honor this, TL/SL does}
        mov     b,2                     {tandy1000}
        jmp     @done
@tandySLTL:
        mov     b,3                     {tandySLTL}
        jmp     @done
@notTandy:
        mov     b,0                     {no PCjr, Tandy found}
@done:
     end;
   if b<>0 then vSnowProne:=false;
   end;

   vDepth := succ(Hi(WindMax));
   {trixfix} {Let's get the *actual* number of rows.}
   asm
   {
   Number of rows not returned by BIOS.  Have to calc number of rows from:
       40:4A	word	Number of screen columns
       40:4C	word	Size of current video regen buffer in bytes
       40:84	byte	Rows on the screen (less 1, EGA+)

   Try to get from 40:84 first.  If early BIOS has that empty, then calc
   it based on the info it does give us.
   }
        mov     ax,40h
        mov     es,ax
        mov     al,es:[84h]
        cmp     al,0                    {our BIOS new enough to populate this?}
        jne     @newbios                {if so, use it}
        mov     bx,es:[4ah]             {if not, calc ourselves}
        mov     ax,es:[4ch]
        shr     ax,1
        div     bl
        dec     al
@newbios:
        inc     al
        les     di,self
        mov     es:[di.vDepth],al
   end;

   vForceBW := false;
end; {DisplayObj.Init}

{trixfix} {video subsystem detection code replaced}
{Replaced with Richard Wilton code; original code couldn't detect CGA.}
type
  VidType=record
    SubSystem,Display:byte;
  end;
  VidArray=array[0..1] of VidType;

Procedure _VideoID(var foo:VidArray); far; external; {$L videoid.obj}

var
  VidInfo:VidArray;

function DisplayOBJ.TestVideo: tVideo;
var
  temp:tVideo;

begin
  _videoID(VidInfo);
  case VidInfo[0].SubSystem of
    0:temp:=unknown;
    1:temp:=MONO;
    2:temp:=CGA;
    3:temp:=EGAcol;
    4:if VidInfo[0].Display=5
        then temp:=MCGAcol
        else temp:=MCGAMono;
    5:if VidInfo[0].Display=5
        then temp:=VGAcol
        else temp:=VGAMono;
    80..82:temp:=mono; {Hercules}
  end;

  TestVideo := Temp;
end; {DisplayOBJ.TestVideo}

function DisplayObj.GetMode;
{}
var Regs : registers;
begin
   with Regs do
   begin
      Ax := $0F00;
      Intr($10,Regs);  {get video display mode}
      GetMode := Al;
   end;
end; {DisplayObj.GetMode}

function DisplayObj.ColorOn: boolean;
{}
begin
   if (vForceBW)
   or (DisplayType in [Mono, MCGAMono, EGAMono, VGAMono])
   or (GetMode = 2) or (GetMode = 0) then {Mode BW?0 active}
      ColorOn := False
   else
      ColorOn := true;
end; {DisplayObj.ColorOn}

procedure DisplayOBJ.SetBW(On:boolean);
{}
begin
   vForceBW := On;
end; {DisplayOBJ.SetBW}

function DisplayObj.BaseOfScreen: pointer;
{}
begin
    BaseofScreen := vBaseOfScreen; {1.00a}
end; {DisplayObj.BaseOfScreen}

function DisplayObj.SnowProne: boolean;
{}
begin
   SnowProne := vSnowProne;
end; {DisplayObj.SnowProne}

function DisplayObj.Width: byte;
{}
begin
   Width := vWidth;
end; {DisplayObj.Width}

function DisplayObj.Depth: byte;
{}
begin
   Depth := vDepth;
end; {DisplayObj.Depth}

function DisplayObj.DisplayType: tVideo;
{}
begin
    DisplayType := vDisplayType;
end; {DisplayObj.DisplayType}

procedure DisplayObj.SetCondensed;
{sets to maximum number od display lines supported by the display system}
begin
   if vDisplayType in [EGAMono,EGACol,VGAMono,VGACol] then
   begin
      TextMode(Lo(LastMode)+Font8x8);
      vDepth := succ(Hi(WindMax));
   end;
end; {DisplayObj.SetCondensed}

procedure DisplayObj.Set25;
{resets display back to 25 lines}
begin
   if Depth <> 25 then
   begin
      TextMode(Lo(LastMode));
      vDepth := succ(Hi(WindMax));
   end;
end; {DisplayObj.Set25}

destructor DisplayObj.Done;
begin end;

{||||||||||||||||||||||||||||||||||||}
{                                    }
{       E Q U I P    S T U F F       }
{                                    }
{||||||||||||||||||||||||||||||||||||}

constructor EquipOBJ.Init;   {1.10}
{}
var
  Reg: registers;
  IDPtr: pointer;
  ROMPtr: pointer;
begin
   intr($11,Reg);
   vMainInfo := Reg.AX;
{$IFDEF DPMI}
   vComputerID := 0;
   vRomdate := 'Unknown';
{$ELSE}
   IDPtr := ptr($F000,$FFFE);
   vComputerID := byte(IDPtr^);
   ROMPtr := ptr($F000,$FFF5);
   move(ROMPtr^,vROMDate[1],8);
   vROMDate[0] := chr(8);
{$ENDIF}
end; {of const EquipOBJ.Init}

function EquipOBJ.ComputerID: byte;
{}
begin
   ComputerID := vComputerID;
end; {EquipOBJ.ComputerID}

function EquipOBJ.ParallelPorts: byte;
{}
begin
   ParallelPorts := hi(vMainInfo) shr 6;
end; {EquipOBJ.ParallelPorts}

function EquipOBJ.SerialPorts: byte;
{}
begin
   SerialPorts := hi(vMainInfo) and $0F shr 1;
end; {EquipOBJ.SerialPorts}

function EquipOBJ.FloppyDrives: byte;
{}
begin
   FloppyDrives := ((vMainInfo and $C0) shr 6) + 1;
end; {EquipOBJ.FloppyDrives}

function EquipOBJ.ROMDate: string;
{}
begin
   ROMDate := vROMDate;
end; {EquipOBJ.ROMDate}

function EquipOBJ.GameAdapter: boolean;
{}
begin
   GameAdapter := ((vMainInfo and $1000) = 1);
end; {EquipOBJ.GameAdapter}

function EquipOBJ.SerialPrinter: boolean;
{}
begin
   SerialPrinter := ((vMainInfo and $2000) = 1);
end; {EquipOBJ.SerialPrinter}

function EquipOBJ.MathChip: boolean;
{}
begin
   MathChip := ((vMainInfo and $2) = $2);
end; {EquipOBJ.mathChip}

destructor EquipOBJ.Done;
begin end;

{||||||||||||||||||||||||||||||||}
{                                }
{       M E M    S T U F F       }
{                                }
{||||||||||||||||||||||||||||||||}

constructor MemOBJ.Init;
{}
const
   FingerPrint: string[8] = 'EMMXXXX0';
var
   Regs: registers;
   ID: string[8];
begin
{$IFDEF DPMI}
   vEMMInstalled := false;
{$ELSE}
   intr($12,Regs);
   vMemInfo := Regs.AX;
   with regs do
   begin
      Ah := $35;
      Al := $67;
      Intr($21,Regs); {ES now points to int $67 segment -- id is 10 bytes on}
      move(mem[ES:$000A],ID[1],8);
      ID[0] := chr(8);
      vEMMInstalled := (ID = FingerPrint);
   end;
{$ENDIF}
   vEMMMajor := 0;
   vEMMMinor := 0;
   if EMMInstalled then
   begin
      {get total expanded memory}
      Regs.Ah := $42;
      intr($67,Regs);
      vMaxExpMem := Regs.DX * 16;
      {get driver version number}
      Regs.Ah := $46;
      intr($67,Regs);
      if Regs.Ah = 0 then
      begin
          vEMMMajor := Regs.Al shr 4;
          vEMMMinor := Regs.AL and $F;
      end;
   end
   else
      vMaxExpMem := 0;
end; {of const MemOBJ.Init}

function MemOBJ.BaseMemory: integer;
{}
begin
   BaseMemory := vMemInfo;
end; {MemOBJ.BaseMemory}

function MemOBJ.EMMInstalled: boolean;
{}
begin
   EMmInstalled := vEMMInstalled;
end; {MemOBJ.EMMInstalled}

function MemOBJ.ExtMemAvail: word;
{}
var regs : registers;
begin
   Regs.Ah := $88;
   Intr($15,Regs);
   ExtMemAvail := Regs.AX;
end; {MemOBJ.ExtMemAvail}

function MemOBJ.ExpMemAvail: word;
{}
var regs : registers;
begin
   if EMMInstalled then
   begin
      Regs.Ah := $42;
      intr($67,Regs);
      ExpMemAvail := Regs.BX * 16;
   end
   else
      ExpMemAvail := 0;
end; {MemOBJ.NetExpMemory}

function MemOBJ.MaxExpMem: word;
{}
begin
   MaxExpMem := vMaxExpMem
end; {MemOBJ.MaxExpMem}

function MemOBJ.MaxExtMem: word;
{}
begin
   MaxExtMem := vMaxExtMem
end; {MemOBJ.MaxExtMem}

function MemOBJ.EMMVersionMajor: byte;
{}
begin
   EMMVersionMajor := vEMMMajor;
end; {MemOBJ.EMMVersionMajor}

function MemOBJ.EMMVersionMinor: byte;
{}
begin
   EMMVersionMinor := vEMMMinor;
end; {MemOBJ.EMMVersionMinor}

function MemOBJ.EMMVersion: string;
{}
begin
   EMMVersion := chr(EMMVersionMajor + 48)+'.'+chr(EMMVersionMinor + 48);
end; {MemOBJ.EMMVersion}


destructor MemOBJ.Done;
begin end;

{||||||||||||||||||||||||||||||||}
{                                }
{       O. S.    S T U F F       }
{                                }
{||||||||||||||||||||||||||||||||}
constructor OSObj.Init;
{}
var
   Regs: registers;
   CountryBuf: array[0..$21] of byte;
   P: byte;
   W: word absolute CountryBuf;
begin
   with regs do
   begin
      Ah := $30;
      msdos(Regs);
      vMajor := Al;
      vMinor := Ah;
      AX := $3800;
      DS := seg(CountryBuf);
      DX := ofs(CountryBuf);
      intr($21,Regs);
      vCountry := Regs.BX;
      if vMajor >= 3 then
      begin
         vDateFmt := tOSDate(W);
         vCurrency := '     ';
         move(CountryBuf[$2],vCurrency[1],5);
         P := pos(#0,vCurrency);      {ASCIIZ string form}
         if P > 0 then
            delete(vCurrency,P,5);
         vThousands := CountryBuf[$7];
         vDecimal := CountryBuf[$9];
         vDateSeparator := CountryBuf[$B];
         vTimeSeparator := CountryBuf[$D];
         vTimeFmt := CountryBuf[$11];
         vCurrencyFmt := CountryBuf[$F];
         vCurrencyDecPlaces := CountryBuf[$10];
      end
      else
      begin
         vDateFmt := tOSDate(W);
         vCurrency := chr(CountryBuf[$2]);
         vThousands := CountryBuf[$04];
         vDecimal := CountryBuf[$06];
         vDateSeparator := ord('/');   {not avialable before DOS 3}
         vTimeSeparator := ord(':');
         vTimeFmt := 1;
         vCurrencyFmt := 0;
         vCurrencyDecPlaces := 2;
      end;
   end;
end; {of const OSObj.Init}

function OSObj.OSVersionMajor: byte;
{}
begin
   OSVersionMajor := vMajor;
end; {OSObj.OSVersionMajor}

function OSObj.OSVersionMinor: byte;
{}
begin
   OSVersionMinor := vMinor;
end; {OSObj.OSVersionMinor}

function OSObj.OSVersion: string;
{}
begin
   OSVersion := chr(OSVersionMajor + 48)+'.'+chr(OSVersionMinor + 48);
end; {OSObj.OSVersion}

function OSObj.Country: word;
{}
begin
   Country := vCountry;
end; {OSObj.Country}

function OSObj.Currency: string;
{}
begin
   Currency := vCurrency;
end; {OSObj.Currency}

function OSObj.DateFmt: tOSDate;
{}
begin
   DateFmt := vDateFmt;
end; {OSObj.DateFmt}

function OSObj.ThousandsSep: char;
{}
begin
   ThousandsSep := chr(vThousands);
end; {OSObj.ThousandsSep}

function OSObj.DecimalSep: char;
{}
begin
   DecimalSep := chr(vDecimal);
end; {OSObj.DecimalSep}

function OSObj.DateSep: char;
{}
begin
   DateSep := chr(vDateSeparator);
end; {OSObj.DateSep}

function OSObj.TimeSep: char;
{}
begin
   TimeSep := chr(vTimeSeparator);
end; {OSObj.TimeSep}

function OSObj.TimeFmt: byte;
{}
begin
   TimeFmt := vTimeFmt;
end; {OSObj.TimeFmt}

function OSObj.CurrencyFmt: byte;
{}
begin
   CurrencyFmt := vCurrencyFmt;
end; {OSObj.CurrencyFmt}

function OSObj.CurrencyDecPlaces: byte;
{}
begin
   CurrencyDecPlaces := vCurrencyDecPlaces;
end; {OSObj.CurrencyDecPlaces}

destructor OSObj.Done;
begin end;
{|||||||||||||||||||||||||||||||||||||||||||||||}
{                                               }
{     U N I T   I N I T I A L I Z A T I O N     }
{                                               }
{|||||||||||||||||||||||||||||||||||||||||||||||}
procedure SysInit;
{initilizes objects and global variables}
begin
   new(Monitor,Init);
end;

{end of unit - add intialization routines below}
{$IFNDEF OVERLAY}
begin
   {$IFDEF INITTRACE}writeln('sysinit');{$ENDIF}
   SysInit;
{$ENDIF}
end.


