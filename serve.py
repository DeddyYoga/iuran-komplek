#!/usr/bin/env python3
"""Server preview dengan header no-cache (biar HP selalu dapat file terbaru)."""
import http.server
import socketserver


class NoCache(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()


if __name__ == "__main__":
    import os
    os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), "app"))
    with socketserver.TCPServer(("", 8765), NoCache) as httpd:
        print("serving :8765 (no-cache)")
        httpd.serve_forever()
