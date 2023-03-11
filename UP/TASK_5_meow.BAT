@Set filename=task_5
@Set resident_one=res_1
@Set input=
@Set execute=%filename%.com %input%

@tasm /la %filename%.asm
@tlink /t %filename%.obj
@cls
td %execute%

@REM @tasm /la %resident_one%.asm
@REM @tlink /t %resident_one%.obj
@REM @cls
@REM %resident_one%
@REM @echo Open debugger?

@REM @CHOICE
@REM @if ERRORLEVEL == 2 goto clear
@REM @echo
@REM :debug
@REM td %execute%

@REM @goto finish

@REM :clear

@CLEAR.BAT

:finish
@exit