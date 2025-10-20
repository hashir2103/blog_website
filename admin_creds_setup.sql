-- Create admin credentials table for your Supabase project
-- Run this SQL in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.creds (
    id TEXT PRIMARY KEY,
    pass TEXT NOT NULL
);

-- Insert a sample admin credential (change these to your desired credentials)
INSERT INTO public.creds (id, pass) 
VALUES ('admin', 'password123')
ON CONFLICT (id) DO NOTHING;

-- Enable Row Level Security (RLS)
ALTER TABLE public.creds ENABLE ROW LEVEL SECURITY;

-- Create policies for admin access (adjust as needed for your security requirements)
CREATE POLICY "Allow public read access to creds" ON public.creds
    FOR SELECT USING (true);

-- Note: You may want to restrict this further in production
-- For example, only allow authenticated users to read credentials
