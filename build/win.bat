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
set __cmake_dir=cmake
set __install_dir=qt_sdk
if /i "%__msvc%" == "1" (
    set __cmake_dir=%__cmake_dir%_msvc
    set __install_dir=%__install_dir%_msvc
)
if /i "%__clangcl%" == "1" (
    set __cmake_dir=%__cmake_dir%_clangcl
    set __install_dir=%__install_dir%_clangcl
)
if /i "%__mingw%" == "1" (
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
set __bat_params=-prefix "%~dp0%__install_dir%" -c++std c++20 -nomake tests -nomake examples -mimetype-database-compression zstd
if /i "%__debug%" == "1" (
    set __bat_params=%__bat_params% -debug
) else (
    set __bat_params=%__bat_params% -release -ltcg -strip
)
if /i "%__static%" == "1" (
    set __bat_params=%__bat_params% -static -static-runtime
) else (
    set __bat_params=%__bat_params% -shared -disable-deprecated-up-to 0x070000
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
call "%__qt_dir%\configure.bat" %__bat_params%
cmake --build . --parallel
cmake --install .
endlocal
cd /d "%~dp0"
pause
exit /b 0
