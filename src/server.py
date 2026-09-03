#!/usr/bin/env python3
"""
Minimal HTTP server for ForgeAppTemplate.
Serves static files from src/ directory and handles basic routes.
"""
import argparse
import http.server
import os
import socketserver
from pathlib import Path


class ForgeHandler(http.server.SimpleHTTPRequestHandler):
    """Custom handler that serves from src/ directory."""
    
    def __init__(self, *args, **kwargs):
        # Serve from the src directory
        src_dir = Path(__file__).parent
        super().__init__(*args, directory=str(src_dir), **kwargs)
    
    def do_GET(self):
        # Serve index.html for root path
        if self.path == '/' or self.path == '':
            self.path = '/index.html'
        return super().do_GET()
    
    def log_message(self, format, *args):
        """Log HTTP requests to stdout."""
        print(f"[ForgeApp] {self.address_string()} - {format % args}")


def main():
    parser = argparse.ArgumentParser(description='ForgeAppTemplate development server')
    parser.add_argument(
        '--port', '-p',
        type=int,
        default=8000,
        help='Port to listen on (default: 8000)'
    )
    parser.add_argument(
        '--host',
        type=str,
        default='0.0.0.0',
        help='Host to bind to (default: 0.0.0.0)'
    )
    args = parser.parse_args()
    
    # Allow port reuse to avoid "Address already in use" errors
    socketserver.TCPServer.allow_reuse_address = True
    
    with socketserver.TCPServer((args.host, args.port), ForgeHandler) as httpd:
        print(f"[ForgeApp] Server starting on http://{args.host}:{args.port}")
        print(f"[ForgeApp] Serving files from: {Path(__file__).parent}")
        print(f"[ForgeApp] Press Ctrl+C to stop")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n[ForgeApp] Server stopped")


if __name__ == '__main__':
    main()
