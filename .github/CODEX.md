# Codex setup for BrokenOps

This repository includes a top-level `AGENTS.md` file so Codex has project
context when it works in Codex cloud or reviews pull requests.

## Enable Codex for the repository

1. Set up Codex cloud for this GitHub repository in ChatGPT/Codex settings.
2. Enable Codex code review for the repository at
   `https://chatgpt.com/codex/settings/code-review`.
3. Confirm Codex has permission to read the repository and, if you want it to
   push fixes, write to branches or open pull requests.

## Ask Codex to review or fix work

- In a pull request comment, use `@codex review` to request a review.
- In a pull request comment, use `@codex fix the CI failures` or another clear
  task to start a Codex cloud task with that PR as context.
- For issues, write the issue with reproduction steps, expected behavior,
  affected files or lab IDs, and the checks to run. Then ask Codex from the PR
  that implements the issue, or start a Codex cloud task from the repository
  and point it at the issue.

## Suggested cloud environment setup

Codex cloud setup scripts run before the agent starts. Use them for dependency
installation, but remember the full BrokenOps VM workflow needs Linux with
KVM/libvirt access.

Useful setup script:

```bash
cd frontend
npm ci
cd ..
python -m pip install --upgrade pip
python -m pip install fastapi uvicorn pydantic pyyaml httpx asyncssh requests paramiko
```

Useful maintenance script:

```bash
cd frontend
npm ci
```

When KVM/libvirt is unavailable in Codex cloud, ask Codex to run static checks
such as:

```bash
cd frontend && npm run lint && npm run build
```

For lab changes, Codex should still inspect `lab.yaml`, `cloud-init.yaml`,
`verify.sh`, `solution.sh`, `question.md`, and `solution.md` together, even if
it cannot boot the VM.
