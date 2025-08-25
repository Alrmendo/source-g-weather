# 🌤️ G-Weather Forecast

Ứng dụng dự báo thời tiết đẹp mắt, responsive được xây dựng bằng Flutter 3, hoạt động mượt mà trên web, mobile và desktop. Tích hợp tính năng đăng ký nhận thông báo qua email.

## ✨ Tính năng

### 🌍 Tính năng Thời tiết
- **Tìm kiếm theo Thành phố**: Tìm kiếm thời tiết theo tên thành phố với gợi ý thông minh
- **Vị trí Hiện tại**: Xem thời tiết tại vị trí hiện tại (sử dụng geolocation)
- **Thời tiết Hiện tại**: Cập nhật thời tiết thời gian thực với nhiệt độ, gió, độ ẩm
- **Dự báo 4 Ngày**: Dự báo mở rộng với khả năng tải thêm (lên đến 10 ngày)
- **Lịch sử Tìm kiếm**: Lưu các tìm kiếm gần đây để truy cập nhanh

### 📧 Đăng ký Email (Xác nhận 2 bước)
- **Đăng ký/Hủy đăng ký**: Thông báo dự báo hàng ngày qua email
- **Xác nhận 2 bước**: Yêu cầu xác nhận email an toàn
- **Tích hợp Firebase**: Sẵn sàng với Firebase Auth + Cloud Functions
- **Hỗ trợ SendGrid**: Tích hợp dịch vụ email có thể cấu hình

### 🎨 Tính năng UI/UX
- **Thiết kế Responsive**: Tối ưu cho desktop (≥1024px), tablet (768-1024px), và mobile (<768px)
- **Giao diện Đẹp**: Phối màu tùy chỉnh phù hợp với thiết kế
- **Trạng thái Loading**: Skeleton loaders và animation mượt mà
- **Xử lý Lỗi**: Thông báo lỗi thân thiện và cơ chế thử lại
- **Chế độ Sáng/Tối**: Hỗ trợ theme theo hệ thống

### 🔧 Tính năng Kỹ thuật
- **Flutter 3 & Dart 3**: Phiên bản ổn định mới nhất
- **Riverpod**: Quản lý state hiện đại
- **WeatherAPI.com**: Nguồn dữ liệu thời tiết đáng tin cậy
- **Local Storage**: Lưu trữ lịch sử tìm kiếm
- **PWA Ready**: Khả năng Progressive Web App

## 🚀 Bắt đầu nhanh

### Yêu cầu
- Flutter 3.10.0 trở lên
- Dart 3.0.0 trở lên
- Tài khoản WeatherAPI.com miễn phí

### 1. Clone & Cài đặt

```bash
git clone <your-repo-url>
cd G-Weather
flutter pub get
```

### 2. Cấu hình Môi trường

Tạo file `.env` trong thư mục gốc:

```bash
cp env.example .env
```

Chỉnh sửa `.env` với API keys của bạn:

```env
# Bắt buộc: Lấy key miễn phí từ https://weatherapi.com/
WEATHER_API_KEY=your_weather_api_key_here

# Tùy chọn: Cấu hình Firebase cho tính năng email
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=your-app-id

# Tùy chọn: SendGrid cho gửi email
SENDGRID_API_KEY=your_sendgrid_api_key
SENDGRID_FROM_EMAIL=noreply@your-domain.com
```

### 3. Chạy ứng dụng

```bash
# Web (khuyến nghị)
flutter run -d chrome

# Mobile (nếu sử dụng thiết bị/giả lập)
flutter run

# Desktop
flutter run -d windows  # hoặc macos/linux
```

## 🔧 Hướng dẫn Cấu hình

### Cài đặt WeatherAPI.com (Bắt buộc)

