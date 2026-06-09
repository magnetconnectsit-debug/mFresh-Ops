# Project Constitution

This repository uses Spec Kit as a spec-first workflow for AI-assisted development.

## Principles

- Define the outcome before implementation.
- Prefer small, scoped changes over broad refactors.
- Keep Flutter apps thin and move reusable logic into shared packages.
- Apply the same spec-first workflow to both `packages/apps/mfresh` and `packages/apps/mfresh_ops`.
- Validate changes with analysis and tests where available.
- Preserve existing behavior unless the spec explicitly changes it.

## Collaboration Rules

- Write specs in plain language first.
- Turn specs into a plan, then into tasks, then into code.
- Call out tradeoffs when a request could affect app behavior, architecture, or release risk.
- Keep the monorepo structure in mind when proposing changes.
