-- ==========================================
-- SETUP SUPABASE AUTH FOR ADMIN
-- ==========================================

-- Step 1: Create admin user
-- You can also do this through Supabase Dashboard > Authentication > Add User
-- For manual SQL creation, you'll need to use the dashboard instead
-- But here's how to verify if a user exists:

-- To create admin user, go to:
-- Supabase Dashboard > Authentication > Users > Add User
-- Email: admin@hbtnews.com (or your preferred email)
-- Password: [Your secure password]
-- Auto Confirm User: YES

-- ==========================================
-- SETUP RLS POLICIES WITH AUTHENTICATION
-- ==========================================

-- Drop all existing policies first
DROP POLICY IF EXISTS "Allow public read access to blog posts" ON public.blog_posts;
DROP POLICY IF EXISTS "Allow public INSERT on blog_posts" ON public.blog_posts;
DROP POLICY IF EXISTS "Allow public UPDATE on blog_posts" ON public.blog_posts;
DROP POLICY IF EXISTS "Allow public DELETE on blog_posts" ON public.blog_posts;
DROP POLICY IF EXISTS "Allow authenticated users to insert blog posts" ON public.blog_posts;
DROP POLICY IF EXISTS "Allow authenticated users to update blog posts" ON public.blog_posts;
DROP POLICY IF EXISTS "Allow authenticated users to delete blog posts" ON public.blog_posts;

DROP POLICY IF EXISTS "Allow public read access to blog images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public SELECT on storage" ON storage.objects;
DROP POLICY IF EXISTS "Allow public INSERT on storage" ON storage.objects;
DROP POLICY IF EXISTS "Allow public UPDATE on storage" ON storage.objects;
DROP POLICY IF EXISTS "Allow public DELETE on storage" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to upload blog images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to update blog images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to delete blog images" ON storage.objects;

-- ==========================================
-- BLOG_POSTS TABLE POLICIES
-- ==========================================

-- Enable RLS
ALTER TABLE public.blog_posts ENABLE ROW LEVEL SECURITY;

-- Allow everyone to read blog posts (public can view)
CREATE POLICY "Public can read blog posts" 
ON public.blog_posts
FOR SELECT 
USING (true);

-- Only authenticated users can create posts
CREATE POLICY "Authenticated users can create posts" 
ON public.blog_posts
FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

-- Only authenticated users can update posts
CREATE POLICY "Authenticated users can update posts" 
ON public.blog_posts
FOR UPDATE 
USING (auth.role() = 'authenticated');

-- Only authenticated users can delete posts
CREATE POLICY "Authenticated users can delete posts" 
ON public.blog_posts
FOR DELETE 
USING (auth.role() = 'authenticated');

-- ==========================================
-- STORAGE POLICIES (blog-images bucket)
-- ==========================================

-- Allow everyone to view images (public can see)
CREATE POLICY "Public can view blog images" 
ON storage.objects
FOR SELECT 
USING (bucket_id = 'blog-images');

-- Only authenticated users can upload images
CREATE POLICY "Authenticated users can upload images" 
ON storage.objects
FOR INSERT 
WITH CHECK (
    bucket_id = 'blog-images' 
    AND auth.role() = 'authenticated'
);

-- Only authenticated users can update images
CREATE POLICY "Authenticated users can update images" 
ON storage.objects
FOR UPDATE 
USING (
    bucket_id = 'blog-images' 
    AND auth.role() = 'authenticated'
);

-- Only authenticated users can delete images
CREATE POLICY "Authenticated users can delete images" 
ON storage.objects
FOR DELETE 
USING (
    bucket_id = 'blog-images' 
    AND auth.role() = 'authenticated'
);

-- ==========================================
-- OPTIONAL: Drop the old creds table (no longer needed)
-- ==========================================

-- Uncomment if you want to remove the old custom auth table
-- DROP TABLE IF EXISTS public.creds;

-- ==========================================
-- VERIFICATION QUERIES
-- ==========================================

-- Check if RLS is enabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'blog_posts';

-- List all policies
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE tablename IN ('blog_posts');

