@echo off
chcp 65001
title Building Qt SDK ...
setlocal enabledelayedexpansion
cls
set __compiler=%1
set __type=%2
set __config=%3
if /i "%__compiler%" == "" set __compiler=msvc
if /i "%__type%" == "" set __type=shared
if /i "%__config%" == "" set __config=release
set __msvc=0
set __clangcl=0
set __mingw=0
if /i "%__compiler%" == "clangcl" (
    set __clangcl=1
) else if /i "%__compiler%" == "mingw" (
    set __mingw=1
) else (
    set __msvc=1
)
set __static=0
if /i "%__type%" == "static" set __static=1
set __debug=0
if /i "%__config%" == "debug" set __debug=1
set __platform=win32
set __cmake_dir=cmake
set __install_dir=qt_sdk
if /i "%__msvc%" == "1" (
    set __platform=%__platform%-msvc
    set __cmake_dir=%__cmake_dir%_msvc
    set __install_dir=%__install_dir%_msvc
)
if /i "%__clangcl%" == "1" (
    set __platform=%__platform%-clang-msvc
    set __cmake_dir=%__cmake_dir%_clangcl
    set __install_dir=%__install_dir%_clangcl
)
if /i "%__mingw%" == "1" (
    set __platform=%__platform%-clang-g++
    set __cmake_dir=%__cmake_dir%_mingw
    set __install_dir=%__install_dir%_mingw
)
if /i "%__debug%" == "1" (
    set __cmake_dir=%__cmake_dir%_debug
    set __install_dir=%__install_dir%_debug
) else (
    set __cmake_dir=%__cmake_dir%_release
    set __install_dir=%__install_dir%_release
)
if /i "%__static%" == "1" (
    set __cmake_dir=%__cmake_dir%_static
    set __install_dir=%__install_dir%_static
) else (
    set __cmake_dir=%__cmake_dir%_shared
    set __install_dir=%__install_dir%_shared
)
set __config_params=-platform %__platform% -prefix "%~dp0%__install_dir%" -nomake tests -nomake examples -feature-relocatable -feature-c++20
set __build_params=--build . --target all --parallel
set __install_params=--install .
if /i "%__debug%" == "1" (
    set __config_params=%__config_params% -debug
    set __build_params=%__build_params% --config Debug
    set __install_params=%__install_params% --config Debug
) else (
    set __config_params=%__config_params% -release
    set __build_params=%__build_params% --config Release
    set __install_params=%__install_params% --config Release --strip
)
if /i "%__static%" == "1" (
    set __config_params=%__config_params% -static -static-runtime
) else (
    set __config_params=%__config_params% -shared -disable-deprecated-up-to 0x070000
)
set __need_vs=0
if /i "%__msvc%" == "1" set __need_vs=1
if /i "%__clangcl%" == "1" set __need_vs=1
if /i "%__need_vs%" == "1" call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
set __qt_dir=%~dp0..
set __qtbase_dir=%__qt_dir%\qtbase
set PATH=%__qtbase_dir%\bin;%PATH%
cd /d "%~dp0"
if exist %__cmake_dir% rd /s /q %__cmake_dir%
if exist %__install_dir% rd /s /q %__install_dir%
md %__cmake_dir%
cd %__cmake_dir%
set QT_ENABLE_VCLTL=1
set QT_ENABLE_YYTHUNKS=1
call "%__qt_dir%\configure.bat" %__config_params%
cmake %__build_params%
cmake %__install_params%
cd /d "%~dp0"
if exist %__install_dir%.7z del /f %__install_dir%.7z
set __7z_params=-mx -myx -ms=on -mqs=on -mmt=on -m0=LZMA2:d=256m:fb=273
7z a %__install_dir%.7z %__install_dir%\ %__7z_params%
endlocal
cd /d "%~dp0"
pause
exit /b 0
