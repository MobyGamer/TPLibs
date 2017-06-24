@echo off
set lib$$=%1
if "%1" == "" set lib$$=LIB

echo %0.BAT

if exist spwnerrt.obj goto start
echo Please extract the files in SPAWN_MS to the current directory and then
echo re-run %0.
goto end

:start
echo About to remove the compiler-specific functions in all of your SPAWNx.LIB
echo libraries with Microsoft C versions, using %lib$$%.
echo.
echo If you do not wish to remove the functions, or you need to change
echo the librarian to be used, press Control-Break now.  To change the
echo librarian, re-run %0 giving the name of the program to use.
pause

echo Processing Tiny model
copy spwnerrt.obj spawnerr.obj
copy system_t.obj system.obj
%lib$$% spawnt -+spawnerr -+system,nul,spawnt >nul
echo Processing Small model
copy spwnerrs.obj spawnerr.obj
copy system_s.obj system.obj
%lib$$% spawns -+spawnerr -+system,nul,spawns >nul
echo Processing Medium model
copy spwnerrm.obj spawnerr.obj
copy system_m.obj system.obj
%lib$$% spawnm -+spawnerr -+system,nul,spawnm >nul
echo Processing Compact model
copy spwnerrc.obj spawnerr.obj
copy system_c.obj system.obj
%lib$$% spawnc -+spawnerr -+system,nul,spawnc >nul
echo Processing Large model
copy spwnerrl.obj spawnerr.obj
copy system_l.obj system.obj
%lib$$% spawnl -+spawnerr -+system,nul,spawnl >nul
echo Processing Huge model
copy spwnerrh.obj spawnerr.obj
copy system_h.obj system.obj
%lib$$% spawnh -+spawnerr -+system,nul,spawnh >nul
echo Removing backup files
del spawn?.bak >nul

:end
set lib$$=
