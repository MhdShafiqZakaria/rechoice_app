/**
 * Google Vision API Provider
 * Implementation of AI image recognition using Google Cloud Vision
 */

const vision = require('@google-cloud/vision');
const AIProvider = require('./aiProvider.interface');

class GoogleVisionProvider extends AIProvider {
  constructor(credentialsPath) {
    super();
    
    if (credentialsPath) {
      process.env.GOOGLE_APPLICATION_CREDENTIALS = credentialsPath;
    }

    try {
      this.client = new vision.ImageAnnotatorClient();
      console.log('✓ Google Vision client initialized');
    } catch (error) {
      console.error('Failed to initialize Google Vision:', error.message);
      throw error;
    }
  }

  /**
   * Recognize objects, labels, and properties in an image
   * @param {string} imagePath - Local file path or GCS URI (gs://bucket/image.jpg)
   * @returns {Promise<Object>} Normalized recognition results
   */
  async recognizeImage(imagePath) {
    try {
      console.log(`Processing image: ${imagePath}`);

      const request = {
        image: {
          source: { filename: imagePath }
        },
        features: [
          { type: 'LABEL_DETECTION', maxResults: 10 },
          { type: 'OBJECT_LOCALIZATION', maxResults: 10 },
          { type: 'IMAGE_PROPERTIES' },
          { type: 'FACE_DETECTION', maxResults: 5 },
          { type: 'TEXT_DETECTION' },
          { type: 'WEB_DETECTION' },
          { type: 'SAFE_SEARCH_DETECTION' }
        ]
      };

      const [result] = await this.client.annotateImage(request);
      return this._normalizeResponse(result);
    } catch (error) {
      console.error('Google Vision API error:', error);
      throw new Error(`AI Recognition failed: ${error.message}`);
    }
  }

  /**
   * Batch recognize multiple images
   * @param {string[]} imagePaths - Array of image paths
   * @returns {Promise<Object[]>} Array of normalized results
   */
  async batchRecognize(imagePaths) {
    const results = await Promise.all(
      imagePaths.map(path => this.recognizeImage(path))
    );
    return results;
  }

  /**
   * Normalize Google Vision response to standard format
   * @private
   */
  _normalizeResponse(googleResult) {
    return {
      labels: (googleResult.labelAnnotations || []).map(label => ({
        name: label.description,
        confidence: Math.round(label.score * 100) / 100, // Round to 2 decimals
        description: this._getDetailedDescription(label.description)
      })),
      objects: (googleResult.localizedObjectAnnotations || []).map(obj => ({
        name: obj.name,
        confidence: Math.round(obj.score * 100) / 100,
        boundingBox: obj.boundingPoly ? this._normalizeBoundingBox(obj.boundingPoly) : null
      })),
      colors: this._extractColors(googleResult.imagePropertiesAnnotation),
      faces: googleResult.faceAnnotations?.length || 0,
      landmarks: (googleResult.landmarkAnnotations || []).map(landmark => ({
        name: landmark.description,
        confidence: Math.round(landmark.score * 100) / 100
      })),
      text: googleResult.fullTextAnnotation?.text || '',
      safeSearch: this._normalizeSafeSearch(googleResult.safeSearchAnnotation),
      webEntities: (googleResult.webDetection?.webEntities || [])
        .slice(0, 5)
        .map(entity => ({
          description: entity.description,
          score: Math.round(entity.score * 100) / 100
        }))
    };
  }

  /**
   * Extract dominant colors from image
   * @private
   */
  _extractColors(imageProperties) {
    if (!imageProperties?.dominantColors?.colors) return [];
    
    return imageProperties.dominantColors.colors
      .slice(0, 5)
      .map(color => ({
        hex: this._rgbToHex(color.color),
        pixelFraction: Math.round(color.pixelFraction * 100)
      }));
  }

  /**
   * Convert RGB to Hex
   * @private
   */
  _rgbToHex(rgb) {
    const r = (rgb.red || 0).toString(16).padStart(2, '0');
    const g = (rgb.green || 0).toString(16).padStart(2, '0');
    const b = (rgb.blue || 0).toString(16).padStart(2, '0');
    return `#${r}${g}${b}`.toUpperCase();
  }

  /**
   * Normalize safe search results
   * @private
   */
  _normalizeSafeSearch(safeSearch) {
    return {
      adult: safeSearch?.adult || 'UNKNOWN',
      spoof: safeSearch?.spoof || 'UNKNOWN',
      medical: safeSearch?.medical || 'UNKNOWN',
      violence: safeSearch?.violence || 'UNKNOWN',
      racy: safeSearch?.racy || 'UNKNOWN'
    };
  }

  /**
   * Normalize bounding box coordinates
   * @private
   */
  _normalizeBoundingBox(boundingPoly) {
    if (!boundingPoly?.normalizedVertices) return null;
    
    return boundingPoly.normalizedVertices.map(vertex => ({
      x: vertex.x || 0,
      y: vertex.y || 0
    }));
  }

  /**
   * Get enhanced description for labels
   * @private
   */
  _getDetailedDescription(labelName) {
    // Knowledge base - can be extended or connected to external API
    const descriptions = {
      'cat': 'A domestic feline animal known for independence and agility',
      'dog': 'A domesticated carnivore known as a faithful companion',
      'tree': 'A woody perennial plant with a trunk and branches',
      'person': 'A human being',
      'car': 'A motor vehicle designed for transportation',
      'book': 'A bound set of printed pages',
      'plant': 'A living organism that typically grows in soil',
      'flower': 'The reproductive part of a flowering plant'
    };
    
    return descriptions[labelName.toLowerCase()] || '';
  }

  /**
   * Get provider name
   */
  getProviderName() {
    return 'Google Vision API';
  }
}

module.exports = GoogleVisionProvider;
