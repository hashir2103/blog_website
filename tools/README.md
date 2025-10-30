# Static Site Generator for HBTinsights

This tool generates static HTML pages for each blog post to help search engines index your content.

## Why This Is Needed

Flutter web apps render content client-side using JavaScript. Google's crawler may see empty pages without content, which violates AdSense policies that prohibit ads on pages without publisher content.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Set environment variables:
```bash
export SUPABASE_URL=your_supabase_url
export SUPABASE_ANON_KEY=your_anon_key
```

## Usage

Generate static pages:
```bash
npm run generate
```

This will:
- Fetch all posts from Supabase
- Generate individual HTML files for each post
- Create an index page listing all posts
- Save files to `web/posts/` directory

## How It Works

Each generated HTML file:
1. Contains the post content in a crawler-friendly format
2. Includes proper meta tags for SEO
3. Includes structured data (JSON-LD) for search engines
4. Automatically redirects users to the main app

This ensures:
- ✅ Google can crawl and see your content
- ✅ Ads only appear on pages with real content
- ✅ SEO-friendly URLs (e.g., `/posts/post-id.html`)
- ✅ Users get redirected to the full Flutter experience

## Deployment

After generating static posts:
1. Build your Flutter app: `flutter build web`
2. Copy the generated static files from `web/posts/` to your build output
3. Deploy to GitHub Pages or your hosting provider

## CI/CD Integration

Add this to your deployment workflow:

```yaml
# In your GitHub Actions workflow
- name: Generate Static Posts
  run: |
    cd tools
    npm install
    npm run generate
    
- name: Build Flutter Web
  run: flutter build web
  
- name: Copy Static Posts
  run: cp -r tools/web/posts build/web/
```

