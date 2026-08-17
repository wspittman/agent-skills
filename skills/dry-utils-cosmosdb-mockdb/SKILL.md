---
name: dry-utils-cosmosdb-mockdb
description: Use when developing code that interacts with dry-utils-cosmosdb and no real Cosmos DB instance is available, such as when writing unit tests or in a container environment. Configure the built-in in-memory database, seed or load fixture data, use its supported query patterns, extend queries with custom handlers, and simulate partition errors.
---

# CosmosDB Mock Database

Use the built-in in-memory database through the normal `dry-utils-cosmosdb` `Container` API. The mock supports the library's common CRUD and query paths, but it is not a complete Cosmos DB emulator.

## When to Use

- Unit Test: You need to unit test functions that rely on Cosmos DB interactions. MockDB provides fast, reliable tests. Use the built-in mocking rather than writing your own mocks.
- Container Environment: You are in an environment where a DB connection isn't possible, such as CI pipelines or agent development containers, but still want to run code that interacts with data.

## Activating MockDB

First, check your environment variables for a way to inject mock configuration.

If you don't have an easy environment variable option, then you can inject directly within the `connectDB` call using the `mockDBData` parameter. The endpoint, key, and database name are unused in mock mode but remain required options.

```typescript
const containers = await connectDB({
  // ...existing config
  // This line activates an empty mock database
  mockDBData: {},
});
```

## Seeding Data

`mockDBData` is `Record<containerName, item[]>`. Each item requires:

- `id` (string)
- The container's `partitionKey` field (string)

Containers omitted from `mockDBData` start empty. Seed only the items needed to reach the state under test.

Use `loadMockDBData` to read a JSON object keyed by container name from an inline string, an absolute file path, or both. Inline data replaces file data for duplicate container names.

```typescript
mockDBData: loadMockDBData({
  mockDataJson: process.env["COSMOS_MOCK_DATA_STRING"],
  mockDataPath: process.env["COSMOS_MOCK_DATA_PATH"],
}),
```

The loader returns `undefined` when both inputs are empty, which does not activate mock mode by itself. Invalid JSON and non-object roots throw descriptive errors.

## Built-In Query Support

The mock handles the query shapes produced by the library's common `Container` methods and `buildQuery`:

- SELECT `*`, `VALUE COUNT(1)`, simple top-level property lists, and the grouped count projection used by `getCountBy`
- parameterized `=`, `>`, `>=`, `<`, `<=`, `IS_DEFINED`, case-insensitive `CONTAINS`, and `IN` filters
- nested `AND` and `OR` groups
- `TOP` and multi-field `ORDER BY`
- `FULLTEXTCONTAINS`, `FULLTEXTCONTAINSALL`, and `FULLTEXTCONTAINSANY` on string fields
- Point-to-Point `ST_DISTANCE(...) <= radius` filters in meters

Nested field paths are supported by filters, ordering, and grouped counts. Full-text matching uses case-insensitive contiguous substrings, and distance uses a Haversine approximation. Do not depend on these approximations for Cosmos DB parity.

## Custom Query Handlers

Use `mockDBFilters` for unsupported WHERE clauses and `mockDBProjects` for unsupported SELECT clauses. Definitions are keyed by container name and take precedence over built-ins. A string matcher must equal the clause text; a regular expression receives its match and capture groups.

Handlers receive the current `items`, query `params` as a name-value map, and `match` for regular-expression matchers. Return the filtered or projected array. Do not rely on unsupported query shapes failing uniformly.

```typescript
interface MockQueryDef {
  matcher: string | RegExp; // matched against the WHERE or SELECT clause text
  fn: (args: {
    items: Item[];
    params: Record<string, JSONValue>;
    match?: RegExpMatchArray; // capture groups when matcher is a RegExp
  }) => unknown[];
}

const mockDBFiltersExample = {
  orders: [
    {
      matcher: /^ARRAY_CONTAINS\(c\.tags,\s*(?<param>@\w+)\)$/i,
      fn: ({ items, params, match }) => {
        const tag = params[match!.groups!["param"]!] as string;
        return items.filter(
          (item) => Array.isArray(item["tags"]) && item["tags"].includes(tag),
        );
      },
    },
  ],
};

const mockDBProjectsExample = {
  users: [
    {
      matcher: "c.id, c.role, UPPER(c.name) AS name", // exact string match
      fn: ({ items }) =>
        items.map((item) => ({
          id: item["id"],
          role: item["role"],
          name: String(item["name"]).toUpperCase(),
        })),
    },
  ],
};
```

## Simulating DB Errors

Seed an item with partition key `"FORCE_ERROR"` to make any operation on that partition throw `{ message: "Error Time" }`.

```typescript
mockDBData: {
  sessions: [{ id: "s1", tenantId: "FORCE_ERROR", token: "abc" }],
}
```
