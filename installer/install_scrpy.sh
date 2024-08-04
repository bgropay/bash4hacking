#!/bin/bash
# Installer scrpy otomatis
# Dibuat oleh Ropay
#
# Jika ada bug atau masalah saat proses instalasi
# laporkan di ''

url_scrpy="https://github.com/Genymobile/scrcpy"
path_app="/opt"
path_scrpy="scrpy"

daftar_dependensi_scrpy=(
	"ffmpeg"
	"pulseaudio"
	"libsdl2-2.0-0"
	"adb"
	"wget"
        "gcc"
	"git"
	"pkg-config"
	"meson"
	"ninja-build"
	"libsdl2-dev"
	"libavcodec-dev"
	"libavdevice-dev"
	"libavformat-dev"
	"libavutil-dev"
        "libswresample-dev"
	"libusb-1.0-0"
	"libusb-1.0-0-dev"
)

for dependensi_scrpy in "${daftar_dependensi_scrpy[@]}"; do
	apt-get install "${dependensi_scrpy}"
done

cd "${path_app}"
git clone "${url_scrpy}"
cd "${path_scrpy}"
./install_release.sh
cd -
