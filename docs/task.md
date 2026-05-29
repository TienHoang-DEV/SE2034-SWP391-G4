# Task mapping by branch

Tài liệu này ghi nhanh nhiệm vụ chính tương ứng với từng nhánh đã tạo từ `main`.

## Danh sách nhánh và nhiệm vụ

| Branch | Nhiệm vụ chính | Ghi chú |
| --- | --- | --- |
| `chore/gitignore-and-env-example` | Thêm/chuẩn hoá `.gitignore`, tạo `.env.example`, loại trừ file cấu hình và secret khỏi Git. | Chuẩn bị nền tảng cho cấu hình môi trường. |
| `feature/env-dotenv` | Tích hợp đọc biến môi trường từ `.env`/dotenv vào ứng dụng. | Dùng chung cho local/dev/prod. |
| `feature/azure-storage-integration` | Tích hợp Azure Storage cho lưu trữ file, ảnh, avatar hoặc tài nguyên học tập. | Phục vụ upload và quản lý media. |
| `feature/roles-db-migration` | Thiết kế/cập nhật migration cho bảng role, mapping role-user và dữ liệu liên quan. | Hỗ trợ phân quyền hệ thống. |
| `feature/auth-register-frontend` | Cập nhật giao diện đăng ký: nhập thông tin cá nhân cần thiết, đồng bộ trường form với backend. | Frontend cho UC-01 Register account. |
| `feature/auth-backend-register` | Xây dựng luồng đăng ký phía backend: validate, tạo user, gán role, lưu dữ liệu, trả phản hồi phù hợp. | Backend cho UC-01 Register account. |
| `feature/instructor-ui` | Xây dựng giao diện cho instructor: dashboard, quản lý course/material/quiz/coupon. | Liên quan nhóm UC-24 → UC-36. |
| `feature/course-management` | Phát triển chức năng quản lý khóa học: danh sách, chi tiết, tạo/sửa/duyệt/xuất bản theo quyền. | Liên quan UC-18, UC-24, UC-37, UC-38. |
| `feature/avatar-upload` | Thêm chức năng tải lên/cập nhật avatar người dùng. | Liên quan hồ sơ cá nhân và media storage. |
| `feature/security-secret-management` | Chuẩn hoá quản lý secret và cấu hình nhạy cảm: env vars, key, token, connection string. | Tăng an toàn vận hành. |
| `feature/docker-and-ci` | Thêm Docker/Docker Compose và pipeline CI để build, test, package tự động. | Phục vụ triển khai và kiểm tra liên tục. |
| `test/unit-and-integration` | Viết test unit và integration cho các luồng chính như auth, role, course, upload. | Bảo đảm chất lượng trước khi merge. |
| `docs/update-requirements` | Cập nhật tài liệu yêu cầu/RDS, mapping use case, mô tả màn hình và checklist thực hiện. | Đồng bộ hoá tài liệu dự án. |
| `feature/learner-ui` | Giao diện học viên: danh sách khóa học, giỏ hàng, đơn hàng, học bài, feedback. | Branch đã tồn tại; không tạo thêm. |

## Ghi chú

- Các nhánh trên được tách từ `main` theo luồng làm việc hiện tại.
- Nếu cần, có thể chuyển sang base `develop` trong một đợt riêng.
- Danh sách nhiệm vụ ở trên là mapping ngắn gọn để theo dõi tiến độ, có thể mở rộng thành checklist chi tiết cho từng branch sau.

