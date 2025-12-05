# MobileVibe - Food Delivery App

Ứng dụng giao đồ ăn với Flutter mobile app và Spring Boot backend, sử dụng Supabase PostgreSQL.


## 🚀 Quick Start
```bash
flutter run -d edge --web-port=3000
```
### 1. Setup Database (Supabase)

Xem hướng dẫn chi tiết trong [`supabase/README.md`](supabase/README.md)

```bash
# Chạy 2 file SQL trong Supabase SQL Editor:
1. supabase/01_schema.sql
2. supabase/02_sample_data.sql
```

### 2. Setup Backend (Spring Boot)

Xem chi tiết trong [`backend/README.md`](backend/README.md)

```bash
cd backend

# Cập nhật password trong application.properties
# Chạy ứng dụng
mvn spring-boot:run
```

API sẽ chạy tại: `http://localhost:8080/api`

### 3. Setup Frontend (Flutter)

Xem chi tiết trong [`frontend/README.md`](frontend/README.md)

```bash
cd frontend

# Cập nhật Supabase anon key trong supabase_config.dart
# Cài đặt dependencies
flutter pub get

# Chạy app
flutter run
```

## 🗄️ Database Schema

**13 tables:**
- `users` - Người dùng (customer, shop_owner, admin)
- `user_addresses` - Địa chỉ giao hàng
- `categories` - Danh mục món ăn
- `shops` - Cửa hàng
- `shop_categories` - Liên kết shop-category
- `food_items` - Món ăn
- `orders` - Đơn hàng
- `order_items` - Chi tiết đơn hàng
- `cart` - Giỏ hàng
- `reviews` - Đánh giá
- `activity_logs` - Nhật ký hoạt động

**Sample data:**
- 12 users (admin, shop owners, customers)
- 5 shops (Phở, Bánh mì, Cà phê, Cơm tấm, Trà sữa)
- 30 food items
- 7 orders với các trạng thái khác nhau

## 🔧 Tech Stack

### Backend
- Java 17
- Spring Boot 3.2.0
- Spring Data JPA
- Spring Security + JWT
- PostgreSQL (Supabase)
- Maven

### Frontend
- Flutter 3.0+
- Supabase Flutter SDK
- Provider (State management)
- Material Design 3

### Database
- Supabase (PostgreSQL)
- Row Level Security
- Real-time subscriptions

## 📝 Tài khoản mẫu

### Admin
- Email: `admin@foodapp.vn`
- Password: `password123`

### Shop Owner
- Email: `owner.pho@foodapp.vn`
- Password: `password123`

### Customer
- Email: `khach1@gmail.com`
- Password: `password123`

## 🛠️ Development Roadmap

### Phase 1: Foundation ✅
- [x] Database schema
- [x] Sample data
- [x] Backend project structure
- [x] Frontend project structure
- [x] Supabase connection

### Phase 2: Backend API (TODO)
- [ ] User authentication & authorization
- [ ] Shop management APIs
- [ ] Food item APIs
- [ ] Order management APIs
- [ ] Cart APIs
- [ ] Review APIs

### Phase 3: Frontend UI (TODO)
- [ ] Authentication screens
- [ ] Home & shop listing
- [ ] Food item details
- [ ] Shopping cart
- [ ] Order placement & tracking
- [ ] User profile
- [ ] Shop owner dashboard

### Phase 4: Advanced Features (TODO)
- [ ] Real-time order tracking
- [ ] Push notifications
- [ ] Payment integration (Momo, Banking)
- [ ] Image upload
- [ ] Search & filters
- [ ] Admin dashboard

## 📚 Documentation

- [Supabase Setup Guide](supabase/README.md)
- [Backend Documentation](backend/README.md)
- [Frontend Documentation](frontend/README.md)

## 🤝 Contributing

1. Clone repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## 📄 License

MIT License

---

**Created by**: Antigravity AI Assistant  
**Date**: 2025-12-04
