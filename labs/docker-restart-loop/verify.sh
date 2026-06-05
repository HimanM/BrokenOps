#!/bin/bash

# 1. Check if docker is active
systemctl is-active --quiet docker
if [ $? -ne 0 ]; then
  echo "FAILURE: Docker daemon is not running."
  exit 1
fi

# 2. Wait up to 30 seconds for the web-app container to be created and start running
echo "Waiting for container 'web-app' to be created and start running..."
CONTAINER_READY=false
for i in {1..30}; do
  if docker ps -a --format '{{.Names}}' | grep -q '^web-app$'; then
    STATUS=$(docker inspect -f '{{.State.Status}}' web-app 2>/dev/null)
    if [ "$STATUS" = "running" ]; then
      CONTAINER_READY=true
      break
    fi
  fi
  sleep 1
done

if [ "$CONTAINER_READY" = "false" ]; then
  echo "FAILURE: Container 'web-app' was not created or did not start running in time."
  echo "=== Debug Info ==="
  docker ps -a
  systemctl status web-app --no-pager
  exit 1
fi

# 3. Check if container has healthcheck enabled
HEALTH_CONF=$(docker inspect -f '{{.Config.Healthcheck}}' web-app 2>/dev/null)
if [ -z "$HEALTH_CONF" ] || [ "$HEALTH_CONF" = "<nil>" ]; then
  echo "FAILURE: Container 'web-app' does not have a healthcheck configured."
  exit 1
fi

# 4. Wait for health status to become 'healthy'
echo "Waiting for container health status to become 'healthy'..."
HEALTHY=false
for i in {1..20}; do
  HEALTH=$(docker inspect -f '{{.State.Health.Status}}' web-app 2>/dev/null)
  if [ "$HEALTH" = "healthy" ]; then
    HEALTHY=true
    break
  fi
  sleep 1
done

if [ "$HEALTHY" = "false" ]; then
  echo "FAILURE: Container health status is '$HEALTH' (expected: healthy)."
  exit 1
fi

# 5. Check if the restart loop has stopped (ensure it remains running)
sleep 5
STATUS2=$(docker inspect -f '{{.State.Status}}' web-app)
if [ "$STATUS2" != "running" ]; then
  echo "FAILURE: Container is still unstable or restarting."
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
