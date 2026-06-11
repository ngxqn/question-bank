#!/bin/bash

# Dia chi file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILE_CAUHOI="$SCRIPT_DIR/../data/Cauhoi.txt"
FILE_TRALOI="$SCRIPT_DIR/../data/Traloi.txt"

# Kiem tra ton tai cua cac file truoc khi chay
if [ ! -f "$FILE_CAUHOI" ] || [ ! -f "$FILE_TRALOI" ]; then
    echo "Loi: Khong tim thay file $FILE_CAUHOI hoac $FILE_TRALOI!"
    exit 1
fi

# Kiem tra so luong cau hoi va dap an co khop nhau khong
tong_so_cau=$(wc -l < "$FILE_CAUHOI")
tong_so_dap_an=$(wc -l < "$FILE_TRALOI")
if [ "$tong_so_cau" -ne "$tong_so_dap_an" ]; then
    echo "Canh bao: So luong cau hoi ($tong_so_cau) va dap an ($tong_so_dap_an) khong khop!"
    echo "Vui long kiem tra lai hai file du lieu."
    echo ""
fi

# =====================================================================
# Them cau hoi trac nghiem vao file Cauhoi.txt
# =====================================================================
them_cau_hoi() {
    echo "--- THEM CAU HOI MOI ---"
    read -p "Nhap noi dung cau hoi (Vd: Cau hoi A.x B.y C.z D.t): " noi_dung
    
    if [ -z "$noi_dung" ]; then
        echo "Loi: Noi dung cau hoi khong hop le!"
        return
    fi
    
    echo "$noi_dung" >> "$FILE_CAUHOI"
    echo "=> Da them cau hoi thanh cong"
}

# =====================================================================
# Them cau tra loi vao file Traloi.txt
# =====================================================================
them_dap_an() {
    echo "--- THEM DAP AN DUNG ---"
    read -p "Nhap dap an tuong ung (A/B/C/D): " dap_an
    
    # Chuyen thanh chu hoa va xoa khoang trang
    dap_an=$(echo "$dap_an" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
    
    if [[ ! "$dap_an" =~ ^[A-D]$ ]]; then
        echo "Loi: Dap an khong hop le! Vui long chi nhap A, B, C, hoac D."
        return
    fi
    
    echo "$dap_an" >> "$FILE_TRALOI"
    echo "=> Da them dap an thanh cong."
}

# =====================================================================
# Xuat de va cham diem
# =====================================================================
xuat_de_va_cham_diem() {
    echo "--- XUAT DE THI NGAU NHIEN---"
    
    tong_so_cau=$(wc -l < "$FILE_CAUHOI")
    if [ "$tong_so_cau" -eq 0 ]; then
        echo "Khong co cau hoi"
        return
    fi
    
    echo "Chung toi dang co $tong_so_cau cau hoi."
    read -p "Nhap so luong cau hoi ban muon lam: " so_luong
    
    if [[ ! "$so_luong" =~ ^[0-9]+$ ]] || [ "$so_luong" -le 0 ] || [ "$so_luong" -gt "$tong_so_cau" ]; then
        echo "Loi: So luong cau hoi khong hop le"
        return
    fi

    echo "--------------------------------------------------"
    echo "BAT DAU LAM BAI THI"
    echo "--------------------------------------------------"
    
    # Khai bao mang luu dong goc, dap an cua nguoi lam va dap an dung
    declare -a marray_dong_goc
    declare -a marray_bai_lam
    declare -a marray_dap_an_dung
    
    # Tron cau hoi ngau nhien
    cac_dong_ngau_nhien=$(shuf -i 1-"$tong_so_cau" -n "$so_luong")
    
    stt=0
    for dong in $cac_dong_ngau_nhien; do
        cau_hoi=$(sed -n "${dong}p" "$FILE_CAUHOI")
        dap_an_goc=$(sed -n "${dong}p" "$FILE_TRALOI" | tr -d '\r' | tr '[:lower:]' '[:upper:]')
        
        # Hien thi cau hoi
        echo "Câu $((stt + 1)): $cau_hoi"
        read -p "Cau tra loi cua ban: " lua_chon
        lua_chon=$(echo "$lua_chon" | tr '[:lower:]' '[:upper:]')
        
        # Luu thong tin vao mang
        marray_dong_goc[$stt]=$dong
        marray_bai_lam[$stt]=$lua_chon
        marray_dap_an_dung[$stt]=$dap_an_goc
        
        echo "--------------------------------------------------"
        ((stt++))
    done

    # =====================================================================
    # IN BANG SO SANH 2 COT VA CHAM DIEM
    # =====================================================================
    echo ""
    echo "======================================================="
    echo "                 BANG SO SANH KET QUA                  "
    echo "======================================================="
    # Dinh dang cot
    printf "%-10s | %-20s | %-20s\n" "STT" "CAU TRA LOI CUA BAN" "DAP AN"
    echo "-------------------------------------------------------"
    
    so_cau_dung=0
    for ((i=0; i<so_luong; i++)); do
        user_ans=${marray_bai_lam[$i]}
        true_ans=${marray_dap_an_dung[$i]}
        
        # Kiem tra dung sai
        if [ "$user_ans" == "$true_ans" ]; then
            ((so_cau_dung++))
        fi
        # In tung dong ket qua tuong ung theo dang cot
        printf "Cau %-6d | %-20s | %-20s\n" "$((i + 1))" "$user_ans" "$true_ans"
    done
    
    # TONG KET DIEM SO
    echo "======================================================="
    echo "So cau dung: $so_cau_dung / $so_luong"
    diem=$(awk -v dung="$so_cau_dung" -v tong="$so_luong" 'BEGIN { printf "%.2f", (dung * 10) / tong }')
    echo "Diem: $diem / 10.0"
    echo "======================================================="
}

# =====================================================================
# MENU
# =====================================================================
while true; do
    echo ""
    echo "========================================"
    echo "    QUAN LY NGAN HANG CAU HOI"
    echo "========================================"
    echo "1. Them cau hoi"
    echo "2. Them cau tra loi dung"
    echo "3. Xuat de va cham diem"
    echo "4. Thoat"
    echo "========================================"
    read -p "Vui long chon chuc nang (1-4): " lua_chon
    echo ""

    case $lua_chon in
        1) them_cau_hoi ;;
        2) them_dap_an ;;
        3) xuat_de_va_cham_diem ;;
        4) 
            echo "Tam biet"
            exit 0 
            ;;
        *) 
            echo "Lua chon khong hop le. Vui long chon tu 1 den 4" 
            ;;
    esac
done

