# node:test style reference

Use this reference when editing unit tests in the `node:test` framework.

## Framework and primitives

- Import `assert` from `node:assert/strict`.
- Import `suite`, `test`, and any needed helpers from `node:test`.
- Use `mock.fn`, `mock.method`, and `context.mock.timers` instead of third-party mocking libraries.

## Preferred structure

- Group tests with `suite(...)`.
- Prefer dense, table-driven cases over many small bespoke tests
  - Lean on arrays plus `forEach(...)` when several variants exercise the same behavior.
  - This is used even when the case matrix gets fairly large or slightly hard to scan.
- Generate practical test names from case data when that keeps the file compact.
  - It is normal to build names from inputs
  - Example: test(`Invalid TOKEN: "${name}"`, ...)
- Reuse suite-level mocks and reset calls in `beforeEach` rather than rebuilding them in every test.
- Look for a shared `test/setup.ts` file for common environment stubs and helpers. Keep new tests compatible with existing defaults, adding to it when appropriate.

## Fixtures and helpers

- Keep helpers file-local: `mockRequest`, `validator`, `formatter`, `waitFor`, `mockTimers`.
- For ExpressJS servers
  - Mock only the request/response surface that the middleware or utility actually touches.
  - Cast lightweight object literals to `Request` or `Response` when needed instead of building full Express objects. Example: `{ json: jsonFn } as unknown as Response`

## Assertions

- Prefer `assert.equal`, `assert.deepEqual`, `assert.ok`, `assert.throws`, and `assert.rejects`.
- Inspect `mock.calls` directly for argument assertions.
- Assert exact outputs for transformation helpers instead of partial matcher-style checks.
- On error paths, verify the key behavior only: `next(...)` call count, error type, message, or status code.

## Async and timing behavior

- Use `context.mock.timers.enable({ apis: ["setTimeout"] })` for timer-driven code.
- Pair timer ticks with `await timers.setImmediate()` so pending callbacks flush.
- When timer mocking is awkward, a small polling helper such as `waitFor(...)` is acceptable.

## Non-idiomatic but accepted local patterns

- Mechanical test names are fine if they clearly identify the case.
- Slightly dense case matrices are preferred over many repetitive test blocks.
- It is acceptable to skip re-testing validator or logging behavior when another nearby suite already covers it.
