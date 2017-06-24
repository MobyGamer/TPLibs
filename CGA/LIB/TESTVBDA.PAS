program test_bda;
{Prints out values from the Video BIOS Data Area, to test the BDA_ absolute
vars in m6845ctl.

The Video BIOS Data Area holds values passed to the m6845 registers as a
courtesy to system programmers, because most of the m6845 registers are
write-only.  (Later clones made these readable as well.)  The BDA is supposed
to be maintained by DOS, the video BIOS, and user programs.  In practice,
this rarely happens... but we are trying to be a nice cga library and so
we will provide an interface to this area and will try to maintain it
whenever we change modes.}

uses
  support,
  m320_640,
  m6845ctl;

procedure printbda;
begin
  writeln('   Current BIOS video mode: ',hex(BDA_crt_mode));
  writeln('     Num displayed columns: ',BDA_crt_cols);
  writeln('        Size of vid buffer: ',hex(BDA_crt_len));
  writeln('Offset of start of vid buf: ',hex(BDA_crt_start));
  writeln('   Start and end of cursor: ',hex(BDA_cursor_mode));
  writeln('  Currently displayed page: ',hex(BDA_active_page));
  writeln('  IO port address of m6845: ',hex(BDA_addr_6845));
  writeln(' Current mode control byte: ',hex(BDA_crt_mode_set));
  writeln(' Current color select byte: ',hex(BDA_crt_palette));
end;

begin
  asm
    mov  ax,0004h
    int  10h
  end;
  Writeln('I''ve initialized 320x200x4 via the BIOS.'#13#10'BDA shows:');
  printbda;
  readkeychar;
  mode4_set;
  Writeln('I''ve initialized 320x200x4 manually.'#13#10'BDA shows:');
  printbda;
  readkeychar;
  asm
    mov  ax,0003h
    int  10h
  end;
  Writeln('I''ve just initialized the video mode to 80x25 color via the BIOS.  BDA shows:');
  printbda;
  readkeychar;
end.