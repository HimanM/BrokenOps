#!/bin/bash
docker stop web-app || true
docker rm web-app || true
docker run -d --name web-app --restart always -p 8080:80   --health-cmd "curl -f http://localhost/ || exit 1"   --health-interval 5s   nginx:latest
