/**
 * Abstract AI Provider Interface
 * Ensures all AI providers follow the same contract
 * 
 * This allows easy swapping between different AI services:
 * - Google Vision
 * - AWS Rekognition
 * - Azure Computer Vision
 * - Custom ML models
 */

class AIProvider {
  /**
   * Recognize image content
   * @param {string} imagePath - Path to image file
   * @returns {Promise<Object>} Recognition results
   */
  async recognizeImage(imagePath) {
    throw new Error('recognizeImage() must be implemented by subclass');
  }

  /**
   * Process multiple images
   * @param {string[]} imagePaths - Array of image paths
   * @returns {Promise<Object[]>} Array of recognition results
   */
  async batchRecognize(imagePaths) {
    throw new Error('batchRecognize() must be implemented by subclass');
  }

  /**
   * Get provider name/identifier
   * @returns {string} Provider name
   */
  getProviderName() {
    throw new Error('getProviderName() must be implemented by subclass');
  }
}

module.exports = AIProvider;
