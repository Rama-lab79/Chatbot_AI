# Mental Health Assistant - Backend

A simple REST API for the Personal Mental Health AI Assistant.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file (copy from `.env.example`):
```bash
cp .env.example .env
```

3. Update `.env` with your values:
- `MONGODB_URI`: Your MongoDB connection string
- `JWT_SECRET`: A secure random string for JWT signing
- `OPENROUTER_API_KEY`: Your OpenRouter API key

4. Start MongoDB (if running locally)

5. Run the server:
```bash
# Development
npm run dev

# Production
npm start
```

## API Endpoints

### Authentication

#### POST /auth/register
Register a new user.

**Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "message": "Registration successful",
  "token": "eyJhbGc...",
  "user": {
    "id": "...",
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

#### POST /auth/login
Login existing user.

**Request:**
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "message": "Login successful",
  "token": "eyJhbGc...",
  "user": { ... }
}
```

### Check-in (Requires Auth)

#### POST /checkin
Create or update daily check-in.

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
```json
{
  "mood": 4,
  "energy": "mid",
  "sleep": true
}
```

**Response:**
```json
{
  "message": "Check-in recorded",
  "checkin": {
    "_id": "...",
    "user_id": "...",
    "mood": 4,
    "energy": "mid",
    "sleep": true,
    "created_at": "2026-01-08T..."
  }
}
```

#### GET /checkin/last
Get the last check-in.

#### GET /checkin/today
Get today's check-in.

### Chat (Requires Auth)

#### POST /chat
Send a message and get AI response.

**Request:**
```json
{
  "message": "I'm feeling anxious today",
  "mode": "listening"
}
```

**Response:**
```json
{
  "userMessage": {
    "_id": "...",
    "role": "user",
    "message": "I'm feeling anxious today",
    "created_at": "..."
  },
  "aiResponse": {
    "_id": "...",
    "role": "ai",
    "message": "I hear you. Anxiety can be really overwhelming...",
    "created_at": "..."
  }
}
```

#### GET /chat/today
Get today's chat history.

#### DELETE /chat/today
Delete today's chat history.

#### POST /chat/summary
Generate and save daily summary.

## Chat Modes

- **listening**: AI only listens and validates feelings, no advice
- **solution**: AI suggests one small actionable step

## License

MIT
