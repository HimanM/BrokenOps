### Scenario
The container starts, but the Open Port path cannot reach it because the service only listens on localhost inside the container.

### Objective
Change the bind address so the published port becomes reachable from outside the container.

### Useful Commands
- `docker build .`
- `docker run -d -p 8080:8080 <image>`
- `curl http://127.0.0.1:8080/`
- `docker logs <container>`
