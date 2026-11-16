# Ánh xạ nội dung Beamer

`beamer.tex` dùng Madrid tỷ lệ 4:3, gồm 28 slide. Báo cáo nhóm D (`../tex-report/code/main.tex`) là nguồn chuẩn; hình và số liệu dùng bản kết quả lưu tại `../assets/simulate-results/`.

## Nhịp nói 30 phút

| Đồng hồ | Slide | Điểm cần nói |
|---|---:|---|
| 00:00–03:00 | 01–05 | Giới thiệu đề tài, lộ trình, thành viên và mục tiêu. |
| 03:00–07:00 | 06–09 | Giải thích lấy mẫu có hoàn lại và phân biệt số mẫu Bootstrap với số lần mô phỏng. |
| 07:00–12:00 | 10–12 | Trình bày hai công thức và giải thích phép đảo cận của Basic. |
| 12:00–16:00 | 13–15 | Đếm số mẫu lấy lại, đọc hạng phân vị type 1 và thay số vào công thức. |
| 16:00–22:00 | 16–19 | Đọc biểu đồ coverage, rồi đối chiếu với độ dài trung bình. |
| 22:00–24:00 | 20 | Giải thích 85,47% coverage bằng số khoảng Basic chứa trung bình thật. |
| 24:00–26:00 | 21–22 | Trình bày ví dụ HR giả định và nghiên cứu RV dùng BCa. |
| 26:00–29:00 | 23–26 | Giải thích Percentile, BCa, phép đổi thang log và giới hạn áp dụng. |
| 29:00–30:00 | 27–28 | Chốt khuyến nghị và cảm ơn. |

Nếu chậm giờ, rút gọn hai slide ứng dụng xuống một ý mỗi slide. Giữ đủ thời gian để đọc biểu đồ coverage và chốt giới hạn kết luận.

## Slide chính

| # | Frame | Nguồn | Mục tiêu | Tài nguyên đối chiếu |
|---:|---|---|---|---|
| 01 | Trang bìa | Bìa | metadata học phần/nhóm | ../assets/tdtu-logo.jpg |
| 02 | Lộ trình trình bày | Tổng quan | mạch nói |  |
| 03 | Thành viên nhóm D | Bìa | giới thiệu thành viên |  |
| 04 | Vì sao cần khoảng tin cậy Bootstrap? | Phần 1 | động lực |  |
| 05 | Mục tiêu và phạm vi khảo sát | Phần 1 | mục tiêu/giới hạn |  |
| 06 | Phân phối thực nghiệm ECDF | Phần 2 | khái niệm |  |
| 07 | Nguyên lý Plug-in | Phần 2 | ý tưởng xấp xỉ |  |
| 08 | Quy trình lấy mẫu Bootstrap | Phần 2 | quy trình |  |
| 09 | B khác K: hai nguồn biến thiên Monte Carlo | Phần 2, 6 | phân biệt B/K | run-info.txt |
| 10 | Normal CI: ý tưởng và công thức | Phần 3 | giả định/công thức |  |
| 11 | Basic CI và phép đảo phân vị | Phần 3 | Quantile Flipping |  |
| 12 | Normal CI và Basic CI khác nhau thế nào? | Phần 4 | so sánh |  |
| 13 | Ví dụ mẫu đối xứng | Phần 5 | liệt kê chính xác | example-symmetric-distribution.csv |
| 14 | Ví dụ mẫu lệch phải | Phần 5 | liệt kê chính xác | example-skewed-distribution.csv; example-confidence-intervals.csv |
| 15 | Đối chiếu các khoảng trong hai ví dụ | Phần 5 | ba phương pháp | example-confidence-intervals.csv |
| 16 | Thiết kế mô phỏng Monte Carlo | Phần 6 | thiết lập | run-info.txt |
| 17 | Kết quả coverage | Phần 6 | coverage | simulation-coverage.pdf; simulation-summary.csv |
| 18 | Kết quả độ dài khoảng trung bình | Phần 6 | độ dài | simulation-average-length.pdf; simulation-summary.csv |
| 19 | Những điều rút ra từ mô phỏng | Phần 6 | diễn giải giới hạn | simulation-summary.csv |
| 20 | Coverage 85,47% nghĩa là gì? | Phần 6 | tính và diễn giải coverage thực nghiệm | simulation-summary.csv; run-info.txt |
| 21 | Ví dụ giả định: Hazard Ratio | Phần 7 | minh họa giả định |  |
| 22 | Ứng dụng: relative validity | Phần 7 | bài báo Deng 2013 |  |
| 23 | Percentile CI | Phần 8 | phương pháp mở rộng |  |
| 24 | BCa: vai trò và giới hạn | Phần 8 | phương pháp mở rộng |  |
| 25 | Tính bất biến qua biến đổi log | Phần 8 | so sánh thang đo | invariance-log-comparison.pdf; invariance-log-comparison.csv |
| 26 | Điều kiện áp dụng và giới hạn kết luận | Phần 2, 4, 9 | điều kiện |  |
| 27 | Kết luận và khuyến nghị | Phần 9 | kết luận |  |
| 28 | Cảm ơn | Kết thúc | lời cảm ơn |  |

## Checklist đồng bộ

- Khi báo cáo đổi, kiểm tra lại các frame có comment trỏ tới phần thay đổi.
- Trước khi điền số liệu, đối chiếu bảng trong báo cáo với CSV trong `assets/simulate-results/`.
- Giữ phân biệt ví dụ liệt kê chính xác, mô phỏng Monte Carlo, HR giả định và ứng dụng RV từ bài báo.
- Giới hạn kết luận theo các phân phối/cỡ mẫu mô phỏng; nêu quy ước phân vị khi nói về tính bất biến.
- Hình được nạp từ PDF của bộ kết quả; khi cập nhật snapshot, đối chiếu lại các bảng và số được ghi trong slide.
