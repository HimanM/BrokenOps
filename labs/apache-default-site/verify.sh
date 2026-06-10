#!/bin/bash

# Check if Apache is responding with the Custom App content
if curl -s http://localhost | grep -q "Custom App is Running"; then
    echo "SUCCESS: The custom application is being served."
    exit 0
else
    echo "FAILURE: The custom application is not being served. Still seeing default page or error."
    exit 1
fi
