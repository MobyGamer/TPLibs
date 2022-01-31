{$R-,S-,Q-,O-}
unit Streams;
{ Unit to provide enhancements to TV Objects unit streams in the form
  of several filters, i.e. stream clients, and other streams. }

{#Z+}  { These comments don't need to go into the help file. }

{$B-}   { Use fast boolean evaluation. }

{ Version 1.2 - Adds TNulStream and TXMSStream, from suggestion and
                code by Stefan Boether; TBitFilter, from suggestion
                by Rene Seguin; added call to Flush to TFilter.Done;
                UseBuf and OwnMem to TRAMStream.
                TTextFilter fixed so that mixed access methods work.
          1.3 - Added TDupFilter, TSequential, CRCs and Checksums
          1.4 - Recoded several of the TRAMStream methods in assembler for
                more speed; fixed numerous TTextFilter bugs and added
                TTextFilter.AssignStream and TextDemo.pas; fixed
                TXMSStream.Seek bug.  Changed xms_Memavail and xms_Maxavail
                to report in bytes, and added ems_Memavail and ems_Maxavail
                (based on code sent to me by Eyal Doron) and disk_Memavail
                and disk_Maxavail. Changed TXMSStream.Init to match
                TEMSStream.Init. Added TConcatFilter, TLimitFilter,
                TLoopFilter, TReverseFilter and TWorkStream.  Added OwnsBase
                field to TFilter.  Did some testing to assure that the unit
                works in BP 7 protected mode.  Thanks to Max Maschein, Eyal
                Doron, and others for bug fix help.
          1.5 - The first public release of the 1.4 enhancements.
          1.6 - fixed some bugs when Getmem returns nil
                fixed bug in ReverseBytes
                fixed bug in termination of TLZWstream
                added workaround for TEMSStream bug, FastCopy
          1.7 - (JL) Removed TRAMStream, as BP7's objects.pas comes with
                TMemoryStream which is more practical (no 64K limit).
                Changed all instances of TRAMStream to TMemoryStream.
                Added 64K overhead to tempstream checks when using RAMSTREAM
                to handle the temp 64K buffer created by FastCopy.

{ Load some conditional defines }
{$i STDefine.inc}

{$ifdef overlays}
  {$O-}
  { Don't overlay this unit; it contains code that needs to participate
         in overlay management. }
{$endif}

{  Hierarchy:

   TStream                  (from Objects)
     TFilter                Base type for filters
       TEncryptFilter       Encrypts as it writes; decrypts as it reads
       TLZWFilter           Compresses as it writes; expands as it reads
       TTextFilter          Provides text file interface to stream
       TLogFilter           Provides logging of text file activity
       TBitFilter           Allows reads & writes by the bit
       TDupFilter           Duplicates output, checks for matching input
       TConcatFilter        Concatenates two streams
       TLimitFilter         Limits I/O to a specific range
         TLoopFilter        Joins end of stream to start
       TReverseFilter       Reads and writes the stream in reverse order
       TSequential          Filter that doesn't allow Seek
         TChksumFilter      Calculates 16 bit checksum for reads and writes
         TCRC16Filter       Calculates XMODEM-style 16 bit CRC
         TCRCARCFilter      Calculates ARC-style 16 bit CRC
         TCRC32Filter       Calculates ZIP/ZModem-style 32 bit CRC
     TNulStream             Eats writes, returns constant on reads
     TEMSStream2            Bug workaround for Borland's TEMSStream
     TXMSStream             Stream in XMS
     TDOSStream             (from Objects)
       TBufStream           (from Objects)
         TNamedBufStream    Buffered file stream that knows its name
           TTempBufStream   Buffered file stream that erases itself when done
     TWorkStream            Stream that grows as needed

   Procedures & functions:

   TempStream      allocates a temporary stream
   OvrInitStream   like OvrInitEMS, but buffers overlays on a stream
                   May be called several times to buffer different
                   segments on different streams.
   OvrDetachStream detaches stream from overlay system
   OvrDisposeStreams detaches all streams from overlay system and disposes of
                   them
   OvrSizeNeeded   Calculates the size needed to load the rest of the segments
                   to a stream
   OvrLoadAll      immediately copies as many overlay segments to the stream
                   as will fit
   UpdateChkSum    updates a 16 bit checksum value
   UpdateCRC16     updates a CRC16 value
   UpdateCRCARC    updates a CRCARC value
   UpdateCRC32     updates a CRC32 value
   ReverseBytes    reverses the byte order within a buffer

}
{#Z-}

interface

uses
  {$ifdef windows}
  strings,windos,winprocs,
  {$else}
  DOS,
  {$endif}
  {$ifdef overlays}
  Overlay,
  {$endif}
  {$ifdef wobjects}
  Wobjects;
  {$else}
  Objects;
  {$endif}

const
  stBadMode = 1;                  { Bad mode for stream - operation not
                                    supported.  ErrorInfo = mode. }
  stStreamFail = 2;               { Stream init failed }
  stBaseError = 3;                { Error in base stream. ErrorInfo = base error value }
  stMemError = 4;                 { Not enough memory for operation }
  stSigError = 5;                 { Problem with LZ file signature }
  stUsedAll = 6;                  { Used limit of allocation }
  stUnsupported = 7;              { Operation unsupported in this stream }
  stBase2Error = 8;               { Error in second base.  ErrorInfo = base2 error value }
  stMisMatch = 9;                 { Two bases don't match.  ErrorInfo = mismatch position
                                    in current buffer. }
  stIntegrity = 10;               { Stream has detected an integrity error
                                    in a self check.  Info depends on
                                    stream type. }
type
  TOpenMode = $3C00..$3DFF;       { Allowable DOS stream open modes }
  {$ifdef windows}
  FNameStr = PChar;            { To make streams take names as in the manual. }
  {$endif}

  PFilter = ^TFilter;
  TFilter =
    object(TStream)
    { Generic object to filter another stream.  TFilter just passes everything
      through, and mirrors the status of the base stream }

      Base : PStream;
      { Pointer to the base stream. }

      Startofs : LongInt;
      { The offset of the start of the filter in the base stream. }

      OwnsBase : Boolean;
      { Defaults true; if set to false, then #Done# won't dispose of
        the base. }

      constructor Init(ABase : PStream);
        { Initialize the filter with the given base. }

      destructor Done; virtual;
        { Flush filter, then dispose of base if #OwnsBase#. }

      function GetPos : LongInt; virtual;
      function GetSize : LongInt; virtual;
      procedure Read(var Buf; Count : Word); virtual;
      procedure Seek(Pos : LongInt); virtual;
      procedure Truncate; virtual;
      procedure Write(var Buf; Count : Word); virtual;
      procedure Flush; virtual;

      function CheckStatus : Boolean; virtual;
    { Return true if status is stOK.
      If status is stOK, but base is not, then reset the base.  This is a poor
      substitute for a virtual Reset method. }

      procedure CheckBase;
        { Check base stream for error, and copy status using own Error method. }
    end;

  PEncryptFilter = ^TEncryptFilter;
  TEncryptFilter =
    object(TFilter)
  { Filter which encrypts text going in or out; encrypting twice with the same
    key decrypts. Not very sophisticated encryption. }

      Key : LongInt;
      { Key is used as a Randseed replacement }

      constructor Init(Akey : LongInt; ABase : PStream);
        { Init with a given key }

      procedure Read(var Buf; Count : Word); virtual;
      procedure Seek(Pos : LongInt); virtual;
      procedure Write(var Buf; Count : Word); virtual;
    end;

const
  MaxStack = 4096;                { Must match lzwstream.asm declaration! }

type
  PLZWTables = ^TLZWTables;
  TLZWTables =
    record
      Collision : array[0..MaxStack-1] of Byte; { Hash table entries }
      PrefixTable : array[0..MaxStack-1] of Word; { Code for preceding stringf }
      SuffixTable : array[0..MaxStack-1] of Byte; { Code for current character }
      ChildTable : array[0..MaxStack-1] of Word; { Next duplicate in collision
                                                 list. }
      CharStack : array[0..MaxStack-1] of Byte; { Decompression stack }
      StackPtr : Word;            { Decompression stack depth }
      Prefix : Word;              { Previous code string }
      TableUsed : Word;           { # string table entries used }
      InputPos : Word;            { Index in input buffer }
      OutputPos : Word;           { Index in output buffer }
      LastHit : Word;             { Last empty slot in collision
                                                 table. }
      CodeBuf : Word;
      SaveIP : Word;
      SaveAX : Word;
      SaveCX : Word;
      SaveDX : Word;

      NotFound : Byte;            { Character combination found
                                                 flag. }
    end;

  PLZWFilter = ^TLZWFilter;
  TLZWFilter =
    object(TFilter)
      Mode : Word;                { Either stOpenRead or stOpenWrite. }
      Size,                       { The size of the expanded stream. }
      Position : LongInt;         { The current position in the expanded stream }
      Tables : PLZWTables;        { Tables holding the compressor state. }

      constructor Init(ABase : PStream; AMode : TOpenMode);
    {  Create new compressor stream, to use ABase as the source/destination
       for data.  AMode must be stOpenRead or stOpenWrite. }

      destructor Done; virtual;
    {  Flushes all data to the stream, and writes the uncompressed
       filesize to the head of it before calling TFilter.done. }

      procedure Flush; virtual;
      function GetPos : LongInt; virtual;
      function GetSize : LongInt; virtual;
      procedure Read(var Buf; Count : Word); virtual;

      procedure Seek(Pos : LongInt); virtual;
    {  Seek is not supported at all in Write mode.  In Read mode, it is
       slow for seeking forwards, and very slow for seeking backwards:
       it rewinds the file to the start and readforward from there. }

      procedure Truncate; virtual;
    {  Truncate is not supported in either mode, and always causes a
       call to Error. }

      procedure Write(var Buf; Count : Word); virtual;
    end;

type
  PTextFilter = ^TTextFilter;
  TTextFilter =
    object(TFilter)
  { A filter to provide ReadLn/WriteLn interface to a stream.  First
    open the stream and position it, then pass it to this filter;
    then Reset, Rewrite, or Append the Textfile variable, and do all
    reads and writes to it; they'll go to the stream through a TFDD.
    You can also assign the stream to any other text variable using
    the #AssignStream# method. }

      TextFile : Text;
      { A fake text file to use with Read(ln)/Write(ln). }
      TextPtr  : ^text;
      { A pointer to the text file used by the filter.  Initialized
        to point to TextFile, but #AssignStream# will change TextPtr. }

      constructor Init(ABase : PStream; AName : String);
    { Initialize the interface to ABase; stores AName in the name field of
      #Textfile#.  AName isn't used beyond this, but may be helpful
      if you choose to watch the TextFile field in the debugger.  }

      destructor Done; virtual;
      { Flushes the text file, then closes and disposes of the base stream. }

      procedure AssignStream(var NewText:text; AName : String);
      { Close the currently assigned text file, and assign a new one.
        As with #Init#, the name is stored in NewText, but is not otherwise
        used.}

      function GetPos : LongInt; virtual;
      function GetSize : LongInt; virtual;
      procedure Flush; virtual;
      procedure Read(var Buf; Count : Word); virtual;
      procedure Seek(Pos : LongInt); virtual;
      procedure Truncate; virtual;
      procedure Write(var Buf; Count : Word); virtual;
    end;

type
  PLogFilter = ^TLogFilter;
  TLogFilter =
    object(TFilter)
      { A filter to log activity on a text file. }

      LogList : ^Text;            { A pointer to the first logged file }

      constructor init(ABase:PStream);
      { Initializes filter, but doesn't start logging anything }

      destructor Done; virtual;
      { Stops logging all files, and closes & disposes of the base stream }

      procedure Log(var F : Text);
    { Logs all input and output to F to the stream.  You must do the Assign to
      F first, and not do another Assign without closing F. }

      function Unlog(var F : Text) : Boolean;
    { Stops logging of F.  Called automatically if file is closed. Returns
      false and does nothing on error. }
    end;

  TBit = 0..1;                    { A single bit }

  PBitFilter = ^TBitFilter;
  TBitFilter =
    object(TFilter)
      BitPos : ShortInt;
      { Position of stream relative to base file.  Negative values signal
        that the buffer is unchanged from the file, positive values signal
        that the file needs to be updated.  Zero signals an empty buffer. }
      Mask : Byte;                { Mask to extract next bit from buffer }
      Buffer : Byte;              { Buffer of next 8 bits from stream }
      AtEnd : Boolean;            { Flag to signal that we're at the end
                                    of the base, and we shouldn't read
                                    it.  Bases that change in length should
                                    set this to false. }

      constructor Init(ABase : PStream);

      procedure Flush; virtual;   { Flush buffer to stream }
      procedure Seek(Pos : LongInt); virtual; { Seek to bit at start of
                                               pos byte. }
      procedure Read(var Buf; Count : Word); virtual;
      procedure Write(var Buf; Count : Word); virtual;

      function GetBit : TBit;     { Get next bit from stream }
      function GetBits(Count : Byte) : LongInt; { Get up to 32 bits }
      procedure ReadBits(var Buf; Count : LongInt); { Read bits from stream }

      procedure PutBit(ABit : TBit); { Put one bit to stream }
      procedure PutBits(ABits : LongInt; Count : Byte); { Put up to 32 bits,
                                                          low bits first. }
      procedure WriteBits(var Buf; Count : LongInt); { Write count bits to stream }

      procedure SeekBit(Pos : LongInt); { Seek to particular bit }
      function GetBitPos : LongInt;

      procedure CopyBits(var S : TBitFilter; Count : LongInt); { Copy bits from S }
      procedure ByteAlign;        { Seek forward to next byte boundary. }

      procedure PrepareBuffer(ForRead : Boolean);
        { Internal method to assure that buffer is valid }
    end;

  PDupFilter = ^TDupFilter;
  TDupFilter =
    object(TFilter)         { Duplicates output, confirms matching input }
      Base2 : PStream;
      { Pointer to the second base. }

      Startofs2 : LongInt;
      { The offset of the start of the filter in the second base. }

      constructor Init(ABase, ABase2 : PStream);
        { Initialize the filter with the given bases. }

      destructor Done; virtual;
        { Flush filter, then dispose of both bases. }

      function MisMatch(var buf1,buf2; count:word):word; virtual;
        { Checks for a mismatch between the two buffers.  Returns
          the byte number of the mismatch (1 based), or 0 if they
          test equal.  This default method checks for an exact match. }

      procedure Read(var Buf; Count : Word); virtual;
      procedure Seek(Pos : LongInt); virtual;
      procedure Truncate; virtual;
      procedure Write(var Buf; Count : Word); virtual;
      procedure Flush; virtual;

      function CheckStatus : Boolean; virtual;
    { Return true if status is stOK.
      If status is stOK, but base is not, then reset the base.  This is a poor
      substitute for a virtual Reset method. }

      procedure CheckBase2;
        { Check 2nd base stream for error, and copy status using own Error method. }
    end;

  PConcatFilter = ^TConcatFilter;
  TConcatFilter =
    object(TFilter)
      { A filter which acts to concatenate two streams (or parts of streams)
        so that they appear as one.}
      Base2 : PStream;
        { Pointer to the second base.  This one logically follows the first.}

      Startofs2 : LongInt;
        { The offset of the start of the filter in the second base. }

      Position : Longint;
        { The current position of the filter.  The corresponding
          base stream is kept synchronized with this }
      Base1Size : Longint;
        { This is used a lot to determine switching. }

      constructor Init(ABase, ABase2 : PStream);        { Initialize the filter with the given bases. }

      destructor Done; virtual;
        { Flush filter, then dispose of both bases. }

      function GetPos:longint; virtual;
      function GetSize:longint; virtual;
      procedure Read(var Buf; Count : Word); virtual;
      procedure Seek(Pos : LongInt); virtual;
      procedure Truncate; virtual;
      procedure Write(var Buf; Count : Word); virtual;
      procedure Flush; virtual;
      { These methods work directly on Base until its size
        is reached, then switch over to Base2.  Base will *never* grow
        from the size at stream initialization. }

      function CheckStatus : Boolean; virtual;

      procedure CheckBase2;
        { Check 2nd base stream for error, and copy status using own Error method. }

    end;

  PLimitFilter = ^TLimitFilter;
  TLimitFilter =
    object(TFilter)
      { Limits all access to the bytes between LoLimit and HiLimit. }
      LoLimit,HiLimit : longint;
      { The lower and upper limit points.  These are in the TFilter
        scale, i.e. relative to #TFilter.Base#. }
      constructor init(ABase:PStream;ALoLimit,AHiLimit:longint);
      { Does the usual init, sets the limits, then does a Seek to ALoLimit
        if it is non-zero. }

      function GetSize:longint; virtual;
      { Returns the smaller of HiLimit and the #TFilter.GetSize# value. }

      procedure Read(var Buf; Count : Word); virtual;
      procedure Seek(Pos : LongInt); virtual;
      procedure Write(var Buf; Count : Word); virtual;
    end;

  PLoopFilter = ^TLoopFilter;
  TLoopFilter =
    object(TLimitFilter)
      { Moves all access to the bytes between LoLimit and HiLimit. }
      function GetSize:longint; virtual;
      { Returns the smaller of the size between the limits, or from
        the low limit to the end of the base }
      procedure Read(var Buf; Count : Word); virtual;
      procedure Seek(Pos : LongInt); virtual;
      procedure Write(var Buf; Count : Word); virtual;
    end;



  PReverseFilter = ^TReverseFilter;
  TReverseFilter =
    object(TFilter)
      { Reads and writes the base in reverse order. }
      ReverseBlocks : Boolean;  { Whether to reverse the bytes within
                                  a Read/Write block }
      constructor init(ABase:PStream; AReverseBlocks:boolean);
      { Standard initialization }
      function GetPos:longint; virtual;
      { Returns the position in bytes from the end of the base }
      procedure Read(var Buf; Count : Word); virtual;
      { See #Write#. }
      procedure Write(var Buf; Count : Word); virtual;
      { These methods read/write the block of bytes just previous to
        the current base file pointer.  The bytes themselves are
        reversed if #ReverseBlocks# is true. }
      procedure Seek(Pos : LongInt); virtual;
      { Does the Seek in the reversed byte order, i.e. count from the
        end of the stream }
      procedure Truncate; virtual;
      { Triggers an #stUnsupported# error. }
    end;

  procedure ReverseBytes(var Buf; Count : Word);
  { Reverses the order of the bytes in the buffer }

type
  PSequential = ^TSequential;
  TSequential =
    object(TFilter)                        { Filter for sequential access only }
      procedure Seek(pos:longint); virtual;{ Signals stUnsupported if a Seek is attempted }
    end;

  PChksumFilter = ^TChksumFilter;
  TChksumFilter =
    object(TSequential)                    { Calculates 16 bit checksum of
                                             bytes read/written. }
      Chksum : word;

      constructor Init(ABase : PStream;AChksum:word);
        { Initialize the filter with the given base and starting checksum. }

      procedure Read(var Buf; Count : Word); virtual;
      procedure Write(var Buf; Count : Word); virtual;
    end;

  PCRC16Filter = ^TCRC16Filter;
  TCRC16Filter =
    object(TSequential)      { Calculates XMODEM style 16 bit CRC }
      CRC16 : word;

      constructor Init(ABase : PStream;ACRC16:word);
        { Initialize the filter with the given base and starting CRC. }

      procedure Read(var Buf; Count : Word); virtual;
      procedure Write(var Buf; Count : Word); virtual;
    end;

  PCRCARCFilter = ^TCRCARCFilter;
  TCRCARCFilter =
    object(TSequential)      { Calculates ARC-style 16 bit CRC }
      CRCARC : word;

      constructor Init(ABase : PStream;ACRCARC:word);
        { Initialize the filter with the given base and starting CRC. }

      procedure Read(var Buf; Count : Word); virtual;
      procedure Write(var Buf; Count : Word); virtual;
    end;

  PCRC32Filter = ^TCRC32Filter;
  TCRC32Filter =
    object(TSequential)      { Calculates PKZIP and ZModem style 32 bit CRC }
      CRC32 : longint;

      constructor Init(ABase : PStream;ACRC32:longint);
        { Initialize the filter with the given base and starting CRC. }

      procedure Read(var Buf; Count : Word); virtual;
      procedure Write(var Buf; Count : Word); virtual;
    end;


  PNulStream = ^TNulStream;
  TNulStream =
    object(TStream)
      Position : LongInt;         { The current position for the stream. }
      Value : Byte;               { The value returned on reads. }

      constructor Init(AValue : Byte);
      function GetPos : LongInt; virtual;
      function GetSize : LongInt; virtual;
      procedure Read(var Buf; Count : Word); virtual;
      procedure Seek(Pos : LongInt); virtual;
      procedure Write(var Buf; Count : Word); virtual;
    end;

  Pbyte_array = ^Tbyte_array;
  Tbyte_array = array[0..65520] of Byte; { Type used as a buffer. }

  PEMSStream2 = ^TEMSStream2;
  TEMSStream2 = object(TEMSStream)
    destructor done; virtual;
    { Corrects bug in #TEMSStream# that leaves #EMSCurPage# wrong when
      done is called }
  end;

  PXMSStream = ^TXMSStream;
  TXMSStream =
    object(TStream)
      Handle : Word;              { XMS handle }
      BlocksUsed : Word;          { Number of 1K blocks used. Always allocates
                                    at least one byte more than Size. }
      Size : LongInt;             { The current size of the stream }
      Position : LongInt;         { Current position }

      constructor Init(MinSize,MaxSize:longint);
      destructor Done; virtual;

      function GetPos : LongInt; virtual;
      function GetSize : LongInt; virtual;
      procedure Read(var Buf; Count : Word); virtual;
      procedure Seek(Pos : LongInt); virtual;
      procedure Truncate; virtual;
      procedure Write(var Buf; Count : Word); virtual;

      procedure NewBlock;         { Internal method to allocate a block }
      procedure FreeBlock;        { Internal method to free one block }
    end;

function xms_MemAvail : Longint;
  { Returns total of available XMS bytes. }
function xms_MaxAvail : Longint;
  { Returns size of largest available XMS block in bytes. }
function ems_MemAvail : Longint;
  { Returns total of available EMS in bytes. }
function ems_MaxAvail : Longint;
  { Returns size of largest available EMS block in bytes. }

const
  TempEnvVar  : String[12]  = 'TEMP';
  { The name of an environment variable holding a directory list
    where #TTempBufStream# should go looking for disk space. }

function disk_MemAvail : Longint;
  { Returns total of available disk space for temp streams, from the
    list specified by #TempEnvVar#. }
function disk_MaxAvail : Longint;
  { Returns maximum available block of disk space for temp streams,
    from the list specified by #TempEnvVar#. }

type
  PNamedBufStream = ^TNamedBufStream;
  TNamedBufStream =
    object(TBufStream)
      { A simple descendant of TBufStream which knows its own name.}

    {$ifdef windows}
    filename : PChar;
    {$else}
      Filename : PString;
    {$endif}
      { The name of the stream. }

      constructor Init(Name : FNameStr; Mode : TOpenMode; ABufSize : Word);
        { Open the file with the given name, and save the name. }

      destructor Done; virtual;
        { Close the file. }

    end;

  PTempBufStream = ^TTempBufStream;
  TTempBufStream =
    object(TNamedBufStream)
      { A temporary buffered file stream, which deletes itself when done.
        It's allocated on one of the directories specified by #TempEnvVar#.}

      constructor Init(ABufSize : Word;InitSize,MaxSize : Longint);
  { Create a temporary file with a unique name, in the directory
    pointed to by the environment varable named in #TempEnvVar# or in
    the current directory, open it in read/write mode, and try to grow
    it to InitSize bytes.   }

      destructor Done; virtual;
        { Close and delete the temporary file. }

    end;

  TStreamType = (NoStream, RAMStream, EMSStream, XMSStream, FileStream);
  { The type of stream that a tempstream might be. }

const
  NumTypes = Ord(FileStream);

type
  TStreamRanking = array[1..NumTypes] of TStreamType;
  { A ranking of preference for a type of stream, from most to least preferred }

  TAllocator = function (InitSize, MaxSize : LongInt;
                       Preference : TStreamRanking) : PStream;
  { This is a declaration just like the Streams.TempStream function.}

  PWorkStream = ^TWorkStream;
  TWorkStream =
    object(TFilter)
     { This is a stream type that grows as you write to it by allocating new
       blocks according to a specified strategy.  Blocks may be of mixed
       types. It's a descendant of a filter, but it manages its own base. }

     Allocate : TAllocator;
     BlockMin,                     { These fields are passed to Allocate }
     BlockMax : longint;
     Preference : TStreamRanking;
     BlockStart: longint; { The offset in the stream where the
                            last block starts. }

     constructor init(Allocator:TAllocator;ABlockmin,ABlockMax:Longint;
                      APreference : TStreamRanking);
     { ABlockmin to APreference are passed to the allocator to allocate
       a new block whenever the current one gives a write error.
       The TWorkStream will never try to write a single block that crosses
       the ABlockMax boundary, so tests within the stream can be simple.}
     procedure write(var Buf; Count:Word); virtual;
     { The write procedure checks whether the write would make the
       current block grow too large; if so, it splits up the write. }
   end;

const
  BufSize : Word = 2048;          { Buffer size if buffered stream is used. }

const ForSpeed : TStreamRanking = (RAMStream, EMSStream, XMSStream, FileStream);
  { Streams ordered for speed }

const ForSize : TStreamRanking = (FileStream, EMSStream, XMSStream, RAMStream);
  { Streams ordered for low impact on the heap }

const ForSizeInMem : TStreamRanking = (EMSStream, XMSStream, RAMStream, NoStream);
  { Streams in memory only, ordered as #ForSize#. }

const ForOverlays : TStreamRanking = (EMSStream, XMSStream, FileStream, NoStream);
  { Streams ordered for speed, but never in RAM. }

function TempStream(InitSize, MaxSize : LongInt;
                    Preference : TStreamRanking) : PStream;

{      This procedure returns a pointer to a temporary stream from a
       choice of 3, specified in the Preference array.  The first stream
       type listed in the Preference array which can be successfully
       created with the given sizes will be returned, or Nil if none can
       be made. }

function StreamName(S:PStream):String;
{ This function returns a string naming the type of S^.  It's useful for
  debugging programs that use TempStream and TWorkStream.  However,
  it's for debugging only!  It links every single stream type into your
  .EXE. }

{$ifdef overlays}
procedure OvrInitStream(S : PStream);
{ Copies overlay segment code to S as new segments are loaded,
  and does reloads from there.  Allows multiple calls, to buffer
  different segments on different streams. }

procedure OvrDetachStream(BadS : PStream);
  { Makes sure that the overlay system makes no references to BadS. }

procedure OvrDisposeStreams;
  { Detaches and disposes of all streams being used by the overlay system }

function OvrSizeNeeded : LongInt;
{ Returns the size required to load any segments which still haven't
  been loaded to a stream. }

function OvrLoadAll : Boolean;
{ Forces all overlay segments to be copied into the stream; if successful
  (true) then no more references to the overlay file will be made. }
{$endif windows}

Function UpdateChksum(Initsum: Word; Var InBuf; InLen : Word) : Word;
{ Updates the checksum Initsum by adding InLen bytes from InBuf }

Function UpdateCRC16(InitCRC : Word; Var InBuf; InLen : Word) : Word;
{ I believe this is the CRC used by the XModem protocol.  The transmitting
  end should initialize with zero, UpdateCRC16 for the block, Continue the
  UpdateCRC16 for two nulls, and append the result (hi order byte first) to
  the transmitted block.  The receiver should initialize with zero and
  UpdateCRC16 for the received block including the two byte CRC.  The
  result will be zero (why?) if there were no transmission errors.  (I have
  not tested this function with an actual XModem implementation, though I
  did verify the behavior just described.  See TESTCRC.PAS.) }


Function UpdateCRCArc(InitCRC : Word; Var InBuf; InLen : Word) : Word;
{ This function computes the CRC used by SEA's ARC utility.  Initialize
  with zero. }

Function UpdateCRC32(InitCRC : LongInt; Var InBuf; InLen : Word) : LongInt;
{ This function computes the CRC used by PKZIP and Forsberg's ZModem.
  Initialize with high-values ($FFFFFFFF), and finish by inverting all bits
  (Not). }

Procedure FastCopy(var Src,Dest:TStream;size:longint);
{ Like Dest.CopyFrom(Src,size), but tries to use a larger buffer }

implementation

  function MinLong(x,y:longint):longint;
  begin
    if x<y then
      MinLong := x
    else
      MinLong := y;
  end;

  function MaxLong(x,y:longint):longint;
  begin
    MaxLong := -MinLong(-x,-y);
  end;

  function MinWord(x,y:word):word;
  begin
    if x<y then
      MinWord := x
    else
      MinWord := y;
  end;

  function MaxWord(x,y:word):word;
  begin
    MaxWord := -MinWord(-x,-y);
  end;

  {****** TFilter code *******}

  constructor TFilter.Init(ABase : PStream);
  begin
    TStream.Init;
    Base := ABase;
    CheckBase;
    if Status = stOK then
      Startofs := Base^.GetPos;
    OwnsBase := true;
  end;

  destructor TFilter.Done;
  begin
    if Base <> nil then
    begin
      Flush;
      if OwnsBase then
        Dispose(Base, Done);
    end;
    TStream.Done;
  end;

  function TFilter.GetPos : LongInt;
  begin
    if CheckStatus then
    begin
      GetPos := Base^.GetPos-Startofs;
      CheckBase;
    end;
  end;

  function TFilter.GetSize : LongInt;
  begin
    if CheckStatus then
    begin
      GetSize := Base^.GetSize-Startofs;
      CheckBase;
    end;
  end;

  procedure TFilter.Read(var Buf; Count : Word);
  begin
    if CheckStatus then
    begin
      Base^.Read(Buf, Count);
      CheckBase;
    end;
  end;

  procedure TFilter.Seek(Pos : LongInt);
  begin
    if CheckStatus then
    begin
      Base^.Seek(Pos+Startofs);
      CheckBase;
    end;
  end;

  procedure TFilter.Truncate;
  begin
    if CheckStatus then
    begin
      Base^.Truncate;
      CheckBase;
    end;
  end;

  procedure TFilter.Write(var Buf; Count : Word);
  begin
    if CheckStatus then
    begin
      Base^.Write(Buf, Count);
      CheckBase;
    end;
  end;

  procedure TFilter.Flush;
  begin
    if CheckStatus then
    begin
      Base^.Flush;
      CheckBase;
    end;
  end;

  function TFilter.CheckStatus : Boolean;
  begin
    if (Status = stOK) and (Base^.Status <> stOK) then
      Base^.Reset;
    CheckStatus := Status = stOK;
  end;

  procedure TFilter.CheckBase;
  begin
    if Base^.Status <> stOK then
      Error(stBaseError, Base^.Status);
  end;

  constructor TEncryptFilter.Init(Akey : LongInt; ABase : PStream);
  begin
    TFilter.Init(ABase);
    Key := Akey;
  end;

  procedure TEncryptFilter.Read(var Buf; Count : Word);
  var
    i : Word;
    SaveSeed : LongInt;
    Bytes : Tbyte_array absolute Buf;
  begin
    SaveSeed := RandSeed;
    RandSeed := Key;
    TFilter.Read(Buf, Count);
    for i := 0 to Count-1 do
      Bytes[i] := Bytes[i] xor Random(256);
    Key := RandSeed;
    RandSeed := SaveSeed;
  end;

  procedure CycleKey(Key, Cycles : LongInt);
{ For cycles > 0, mimics cycles calls to the TP random number generator.
  For cycles < 0, backs it up the given number of calls. }
  var
    i : LongInt;
    Junk : Integer;
    SaveSeed : LongInt;
  begin
    if Cycles > 0 then
    begin
      SaveSeed := RandSeed;
      RandSeed := Key;
      for i := 1 to Cycles do
        Junk := Random(0);
      Key := RandSeed;
      RandSeed := SaveSeed;
    end
    else
      for i := -1 downto Cycles do
        Key := (Key-1)*(-649090867);
  end;

  procedure TEncryptFilter.Seek(Pos : LongInt);
  var
    OldPos : LongInt;
  begin
    OldPos := GetPos;
    TFilter.Seek(Pos);
    CycleKey(Key, Pos-OldPos);
  end;

  procedure TEncryptFilter.Write(var Buf; Count : Word);
  var
    i : Word;
    SaveSeed : LongInt;
    BufPtr : Pointer;
    BufPtrOffset : Word absolute BufPtr;
    Buffer : array[0..255] of Byte;
  begin
    SaveSeed := RandSeed;
    RandSeed := Key;
    BufPtr := @Buf;
    while Count > 256 do
    begin
      Move(BufPtr^, Buffer, 256);
      for i := 0 to 255 do
        Buffer[i] := Buffer[i] xor Random(256);
      TFilter.Write(Buffer, 256);
      Dec(Count, 256);
      Inc(BufPtrOffset, 256);
    end;
    Move(BufPtr^, Buffer, Count);
    for i := 0 to Count-1 do
      Buffer[i] := Buffer[i] xor Random(256);
    TFilter.Write(Buffer, Count);
    Key := RandSeed;
    RandSeed := SaveSeed;
  end;


  { ******* LZW code ******* }

{$L LZWSTREA.OBJ}

  procedure Initialise(Tables : PLZWTables); External;

  function PutSignature(Tables : PLZWTables) : Boolean; External;

  function Crunch(InBufSize, OutBufSize : Word;
                  var InBuffer, OutBuffer;
  Tables : PLZWTables) : Pointer; External;

{  Crunch some more text.  Stops when Inbufsize bytes are used up, or
   output buffer is full.   Returns bytes used in segment, bytes written
   in offset of result }

  function FlushLZW(var OutBuffer;
  Tables : PLZWTables) : Word; External;
{  Flush the remaining characters to signal EOF.  Needs space for up to
   3 characters. }

  function GetSignature(var InBuffer, Dummy;
  Tables : PLZWTables) : Boolean; External;
{ Initializes for reading, and checks for 'LZ' signature in start of compressed
  code.  Inbuffer must contain at least 3 bytes.  Dummy is just there to put the
  Inbuffer in the right spot }

  function Uncrunch(InBufSize, OutBufSize : Word;
                    var InBuffer, OutBuffer;
  Tables : PLZWTables) : Pointer; External;
{  Uncrunch some text.  Will stop when it has done Outbufsize worth or has
   exhausted Inbufsize worth.  Returns bytes used in segment, bytes written
   in offset of result }

  constructor TLZWFilter.Init(ABase : PStream; AMode : TOpenMode);
    {  Create new compressor stream, to use ABase as the source/destination
       for data.  Mode must be stOpenRead or stOpenWrite. }
  var
    Buffer : array[1..3] of Byte;
    Info : Integer;
  begin
    Info := stBadMode;
    if (AMode = stOpenRead) or (AMode = stOpenWrite) then
    begin
      Info := stStreamFail;
      if TFilter.Init(ABase) then
      begin
        if Status = stOK then
        begin
          Info := stMemError;
          Startofs := Base^.GetPos;
          Position := 0;
          Mode := AMode;

          if MaxAvail >= SizeOf(TLZWTables) then
          begin
            Info := stSigError;
            GetMem(Tables, SizeOf(TLZWTables));
            if Tables <> nil then { !1.6}
            begin
              Initialise(Tables);
              if Mode = stOpenRead then
              begin
                Base^.Read(Size, SizeOf(Size));
                Base^.Read(Buffer, 3);
                CheckBase;
                if GetSignature(Buffer, Buffer, Tables) then
                  Exit;             { Successfully opened for reading }
              end
              else if Mode = stOpenWrite then
              begin
                Size := 0;
                Base^.Write(Size, SizeOf(Size)); { Put a place holder }
                CheckBase;
                if PutSignature(Tables) then
                  Exit;             { Successful construction for writing! }
              end;
            end;
          end;
        end;
      end;
    end;
    Error(stInitError, Info);
  end;

  destructor TLZWFilter.Done;
  begin
    Flush;
    FreeMem(Tables, SizeOf(TLZWTables));
    TFilter.Done;
  end;

  procedure TLZWFilter.Write(var Buf; Count : Word);
  var
    Inbuf : array[0..65520] of Byte absolute Buf;
    Outbuf : array[0..255] of Byte;
    Inptr : Word;
    Sizes : record
              OutSize, UsedSize : Word;
            end;
  begin
    if CheckStatus then
    begin
      if Mode <> stOpenWrite then
        Error(stBadMode, Mode);
      Inptr := 0;
      repeat
        Pointer(Sizes) := Crunch(Count, SizeOf(Outbuf),
                                 Inbuf[Inptr], Outbuf, Tables);
        with Sizes do
        begin
          Base^.Write(Outbuf, OutSize);

          Dec(Count, UsedSize);
          Inc(Inptr, UsedSize);
          Inc(Size, UsedSize);
          Inc(Position, UsedSize);
        end;
      until Count = 0;
      CheckBase;
    end;
  end;

  procedure TLZWFilter.Flush;
  var
    Outbuf : array[0..255] of Byte;
    Sizes : record
              OutSize, UsedSize : Word;
            end;
    Pos : LongInt;
    extra : word;
    zero : byte;
  begin
    if CheckStatus then
    begin
      if Mode = stOpenWrite then
      begin
        { Changes here in 1.6 }
        extra := 0;
        zero := 0;
        repeat
          Pointer(Sizes) := Crunch(1, Sizeof(Outbuf), zero, Outbuf, Tables);
          with Sizes do
            if OutSize > 0 then
            begin
              inc(extra,outsize);
              Base^.Write(Outbuf, Outsize);
            end;
        until extra > 4;

        Pos := Base^.GetPos;
        Base^.Seek(Startofs);
        Base^.Write(Size, SizeOf(Size));
        Base^.Seek(Pos);
      end;
      Base^.Flush;
      Mode := 0;
      CheckBase;
    end;
  end;

  procedure TLZWFilter.Read(var Buf; Count : Word);
  var
    Outbuf : array[0..65520] of Byte absolute Buf;
    Inbuf : array[0..255] of Byte;
    OutPtr : Word;
    BlockSize : Word;
    Sizes : record
              OutSize, UsedSize : Word;
            end;
    BytesLeft : LongInt;
  begin
    if CheckStatus then
    begin
      if Mode <> stOpenRead then
        Error(stBadMode, Mode);
      OutPtr := 0;
      BlockSize := SizeOf(Inbuf);
      with Base^ do
        BytesLeft := GetSize-GetPos;

      if Position+Count > Size then
      begin
        Error(stReaderror, 0);
        FillChar(Buf, Count, 0);
        Exit;
      end;

      while Count > 0 do
      begin
        if BytesLeft < BlockSize then
          BlockSize := BytesLeft;
        Base^.Read(Inbuf, BlockSize);
        Pointer(Sizes) := Uncrunch(BlockSize, Count, Inbuf,
                                   Outbuf[OutPtr], Tables);
        with Sizes do
        begin
          if OutSize = 0 then
          begin
            Error(stReaderror, 0);
            FillChar(Outbuf[OutPtr], Count, 0);
            Exit;
          end;
          Dec(BytesLeft, UsedSize);
          Inc(Position, OutSize);
          Dec(Count, OutSize);
          Inc(OutPtr, OutSize);
          if UsedSize < BlockSize then
            with Base^ do         { seek back to the first unused byte }
              Seek(GetPos-(BlockSize-UsedSize));
        end;
      end;
      CheckBase;
    end;
  end;

  procedure TLZWFilter.Seek(Pos : LongInt);
  var
    Buf : array[0..255] of Byte;
    Bytes : Word;
  begin
    if CheckStatus then
    begin
      if Mode <> stOpenRead then
      begin
        Error(stBadMode, Mode);
        Exit;
      end;
      if Pos < Position then
      begin
        Base^.Seek(Startofs);
        FreeMem(Tables, SizeOf(TLZWTables));

        TLZWFilter.Init(Base, Mode); { Re-initialize everything.  Will this cause
                                     bugs in descendents? }
      end;
      while Pos > Position do
      begin
        if Pos-Position > SizeOf(Buf) then
          Bytes := SizeOf(Buf)
        else
          Bytes := Pos-Position;
        Read(Buf, Bytes);
      end;
    end;
  end;

  procedure TLZWFilter.Truncate;
  begin
    Error(stBadMode, Mode);
  end;

  function TLZWFilter.GetPos;
  begin
    GetPos := Position;
  end;

  function TLZWFilter.GetSize;
  begin
    GetSize := Size;
  end;

  { ***** Text Filter Code ******* }

  { These declarations are used both by TTextFilter and TLogFilter }

type
  TFDDfunc = function(var F : Text) : Integer;

  PStreamTextRec = ^StreamTextRec;
  PSaveText = ^TSaveText;
  TSaveText =
    record                        { Used when logging for original data values }
      OpenFunc,
      InOutFunc,
      FlushFunc,
      CloseFunc : TFDDfunc;
      S : PLogFilter;
      SaveData : PSaveText;
      Next : PStreamTextRec;
      Data : array[13..16] of Byte;
    end;

  StreamTextRec =
    record
      Handle : Word;
      Mode : Word;
      BufSize : Word;
      private : Word;
      BufPos : Word;
      BufEnd : Word;
      BufPtr : Pbyte_array;
      OpenFunc,
      InOutFunc,
      FlushFunc,
      CloseFunc : TFDDfunc;
      S : PFilter;                { This is a TTextFilter or a TLogFilter }
      SaveData : PSaveText;
      Next : PStreamTextRec;
      OtherData : array[13..16] of Byte;
      Name : array[0..79] of Char;
      Buffer : array[0..127] of Byte;
    end;

  function XLATstatus(var S:TStream):integer;
  const
    TextErrors : array[0..6] of integer = (0,5,5,100,101,212,212);
  var
    status : integer;
  begin
    status := S.status;
    if (status = stBaseError) or (status = stBase2Error) then
      status := S.errorinfo;
    if (-6 <= status) and (status <= 0) then
      XLATstatus := TextErrors[-status]
    else
      XLATstatus := 5;
  end;

  function TextIn(var F : Text) : Integer; Far;
  var
    savemode : word;
  begin
    with StreamTextRec(F), S^ do
    begin
      if Status = 0 then
      begin
        savemode := mode;
        mode := fmClosed;               { This stops infinite loop }
        if GetSize-GetPos > BufSize then
        begin
          Read(BufPtr^, BufSize);
          BufEnd := BufSize;
        end
        else
        begin
          BufEnd := GetSize-GetPos;
          if BufEnd > 0 then
            Read(BufPtr^, BufEnd);
        end;
        BufPos := 0;
        mode := savemode;
      end;
      TextIn := XLATStatus(S^);
    end;
  end;

  function TextOut(var F : Text) : Integer; Far;
  var
    savemode : word;
  begin
    with StreamTextRec(F), S^ do
    begin
      if Status = 0 then
      begin
        savemode := mode;
        mode := fmClosed;
        Write(BufPtr^, BufPos);
        mode := savemode;
        BufPos := 0;
      end;
      TextOut := XLATStatus(S^);
    end;
  end;

  function TextInFlush(var F : Text) : Integer; Far;
  begin
    TextInFlush := 0;           { 1.3A bug fix }
  end;

  function TextOutFlush(var F : Text) : Integer; Far;
  begin
    TextOutFlush := 0;          { 1.6 change from TextOut(F); }
  end;

  function TextClose(var F : Text) : Integer; Far;
  begin
    with StreamTextRec(F) do
    begin
      S^.Flush;
      TextClose := XLATStatus(S^);
    end;
  end;

  function TextOpen(var F : Text) : Integer; Far;
  var
    saveMode : word;
  begin
    with StreamTextRec(F) do
    begin
      case Mode of
        fmInOut :
        begin
                  Mode := fmClosed;
                  S^.Seek(S^.GetSize);
                  Mode := fmOutput;
        end;
        fmInput,fmOutput :
        begin
                  saveMode := Mode;
                  Mode := fmClosed;
                  S^.Seek(0);
                  Mode := saveMode;
        end;
      end;
      case Mode of
        fmInput : begin
                    InOutFunc := TextIn;
                    FlushFunc := TextInFlush;
                  end;
        fmOutput : begin
                     InOutFunc := TextOut;
                     FlushFunc := TextOutFlush;
                   end;
      end;
      TextOpen := XLATStatus(S^);
    end;
  end;

  constructor TTextFilter.Init(ABase : PStream; AName : String);
  begin
    if not TFilter.Init(ABase) then
      Fail;
    TextPtr := nil;
    AssignStream(TextFile,AName);
  end;

  destructor TTextFilter.Done;
  begin
    if StreamTextRec(TextPtr^).Mode <> fmClosed then
      Close(Textptr^);
    TFilter.Done;
  end;

  procedure TTextFilter.AssignStream(var NewText:text;AName:string);
  begin
    if (TextPtr <> nil) and (StreamTextRec(TextPtr^).Mode <> fmClosed) then
      Close(TextPtr^);
    with StreamTextRec(NewText) do
    begin
      Mode := fmClosed;
      BufSize := SizeOf(Buffer);
      BufPtr := PByte_Array(@Buffer);
      OpenFunc := TextOpen;
      CloseFunc := TextClose;
      AName := Copy(AName, 1, 79);
      Move(AName[1], Name, Length(AName));
      Name[Length(AName)] := #0;
      S := @Self;
    end;
    TextPtr := @NewText;
  end;

  function TTextFilter.GetPos : LongInt;
  var
    result : longint;
  begin
    result := TFilter.GetPos;
    with StreamTextRec(Textptr^) do
      case Mode of
        fmInput  : result := result - (BufEnd - BufPos);
        fmOutput : result := result + (BufPos);
      end;
    GetPos := Result;
  end;

  function TTextFilter.GetSize : LongInt;
  begin
    if StreamTextRec(Textptr^).Mode <> fmClosed then
      System.Flush(TextPtr^);
    GetSize := TFilter.GetSize;
  end;

  procedure TTextFilter.Flush;
  begin
    with StreamTextRec(TextPtr^) do
    begin
      case Mode of
        fmOutput : system.flush(TextPtr^);
        fmInput  :
          begin
            TFilter.Seek(TFilter.GetPos - BufEnd + BufPos);
            BufPos := 0;
            BufEnd := 0;
          end;
      end;
    end;
    TFilter.Flush;
  end;

  procedure TTextFilter.Read(var Buf; Count : Word);
  var
    outbuf : Tbyte_array absolute buf;
    size : word;
  begin
    with StreamTextRec(TextPtr^) do
    begin
      if mode <> fmInput then   { This means we've been called by the
                                  TFDD, or while writing to the text file,
                                  or the text file is closed }
      begin
        if mode = fmOutput then
          Flush;
        TFilter.Read(Buf,Count)
      end
      else
      begin
        size := minword(Count, BufEnd-BufPos);
        move(bufptr^[BufPos],outbuf,size);
        dec(count,size);
        if count > 0 then
        begin
          bufpos := 0;
          bufend := 0;
          TFilter.Read(outbuf[size],count);
        end
        else
          inc(bufpos,size);
      end;
    end;
  end;

  procedure TTextFilter.Seek(Pos : LongInt);
  var
    basepos : longint;
  begin
    with StreamTextRec(TextPtr^) do
    begin
      basepos := TFilter.GetPos;
      case Mode of
        fmInput : begin
          if (basepos - bufend <= pos) and (pos < basepos) then
            bufpos := pos-(basepos-bufend)
          else
          begin
            Flush;
            TFilter.Seek(Pos);
          end;
        end;
        fmOutput : begin
          if (basepos <= pos) and (pos < basepos + bufsize) then
            bufpos := pos-basepos
          else
          begin
            Flush;
            TFilter.Seek(Pos);
          end;
        end;
        else
          TFilter.Seek(Pos);
      end;
    end;
  end;

  procedure TTextFilter.Truncate;
  begin
    Flush;
    TFilter.Truncate;
  end;

  procedure TTextFilter.Write(var Buf; Count : Word);
  var
    inbuf : Tbyte_array absolute buf;
    size : word;
  begin
    with StreamTextRec(TextPtr^) do
    begin
      if mode <> fmOutput then
      begin
        if mode = fmInput then
          Flush;
        TFilter.write(buf,count);
      end
      else
      begin
        size := minword(Count, BufSize-BufPos);
        move(inbuf,bufptr^[BufPos],size);
        dec(count,size);
        inc(BufPos,size);
        if count > 0 then
        begin
          Flush;
          TFilter.write(inbuf[size],count);
        end;
      end;
    end;
  end;

  function DoOldCall(Func : TFDDfunc; var F : Text) : Integer;
  var
    Save : TSaveText;
  begin
    if @Func <> nil then
      with StreamTextRec(F) do
      begin
        Move(OpenFunc, Save, SizeOf(TSaveText));
        Move(SaveData^, OpenFunc, SizeOf(TSaveText)); { Now using old functions }
        DoOldCall := Func(F);
        Move(OpenFunc, Save.SaveData^, SizeOf(TSaveText)); { Save any changes }
        Move(Save, OpenFunc, SizeOf(TSaveText)); { Back to new ones }
      end;
  end;

  function LogIn(var F : Text) : Integer; Far;
  var
    Result : Integer;
  begin
    with StreamTextRec(F) do
    begin
      Result := DoOldCall(SaveData^.InOutFunc, F);
      if Result = 0 then
        S^.Write(BufPtr^, BufEnd); { Might want to record errors
                                               here }
      LogIn := Result;
    end;
  end;

  function LogOut(var F : Text) : Integer; Far;
  begin
    with StreamTextRec(F) do
    begin
      S^.Write(BufPtr^, BufPos);
      LogOut := DoOldCall(SaveData^.InOutFunc, F);
    end;
  end;

  function LogInFlush(var F : Text) : Integer; Far;
  begin
    with StreamTextRec(F) do
      LogInFlush := DoOldCall(SaveData^.FlushFunc, F);
  end;

  function LogOutFlush(var F : Text) : Integer; Far;
  var
    OldPos : Word;
  begin
    with StreamTextRec(F) do
    begin
      OldPos := BufPos;
      LogOutFlush := DoOldCall(SaveData^.FlushFunc, F);
      if BufPos = 0 then
        S^.Write(BufPtr^, OldPos);
    end;
  end;

  function LogClose(var F : Text) : Integer; Far;
  begin
    with StreamTextRec(F) do
    begin
      LogClose := DoOldCall(SaveData^.CloseFunc, F);
      if not PLogFilter(S)^.Unlog(F) then
        { Bug! } ;
    end;
  end;

  function LogOpen(var F : Text) : Integer; Far;
  begin
    with StreamTextRec(F) do
    begin
      LogOpen := DoOldCall(SaveData^.OpenFunc, F);
      case Mode of
        fmInOut, fmOutput : begin
                              InOutFunc := LogOut;
                              if @FlushFunc <> nil then
                                FlushFunc := LogOutFlush;
                            end;
        fmInput : begin
                    InOutFunc := LogIn;
                    if @FlushFunc <> nil then
                      FlushFunc := LogInFlush;
                  end;
      end;
    end;
  end;

  { ******* TLogFilter methods ******** }

  constructor TLogFilter.Init(Abase:PStream);
  begin
    if not TFilter.init(ABase) then
      fail;
    LogList := nil;
  end;

  destructor TLogFilter.Done;
  begin
    while (LogList <> nil) and Unlog(LogList^) do ;
    TFilter.Done;
  end;

  procedure TLogFilter.Log(var F : Text);
  var
    Save : PSaveText;
    OldOpen : TFDDfunc;
    Junk : Integer;

  begin
    New(Save);
    with StreamTextRec(F) do
    begin
      Move(OpenFunc, Save^, SizeOf(TSaveText)); { Save the original contents }
      S := @Self;
      SaveData := Save;
      Next := PStreamTextRec(LogList);
      LogList := @F;              { Insert this file into the list of logged files }
      OldOpen := SaveData^.OpenFunc;
      Pointer(@SaveData^.OpenFunc) := nil; { Call LogOpen, but don't open. }
      Junk := LogOpen(F);
      SaveData^.OpenFunc := OldOpen;
      CloseFunc := LogClose;
    end;
  end;

  function TLogFilter.Unlog(var F : Text) : Boolean;
  var
    Save : PSaveText;
    Prev : PStreamTextRec;
  begin
    Unlog := False;               { Assume failure }
    with StreamTextRec(F) do
    begin
      if S = PFilter(@Self) then
      begin
        { First, delete it from the list. }
        if LogList = @F then
          LogList := Pointer(Next)
        else
        begin
          Prev := PStreamTextRec(LogList);
          while (Prev^.Next <> nil) and (Prev^.Next <> PStreamTextRec(@F)) do
            Prev := Prev^.Next;
          if Prev^.Next <> PStreamTextRec(@F) then
            Exit;                 { Couldn't find it in the list!? }
          Prev^.Next := Next;
        end;
        Save := SaveData;
        Move(Save^, OpenFunc, SizeOf(TSaveText));
        Dispose(Save);
        Unlog := True;
      end;
    end;
  end;

{$ifdef overlays}

  { ****** Overlay stream code ****** }

type
  { This is the structure at the start of each "thunk" segment }
  POvrhead = ^TOvrhead;
  TOvrhead = record
               Signature : Word;  { CD 3F  - INT 3F call used on returns }
               Ret_Ofs : Word;    { The offset to jump to when a return triggers a
                            reload }
               Offset : LongInt;  { The offset to the segment in the .OVR file }
               Code_Bytes,        { Size of the code image }
               Reloc_Bytes,       { Number of relocation fixups times 2 }
               Entry_Count,       { The number of entry points }
               NextSeg,           { Next overlay segment - add prefixseg + $10 to find
                            thunks.  List starts with System.ovrcodelist. }
               LoadSeg,           { The segment at which the overlay is loaded, or 0 }
               Reprieve,          { Set to 1 to if overlay used while on probation }
               NextLoaded : Word; { The segment of the next loaded overlay.  List starts
                            with System.ovrloadlist.  Updated *after* call to
                            ovrreadbuf. }
               case Integer of
                 1 : (EMSPage,    { The EMS page where this overlay is stored }
                      EMSOffset : Word); { The offset within the EMS page }
                 2 : (S : PStream; { The stream holding this segment's code }
                      Soffset : LongInt); { The offset within S }
             end;

var
  OldReadFunc : OvrReadFunc;
  OvrOldExitProc : Pointer;
  OvrStream : PStream;
const
  OvrStreamInstalled : Boolean = False;
  OvrExitHandler : Boolean = False;

  function OvrPtr(Seg : Word) : POvrhead;
{ Convert map style segment number, as used by overlay manager, to
  pointer }
  begin
    OvrPtr := Ptr(Seg+PrefixSeg+$10, 0);
  end;

  function StdPtr(Seg : Word) : POvrhead;
    { Convert straight segment number to a pointer }
  begin
    StdPtr := Ptr(Seg, 0);
  end;

  function NewReadFunc(OvrSeg : Word) : Integer; Far;
  var
    Result : Integer;
  begin
    with StdPtr(OvrSeg)^ do
    begin
      if S = nil then
      begin                       { Segment not yet loaded }
        Result := OldReadFunc(OvrSeg);
        if Result = 0 then
        begin
          { Now copy the loaded code to our stream }
          Soffset := OvrStream^.GetSize;
          OvrStream^.Seek(Soffset);
          OvrStream^.Write(Ptr(LoadSeg, 0)^, Code_Bytes);
          Result := OvrStream^.Status;
          if Result = stOK then
            S := OvrStream
          else
            OvrStream^.Reset;     { Something failed; hope we haven't messed
                              up the stream too much }
        end;
      end
      else
      begin                       { Segment has been loaded into the stream }
        S^.Seek(Soffset);
        S^.Read(Ptr(LoadSeg, 0)^, Code_Bytes);
        Result := S^.Status;
        if Result <> stOK then
        begin
          S^.Reset;               { Fix the stream, and try a standard load }
          Result := OldReadFunc(OvrSeg);
        end;
      end;
    end;
    NewReadFunc := Result;
  end;

  procedure OvrExitProc; Far;
{ Installed exit procedure; disposes of any streams that are still
  handling overlays. }
  begin
    ExitProc := OvrOldExitProc;
    OvrDisposeStreams;
  end;

  procedure OvrInitStream(S : PStream);
  begin
    if not OvrStreamInstalled then
    begin
      OldReadFunc := OvrReadBuf;  { Install our reader function }
      OvrReadBuf := NewReadFunc;
      OvrStreamInstalled := True;
    end;
    if not OvrExitHandler then
    begin
      OvrOldExitProc := ExitProc;
      ExitProc := @OvrExitProc;
      OvrExitHandler := True;
    end;
    OvrStream := S;               { And set stream to use }
  end;

  procedure OvrDetachStream(BadS : PStream);
  var
    OvrSeg : Word;
  begin
    if OvrStreamInstalled then
    begin
      if OvrStream = BadS then
        OvrStream := nil;         { Detach default stream }
      OvrSeg := OvrCodeList;
      while OvrSeg <> 0 do        { Walk the overlay list }
        with OvrPtr(OvrSeg)^ do
        begin
          if S <> nil then
          begin
            if S <> BadS then
            begin
              if OvrStream = nil then
                OvrStream := S;   { Set default stream to first found }
            end
            else
              S := nil;           { Blank out BadS references }
          end;
          OvrSeg := NextSeg;
        end;
      if OvrStream = nil then
      begin
        OvrStreamInstalled := False; { If we don't have a stream, better
                                          uninstall. }
        OvrReadBuf := OldReadFunc;
      end;
    end;
  end;

  procedure OvrDisposeStreams;
  var
    S : PStream;
  begin
    while OvrStreamInstalled and (OvrStream <> nil) do
    begin
      S := OvrStream;
      OvrDetachStream(S);
      Dispose(S, Done);
    end;
  end;

  function OvrSizeNeeded : LongInt;
  var
    OvrSeg : Word;
    Result : LongInt;
  begin
    OvrSeg := OvrCodeList;
    Result := 0;
    while OvrSeg <> 0 do          { Walk the overlay list }
      with OvrPtr(OvrSeg)^ do
      begin
        if S = nil then
          Inc(Result, Code_Bytes);
        OvrSeg := NextSeg;
      end;
    OvrSizeNeeded := Result;
  end;

  function OvrLoadAll : Boolean;
  var
    OvrSeg : Word;
    Junk : Integer;
  begin
    if not OvrStreamInstalled then
      OvrLoadAll := False
    else
    begin
      OvrClearBuf;
      OvrSeg := OvrCodeList;
      while OvrSeg <> 0 do        { Walk the overlay list }
        with OvrPtr(OvrSeg)^ do
        begin
          if S = nil then
          begin
            LoadSeg := OvrHeapOrg; { load at start of overlay buffer }
            Junk := NewReadFunc(OvrSeg+PrefixSeg+$10);
            LoadSeg := 0;         { Don't really want it loaded yet }
          end;
          OvrSeg := NextSeg;
        end;
      OvrLoadAll := OvrStream^.Status = stOK;
    end;
  end;

  {$endif windows}

  { ****** Bit filter code ****** }

  constructor TBitFilter.Init(ABase : PStream);
  begin
    TFilter.Init(ABase);
    BitPos := 0;
    AtEnd := false;
  end;

  procedure TBitFilter.PrepareBuffer(ForRead : Boolean);
  begin
    if BitPos = 8 then            { Buffer full on write }
    begin
      Base^.Write(Buffer, 1);
      BitPos := 0;
    end;
    if BitPos = 0 then            { Buffer empty }
    begin
      if not AtEnd then
      begin
        if not ForRead then
          AtEnd := (Base^.GetPos >= Base^.GetSize);
        if (not AtEnd) or ForRead then
        begin
          Base^.Read(Buffer,1);
          BitPos := -8
        end;
      end;
      if AtEnd then
        Buffer := 0;
      Mask := 1;
    end;
    if (not ForRead) and (BitPos < 0) then
    begin
      Base^.Seek(Base^.GetPos-1);
      Inc(BitPos, 8);
      AtEnd := false;
    end;
  end;

  function TBitFilter.GetBit : TBit;
  begin
    if CheckStatus then
    begin
      PrepareBuffer(True);
      GetBit := TBit((Buffer and Mask) > 0);
      Mask := Mask shl 1;
      Inc(BitPos);
      CheckBase;
    end;
  end;

  function TBitFilter.GetBits(Count : Byte) : LongInt;
  var
    Result : LongInt;
  begin
    Result := 0;
    ReadBits(Result, Count);
    GetBits := Result;
  end;

  procedure TBitFilter.PutBit(ABit : TBit);
  begin
    if CheckStatus then
    begin
      PrepareBuffer(False);
      if ABit = 1 then
        Buffer := Buffer or Mask;
      Mask := Mask shl 1;
      Inc(BitPos);
    end;
  end;

  procedure TBitFilter.PutBits(ABits : LongInt; Count : Byte);
  begin
    WriteBits(ABits, Count);
  end;

  procedure TBitFilter.ReadBits(var Buf; Count : LongInt);
  var
    w : Word;
    b : array[1..2] of Byte absolute w;
    bBuf : TByte_Array absolute Buf;
    i, Bytes : Word;
    Shift : Word;
  begin
    if (Count > 0) and CheckStatus then
    begin
      PrepareBuffer(True);
      if BitPos > 0 then
      begin
        Base^.Write(Buffer, 1);
        Dec(BitPos, 8);
      end;
      Shift := BitPos+8;          { the number of bits to shift by }
      Bytes := (Count+Shift-1) div 8; { Count of whole bytes to read }
      if Bytes > 0 then
      begin
        TFilter.Read(Buf, Bytes);
        b[1] := Buffer;
        for i := 0 to Pred(Bytes) do
        begin
          b[2] := bBuf[i];
          w := w shr Shift;
          bBuf[i] := b[1];
          w := w shr (8-Shift);
        end;
        Buffer := b[1];
      end;
      { Now fix up the last few bits }
      Dec(Count, 8*LongInt(Bytes));
      if Count > 0 then
        bBuf[Bytes] := (Buffer shr Shift) and not($FF shl Count)
      else
        if Count < 0 then
          bBuf[Bytes-1] := bBuf[Bytes-1] and not($FF shl (8+Count));
      BitPos := BitPos+Count;
      Mask := 1 shl (BitPos+8);
    end;
  end;

  procedure TBitFilter.WriteBits(var Buf; Count : LongInt);
  var
    w : Word;
    b : array[1..2] of Byte absolute w;
    bBuf : TByte_Array absolute Buf;
    i, Bytes : Word;
    Shift : Word;
    SaveBuf : Byte;
    SavePos : ShortInt;
  begin
    if CheckStatus then
    begin
      PrepareBuffer(False);
      Bytes := (Count+BitPos-1) div 8; { Count of whole bytes to write }
      Shift := 8-BitPos;
      if Bytes > 0 then
      begin
        if Shift < 8 then
        begin
          b[1] := Buffer shl Shift;
          for i := 0 to Pred(Bytes) do
          begin
            b[2] := bBuf[i];
            w := w shr Shift;
            Base^.Write(b[1], 1);
            w := w shr (8-Shift);
          end;
          Buffer := b[1] shr Shift;
        end
        else
          Base^.Write(Buf, Bytes);
      end;
      Dec(Count, 8*LongInt(Bytes));
      if Count > 0 then
        Buffer := (Buffer or (bBuf[Bytes] shl (8-Shift)));
      BitPos := BitPos+Count;
      if BitPos > 0 then          { Fill in upper part of buffer }
      begin
        SaveBuf := Buffer;
        SavePos := BitPos;
        BitPos := 0;              { signal empty buffer }
        PrepareBuffer(False);     { and load it }
        Buffer := (Buffer and ($FF shl SavePos)) { old part }
                  or (SaveBuf and not($FF shl SavePos)); { new part }
        BitPos := SavePos;
      end;
      Mask := 1 shl BitPos;
      CheckBase;
    end;
  end;

  procedure TBitFilter.Flush;
  begin
    if CheckStatus then
    begin
      if BitPos > 0 then
        Base^.Write(Buffer, 1);
      Dec(BitPos, 8);
      AtEnd := false;
      CheckBase;
    end;
  end;

  procedure TBitFilter.Seek(Pos : LongInt);
  begin
    if CheckStatus then
    begin
      Flush;
      TFilter.Seek(Pos);
      BitPos := 0;
      AtEnd := false;
    end;
  end;

  procedure TBitFilter.Read(var Buf; Count : Word);
  begin
    ReadBits(Buf, 8*LongInt(Count));
  end;

  procedure TBitFilter.Write(var Buf; Count : Word);
  begin
    WriteBits(Buf, 8*LongInt(Count));
  end;

  procedure TBitFilter.SeekBit(Pos : LongInt);
  var
    i : Byte;
    b : TBit;
  begin
    if CheckStatus then
    begin
      Seek(Pos div 8);
      for i := 1 to (Pos and 7) do
        b := GetBit;
    end;
  end;

  function TBitFilter.GetBitPos : LongInt;
  begin
    GetBitPos := 8*TFilter.GetPos+BitPos;  { Need TFilter override in
                                             case descendants override
                                             GetPos }
  end;

  procedure TBitFilter.CopyBits(var S : TBitFilter; Count : LongInt);
  var
    localbuf : array[1..256] of Byte;
  begin
    while Count > 2048 do
    begin
      S.ReadBits(localbuf, 2048);
      WriteBits(localbuf, 2048);
      Dec(Count, 2048);
    end;
    if Count > 0 then
    begin
      S.ReadBits(localbuf, Count);
      WriteBits(localbuf, Count);
    end;
  end;

  procedure TBitFilter.ByteAlign;
  begin
    SeekBit((GetBitPos+7) and $FFFFFFF8);
  end;

  { ****** Duplicate filter code ****** }

  constructor TDupFilter.Init(ABase, ABase2 : PStream);
  { Initialize the filter with the given bases. }
  begin
    if not TFilter.Init(Abase) then
      fail;
    Base2 := ABase2;
    CheckBase2;
    if Status = stOK then
      Startofs2 := Base2^.GetPos;
  end;

  destructor TDupFilter.Done;
  { Flush filter, then dispose of both bases. }
  begin
    Flush;
    if Base2 <> nil then
      Dispose(Base2,done);
    TFilter.Done;
  end;

  function TDupFilter.MisMatch(var buf1,buf2;count:word):word;
  var
    i : word;
    bbuf1 : TByte_Array absolute buf1;
    bbuf2 : TByte_Array absolute buf2;
  begin
    for i := 0 to pred(count) do
      if bbuf1[i] <> bbuf2[i] then
      begin
        MisMatch := succ(i);
        exit;
      end;
    MisMatch := 0;
  end;

  procedure TDupFilter.Read(var Buf; Count : Word);
  var
    bpos : word;
    localbuf : array[0..255] of byte;

    procedure CompareBuffer(size:word);
    var
      epos : word;
      bbuf : TByte_Array absolute Buf;
    begin
      Base2^.Read(localbuf,size);
      dec(count,size);
      CheckBase2;
      if status = stOK then
      begin
        epos := MisMatch(bbuf[bpos],localbuf,size);
        if epos <> 0 then
          Error(stMismatch,bpos+epos);
      end;
      inc(bpos,size);
    end;

  begin
    TFilter.Read(buf, Count);
    bpos := 0;
    While (Status = stOK) and (Count >= sizeof(localbuf)) do
      CompareBuffer(Sizeof(localbuf));
    If (Status = stOK) and (Count > 0) then
      CompareBuffer(Count);
    { Be sure the bases are synchronized }
    Base2^.Seek(GetPos+StartOfs2);
  end;

  procedure TDupFilter.Seek(Pos : LongInt);
  begin
    TFilter.Seek(Pos);
    if Status = stOK then
    begin
      base2^.Seek(pos+startofs2);
      CheckBase2;
    end;
  end;

  procedure TDupFilter.Truncate;
  begin
    TFilter.Truncate;
    if Status = stOK then
    begin
      base2^.truncate;
      CheckBase2;
    end;
  end;

  procedure TDupFilter.Write(var Buf; Count : Word);
  begin
    TFilter.Write(buf,Count);
    if Status = stOK then
    begin
      Base2^.write(buf,Count);
      CheckBase2;
    end;
  end;

  procedure TDupFilter.Flush;
  begin
    TFilter.Flush;
    if Status = stOK then
    begin
      base2^.flush;
      CheckBase2;
    end;
  end;

  function TDupFilter.CheckStatus : Boolean;
  begin
    if TFilter.CheckStatus then
      if Base2^.Status <> stOK then
        Base2^.Reset;
    CheckStatus := Status = stOK;
  end;

  procedure TDupFilter.CheckBase2;
  begin
    if Base2^.status <> stOk then
      Error(stBase2Error,Base2^.status);
  end;

  { ****** Concatenating Filter code ****** }

  constructor TConcatFilter.Init(ABase, ABase2 : PStream);
  { Initialize the filter with the given bases. }
  begin
    if not TFilter.Init(ABase) then
      fail;
    Base2 := ABase2;
    CheckBase2;
    Base1Size := TFilter.GetSize;
    if Status = stOK then
      StartOfs2 := Base2^.GetPos;
    Position := Base1Size;
  end;

  destructor TConcatFilter.done;
  begin
    Flush;
    if Base2 <> nil then
      Dispose(Base2,done);
    if Base <> nil then
      Dispose(Base,Done);   { Can't call TFilter.Done!!!! }
    TStream.done;
  end;

  function TConcatFilter.GetPos:longint;
  begin
    GetPos := Position;
  end;

  function TConcatFilter.GetSize:longint;
  begin
    if CheckStatus then
    begin
      GetSize := Base1Size + Base2^.GetSize;
      CheckBase2;
    end;
  end;

  procedure TConcatFilter.Read(var Buf; Count : Word);
  var
    Buffer : TByte_array absolute Buf;
    base1part : word;
  begin
    { First read the Base 1 portion }
    if Position < Base1Size then
    begin
      base1part := Count;
      if Position+base1part > Base1Size then
        base1part := Base1Size - Position;
      TFilter.Read(Buf, base1part);
      dec(Count,base1part);
      inc(Position,Base1part);
      if Count > 0 then
        Base2^.Seek(StartOfs2);   { Be sure Base2 agrees with Pos now }
    end
    else
      base1part := 0;
    { Now read the Base 2 portion }
    if (Count > 0) and (status = stOK) then
    begin
      if Position = Base1Size then
        Base2^.Seek(StartOfs2);
      Base2^.Read(Buffer[base1part],Count);
      CheckBase2;
      inc(Position,count);
    end;
  end;

  procedure TConcatFilter.Seek(Pos : LongInt);
  begin
    if Pos < Base1Size then
      TFilter.Seek(Pos)
    else
    begin
      if CheckStatus then
      begin
        Base2^.Seek(Pos-Base1Size+StartOfs2);
        CheckBase2;
      end;
    end;
    if Status = stOK then
      Position := Pos;
  end;

  procedure TConcatFilter.Truncate;
  begin
    if Position < Base1Size then
      Error(stUnsupported,0)     { We don't allow Base to be truncated, only
                                   Base2 }
    else
      if CheckStatus then
      begin
        Base2^.Truncate;
        CheckBase2;
      end;
  end;

  procedure TConcatFilter.Write(var Buf; Count : Word);
  var
    Buffer : TByte_array absolute Buf;
    base1part : word;
  begin
    { First write the Base 1 portion }
    if Position < Base1Size then
    begin
      base1part := Count;
      if Position+base1part > Base1Size then
        base1part := Base1Size - Position;
      TFilter.Write(Buf, base1part);
      dec(Count,base1part);
      inc(Position,Base1part);
      if Count > 0 then
        Base2^.Seek(StartOfs2);   { Be sure Base2 agrees with Pos now }
    end
    else
      base1part := 0;
    { Now write the Base 2 portion }
    if (Count > 0) and (status = stOK) then
    begin
      Base2^.Write(Buffer[base1part],Count);
      CheckBase2;
      inc(Position,count);
    end;
  end;

  procedure TConcatFilter.Flush;
  begin
    TFilter.Flush;
    if status = stOK then
    begin
      Base2^.Flush;
      CheckBase2;
    end;
  end;

  function TConcatFilter.CheckStatus : Boolean;
  begin
    if TFilter.CheckStatus then
      if Base2^.Status <> stOK then
        Base2^.Reset;
    CheckStatus := Status = stOK;
  end;

  procedure TConcatFilter.CheckBase2;
  begin
    if Base2^.status <> stOk then
      Error(stBase2Error,Base2^.status);
  end;

  { ****** Limit Filter code *****}

  constructor TLimitFilter.init(ABase:PStream;ALoLimit,AHiLimit:longint);
  { Does the usual init, sets the limits, then does a Seek to ALoLimit
    if it is non-zero. }
  begin
    if not TFilter.Init(ABase) then
      fail;
    LoLimit := ALoLimit;
    HiLimit := AHiLimit;
    if ALoLimit <> 0 then
      Seek(ALoLimit);
  end;

  procedure TLimitFilter.Read(var Buf; Count : Word);
  begin
    if status = stOk then
    begin
      if GetPos + Count > HiLimit then
      begin
        Error(stReadError,0);
        Fillchar(Buf,Count,0);
      end
      else
        TFilter.Read(Buf,Count);
    end;
  end;

  procedure TLimitFilter.Seek(Pos : LongInt);
  begin
    if Status = stOK then
    begin
      if (Pos < LoLimit) or (Pos > HiLimit) then
        Error(stReadError,0)
      else
        TFilter.Seek(Pos);
    end;
  end;

  procedure TLimitFilter.Write(var Buf; Count : Word);
  begin
    if Status = stOk then
    begin
      if GetPos + Count > HiLimit then
        Error(stWriteError,0)
      else
        TFilter.Write(Buf,Count);
    end;
  end;

  function TLimitFilter.GetSize:longint;
  var
    result : longint;
  begin
    result := TFilter.GetSize;
    if result > HiLimit then
      GetSize := HiLimit
    else
      GetSize := result;
  end;

  { ****** Loop Filter code *****}

  procedure TLoopFilter.Read(var Buf; Count : Word);
  var
    buffer : TByte_Array absolute Buf;
    pos : word;
  begin
    if status = stOk then
    begin
      if GetPos + Count > HiLimit then
      begin
        pos := HiLimit - GetPos;
        TFilter.Read(Buf,pos);
        dec(count,pos);
        TFilter.Seek(LoLimit);
        Read(Buffer[pos],Count);  { Recursive call! }
      end
      else
        Tfilter.Read(Buf,Count);
    end;
  end;

  procedure TLoopFilter.Seek(Pos : LongInt);
  var
    size : longint;
  begin
    size := HiLimit - LoLimit;
    if Pos < LoLimit then
      Pos := LoLimit + (Pos - LoLimit) mod Size + Size;
    TFilter.Seek(LoLimit + (Pos - LoLimit) mod Size);
  end;

  procedure TLoopFilter.Write(var Buf; Count : Word);
  var
    buffer : TByte_Array absolute Buf;
    pos : word;
  begin
    if status = stOk then
    begin
      if GetPos + Count > HiLimit then
      begin
        pos := HiLimit - GetPos;
        TFilter.Write(Buf,pos);
        dec(count,pos);
        TFilter.Seek(LoLimit);
        Write(Buffer[pos],Count);  { Recursive call! }
      end
      else
        Tfilter.Write(Buf,Count);
    end;
  end;

  function TLoopFilter.GetSize:longint;
  var
    result : longint;
  begin
    result := TFilter.GetSize;
    if result > HiLimit then
      GetSize := HiLimit - LoLimit
    else
      GetSize := result - LoLimit;
  end;

  { ****** TReverseFilter code ******}

  constructor TReverseFilter.Init(ABase : PStream; AReverseBlocks:boolean);
  begin
    TFilter.Init(ABase);
    ReverseBlocks := AReverseBlocks;
  end;

  function TReverseFilter.GetPos:longint;
  begin
    GetPos := TFilter.GetSize-TFilter.GetPos;
  end;

  procedure TReverseFilter.Read(var Buf;Count : word);
  var
    curpos : longint;
  begin
    curpos := TFilter.GetPos;   { We call the Tfilter methods to propagate errors }
    Base^.Seek(curpos-Count);
    Base^.Read(Buf,Count);
    if ReverseBlocks then
      ReverseBytes(Buf,Count);
    TFilter.Seek(curpos-Count);
  end;

  procedure TReverseFilter.Write(var Buf;Count : word);
  var
    curpos : longint;
  begin
    curpos := TFilter.GetPos;   { We call the Tfilter methods to propagate errors }
    Base^.Seek(curpos-Count);
    if ReverseBlocks then
      ReverseBytes(Buf,Count);
    Base^.Write(Buf,Count);
    if ReverseBlocks then
      ReverseBytes(Buf,Count);
    TFilter.Seek(curpos-Count);
  end;

  procedure TReverseFilter.Seek(Pos:Longint);
  begin
    TFilter.Seek(TFilter.GetSize-Pos);
  end;

  procedure TReverseFilter.Truncate;
  begin
    Error(stUnsupported,0);
  end;

  procedure ReverseBytes(var Buf; Count:Word);
  var
    buffer : TByte_Array absolute Buf;
    i,j : word;
    t : byte;
  begin
    if Count > 1 then
    begin
      j := Count-1;
      for i:=0 to (Count div 2) - 1 do
      begin
        t := buffer[i];
        buffer[i] := buffer[j];
        buffer[j] := t;
        dec(j);
      end;
    end;
  end;

  { ****** Checksum/CRC code ******}

  Function UpdateChksum(initsum:word; var Inbuf; inlen:word):word;
  var
    i : word;
    bbuf : TByte_Array absolute inbuf;
  begin
    for i:=0 to pred(inlen) do
      inc(initsum,bbuf[i]);
    UpdateChksum := initsum;
  end;

{ From the original CRC.PAS: }

{ This unit provides three speed-optimized functions to compute (or continue
  computation of) a Cyclic Redundency Check (CRC).  These routines are
  contributed to the public domain (with the limitations noted by the
  original authors in the TASM sources).

  Each function takes three parameters:

  InitCRC - The initial CRC value.  This may be the recommended initialization
  value if this is the first or only block to be checked, or this may be
  a previously computed CRC value if this is a continuation.

  InBuf - An untyped parameter specifying the beginning of the memory area
  to be checked.

  InLen - A word indicating the length of the memory area to be checked.  If
  InLen is zero, the function returns the value of InitCRC.

  The function result is the updated CRC.  The input buffer is scanned under
  the limitations of the 8086 segmented architecture, so the result will be
  in error if InLen > 64k - Offset(InBuf).

  These conversions were done on 10-29-89 by:

  Edwin T. Floyd [76067,747]
  #9 Adams Park Court
  Columbus, GA 31909
  (404) 576-3305 (work)
  (404) 322-0076 (home)
}

Function UpdateCRC16(InitCRC : Word; Var InBuf; InLen : Word) : Word;
  external; {$L crc16.obj}
{ I believe this is the CRC used by the XModem protocol.  The transmitting
  end should initialize with zero, UpdateCRC16 for the block, Continue the
  UpdateCRC16 for two nulls, and append the result (hi order byte first) to
  the transmitted block.  The receiver should initialize with zero and
  UpdateCRC16 for the received block including the two byte CRC.  The
  result will be zero (why?) if there were no transmission errors.  (I have
  not tested this function with an actual XModem implementation, though I
  did verify the behavior just described.  See TESTCRC.PAS.) }


Function UpdateCRCArc(InitCRC : Word; Var InBuf; InLen : Word) : Word;
  external; {$L crcarc.obj}
{ This function computes the CRC used by SEA's ARC utility.  Initialize
  with zero. }

Function UpdateCRC32(InitCRC : LongInt; Var InBuf; InLen : Word) : LongInt;
  external; {$L crc32.obj}
{ This function computes the CRC used by PKZIP and Forsberg's ZModem.
  Initialize with high-values ($FFFFFFFF), and finish by inverting all bits
  (Not). }

  { ****** Sequential filter code ****** }

  procedure TSequential.Seek(pos:longint);
  begin
    Error(stUnsupported,0);
  end;

  { ****** Chksum filter code ******}

  constructor TChkSumFilter.init(ABase:PStream; AChksum:word);
  begin
    if not TSequential.init(ABase) then
      fail;
    Chksum := AChksum;
  end;

  procedure TChkSumFilter.Read(var buf; Count:word);
  begin
    TSequential.Read(buf,count);
    if status = stOK then
      ChkSum := UpdateChksum(ChkSum,buf,Count);
  end;

  procedure TChkSumFilter.Write(var buf; Count:word);
  begin
    TSequential.Write(buf,count);
    if status = stOk then
      ChkSum := UpdateChksum(ChkSum,buf,Count);
  end;

{ ***** CRC16 filter code ***** }

  constructor TCRC16Filter.init(ABase:PStream; ACRC16:word);
  begin
    if not TSequential.init(ABase) then
      fail;
    CRC16 := ACRC16;
  end;

  procedure TCRC16Filter.Read(var buf; Count:word);
  begin
    TSequential.Read(buf,count);
    if status = stOK then
      CRC16 := UpdateCRC16(CRC16,buf,count);
  end;

  procedure TCRC16Filter.Write(var buf; Count:word);
  begin
    TSequential.Write(buf,count);
    if status = stOk then
      CRC16 := UpdateCRC16(CRC16,buf,count);
  end;

  { ***** CRCARC filter code ***** }

  constructor TCRCARCFilter.init(ABase:PStream; ACRCARC:word);
  begin
    if not TSequential.init(ABase) then
      fail;
    CRCARC := ACRCARC;
  end;

  procedure TCRCARCFilter.Read(var buf; Count:word);
  begin
    TSequential.Read(buf,count);
    if status = stOK then
      CRCARC := UpdateCRCARC(CRCARC,buf,count);
  end;

  procedure TCRCARCFilter.Write(var buf; Count:word);
  begin
    TSequential.Write(buf,count);
    if status = stOk then
      CRCARC := UpdateCRCARC(CRCARC,buf,count);
  end;

  { ***** CRC32 filter code ***** }

  constructor TCRC32Filter.init(ABase:PStream; ACRC32:longint);
  begin
    if not TSequential.init(ABase) then
      fail;
    CRC32 := ACRC32;
  end;

  procedure TCRC32Filter.Read(var buf; Count:word);
  begin
    TSequential.Read(buf,count);
    if status = stOK then
      CRC32 := UpdateCRC32(CRC32,buf,count);
  end;

  procedure TCRC32Filter.Write(var buf; Count:word);
  begin
    TSequential.Write(buf,count);
    if status = stOk then
      CRC32 := UpdateCRC32(CRC32,buf,count);
  end;

  { ****** Null stream code ****** }

  constructor TNulStream.Init;
  begin
    TStream.Init;
    Position := 0;
    Value := AValue;
  end;

  function TNulStream.GetPos;
  begin
    GetPos := Position;
  end;

  function TNulStream.GetSize;
  begin
    GetSize := Position;
  end;

  procedure TNulStream.Read;
  begin
    FillChar(Buf, Count, Value);
    Inc(Position, Count);
  end;

  procedure TNulStream.Seek;
  begin
    Position := Pos;
  end;

  procedure TNulStream.Write;
  begin
    Inc(Position, Count);
  end;

  { ***** EMS stream code ***** }

  destructor TEMSStream2.done;
  begin
    TEMSStream.done;
    EMSCurpage := $FFFF;
  end;

  { ***** XMS stream code ***** }

  {$I xmsstrm.inc}

  { ***** EMS size code ***** }

  function exist_ems:boolean;
  const
    ems_found : boolean = false;  { Used as initialized var }
  var
    S : TEMSStream2;
  begin
    if not ems_found then
    begin
      S.init(1,1);
      ems_found := S.status = stOk;
      S.done;
    end;
    exist_ems := ems_found;
  end;

  function ems_maxavail: longint;
  begin
    if not exist_ems then
      ems_maxavail:=0
    else
    asm
      mov ah,$42;
      int $67
      mov ax,16384
      mul bx
      mov word ptr @result,ax
      mov word ptr @result[2],dx
    end;
  end;

  function ems_memavail: longint;
  begin
    ems_memavail := ems_maxavail;
  end;

  function GetTempList:String;
  { Function to get the list of directories for temp files }
  var
  {$ifdef windows}
    p : PChar;
  {$endif}
    result : string;
  begin
  {$ifdef windows}
    p := GetEnvVar(@TempEnvVar[1]);
  if p <> nil then
    result := StrPas(p)
  else
    result := '';
  {$else}
    result := GetEnv(TempEnvVar);
  {$endif}
    if Length(result) = 0 then
      result := '.\';
    GetTempList := result;
  end;

  function GetTempDir(var TempList:string):string;
  { Strip one temp directory off the front of the list, and
    return it fully qualified, with a '\' at the end. }
  var
    Semicolon : byte;
    result : string;
    curdir : string;
  begin
    Semicolon := Pos(';',TempList);
    if Semicolon > 0 then
    begin
      result := Copy(TempList,1,Semicolon-1);
      TempList := Copy(TempList,Semicolon+1,255);
    end
    else
    begin
      result := TempList;
      TempList := '';
    end;
    if result[Length(result)] <> '\' then
      result := result+'\';
    if (length(result) < 2) or (result[2] <> ':') then
      GetDir(0,curdir)
    else
    begin
      GetDir(ord(upcase(result[1]))-ord('A')+1,curdir);
      result := copy(result,3,255);
    end;
    if (length(result) > 1) and (result[1] <> '\') then
      result := curdir + '\' + result
    else
      result := copy(curdir,1,2) + result;
    GetTempDir := result;
  end;

  function disk_maxavail: longint;
  var
    templist,tempname : string;
    result : longint;
  begin
    result := 0;
    templist := GetTempList;
    repeat
      tempname := GetTempDir(templist);
      result := MaxLong(result,
                        DiskFree(ord(upcase(tempname[1]))-ord('A')+1))
    until templist = '';
    disk_maxavail := result;
  end;

  function disk_memavail: longint;
  var
    templist,tempname : string;
    result,space : longint;
    disk : byte;
    disks : array[1..32] of boolean;
  begin
    fillchar(disks,sizeof(disks),false);
    result := 0;
    templist := GetTempList;
    repeat
      tempname := GetTempDir(templist);
      disk := ord(upcase(tempname[1]))-ord('A')+1;
      if not disks[disk] then
      begin
        disks[disk] := true;
        space := DiskFree(disk);
      end
      else
        space := 0;
      if space > 0 then
        inc(result,space);
    until templist = '';
    disk_memavail := result;
  end;

  { ***** Named Buffered file stream code ***** }

  constructor TNamedBufStream.Init(Name : FNameStr; Mode : TOpenMode; ABufSize : Word);
  begin
    if TBufStream.Init(Name, Mode, ABufSize) then
    {$ifdef windows}
    filename := StrNew(name)
    {$else}
      Filename := NewStr(Name)
    {$endif}
    else
      Fail;
  end;

  destructor TNamedBufStream.Done;
  begin
  {$ifdef windows}
  StrDispose(filename);
  {$else}
    DisposeStr(Filename);
  {$endif}
    TBufStream.Done;
  end;

  constructor TTempBufStream.Init(ABufSize : Word;
                                  InitSize,MaxSize : Longint);
  var
    TempList,TempName : String;
    Okay : Boolean;
    NewHandle : Word;
    F : File;
  begin
    if not TStream.Init then
      Fail;
    if MaxAvail < ABufSize then
      Fail;
    BufSize := ABufSize;
    GetMem(Buffer, BufSize);
    if Buffer = Nil then { !1.6 }
      Fail;
    MaxSize := MaxLong(MinLong(MaxSize,Disk_MaxAvail),InitSize);
    TempList := GetTempList;
    repeat
      TempName := GetTempDir(TempList);
      FillChar(TempName[Length(TempName)+1], 255-Length(TempName), #0);
      asm
        push    ds
        push    ss
        pop     ds
        lea     dx,TempName[1]
        mov     ah, $5a
        xor     cx,cx
      {$ifdef windows}
        call dos3call
      {$else}
        int     $21                 { Create temporary file. }
      {$endif}
        pop     ds
        jc      @failed
        mov     Okay,True
        mov     NewHandle,ax
        jmp     @done
@failed:
        mov     Okay,False
@done:
      end;
      if okay then
      begin
        Handle := NewHandle;
        while TempName[Length(TempName)+1] <> #0 do
          Inc(TempName[0]);
        {$ifdef windows}
        Filename := StrNew(StrPCopy(@tempname[1],tempname));
        {$else}
        Filename := NewStr(TempName);
        {$endif}
        Seek(MaxSize-1);
        Write(okay,1);      { Write a 0 }
        Flush;
        Seek(InitSize);
        Truncate;
        Seek(0);            { !1.6}
        okay := Status = stOK;
        if not okay and (TempList <> '') then
        begin
          asm
            mov ah,$3E
            mov bx,NewHandle
            int $21             { Close file }
          end;
          assign(F,filename^);
          Erase(F);
          Reset;
          {$ifdef windows}
          StrDispose(Filename);
          {$else}
          DisposeStr(Filename);
          {$endif}
          Filename := nil;
        end;
      end;
    until okay or (TempList = '');
  end;

  destructor TTempBufStream.Done;
  var
    F : file;
  begin
  {$ifdef windows}
  assign(f,StrPas(Filename));
  {$else}
    Assign(F, Filename^);
  {$endif}
    TNamedBufStream.Done;
    Erase(F);
  end;

  {******** TWorkStream code ******* }

  constructor TWorkStream.init(Allocator:TAllocator;ABlockmin,ABlockMax:Longint;
                   APreference : TStreamRanking);
  begin
    TFilter.init(Allocator(ABlockmin,ABlockmax,APreference));
    Allocate := Allocator;
    Blockmin := ABlockmin;
    Blockmax := ABlockmax;
    Preference := APreference;
    BlockStart := 0;
  end;

  procedure TWorkStream.write(var Buf; Count:Word);
  var
    Buffer : TByte_array absolute Buf;
    firstpart : word;
    byteswritten : word;
    pos : longint;
    NewBase : PStream;
    saveStatus, saveInfo : integer;
  begin
    pos := GetPos;
    byteswritten := 0;
    if CheckStatus then
      repeat
        firstpart := Count;
        if (Pos < BlockStart+BlockMax) and (Pos+firstpart > BlockStart+BlockMax) then
          firstpart := BlockStart+BlockMax-Pos;
        TFilter.Write(Buffer[byteswritten], firstpart);

        { **** crummy code to get around problems with TBufStream **** }
        { The test is an efficiency hack - we don't want to flush every
          segment of the stream, just the last one. }
        if typeof(Base^) = typeof(TConcatFilter) then
          PConcatFilter(Base)^.Base2^.Flush
        else
          Base^.Flush;          { Must flush all writes to see TBufStream
                                errors immediately :-( }
        CheckBase;              { 1.6 fix }
        { **** end of crummy code :-) ***** }
        if Status = stOK then
        begin
          dec(Count,firstpart);
          inc(Pos,firstpart);
          inc(byteswritten,firstpart);
        end
        else
        begin
          saveStatus := Status;
          saveInfo   := ErrorInfo;
          Reset;
          if Pos = GetSize then
          begin
            { If write failed at eof, allocate a new block }
            Seek(0);
            NewBase := Allocate(BlockMin,BlockMax,Preference);
            if (NewBase = nil) or (NewBase^.Status <> stOK) then
            begin
              error(stBaseError, stWriteError);
              exit;
            end;
            Base := New(PConcatFilter,init(Base,NewBase));
            BlockStart := Pos;
          end
          else  { Some other kind of write failure; restore the error status }
          begin
            error(saveStatus,saveInfo);
            exit;
          end;
        end;
      until count = 0;
  end;

  { ***** Temp Stream Code ******* }

  function TempStream(InitSize, MaxSize : LongInt;
                      Preference : TStreamRanking) : PStream;
  var
    Choice : Integer;
    Result : PStream;
    StreamType : TStreamType;
    Nulls : TNulStream;
  begin
    Result := nil;
    Nulls.Init(0);
    for Choice := 1 to NumTypes do
    begin
      StreamType := Preference[Choice];
      case StreamType of
        RAMStream :
          if MaxAvail >= MaxSize+$10000 then
            Result := New(PMemoryStream, Init(InitSize, MaxSize));
        EMSStream :
          if ems_MaxAvail >= MaxSize then
            Result := New(PEMSStream2, Init(InitSize, MaxSize));
        XMSStream :
          if xms_MaxAvail >= MaxSize then
            Result := New(PXMSStream, Init(InitSize, MaxSize));
        FileStream :
          if disk_MaxAvail >= MaxSize then
            Result := New(PTempBufStream, Init(2048, InitSize, MaxSize));
      end;
      if (Result <> nil) and (Result^.Status = stOK) then
      begin
        FastCopy(Nulls, Result^, InitSize);
        Result^.Seek(0);
        if Result^.Status = stOK then
        begin
          Nulls.Done;
          TempStream := Result;
          Exit;
        end;
      end;
      if Result <> nil then
        Dispose(Result, Done); { Clean up and start over } ;
      Result := nil;
    end;
    TempStream := nil;
  end;

  function StreamName(S:PStream):String;
  { This function is for debugging only!  It links every single stream
    type into your .EXE. }
  var
    t : pointer;
  begin
    if S=nil then
      StreamName := 'nil'
    else
    begin
      t := typeof(S^);
           if t = typeof(TStream)         then StreamName := 'TStream'
      else if t = typeof(TEMSStream)      then StreamName := 'TEMSStream'
      else if t = typeof(TDOSStream)      then StreamName := 'TDOSStream'
      else if t = typeof(TBufStream)      then StreamName := 'TBufStream'
      else if t = typeof(TFilter)         then StreamName := 'TFilter'
      else if t = typeof(TEncryptFilter)  then StreamName := 'TEncryptFilter'
      else if t = typeof(TLZWFilter)      then StreamName := 'TLZWFilter'
      else if t = typeof(TTextFilter)     then StreamName := 'TTextFilter'
      else if t = typeof(TLogFilter)      then StreamName := 'TLogFilter'
      else if t = typeof(TBitFilter)      then StreamName := 'TBitFilter'
      else if t = typeof(TDupFilter)      then StreamName := 'TDupFilter'
      else if t = typeof(TConcatFilter)   then StreamName := 'TConcatFilter'
      else if t = typeof(TLimitFilter)    then StreamName := 'TLimitFilter'
      else if t = typeof(TLoopFilter)     then StreamName := 'TLoopFilter'
      else if t = typeof(TReverseFilter)  then StreamName := 'TReverseFilter'
      else if t = typeof(TSequential)     then StreamName := 'TSequential'
      else if t = typeof(TChksumFilter)   then StreamName := 'TChksumFilter'
      else if t = typeof(TCRC16Filter)    then StreamName := 'TCRC16Filter'
      else if t = typeof(TCRCARCFilter)   then StreamName := 'TCRCARCFilter'
      else if t = typeof(TCRC32Filter)    then StreamName := 'TCRC32Filter'
      else if t = typeof(TNulStream)      then StreamName := 'TNulStream'
      else if t = typeof(TMemoryStream)   then StreamName := 'TMemoryStream'
      else if t = typeof(TEMSStream2)     then StreamName := 'TEMSStream2'
      else if t = typeof(TXMSStream)      then StreamName := 'TXMSStream'
      else if t = typeof(TNamedBufStream) then StreamName := 'TNamedBufStream'
      else if t = typeof(TTempBufStream)  then StreamName := 'TTempBufStream'
      else if t = typeof(TWorkStream)     then StreamName := 'TWorkStream'
      else StreamName := 'Unknown (or uninitialized) stream';
    end;
  end;

{ ******* Fast copy code ******** }

procedure FastCopy(var src,dest:TStream; size:longint);
var
  buffer : pbyte_array;
  bufsize : word;
begin
  bufsize := minlong(minlong(65536-512, maxavail), size);
  if bufsize < 512 then
    dest.copyfrom(src,size)
  else
  begin
    getmem(buffer,bufsize);
    if buffer = nil then
      dest.copyfrom(src,size)
    else
    begin
      while size >= bufsize do
      begin
        src.read(buffer^,bufsize);
        dest.write(buffer^,bufsize);
        dec(size,bufsize);
      end;
      if size > 0 then
      begin
        src.read(buffer^,size);
        dest.write(buffer^,size);
      end;
      freemem(buffer,bufsize);
    end;
  end;
end;

end.
