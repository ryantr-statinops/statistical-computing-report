# Ánh xạ nội dung Beamer

Khung `beamer.tex` dùng Madrid ở tỷ lệ 4:3, theo mẫu thanh tiêu đề/đầu trang/chân trang của nhóm, dành cho bài nói 25–30 phút. Báo cáo là nguồn chuẩn. Mỗi frame trong mã nguồn có comment ghi nguồn, mục tiêu và tài nguyên dự kiến. Frame kết quả hiện để placeholder, chưa chứa số liệu hoặc đồ thị.

## Slide chính

| # | Frame | Nguồn | Mục tiêu | Tài nguyên dự kiến |
|---:|---|---|---|---|
| 01 | Trang bìa | Bìa | metadata học phần/nhóm | ../assets/tdtu-logo.jpg |
| 02 | Lộ trình trình bày | Tổng quan | mạch nói |  |
| 03 | Vì sao cần khoảng tin cậy Bootstrap? | Phần 1 | động lực |  |
| 04 | Mục tiêu và phạm vi khảo sát | Phần 1 | mục tiêu/giới hạn |  |
| 05 | Phân phối thực nghiệm ECDF | Phần 2 | khái niệm |  |
| 06 | Nguyên lý Plug-in | Phần 2 | ý tưởng xấp xỉ |  |
| 07 | Quy trình lấy mẫu Bootstrap | Phần 2 | quy trình |  |
| 08 | B khác K: hai nguồn biến thiên Monte Carlo | Phần 2, 6 | phân biệt B/K | run-info.txt |
| 09 | Normal CI: ý tưởng và công thức | Phần 3 | giả định/công thức |  |
| 10 | Basic CI và phép đảo phân vị | Phần 3 | Quantile Flipping |  |
| 11 | Normal CI và Basic CI khác nhau thế nào? | Phần 4 | so sánh |  |
| 12 | Ví dụ mẫu đối xứng | Phần 5 | liệt kê chính xác | example-bootstrap-distributions.pdf |
| 13 | Ví dụ mẫu lệch phải | Phần 5 | liệt kê chính xác | example-confidence-intervals.csv |
| 14 | Đối chiếu các khoảng trong hai ví dụ | Phần 5 | ba phương pháp | example-confidence-intervals.csv |
| 15 | Thiết kế mô phỏng Monte Carlo | Phần 6 | thiết lập | run-info.txt |
| 16 | Kết quả coverage | Phần 6 | coverage | simulation-coverage.pdf; simulation-summary.csv |
| 17 | Kết quả độ dài khoảng trung bình | Phần 6 | độ dài | simulation-average-length.pdf; simulation-summary.csv |
| 18 | Những điều rút ra từ mô phỏng | Phần 6 | diễn giải giới hạn | simulation-summary.csv |
| 19 | Ví dụ giả định: Hazard Ratio | Phần 7 | minh họa giả định |  |
| 20 | Ứng dụng: relative validity | Phần 7 | bài báo Deng 2013 |  |
| 21 | Percentile CI | Phần 8 | phương pháp mở rộng |  |
| 22 | BCa: vai trò và giới hạn | Phần 8 | phương pháp mở rộng |  |
| 23 | Tính bất biến qua biến đổi log | Phần 8 | so sánh thang đo | invariance-log-comparison.pdf; invariance-log-comparison.csv |
| 24 | Điều kiện áp dụng và giới hạn kết luận | Phần 2, 4, 9 | điều kiện |  |
| 25 | Kết luận và khuyến nghị | Phần 9 | kết luận |  |
| 26 | Cảm ơn và hỏi đáp | Kết thúc | hỏi đáp |  |

## Phụ lục

| # | Frame | Nguồn | Mục tiêu | Tài nguyên dự kiến |
|---|---|---|---|---|
| A1 | Chi tiết suy luận Basic CI | Phần 3 | các bước suy luận |  |
| A2 | Bảng kết quả mô phỏng đầy đủ | Phần 6 | giá trị cho hỏi đáp | simulation-summary.csv |
| A3 | Thiết lập R và khả năng tái lập | Mã R/log | seed, phiên bản, B/K | run-info.txt; output/logs/session-info.txt |
| A4 | Tài liệu tham khảo | Danh mục trong báo cáo | các nguồn được viện dẫn | main.tex: bibliography |

## Checklist đồng bộ

- Khi báo cáo đổi, kiểm tra lại các frame có comment trỏ tới phần thay đổi.
- Trước khi điền số liệu, đối chiếu bảng trong báo cáo với CSV trong `assets/simulate-results/`.
- Giữ phân biệt ví dụ liệt kê chính xác, mô phỏng Monte Carlo, HR giả định và ứng dụng RV từ bài báo.
- Giới hạn kết luận theo các phân phối/cỡ mẫu mô phỏng; nêu quy ước phân vị khi nói về tính bất biến.
- Các PDF/CSV trong comment là nguồn dự kiến; chưa được nạp tự động vào slide.
