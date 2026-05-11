---
name: dry-utils-cosmosdb-mockdb
description: Use when developing code that interacts with dry-utils-cosmosdb and no real Cosmos DB instance is available, such as when writing unit tests or in a container environment. This skill helps you set up mock databases, seed data, define custom query handlers, simulate errors, and leverage built-in query support.
---

# CosmosDB MockDB

The `dry-utils-cosmosdb` library includes a built-in in-memory mock database for testing and development without a real Cosmos DB instance. All application code runs unchanged against it.

## When to Use

- Unit Test: You need to unit test functions that rely on Cosmos DB interactions. MockDB provides fast, reliable tests. Use the built-in mocking rather than writing your own mocks.
- Container Environment: You are in an environment where a DB connection isn't possible, such as CI pipelines or agent development containers, but still want to run code that interacts with data.

## Activating MockDB

First, check your environment variables for a way to inject mock configuration.

If you don't have an easy environment variable option, then you can inject directly within the `connectDB` call using the `mockDBData` parameter.

```typescript
const containers = await connectDB({
  // ...existing config
  containers: [{ name: "users", partitionKey: "userId" }],
  // Add this to seed mock data at startup:
  mockDBData: {
    users: [
      { id: "1", userId: "alice", role: "admin", status: "active" },
      { id: "2", userId: "bob", role: "viewer", status: "suspended" },
    ],
  },
});
```

## Seeding Data

`mockDBData` is `Record<containerName, item[]>`. Each item requires:

- `id` (string)
- the container's `partitionKey` field (string)

Containers omitted from `mockDBData` start empty. Seed only the items needed to reach the state under test.

## Built-In Query Support

All query patterns from `Container` methods and the `Query` builder work without extra configuration.

**SELECT:** `*`, `VALUE COUNT(1)`, `c.field, c.field, ...`, `c.{prop} AS name, COUNT(1) AS count`

**WHERE:** `=`, `>`, `>=`, `<`, `<=`, `CONTAINS(c.field, @p, true)`, `IS_DEFINED(c.field)`, multiple conditions with `AND`

If a query falls outside these patterns the mock throws: `Query did not match supported mocking pattern`.

## Custom Query Handlers

Use `mockDBFilters` (WHERE) or `mockDBProjects` (SELECT) for unsupported query patterns. Both are `Record<containerName, MockQueryDef[]>`. Custom matchers run before built-ins.

```typescript
interface MockQueryDef {
  matcher: string | RegExp; // matched against the WHERE or SELECT clause text
  fn: (args: {
    items: Item[];
    params: Record<string, JSONValue>;
    match?: RegExpMatchArray; // capture groups when matcher is a RegExp
  }) => unknown[];
}
```

Custom WHERE (`mockDBFilters`) example:

```typescript
mockDBFilters: {
  orders: [{
    matcher: /^ARRAY_CONTAINS\(c\.tags,\s*(?<param>@\w+)\)$/i,
    fn: ({ items, params, match }) => {
      const tag = params[match!.groups!["param"]!] as string;
      return items.filter(
        (item) => Array.isArray(item["tags"]) && (item["tags"] as string[]).includes(tag),
      );
    },
  }],
},
```

Custom SELECT (`mockDBProjects`) example:

```typescript
mockDBProjects: {
  users: [{
    matcher: "c.id, c.role, UPPER(c.name) AS name",  // exact string match
    fn: ({ items }) =>
      items.map((item) => ({
        id:   item["id"],
        role: item["role"],
        name: String(item["name"]).toUpperCase(),
      })),
  }],
},
```

## Simulating DB Errors

Seed an item with partition key `"FORCE_ERROR"` to make any operation on that partition throw `{ message: "Error Time" }`.

```typescript
mockDBData: {
  sessions: [{ id: "s1", tenantId: "FORCE_ERROR", token: "abc" }],
}
```
