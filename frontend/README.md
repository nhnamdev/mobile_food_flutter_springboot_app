# Food Delivery App - Frontend (Flutter)

Mobile app cho ứng dụng giao đồ ăn sử dụng Flutter và Supabase.

## 🚀 Yêu cầu hệ thống

- Flutter SDK 3.0.0 trở lên
- Dart SDK
- Android Studio / VS Code
- Supabase account

## 📦 Cài đặt

### 1. Cấu hình Supabase

Mở file `lib/config/supabase_config.dart` và cập nhật:

```dart
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

**Lấy Supabase Anon Key:**
1. Vào Supabase Dashboard
2. Chọn project của bạn
3. Vào **Settings** → **API**
4. Copy **anon public** key

### 2. Cài đặt dependencies

```bash
flutter pub get
```

### 3. Chạy ứng dụng

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Web
flutter run -d chrome
```

## 📁 Cấu trúc thư mục

```
frontend/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── config/
│   │   └── supabase_config.dart     # Supabase configuration
│   ├── models/                      # Data models (TODO)
│   ├── services/                    # API services (TODO)
│   ├── screens/                     # UI screens (TODO)
│   ├── widgets/                     # Reusable widgets (TODO)
│   └── providers/                   # State management (TODO)
└── pubspec.yaml                     # Dependencies
```

## 🔧 Cấu hình Supabase

### Connection Details

```
URL: https://nwagwvwydcggsbxqiwbo.supabase.co
Database Host: db.nwagwvwydcggsbxqiwbo.supabase.co
Port: 5432
Database: postgres
```

### Sử dụng Supabase Client

```dart
import 'package:foodapp_mobile/config/supabase_config.dart';

// Truy vấn dữ liệu
final response = await SupabaseConfig.client
    .from('shops')
    .select()
    .execute();

// Insert dữ liệu
await SupabaseConfig.client
    .from('cart')
    .insert({'user_id': 1, 'food_item_id': 5, 'quantity': 2});
```

## 📚 Dependencies chính

- `supabase_flutter: ^2.0.0` - Supabase client
- `provider: ^6.1.1` - State management
- `google_fonts: ^6.1.0` - Custom fonts
- `cached_network_image: ^3.3.0` - Image caching
- `image_picker: ^1.0.5` - Image selection
- `shared_preferences: ^2.2.2` - Local storage
- `intl: ^0.18.1` - Internationalization

## 🎨 Features (TODO)

- [ ] Authentication (Login/Register)
- [ ] Browse shops và food items
- [ ] Shopping cart
- [ ] Order management
- [ ] Reviews & ratings
- [ ] User profile
- [ ] Shop owner dashboard
- [ ] Admin panel

## 🛠️ Bước tiếp theo

1. Tạo models cho User, Shop, FoodItem, Order, etc.
2. Tạo authentication service
3. Implement login/register screens
4. Tạo home screen với danh sách shops
5. Implement shopping cart
6. Tạo order flow
7. Add reviews & ratings

## 📝 Ghi chú

- App hiện tại chỉ có home screen cơ bản
- Cần implement authentication trước khi build các features khác
- Sử dụng Provider cho state management
- UI sẽ được thiết kế theo Material Design 3
