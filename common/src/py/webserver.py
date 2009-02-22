# Copyright 2008-2009 WebDriver committers
# Copyright 2008-2009 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""A simple web server for testing purpose.
It serves the testing html pages that are needed by the webdriver unit tests."""

import logging
import os
import threading
import urllib
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer

HTML_ROOT = os.getenv("webdriver_test_htmlroot")
PORT = 8000

class HtmlOnlyHandler(BaseHTTPRequestHandler):
    """Http handler."""
    def do_GET(self):
        """GET method handler."""
        try:
            path = self.path[1:].split('?')[0]
            html = open(os.path.join(HTML_ROOT, path))
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(html.read())
            html.close()
        except IOError:
            self.send_response(404,'File Not Found: %s' % path)

class SimpleWebServer(object):
    """A very basic web server."""
    def __init__(self):
        self.stop_serving = False
        self.server = HTTPServer(('', PORT), HtmlOnlyHandler)
        self.thread = threading.Thread(target=self._run_web_server)

    def _run_web_server(self):
        """Runs the server loop."""
        logging.debug("web server started")
        while not self.stop_serving:
            self.server.handle_request()
        self.server.server_close()

    def start(self):
        """Starts the server."""
        self.thread.start()

    def stop(self):
        """Stops the server."""
        self.stop_serving = True
        try:
            # This is to force stop the server loop
            urllib.URLopener().open("http://localhost:8000")
        except Exception:
            pass  #the server has shutdown
        self.thread.join()
