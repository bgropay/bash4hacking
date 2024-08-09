#!/bin/bash
# Installer reaver otomatis
# Dibuat oleh Ropay
#
# Jika ada bug atau masalah saat proses instalasi
# laporkan di 'https://github.com/bgropay/bash4hacking/issues'

# Path untuk menyimpan semua tools yang diperlukan oleh wpscry.
path_app="/opt"

# Fungsi untuk mengecek apakah Anda memiliki koneksi internet atau tidak.
function cek_koneksi_internet(){
        echo "[*] Mengecek koneksi internet..."
        if ping -c 1 8.8.8.8 >> /dev/null 2>&1; then
	        sleep 3
                echo "[+] Anda memiliki koneksi internet. Proses instalasi dapat dilanjutkan."
	else
                sleep 5
                echo "[-] Anda tidak memiliki koneksi internet. Proses instalasi tidak dapat dilanjutkan."
		exit 1
        fi
}

# Fungsi untuk mengecek apakah Anda sudah menginstal git atau belum.
function cek_git(){
        echo "[*] Mengecek git..."
	if command -v git >> /dev/null 2>&1; then
                sleep 3
                echo "[+] Git sudah terinstal."
	else
                sleep 5
		echo "[-] Git belum terinstal."
                echo "[*] Menginstal git..."
		sleep 3
                apt-get install git -y
		if [[ $? -eq 0 ]]; then
                        echo "[+] Git berhasil diinstal. proses instalasi dapat dilanjutkan."
		else
                        echo "[-] Git gagal diinstal. proses instalasi tidak dapat dilanjutkan."
			exit 1
                fi
	fi
}

# Pindah ke folder '/opt'
cd "${path_app}"

# Fungsi untuk menginstal tools reaver.
function instal_reaver(){
        url_reaver="https://github.com/t6x/reaver-wps-fork-t6x"
        path_reaver="reaver-wps-fork-t6x"

        # list dependensi yang diperlukan oleh reaver.
        daftar_dependensi_reaver=(
                "wireless-tools"
                "build-essential"
                "libpcap-dev"
        	# "pixiewps"
	        # "aircrack-ng"
	        "libsdl2-2.0-0"
        )

        # Menginstal seluruh dependensi yang diperlukan oleh reaver 
        for dependensi_reaver in "${daftar_dependensi_reaver[@]}"; do
	        apt-get install "${dependensi_reaver}" -y
        done

        # Instal reaver.
        git clone "${url_reaver}"
        cd "${path_reaver}/src"
        ./configure
        make
        make install
	
	cd ../../ # kembali ke direktori '/opt'
}

function instal_pixiewps(){
        url_pixiewps="https://github.com/wiire-a/pixiewps"
        path_pixiewps="pixiewps"

        # List dependensi yang diperlukan oleh pixiewps.
        # daftar_dependensi_pixiewps=(
        #         "build-essential"
        # )

        # Menginstal seluruh dependensi yang diperlukan oleh pixiewps 
        # for dependensi_pixiewps in "${daftar_dependensi_pixiewps[@]}"; do
        #        apt-get install "${dependensi_pixiewps}"
        # done

        # Instal pixiewps
        git clone "${url_pixiewps}"
        cd "${path_pixiewps}"
        make
        make install

        cd ../ # kembali ke direktori '/opt'
}

function instal_aircrack(){
        url_aircrack="https://github.com/aircrack-ng/aircrack-ng"
        path_aircrack="aircrack-ng"
        
        # List dependensi yang diperlukan oleh aircrack-ng.
        daftar_dependensi_aircrack=(
                # "build-essential" 
        	"autoconf"
                "automake"
        	"libtool"
                "pkg-config"
        	"libnl-3-dev"
                "libnl-genl-3-dev"
        	"libssl-dev ethtool"
                "libssl-dev"
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

        # Menginstal seluruh dependensi yang diperlukan oleh aircrack-ng
        for dependensi_aircrack in "${daftar_dependensi_aircrack[@]}"; do
                apt-get install "${dependensi_aircrack}" -y
        done

        # Instal aircrack-ng
        git clone "${url_aircrack}"
        cd "${path_aircrack}"
        autoreconf -i
        ./configure --with-experimental
        make
        make install 
        ldconfig

        cd ../ # kembali ke direktori '/opt'
}
