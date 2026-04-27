export default ({ defineStep }) => [
  // Asserts that an <input> or <textarea> on the page has the given display value.
  // Use this when the value is rendered in a form field rather than as a visible text node.
  defineStep('I should see input with value {string}', async (ctx, value) => {
    await ctx.page.waitForFunction(
      (v) => {
        const inputs = document.querySelectorAll('input, textarea');
        return Array.from(inputs).some(el => el.value === v);
      },
      value,
      { timeout: 10000 }
    );
  }),

  // Clicks a named item in the BuildContainer list (MUI ListItemText — not a button or link).
  defineStep('I click on the list item {string}', async (ctx, text) => {
    const item = ctx.page.locator('li').filter({ hasText: text }).first();
    await item.waitFor({ timeout: 5000 });
    await item.click();
  }),

  // Targets the SVG directly so the step works on both patched (IconButton) and
  // unpatched (plain span) code — on unpatched, the click is a no-op and the row stays.
  defineStep('I click the first trash icon on the code list', async (ctx) => {
    const icon = ctx.page.locator('table tbody tr:first-child td:last-child svg').first();
    await icon.waitFor({ timeout: 5000 });
    await icon.click();
  }),

  // Adds a new code row, fills in value and label (via autocomplete), and selects the matching option.
  // Requires the instrument to have a category with the given label already loaded.
  defineStep('I add a code with value {string} and label {string}', async (ctx, value, label) => {
    await ctx.page.locator('button[aria-label="Add code"]').click();
    await ctx.page.waitForTimeout(500);

    const valueInputs = ctx.page.locator('textarea[name*=".value"]');
    await valueInputs.last().fill(value);

    const labelInputs = ctx.page.locator('input[name*=".label"]');
    await labelInputs.last().fill(label);
    await ctx.page.waitForSelector('[role="listbox"]', { timeout: 5000 });
    await ctx.page.locator('[role="option"]').filter({ hasText: new RegExp('^' + label + '$') }).first().click();
  }),
];
