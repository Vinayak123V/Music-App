const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');
const fs = require('fs');

const songsRouter = require('./routes/songs');
const categoriesRouter = require('./routes/categories');
const deitiesRouter = require('./routes/deities');
const streamRouter = require('./routes/stream');
const searchRouter = require('./routes/search');
const authRouter = require('./routes/auth');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Static files for uploads (audio & artwork)
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

// API Routes
app.use('/api/songs', songsRouter);
app.use('/api/categories', categoriesRouter);
app.use('/api/deities', deitiesRouter);
app.use('/api/stream', streamRouter);
app.use('/api/search', searchRouter);
app.use('/api/auth', authRouter);

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'online',
    app: 'Bhakti Music API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

// Serve production React client build if dist folder exists
const clientDist = path.join(__dirname, '..', '..', 'client', 'dist');
if (fs.existsSync(clientDist)) {
  app.use(express.static(clientDist));
  app.get('*', (req, res, next) => {
    if (req.path.startsWith('/api') || req.path.startsWith('/uploads')) {
      return next();
    }
    res.sendFile(path.join(clientDist, 'index.html'));
  });
}

app.listen(PORT, () => {
  console.log(`\n====================================================`);
  console.log(`🕉️  BHAKTI MUSIC FULL-STACK SERVER RUNNING ON PORT ${PORT}`);
  console.log(`   Web App & API: http://localhost:${PORT}`);
  console.log(`   Catalog API:   http://localhost:${PORT}/api/songs`);
  console.log(`====================================================\n`);
});
