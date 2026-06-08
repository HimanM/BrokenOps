# Contributing to BrokenOps

Thank you for your interest in contributing to BrokenOps. This document
outlines the process for contributing and the standards we expect from all
contributors.

## Bug Reports and Feature Requests

Bugs and feature suggestions should be submitted via [GitHub Issues](https://github.com/HimanM/BrokenOps/issues).
When filing a bug report, please include:

- A clear, descriptive title
- Steps to reproduce the issue
- Expected vs. actual behavior
- Environment details (OS, software versions, etc.)

Feature requests should describe the problem you are trying to solve and the
use case behind it.

## Lab Contribution Workflow

BrokenOps labs live in the `labs/` directory. Each lab is a self-contained
folder with the files described in [LAB_FORMAT.md](LAB_FORMAT.md). Follow
these steps to contribute a new lab:

1. **Fork the repository** on GitHub.
2. **Create a feature branch** from `main`:
   ```bash
   git checkout -b labs/my-new-lab
   ```
3. **Create the lab folder** at `labs/<lab-id>/` and add the required files:
   - `lab.yaml` — lab metadata and VM specification
   - `cloud-init.yaml` — provisioning and intentional break configuration
   - `verify.sh` — score verification script
   - `solution.sh` — automated fix script
   - `question.md` — task description
   - `solution.md` — step-by-step solution guide

   See [LAB_FORMAT.md](LAB_FORMAT.md) for the full specification of each file,
   including required field names and format templates.

4. **Test your lab locally** before opening a pull request:
   ```bash
   python3 scripts/test_labs.py
   ```
   Ensure `verify.sh` passes once the fix from `solution.sh` is applied and
   fails when the environment is in its broken state.

5. **Open a pull request** against `main`. Use the pull request template and
   fill in all requested sections.

## Coding Standards for Bash Scripts

All bash scripts in this repository must follow these standards:

- **Shebang**: Use `#!/bin/bash` at the top of every script. Do not use `#!/bin/sh`.
- **Exit codes**: Scripts must exit with `0` on success and a non-zero value on
  failure. The `verify.sh` script must exit `0` only when the lab is fully
  solved.
- **Error handling**: Use `set -e` and `set -u` at the top of scripts where
  appropriate to catch errors early.
- **Quotes**: Always quote variables containing paths or user-supplied values
  (e.g., `"$VAR"` not `$VAR`).
- **Style**: Prefer `[[ ]]` over `[ ]` for conditionals in new code.

## Pull Request Process

When opening a pull request:

1. Fill out the PR template completely. The template prompts you to describe
   the change, select the type of change, and verify lab requirements.
2. For new labs, ensure all items in the "Lab Requirements" checklist are
   satisfied.
3. Link any related GitHub issue using the "Closes #<id>" syntax.
4. Ensure `scripts/test_labs.py` passes for any new or modified labs.
5. A maintainer will review your PR and may request changes. Be responsive to
   feedback.

## Development Setup

The platform consists of a backend (FastAPI application) and a frontend (React 19 + Vite interface).
Both run inside Docker containers orchestrated by Docker Compose.

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- Python 3.10+ (for running test scripts locally)

### Running the Platform Locally

```bash
./deploy.sh
```

This script builds and starts all containers. The frontend is available at
`http://localhost:80` and the backend is exposed by the FastAPI container.

### Running Tests

```bash
python3 scripts/test_labs.py
```

## Project Structure

```
BrokenOps/
├── labs/                 # All training labs (one folder per lab)
│   └── <lab-id>/
│       ├── lab.yaml
│       ├── cloud-init.yaml
│       ├── verify.sh
│       ├── solution.sh
│       ├── question.md
│       └── solution.md
├── backend/              # FastAPI application
├── frontend/             # React 19 + Vite interface
├── scripts/
│   └── test_labs.py      # Lab validation script
├── deploy.sh             # Docker Compose deployment script
└── LAB_FORMAT.md         # Lab authoring guide
```

## License

By contributing to BrokenOps, you agree that your contributions will be
licensed under the [MIT License](LICENSE).