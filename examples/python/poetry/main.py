#!/usr/bin/env python3
"""Simple HTTP server example using Poetry for dependency management."""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os


class HelloHandler(BaseHTTPRequestHandler):
    """Simple HTTP request handler."""

    def do_GET(self):
        """Handle GET requests."""
        response = {
            "message": "Hello from distroless Python with Poetry!",
            "python_version": os.popen("python3 --version").read().strip(),
            "path": self.path,
        }
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(response, indent=2).encode())

    def log_message(self, format, *args):
        """Log HTTP requests."""
        print(f"[HTTP] {args[0]}")


def main():
    """Start the HTTP server."""
    port = int(os.environ.get("PORT", 8080))
    server = HTTPServer(("", port), HelloHandler)
    print(f"Server running on port {port}")
    server.serve_forever()


if __name__ == "__main__":
    main()
