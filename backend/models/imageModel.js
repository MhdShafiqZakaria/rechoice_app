/**
 * Image Model
 * Represents image metadata and AI recognition results
 * 
 * Replace this with your actual database (Firebase, MongoDB, etc.)
 */

class ImageModel {
  /**
   * Constructor - initialize in-memory storage (for demo)
   * In production, use a real database
   */
  constructor() {
    this.images = new Map(); // imageId -> metadata
  }

  /**
   * Save image metadata
   */
  async create(metadata) {
    if (!metadata.imageId) {
      throw new Error('imageId is required');
    }

    this.images.set(metadata.imageId, {
      ...metadata,
      createdAt: new Date(),
      updatedAt: new Date()
    });

    return this.images.get(metadata.imageId);
  }

  /**
   * Find image by ID
   */
  async findOne(query) {
    if (query.imageId) {
      return this.images.get(query.imageId) || null;
    }
    throw new Error('Query parameter required');
  }

  /**
   * Find all images by user
   */
  async find(query) {
    if (!query.userId) {
      throw new Error('userId is required');
    }

    const results = Array.from(this.images.values())
      .filter(img => img.userId === query.userId);
    
    return results;
  }

  /**
   * Update image metadata
   */
  async findOneAndUpdate(query, updates) {
    if (!query.imageId) {
      throw new Error('imageId is required');
    }

    const existing = this.images.get(query.imageId);
    if (!existing) {
      throw new Error('Image not found');
    }

    const updated = {
      ...existing,
      ...updates,
      updatedAt: new Date()
    };

    this.images.set(query.imageId, updated);
    return updated;
  }

  /**
   * Delete image record
   */
  async deleteOne(query) {
    if (!query.imageId) {
      throw new Error('imageId is required');
    }

    const existed = this.images.has(query.imageId);
    this.images.delete(query.imageId);
    return { deletedCount: existed ? 1 : 0 };
  }

  /**
   * Get all images (admin only)
   */
  async findAll() {
    return Array.from(this.images.values());
  }

  /**
   * Get statistics
   */
  async getStats() {
    const all = Array.from(this.images.values());
    return {
      totalImages: all.length,
      completed: all.filter(img => img.status === 'completed').length,
      processing: all.filter(img => img.status === 'processing').length,
      errors: all.filter(img => img.status === 'error').length
    };
  }
}

// Export singleton instance
module.exports = new ImageModel();
