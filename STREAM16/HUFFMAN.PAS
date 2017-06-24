{$B-}   { Use fast boolean evaluation. }

unit Huffman;   { Copyright D.J. Murdoch, (1992) }

{ Defines a Huffman compression filter to illustrate use of the TBitFilter. }

{ The THuffmanFilter object defined in this file isn't optimized as much as
  I'd like, so I haven't put it into the main Streams unit.  It's also a
  little rough - be careful if you use it.  If you make any substantial
  improvements, I'd like to see them! - djm}

interface

{$i StDefine.inc}

uses
  {$ifdef wobjects}  wobjects,   {$else}  objects,  {$endif}
  streams;

const
  MaxNode = 510;
  StoreSize = ((MaxNode-255)*18+7) div 8; { Bytes required to store the code
                                            table }

type
  PHuffmanfilter = ^THuffmanfilter;
  THuffmanfilter = object(TBitfilter)
    { This object defines a Huffman encoder/decoder which encodes the 256
      letter alphabet of bytes using variable length codes in the 2 letter
      alphabet of bits. }

    Size,                       { The size of the expanded stream. }
    Position : LongInt;         { The current position in the expanded stream }

    Counts : array[0..MaxNode] of longint; { Counts uncompressed characters;
                                         second half used as workspace }

    Decoder : array[256..MaxNode,TBit] of integer; { Array holding decoder }
    EncodeStates : array[0..MaxNode] of integer;   { The state change array }
    EncodeBits   : array[0..MaxNode] of TBit;      { The encoding bit for each
                                                 state }
    Learning : boolean;     { Signals whether writes are enabled, and whether
                              to attempt to decode reads. }

    constructor init(ABase:PStream);
    { Inits the Counts to 0, but doesn't set up a code.  Puts filter
      in "learning" mode.  Before setting Learning to false, be sure to
      call LoadCode or BuildCode. }

    procedure LoadCode;
    { Reads an encoding from the base stream. }

    procedure StoreCode;
    { Writes an encoding to the base stream. }

    procedure BuildCode;
    { Builds the optimal encoding based on the values in the Counts array }

    procedure BuildEncoder(Verify:boolean);
    { Initializes the Encode arrays based on the Decoder array.  Called
      automatically by LoadCode and BuildCode; use this routine only
      if you've loaded the Decoder in some other way. If Verify is true,
      it will check that the Decoder array is valid. }

    function CodeBits(b:byte):word;
    { Returns the number of bits that will be used in the current code
      to write b. }

    function PredictedSize:Longint;
    { Returns the predicted number of bytes to write the distribution of
      bytes given in Counts in the current encoding. }

    procedure read(var buf; count:word); virtual;
    procedure write(var buf; count:word); virtual;
    function getpos:longint; virtual;
    function getsize:longint; virtual;
   end;

implementation

constructor THuffmanFilter.Init(ABase:PStream);
begin
  if not TFilter.Init(ABase) then
    fail;
  Size := 0;
  Position := 0;
  FillChar(counts,sizeof(counts),0);
  Learning := true;
end;

procedure THuffmanFilter.LoadCode;
var
  i,code : integer;
begin
  for i:=256 to MaxNode do
  begin
    ReadBits(code,9);
    Decoder[i,0] := code;     { Should we confirm code<=MaxNode? }
    ReadBits(code,9);
    Decoder[i,1] := code;
  end;
  BuildEncoder(true);
end;

procedure THuffmanFilter.StoreCode;
var
  i : integer;
begin
  for i:=256 to MaxNode do
  begin
    WriteBits(Decoder[i,0],9);
    WriteBits(Decoder[i,1],9);
  end;
end;

procedure THuffmanFilter.BuildCode;
var
  letters : array[byte] of integer;  { The array of symbols }

    procedure Revsort;
  { Procedure to do a Quicksort on the array of letters,
    to put Counts[letters[i]] into decreasing order.
    Ties are broken by the letter order.
    Based on Quicksort as given in Steal This Code, by F.D. Boswell, Watcom 1986.
  }
    procedure quick(first,last : integer);
    var
      pivot : integer;
      temp : integer;
      scanright, scanleft : integer;
    begin
      if (first < last) then
      begin
        pivot := letters[first];
        scanright := first;
        scanleft := last;
        while scanright < scanleft do
        begin
          if Counts[letters[scanright+1]] < Counts[pivot] then
          begin
            if Counts[letters[scanleft]] >= Counts[pivot] then
            begin
              temp := letters[scanleft];
              inc(scanright);
              letters[scanleft] := letters[scanright];
              letters[scanright] := temp;
              dec(scanleft);
            end
            else
              dec(scanleft);
          end
          else
            inc(scanright);
        end;
        temp := letters[scanright];
        letters[scanright] := letters[first];
        letters[first] := temp;
        quick(first, scanright-1);
        quick(scanright+1, last);
      end;
    end;
  begin  {quicksort}
    quick(0, 255);
  end;

var
  i,LastEntry,LastLetter,PrevLetter,InsertAt : integer;
begin { BuildCode }
  for i:=0 to 255 do
    letters[i] := i;                 { Initialize to match counts }
  RevSort;                        { Sort into decreasing frequency }
  for i :=256 to MaxNode do
  begin
  { Create node by combining last two entries }
    LastEntry := 511-i;
    LastLetter := Letters[LastEntry];
    PrevLetter := Letters[LastEntry-1];
    Decoder[i,0] := PrevLetter;
    Decoder[i,1] := LastLetter;
    Counts[i] := Counts[PrevLetter] + Counts[LastLetter];
  { Find where to insert it }
    InsertAt := LastEntry-1;
    While (InsertAt > 0) and (Counts[Letters[InsertAt-1]] <= Counts[i]) do
      dec(InsertAt);
  { Insert the node }
    Move(Letters[InsertAt],Letters[InsertAt+1],
         (LastEntry-1-InsertAt)*sizeof(Integer));
    Letters[InsertAt] := i;
  end;
  BuildEncoder(false);
end;

procedure THuffmanFilter.BuildEncoder(verify:boolean);
var
  i,code : integer;
  j : TBit;
begin
  fillchar(EncodeBits,sizeof(EncodeBits),0);
  if verify then
  begin
    { First, confirm that all the Decoder values are in range }
    for i:=256 to MaxNode do
      for j:=0 to 1 do
        if (Decoder[i,j] < 0) or (Decoder[i,j] > MaxNode) then
        begin
          Error(stIntegrity,i);
          exit;
        end;
    { Initialize the EncodeStates to illegal values to detect missing
      codes }
    fillchar(EncodeStates,sizeof(EncodeStates),0);
  end;
  for i:=256 to MaxNode do
  begin
    EncodeStates[Decoder[i,0]] := i;
    code := Decoder[i,1];
    EncodeStates[code] := i;
    EncodeBits[code] := 1;
  end;
  if verify then
    for i:=0 to pred(MaxNode) do
      if EncodeStates[i] = 0 then
      begin
        Error(stIntegrity,i);
        exit;
      end;
end;

function THuffmanFilter.CodeBits(b:byte):word;
var
  state : 0..MaxNode;
  result : word;
begin
  result := 0;
  state := b;
  while state < MaxNode do
  begin
    inc(result);
    state := EncodeStates[state];
  end;
  CodeBits := result;
end;

function THuffmanFilter.PredictedSize:longint;
var
  bitcount : longint;
  b : byte;
begin
  bitcount := 0;
  for b:=0 to 255 do
    inc(bitcount,Counts[b]*CodeBits(b));
  PredictedSize := (bitcount+7) div 8;
end;

procedure THuffmanFilter.Read(var buf;Count:word);
var
  i : word;
  bbuf : TByteArray absolute buf;
  State : 0..MaxNode;
begin
  if CheckStatus then
  begin
    if learning then
      TBitFilter.Read(buf,Count)
    else
      for i:=0 to Count-1 do
      begin
        State := MaxNode;
        repeat
          State := Decoder[State,GetBit];
        until State < 256;
        bbuf[i] := State;
      end;
    for i:=0 to Count-1 do
      inc(Counts[bbuf[i]]);
    inc(position,Count);
    if Position>Size then
      Size := Position;
    CheckBase;
  end;
end;

procedure THuffmanFilter.Write(var buf;Count:word);
var
  bbuf : TByteArray absolute buf;
  i : word;
  bitstack : word;
  bitcount : word;
  words : word;
  state : 0..MaxNode;
begin
  if CheckStatus then
  begin
    for i:=0 to Count-1 do
      inc(Counts[bbuf[i]]);
    if not learning then
    begin
      for i:=0 to Count-1 do
      begin
        bitstack := 0;
        bitcount := 0;
        words := 0;
        state := bbuf[i];
        { Push all the bits onto the stack }
        while state < MaxNode do
        begin
          bitstack := 2*bitstack + EncodeBits[state];
          inc(bitcount);
          if bitcount = 16 then
          begin
            asm
              push bitstack
            end;
            bitstack := 0;
            bitcount := 0;
            inc(words);
          end;
          state := EncodeStates[state];
        end;
        { Now write out all the bits }
        WriteBits(bitstack,bitcount);
        while words > 0 do
        begin
          asm
            pop bitstack
          end;
          WriteBits(BitStack,16);
          dec(words);
        end;
      end;
      inc(position,count);
      if position>size then
        size := position;
      CheckBase;
    end;
  end;
end;

function THuffmanFilter.GetPos:longint;
begin
  GetPos := Position;
end;

function THuffmanFilter.GetSize:longint;
begin
  GetSize := Size;
end;

end.

