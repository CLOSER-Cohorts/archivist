// Project-custom auth steps for Archivist.
//
// Archivist has no /__test__/login backdoor today, so these steps drive
// the real Devise-backed React login form. Credentials must correspond
// to a user that exists in the local dev DB.

export default ({ defineStep }) => [
  defineStep(
    'I log in as {string} with password {string}',
    async (ctx, email, password) => {
      const base = ctx.config.base_url.replace(/\/$/, '');
      await ctx.page.goto(`${base}/login`);
      await ctx.page.locator('input[name="email"]').fill(email);
      await ctx.page.locator('input[name="password"]').fill(password);

      const signInResponse = ctx.page.waitForResponse(
        (r) => r.url().includes('/users/sign_in'),
        { timeout: 10000 }
      );
      await ctx.page.locator('button[type="submit"]').click();
      await signInResponse;

      await ctx.page.waitForURL(
        (url) => !url.pathname.startsWith('/login'),
        { timeout: 15000 }
      );
    }
  ),

  // Wait for any in-flight XHR/fetch to finish + any client-side redirects
  // to settle. Use before URL assertions when the app may redirect after
  // an async API response (e.g. axios 404 interceptor).
  defineStep('I wait for the page to settle', async (ctx) => {
    await ctx.page.waitForLoadState('networkidle', { timeout: 10000 });
  }),
];
