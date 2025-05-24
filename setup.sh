#!/bin/ash

DIR=/usr/bin
CONFIG=/etc/config
INIT=/etc/init.d
MODEL=/usr/lib/lua/luci/model/cbi
CONTROLLER=/usr/lib/lua/luci/controller
GITHUB=https://raw.githubusercontent.com/kangzul/HiMon/main
MAX_RETRIES=3

finish() {
    clear
    echo ""
    echo "BERHASIL INSTALL HILINK SERVICE"
    echo ""
    echo "Untuk Menjalankan Ketik m dan enter di terminal"
    sleep 3
    echo ""
    echo ""
}

download_file() {
    local dest=$1
    local src=$2
    local retries=0

    while [ $retries -lt $MAX_RETRIES ]; do
        wget -O "$dest" "$src"
        if [ $? -eq 0 ] && [ -s "$dest" ]; then
            chmod +x "$dest"
            return 0
        fi
        echo "Gagal mengunduh $src, mencoba ulang... ($((retries + 1))/$MAX_RETRIES)"
        retries=$((retries + 1))
        sleep 2
    done

    echo "Gagal mengunduh $src setelah $MAX_RETRIES percobaan. Menghentikan instalasi."
    exit 1
}

download_files() {
    clear
    echo "Sedang mengunduh file yang diperlukan..."
    echo ""
    download_file "$DIR/m" "$GITHUB/usr/bin/m"
    download_file "$DIR/hilink" "$GITHUB/usr/bin/hilink"
    download_file "$DIR/himon" "$GITHUB/usr/bin/himon"
    download_file "$DIR/balong-nvtool" "$GITHUB/usr/bin/balong-nvtool"
    download_file "$CONFIG/hilink" "$GITHUB/hilink"
    download_file "$INIT/himon" "$GITHUB/etc/init.d/himon"
    download_file "$CONTROLLER/hilink.lua" "$GITHUB/controller/hilink.lua"
    download_file "$MODEL/hilink.lua" "$GITHUB/cbi/hilink.lua"
    finish
}

echo ""

while true; do
    read -p "This will download the files into $DIR. Do you want to continue (y/n)? " yn
    case $yn in
    [Yy]*)
        download_files
        break
        ;;
    [Nn]*) exit ;;
    *) echo "Please answer 'y' or 'n'." ;;
    esac
done
