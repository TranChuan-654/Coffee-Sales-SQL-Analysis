# ☕ Coffee Sales SQL Analysis

## 📌 1. Tổng quan dự án

Đây là dự án **Phân tích dữ liệu bằng SQL (SQL Data Analysis)** sử dụng dữ liệu bán hàng cà phê để phân tích:

- Doanh số và doanh thu
- Khách hàng
- Sản phẩm
- Hiệu suất bán hàng theo thành phố
- Tăng trưởng doanh số theo thời gian
- Chi phí thuê mặt bằng
- Tiềm năng thị trường

Mục tiêu của dự án là sử dụng SQL để chuyển đổi dữ liệu giao dịch thành các **Business Insights**, từ đó hỗ trợ đánh giá hiệu quả kinh doanh và tiềm năng mở rộng cửa hàng cà phê.

---

# 🎯 2. Mục tiêu dự án

Dự án tập trung giải quyết các câu hỏi kinh doanh sau:

- Thành phố nào có số lượng khách hàng cao?
- Thành phố nào có doanh thu cao nhất?
- Sản phẩm cà phê nào bán chạy nhất?
- 3 sản phẩm bán chạy nhất tại mỗi thành phố là gì?
- Có bao nhiêu khách hàng đã mua cà phê?
- Doanh số trung bình trên mỗi khách hàng là bao nhiêu?
- Doanh số thay đổi như thế nào theo từng tháng?
- Doanh số trung bình có tương quan như thế nào với tiền thuê mặt bằng?
- Thành phố nào có tiềm năng phát triển thị trường cà phê?
- Thành phố nào có thể được xem xét cho việc mở rộng cửa hàng?

---

# 🗂️ 3. Cấu trúc Database

Database gồm 4 bảng chính:

## 🏙️ Bảng `city`

Lưu thông tin về các thành phố.

| Cột | Mô tả |
|---|---|
| `city_id` | Mã thành phố |
| `city_name` | Tên thành phố |
| `population` | Dân số |
| `estimated_rent` | Tiền thuê mặt bằng ước tính |
| `city_rank` | Xếp hạng thành phố |

---

## 👥 Bảng `customers`

Lưu thông tin khách hàng.

| Cột | Mô tả |
|---|---|
| `customer_id` | Mã khách hàng |
| `customer_name` | Tên khách hàng |
| `city_id` | Mã thành phố của khách hàng |

---

## ☕ Bảng `products`

Lưu thông tin các sản phẩm cà phê.

| Cột | Mô tả |
|---|---|
| `product_id` | Mã sản phẩm |
| `product_name` | Tên sản phẩm |
| `price` | Giá sản phẩm |

---

## 💰 Bảng `sales`

Lưu thông tin các giao dịch bán hàng.

| Cột | Mô tả |
|---|---|
| `sale_id` | Mã giao dịch |
| `sale_date` | Ngày bán hàng |
| `product_id` | Mã sản phẩm |
| `customer_id` | Mã khách hàng |
| `total` | Tổng giá trị giao dịch |
| `rating` | Đánh giá của khách hàng |

---

# 🔗 4. Mối quan hệ giữa các bảng

```text
                 ┌──────────────┐
                 │     city     │
                 │──────────────│
                 │ city_id      │
                 │ city_name    │
                 │ population   │
                 │ rent         │
                 └──────┬───────┘
                        │
                        │ city_id
                        │
                 ┌──────▼───────┐
                 │  customers   │
                 │──────────────│
                 │ customer_id  │
                 │ customer_name│
                 │ city_id      │
                 └──────┬───────┘
                        │
                        │ customer_id
                        │
                 ┌──────▼───────┐
                 │    sales     │
                 │──────────────│
                 │ sale_id      │
                 │ sale_date    │
                 │ product_id   │
                 │ customer_id  │
                 │ total        │
                 │ rating       │
                 └──────┬───────┘
                        │
                        │ product_id
                        │
                 ┌──────▼───────┐
                 │   products   │
                 │──────────────│
                 │ product_id   │
                 │ product_name │
                 │ price        │
                 └──────────────┘
