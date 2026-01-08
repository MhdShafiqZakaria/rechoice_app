const functions = require('firebase-functions');
const admin = require('firebase-admin');
const vision = require('@google-cloud/vision');

admin.initializeApp();

// Initialize Vision client with explicit credentials
const visionClient = new vision.ImageAnnotatorClient({
  // Credentials will be picked up from GOOGLE_APPLICATION_CREDENTIALS env var
  // or from the default service account in Firebase
});

exports.processImage = functions.https.onCall(async (data, context) => {
  // 1. VERIFY AUTHENTICATION
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to call this function.'
    );
  }

  const { imageId, imageUrl } = data;

  // 2. VALIDATE INPUT
  if (!imageId || !imageUrl) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required parameters: imageId and imageUrl'
    );
  }

  console.log(`Processing image ${imageId} for user ${context.auth.uid}`);

  try {
    // 3. UPDATE STATUS
    await admin.firestore().collection('images').doc(imageId).update({
      status: 'processing',
      userId: context.auth.uid,
      startedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 4. CALL VISION API
    console.log('Calling Vision API for:', imageUrl);
    const [result] = await visionClient.annotateImage({
      image: { source: { imageUri: imageUrl } },
      features: [
        { type: 'LABEL_DETECTION', maxResults: 10 },
        { type: 'OBJECT_LOCALIZATION', maxResults: 10 },
        { type: 'IMAGE_PROPERTIES' },
        { type: 'TEXT_DETECTION' },
      ],
    });

    console.log('Vision API response received');

    // 5. PROCESS RESULTS
    const results = {
      labels: (result.labelAnnotations || []).map(l => ({
        name: l.description,
        confidence: Math.round(l.score * 100) / 100,
      })),
      objects: (result.localizedObjectAnnotations || []).map(o => ({
        name: o.name,
        confidence: Math.round(o.score * 100) / 100,
      })),
      colors: result.imagePropertiesAnnotation?.dominantColors?.colors
        ? result.imagePropertiesAnnotation.dominantColors.colors
            .slice(0, 5)
            .map(c => ({
              hex: rgbToHex(c.color),
              pixelFraction: Math.round(c.pixelFraction * 100),
            }))
        : [],
      text: result.textAnnotations?.[0]?.description || '',
    };

    // 6. SAVE RESULTS
    await admin.firestore().collection('images').doc(imageId).update({
      status: 'completed',
      results: results,
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Image ${imageId} processed successfully`);
    return { 
      success: true, 
      results: results 
    };

  } catch (error) {
    console.error('Processing error:', error);
    console.error('Error code:', error.code);
    console.error('Error details:', error.details);

    // Update Firestore with error
    await admin.firestore().collection('images').doc(imageId).update({
      status: 'error',
      error: error.message,
      errorCode: error.code,
      failedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Throw appropriate error
    if (error.code === 7) { // PERMISSION_DENIED
      throw new functions.https.HttpsError(
        'permission-denied',
        'Vision API access denied. Check service account permissions.'
      );
    }

    throw new functions.https.HttpsError(
      'internal',
      `Image processing failed: ${error.message}`
    );
  }
});

function rgbToHex(color) {
  const r = Math.round(color.red || 0);
  const g = Math.round(color.green || 0);
  const b = Math.round(color.blue || 0);
  return '#' + 
    r.toString(16).padStart(2, '0') + 
    g.toString(16).padStart(2, '0') + 
    b.toString(16).padStart(2, '0');
}