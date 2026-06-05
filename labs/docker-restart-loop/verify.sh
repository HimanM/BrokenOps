#!/bin/bash

# 1. Check if docker is active
systemctl is-active --quiet docker
if [ $? -ne 0 ]; then
  echo "FAILURE: Docker daemon is not running."
  exit 1
fi

# 2. Check if web-app container exists
if ! docker ps -a --format '{{.Names}}' | grep -q '^web-app$'; then
  echo "FAILURE: Container 'web-app' does not exist."
  exit 1
fi

# 3. Check if web-app container is running
STATUS=$(docker inspect -f '{{.State.Status}}' web-app)
if [ "$STATUS" != "running" ]; then
  echo "FAILURE: Container 'web-app' is not running (status: $STATUS)."
  exit 1
fi

# 4. Check if container has healthcheck enabled and is healthy
HEALTH=$(docker inspect -f '{{.State.Health.Status}}' web-app 2>/dev/null)
if [ -z "$HEALTH" ]; then
  echo "FAILURE: Container 'web-app' does not have a healthcheck configured."
  exit 1
fi

if [ "$HEALTH" != "healthy" ]; then
  echo "FAILURE: Container 'web-app' health status is '$HEALTH' (expected: healthy)."
  exit 1
fi

# 5. Check if the restart loop has stopped (restart count is not increasing)
sleep 5
STATUS2=$(docker inspect -f '{{.State.Status}}' web-app)
HEALTH2=$(docker inspect -f '{{.State.Health.Status}}' web-app 2>/dev/null)

if [ "$STATUS2" != "running" ] || [ "$HEALTH2" != "healthy" ]; then
  echo "FAILURE: Container is still unstable or unhealthy."
  exit 1
fi

# 6. Make sure the health check command doesn't have kill 1 in it
CMD=$(docker inspect -f '{{.Config.Healthcheck.Test}}' web-app 2>/dev/null)
if [[ "$CMD" == *"kill"* ]]; then
  echo "FAILURE: The healthcheck command still contains a self-destruct 'kill' command!"
  exit 1
fi

echo "SUCCESS: Container 'web-app' is running and healthy!"
exit 0
