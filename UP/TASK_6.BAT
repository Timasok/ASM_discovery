@Set filename=task_6
@Set input=
@Set execute=%filename%.com %input%

@tasm /la %filename%.asm
@tlink /t %filename%.obj
@cls
%execute%
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