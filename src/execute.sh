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

# Định nghĩa các mã màu ANSI (Cyan & Slate Gray theme)
CYAN='\033[0;36m'
BOLD_CYAN='\033[1;36m'
GRAY='\033[0;90m'      # Slate Gray
WHITE='\033[0;37m'
BOLD_WHITE='\033[1;37m'
GREEN='\033[0;32m'
BOLD_GREEN='\033[1;32m'
RED='\033[0;31m'
BOLD_RED='\033[1;31m'
YELLOW='\033[0;33m'
BOLD_YELLOW='\033[1;33m'
RESET='\033[0m'

# Kiểm tra số lượng câu hỏi và đáp án có khớp nhau không
tong_so_cau=$(wc -l < "$FILE_CAUHOI")
tong_so_dap_an=$(wc -l < "$FILE_TRALOI")
if [ "$tong_so_cau" -ne "$tong_so_dap_an" ]; then
    echo -e "  ${BOLD_YELLOW}⚠ Cảnh báo:${RESET} Số lượng câu hỏi (${BOLD_WHITE}$tong_so_cau${RESET}) và đáp án (${BOLD_WHITE}$tong_so_dap_an${RESET}) không khớp!"
    echo -e "  Vui lòng kiểm tra lại hai file dữ liệu trong thư mục 'data/'."
    echo ""
fi

