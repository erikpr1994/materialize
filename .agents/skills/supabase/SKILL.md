---
name: supabase
description: "Supabase client setup, migrations, CLI, database schema design, and RLS security."
---

# Supabase

## Core Principles

1. **Verify against changelog and current docs**: Scan `https://supabase.com/changelog.md` for breaking changes and use MCP `search_docs` for current APIs.
2. **Expose tables to the Data API**: Newly created tables in SQL might require explicit `GRANT` to `anon` and `authenticated` roles to be exposed via the Data API. Always enable RLS on exposed public tables.
3. **Always use RLS**: Enable RLS on every table in `public` or exposed schemas. Create specific policies; do not default everything to a generic `auth.uid()` check.

## Security Checklist

- **JWT claims**: Never use `raw_user_meta_data` for RLS or authorization decisions (it is user-editable). Use `raw_app_meta_data` instead.
- **Service role key**: Never expose the `service_role` or secret key on the client.
- **Views bypass RLS**: In Postgres 15+, use `CREATE VIEW ... WITH (security_invoker = true)`. Otherwise, restrict role permissions or place views in unexposed schemas.
- **UPDATE requires SELECT**: In RLS, UPDATE operations require a matching SELECT policy to locate the rows.
- **Role checks**: Use `TO authenticated` or `TO anon` on the policy instead of checking `auth.role()`.
- **UPDATE checks**: Update policies must define both `USING` (who can update) and `WITH CHECK` (prevents reassigning ownership).
- **Security Definer**: Avoid `SECURITY DEFINER` for resolving permission errors. If used, specify explicit `auth.uid()` checks in the body and keep the function in an unexposed schema.
- **Storage**: Upserting files requires INSERT, SELECT, and UPDATE storage permissions.

## CLI & MCP Reference

- **CLI Usage**: Discover commands via `supabase <command> --help`.
- **Migrations**: Always create migrations via `supabase migration new <name>`.
- **Local DB queries**: Use `execute_sql` (MCP) or `supabase db query` (CLI) to prototype. Generate migrations when done via `supabase db diff` or `supabase db pull <name> --local --yes`.
- **MCP Server troubleshooting**:
  1. Test status: `curl -so /dev/null -w "%{http_code}" https://mcp.supabase.com/mcp` (expects 401).
  2. Verify project `.mcp.json` matches the server URL.
  3. Re-authenticate via the browser OAuth flow if tools are missing.

## Reference Guides

- [Skill Feedback](references/skill-feedback.md)

