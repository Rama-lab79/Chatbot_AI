# Mental Health Assistant - Flutter Frontend

A simple mobile app for the Personal Mental Health AI Assistant.

## Setup

1. Make sure Flutter is installed: https://flutter.dev/docs/get-started/install

2. Install dependencies:
```bash
flutter pub get
```

3. Update API URL in `lib/config/api_config.dart`:
```dart
// For Android emulator:
static const String baseUrl = 'http://10.0.2.2:3000';

// For iOS simulator:
static const String baseUrl = 'http://localhost:3000';

// For real device (replace with your computer's IP):
static const String baseUrl = 'http://192.168.1.100:3000';
```

4. Run the app:
```bash
flutter run
```

## Screens

1. **Auth Screen** - Login and Register with email/password
2. **Home Screen** - Daily check-in status and chat access
3. **Check-in Screen** - Record mood (1-5), energy (low/mid/high), sleep (yes/no)
4. **Chat Screen** - Talk to AI companion with listening or solution mode

## Features

- JWT authentication stored in SharedPreferences
- Daily mood, energy, and sleep tracking
- AI chat with two modes:
  - **Listening**: Empathetic responses, no advice
  - **Solution**: One actionable step suggestion
- Delete today's chat option
- Ethical disclaimers throughout the app

## Project Structure

```
lib/
├── main.dart
├── config/
│   └── api_config.dart
├── models/
│   ├── user.dart
│   ├── daily_checkin.dart
│   └── chat_message.dart
├── services/
│   ├── auth_service.dart
│   ├── checkin_service.dart
│   └── chat_service.dart
└── screens/
    ├── auth_screen.dart
    ├── home_screen.dart
    ├── checkin_screen.dart
    └── chat_screen.dart
```

## Notes

- The app uses Material 3 design
- Custom fonts (Inter) are referenced but you may need to add them or remove the font configuration
- For production, implement proper error handling and loading states

## Removing Custom Fonts (Optional)

If you don't want to add custom fonts, remove the fonts section from `pubspec.yaml`:

```yaml
# Remove this section from pubspec.yaml:
fonts:
  - family: Inter
    fonts:
      - asset: assets/fonts/Inter-Regular.ttf
      ...
```

And remove `fontFamily: 'Inter'` from the theme in `main.dart`.
