# Slide Bootstrap nhóm D

Bộ trình chiếu gồm 20 frame tỷ lệ 4:3 trong beamer.tex. Báo cáo nhóm D là nguồn chính. Chân slide ghi số trang in trong tài liệu.

| Thời gian | Trang | Nội dung |
|---|---:|---|
| 00:00–04:00 | 1–4 | Giới thiệu nhóm, mức danh nghĩa và độ bao phủ |
| 04:00–12:00 | 5–9 | ECDF, lấy mẫu lại, cách dựng Normal và Basic |
| 12:00–17:00 | 10–11 | Tính khoảng cho mẫu đối xứng và mẫu lệch phải |
| 17:00–23:00 | 12–15 | Thiết kế và kết quả mô phỏng |
| 23:00–28:00 | 16–18 | Hazard Ratio, RV và phép đổi thang log |
| 28:00–30:00 | 19–20 | Kết luận và cảm ơn |

Chạy powershell -NoProfile -File scripts/build.ps1 -Target slides từ gốc repo trên Windows hoặc bash scripts/build.sh slides trên macOS để tạo slide/beamer.pdf. Ghi chú thuyết trình nằm trong speaker-notes.tex và speaker-notes.pdf.
