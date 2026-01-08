# Mental Health Assistant

A simple Personal Mental Health AI Assistant with Node.js backend and Flutter mobile frontend.

## Project Structure

```
├── backend/           # Node.js Express.js REST API
│   ├── src/
│   │   ├── index.js          # Main entry point
│   │   ├── models/           # MongoDB models
│   │   ├── routes/           # API routes
│   │   ├── middleware/       # Auth middleware
│   │   └── services/         # OpenRouter AI service
│   ├── package.json
│   └── .env.example
│
└── frontend/          # Flutter mobile app
    ├── lib/
    │   ├── main.dart
    │   ├── config/           # API configuration
    │   ├── models/           # Data models
    │   ├── services/         # API services
    │   └── screens/          # UI screens
    └── pubspec.yaml
```

## Quick Start

### Backend

1. Navigate to backend folder:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create `.env` file:
```bash
cp .env.example .env
```

4. Edit `.env` with your configuration:
```
PORT=3000
MONGODB_URI=mongodb://localhost:27017/mental_health_app
JWT_SECRET=your_secret_key_here
OPENROUTER_API_KEY=your_openrouter_api_key
```

5. Start MongoDB (must be running)

6. Start the server:
```bash
npm run dev
```

### Frontend

1. Navigate to frontend folder:
```bash
cd frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update `lib/config/api_config.dart` with your backend URL

4. Run the app:
```bash
flutter run
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /auth/register | Register new user |
| POST | /auth/login | Login user |
| POST | /checkin | Submit daily check-in |
| GET | /checkin/last | Get last check-in |
| GET | /checkin/today | Get today's check-in |
| POST | /chat | Send message to AI |
| GET | /chat/today | Get today's chat history |
| DELETE | /chat/today | Delete today's chat |
| POST | /chat/summary | Generate daily summary |

## Features

- **Authentication**: JWT-based register/login
- **Daily Check-in**: Track mood (1-5), energy (low/mid/high), sleep (yes/no)
- **AI Chat**: OpenRouter-powered conversations
  - Listening mode: Empathetic support only
  - Solution mode: One actionable step
- **Daily Summary**: AI-generated summary stored for context

## Tech Stack

- **Backend**: Node.js, Express.js, MongoDB, JWT
- **Frontend**: Flutter, HTTP, SharedPreferences
- **AI**: OpenRouter API (GPT-3.5-turbo)

## Ethical Considerations

- App includes disclaimers that this is NOT professional mental health care
- AI never diagnoses conditions
- Responses are kept short and supportive
- Users can delete their chat history

## License

MIT
