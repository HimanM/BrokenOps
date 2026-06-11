### Scenario
A container image builds, but the application exits right away because the default command still uses an obsolete flag name.

### Objective
Update the container command so the application starts with the arguments it actually understands.

### Useful Commands
- `docker build .`
- `docker run --rm <image>`
- `docker inspect <image>`
