# Báo cáo Thống kê tính toán

## Cấu trúc thư mục

```text
assets/                    Tài nguyên tĩnh dùng chung: logo, hình có sẵn
r/                         Mã nguồn R (chưa triển khai)
output/
  figures/                 Biểu đồ PDF, PNG do R sinh ra
  tables/                  Bảng kết quả CSV do R sinh ra
  logs/                    Seed, tham số, phiên bản R và thông tin lần chạy
tex-report/code/main.tex   Mã nguồn báo cáo LaTeX
slide/                     Mã nguồn slide (chưa triển khai)
archive/previous-results/  Kết quả cũ để tham khảo, không phải đầu ra hiện hành
```

## Quy ước đường dẫn

- Chạy mã R từ thư mục gốc dự án; ghi kết quả vào `output/`.
- Báo cáo và slide dùng chung tài nguyên trong `assets/` và `output/`.
- Không sao chép kết quả sinh ra vào thư mục mã nguồn LaTeX hoặc slide.
- Biên dịch báo cáo từ `tex-report/code/`. `main.tex` đã khai báo
  `\graphicspath{{../../assets/}{../../output/figures/}}`.
- Dùng XeLaTeX hoặc LuaLaTeX vì báo cáo sử dụng `fontspec`.

## Trạng thái sau khi sắp xếp

Logo đã được chuyển vào `assets/`. Các hình, CSV và thông tin lần chạy cũ
được lưu ở `archive/previous-results/`. `output/` đang chờ kết quả mới từ R.

Báo cáo vẫn giữ các đoạn R minh họa, bảng số liệu và nhận xét đã viết trước
đó; chúng chưa được kiểm chứng lại bằng mã R độc lập. Báo cáo có nhắc đến
`bootstrap_simulation.R`, nhưng file này chưa được tạo.

Bốn hình kết quả mà báo cáo đang chờ trong `output/figures/`:

- `example-bootstrap-distributions.pdf`
- `simulation-coverage.pdf`
- `simulation-average-length.pdf`
- `invariance-log-comparison.pdf`

Chưa thể biên dịch đầy đủ báo cáo với các đường dẫn mới cho đến khi những
hình này được tạo. Thư mục lưu trữ không nằm trong đường dẫn tìm hình của
LaTeX, để kết quả cũ không bị dùng nhầm như kết quả mới.
