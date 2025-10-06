#!/usr/bin/env bash
# folder_locker_mac.sh
# Simple Folder Locker untuk macOS menggunakan encrypted .dmg
# Default: ~/Private.dmg dimount ke /Volumes/PrivateLocker

DMG_PATH="${HOME}/Private.dmg"
VOLUME_NAME="PrivateLocker"
MOUNT_POINT="/Volumes/${VOLUME_NAME}"
SIZE="100m"   # ubah jika mau ukuran berbeda (mis. 500m, 1g)

clear
while true; do
  cat <<EOF
================================
       FOLDER LOCKER (macOS)
================================
1. Buka (mount) folder
2. Sembunyikan (unmount) folder
3. Ganti password
4. Keluar
================================
EOF
  read -rp "Pilih opsi (1/2/3/4): " choice
  case "$choice" in
    1)
      # Jika DMG belum ada, buat dulu
      if [ ! -f "$DMG_PATH" ]; then
        echo "Belum ada file image. Membuat ${DMG_PATH} (ukuran: ${SIZE})..."
        read -rsp "Masukkan password baru untuk image: " PASS
        echo
        if [ -z "$PASS" ]; then
          echo "Password kosong — batal membuat."
          sleep 1
          continue
        fi
        # Buat dmg terenkripsi (stdinpass menerima password melalui stdin)
        printf "%s" "$PASS" | hdiutil create -encryption -stdinpass -size "$SIZE" -fs APFS -volname "$VOLUME_NAME" "$DMG_PATH" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
          echo "Gagal membuat image. Coba ubah SIZE atau cek izin."
          sleep 2
          continue
        fi
        echo "Image berhasil dibuat: $DMG_PATH"
      fi

      # Mount / attach
      read -rsp "Masukkan password untuk membuka folder: " PASSIN
      echo
      if [ -z "$PASSIN" ]; then
        echo "Password kosong — batal."
        sleep 1
        continue
      fi
      # buat mount point jika belum ada (umumnya hdiutil akan pakai /Volumes)
      mkdir -p "$MOUNT_POINT" 2>/dev/null || true
      printf "%s" "$PASSIN" | hdiutil attach "$DMG_PATH" -stdinpass -mountpoint "$MOUNT_POINT"
      if [ $? -eq 0 ]; then
        echo "Folder berhasil dibuka di: $MOUNT_POINT"
      else
        echo "Gagal membuka. Pastikan password benar atau file image tidak korup."
      fi
      read -n1 -rsp $'Tekan tombol apa saja untuk kembali ke menu...\n'
      ;;
    2)
      # Unmount / eject
      if [ ! -d "$MOUNT_POINT" ]; then
        echo "Folder tidak sedang dimount."
      else
        # detach via hdiutil detach path (bisa /Volumes/Name)
        hdiutil detach "$MOUNT_POINT" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
          echo "Folder telah disembunyikan (dilepas)."
        else
          echo "Gagal melepas. Coba jalankan: hdiutil detach \"$MOUNT_POINT\""
        fi
      fi
      read -n1 -rsp $'Tekan tombol apa saja untuk kembali ke menu...\n'
      ;;
    3)
      # Ganti password
      if [ ! -f "$DMG_PATH" ]; then
        echo "File image tidak ditemukan: $DMG_PATH"
        sleep 1
        continue
      fi
      read -rsp "Masukkan password lama: " OLDP
      echo
      read -rsp "Masukkan password baru: " NEWP
      echo
      if [ -z "$OLDP" ] || [ -z "$NEWP" ]; then
        echo "Password tidak boleh kosong."
        sleep 1
        continue
      fi
      # hdiutil chpass membaca null-terminated old + new password dari stdin
      printf "%s\0%s\0" "$OLDP" "$NEWP" | hdiutil chpass "$DMG_PATH" -oldstdinpass -newstdinpass
      if [ $? -eq 0 ]; then
        echo "Password berhasil diganti."
      else
        echo "Gagal mengganti password. Pastikan password lama benar."
      fi
      read -n1 -rsp $'Tekan tombol apa saja untuk kembali ke menu...\n'
      ;;
    4)
      echo "Keluar..."
      exit 0
      ;;
    *)
      echo "Pilihan tidak dikenal."
      ;;
  esac
  clear
done