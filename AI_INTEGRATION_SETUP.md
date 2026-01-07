# AI Image Recognition Integration Setup

## Files Created

### Backend Files (Already in `backend/`)
- ✅ `app.js` - Express server entry point
- ✅ `services/ai_image_service.dart` - Orchestration logic
- ✅ `services/aiProviders/googleVisionProvider.js` - Google Vision API
- ✅ `controllers/imageController.js` - HTTP handlers
- ✅ `routes/imageRoutes.js` - API endpoints
- ✅ `models/imageModel.js` - Data model

### Frontend Files (New in `lib/`)
- ✅ `lib/services/ai_image_service.dart` - Service to call backend
- ✅ `lib/pages/ai_recognition/ai_recognition_page.dart` - Main UI for image upload & results
- ✅ `lib/pages/ai_recognition/ai_recognition_history_page.dart` - History of recognized images
- ✅ `lib/main_ai_demo.dart` - Demo app showing all features

---

## Setup Instructions

### Step 1: Update Backend URL in Flutter

Edit `lib/main_ai_demo.dart`:

```dart
// Change this based on your setup:
const String BACKEND_URL = 'http://10.0.2.2:3000'; // Android emulator

// OR for physical device:
const String BACKEND_URL = 'http://192.168.x.x:3000';

// OR for iOS simulator:
const String BACKEND_URL = 'http://localhost:3000';
```

### Step 2: Ensure Backend is Running

```bash
cd backend
node app.js
```

You should see:
```
✓ Google Vision client initialized
✓ AI Provider: Google Vision API
🚀 Server running on http://localhost:3000
```

### Step 3: Run Flutter App

```bash
flutter pub get
flutter run -d chrome  # or your device
```

Then open `main_ai_demo.dart` instead of `main.dart` to see the demo.

---

## How to Test

### Option A: In Flutter Emulator (Easiest)

1. Start Android emulator
2. Run backend: `node app.js` in backend folder
3. Run Flutter: `flutter run`
4. Go to "Recognize" tab
5. Take photo or pick from gallery
6. Tap "Recognize Image"
7. Wait for results

### Option B: Physical Device

1. Find your PC's IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
2. Update `BACKEND_URL` in `main_ai_demo.dart`:
   ```dart
   const String BACKEND_URL = 'http://192.168.1.100:3000'; // Your IP
   ```
3. Make sure backend is accessible from phone (same network)
4. Run Flutter on device
5. Upload image

---

## API Flow (What's Happening Behind the Scenes)

```
User Action                 Flutter App                     Backend                    Google Vision
    │                           │                              │                            │
    ├─ Pick Image ─────────────>│                              │                            │
    │                           │                              │                            │
    ├─ Tap Upload ─────────────>│                              │                            │
    │                           ├─ POST /api/images/upload ──>│                            │
    │                           │  (multipart: image, userId) │                            │
    │                           │                              ├─ Save image file          │
    │                           │<─ 202 Accepted (imageId) ──│                            │
    │                           │  (start async processing)   │                            │
    │<─ Image Uploaded ─────────│                              │                            │
    │  (imageId shown)          │                              ├─ Process image ──────────>│
    │                           │                              │  (AI recognition)         │
    ├─ Polling ────────────────>│                              │                            │
    │ (wait for results)        │                              │<─ Results ────────────────│
    │                           ├─ GET /api/images/{id}/results                           │
    │                           │  (202 if processing, 200 if done)                       │
    │                           │                              ├─ Return normalized result │
    │                           │<─ 200 OK (AI results) ─────│                            │
    │                           │  {labels, objects, colors, ...}                        │
    │<─ Display Results ────────│                              │                            │
    │  (labels, objects, etc)   │                              │                            │
    │                           │  ✓ Recognition complete!   │                            │
```

---

## Example Responses

### POST /api/images/upload
```json
{
  "success": true,
  "imageId": "img_a1b2c3d4e5f6g7h8",
  "status": "pending",
  "message": "Image uploaded successfully. Processing started."
}
```

### GET /api/images/{imageId}/results (Still Processing)
```json
{
  "imageId": "img_a1b2c3d4e5f6g7h8",
  "status": "processing",
  "message": "Still processing. Check again in 2 seconds."
}
```

### GET /api/images/{imageId}/results (Complete)
```json
{
  "imageId": "img_a1b2c3d4e5f6g7h8",
  "status": "completed",
  "results": {
    "labels": [
      {
        "name": "Cat",
        "confidence": 0.98,
        "description": "A domestic feline animal..."
      }
    ],
    "objects": [...],
    "colors": [
      {"hex": "#A0A0A0", "pixelFraction": 45},
      {"hex": "#FFFFFF", "pixelFraction": 30}
    ],
    "faces": 0,
    "text": "",
    "webEntities": [...]
  },
  "processingTime": 2.3,
  "timestamp": "2026-01-08T10:30:45Z"
}
```

---

## Features Included

✅ **AI Recognition Page**
- Camera + Gallery picker
- Image preview
- Upload to backend
- Auto-polling for results
- Beautiful results display

✅ **History Page**
- View all recognized images
- Delete images
- See top labels and confidence
- Image details

✅ **Settings Page**
- User ID display
- Backend URL info
- API status
- Usage guide

✅ **Error Handling**
- Network error messages
- Timeout handling
- User feedback

---

## Next Steps

1. **Database Integration** (Optional)
   - Store results in Firebase
   - Show user stats (total images, most common labels, etc)

2. **Advanced Features**
   - Batch recognition (multiple images)
   - Real-time camera stream recognition
   - Export results as PDF
   - Share recognition on social media

3. **Optimization**
   - Image compression before upload
   - Caching results locally
   - Offline mode

---

## Troubleshooting

### "Connection refused" error
- Check backend is running: `node app.js`
- Verify BACKEND_URL matches your setup
- For emulator: Use `10.0.2.2` not `localhost`

### "Image not found" after upload
- Wait a bit longer (processing might still be happening)
- Check backend logs for errors
- Ensure Google Vision API has credentials

### UI doesn't show results
- Check Flutter console for errors
- Verify image uploaded successfully (check in backend/uploads folder)
- Try with a simpler image first

---

## Important: Before Production

1. ✅ Update BACKEND_URL to production URL
2. ✅ Add proper authentication (user login)
3. ✅ Store service account key securely (never in code!)
4. ✅ Add rate limiting
5. ✅ Monitor API costs
6. ✅ Add error logging
7. ✅ Test with different image types
8. ✅ Add image compression
9. ✅ Set up HTTPS for backend
10. ✅ Add database backups

---

**Questions? Check the console logs in both backend and Flutter for detailed error messages!**
