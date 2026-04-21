export default ({ defineStep }) => [
  defineStep('I select {string} from the {string} dropdown', async (ctx, option, label) => {
    await ctx.page.getByLabel(label).click();
    const listbox = ctx.page.locator('[role="listbox"]');
    await listbox.waitFor({ timeout: 5000 });
    await listbox.locator('[role="option"]').filter({ hasText: option }).click();
  }),
];
