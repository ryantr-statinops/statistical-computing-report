# Làm việc nhóm trên Windows và macOS

## Môi trường chung

- Dùng MiKTeX, compiler XeLaTeX và editor TeXstudio.
- Thống nhất một đợt cập nhật MiKTeX trước khi chốt bản nộp. Cùng dùng MiKTeX
  chưa bảo đảm các máy có cùng phiên bản engine và package.
- Trong MiKTeX Console, cập nhật package và bật cài package thiếu nếu muốn.
  Khởi động lại TeXstudio sau khi cài hoặc cập nhật.
- Font đã nằm trong repo, không cần cài vào hệ điều hành. Giữ nguyên các
  giấy phép trong `assets/fonts/` khi phân phối lại.
- Script hiện dùng base R. Team nên thống nhất phiên bản R; kết quả lưu trữ
  cũ dùng R 4.3.3. Nếu bổ sung package bên ngoài, thống nhất cách khóa dependency.

Kiểm tra trong terminal:

```text
git --version
xelatex --version
Rscript --version
```

Nếu thiếu lệnh, thêm thư mục executable của MiKTeX/R vào PATH theo vị trí
cài trên máy. Không ghi đường dẫn máy cá nhân vào mã nguồn chung.

## TeXstudio

1. Windows: Options → Configure TeXstudio. macOS: Preferences.
2. Trong Build, chọn Default Compiler là XeLaTeX và dùng PDF Viewer nội bộ.
3. Trong Commands, kiểm tra XeLaTeX trỏ tới bản thuộc MiKTeX trên máy.
4. Lưu file UTF-8; dùng 4 dấu cách cho LaTeX, 2 dấu cách cho R. `.editorconfig`
   dành cho editor hỗ trợ nó; nếu TeXstudio không đọc file, thiết lập qua giao diện.
5. Mở `tex-report/code/main.tex` rồi Build & View. Toàn bộ nội dung và cấu hình nằm trong file này. Không đặt root thủ công
   khác với `main.tex`. Biên dịch lại nếu mục lục hoặc tham chiếu cần cập nhật.

`main.tex` đã chỉ định XeLaTeX và UTF-8 bằng magic comments. Font được nạp
trực tiếp từ `assets/fonts/`. Đường dẫn executable và session editor là
cấu hình riêng từng máy. Không tự format toàn bộ file chỉ để đổi thụt lề.

## Chạy R và build báo cáo

Báo cáo dùng bộ kết quả lưu sẵn tại `assets/simulate-results/`, nên có thể
build ngay. Khi cần tạo kết quả mới, từ gốc repo chạy:

```text
Rscript r/Nhom_D_TKTT.R
```

Đây là mô phỏng đầy đủ với K = 10000, B = 1999, có thể mất thời gian.
Rscript xác định gốc dự án từ vị trí script. Nếu dùng R/RStudio, đặt working
directory ở gốc repo rồi gọi `source("r/Nhom_D_TKTT.R")`.

Build từ terminal, hoặc dùng TeXstudio:

```powershell
# Windows
powershell -NoProfile -File scripts/build.ps1
```

```bash
# macOS
bash scripts/build.sh
```

Hai script kiểm tra đầu vào, chuyển tới `tex-report/code/` rồi chạy XeLaTeX
ba lượt. PDF nằm tại `tex-report/code/main.pdf` và được lưu trong Git.
Nếu chính sách PowerShell của máy chặn script, dùng TeXstudio để build.

## Đường dẫn và kết quả

- Dùng `/` trong LaTeX, `file.path()` trong R. Tên file mới dùng chữ Latin
  không dấu, không khoảng trắng; tham chiếu đúng chữ hoa/thường.
- Tài nguyên tĩnh nằm ở `assets/`; kết quả R ở `output/figures/`,
  `output/tables/`, `output/logs/`. Seed và tham số được ghi vào `run-info.txt`,
  thông tin môi trường vào `session-info.txt`.
- Không đổi seed, K, B hoặc quantile chỉ để thử build. Khi sửa mô phỏng,
  cập nhật bảng số và nhận xét trong báo cáo theo kết quả mới.
- Kết quả `output/` được phép commit. Một người phụ trách chạy mô phỏng đầy
  đủ và commit hình, bảng, log cùng nhau. Thành viên khác dùng kết quả đã kiểm
  tra, không cần chạy lại khi chỉ sửa chữ.
- `assets/simulate-results/` là bộ hình, bảng và log đang dùng cho báo cáo,
  được copy từ `archive/previous-results/`. R vẫn xuất vào `output/`. Sau khi
  kiểm tra kết quả mới, copy các file tương ứng vào bộ kết quả báo cáo và cập
  nhật số liệu/nhận xét cùng nhau. Giữ `archive/previous-results/` để đối chiếu.

## Chỉnh sửa nội dung

Toàn bộ báo cáo, package, font và định dạng nằm trong
`tex-report/code/main.tex`. Giữ cấu trúc một file này, không tách thành
`sections/` hoặc `preamble.tex` nếu chưa được yêu cầu.

Thống nhất người phụ trách từng phần nội dung trước khi sửa cùng file để
hạn chế xung đột. Giữ label duy nhất toàn bài và báo rõ khi thay đổi định dạng chung.

## Git

Lưu hoặc commit công việc đang làm trước khi chuyển nhánh. Bắt đầu việc mới:

```text
git switch main
git pull --ff-only
git switch -c report/ten-cong-viec
```

Sửa phần được giao, build khi có đủ hình, xem PDF và diff trước khi commit.
Chỉ stage file thuộc công việc của mình, ví dụ:

```text
git diff
git add tex-report/code/main.tex
git commit -m "Update report introduction"
git push -u origin report/ten-cong-viec
```

Mở pull request vào `main`, nhờ một thành viên khác review trước khi merge.
Không force push `main`. Đây là quy ước nhóm; chưa bật branch protection
trên GitHub. `.gitattributes` thống nhất LF trong repo, không cần sửa Git
config toàn cục của từng máy. `.gitignore` loại file phụ LaTeX và session cá nhân; giữ các file PDF trong Git.

## Tài liệu chính thức

- [TeXstudio magic comments](https://texstudio-org.github.io/advanced.html#advanced-header-usage)
- [MiKTeX Console](https://miktex.org/howto/miktex-console)
- [Git gitattributes](https://git-scm.com/docs/gitattributes)
