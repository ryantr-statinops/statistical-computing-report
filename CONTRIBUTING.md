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

Hai script kiểm tra đầu vào rồi chạy XeLaTeX ba lượt. Mặc định build báo cáo;
thêm `-Target slides` (PowerShell) hoặc `slides` (Bash) để build slide, `all`
để build cả hai. PDF báo cáo và slide đều được lưu trong Git.
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

## Slide Beamer

Khung Madrid tỷ lệ 4:3 cho bài nói 25–30 phút nằm trong `slide/beamer.tex`, với 26 frame chính và 4 frame phụ lục. Mỗi frame ghi nguồn báo cáo, mục tiêu và tài nguyên dự kiến trong comment. Nội dung hiện là placeholder; khi báo cáo đổi, đối chiếu bảng ánh xạ trong `slide/README.md`. Dùng cùng logo và font tại `assets/` và kết quả tại `assets/simulate-results/`.

Build slide bằng `powershell -NoProfile -File scripts/build.ps1 -Target slides` trên Windows hoặc `bash scripts/build.sh slides` trên macOS. Dùng `all` để build cả báo cáo và slide. PDF slide được lưu trong Git.

## Chỉnh sửa nội dung

Toàn bộ báo cáo, package, font và định dạng nằm trong
`tex-report/code/main.tex`. Giữ cấu trúc một file này, không tách thành
`sections/` hoặc `preamble.tex` nếu chưa được yêu cầu.

Thống nhất người phụ trách từng phần nội dung trước khi sửa cùng file để
hạn chế xung đột. Giữ label duy nhất toàn bài và báo rõ khi thay đổi định dạng chung.

## Git

Mọi thay đổi phải đi qua nhánh riêng và pull request. Chỉ tài khoản chủ repo
`ryantr-statinops` duyệt rồi merge vào `main`; không commit hoặc push trực tiếp
lên `main`, và không tự merge pull request của mình. Quy tắc này hiện được ghi
trong tài liệu và PR template; cần bật branch protection trên GitHub nếu muốn
GitHub chặn trực tiếp thao tác push/merge ngoài quy trình.

Trước khi bắt đầu, cập nhật `main` và tạo nhánh ngắn gọn theo dạng
`report/<viec-can-lam>`, `slides/<viec-can-lam>` hoặc `docs/<viec-can-lam>`:

```text
git switch main
git pull --ff-only
git switch -c slides/update-beamer-layout
```

Chỉ sửa phạm vi đã nhận. Trước khi push, build tài liệu bị ảnh hưởng, xem PDF
và `git diff`. Commit bằng thông điệp ngắn mô tả hành động. Ví dụ:

```text
git diff
git add slide/beamer.tex slide/beamer.pdf slide/README.md
git commit -m "Refine Beamer layout"
git push -u origin slides/update-beamer-layout
```

Mở pull request từ nhánh công việc vào `main`. Mô tả mục đích và phạm vi,
liệt kê kiểm tra đã chạy, nêu ảnh hưởng đến số liệu/kết quả nếu có, và đính
kèm ảnh trang PDF khi đổi bố cục. Gắn file PDF đã build cùng mã nguồn khi
thay đổi ảnh hưởng đến tài liệu. Đánh dấu sẵn sàng review; sau đó chờ
`ryantr-statinops` duyệt và merge. Nếu có yêu cầu chỉnh sửa, cập nhật trên
cùng nhánh/pull request rồi báo reviewer. Không force push `main`.

`.gitattributes` thống nhất LF trong repo, không cần sửa Git config toàn cục.
`.gitignore` loại file phụ LaTeX và session cá nhân; PDF hoàn chỉnh được lưu
trong Git.

## Tài liệu chính thức

- [TeXstudio magic comments](https://texstudio-org.github.io/advanced.html#advanced-header-usage)
- [MiKTeX Console](https://miktex.org/howto/miktex-console)
- [Git gitattributes](https://git-scm.com/docs/gitattributes)
