unit cgalib_g;
{Contains global constant definitions for all of the modules.}

interface

const
  nummodes=11;

type
  {video modes we are going to draw graphics in.  What denotes a graphics
  mode from another is memory organization of screen RAM and individual pixels.}
  cgamodetype=(
    {All text modes use #177 (±) as the "pixel" which gives us maximum 136 "colors"}
    text40x25, text80x25, {stock text modes}
    text40x50, text80x50,
    text40x100,text80x100, {tweaked text modes}
    lowres, {"lowres" 160x100x16, uses ASCII #222 (Þ) to enable use of the attribute byte as "pixels"}
    mode4,mode6, {320x200x4 and 640x200x2}
    composite, {160x200x16 composite color CGA}
    dummy {used for benchmarking purposes}
  );

  (*
  {information about a video mode}
  modeinfo=record
    VideoMode:cgamodetype;
    Width:word; {width in pixels.  Example: 320 (range [0..319])}
    Height:word; {height in pixels.  Example: 200 (range [0..199])}
    MaxColors:word;
    BitsPerPixel:byte;
    SLWB:word; {ScanLineWidthBytes -- width, in bytes, of a single horizontal scanline}
    HiddenBuf:pointer; {pointer to offscreen buffer}
    HiddenBufSize:word;
  end;
  *)

const
  ModeDescriptions:array[text40x25..dummy] of string[40]=(
    '40x25   136 colors',
    '80x25   136 colors',
    '40x50   136 colors',
    '80x50   136 colors',
    '40x100  136 colors',
    '80x100  136 colors',
    '160x100 16 colors',
    '320x200 4 colors',
    '640x200 2 colors',
    '160x200 composite color',
    'dummy   (used for benchmarking)'
  );

(*
var
  cga_curmode:modeinfo; {current mode's info}
*)

implementation

end.
