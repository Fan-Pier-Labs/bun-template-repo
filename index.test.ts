import { test, expect } from "bun:test";

test("should pass a simple test", () => {
  expect(1 + 1).toBe(2);
});

test("should verify basic string operations", () => {
  const message = "Hello via Bun!";
  expect(message).toContain("Bun");
  expect(message.length).toBeGreaterThan(0);
});
