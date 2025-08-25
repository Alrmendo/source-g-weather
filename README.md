# 🌤️ G-Weather Forecast

A beautiful, responsive Flutter web application for weather forecasting with email subscription features. Built with Flutter 3, designed to work seamlessly on web, mobile, and desktop platforms.

![Weather Dashboard](https://via.placeholder.com/800x400/5F7CF6/FFFFFF?text=G-Weather+Dashboard)

## ✨ Features

### 🌍 Weather Features
- **City Search**: Search weather by city name with smart auto-complete
- **Current Location**: Get weather for your current location (geolocation)
- **Current Weather**: Real-time weather with temperature, wind, humidity
- **4-Day Forecast**: Extended forecast with load more functionality (up to 10 days)
- **Search History**: Recent searches saved locally for quick access

### 📧 Email Subscription (Double Opt-in)
- **Subscribe/Unsubscribe**: Email-based daily forecast notifications
- **Double Opt-in**: Secure email confirmation required
- **Firebase Integration**: Ready for Firebase Auth + Cloud Functions
- **SendGrid Support**: Configurable email service integration

### 🎨 UI/UX Features
- **Responsive Design**: Optimized for desktop (≥1024px), tablet (768-1024px), and mobile (<768px)
- **Beautiful Theme**: Custom color scheme matching the design mockup
- **Loading States**: Skeleton loaders and smooth animations
- **Error Handling**: Graceful error messages and retry mechanisms
- **Dark/Light Theme**: System theme support

### 🔧 Technical Features
- **Flutter 3 & Dart 3**: Latest stable versions
- **Riverpod**: Modern state management
- **WeatherAPI.com**: Reliable weather data source
- **Local Storage**: Persistent search history
- **PWA Ready**: Progressive Web App capabilities

## 🚀 Quick Start

### Prerequisites
- Flutter 3.10.0 or later
- Dart 3.0.0 or later
- WeatherAPI.com free account

### 1. Clone & Install

```bash
git clone <your-repo-url>
cd G-Weather
flutter pub get
```

### 2. Configure Environment

Create a `.env` file in the root directory:

```bash
cp env.example .env
```

Edit `.env` with your API keys:

```env
# Required: Get free key from https://weatherapi.com/
WEATHER_API_KEY=your_weather_api_key_here

# Optional: Firebase configuration for email features
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=your-app-id

# Optional: SendGrid for email sending
SENDGRID_API_KEY=your_sendgrid_api_key
SENDGRID_FROM_EMAIL=noreply@your-domain.com
```

### 3. Generate Code

```bash
dart run build_runner build
```

### 4. Run the App

```bash
# Web (recommended)
flutter run -d chrome

# Mobile (if using mobile device/simulator)
flutter run

# Desktop
flutter run -d windows  # or macos/linux
```

## 🔧 Configuration Guide

### WeatherAPI.com Setup (Required)

1. Visit [WeatherAPI.com](https://weatherapi.com/)
2. Sign up for a free account
3. Get your API key from the dashboard
4. Add it to your `.env` file as `WEATHER_API_KEY`

**Free tier includes:**
- 1 million calls/month
- Real-time weather
- 10-day forecast
- Search functionality

### Firebase Setup (Optional - for Email Features)

#### 1. Create Firebase Project
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize project
firebase init
```

#### 2. Configure Firebase
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable **Authentication** with Email/Link sign-in
4. Enable **Firestore Database**
5. Get configuration from Project Settings
6. Add values to `.env` file

#### 3. Firebase Auth Email Links
Configure email link authentication:
1. Go to Authentication > Sign-in method
2. Enable "Email link (passwordless sign-in)"
3. Add your domain to authorized domains

#### 4. Cloud Functions (for sending emails)
```bash
# In functions/ directory
npm install sendgrid

# Deploy functions
firebase deploy --only functions
```

### SendGrid Setup (Optional - for Email Sending)

1. Create [SendGrid account](https://sendgrid.com/)
2. Get API key from Settings > API Keys
3. Verify sender identity
4. Add `SENDGRID_API_KEY` and `SENDGRID_FROM_EMAIL` to `.env`

## 📱 Responsive Breakpoints

### Desktop (≥1024px)
- Sidebar layout: Search form on left, weather display on right
- 4-column forecast grid
- Full subscription form visible

### Tablet (768px - 1024px)
- Split top section: Search + current weather side by side
- 2-column forecast grid
- Compact subscription form

### Mobile (<768px)
- Stacked vertical layout
- Single-column forecast grid
- Mobile-optimized subscription form

## 🛠️ Development

### Project Structure
```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Main app widget
├── core/                        # Core utilities
│   ├── constants/              # API & storage constants
│   ├── env/                    # Environment configuration
│   └── theme/                  # App theming
├── data/
│   ├── models/                 # Data models (JSON serializable)
│   └── services/               # API & storage services
└── features/
    ├── weather/                # Weather feature
    │   ├── pages/             # Weather pages
    │   ├── providers/         # Riverpod providers
    │   └── widgets/           # Weather widgets
    └── subscription/           # Email subscription feature
        ├── pages/             # Subscription pages
        └── widgets/           # Subscription widgets
```

### Key Dependencies
- `flutter_riverpod`: State management
- `http`: API calls
- `shared_preferences`: Local storage
- `json_serializable`: JSON parsing
- `geolocator`: Location services
- `flutter_dotenv`: Environment variables
- `intl`: Date formatting

### Adding New Features

1. **New weather data**: Extend models in `data/models/`
2. **New UI components**: Add to appropriate `widgets/` folder
3. **New state**: Add providers in `features/weather/providers/`
4. **New services**: Add to `data/services/`

### Code Generation
```bash
# Regenerate JSON serialization code
dart run build_runner build

# Clean and rebuild
dart run build_runner build --delete-conflicting-outputs
```

## 🌐 Deployment

### Web Deployment
```bash
# Build for web
flutter build web --release

# Deploy to Firebase Hosting (if configured)
firebase deploy --only hosting

# Deploy to GitHub Pages, Netlify, or Vercel
# Upload contents of build/web/ directory
```

### Mobile Deployment
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

### Desktop Deployment
```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

## 🧪 Testing

### Run Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/weather_service_test.dart

# With coverage
flutter test --coverage
```

### Demo Mode
Without API keys, the app runs in demo mode with:
- Mock weather data
- Simulated API responses
- Local-only email subscription simulation

## 🐛 Troubleshooting

### Common Issues

#### Build Runner Fails
```bash
# Clean and retry
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build
```

#### Location Permission Denied
- Ensure HTTPS for web deployment
- Check browser location permissions
- Verify app permissions on mobile

#### Email Features Not Working
- Check Firebase configuration
- Verify SendGrid API key
- Check Cloud Functions logs
- Ensure email templates are deployed

#### Weather API Errors
- Verify API key is correct
- Check API usage limits
- Ensure network connectivity
- Check city name spelling

### Debug Mode
Set `kDebugMode` to see detailed logs:
```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  print('Debug information...');
}
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 🆘 Support

- **Issues**: Create an issue on GitHub
- **Email**: [Your email for support]
- **Documentation**: Check the `/docs` folder for detailed guides

## 🎯 Roadmap

- [ ] Weather alerts and notifications
- [ ] Multiple location bookmarks
- [ ] Weather maps integration
- [ ] Social sharing features
- [ ] Offline mode support
- [ ] Widget/tile support
- [ ] Voice search integration

---

Built with ❤️ using Flutter & WeatherAPI.com
