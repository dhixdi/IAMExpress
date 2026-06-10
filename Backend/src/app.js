const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const { errorResponse } = require('./utils/response');

const app = express();

// Security headers
app.use(helmet());

// CORS
const corsOrigin = process.env.NODE_ENV === 'development'
  ? true  // izinkan semua origin di development
  : process.env.ALLOWED_ORIGINS?.split(',') || '*';

app.use(cors({
  origin: corsOrigin,
  credentials: true,
}));

// Logging
app.use(morgan('dev'));

// Body parsers
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/', (req, res) => {
  res.json({ success: true, message: 'IAMExpress API is running' });
});

// API routes
app.use('/api/v1', require('./routes/v1'));

// 404 handler for unmatched routes
app.use((req, res) => {
  return errorResponse(res, `Route ${req.method} ${req.originalUrl} not found`, 404);
});

// Global error handler
app.use((err, req, res, _next) => {
  console.error('Unhandled error:', err);
  return errorResponse(res, 'Internal server error', 500);
});

module.exports = app;
