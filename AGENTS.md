# AGENTS.md

## Project overview

BrokenOps is an interactive DevOps and sysadmin training platform. It runs a
FastAPI backend, a React/Vite frontend, and intentionally broken Linux lab VMs
defined under `labs/`.

The platform depends on native Linux KVM/libvirt. Do not assume WSL2, Docker
Desktop, or nested virtualization can run the full VM workflow.

## Repository layout

- `backend/`: FastAPI app, lab parsing, cloud-init generation, and libvirt VM
  orchestration.
- `frontend/`: React 19 + Vite UI, including the lab dashboard, terminal view,
  and standalone terminal route.
- `labs/<lab-id>/`: one lab per directory. Each lab should include
  `lab.yaml`, `cloud-init.yaml`, `verify.sh`, `solution.sh`, `question.md`, and
  `solution.md`.
- `scripts/test_labs.py`: CI-style lab verification against launched VMs.
- `.github/workflows/ci-verify-labs.yml`: verifies changed labs in pull
  requests.

## Development commands

- Frontend install: `cd frontend && npm install`
- Frontend lint: `cd frontend && npm run lint`
- Frontend build: `cd frontend && npm run build`
- Full local stack: `./deploy.sh`
- Changed lab CI flow: `.github/workflows/ci-verify-labs.yml`
- Lab verification after the stack is running:
  `python scripts/test_labs.py --key keys/id_ed25519 --labs <lab-id>`

If a task touches frontend code, run lint and build when possible. If a task
touches lab definitions, run the affected lab verification when KVM/libvirt is
available. If the environment cannot run KVM/libvirt, say so explicitly and
still run any static checks that apply.

## Lab authoring rules

- Keep each lab self-contained under `labs/<lab-id>/`.
- `lab.yaml` must use an `id` matching the folder name.
- `cloud-init.yaml` creates the broken initial state.
- `verify.sh` must fail before the solution and exit `0` only when the lab is
  fully fixed.
- `solution.sh` must be executable in a non-interactive root shell and should
  make the smallest practical fix.
- `question.md` should describe the scenario, objective, and useful commands
  without revealing the answer.
- `solution.md` should explain the root cause and provide clear fix steps.
- When adding exposed ports, set `port_works_initially` in `lab.yaml` only when
  CI should expect the port to return HTTP 200 before the solution.

## Backend rules

- Preserve the existing FastAPI route shapes unless the issue asks for an API
  change.
- Treat lab IDs, file paths, and VM names as untrusted input. Keep path
  handling constrained to the project/lab directories.
- Be careful around cleanup and VM lifecycle code; avoid leaving orphaned VMs,
  overlays, or ready files.
- Prefer explicit errors for missing base images, labs, and VM startup failures.

## Frontend rules

- Keep the app as a usable tool, not a marketing page.
- Match the existing routes and component structure.
- Keep terminal behavior stable; avoid remounting the terminal unless the lab
  session truly changed.
- Use existing dependencies and lucide-react icons where appropriate.
- Verify responsive layout for dashboard and lab pages when UI changes are made.

## Review guidelines

- Prioritize issues that can break VM launch, SSH access, lab verification,
  filesystem safety, or GitHub CI.
- Flag any change that makes labs pass before the solution runs.
- Flag path traversal, unsafe shell construction, leaked keys, or accidental
  exposure of solution content.
- Flag frontend changes that make the terminal unusable, hide verification
  results, or break lab navigation.
- Treat missing or stale verification steps as a serious review concern when
  behavior changes.

## GitHub/Codex usage notes

- Use `@codex review` in a pull request comment to request a Codex review after
  Codex code review is enabled for this repository.
- Use `@codex <task>` in a pull request comment to ask Codex cloud to work on
  that PR, for example `@codex fix the CI failures`.
- For issue-based work, include clear reproduction steps, expected behavior,
  relevant files or lab IDs, and the checks Codex should run.
