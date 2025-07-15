@echo off
title Folder Locker
set "folderName=Private"
set "password=rahasia123"

:MENU
cls
echo ================================
echo       FOLDER LOCKER MENU
echo ================================
echo 1. Buka folder
echo 2. Sembunyikan folder
echo 3. Keluar
echo ================================
set /p choice="Pilih opsi (1/2/3): "

if "%choice%"=="1" goto UNLOCK
if "%choice%"=="2" goto LOCK
if "%choice%"=="3" exit
goto MENU

:LOCK
if not exist "%folderName%" (
    echo Folder "%folderName%" belum ada. Membuat folder...
    md "%folderName%"
)

set /p confirm="Yakin ingin menyembunyikan folder? (Y/N): "
if /I "%confirm%"=="Y" (
    attrib +h +s "%folderName%"
    echo Folder telah disembunyikan.
) else (
    echo Folder tidak disembunyikan.
)
pause
goto MENU

:UNLOCK
if not exist "%folderName%" (
    echo Folder "%folderName%" belum ada. Membuat folder...
    md "%folderName%"
    pause
    goto MENU
)

echo Masukkan password untuk membuka folder:
set /p "inputpass=> "
if "%inputpass%"=="%password%" (
    attrib -h -s "%folderName%"
    echo Password benar. Folder telah dibuka.
) else (
    echo Password salah!
)
pause
goto MENU
