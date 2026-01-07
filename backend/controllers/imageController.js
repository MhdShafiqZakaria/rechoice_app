/**
 * Image Controller
 * Handles HTTP requests and responses
 * Delegates business logic to ImageService
 */

class ImageController {
  constructor(imageService) {
    this.imageService = imageService;
  }

  /**
   * POST /api/images/upload
   * Upload image and start AI recognition
   */
  async uploadImage(req, res, next) {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          error: 'No image file provided'
        });
      }

      const userId = req.user?.id || req.body.userId || req.query.userId;
      if (!userId) {
        return res.status(401).json({
          success: false,
          error: 'User ID required'
        });
      }

      const result = await this.imageService.uploadImage(req.file, userId);

      // 202 Accepted - request accepted but still processing
      res.status(202).json({
        success: true,
        ...result
      });
    } catch (error) {
      res.status(400).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/images/:imageId/results
   * Get recognition results or processing status
   */
  async getResults(req, res, next) {
    try {
      const { imageId } = req.params;

      if (!imageId) {
        return res.status(400).json({
          success: false,
          error: 'imageId parameter required'
        });
      }

      const result = await this.imageService.getResults(imageId);

      // Return 202 if still processing, 200 if complete
      const statusCode = result.status === 'processing' ? 202 : 200;
      res.status(statusCode).json(result);
    } catch (error) {
      res.status(404).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/users/:userId/images
   * Get user's image history
   */
  async getUserImages(req, res, next) {
    try {
      const { userId } = req.params;
      const { limit } = req.query;

      if (!userId) {
        return res.status(400).json({
          success: false,
          error: 'userId parameter required'
        });
      }

      const images = await this.imageService.getUserImages(
        userId,
        parseInt(limit) || 20
      );

      res.status(200).json({
        success: true,
        count: images.length,
        images
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * DELETE /api/images/:imageId
   * Delete image and results
   */
  async deleteImage(req, res, next) {
    try {
      const { imageId } = req.params;
      const userId = req.user?.id || req.body.userId || req.query.userId;

      if (!imageId) {
        return res.status(400).json({
          success: false,
          error: 'imageId parameter required'
        });
      }

      if (!userId) {
        return res.status(401).json({
          success: false,
          error: 'User ID required'
        });
      }

      const result = await this.imageService.deleteImage(imageId, userId);
      res.status(200).json(result);
    } catch (error) {
      const statusCode = error.message.includes('Unauthorized') ? 403 : 500;
      res.status(statusCode).json({
        success: false,
        error: error.message
      });
    }
  }

  /**
   * GET /api/stats
   * Get service statistics (admin only)
   */
  async getStats(req, res, next) {
    try {
      const stats = await this.imageService.getStats();
      res.status(200).json({
        success: true,
        stats
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  }
}

module.exports = ImageController;
