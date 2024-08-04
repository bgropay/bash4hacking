#!/bin/bash
# Installer reaver otomatis
# Dibuat oleh Ropay
#
# Jika ada bug atau masalah saat proses instalasi
# laporkan di 'https://github.com/bgropay/bash4hacking/issues'

url_reaver="https://github.com/t6x/reaver-wps-fork-t6x"
url_pixiewps="https://github.com/wiire-a/pixiewps"
url_aircrack="https://github.com/aircrack-ng/aircrack-ng"
path_app="/opt"
path_reaver="reaver-wps-fork-t6x"
path_pixiewps="pixiewps"
path_aircrack="aircrack-ng"

daftar_dependensi_reaver=(
        "wireless-tools"
        "build-essential"
        "libpcap-dev"
	# "pixiewps"
	# "aircrack-ng"
	"libsdl2-2.0-0"
)

# daftar_dependensi_pixiewps=(
#         "build-essential"
# )

daftar_dependensi_aircrack=(
        # "build-essential" 
	"autoconf"
        "automake"
	"libtool"
        "pkg-config"
	"libnl-3-dev"
        "libnl-genl-3-dev"
	"libssl-dev ethtool"
        "shtool"
	"rfkill"
        "zlib1g-dev"
	# "libpcap-dev"
        "libsqlite3-dev"
	"libpcre2-dev"
        "libhwloc-dev"
	"libcmocka-dev"
        "hostapd"
	"wpasupplicant"
        "tcpdump"
	"screen"
        "iw"
	"usbutils"
        "expect"
)

apt-get update -y

# menginstal seluruh dependensi yang diperlukan oleh reaver 
for dependensi_reaver in "${daftar_dependensi_reaver[@]}"; do
	apt-get install "${dependensi_reaver}" -y
done

# menginstal seluruh dependensi yang diperlukan oleh pixiewps 
# for dependensi_pixiewps in "${daftar_dependensi_pixiewps[@]}"; do
#        apt-get install "${dependensi_pixiewps}"
# done

# menginstal seluruh dependensi yang diperlukan oleh aircrack-ng
for dependensi_aircrack in "${daftar_dependensi_aircrack[@]}"; do
	apt-get install "${dependensi_aircrack}" -y
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
cd ../ # kembali ke direktori '/opt'
git clone "${url_aircrack}"
cd "${path_aircrack}"
autoreconf -i
./configure --with-experimental
make
make install 
ldconfig
