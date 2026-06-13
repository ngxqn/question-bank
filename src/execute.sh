#!/bin/bash

# Địa chỉ file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILE_CAUHOI="$SCRIPT_DIR/../data/Cauhoi.txt"
FILE_TRALOI="$SCRIPT_DIR/../data/Traloi.txt"

# Kiểm tra tồn tại của các file
if [ ! -f "$FILE_CAUHOI" ] || [ ! -f "$FILE_TRALOI" ]; then
    echo "Lỗi: Không tìm thấy file $FILE_CAUHOI hoặc $FILE_TRALOI!"
    exit 1
fi

# Kiểm tra số lượng câu hỏi và đáp án có khớp nhau không
tong_so_cau=$(wc -l < "$FILE_CAUHOI")
tong_so_dap_an=$(wc -l < "$FILE_TRALOI")
if [ "$tong_so_cau" -ne "$tong_so_dap_an" ]; then
    echo "Cảnh báo: Số lượng câu hỏi ($tong_so_cau) và đáp án ($tong_so_dap_an) không khớp!"
    echo "Vui lòng kiểm tra lại hai file dữ liệu."
    echo ""
fi

# =====================================================================
# Thêm câu hỏi & đáp án
# =====================================================================
them_cau_hoi_va_dap_an() {
    echo "--- THÊM CÂU HỎI VÀ ĐÁP ÁN MỚI ---"
    read -p "Nhập nội dung câu hỏi (Vd: Câu hỏi A.x B.y C.z D.t): " noi_dung
    
    if [ -z "$noi_dung" ]; then
        echo "Lỗi: Nội dung câu hỏi không hợp lệ!"
        return
    fi
    
    read -p "Nhập đáp án tương ứng (A/B/C/D): " dap_an
    
    # Chuyển thành chữ hoa và xóa khoảng trắng
    dap_an=$(echo "$dap_an" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
    
    if [[ ! "$dap_an" =~ ^[A-D]$ ]]; then
        echo "Lỗi: Đáp án không hợp lệ! Vui lòng chỉ nhập A, B, C hoặc D."
        echo "Chưa thêm câu hỏi và đáp án vào hệ thống."
        return
    fi
    
    echo "$noi_dung" >> "$FILE_CAUHOI"
    echo "$dap_an" >> "$FILE_TRALOI"
    echo "=> Đã thêm câu hỏi và đáp án thành công!"
}

# =====================================================================
# Xuất đề và chấm điểm
# =====================================================================
xuat_de_va_cham_diem() {
    echo "--- XUẤT ĐỀ VÀ CHẤM ĐIỂM ---"
    
    tong_so_cau=$(wc -l < "$FILE_CAUHOI")
    if [ "$tong_so_cau" -eq 0 ]; then
        echo "Không có câu hỏi"
        return
    fi
    
    echo "Hiện tại có $tong_so_cau câu hỏi."
    read -p "Nhập số lượng câu hỏi bạn muốn làm: " so_luong
    
    if [[ ! "$so_luong" =~ ^[0-9]+$ ]] || [ "$so_luong" -le 0 ] || [ "$so_luong" -gt "$tong_so_cau" ]; then
        echo "Lỗi: Số lượng câu hỏi không hợp lệ."
        return
    fi

    echo "--------------------------------------------------"
    echo "BẮT ĐẦU LÀM BÀI THI"
    echo "--------------------------------------------------"
    
    # Khai báo mảng lưu dòng gốc, đáp án của người làm và đáp án đúng
    declare -a marray_dong_goc
    declare -a marray_bai_lam
    declare -a marray_dap_an_dung
    
    # Trộn câu hỏi ngẫu nhiên
    cac_dong_ngau_nhien=$(shuf -i 1-"$tong_so_cau" -n "$so_luong")
    
    stt=0
    for dong in $cac_dong_ngau_nhien; do
        cau_hoi=$(sed -n "${dong}p" "$FILE_CAUHOI")
        dap_an_goc=$(sed -n "${dong}p" "$FILE_TRALOI" | tr -d '\r' | tr '[:lower:]' '[:upper:]')
        
        # Hiển thị câu hỏi
        echo "Câu $((stt + 1)): $cau_hoi"
        read -p "Câu trả lời của bạn: " lua_chon
        lua_chon=$(echo "$lua_chon" | tr '[:lower:]' '[:upper:]')
        
        # Lưu thông tin vào mảng
        marray_dong_goc[$stt]=$dong
        marray_bai_lam[$stt]=$lua_chon
        marray_dap_an_dung[$stt]=$dap_an_goc
        
        echo "--------------------------------------------------"
        ((stt++))
    done

    # =====================================================================
    # IN BẢNG SO SÁNH 2 CỘT VÀ CHẤM ĐIỂM
    # =====================================================================
    echo ""
    echo "======================================================="
    echo "                 BẢNG SO SÁNH KẾT QUẢ                  "
    echo "======================================================="
    # Định dạng cột
    printf "%-10s | %-20s | %-20s\n" "STT" "CÂU TRẢ LỜI CỦA BẠN" "ĐÁP ÁN"
    echo "-------------------------------------------------------"
    
    so_cau_dung=0
    for ((i=0; i<so_luong; i++)); do
        user_ans=${marray_bai_lam[$i]}
        true_ans=${marray_dap_an_dung[$i]}
        
        # Kiểm tra đúng sai
        if [ "$user_ans" == "$true_ans" ]; then
            ((so_cau_dung++))
        fi
        # In từng dòng kết quả tương ứng theo dạng cột
        printf "Câu %-6d | %-20s | %-20s\n" "$((i + 1))" "$user_ans" "$true_ans"
    done
    
    # TỔNG KẾT ĐIỂM SỐ
    echo "======================================================="
    echo "Số câu đúng: $so_cau_dung / $so_luong"
    diem=$(awk -v dung="$so_cau_dung" -v tong="$so_luong" 'BEGIN { printf "%.2f", (dung * 10) / tong }')
    echo "Điểm: $diem / 10.0"
    echo "======================================================="
}

# =====================================================================
# MENU
# =====================================================================
while true; do
    echo ""
    echo "========================================"
    echo "    QUẢN LÝ NGÂN HÀNG CÂU HỎI"
    echo "========================================"
    echo "1. Thêm câu hỏi và đáp án"
    echo "2. Xuất đề và chấm điểm"
    echo "3. Thoát"
    echo "========================================"
    read -p "Vui lòng chọn chức năng (1-3): " lua_chon
    echo ""

    case $lua_chon in
        1) them_cau_hoi_va_dap_an ;;
        2) xuat_de_va_cham_diem ;;
        3) 
            echo "Tạm biệt!"
            exit 0 
            ;;
        *) 
            echo "Lựa chọn không hợp lệ. Vui lòng chọn từ 1 đến 3" 
            ;;
    esac
done

