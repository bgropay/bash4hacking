#!/bin/bash
# Installer scrpy otomatis
# Dibuat oleh Ropay
#
# Jika ada bug atau masalah saat proses instalasi
# laporkan di ''

url="https://github.com/Genymobile/scrcpy"
path="scrpy"

daftar_dependensi=(
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

for dependensi in "${daftar_dependensi[@]}"; do
	apt-get install "${dependensi}"
done

git clone "${url}"
cd "${path}"
./install_release.sh
