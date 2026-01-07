/**
 * Image Routes
 * API endpoints for image upload and recognition
 */

const express = require('express');
const multer = require('multer');
const ImageController = require('../controllers/imageController');

// Configure multer for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 20 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPEG, PNG, and WebP allowed.'));
    }
  }
});

/**
 * Create image routes with injected ImageService
 * @param {ImageService} imageService - Image service instance
 * @returns {Router} Express router
 */
function createImageRoutes(imageService) {
  const router = express.Router();
  const controller = new ImageController(imageService);

  // Bind methods to preserve 'this' context
  const uploadImage = controller.uploadImage.bind(controller);
  const getResults = controller.getResults.bind(controller);
  const getUserImages = controller.getUserImages.bind(controller);
  const deleteImage = controller.deleteImage.bind(controller);
  const getStats = controller.getStats.bind(controller);

  // ===== IMAGE ROUTES =====

  /**
   * POST /api/images/upload
   * Upload image for AI recognition
   * 
   * Request:
   *   - Content-Type: multipart/form-data
   *   - image: File (JPEG/PNG/WebP)
   *   - userId: string (query param or body)
   * 
   * Response:
   *   - 202 Accepted with imageId
   */
  router.post('/images/upload', (req, res, next) => {
    console.log('📨 POST /api/images/upload received');
    console.log('Content-Type:', req.headers['content-type']);
    upload.single('image')(req, res, (err) => {
      if (err) {
        console.error('❌ Multer error:', err.message);
        return res.status(400).json({
          success: false,
          error: 'File upload error: ' + err.message
        });
      }
      console.log('📂 File received by multer:', req.file ? req.file.originalname : 'None');
      uploadImage(req, res, next);
    });
  });

  /**
   * GET /api/images/:imageId/results
   * Get recognition results
   * 
   * Response:
   *   - 200 OK: Results available
   *   - 202 Accepted: Still processing
   *   - 404 Not Found: Image not found
   */
  router.get('/images/:imageId/results', getResults);

  /**
   * GET /api/users/:userId/images
   * Get user's image history
   * 
   * Query params:
   *   - limit: number (default: 20)
   * 
   * Response:
   *   - 200 OK with array of images
   */
  router.get('/users/:userId/images', getUserImages);

  /**
   * DELETE /api/images/:imageId
   * Delete image and results
   * 
   * Request:
   *   - userId: string (query param or body)
   * 
   * Response:
   *   - 200 OK: Image deleted
   *   - 401 Unauthorized: No userId
   *   - 403 Forbidden: Not owner
   *   - 404 Not Found: Image not found
   */
  router.delete('/images/:imageId', deleteImage);

  /**
   * GET /api/stats
   * Get service statistics
   * 
   * Response:
   *   - totalImages, completed, processing, errors
   */
  router.get('/stats', getStats);

  return router;
}

module.exports = createImageRoutes;
