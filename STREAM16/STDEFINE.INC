{ This file sets some conditional compilation defines }

{$define overlays}  { Assume we'll want the overlay code, but turn
                      it off in certain cases }
{$ifdef windows}
  {$undef overlays}
{$endif}

{$ifdef dpmi}
  {$undef overlays}
{$endif}

{ Only TPW uses "WObjects"; BP 7 calls the same unit "Objects" }
{$ifdef windows}
  {$ifndef ver70}
    {$define wobjects}
  {$endif}
{$endif}