# Refactor Candidates

At each green, within the reach of the test you just passed:

- **Duplication** → Extract function/class
- **Long methods** → Break into private helpers (keep tests on public interface)
- **Feature envy** → Move logic to where data lives

Once every behavior is in — these need the whole shape in view:

- **Shallow modules** → Combine or deepen
- **Primitive obsession** → Introduce value objects
- **Existing code** the new code reveals as problematic
