# question-bank

Đây là công cụ viết bằng Bash script chạy trên terminal giúp quản lý ngân hàng câu hỏi trắc nghiệm và tổ chức thi trắc nghiệm ngẫu nhiên.

## Cấu trúc dự án

```
└── question-bank/
    ├── README.md
    ├── data/
    │   ├── Cauhoi.txt        # Lưu trữ danh sách các câu hỏi (mỗi câu hỏi trên 1 dòng)
    │   └── Traloi.txt        # Lưu trữ danh sách đáp án đúng tương ứng (mỗi đáp án trên 1 dòng)
    ├── docs/
    │   └── requirements.md   # Yêu cầu đề tài
    └── src/
        └── execute.sh        # File script chính chứa toàn bộ logic chương trình
```

## Yêu cầu hệ thống

- Chương trình chạy bằng Bash shell.
- Nếu chạy trên Windows, cần sử dụng một trong các môi trường sau:
    - Git Bash
    - WSL
    - MSYS2 hoặc Cygwin

## Hướng dẫn sử dụng

1. Mở Terminal / Git Bash trong thư mục dự án này.
2. Chạy lệnh sau để khởi động chương trình:
   ```bash
   bash src/execute.sh
   ```
3. Chọn các chức năng từ menu hiển thị trên màn hình:
   - **Thêm câu hỏi mới**: Nhập câu hỏi và đáp án trực tiếp trên terminal.
   - **Làm bài kiểm tra**: Chọn số lượng câu hỏi, hệ thống sẽ chọn ngẫu nhiên từ ngân hàng và chấm điểm kết quả.
   - **Thoát**: Kết thúc chương trình.
