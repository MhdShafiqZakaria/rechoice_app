/**
 * Storage Service
 * Handles file upload and storage operations
 * 
 * Currently: Local filesystem
 * Can be replaced with: AWS S3, Google Cloud Storage, Firebase Storage
 */

const fs = require('fs').promises;
const path = require('path');

class StorageService {
  constructor(uploadDir = './uploads') {
    this.uploadDir = uploadDir;
    this._initializeUploadDir();
  }

  /**
   * Initialize upload directory
   * @private
   */
  async _initializeUploadDir() {
    try {
      await fs.mkdir(this.uploadDir, { recursive: true });
      console.log(`✓ Upload directory ready: ${this.uploadDir}`);
    } catch (error) {
      console.error('Failed to create upload directory:', error);
      throw error;
    }
  }

  /**
   * Save image buffer to storage
   * @param {Buffer} buffer - Image file buffer
   * @param {string} imageId - Unique image ID
   * @param {string} userId - User ID for organization
   * @returns {Promise<string>} Path to saved file
   */
  async saveImage(buffer, imageId, userId) {
    try {
      // Create user-specific directory
      const userDir = path.join(this.uploadDir, userId);
      await fs.mkdir(userDir, { recursive: true });

      // Generate filename with timestamp
      const timestamp = Date.now();
      const filename = `${imageId}_${timestamp}.jpg`;
      const filePath = path.join(userDir, filename);

      // Write file
      await fs.writeFile(filePath, buffer);
      console.log(`✓ Image saved: ${filePath}`);

      return filePath;
    } catch (error) {
      console.error('Failed to save image:', error);
      throw error;
    }
  }

  /**
   * Read image file
   * @param {string} filePath - Path to image file
   * @returns {Promise<Buffer>} Image buffer
   */
  async getImage(filePath) {
    try {
      return await fs.readFile(filePath);
    } catch (error) {
      console.error('Failed to read image:', error);
      throw new Error('Image not found');
    }
  }

  /**
   * Delete image file
   * @param {string} filePath - Path to image file
   * @returns {Promise<boolean>} Success status
   */
  async deleteImage(filePath) {
    try {
      await fs.unlink(filePath);
      console.log(`✓ Image deleted: ${filePath}`);
      return true;
    } catch (error) {
      console.error('Failed to delete image:', error);
      return false;
    }
  }

  /**
   * Get file info
   * @param {string} filePath - Path to image file
   * @returns {Promise<Object>} File stats
   */
  async getFileStats(filePath) {
    try {
      return await fs.stat(filePath);
    } catch (error) {
      console.error('Failed to get file stats:', error);
      throw error;
    }
  }

  /**
   * Clean up old uploads (optional maintenance)
   * @param {number} daysOld - Delete files older than X days
   */
  async cleanupOldFiles(daysOld = 30) {
    try {
      const now = Date.now();
      const maxAge = daysOld * 24 * 60 * 60 * 1000;

      const files = await fs.readdir(this.uploadDir, { recursive: true });
      
      for (const file of files) {
        const filePath = path.join(this.uploadDir, file);
        const stats = await fs.stat(filePath);
        
        if (now - stats.mtime.getTime() > maxAge) {
          await fs.unlink(filePath);
          console.log(`Cleaned up: ${filePath}`);
        }
      }
    } catch (error) {
      console.error('Cleanup error:', error);
    }
  }
}

module.exports = StorageService;
