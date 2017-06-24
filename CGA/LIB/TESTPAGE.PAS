{$DEFINE PAGEFLIPTEST}
program testpage;
{
Tests the hidden/visible page facility of cgalib.  Pages allow the user
to write to a "hidden" page and then show that page on the next vertical
retrace.  This allows for clean image updating.

Video pages work two ways in CGALIB:
  If there is only one physical video page, then:
    SetActivePage(hidden) is a permanent change that means all updates
    will be written to a hidden page in system ram
    PageFlip() will copy that page to video ram
  If there are two or more physical pages, then:
    SetActivePage(hidden) or (visible) works as advertised
    PageFlip() will toggle the display between two different areas of
    video ram
}

uses
  cgalib,
  support;

var
  vs:pVidSystem;
  oldma:longint;
  w:word;

begin
  {take note of available ram to make sure we don't have a memory leak}
  oldma:=maxavail;
  {init video system}
  vs:=init_askmode(true);

  with vs^ do begin
    {assign visible page to draw on}
    setDrawPage(visible);
    {draw test}
    clear(1);
    rect(5,5,width-5,height-5,0);
    for w:=0 to width-1 do line(w,0,width-w-1,height-1,w and (maxcolors-1));
    {pause so we can see what the test looks like}
    readkeychar;
    {assign hidden page to draw on}
    setDrawPage(hidden);
    {draw test}
    clear(0);
    rect(5,5,width-5,height-5,1);
    for w:=0 to height-1 do line(0,w,width-1,height-1-w,w and (maxcolors-1));
    {flip pages -- we should see the hidden drawing}
    PageFlip;
    readkeychar;
    {$IFDEF PAGEFLIPTEST}
    if hardwarePages then begin
      {pageflip again to see the original image}
      pageflip;
      readkeychar;
      {pageflip again to see the second image}
      pageflip;
      readkeychar;
      {flip between both pages repeatedly on crt sync until key hit}
      repeat
        WaitVertRetrace;
        pageflip;
      until keypressed; if keypressed then readkeychar;
      {flip between both pages repeatedly until key hit}
      repeat
        pageflip;
      until keypressed; if keypressed then readkeychar;
    end else {$ENDIF} begin
      for w:=0 to 15 do line(0,w,width-1,w,w and (maxcolors-1));
      pageflip; {this should re-copy the hidden to visible if software pages}
      readkeychar;
      setDrawPage(visible); {set drawing location back to visible}
      for w:=0 to width-1 do line(w,0,width-w-1,height-1,0); {we should see this getting drawn}
      readkeychar;
    end
  end;

  {shut down video system}
  dispose(vs,done);

  {check for memory leak}
  if memavail<>oldma then writeln('Memory leak of ',oldma-memavail,' bytes detected :-(');
end.
