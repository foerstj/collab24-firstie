:: name of map
set map=collab24-firstie
set res=collab24
:: name of map, case-sensitive
set map_cs=Collab 24 Firstie
:: tank properties
set year=2026
set copyright=CC-BY-SA %year%
set author=Firstie
set title=%map_cs%

:: path of Bits dir
set bits=%~dp0.
:: path of DS installation
set ds=%DungeonSiege%
:: path of TankCreator
set tc=%TankCreator%

:: param
set mode=%1
echo %mode%

:: pre-build checks
setlocal EnableDelayedExpansion
if not "%gaspy%"=="" (
  if not "%mode%"=="light" (
    pushd %gaspy%
    set checks=standard
    if "%mode%"=="release" (
      set checks=all
    )
    venv\Scripts\python -m build.pre_build_checks %map% --check !checks! --bits "%bits%"
    if !errorlevel! neq 0 pause
    popd
  )
)
endlocal

:: Compile map file
rmdir /S /Q "%tmp%\Bits"
robocopy "%bits%\world\maps\%map%" "%tmp%\Bits\world\maps\%map%" /S
setlocal EnableDelayedExpansion
if not "%gaspy%"=="" (
  pushd %gaspy%
  set dev_only=--dev-only-false
  venv\Scripts\python -m build.fix_start_positions_required_levels %map% !dev_only! --bits "%tmp%\Bits"
  if !errorlevel! neq 0 pause

  if "%mode%"=="release" (
    venv\Scripts\python -m build.add_world_levels %map% --bits "%tmp%\Bits" --template-bits "%bits%"
    if !errorlevel! neq 0 pause
  )
  popd
)
endlocal
"%tc%\RTC.exe" -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.dsmap" -copyright "%copyright%" -title "%title%" -author "%author%"
if %errorlevel% neq 0 pause

:: Compile main resource file
rmdir /S /Q "%tmp%\Bits"
robocopy "%bits%\art" "%tmp%\Bits\art" /S /xd git-ignore
robocopy "%bits%\ui" "%tmp%\Bits\ui" /S
robocopy "%bits%\world\ai\jobs\minibits" "%tmp%\Bits\world\ai\jobs\minibits" /S
robocopy "%bits%\world\ai\jobs\%res%" "%tmp%\Bits\world\ai\jobs\%res%" /S
robocopy "%bits%\world\contentdb\components\minibits" "%tmp%\Bits\world\contentdb\components\minibits" /S
robocopy "%bits%\world\contentdb\components\%res%" "%tmp%\Bits\world\contentdb\components\%res%" /S
robocopy "%bits%\world\contentdb\templates\minibits" "%tmp%\Bits\world\contentdb\templates\minibits" /S
robocopy "%bits%\world\contentdb\templates\%res%" "%tmp%\Bits\world\contentdb\templates\%res%" /S
robocopy "%bits%\world\global\moods\%res%" "%tmp%\Bits\world\global\moods\%res%" /S
robocopy "%bits%\world\global\effects" "%tmp%\Bits\world\global\effects" %res%-*.gas /S
robocopy "%bits%\world\global\effects" "%tmp%\Bits\world\global\effects" minibits-*.gas /S
"%tc%\RTC.exe" -source "%tmp%\Bits" -out "%ds%\DSLOA\%map_cs%.dsres" -copyright "%copyright%" -title "%title%" -author "%author%"
if %errorlevel% neq 0 pause