1. Truy cập [WeatherAPI.com](https://weatherapi.com/)
2. Đăng ký tài khoản miễn phí
3. Lấy API key từ dashboard
4. Thêm vào file `.env` với tên `WEATHER_API_KEY`

**Gói miễn phí bao gồm:**
- 1 triệu lượt gọi/tháng
- Thời tiết thời gian thực
- Dự báo 10 ngày
- Chức năng tìm kiếm

## 📱 Responsive Breakpoints

### Desktop (≥1024px)
- Layout sidebar: Form tìm kiếm bên trái, hiển thị thời tiết bên phải
- Lưới dự báo 4 cột
- Form đăng ký đầy đủ

### Tablet (768px - 1024px)
- Phần trên chia đôi: Tìm kiếm + thời tiết hiện tại cạnh nhau
- Lưới dự báo 2 cột
- Form đăng ký gọn nhẹ

### Mobile (<768px)
- Layout dọc
- Lưới dự báo 1 cột
- Form đăng ký tối ưu cho mobile

## 🛠️ Phát triển

### Cấu trúc Dự án
ib/
├── main.dart                    # Điểm vào ứng dụng
├── app.dart                     # Widget app chính
├── core/                        # Tiện ích core
│   ├── constants/              # Hằng số API & storage
│   ├── env/                    # Cấu hình môi trường
│   └── theme/                  # Theme ứng dụng
├── data/
│   ├── models/                 # Models dữ liệu (JSON serializable)
│   └── services/               # Services API & storage
└── features/
├── weather/                # Tính năng thời tiết
│   ├── pages/             # Các trang thời tiết
│   ├── providers/         # Providers Riverpod
│   └── widgets/           # Widgets thời tiết
└── subscription/           # Tính năng đăng ký email
├── pages/             # Các trang đăng ký
└── widgets/           # Widgets đăng ký


### Dependencies Chính
- `flutter_riverpod`: Quản lý state
- `http`: Gọi API
- `shared_preferences`: Lưu trữ local
- `json_serializable`: Parse JSON
- `geolocator`: Dịch vụ vị trí
- `flutter_dotenv`: Biến môi trường
- `intl`: Định dạng ngày tháng

## 🌐 Triển khai

### Triển khai Web
```bash
# Build cho web
flutter build web --release

# Triển khai lên Firebase Hosting (nếu đã cấu hình)
firebase deploy --only hosting

# Triển khai lên GitHub Pages, Netlify, hoặc Vercel
# Upload nội dung thư mục build/web/
```

### Triển khai Mobile
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

### Triển khai Desktop
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 🧪 Kiểm thử

### Chạy Tests
```bash
# Tất cả tests
flutter test

# File test cụ thể
flutter test test/weather_service_test.dart

# Với coverage
flutter test --coverage
```

### Chế độ Demo
Khi không có API keys, ứng dụng chạy ở chế độ demo với:
- Dữ liệu thời tiết giả lập
- Phản hồi API mô phỏng
- Mô phỏng đăng ký email local

## 🐛 Xử lý Sự cố

### Vấn đề Thường gặp

#### Build Runner Fails
```bash
# Clean và thử lại
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build
```

#### Từ chối Quyền Vị trí
- Đảm bảo HTTPS cho triển khai web
- Kiểm tra quyền vị trí trên trình duyệt
- Xác minh quyền ứng dụng trên mobile

#### Tính năng Email Không Hoạt động
- Kiểm tra cấu hình Firebase
- Xác minh SendGrid API key
- Kiểm tra logs Cloud Functions
- Đảm bảo templates email đã được triển khai

#### Lỗi Weather API
- Xác minh API key chính xác
- Kiểm tra giới hạn sử dụng API
- Đảm bảo kết nối mạng
- Kiểm tra chính tả tên thành phố

## 📄 Giấy phép

Dự án này được cấp phép theo Giấy phép MIT - xem file [LICENSE](LICENSE) để biết chi tiết.

## 🤝 Đóng góp

1. Fork repository
2. Tạo nhánh tính năng
3. Thực hiện thay đổi
4. Thêm tests nếu cần
5. Gửi pull request

## 🆘 Hỗ trợ

- **Issues**: Tạo issue trên GitHub
- **Email**: [Email hỗ trợ của bạn]
- **Tài liệu**: Xem thư mục `/docs` để biết hướng dẫn chi tiết

## 🎯 Lộ trình

- [ ] Cảnh báo và thông báo thời tiết
- [ ] Đánh dấu nhiều vị trí
- [ ] Tích hợp bản đồ thời tiết
- [ ] Tính năng chia sẻ xã hội
- [ ] Hỗ trợ chế độ offline
- [ ] Hỗ trợ widget/tile
- [ ] Tích hợp tìm kiếm bằng giọng nói

---

Xây dựng với ❤️ bằng Flutter & WeatherAPI.com
