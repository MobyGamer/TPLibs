program testpr; {tests the tandy/pcjr video page register}

uses
  support;

var
  displayedpage,mappedpage:byte;

begin
  {Enter 160x200x16 graphics mode}
  asm
    mov ax,0008h
    int 10h
  end;
  displayedpage:=7; mappedpage:=6;
  port[$3DF] := (mappedpage SHL 3)+displayedpage;
  {put pixel on hidden page}
  mem[$b800:0]:=$1E;
  readkeychar;
  displayedpage:=6; mappedpage:=7;
  port[$3DF] := (mappedpage SHL 3)+displayedpage;
  {put pixel on other hidden page}
  mem[$b800:1]:=$2F;
  readkeychar;
  displayedpage:=7;
  port[$3DF] := (mappedpage SHL 3)+displayedpage;
  readkeychar;
  displayedpage:=6;
  port[$3DF] := (mappedpage SHL 3)+displayedpage;
  readkeychar;
  asm
    mov ax,0003
    int 10h
  end;
end.

  port[$3DF] := 6*8+7;                { show page 7, map page 6   }
