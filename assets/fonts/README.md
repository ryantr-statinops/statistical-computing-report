# Font dùng chung

Các font code và Beamer được nạp trực tiếp từ thư mục này. Phần thân báo cáo dùng Times New Roman cài trên hệ điều hành, không lưu font này trong repo.

- Arial: Regular, Bold, Italic, BoldItalic (dùng cho Beamer).
- Noto Sans: Regular, Bold, Italic, BoldItalic.
- Noto Sans Mono: Regular, Bold (dùng cho code trong báo cáo).
  [Nguồn Noto cố định](https://github.com/notofonts/noto-fonts/tree/ffebf8c1ee449e544955a7e813c54f9b73848eac).
  Giấy phép: `LICENSE-Noto.txt`.

`manifest.json` ghi URL nguồn và SHA-256 từng file. Font gốc không bị sửa.
Cài Times New Roman từ nguồn được cấp phép trên Windows/macOS trước khi build báo cáo.
Khi nâng phiên bản, cập nhật font, giấy phép, manifest và kiểm tra lại PDF.
