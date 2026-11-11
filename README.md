# Báo cáo Thống kê tính toán

Dự án dùng MiKTeX + XeLaTeX + TeXstudio trên Windows và macOS.

## Bắt đầu

1. Clone repo, cài MiKTeX, TeXstudio và R. Thống nhất phiên bản trong team;
   kết quả lưu trữ trước đây dùng R 4.3.3.
2. Bộ kết quả cho báo cáo đã có trong `assets/simulate-results/`. Khi cần chạy lại
   mô phỏng, từ gốc repo chạy `Rscript r/Nhom_D_TKTT.R` để xuất vào `output/`.
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
PDF: `tex-report/code/main.pdf` (được lưu trong Git).

## Cấu trúc

```text
assets/
  tdtu-logo.jpg            Logo dùng chung
  fonts/                   Font cố định, giấy phép và SHA-256
  simulate-results/        Bộ kết quả lưu sẵn đang dùng cho báo cáo
r/Nhom_D_TKTT.R            Mô phỏng và xuất kết quả
output/
  figures/                 Hình PDF, PNG do R tạo
  tables/                  Bảng CSV do R tạo
  logs/                    Tham số, seed và sessionInfo()
tex-report/code/
  main.tex                 Toàn bộ nội dung, package, font và định dạng báo cáo
slide/                     Mã nguồn slide sau này
scripts/                   Lệnh build Windows và macOS
archive/previous-results/  Kết quả cũ chỉ để đối chiếu
CONTRIBUTING.md            Hướng dẫn thiết lập và làm việc nhóm
```

## Trạng thái kết quả

`assets/simulate-results/` chứa bản sao 14 file kết quả từ
`archive/previous-results/`: hình PDF/PNG, bảng CSV và `run-info.txt`.
LaTeX và script build dùng bộ kết quả lưu sẵn này. Đây là kết quả cũ,
chưa phải lần chạy lại bằng script hiện tại. R vẫn xuất kết quả mới vào
`output/`; sau khi kiểm tra và đối chiếu số liệu, cập nhật bộ kết quả trong
`assets/simulate-results/` cùng nội dung báo cáo nếu cần.

Xem [CONTRIBUTING.md](CONTRIBUTING.md) để thiết lập TeXstudio và làm việc nhóm.
