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
5. Mở `tex-report/code/main.tex` rồi Build & View. Các file thành phần có
   `% !TeX root` để TeXstudio biên dịch đúng tài liệu gốc. Không đặt root thủ công
   khác với `main.tex`. Biên dịch lại nếu mục lục hoặc tham chiếu cần cập nhật.

`main.tex` đã chỉ định XeLaTeX và UTF-8 bằng magic comments. Font được nạp
trực tiếp từ `assets/fonts/`. Đường dẫn executable và session editor là
cấu hình riêng từng máy. Không tự format toàn bộ file chỉ để đổi thụt lề.

## Chạy R và build báo cáo

Từ gốc repo, tạo kết quả:

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
ba lượt. PDF nằm tại `tex-report/code/main.pdf`, không được Git theo dõi.
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
- `archive/previous-results/` chỉ để đối chiếu. LaTeX không tự dùng các hình
  này thay cho đầu ra mới.

## Phân chia nội dung

Các file nằm trong `tex-report/code/sections/`:

| File | Nội dung |
| --- | --- |
| `00-front-matter.tex` | Bìa, phân công, lời cảm ơn, mở đầu, mục lục |
| `01-introduction.tex` | Giới thiệu |
| `02-theory.tex` | ECDF và Monte Carlo |
| `03-methods.tex` | Normal và Basic CI |
| `04-comparison.tex` | So sánh phương pháp |
| `05-examples.tex` | Ví dụ |
| `06-simulation.tex` | Mô phỏng và kết quả |
| `07-application.tex` | Ứng dụng y sinh |
| `08-extensions.tex` | Percentile, BCa, tính bất biến |
| `09-conclusion.tex` | Kết luận |
| `10-references.tex` | Tài liệu tham khảo |

Thống nhất người phụ trách mỗi phần. `preamble.tex` chứa định dạng chung;
báo rõ khi thay đổi file này trong pull request. Giữ label duy nhất toàn bài.

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
git add tex-report/code/sections/01-introduction.tex
git commit -m "Update report introduction"
git push -u origin report/ten-cong-viec
```

Mở pull request vào `main`, nhờ một thành viên khác review trước khi merge.
Không force push `main`. Đây là quy ước nhóm; chưa bật branch protection
trên GitHub. `.gitattributes` thống nhất LF trong repo, không cần sửa Git
config toàn cục của từng máy. `.gitignore` loại file phụ LaTeX và session cá nhân.

## Tài liệu chính thức

- [TeXstudio magic comments](https://texstudio-org.github.io/advanced.html#advanced-header-usage)
- [MiKTeX Console](https://miktex.org/howto/miktex-console)
- [Git gitattributes](https://git-scm.com/docs/gitattributes)
