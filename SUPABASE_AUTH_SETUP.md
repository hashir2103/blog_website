# Supabase Authentication Setup Guide

## What Changed?

Your blog app now uses **Supabase Authentication** instead of a custom `creds` table. This provides:
- ✅ Proper security with Row Level Security (RLS)
- ✅ Built-in session management
- ✅ Better protection against unauthorized access

---

## Setup Steps

### Step 1: Run SQL in Supabase Cloud

Go to **Supabase Dashboard** → **SQL Editor** → **New Query**

Paste and run the SQL from `setup_supabase_auth.sql`:

```sql
-- See the setup_supabase_auth.sql file for full SQL
```

This will:
- Set up proper RLS policies
- Allow public to read blog posts (view website)
- Require authentication to create/edit/delete posts

---

### Step 2: Create Admin User

Go to **Supabase Dashboard** → **Authentication** → **Users**

Click **"Add User"** and fill in:
- **Email:** `admin@hbtnews.com` (or your preferred email)
- **Password:** Choose a strong password (remember it!)
- **Auto Confirm User:** ✅ YES (check this box)

Click **"Create User"**

---

### Step 3: Update Web Configuration

Open `lib/supabase_config.dart` and you'll see it uses `.env` for local development.

**For web deployment (GitHub Pages), you need to either:**

**Option A: Hardcode credentials (simplest)**
```dart
// In lib/supabase_config.dart
static Future<void> initialize() async {
  const supabaseUrl = 'https://your-project.supabase.co';
  const supabaseAnonKey = 'your-anon-key-here';
  
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}
```

**Option B: Use build-time environment variables** (more secure)
```bash
flutter build web --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-key
```

---

### Step 4: Import Your Blog Posts

Go to **Supabase Dashboard** → **SQL Editor** → **New Query**

1. Open `blog_posts_data.sql` in your code editor
2. Copy ALL the content
3. Paste into SQL Editor
4. Click **Run**

Your blog posts will be imported!

---

### Step 5: Test Locally

1. Make sure your `.env` file has:
```env
supabase_url=https://your-project.supabase.co
anon_key=your-anon-key-here
```

2. Run the app:
```bash
flutter run -d chrome
```

3. Try logging in with the email and password you created in Step 2

---

### Step 6: Deploy to GitHub Pages

1. Rebuild with proper configuration (see Step 3)
2. Commit and push:
```bash
cd build/web
git add .
git commit -m "Update to Supabase Auth"
git push
```

---

## How to Use

### Admin Login
1. Go to your website
2. Click the edit icon (✏️) in the top right
3. Enter your admin **email** (not ID anymore!)
4. Enter your password
5. You're logged in! ✅

### Create/Edit Posts
- Once logged in, you can create, edit, and delete blog posts
- Only authenticated admins can do this
- Public users can only view posts

### Logout
- Click the logout icon (🚪) in the top right when you're done

---

## Security Notes

⚠️ **Important:**
- Your `anon` key is visible in the web build JavaScript - this is normal
- The security comes from RLS policies, not hiding the key
- RLS ensures only authenticated users can modify data
- Public users can only read blog posts

✅ **Your data is secure because:**
- Only logged-in admins can create/edit/delete posts
- Everyone can view posts (which is what you want for a public blog)
- Supabase handles authentication tokens securely

---

## Troubleshooting

### "Failed to create post"
- Make sure you're logged in as admin
- Check browser console (F12) for error messages
- Verify RLS policies are set up (Step 1)

### "Invalid credentials"
- Double-check the email and password
- Make sure you created the user in Supabase Dashboard
- Make sure "Auto Confirm User" was checked

### "Blank screen on GitHub Pages"
- Make sure you hardcoded the credentials for web (Step 3, Option A)
- Or use build-time environment variables (Step 3, Option B)
- The `.env` file doesn't work for web builds!

---

## Old vs New Login

| Old System | New System |
|------------|------------|
| Custom `creds` table | Supabase Auth |
| Admin ID + Password | Email + Password |
| Manual verification | Built-in auth |
| Less secure | More secure |
| No session management | Automatic sessions |

---

## Need Help?

1. Check the Supabase logs: Dashboard → Logs
2. Check browser console: Press F12
3. Verify you completed all setup steps above

Good luck! 🚀

