@echo off

:: Temporary system path at cmd startup

:: set PATH=%PATH%;"C:\Program Files\Sublime Text 2\"

:: Add to path by command

DOSKEY test=echo "bruh"

DOSKEY add_python26=set PATH=%PATH%;"C:\Python26\"
DOSKEY add_python33=set PATH=%PATH%;"C:\Python33\"
DOSKEY add_wasm=set PATH=%PATH%;"%USERPROFILE%\Programming\wasm\emsdk"
DOSKEY do_wasm=emsdk activate latest

:: Reload this file
DOSKEY .s= %USERPROFILE%\Programming\command_aliases\aliases.cmd
:: Movement


DOSKEY ..=cd ../
DOSKEY ...=cd ../../
DOSKEY ....=cd ../../../
DOSKEY gohome=cd %USERPROFILE%\
DOSKEY godown=cd %USERPROFILE%\Downloads\
DOSKEY gopro=cd %USERPROFILE%\Programming\

:: Commands

DOSKEY ls=dir \B $*
DOSKEY ll=dir $*
DOSKEY sublime=sublime_text $*
    ::sublime_text.exe is name of the executable. By adding a temporary entry to system path, we don't have to write the whole directory anymore.
DOSKEY gsp="C:\Program Files (x86)\Sketchpad5\GSP505en.exe"
DOSKEY alias=notepad %USERPROFILE%\Dropbox\alias.cmd

:: Linux like aliases
DOSKEY lsl=DIR $* 
DOSKEY cp=COPY $* 
DOSKEY xcp=XCOPY $*
DOSKEY mv=MOVE $* 
DOSKEY clear=CLS
DOSKEY h=DOSKEY /HISTORY


:: Git commands
DOSKEY gs=git status
DOSKEY gad=git add $*
DOSKEY gds=git diff --staged
DOSKEY gus=git restore --staged *
DOSKEY gap=git add -p
DOSKEY gup=git restore --staged -p

:: NPM Run
DOSKEY npmd=npm run dev
DOSKEY npmb=npm run build
DOSKEY npms=npm run start

:: Common directories
DOSKEY dropbox=cd "%USERPROFILE%\Dropbox\$*"
DOSKEY research=cd %USERPROFILE%\Dropbox\Research\

:: 
DOSKEY alias=if ".$*." == ".." ( DOSKEY /MACROS ) else ( DOSKEY $* )

echo "Configurations loaded"
