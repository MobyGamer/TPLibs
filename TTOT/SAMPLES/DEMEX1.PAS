Program DemoMiscExecOne;
{DEMEX1 - executing other programs from within a Turbo Pascal program}

Uses DOS,CRT, totMISC;

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

{$M $800,$50,$50}

var RetCode : integer;

begin
   writeln('This is the parent program!');
   Retcode := RunDOS('Type EXIT to return to the parent program');
   writeln('Welcome back');
   if RetCode <> 0 then
      Writeln('Something went wrong!');
   writeln('Press any key...');
   repeat until keypressed;
end.



