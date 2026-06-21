# Good and Bad Tests

## Good Tests

**Integration-style**: Test through real interfaces, not mocks of internal parts.

```typescript
// GOOD: Tests observable behavior
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

Characteristics:

- Tests behavior users/callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test

## Bad Tests

**Implementation-detail tests**: Coupled to internal structure.

```typescript
// BAD: Tests implementation details
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

Red flags:

- Mocking internal collaborators
- Testing private methods
- Asserting on call counts/order
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT
- Verifying through external means instead of interface

```typescript
// BAD: Bypasses interface to verify
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: Verifies through interface
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

## Tautological Tests

The expected value — the test's **oracle** — must come from an independent source: the spec, a hand-computed result, or real recorded input/output. Never derive it by running the code under test, and never accept a generated snapshot without checking it's actually correct. A fixture tuned to match the implementation passes by construction — it locks in current behavior, bugs included, and can never go RED for the right reason.

```typescript
// BAD: expected value was copy-pasted from the parser's own output
test("parse handles the sample report", () => {
  expect(parse(report)).toEqual(LAST_RUNS_OUTPUT); // never independently checked
});

// GOOD: oracle is independent — a hand-checked result
test("parse extracts both findings from the sample report", () => {
  expect(parse(report)).toEqual([
    { code: "R3", severity: "high" },
    { code: "T2", severity: "medium" },
  ]);
});
```

Most dangerous when retrofitting tests onto existing code (a characterization test that snapshots whatever it does today) or when a fixture and the code consuming it were authored together — grade the fixture against reality before trusting any test that uses it.

## Property-Based Tests

When the behavior is an **invariant** rather than one concrete case, assert the invariant over generated inputs instead of hardcoded values. This catches edge cases example tests miss and describes WHAT must always hold.

```typescript
// Example test: one case
test("reverse([1,2,3]) is [3,2,1]", () => {
  expect(reverse([1, 2, 3])).toEqual([3, 2, 1]);
});

// Property test: the invariant for all inputs
test("reversing twice returns the original", () => {
  forAll(arrayOf(integers), (xs) => {
    expect(reverse(reverse(xs))).toEqual(xs);
  });
});
```

Good fits: round-trips (`encode`/`decode`), idempotence, commutativity, results that must always satisfy a constraint. Reach for an example test when the expected output is a specific known value, not a rule. Any PBT library works (`forAll`/`arrayOf` above are illustrative).
