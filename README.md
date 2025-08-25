# G-Weather Forecast

Ứng dụng dự báo thời tiết đẹp mắt, responsive được xây dựng bằng Flutter 3, hoạt động mượt mà trên web, mobile và desktop. Tích hợp tính năng đăng ký nhận thông báo qua email.

## Tính năng

### Tính năng Thời tiết
- **Tìm kiếm theo Thành phố**: Tìm kiếm thời tiết theo tên thành phố với gợi ý thông minh
- **Vị trí Hiện tại**: Xem thời tiết tại vị trí hiện tại (sử dụng geolocation)
- **Thời tiết Hiện tại**: Cập nhật thời tiết thời gian thực với nhiệt độ, gió, độ ẩm
- **Dự báo 4 Ngày**: Dự báo mở rộng với khả năng tải thêm (lên đến 10 ngày)
- **Lịch sử Tìm kiếm**: Lưu các tìm kiếm gần đây để truy cập nhanh

### Đăng ký Email (Xác nhận 2 bước)
- **Đăng ký/Hủy đăng ký**: Thông báo dự báo hàng ngày qua email
- **Xác nhận 2 bước**: Yêu cầu xác nhận email an toàn

### Tính năng UI/UX
- **Thiết kế Responsive**: Tối ưu cho desktop (≥1024px), tablet (768-1024px), và mobile (<768px)
- **Giao diện Đẹp**: Phối màu tùy chỉnh phù hợp với thiết kế
- **Trạng thái Loading**: Skeleton loaders và animation mượt mà
- **Xử lý Lỗi**: Thông báo lỗi thân thiện và cơ chế thử lại

### Tính năng Kỹ thuật
- **Flutter 3 & Dart 3**: Phiên bản ổn định mới nhất
- **Riverpod**: Quản lý state hiện đại
- **WeatherAPI.com**: Nguồn dữ liệu thời tiết đáng tin cậy
- **Local Storage**: Lưu trữ lịch sử tìm kiếm
- **PWA Ready**: Khả năng Progressive Web App

## Bắt đầu nhanh

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
# Weather API Configuration
# Get your free API key from: https://www.weatherapi.com/
WEATHER_API_KEY=your_weatherapi_key_here
WEATHER_API_BASE_URL=https://api.weatherapi.com/v1

# Email Backend Configuration
# This should point to your deployed backend URL
EMAIL_BACKEND_URL=http://localhost:3000

# App Configuration
APP_NAME=G-Weather
APP_URL=http://localhost:8080
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
