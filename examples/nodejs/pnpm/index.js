/**
 * Simple HTTP server example using pnpm for dependency management.
 */

const http = require('http');

const port = process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  const response = {
    message: 'Hello from distroless Node.js with pnpm!',
    nodeVersion: process.version,
    path: req.url,
    method: req.method,
  };

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(response, null, 2));

  console.log(`[HTTP] ${req.method} ${req.url}`);
});

server.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
