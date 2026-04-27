export default ({ defineStep }) => [
  defineStep('I select {string} from the {string} dropdown', async (ctx, option, label) => {
    await ctx.page.getByLabel(label).click();
    const listbox = ctx.page.locator('[role="listbox"]');
    await listbox.waitFor({ timeout: 5000 });
    await listbox.locator('[role="option"]').filter({ hasText: option }).click();
  }),

  // Wait for the URL to match a regex pattern, then settle — needed after async Redux redirects
  // where the URL changes client-side before the subsequent API fetches begin.
  defineStep('I wait for the URL to match {string}', async (ctx, pattern) => {
    await ctx.page.waitForURL(new RegExp(pattern), { timeout: 10000 });
    await ctx.page.waitForLoadState('networkidle', { timeout: 10000 });
  }),
];
