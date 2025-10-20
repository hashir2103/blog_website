#!/usr/bin/env python3
"""
Python script to create the blog_posts table in Supabase
Run this script to set up your database table locally
"""

import psycopg2
import sys
from datetime import datetime

# Supabase local connection details
DB_CONFIG = {
    'host': '127.0.0.1',
    'port': 54322,  # Supabase local DB port
    'database': 'postgres',
    'user': 'postgres',
    'password': 'postgres'  # Default Supabase local password
}

def create_blog_table():
    """Create the blog_posts table with proper structure and policies"""
    
    # SQL to create the table
    create_table_sql = """
    CREATE TABLE IF NOT EXISTS public.blog_posts (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        title TEXT NOT NULL,
        category TEXT NOT NULL CHECK (category IN ('economic', 'tech', 'newArrivals')),
        content TEXT NOT NULL,
        image_url TEXT DEFAULT '',
        created_at TIMESTAMP DEFAULT NOW()
    );
    """
    
    # SQL to create indexes for better performance
    create_indexes_sql = [
        "CREATE INDEX IF NOT EXISTS idx_blog_posts_category ON public.blog_posts(category);",
        "CREATE INDEX IF NOT EXISTS idx_blog_posts_created_at ON public.blog_posts(created_at DESC);"
    ]
    
    # SQL to enable Row Level Security
    enable_rls_sql = "ALTER TABLE public.blog_posts ENABLE ROW LEVEL SECURITY;"
    
    # SQL to create RLS policies
    create_policies_sql = [
        """CREATE POLICY "Allow public read access to blog posts" ON public.blog_posts
           FOR SELECT USING (true);""",
        """CREATE POLICY "Allow authenticated users to insert blog posts" ON public.blog_posts
           FOR INSERT WITH CHECK (auth.role() = 'authenticated');""",
        """CREATE POLICY "Allow authenticated users to update blog posts" ON public.blog_posts
           FOR UPDATE USING (auth.role() = 'authenticated');""",
        """CREATE POLICY "Allow authenticated users to delete blog posts" ON public.blog_posts
           FOR DELETE USING (auth.role() = 'authenticated');"""
    ]
    
    # SQL to insert sample data
    insert_sample_data_sql = """
    INSERT INTO public.blog_posts (title, content, category, image_url, created_at) VALUES
    ('Getting Started with Flutter', 'Flutter is Google''s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.', 'tech', '', NOW() - INTERVAL '2 days'),
    ('The Future of Mobile Development', 'Mobile development is evolving rapidly with new frameworks, tools, and technologies emerging constantly.', 'tech', '', NOW() - INTERVAL '1 day'),
    ('Economic Impact of Technology', 'Technology continues to reshape the global economy, creating new opportunities while disrupting traditional industries.', 'economic', '', NOW() - INTERVAL '3 days'),
    ('New Features in Flutter 3.0', 'Flutter 3.0 brings exciting new features including improved performance, better web support, and enhanced developer tools.', 'newArrivals', '', NOW() - INTERVAL '4 hours'),
    ('Building Responsive UIs', 'Creating responsive user interfaces that work seamlessly across different screen sizes and devices is crucial for modern app development.', 'tech', '', NOW() - INTERVAL '6 hours')
    ON CONFLICT DO NOTHING;
    """
    
    try:
        print("🔌 Connecting to Supabase database...")
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = True
        cursor = conn.cursor()
        
        print("✅ Connected successfully!")
        
        # Create the table
        print("📝 Creating blog_posts table...")
        cursor.execute(create_table_sql)
        print("✅ Table created successfully!")
        
        # Create indexes
        print("📊 Creating indexes...")
        for index_sql in create_indexes_sql:
            cursor.execute(index_sql)
        print("✅ Indexes created successfully!")
        
        # Enable RLS
        print("🔒 Enabling Row Level Security...")
        cursor.execute(enable_rls_sql)
        print("✅ RLS enabled successfully!")
        
        # Create policies
        print("🛡️ Creating security policies...")
        for policy_sql in create_policies_sql:
            try:
                cursor.execute(policy_sql)
            except psycopg2.errors.DuplicateTable:
                print("   Policy already exists, skipping...")
        print("✅ Security policies created successfully!")
        
        # Insert sample data
        print("📄 Inserting sample data...")
        cursor.execute(insert_sample_data_sql)
        print("✅ Sample data inserted successfully!")
        
        # Verify the table was created
        cursor.execute("SELECT COUNT(*) FROM public.blog_posts;")
        count = cursor.fetchone()[0]
        print(f"🎉 Setup complete! Table has {count} blog posts.")
        
        cursor.close()
        conn.close()
        
        print("\n🚀 Your Supabase database is ready!")
        print("You can now run your Flutter app with: flutter run")
        
    except psycopg2.OperationalError as e:
        print(f"❌ Connection failed: {e}")
        print("\n💡 Make sure Supabase is running locally:")
        print("   - Check if Supabase is started")
        print("   - Verify the database is accessible on port 54322")
        print("   - Try running: supabase start")
        sys.exit(1)
        
    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

def check_connection():
    """Test database connection"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        conn.close()
        return True
    except:
        return False

if __name__ == "__main__":
    print("🏗️  Supabase Blog Table Setup Script")
    print("=" * 40)
    
    # Check if Supabase is running
    if not check_connection():
        print("❌ Cannot connect to Supabase database!")
        print("\n💡 Please make sure:")
        print("   1. Supabase is running locally")
        print("   2. Database is accessible on port 54322")
        print("   3. Default credentials are correct (postgres/postgres)")
        print("\n🔧 To start Supabase:")
        print("   supabase start")
        sys.exit(1)
    
    create_blog_table()
