@echo off
chcp 65001
title Preparing VCPKG ...
setlocal enabledelayedexpansion
cls
set __vcpkg_dir=%~dp0..\vcpkg
set __triplet_dir=%~dp0vcpkg-custom-triplets
set __qt_deps=openssl icu
set __vcpkg_triplets=x64-windows-shared-mt-release x64-windows-static-mt-release
cd /d "%__vcpkg_dir%"
call bootstrap-vcpkg.bat
cd /d "%__vcpkg_dir%"
:: Always try to update the libraries to the latest version.
vcpkg update
:: Without the "--no-dry-run" parameter, VCPKG won't upgrade
:: the installed libraries in reality.
vcpkg upgrade --no-dry-run
for %%i in (%__vcpkg_triplets%) do vcpkg install %__qt_deps% --triplet=%%i --overlay-triplets="%__triplet_dir%"
endlocal
cd /d "%~dp0"
pause
exit /b 0