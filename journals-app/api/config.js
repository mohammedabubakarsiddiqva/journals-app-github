// Vercel serverless function: hands the *public* Supabase settings to the browser.
// Set SUPABASE_URL and SUPABASE_ANON_KEY in Vercel -> Project -> Settings -> Environment Variables.
// (The anon/publishable key is designed to be public; Row Level Security protects the data.)
module.exports = (req, res) => {
  const url = process.env.SUPABASE_URL;
  const anonKey = process.env.SUPABASE_ANON_KEY;
  res.setHeader("Cache-Control", "no-store");
  if (!url || !anonKey) {
    return res.status(500).json({ error: "Missing SUPABASE_URL or SUPABASE_ANON_KEY" });
  }
  return res.status(200).json({ url, anonKey });
};
