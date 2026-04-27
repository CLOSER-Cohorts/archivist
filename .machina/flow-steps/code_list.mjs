export default ({ defineStep }) => [
  // Fill in the code list's own label field (textarea[name="label"]).
  // Uses a direct name selector to avoid ambiguity with code-row label inputs.
  defineStep('I fill in the code list label with {string}', async (ctx, value) => {
    await ctx.page.locator('textarea[name="label"], input[name="label"]').first().waitFor({ timeout: 10000 });
    await ctx.page.locator('textarea[name="label"], input[name="label"]').first().fill(value);
  }),

  // Fill in the code list label with a value that includes a timestamp suffix so each
  // test run creates a distinct code list (avoids uniqueness-per-instrument constraint).
  defineStep('I fill in the code list label with {string} and a unique suffix', async (ctx, base) => {
    const label = `${base}-${Date.now()}`;
    const field = ctx.page.locator('textarea[name="label"], input[name="label"]').first();
    await field.waitFor({ timeout: 10000 });
    await field.fill(label);
  }),

  // Fill in the value and label for a specific code row (1-indexed).
  // Uses react-final-form FieldArray names: codes[N].value (textarea) and codes[N].label (input).
  defineStep('I fill in the code row {int} with value {string} and label {string}', async (ctx, row, value, label) => {
    const idx = row - 1;
    await ctx.page.locator(`textarea[name="codes[${idx}].value"]`).fill(value);
    const labelInput = ctx.page.locator(`input[name="codes[${idx}].label"]`);
    await labelInput.fill(label);
    await labelInput.press('Tab');
  }),

  // Wait for the codes table to show at least one row — confirms the code list data has loaded
  // after a redirect (React fetches asynchronously after the URL changes).
  defineStep('I wait for the code list to load', async (ctx) => {
    await ctx.page.locator('table tbody tr').first().waitFor({ timeout: 10000 });
  }),

  // Assert the label input value for a specific code row (1-indexed).
  // Category labels render inside MUI Autocomplete inputs, not as text nodes, so we read inputValue.
  defineStep('the code row {int} should have label {string}', async (ctx, row, label) => {
    const input = ctx.page.locator(`input[name="codes[${row - 1}].label"]`);
    await input.waitFor({ timeout: 5000 });
    const actual = await input.inputValue();
    if (actual !== label) throw new Error(`Expected code row ${row} label "${label}" but got "${actual}"`);
  }),

  // Click the add-code button (aria-label="Add code") that sits next to the "Codes" heading.
  // The button only renders once instrument data has loaded, so we wait for it.
  defineStep('I click the add code button', async (ctx) => {
    const addBtn = ctx.page.locator('button[aria-label="Add code"]');
    await addBtn.waitFor({ timeout: 10000 });
    await addBtn.click();
  }),
];
