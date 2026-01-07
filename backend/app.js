/**
 * Main Application Entry Point
 * AI Image Recognition Backend API
 */

const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');

// Load environment variables
dotenv.config();

// Import services and routes
const GoogleVisionProvider = require('./services/aiProviders/googleVisionProvider');
const ImageService = require('./services/imageService');
const StorageService = require('./services/storageService');
const createImageRoutes = require('./routes/imageRoutes');

// Initialize Express app
const app = express();

// Middleware
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'API is running',
    timestamp: new Date()
  });
});

// Initialize AI Provider
console.log('Initializing AI provider...');
const aiProvider = new GoogleVisionProvider(
  process.env.GOOGLE_APPLICATION_CREDENTIALS
);
console.log(`✓ AI Provider: ${aiProvider.getProviderName()}`);

// Initialize Storage Service
const storageService = new StorageService(process.env.UPLOAD_DIR);

// Initialize Image Service
const imageService = new ImageService(aiProvider, storageService);

// Setup routes
app.use('/api', createImageRoutes(imageService));

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: 'Not Found',
    path: req.path
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  
  const statusCode = err.statusCode || 500;
  const message = process.env.NODE_ENV === 'development' 
    ? err.message 
    : 'Internal server error';

  res.status(statusCode).json({
    success: false,
    error: message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Start server
const PORT = process.env.PORT || 3000;
const server = app.listen(PORT, () => {
  console.log(`\n🚀 Server running on http://localhost:${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV}`);
  console.log(`CORS Origin: ${process.env.CORS_ORIGIN || '*'}\n`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

module.exports = app;
