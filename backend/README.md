# Food Delivery App - Backend (Spring Boot)

Backend API cho ứng dụng giao đồ ăn sử dụng Spring Boot và Supabase PostgreSQL.

## 🚀 Yêu cầu hệ thống

- Java 17 hoặc cao hơn
- Maven 3.6+
- Supabase account với database đã setup

## 📦 Cài đặt

### 1. Cấu hình Database

Mở file `src/main/resources/application.properties` và cập nhật password:

```properties
spring.datasource.password=[YOUR_PASSWORD]
```

Thay `[YOUR_PASSWORD]` bằng password database Supabase của bạn.

### 2. Cài đặt dependencies

```bash
mvn clean install
```

### 3. Chạy ứng dụng

```bash
mvn spring-boot:run
```

Server sẽ chạy tại: `http://localhost:8080/api`

## 📁 Cấu trúc thư mục

```
backend/
├── src/
│   └── main/
│       ├── java/com/foodapp/
│       │   ├── FoodAppApplication.java      # Main application
│       │   ├── config/                      # Configuration classes
│       │   │   └── SecurityConfig.java      # Security & CORS config
│       │   ├── entity/                      # JPA entities (TODO)
│       │   ├── repository/                  # Data repositories (TODO)
│       │   ├── service/                     # Business logic (TODO)
│       │   └── controller/                  # REST controllers (TODO)
│       └── resources/
│           └── application.properties       # App configuration
└── pom.xml                                  # Maven dependencies
```

## 🔧 Cấu hình

### Database Connection

```properties
Host: db.nwagwvwydcggsbxqiwbo.supabase.co
Port: 5432
Database: postgres
User: postgres
```

### API Endpoints

Base URL: `http://localhost:8080/api`

- `/api/auth/**` - Authentication endpoints (public)
- `/api/public/**` - Public endpoints
- Các endpoints khác sẽ được thêm sau

## 🔐 Security

- CORS enabled cho tất cả origins (development mode)
- BCrypt password encoding
- JWT authentication (sẽ implement sau)
- Session management: STATELESS

## 📚 Dependencies chính

- Spring Boot 3.2.0
- Spring Data JPA
- PostgreSQL Driver
- Spring Security
- JWT (jjwt 0.12.3)
- Lombok

## 🛠️ Bước tiếp theo

1. Tạo Entity classes cho các bảng database
2. Tạo Repository interfaces
3. Implement Service layer
4. Tạo REST Controllers
5. Implement JWT authentication
6. Add validation và error handling

## 📝 Ghi chú

- Hiện tại security config cho phép tất cả requests (để test)
- Cần implement JWT authentication trước khi deploy production
- CORS cần được cấu hình cụ thể cho production
