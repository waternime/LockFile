@echo off
title Folder Locker
setlocal enabledelayedexpansion

set "folderName=Private"
set "passFile=pass.txt"

:: ===== Cek password file, kalau tidak ada buat baru =====
if not exist "%passFile%" (
    echo Belum ada password. Buat password baru:
    set /p newpass="Masukkan password baru: "
    echo !newpass!>"%passFile%"
    echo Password berhasil disimpan.
    pause
)

:: Ambil password dari file
set /p savedpass=<"%passFile%"

:: ===== Sembunyikan folder jika belum disembunyikan =====
if exist "%folderName%" (
    attrib "%folderName%" | find /i "H" >nul
    if errorlevel 1 (
        attrib +h +s "%folderName%"
    )
)

:MENU
cls
echo ================================
echo       FOLDER LOCKER MENU
echo ================================
echo 1. Buka folder
echo 2. Sembunyikan folder
echo 3. Ganti password
echo 4. Keluar
echo ================================
set /p choice="Pilih opsi (1/2/3/4): "

if "%choice%"=="1" goto UNLOCK
if "%choice%"=="2" goto LOCK
if "%choice%"=="3" goto CHANGEPASS
if "%choice%"=="4" exit
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

:: Bandingkan input dengan password dari file
if "!inputpass!"=="!savedpass!" (
    attrib -h -s "%folderName%"
    echo Password benar. Folder telah dibuka.
) else (
    echo Password salah!
)
pause
goto MENU

:CHANGEPASS
echo Masukkan password lama:
set /p "oldpass=> "
if not "!oldpass!"=="!savedpass!" (
    echo Password lama salah!
    pause
    goto MENU
)

set /p "newpass=Masukkan password baru: "
echo !newpass!>"%passFile%"
set "savedpass=!newpass!"
echo Password berhasil diganti.
pause
goto MENU