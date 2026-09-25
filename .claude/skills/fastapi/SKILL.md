---
name: fastapi
description: FastAPI engineering guidance. Use when the repository uses FastAPI or the task changes FastAPI routes, dependencies, schemas, middleware, or application startup.
---

# FastAPI Engineering Rules

Load only when FastAPI is actually in use.

## MUST

- Validate request data at the API boundary.
- Keep business logic out of route handlers.
- Keep response models explicit for public endpoints.
- Reuse established dependency injection patterns in the project.

## PREFER

- Thin route handlers and testable service/domain functions.
- Explicit error mapping at API boundaries.
- API tests for externally observable behavior.

## AVOID

- Hidden database or network calls in validation code.
- Route handlers that own business workflows.
- Adding a new dependency pattern when the codebase already has one.
