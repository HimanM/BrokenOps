### Scenario
A container image stopped building after a refactor changed the artifact path in a multi-stage Dockerfile.

### Objective
Fix the Dockerfile so the final image can be built and run successfully again.

### Useful Commands
- `docker build .`
- `docker run --rm <image>`
- `sed -n '1,120p' Dockerfile`
