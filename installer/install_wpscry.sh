#!/bin/bash
# Installer reaver otomatis
# Dibuat oleh Ropay
#
# Jika ada bug atau masalah saat proses instalasi
# laporkan di ''

url_reaver="https://github.com/t6x/reaver-wps-fork-t6x"
path_app="/opt"
path_reaver="reaver-wps-fork-t6x"

daftar_dependensi_reaver=(
  "build-essential"
  "libpcap-dev"
	"pixiewps"
	"aircrack-ng"
	"libsdl2-2.0-0"
)

for dependensi_reaver in "${daftar_dependensi_reaver[@]}"; do
	apt-get install "${dependensi_reaver}"
done

cd "${path_app}"
git clone "${url_reaver}"
cd "${path_reaver}/src"
./configure
make
make install
cd -