# Hàm xóa khoảng trắng đầu/cuối của chuỗi
trim() {
    echo "$1" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

# Hàm hiển thị Banner chính
print_banner() {
    clear
    echo -e "${GRAY}┌────────────────────────────────────────┐${RESET}"
    echo -e "${GRAY}│${RESET}       ${BOLD_CYAN}QUẢN LÝ NGÂN HÀNG CÂU HỎI${RESET}        ${GRAY}│${RESET}"
    echo -e "${GRAY}└────────────────────────────────────────┘${RESET}"
}

# Hàm tách câu hỏi và các lựa chọn
# Input: line_content
# Output: Các biến toàn cục: QH_TEXT, OPT_A, OPT_B, OPT_C, OPT_D
parse_question() {
    local line=$(echo "$1" | tr -d '\r')
    
    if [[ "$line" =~ A\..*B\..*C\..*D\. ]]; then
        QH_TEXT=$(echo "$line" | sed -E 's/ A\..*$//')
        OPT_A=$(echo "$line" | sed -E 's/^.* A\.//; s/ B\..*$//')
        OPT_B=$(echo "$line" | sed -E 's/^.* B\.//; s/ C\..*$//')
        OPT_C=$(echo "$line" | sed -E 's/^.* C\.//; s/ D\..*$//')
        OPT_D=$(echo "$line" | sed -E 's/^.* D\.//')
    else
        QH_TEXT="$line"
        OPT_A=""
        OPT_B=""
        OPT_C=""
        OPT_D=""
    fi

    QH_TEXT=$(trim "$QH_TEXT")
    OPT_A=$(trim "$OPT_A")
    OPT_B=$(trim "$OPT_B")
    OPT_C=$(trim "$OPT_C")
    OPT_D=$(trim "$OPT_D")
}

# Hàm vẽ khung hiển thị câu hỏi dạng box
draw_question_box() {
    local index="$1"
    local total="$2"
    local question_text="$3"
    local opt_a="$4"
    local opt_b="$5"
    local opt_c="$6"
    local opt_d="$7"

    echo -e "  ${GRAY}┌──${RESET} ${BOLD_CYAN}CÂU HỎI $index/$total${RESET} ${GRAY}──────────────────────────────────────────${RESET}"
    echo -e "  ${GRAY}│${RESET} ${BOLD_WHITE}$question_text${RESET}"
    
    if [ -n "$opt_a" ]; then
        echo -e "  ${GRAY}│${RESET}"
        echo -e "  ${GRAY}│${RESET}   ${CYAN}[A]${RESET} $opt_a"
        echo -e "  ${GRAY}│${RESET}   ${CYAN}[B]${RESET} $opt_b"
        echo -e "  ${GRAY}│${RESET}   ${CYAN}[C]${RESET} $opt_c"
        echo -e "  ${GRAY}│${RESET}   ${CYAN}[D]${RESET} $opt_d"
    fi
    echo -e "  ${GRAY}└──────────────────────────────────────────────────────────${RESET}"
}

# =====================================================================
# Thêm câu hỏi & đáp án
# =====================================================================
them_cau_hoi_va_dap_an() {
    print_banner
    echo -e "  ${BOLD_WHITE}--- THÊM CÂU HỎI VÀ ĐÁP ÁN MỚI ---${RESET}"
    echo ""
    echo -ne "  ${BOLD_CYAN}❯${RESET} Nhập nội dung câu hỏi (Định dạng: Câu hỏi A.x B.y C.z D.t):\n  ${GRAY}↳${RESET} "
    read -r noi_dung
    
    if [ -z "$noi_dung" ]; then
        echo -e "\n  ${BOLD_RED}Lỗi:${RESET} Nội dung câu hỏi không hợp lệ!"
        echo -ne "  ${GRAY}Nhấn Enter để quay lại...${RESET} "
        read -r
        return
    fi

    # Kiểm tra xem câu hỏi có chứa định dạng A. B. C. D. không
    if [[ ! "$noi_dung" =~ A\..*B\..*C\..*D\. ]]; then
        echo -e "\n  ${BOLD_RED}Lỗi:${RESET} Câu hỏi phải bao gồm đầy đủ 4 đáp án A., B., C., D.!"
        echo -ne "  ${GRAY}Nhấn Enter để quay lại...${RESET} "
        read -r
        return
    fi
    
    echo ""
    echo -ne "  ${BOLD_CYAN}❯${RESET} Nhập đáp án tương ứng (A/B/C/D): "
    read -r dap_an
    
    # Chuyển thành chữ hoa và xóa khoảng trắng
    dap_an=$(echo "$dap_an" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
    
    if [[ ! "$dap_an" =~ ^[A-D]$ ]]; then
        echo -e "\n  ${BOLD_RED}Lỗi:${RESET} Đáp án không hợp lệ! Vui lòng chỉ nhập A, B, C hoặc D."
        echo -e "  Chưa thêm câu hỏi và đáp án vào hệ thống."
        echo -ne "  ${GRAY}Nhấn Enter để quay lại...${RESET} "
        read -r
        return
    fi
    
    echo "$noi_dung" >> "$FILE_CAUHOI"
    echo "$dap_an" >> "$FILE_TRALOI"
    echo -e "\n  ${BOLD_GREEN}✔ Đã thêm câu hỏi và đáp án thành công!${RESET}"
    echo -ne "  ${GRAY}Nhấn Enter để quay lại...${RESET} "
    read -r
}

# =====================================================================
# Xuất đề và chấm điểm
# =====================================================================
xuat_de_va_cham_diem() {
    print_banner
    echo -e "  ${BOLD_WHITE}--- XUẤT ĐỀ VÀ CHẤM ĐIỂM ---${RESET}"
    echo ""
    
    tong_so_cau=$(wc -l < "$FILE_CAUHOI")
    if [ "$tong_so_cau" -eq 0 ]; then
        echo -e "  ${BOLD_RED}Lỗi:${RESET} Không có câu hỏi nào trong hệ thống!"
        echo -ne "  ${GRAY}Nhấn Enter để quay lại...${RESET} "
        read -r
        return
    fi
    
    echo -e "  Hiện tại có ${BOLD_CYAN}$tong_so_cau${RESET} câu hỏi."
    echo -ne "  ${BOLD_CYAN}❯${RESET} Nhập số lượng câu hỏi bạn muốn làm: "
    read -r so_luong
    
    if [[ ! "$so_luong" =~ ^[0-9]+$ ]] || [ "$so_luong" -le 0 ] || [ "$so_luong" -gt "$tong_so_cau" ]; then
        echo -e "\n  ${BOLD_RED}Lỗi:${RESET} Số lượng câu hỏi không hợp lệ."
        echo -ne "  ${GRAY}Nhấn Enter để quay lại...${RESET} "
        read -r
        return
    fi

    # Khai báo mảng lưu dòng gốc, đáp án của người làm và đáp án đúng
    declare -a marray_dong_goc
    declare -a marray_bai_lam
    declare -a marray_dap_an_dung
    
    # Trộn câu hỏi ngẫu nhiên
    cac_dong_ngau_nhien=$(shuf -i 1-"$tong_so_cau" -n "$so_luong")
    
    stt=0
    for dong in $cac_dong_ngau_nhien; do
        clear
        print_banner
        
        cau_hoi_dong=$(sed -n "${dong}p" "$FILE_CAUHOI")
        dap_an_goc=$(sed -n "${dong}p" "$FILE_TRALOI" | tr -d '\r' | tr '[:lower:]' '[:upper:]')
        
        parse_question "$cau_hoi_dong"
        
        draw_question_box "$((stt + 1))" "$so_luong" "$QH_TEXT" "$OPT_A" "$OPT_B" "$OPT_C" "$OPT_D"
        
        while true; do
            echo -ne "  ${BOLD_CYAN}❯${RESET} Câu trả lời của bạn (A/B/C/D): "
            read -r lua_chon
            lua_chon=$(echo "$lua_chon" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
            
            if [[ "$lua_chon" =~ ^[A-D]$ ]]; then
                break
            else
                echo -e "  ${BOLD_RED}Lỗi:${RESET} Vui lòng chỉ nhập A, B, C hoặc D!"
            fi
        done
        
        marray_dong_goc[$stt]=$dong
        marray_bai_lam[$stt]=$lua_chon
        marray_dap_an_dung[$stt]=$dap_an_goc
        
        ((stt++))
    done

    # =====================================================================
    # IN BẢNG SO SÁNH KẾT QUẢ VÀ CHẤM ĐIỂM
    # =====================================================================
    clear
    print_banner
    echo -e "  ${BOLD_WHITE}--- BẢNG SO SÁNH KẾT QUẢ ---${RESET}"
    echo ""
    
    echo -e "  ${GRAY}┌─────────┬────────────────────────┬───────────┬──────────────┐${RESET}"
    echo -e "  ${GRAY}│${RESET}   ${BOLD_WHITE}STT${RESET}   ${GRAY}│${RESET}  ${BOLD_WHITE}CÂU TRẢ LỜI CỦA BẠN${RESET}   ${GRAY}│${RESET}  ${BOLD_WHITE}ĐÁP ÁN${RESET}   ${GRAY}│${RESET}  ${BOLD_WHITE}TRẠNG THÁI${RESET}  ${GRAY}│${RESET}"
    echo -e "  ${GRAY}├─────────┼────────────────────────┼───────────┼──────────────┤${RESET}"
    
    so_cau_dung=0
    for ((i=0; i<so_luong; i++)); do
        user_ans=${marray_bai_lam[$i]}
        true_ans=${marray_dap_an_dung[$i]}
        
        if [ "$user_ans" == "$true_ans" ]; then
            ((so_cau_dung++))
            status_print="   ${GREEN}✔ ĐÚNG${RESET}     "
        else
            status_print="   ${RED}✘ SAI${RESET}      "
        fi
        
        printf "  ${GRAY}│${RESET} Câu %-4d ${GRAY}│${RESET}           %-13s ${GRAY}│${RESET}     %-6s ${GRAY}│${RESET}%s${GRAY}│${RESET}\n" "$((i + 1))" "$user_ans" "$true_ans" "$status_print"
    done
    
    echo -e "  ${GRAY}└─────────┴────────────────────────┴───────────┴──────────────┘${RESET}"
    
    # TỔNG KẾT ĐIỂM SỐ
    echo ""
    diem=$(awk -v dung="$so_cau_dung" -v tong="$so_luong" 'BEGIN { printf "%.2f", (dung * 10) / tong }')
    
    echo -e "  ${GRAY}┌── TỔNG KẾT BÀI THI ─────────────────────────────────────────${RESET}"
    echo -e "  ${GRAY}│${RESET}  Tổng số câu đúng: ${BOLD_GREEN}$so_cau_dung${RESET} / ${BOLD_WHITE}$so_luong${RESET}"
    echo -e "  ${GRAY}│${RESET}  Điểm số: ${BOLD_CYAN}$diem${RESET} / ${BOLD_WHITE}10.0${RESET}"
    echo -e "  ${GRAY}└─────────────────────────────────────────────────────────────${RESET}"
    echo ""
    echo -ne "  ${GRAY}Nhấn Enter để quay lại menu chính...${RESET} "
    read -r
}

# =====================================================================
# MENU CHÍNH
# =====================================================================
while true; do
    print_banner
    echo -e "  ${CYAN}1.${RESET} Thêm câu hỏi và đáp án"
    echo -e "  ${CYAN}2.${RESET} Xuất đề và chấm điểm"
    echo -e "  ${CYAN}3.${RESET} Thoát"
    echo -e "  ${GRAY}────────────────────────────────────────${RESET}"
    echo -ne "  ${BOLD_CYAN}❯${RESET} Vui lòng chọn chức năng (1-3): "
    read -r lua_chon
    echo ""

    case $lua_chon in
        1) them_cau_hoi_va_dap_an ;;
        2) xuat_de_va_cham_diem ;;
        3) 
            echo -e "  Tạm biệt!"
            exit 0 
            ;;
        *) 
            echo -e "  ${BOLD_RED}Lựa chọn không hợp lệ!${RESET} Vui lòng chọn từ 1 đến 3."
            sleep 1.5
            ;;
    esac
done
