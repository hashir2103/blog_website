-- Create blog_posts table
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

-- Create an index on category for faster queries
CREATE INDEX IF NOT EXISTS idx_blog_posts_category ON public.blog_posts(category);

-- Create an index on publish_date for faster ordering
CREATE INDEX IF NOT EXISTS idx_blog_posts_publish_date ON public.blog_posts(publish_date DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.blog_posts ENABLE ROW LEVEL SECURITY;

-- Create a policy that allows everyone to read blog posts
CREATE POLICY "Allow public read access to blog posts" ON public.blog_posts
    FOR SELECT USING (true);

-- Create a policy that allows authenticated users to insert blog posts
CREATE POLICY "Allow authenticated users to insert blog posts" ON public.blog_posts
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Create a policy that allows authenticated users to update their own blog posts
CREATE POLICY "Allow authenticated users to update blog posts" ON public.blog_posts
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Create a policy that allows authenticated users to delete blog posts
CREATE POLICY "Allow authenticated users to delete blog posts" ON public.blog_posts
    FOR DELETE USING (auth.role() = 'authenticated');

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
