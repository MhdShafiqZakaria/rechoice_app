/**
 * Image Service
 * Orchestrates image handling and AI recognition
 * Business logic layer - decoupled from HTTP
 */

const crypto = require('crypto');
const ImageModel = require('../models/imageModel');

class ImageService {
  constructor(aiProvider, storageService) {
    this.aiProvider = aiProvider;
    this.storageService = storageService;
    this.processingCache = new Map(); // Track in-progress recognitions
    console.log('✓ Image Service initialized');
  }

  /**
   * Upload and process image
   * @param {Object} file - Uploaded file from multer
   * @param {string} userId - User ID
   * @returns {Promise<Object>} Image metadata with ID
   */
  async uploadImage(file, userId) {
    // Validate file
    this._validateImage(file);

    // Generate unique ID
    const imageId = this._generateImageId();

    try {
      // Save to storage
      const storagePath = await this.storageService.saveImage(
        file.buffer,
        imageId,
        userId
      );

      // Store metadata in database
      const imageMetadata = {
        imageId,
        userId,
        filename: file.originalname,
        size: file.size,
        mimeType: file.mimetype,
        uploadedAt: new Date(),
        storagePath,
        status: 'pending',
        aiResults: null,
        processingTime: null,
        completedAt: null,
        errorMessage: null
      };

      await ImageModel.create(imageMetadata);

      // Start async AI recognition (fire and forget)
      this._recognizeImageAsync(imageId, storagePath);

      return {
        imageId,
        status: 'pending',
        message: 'Image uploaded successfully. Processing started.'
      };
    } catch (error) {
      console.error('Image upload error:', error);
      throw error;
    }
  }

  /**
   * Get recognition results (or processing status)
   * @param {string} imageId - Image ID
   * @returns {Promise<Object>} Results or status
   */
  async getResults(imageId) {
    const metadata = await ImageModel.findOne({ imageId });

    if (!metadata) {
      throw new Error('Image not found');
    }

    if (metadata.status === 'completed') {
      return {
        imageId,
        status: 'completed',
        results: metadata.aiResults,
        processingTime: metadata.processingTime,
        timestamp: metadata.completedAt
      };
    } else if (metadata.status === 'processing') {
      return {
        imageId,
        status: 'processing',
        message: 'Still processing. Check again in 2 seconds.'
      };
    } else if (metadata.status === 'error') {
      return {
        imageId,
        status: 'error',
        error: metadata.errorMessage
      };
    } else {
      return {
        imageId,
        status: 'pending',
        message: 'Waiting to be processed.'
      };
    }
  }

  /**
   * Get user's image history
   * @param {string} userId - User ID
   * @param {number} limit - Number of results to return
   */
  async getUserImages(userId, limit = 20) {
    const images = await ImageModel.find({ userId });
    
    return images
      .sort((a, b) => new Date(b.uploadedAt) - new Date(a.uploadedAt))
      .slice(0, limit)
      .map(img => ({
        imageId: img.imageId,
        filename: img.filename,
        timestamp: img.uploadedAt,
        status: img.status,
        topLabel: img.aiResults?.labels?.[0]?.name || null,
        confidence: img.aiResults?.labels?.[0]?.confidence || null
      }));
  }

  /**
   * Delete image
   * @param {string} imageId - Image ID
   * @param {string} userId - User ID (for authorization)
   */
  async deleteImage(imageId, userId) {
    const metadata = await ImageModel.findOne({ imageId });

    if (!metadata) {
      throw new Error('Image not found');
    }

    if (metadata.userId !== userId) {
      throw new Error('Unauthorized - cannot delete another user\'s image');
    }

    // Delete from storage
    await this.storageService.deleteImage(metadata.storagePath);

    // Delete from database
    await ImageModel.deleteOne({ imageId });

    return { success: true, message: 'Image deleted' };
  }

  /**
   * Replace AI provider (for flexibility)
   * Allows swapping providers without changing business logic
   */
  setAIProvider(newProvider) {
    this.aiProvider = newProvider;
    console.log(`AI Provider changed to: ${newProvider.getProviderName()}`);
  }

  /**
   * Get service statistics
   */
  async getStats() {
    return await ImageModel.getStats();
  }

  // ============ PRIVATE METHODS ============

  /**
   * Validate uploaded image
   * @private
   */
  _validateImage(file) {
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    const maxSize = 20 * 1024 * 1024; // 20MB

    if (!file) {
      throw new Error('No file provided');
    }

    if (!allowedMimes.includes(file.mimetype)) {
      throw new Error('Invalid image format. Use JPEG, PNG, or WebP');
    }

    if (file.size > maxSize) {
      throw new Error('Image size exceeds 20MB limit');
    }

    if (file.size < 1000) {
      throw new Error('Image is too small (min 1KB)');
    }
  }

  /**
   * Generate unique image ID
   * @private
   */
  _generateImageId() {
    return `img_${crypto.randomBytes(8).toString('hex')}`;
  }

  /**
   * Async image recognition (fire and forget)
   * @private
   */
  async _recognizeImageAsync(imageId, storagePath) {
    const startTime = Date.now();
    this.processingCache.set(imageId, 'processing');

    try {
      // Update status to processing
      await ImageModel.findOneAndUpdate(
        { imageId },
        { status: 'processing' }
      );

      // Call AI provider
      console.log(`🔄 Starting AI recognition for ${imageId}`);
      const aiResults = await this.aiProvider.recognizeImage(storagePath);
      const processingTime = (Date.now() - startTime) / 1000;

      // Update metadata with results
      await ImageModel.findOneAndUpdate(imageId, {
        status: 'completed',
        aiResults,
        processingTime,
        completedAt: new Date()
      });

      this.processingCache.delete(imageId);
      console.log(`✓ Image ${imageId} processed in ${processingTime.toFixed(2)}s`);
    } catch (error) {
      console.error(`✗ AI recognition failed for ${imageId}:`, error.message);
      
      await ImageModel.findOneAndUpdate(
        { imageId },
        {
          status: 'error',
          errorMessage: error.message
        }
      );
      
      this.processingCache.delete(imageId);
    }
  }
}

module.exports = ImageService;
