# Báo cáo Thống kê tính toán

Dự án dùng MiKTeX + XeLaTeX + TeXstudio trên Windows và macOS.

## Bắt đầu

1. Clone repo, cài MiKTeX, TeXstudio và R. Thống nhất phiên bản trong team;
   kết quả lưu trữ trước đây dùng R 4.3.3.
2. Từ thư mục gốc, chạy `Rscript r/Nhom_D_TKTT.R` để tạo hình, bảng và log.
   Đây là mô phỏng đầy đủ (K = 10000, B = 1999), có thể mất thời gian.
   Script dùng base R, không cần package bên ngoài.
3. Mở `tex-report/code/main.tex` trong TeXstudio và chọn Build & View.
   File đã chỉ định XeLaTeX và UTF-8, font được đọc từ repo.
   Biên dịch lại nếu mục lục hoặc tham chiếu cần cập nhật.

Hoặc build bằng terminal từ gốc repo:

```powershell
# Windows
powershell -NoProfile -File scripts/build.ps1
```

```bash
# macOS
bash scripts/build.sh
```

Hai script kiểm tra đầu vào và chạy XeLaTeX ba lượt.
PDF: `tex-report/code/main.pdf` (không được Git theo dõi).

## Cấu trúc

```text
assets/
  tdtu-logo.jpg            Logo dùng chung
  fonts/                   Font cố định, giấy phép và SHA-256
r/Nhom_D_TKTT.R            Mô phỏng và xuất kết quả
output/
  figures/                 Hình PDF, PNG do R tạo
  tables/                  Bảng CSV do R tạo
  logs/                    Tham số, seed và sessionInfo()
tex-report/code/
  main.tex                 Điểm vào để biên dịch
  preamble.tex             Package, font, định dạng chung
  sections/                Phần đầu, chín phần nội dung, tài liệu tham khảo
slide/                     Mã nguồn slide sau này
scripts/                   Lệnh build Windows và macOS
archive/previous-results/  Kết quả cũ chỉ để đối chiếu
CONTRIBUTING.md            Hướng dẫn thiết lập và làm việc nhóm
```

## Trạng thái kết quả

`output/` đang chờ lần chạy mới. Số liệu, nhận xét và các đoạn R minh họa
trong báo cáo được giữ nguyên khi tách file; chưa đối chiếu lại với đầu ra
của script hiện tại. Kết quả cũ ở `archive/previous-results/` không được
LaTeX tự dùng thay cho kết quả mới.

Xem [CONTRIBUTING.md](CONTRIBUTING.md) để thiết lập TeXstudio và làm việc nhóm.
