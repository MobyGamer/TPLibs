program DemoDirFour;
{demls4 - a user sortable directory listing}
{trixfix - made more useful and clearer to understand}

Uses DOS, CRT,
     totFAST, totLIST, totKEY;

Var
   ListWin:  ListDirSortObj;
   s:string;

begin
   Screen.Clear(white,'°'); {paint the screen}
   Screen.WriteCenter(25,white,' Press S or Right Mouse Button for Sort Options ');
   with ListWin do
   begin
      Init;
      setTagging(false); {trix}
      ReadFiles('*.*',AnyFile-directory);
      Go;
      if (LastKey = kEsc) or (Lastkey = wClose)
        then writeln('You escaped!')
        else s:=GetHiString;
      Done; {trashes our result}
   end;
   writeln('You chose file ',s);
end.
