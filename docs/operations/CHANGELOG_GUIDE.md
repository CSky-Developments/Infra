# Changelog & Contribution Guide

## Why does this exist?
To guarantee that the infrastructure repository maintains a clean, searchable, and logical history of changes over the lifetime of the platform.

## When should it be used?
Before committing any changes to the `infra` repository or modifying documentation.

## How does it work?
We strictly enforce Conventional Commits. Every commit must describe *what* changed and implicitly *why*, grouped logically by impact.

## Standards

### 1. Conventional Commits
Format: `<type>: <description>`
- `feat:` A new infrastructure feature (e.g., adding a new script or network).
- `fix:` A bug fix (e.g., fixing a permission issue in a script).
- `docs:` Documentation changes only.
- `chore:` Maintenance tasks, refactoring, or minor tweaks without functional impact.

### 2. Branch Strategy
- Commits can be pushed directly to `main` for hotfixes or minor docs.
- Major architectural changes should be drafted on a branch and reviewed before merging.

### 3. Documentation Standards
- **Wiki Format**: Every new document in `docs/` MUST include the following headers:
  - Why does this exist?
  - When should it be used?
  - How does it work?
  - Step-by-Step Instructions
  - Common Mistakes
  - Troubleshooting
  - Related Documentation

### 4. Updating the State Tracker
If a commit completes a pending action, `docs/STATE.md` must be updated in the same commit to reflect the new reality.

## Common Mistakes
- Bundling a `feat` and a `docs` update into a single commit called "updates". Separate them logically.

## Related Documentation
- [Architecture & History](ARCHITECTURE.md)
