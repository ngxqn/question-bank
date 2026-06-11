# question-bank

Đây là công cụ viết bằng Bash script chạy trên terminal giúp quản lý ngân hàng câu hỏi trắc nghiệm và tổ chức thi trắc nghiệm ngẫu nhiên.

## Cấu trúc dự án

* `src/execute.sh`: File script chính chứa toàn bộ logic chương trình.
* `data/Cauhoi.txt`: Lưu trữ danh sách các câu hỏi (mỗi câu hỏi trên 1 dòng).
* `data/Traloi.txt`: Lưu trữ danh sách đáp án đúng tương ứng (mỗi đáp án trên 1 dòng).
* `docs/requirements.md`: Yêu cầu đề tài.

## Yêu cầu hệ thống

Chương trình chạy bằng Bash shell. Nếu chạy trên Windows, cần sử dụng một trong các môi trường sau:
* **Git Bash**
* **WSL**
* **MSYS2** hoặc **Cygwin**

## Hướng dẫn sử dụng

1. Mở Terminal / Git Bash trong thư mục dự án này.
2. Chạy lệnh sau để khởi động chương trình:
   ```bash
   bash src/execute.sh
   ```
3. Chọn các chức năng từ menu hiển thị trên màn hình:
   * **Chức năng 1**: Thêm câu hỏi mới và nhập đáp án tương ứng trực tiếp.
   * **Chức năng 2**: Chọn số lượng câu hỏi cần làm, thực hiện bài kiểm tra ngẫu nhiên và xem kết quả chấm điểm.
   * **Chức năng 3**: Thoát chương trình.
