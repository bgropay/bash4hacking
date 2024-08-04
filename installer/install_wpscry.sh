#!/bin/bash
# Installer reaver otomatis
# Dibuat oleh Ropay
#
# Jika ada bug atau masalah saat proses instalasi
# laporkan di 'https://github.com/bgropay/bash4hacking/issues'

url_reaver="https://github.com/t6x/reaver-wps-fork-t6x"
url_pixiewps="https://github.com/wiire-a/pixiewps"
path_app="/opt"
path_reaver="reaver-wps-fork-t6x"
path_pixiewps="pixiewps"

daftar_dependensi_reaver=(
        "wireless-tools"
        "build-essential"
        "libpcap-dev"
	# "pixiewps"
	"aircrack-ng"
	"libsdl2-2.0-0"
)

daftar_dependensi_pixiewps=(
        "build-essential"
)

apt-get update -y

# menginstal seluruh dependensi yang diperlukan oleh reaver 
for dependensi_reaver in "${daftar_dependensi_reaver[@]}"; do
	apt-get install "${dependensi_reaver}" -y
done

# menginstal seluruh dependensi yang diperlukan oleh pixiewps 
for dependensi_pixiewps in "${daftar_dependensi_pixiewps[@]}"; do
        apt-get install "${dependensi_pixiewps}"
done

cd "${path_app}"
git clone "${url_reaver}"
cd "${path_reaver}/src"
./configure
make
make install
cd ../../ # kembali ke direktori '/opt'
git clone "${url_pixiewps}"
cd "${path_pixiewps}"
make
make install
