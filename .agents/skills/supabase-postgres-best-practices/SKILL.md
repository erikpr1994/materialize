---
name: supabase-postgres-best-practices
description: "Postgres optimization guide (query performance, connections, locking, indexes, schema)."
---

# Supabase Postgres Best Practices

Postgres performance optimization rules prioritized by impact. Refer to individual rule files for details.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Reference Files |
|----------|----------|--------|--------|-----------------|
| 1 | Query Performance | CRITICAL | `query-` | `query-missing-indexes.md`, `query-covering-indexes.md`, `query-composite-indexes.md`, `query-partial-indexes.md`, `query-index-types.md` |
| 2 | Connection Management | CRITICAL | `conn-` | `conn-pooling.md`, `conn-limits.md`, `conn-idle-timeout.md`, `conn-prepared-statements.md` |
| 3 | Security & RLS | CRITICAL | `security-` | `security-rls-basics.md`, `security-rls-performance.md`, `security-privileges.md` |
| 4 | Schema Design | HIGH | `schema-` | `schema-primary-keys.md`, `schema-constraints.md`, `schema-foreign-key-indexes.md`, `schema-lowercase-identifiers.md`, `schema-data-types.md`, `schema-partitioning.md` |
| 5 | Concurrency & Locking | MEDIUM-HIGH | `lock-` | `lock-deadlock-prevention.md`, `lock-short-transactions.md`, `lock-advisory.md`, `lock-skip-locked.md` |
| 6 | Data Access Patterns | MEDIUM | `data-` | `data-n-plus-one.md`, `data-batch-inserts.md`, `data-upsert.md`, `data-pagination.md` |
| 7 | Monitoring & Diagnostics | LOW-MEDIUM | `monitor-` | `monitor-explain-analyze.md`, `monitor-pg-stat-statements.md`, `monitor-vacuum-analyze.md` |
| 8 | Advanced Features | LOW | `advanced-` | `advanced-full-text-search.md`, `advanced-jsonb-indexing.md` |

## References
- [Postgres Docs](https://www.postgresql.org/docs/current/)
- [Supabase Docs](https://supabase.com/docs)

