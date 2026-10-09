# Journals — private journaling app

Email + password accounts, entries, templates, calendar, PDF export — saved per user in **Supabase**, hosted on **Vercel**.

```
journals-app/
├── public/index.html      the whole app (UI + login + cloud sync)
├── api/config.js          Vercel serverless function: serves the public Supabase settings
├── supabase/schema.sql    database tables + Row Level Security
├── vercel.json            security headers
└── package.json
```

How it works: the browser signs users in with Supabase Auth and reads/writes `entries`, `templates` and `settings`
directly. **Row Level Security** guarantees each user can only ever see their own rows. Your Supabase URL and
anon key live in Vercel environment variables (never in the code) and are handed to the page by `/api/config`.

---

## 1. Create the Supabase project (5 min)

1. Go to https://supabase.com → **New project**. Pick a name, a strong database password and a region near you.
2. Open **SQL Editor → New query**, paste the whole of `supabase/schema.sql`, click **Run**. You should see "Success".
3. Open **Project Settings → API** and copy:
   - **Project URL** → this is `SUPABASE_URL`
   - **anon / publishable key** → this is `SUPABASE_ANON_KEY`
   - ⚠️ Never use the `service_role` / secret key anywhere in this app.

## 2. Push to GitHub

```bash
cd journals-app
git init
git add .
git commit -m "Journals app"
git branch -M main
# create an empty repo on github.com first, then:
git remote add origin https://github.com/YOUR-USERNAME/journals.git
git push -u origin main
```

## 3. Deploy on Vercel

1. https://vercel.com → **Add New → Project** → import your GitHub repo.
2. Framework preset: **Other**. Leave Build Command and Output Directory empty (Vercel serves `public/` and `api/` automatically).
3. Open **Environment Variables** and add (for Production, Preview and Development):
   - `SUPABASE_URL` = your Project URL
   - `SUPABASE_ANON_KEY` = your anon/publishable key
4. Click **Deploy**. If you add the variables after the first deploy, press **Redeploy** so they take effect.

## 4. Tell Supabase your site address

In Supabase → **Authentication → URL Configuration**:
- **Site URL**: `https://YOUR-APP.vercel.app` (your Vercel domain)
- **Redirect URLs**: add `https://YOUR-APP.vercel.app` (and `http://localhost:3000` for local testing)

This makes the confirmation and password-reset emails link back to your app.

## 5. Use it

Open your Vercel URL → **Create an account** → confirm the email (if confirmation is on) → sign in → write.

**Skip the confirmation email while testing:** Supabase → Authentication → Sign In / Providers → Email → turn off *Confirm email*.
Supabase's built-in mailer is rate-limited (a few emails per hour); for real use, add your own SMTP under Authentication → SMTP Settings.

## Run locally (optional)

```bash
cp .env.example .env      # fill in the two values
npx vercel dev            # http://localhost:3000
```

## Notes

- Changes save automatically ~1 second after you stop typing ("Saved to cloud" at the bottom of the page). Closing the tab with unsaved changes shows a warning.
- Signing out saves first, then clears the screen.
- Syncing is last-write-wins and loads at sign-in: if you edit on two devices at once, reload the other one to see the changes.
- Deleting an entry (× in the sidebar) permanently removes it from the database.
- Troubleshooting: *"The app isn't configured yet"* = environment variables missing/redeploy needed. *"database tables are missing"* = run `schema.sql`.
