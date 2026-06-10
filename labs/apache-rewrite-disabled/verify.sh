#!/bin/bash

# Check if rewrite module is enabled
if ! apache2ctl -M | grep -q "rewrite_module"; then
    echo "FAILURE: mod_rewrite is not enabled."
    exit 1
fi

# Check if a custom route (e.g., /test-route) returns the app content (200 OK)
# The .htaccess should forward /test-route to index.php
if curl -s http://localhost/test-route | grep -q "Welcome to the App: /test-route"; then
    echo "SUCCESS: Routing is working correctly."
    exit 0
else
    echo "FAILURE: Routing is still broken (returned 404 or unexpected content)."
    exit 1
fi
