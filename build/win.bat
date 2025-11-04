@echo off
color
chcp 65001
title Building Qt SDK ...
setlocal enabledelayedexpansion
cls
cd /d "%~dp0."
if exist env.bat call env.bat
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
set __cmake_dir=%~dp0cmake
set __install_dir=%~dp0qt_sdk
set __vcpkg_dir=%~dp0..\vcpkg
set __vcpkg_install_dir=%__vcpkg_dir%\installed\x64-windows
::set VCPKG_ROOT=%__vcpkg_dir%
::set QT_VCPKG_TARGET_TRIPLET=x64-windows
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
    set __platform=%__platform%-g++
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
    rem set QT_VCPKG_TARGET_TRIPLET=%QT_VCPKG_TARGET_TRIPLET%-static-mt-release
    set __vcpkg_install_dir=%__vcpkg_install_dir%-static-mt-release
) else (
    set __cmake_dir=%__cmake_dir%_shared
    set __install_dir=%__install_dir%_shared
    rem set QT_VCPKG_TARGET_TRIPLET=%QT_VCPKG_TARGET_TRIPLET%-shared-mt-release
    set __vcpkg_install_dir=%__vcpkg_install_dir%-shared-mt-release
)
:: OpenSSL
::set OpenSSL_DIR=%__vcpkg_install_dir%
::set OpenSSL_ROOT=%OpenSSL_DIR%
::set OPENSSL_ROOT_DIR=%OpenSSL_ROOT%
::set OPENSSL_BIN_DIR=%OPENSSL_ROOT_DIR%\bin
::set OPENSSL_INCLUDE_DIR=%OPENSSL_ROOT_DIR%\include
::set OPENSSL_LIB_DIR=%OPENSSL_ROOT_DIR%\lib
::set OPENSSL_CRYPTO_LIBRARY=%OPENSSL_LIB_DIR%\libcrypto.lib
::set OPENSSL_SSL_LIBRARY=%OPENSSL_LIB_DIR%\libssl.lib
::set OPENSSL_INCLUDE_DIRS=%OPENSSL_INCLUDE_DIR%
::set OPENSSL_LIBRARIES=%OPENSSL_CRYPTO_LIBRARY%;%OPENSSL_SSL_LIBRARY%
:: ICU
::set ICU_DIR=%__vcpkg_install_dir%
::set ICU_ROOT=%ICU_DIR%
::set ICU_ROOT_DIR=%ICU_ROOT%
::set ICU_BIN_DIR=%ICU_ROOT_DIR%\bin
::set ICU_INCLUDE_DIR=%ICU_ROOT_DIR%\include
::set ICU_LIB_DIR=%ICU_ROOT_DIR%\lib
::set ICU_I18N_LIBRARY=%ICU_LIB_DIR%\icuin.lib
::set ICU_UC_LIBRARY=%ICU_LIB_DIR%\icuuc.lib
::set ICU_DATA_LIBRARY=%ICU_LIB_DIR%\icudt.lib
::set ICU_IO_LIBRARY=%ICU_LIB_DIR%\icuio.lib
::set ICU_INCLUDE_DIRS=%ICU_INCLUDE_DIR%
::set ICU_LIBRARIES=%ICU_I18N_LIBRARY%;%ICU_UC_LIBRARY%;%ICU_DATA_LIBRARY%;%ICU_IO_LIBRARY%
:: -vcpkg: we need this parameter to enable VCPKG integration, but here we don't need VCPKG, because we have set the required CMake variables already.
:: -icu
set __config_params=-platform %__platform% -prefix "%__install_dir%" -nomake tests -nomake examples -feature-relocatable -feature-c++20 -force-bundled-libs -verbose
if /i "%__mingw%" == "1" (
    set __config_params=%__config_params% -reduce-exports
)
set __build_target=install
if /i "%__debug%" == "0" (
    if /i "%__mingw%" == "1" (
        set __build_target=!__build_target!/strip
    )
)
set __build_params=--build . --target %__build_target% --parallel
if /i "%__debug%" == "1" (
    set __config_params=%__config_params% -debug
    set __build_params=%__build_params% --config Debug
) else (
    set __config_params=%__config_params% -release
    set __build_params=%__build_params% --config Release
)
if /i "%__static%" == "1" (
    :: ZLIB_USE_STATIC_LIBS=ON OPENSSL_USE_STATIC_LIBS=ON -openssl-linked
    set __config_params=%__config_params% -static -static-runtime
) else (
    :: -openssl-runtime
    set __config_params=%__config_params% -shared -disable-deprecated-up-to 0x0A0000
)
:: MSVC + LTCG is causing too many bugs!
::if /i "%__debug%" == "0" (
::    if /i "%__static%" == "0" (
::        set __config_params=!__config_params! -ltcg
::    )
::)
set __need_vs=0
if /i "%__msvc%" == "1" set __need_vs=1
if /i "%__clangcl%" == "1" set __need_vs=1
if /i "%__need_vs%" == "1" call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
set __qt_dir=%~dp0..
set __qtbase_dir=%__qt_dir%\qtbase
::set PATH=%OPENSSL_BIN_DIR%;%ICU_BIN_DIR%;%__qtbase_dir%\bin;%PATH%
set PATH=%__qtbase_dir%\bin;%PATH%
cd /d "%~dp0."
if exist %__cmake_dir% rd /s /q %__cmake_dir%
if exist %__install_dir% rd /s /q %__install_dir%
md %__cmake_dir%
cd %__cmake_dir%
::set QT_ENABLE_VCLTL=0
::set QT_ENABLE_YYTHUNKS=0
::if /i "%__debug%" == "0" (
::    set QT_ENABLE_VCLTL=1
::    set QT_ENABLE_YYTHUNKS=1
::)
echo Configure command: call "%__qt_dir%\configure.bat" %__config_params%
call "%__qt_dir%\configure.bat" %__config_params%
if %errorlevel% neq 0 goto err
echo Build command: cmake %__build_params%
cmake %__build_params%
if %errorlevel% neq 0 goto err
goto succ
::if /i "%__static%" == "0" (
::    copy /y "%OPENSSL_BIN_DIR%\*.dll" "%__install_dir%\bin"
::    copy /y "%ICU_BIN_DIR%\*.dll" "%__install_dir%\bin"
::)
::copy /y "%OPENSSL_LIB_DIR%\*.lib" "%__install_dir%\lib"
::copy /y "%ICU_LIB_DIR%\*.lib" "%__install_dir%\lib"
::xcopy "%OPENSSL_INCLUDE_DIR%" "%__install_dir%\include" /s /i /f /r /y
::xcopy "%ICU_INCLUDE_DIR%" "%__install_dir%\include" /s /i /f /r /y
::cd /d "%~dp0."
::if exist %__install_dir%.7z del /f %__install_dir%.7z
::set __7z_params=-mx -myx -ms=on -mqs=on -mmt=on -m0=LZMA2:d=64m:fb=64
::7z a %__install_dir%.7z %__install_dir%\ %__7z_params%
:err
color C0
goto fin
:succ
color A0
goto fin
:fin
cd /d "%~dp0."
endlocal
pause
exit /b 0
