# Service Account Configuration

## Setup Instructions

### 1. Download Service Account Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Go to **APIs & Services** → **Credentials**
4. Find your service account and click on it
5. Go to **Keys** tab
6. Click **Add Key** → **Create new key** → **JSON**
7. Download the JSON file

### 2. Place in This Directory

Save the downloaded JSON file as:
```
service-account-key.json
```

### 3. Update .env

In the root `.env` file:
```
GOOGLE_APPLICATION_CREDENTIALS=./config/service-account-key.json
GOOGLE_PROJECT_ID=your-project-id
```

### 4. Verify Setup

The app will show on startup:
```
✓ Google Vision client initialized
✓ AI Provider: Google Vision API
```

---

## Security Notes

⚠️ **IMPORTANT:**
- `service-account-key.json` is in `.gitignore` - NEVER commit it
- Never share this file or its contents
- Consider rotating keys periodically
- Use service account only for backend (not mobile app)

---

## Testing

```bash
curl -X POST http://localhost:3000/api/images/upload \
  -F "image=@test.jpg" \
  -F "userId=user123"
```
