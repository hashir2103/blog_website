-- Create blog_posts table for your Supabase project
-- Run this SQL in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.blog_posts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('economic', 'tech', 'entertainment', 'health')),
    image_url TEXT DEFAULT '',
    publish_date TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_blog_posts_category ON public.blog_posts(category);
CREATE INDEX IF NOT EXISTS idx_blog_posts_publish_date ON public.blog_posts(publish_date DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.blog_posts ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (adjust as needed for your security requirements)
CREATE POLICY "Allow public read access to blog posts" ON public.blog_posts
    FOR SELECT USING (true);

CREATE POLICY "Allow public insert access to blog posts" ON public.blog_posts
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public update access to blog posts" ON public.blog_posts
    FOR UPDATE USING (true);

CREATE POLICY "Allow public delete access to blog posts" ON public.blog_posts
    FOR DELETE USING (true);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to automatically update the updated_at column
CREATE TRIGGER handle_blog_posts_updated_at
    BEFORE UPDATE ON public.blog_posts
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- Create storage policies for BlogBucket
CREATE POLICY "Allow public read access to BlogBucket" ON storage.objects
    FOR SELECT USING (bucket_id = 'BlogBucket');

CREATE POLICY "Allow public upload to BlogBucket" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'BlogBucket');

CREATE POLICY "Allow public update to BlogBucket" ON storage.objects
    FOR UPDATE USING (bucket_id = 'BlogBucket');

CREATE POLICY "Allow public delete from BlogBucket" ON storage.objects
    FOR DELETE USING (bucket_id = 'BlogBucket');
