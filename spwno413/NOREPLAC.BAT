@echo off
set lib$$=%1
if "%1" == "" set lib$$=TLIB

echo NOREPLAC.BAT
echo About to remove the functions which replace the standard spawn..()
echo functions from all of your SPAWNx.LIB libraries, using %lib$$%.
echo.
echo If you do not wish to remove the functions, or you need to change
echo the librarian to be used, press Control-Break now.  To change the
echo librarian, re-run NOREPLAC giving the name of the program to run.
pause

echo Processing Tiny model
%lib$$% spawnt -_system-_spawn-_spawne-_spawnp-_spawnpe,nul,spawnt >nul
echo Processing Small model
%lib$$% spawns -_system-_spawn-_spawne-_spawnp-_spawnpe,nul,spawns >nul
echo Processing Medium model
%lib$$% spawnm -_system-_spawn-_spawne-_spawnp-_spawnpe,nul,spawnm >nul
echo Processing Compact model
%lib$$% spawnc -_system-_spawn-_spawne-_spawnp-_spawnpe,nul,spawnc >nul
echo Processing Large model
%lib$$% spawnl -_system-_spawn-_spawne-_spawnp-_spawnpe,nul,spawnl >nul
echo Processing Huge model
%lib$$% spawnh -_system-_spawn-_spawne-_spawnp-_spawnpe,nul,spawnh >nul
echo Removing backup files
del spawn?.bak >nul
set lib$$=

