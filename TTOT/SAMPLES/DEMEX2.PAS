Program DemoMiscExecOne;
{DEMEX1 - executing other programs from within a Turbo Pascal program}

Uses DOS,CRT, totMISC, totFAST, totINPUT, totIO2;

{IMPORTANT NOTE: you must use the $M compiler directive to instruct the
 compiler to leave some memory for the child process, i.e. leave enough
 memory for the sub-program to run.

 $M limits the amount of memory available for the parent program, and 
 the precise settings are therefore dependant upon the program's size.
 You will have to experment with different values -- your goal should be
 to allocate "just enough" memory for the parent program, thereby leaving
 the maximum amount possible for the child program.

 Other Toolkit units make extensive use of the heap, and in
 most "real life" program you will need to set the heap to a non-zero 
 value, e.g. $M $8000,$4000,$4000. As a rule, set the min and max values
 the same. Refer to the Turbo Pascal documentation for further information
 regarding the $M compiler directive.

}

{$M $2000,$2000,$2000}

var 
  RetCode : integer;
  InputField: LateralIOOBJ;
  Command: string;
begin
   Clrscr;
   repeat
      writeln;
      with InputField do
      begin
         Init(36,Screen.WhereY,30,70);
         SetLabel('Enter a program to execute, or ESC');
         Activate;
         Command := GetValue;
         Done;
      end;
      if (Key.LastKey = 27) or (Command = '') then
         halt(0);
      Retcode := RunAnything(Command);
   until Retcode <> 0;
   writeln('Something went wrong!');
end.

