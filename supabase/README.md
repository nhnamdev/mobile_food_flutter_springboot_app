# Supabase Database Setup - Food Delivery App

Hướng dẫn thiết lập database Supabase cho ứng dụng giao đồ ăn (Flutter + Spring Boot).

## 📋 Tổng quan

Database này bao gồm:
- **13 bảng** quản lý người dùng, cửa hàng, món ăn, đơn hàng, đánh giá
- **Dữ liệu mẫu** với món ăn Việt Nam (phở, bánh mì, cơm tấm, cà phê, trà sữa...)
- **6 ENUM types** cho các trạng thái
- **Triggers** tự động cập nhật rating shop
- **Indexes** tối ưu hiệu suất

## 🚀 Cách thực hiện

### Bước 1: Tạo Supabase Project

1. Truy cập [https://supabase.com](https://supabase.com)
2. Đăng nhập hoặc tạo tài khoản mới
3. Click **"New Project"**
4. Điền thông tin:
   - **Name**: `foodapp` (hoặc tên bạn muốn)
   - **Database Password**: Tạo mật khẩu mạnh (lưu lại để dùng sau)
   - **Region**: Chọn `Southeast Asia (Singapore)` để độ trễ thấp
5. Click **"Create new project"** và đợi ~2 phút

### Bước 2: Chạy Schema SQL

1. Trong Supabase Dashboard, vào **SQL Editor** (biểu tượng database bên trái)
2. Click **"New query"**
3. Mở file [`01_schema.sql`](file:///c:/Users/Admin/Desktop/mobilevibe/supabase/01_schema.sql)
4. Copy toàn bộ nội dung và paste vào SQL Editor
5. Click **"Run"** hoặc nhấn `Ctrl+Enter`
6. Kiểm tra kết quả: Phải thấy thông báo **"Success. No rows returned"**

### Bước 3: Chạy Sample Data SQL

1. Tạo **New query** mới trong SQL Editor
2. Mở file [`02_sample_data.sql`](file:///c:/Users/Admin/Desktop/mobilevibe/supabase/02_sample_data.sql)
3. Copy toàn bộ nội dung và paste vào SQL Editor
4. Click **"Run"** hoặc nhấn `Ctrl+Enter`
5. Kiểm tra kết quả: Phải thấy thông báo insert thành công

### Bước 4: Xác minh dữ liệu

Chạy các query sau để kiểm tra:

```sql
-- Kiểm tra số lượng bản ghi
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Shops', COUNT(*) FROM shops
UNION ALL
SELECT 'Food Items', COUNT(*) FROM food_items
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Reviews', COUNT(*) FROM reviews;

-- Xem danh sách shops với rating
SELECT shop_name, rating_average, total_reviews, status 
FROM shops 
ORDER BY rating_average DESC;

-- Xem đơn hàng theo trạng thái
SELECT order_status, COUNT(*) as count 
FROM orders 
GROUP BY order_status;
```

Kết quả mong đợi:
- **Users**: 12 người dùng
- **Shops**: 5 cửa hàng
- **Food Items**: 30 món ăn
- **Orders**: 7 đơn hàng
- **Reviews**: 3 đánh giá

## 📊 Cấu trúc Database

### Bảng chính

| Bảng | Mô tả | Số bản ghi mẫu |
|------|-------|----------------|
| `users` | Người dùng (customer, shop_owner, admin) | 12 |
| `user_addresses` | Địa chỉ giao hàng | 6 |
| `categories` | Danh mục món ăn | 8 |
| `shops` | Cửa hàng | 5 |
| `shop_categories` | Liên kết shop-category | 10 |
| `food_items` | Món ăn | 30 |
| `orders` | Đơn hàng | 7 |
| `order_items` | Chi tiết đơn hàng | 17 |
| `cart` | Giỏ hàng | 6 |
| `reviews` | Đánh giá | 3 |
| `activity_logs` | Nhật ký hoạt động | 11 |

### ENUM Types

```sql
user_role_enum: 'customer', 'shop_owner', 'admin'
user_status_enum: 'inactive', 'active', 'suspended', 'banned'
shop_status_enum: 'pending', 'approved', 'active', 'suspended', 'closed'
payment_method_enum: 'COD', 'Momo', 'Banking'
payment_status_enum: 'unpaid', 'paid'
order_status_enum: 'pending', 'confirmed', 'preparing', 'ready', 'delivering', 'completed', 'cancelled'
```

## 🔐 Kết nối từ Spring Boot

### 1. Lấy thông tin kết nối

Trong Supabase Dashboard:
1. Vào **Settings** → **Database**
2. Tìm phần **Connection string**
3. Chọn tab **Java** hoặc **URI**
4. Copy connection string

### 2. Cấu hình `application.properties`

```properties
# Supabase PostgreSQL Connection
spring.datasource.url=jdbc:postgresql://db.[your-project-ref].supabase.co:5432/postgres
spring.datasource.username=postgres
spring.datasource.password=[your-database-password]
spring.datasource.driver-class-name=org.postgresql.Driver

# JPA Configuration
spring.jpa.hibernate.ddl-auto=none
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.properties.hibernate.format_sql=true
```

### 3. Thêm dependency vào `pom.xml`

```xml
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

## 📱 Kết nối từ Flutter

### 1. Cài đặt Supabase Flutter package

```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.0.0
```

### 2. Lấy API credentials

Trong Supabase Dashboard:
1. Vào **Settings** → **API**
2. Copy **Project URL** và **anon public** key

### 3. Khởi tạo Supabase

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://[your-project-ref].supabase.co',
    anonKey: '[your-anon-key]',
  );
  
  runApp(MyApp());
}

// Sử dụng
final supabase = Supabase.instance.client;
```

## 👥 Tài khoản mẫu

### Admin
- Email: `admin@foodapp.vn`
- Password: `password123` (đã hash)
- Role: `admin`

### Shop Owners
- Email: `owner.pho@foodapp.vn` - Phở Hà Nội 24h
- Email: `owner.banhmi@foodapp.vn` - Bánh Mì Huỳnh Hoa
- Email: `owner.coffee@foodapp.vn` - Highlands Coffee
- Email: `owner.comtam@foodapp.vn` - Cơm Tấm Mộc
- Password: `password123` (đã hash)

### Customers
- Email: `khach1@gmail.com`, `khach2@gmail.com`, `khach3@gmail.com`
- Password: `password123` (đã hash)

> **Lưu ý**: Password đã được hash bằng BCrypt. Trong production, bạn nên dùng Supabase Auth thay vì tự quản lý password.

## 🔒 Row Level Security (RLS)

Supabase khuyến nghị bật RLS để bảo mật. Sau khi setup xong, bạn có thể thêm policies:

```sql
-- Ví dụ: Chỉ cho phép user xem đơn hàng của mình
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own orders"
ON orders FOR SELECT
USING (auth.uid()::text = customer_id::text);
```

## 📝 Ghi chú quan trọng

1. **Password hashing**: Dữ liệu mẫu dùng BCrypt hash cho password `password123`
2. **Timestamps**: Sử dụng `TIMESTAMPTZ` (timezone-aware) thay vì `TIMESTAMP`
3. **Auto-increment**: Dùng `BIGSERIAL` thay vì `INT AUTO_INCREMENT`
4. **Foreign Keys**: Tất cả đều có `ON DELETE CASCADE` hoặc `SET NULL`
5. **Indexes**: Đã tạo indexes cho các cột thường query (user_id, shop_id, status...)

## 🐛 Troubleshooting

### Lỗi "relation already exists"
- Xóa toàn bộ tables và chạy lại `01_schema.sql`
- Hoặc thêm `DROP TABLE IF EXISTS` trước mỗi `CREATE TABLE`

### Lỗi "type already exists"
- Script đã có `DROP TYPE IF EXISTS` ở đầu file
- Nếu vẫn lỗi, chạy thủ công: `DROP TYPE [type_name] CASCADE;`

### Không kết nối được từ Spring Boot
- Kiểm tra firewall/network
- Verify connection string và password
- Đảm bảo đã thêm PostgreSQL driver vào dependencies

## 📚 Tài liệu tham khảo

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Spring Boot + PostgreSQL](https://spring.io/guides/gs/accessing-data-postgresql/)

---

**Tạo bởi**: Antigravity AI Assistant  
**Ngày**: 2025-12-04  
**Version**: 1.0
