/**
 * CareerOS Frontend Development Proxy
 * 
 * Serves Flutter Web build and proxies /api/* to Spring Boot backend at localhost:8080.
 * 
 * Usage:
 *   1. Build Flutter web: flutter build web --release --dart-define=API_BASE_URL=/api
 *   2. Run proxy: npm start (from dev-proxy directory)
 *   3. Open http://localhost:3000
 */

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;
const BACKEND_URL = 'http://localhost:8080';
const FLUTTER_BUILD_DIR = path.join(__dirname, '..', 'build', 'web');

// Verify Flutter build exists
if (!fs.existsSync(FLUTTER_BUILD_DIR)) {
  console.error('❌ Flutter build not found at:', FLUTTER_BUILD_DIR);
  console.error('   Run: flutter build web --release --dart-define=API_BASE_URL=/api');
  process.exit(1);
}

// 1. Proxy /api/* requests to backend
app.use('/api', createProxyMiddleware({
  target: BACKEND_URL,
  changeOrigin: true,
  pathRewrite: {
    '^/api': '/api'  // Keep /api prefix when forwarding
  },
  onProxyReq: (proxyReq, req, res) => {
    // Preserve Authorization header
    const authHeader = req.headers.authorization;
    if (authHeader) {
      proxyReq.setHeader('Authorization', authHeader);
    }
    // Log API requests in development
    console.log(`[PROXY] ${req.method} ${req.originalUrl} -> ${BACKEND_URL}${req.originalUrl}`);
  },
  onProxyRes: (proxyRes, req, res) => {
    console.log(`[PROXY] ${req.method} ${req.originalUrl} <- ${proxyRes.statusCode}`);
  },
  onError: (err, req, res) => {
    console.error(`[PROXY ERROR] ${req.method} ${req.originalUrl}:`, err.message);
    if (!res.headersSent) {
      res.status(502).json({
        success: false,
        message: 'Unable to connect to CareerOS backend. Please ensure backend is running on port 8080.',
        error: 'BAD_GATEWAY'
      });
    }
  }
}));

// 2. Serve Flutter static assets
app.use(express.static(FLUTTER_BUILD_DIR, {
  index: false,  // We'll handle index.html manually for SPA routing
  maxAge: '0',   // No caching in development
  setHeaders: (res, filePath) => {
    // Ensure proper MIME types
    if (filePath.endsWith('.js')) {
      res.setHeader('Content-Type', 'application/javascript');
    } else if (filePath.endsWith('.wasm')) {
      res.setHeader('Content-Type', 'application/wasm');
    } else if (filePath.endsWith('.json')) {
      res.setHeader('Content-Type', 'application/json');
    }
  }
}));

// 3. SPA fallback - serve index.html for all non-API routes
app.use((req, res, next) => {
  // Skip API routes (already handled by proxy)
  if (req.path.startsWith('/api')) {
    return next();
  }
  
  // Serve index.html for all other routes (SPA routing)
  const indexPath = path.join(FLUTTER_BUILD_DIR, 'index.html');
  if (fs.existsSync(indexPath)) {
    res.sendFile(indexPath);
  } else {
    res.status(404).send('Flutter build not found');
  }
});

// 4. Start server
app.listen(PORT, () => {
  console.log('╔══════════════════════════════════════════════════════════╗');
  console.log('║  CareerOS Frontend Development Proxy                        ║');
  console.log('╠══════════════════════════════════════════════════════════╣');
  console.log(`║  Frontend:  http://localhost:${PORT}                           ║`);
  console.log(`║  Proxy:     /api/* -> ${BACKEND_URL}                           ║`);
  console.log(`║  Serving:   ${FLUTTER_BUILD_DIR}                          ║`);
  console.log('╚══════════════════════════════════════════════════════════╝');
  console.log('\n📋 Prerequisites:');
  console.log('   1. Backend running on http://localhost:8080');
  console.log('   2. Flutter built: flutter build web --release --dart-define=API_BASE_URL=/api');
  console.log('\n🚀 Open http://localhost:3000 in your browser');
  console.log('─'.repeat(60));
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n👋 Shutting down proxy...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n👋 Shutting down proxy...');
  process.exit(0);
});