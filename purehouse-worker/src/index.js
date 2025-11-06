require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3002;

// Middleware
app.use(express.json());
app.use(cors());

// Helper function to format logs
const formatLog = (logData) => {
  const timestamp = logData.timestamp || new Date().toISOString();
  const level = (logData.level || 'INFO').toUpperCase();
  
  // Color coding for different log levels
  const colors = {
    ERROR: '\x1b[31m', // Red
    WARN: '\x1b[33m',  // Yellow
    INFO: '\x1b[36m',  // Cyan
    DEBUG: '\x1b[35m', // Magenta
    SUCCESS: '\x1b[32m' // Green
  };
  const reset = '\x1b[0m';
  const color = colors[level] || colors.INFO;

  return {
    color,
    reset,
    timestamp,
    level,
    message: logData.message || 'No message provided',
    metadata: logData.metadata || {}
  };
};

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    service: 'purehouse-worker',
    timestamp: new Date().toISOString() 
  });
});

// Main log endpoint
app.post('/logs', (req, res) => {
  try {
    const log = formatLog(req.body);
    
    // Console log with colors
    console.log('\n' + '='.repeat(60));
    console.log(`${log.color}📋 [${log.level}]${log.reset} ${log.timestamp}`);
    console.log(`${log.color}Message:${log.reset} ${log.message}`);
    
    if (Object.keys(log.metadata).length > 0) {
      console.log(`${log.color}Metadata:${log.reset}`);
      console.log(JSON.stringify(log.metadata, null, 2));
    }
    
    console.log('='.repeat(60) + '\n');
    
    res.status(200).json({ 
      status: 'logged',
      timestamp: log.timestamp,
      level: log.level
    });
  } catch (error) {
    console.error('❌ Error processing log:', error);
    res.status(500).json({ 
      status: 'error', 
      message: 'Failed to process log' 
    });
  }
});

// Batch logs endpoint (for multiple logs at once)
app.post('/logs/batch', (req, res) => {
  try {
    const logs = req.body.logs || [];
    
    console.log('\n' + '🔥'.repeat(30));
    console.log(`📦 BATCH LOGS - ${logs.length} entries`);
    console.log('🔥'.repeat(30));
    
    logs.forEach((logData, index) => {
      const log = formatLog(logData);
      console.log(`\n[${index + 1}/${logs.length}] ${log.color}[${log.level}]${log.reset} ${log.message}`);
      if (Object.keys(log.metadata).length > 0) {
        console.log(JSON.stringify(log.metadata, null, 2));
      }
    });
    
    console.log('\n' + '🔥'.repeat(30) + '\n');
    
    res.status(200).json({ 
      status: 'logged',
      count: logs.length,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('❌ Error processing batch logs:', error);
    res.status(500).json({ 
      status: 'error', 
      message: 'Failed to process batch logs' 
    });
  }
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ 
    status: 'error', 
    message: 'Endpoint not found' 
  });
});

// Start server
app.listen(PORT, () => {
  console.log('\n' + '🚀'.repeat(30));
  console.log(`✅ PureHouse Worker running on port ${PORT}`);
  console.log(`📋 Health check: http://localhost:${PORT}/health`);
  console.log(`📝 Log endpoint: http://localhost:${PORT}/logs`);
  console.log('🚀'.repeat(30) + '\n');
});
