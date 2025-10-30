// Static Site Generator for Blog Posts
// Generates individual HTML pages for each blog post that search engines can crawl

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// ESM compatibility for __dirname / __filename
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Read the noscript content from index.html as base
function generateStaticPost(post, baseNoscriptContent) {
  const title = post.title;
  const category = post.category;
  const publishDate = new Date(post.publish_date).toLocaleDateString('en-US', { 
    year: 'numeric', month: 'long', day: 'numeric' 
  });
  
  // Extract first 200 words for description
  const plainContent = post.content.replace(/#+ /g, '').replace(/\*\*/g, '').replace(/\*/g, '');
  const description = plainContent.substring(0, 200) + '...';
  
  const imageMeta = post.image_url ? `<meta property="og:image" content="${post.image_url}">` : '';
  
  // Convert markdown to HTML for full content display
  function markdownToHtml(markdown) {
    if (!markdown) return '';
    
    // Process headers first (before line processing)
    let html = markdown
      .replace(/^#{6} (.+)$/gm, '<h6>$1</h6>')
      .replace(/^#{5} (.+)$/gm, '<h5>$1</h5>')
      .replace(/^#{4} (.+)$/gm, '<h4>$1</h4>')
      .replace(/^### (.+)$/gm, '<h3>$1</h3>')
      .replace(/^## (.+)$/gm, '<h2>$1</h2>')
      .replace(/^# (.+)$/gm, '<h1>$1</h1>');
    
    // Process bold and italic (before paragraph processing to avoid conflicts)
    html = html
      .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
      .replace(/\*(.+?)\*/g, '<em>$1</em>');
    
    // Process links
    html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>');
    
    // Convert lines to paragraphs
    // Split by double newlines for paragraphs
    const paragraphs = html.split(/\n\s*\n/);
    const processedParagraphs = paragraphs.map(para => {
      const trimmed = para.trim();
      if (!trimmed) return '';
      
      // If it's already a header, return as is
      if (trimmed.match(/^<h[1-6]>/)) {
        return trimmed;
      }
      
      // Convert single newlines within paragraphs to spaces
      const singleLine = trimmed.replace(/\n/g, ' ').trim();
      
      // Wrap in paragraph tag if it contains content
      if (singleLine && !singleLine.match(/^<h[1-6]>/)) {
        return `<p>${singleLine}</p>`;
      }
      
      return singleLine;
    });
    
    return processedParagraphs.filter(p => p).join('\n\n');
  }
  
  // Escape HTML special characters for safe embedding
  function escapeHtml(text) {
    const map = {
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
  }
  
  const escapedTitle = escapeHtml(title);
  const escapedCategory = escapeHtml(category);
  const htmlContent = markdownToHtml(post.content);
  
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  
  <!-- Primary Meta Tags -->
  <title>${escapedTitle} - HBTinsights</title>
  <meta name="title" content="${escapedTitle} - HBTinsights">
  <meta name="description" content="${escapeHtml(description)}">
  <meta name="author" content="HBTinsights">
  <meta name="robots" content="index, follow">
  
  <!-- Canonical URL -->
  <link rel="canonical" href="https://hbtinsights.com/posts/${post.id}.html">
  
  <!-- Open Graph / Facebook -->
  <meta property="og:type" content="article">
  <meta property="og:url" content="https://hbtinsights.com/posts/${post.id}.html">
  <meta property="og:title" content="${escapedTitle}">
  <meta property="og:description" content="${escapeHtml(description)}">
  ${imageMeta}
  <meta property="og:site_name" content="HBTinsights">
  
  <!-- Twitter -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${escapedTitle}">
  <meta name="twitter:description" content="${escapeHtml(description)}">
  
  <!-- Article Schema -->
  <script type="application/ld+json">
  {
    "@context": "https://schema.org",
    "@type": "NewsArticle",
    "headline": ${JSON.stringify(title)},
    "description": ${JSON.stringify(description)},
    "datePublished": "${post.publish_date}",
    "dateModified": "${post.updated_at || post.publish_date}",
    "author": {
      "@type": "Organization",
      "name": "HBTinsights"
    },
    "publisher": {
      "@type": "Organization",
      "name": "HBTinsights",
      "logo": {
        "@type": "ImageObject",
        "url": "https://hbtinsights.com/icons/Icon-192.png"
      }
    }${post.image_url ? `,
    "image": {
      "@type": "ImageObject",
      "url": "${post.image_url}"
    }` : ''}
  }
  </script>
  
  <!-- Favicon -->
  <link rel="icon" type="image/png" href="/favicon.png">
  
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
      line-height: 1.8;
      color: #374151;
      background-color: #ffffff;
    }
    
    .container {
      max-width: 900px;
      margin: 0 auto;
      padding: 40px 20px;
    }
    
    header {
      background-color: #000000;
      color: #ffffff;
      padding: 20px 0;
      margin-bottom: 40px;
    }
    
    .header-content {
      max-width: 1200px;
      margin: 0 auto;
      padding: 0 20px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 20px;
    }
    
    .logo {
      background-color: #dc2626;
      color: #ffffff;
      padding: 8px 12px;
      border-radius: 4px;
      font-weight: bold;
      font-size: 18px;
      text-decoration: none;
    }
    
    nav a {
      color: #ffffff;
      text-decoration: none;
      font-weight: 500;
      margin-left: 20px;
    }
    
    nav a:hover {
      color: #dc2626;
    }
    
    .article-header {
      margin-bottom: 30px;
    }
    
    h1 {
      color: #1f2937;
      font-size: 36px;
      font-weight: 700;
      line-height: 1.3;
      margin-bottom: 15px;
    }
    
    .article-meta {
      color: #6b7280;
      font-size: 14px;
      margin-bottom: 25px;
      padding-bottom: 20px;
      border-bottom: 1px solid #e5e7eb;
    }
    
    .category-badge {
      display: inline-block;
      padding: 6px 12px;
      background-color: #dc2626;
      color: #ffffff;
      border-radius: 4px;
      font-size: 12px;
      font-weight: 600;
      text-transform: uppercase;
      margin-right: 15px;
    }
    
    .article-image {
      width: 100%;
      max-width: 100%;
      height: auto;
      margin: 30px 0;
      border-radius: 8px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }
    
    .article-content {
      font-size: 18px;
      line-height: 1.8;
      color: #374151;
    }
    
    .article-content p {
      margin-bottom: 20px;
    }
    
    .article-content h1,
    .article-content h2,
    .article-content h3,
    .article-content h4,
    .article-content h5,
    .article-content h6 {
      margin-top: 35px;
      margin-bottom: 15px;
      font-weight: 600;
      line-height: 1.3;
    }
    
    .article-content h1 { font-size: 32px; color: #1f2937; }
    .article-content h2 { font-size: 28px; color: #1f2937; }
    .article-content h3 { font-size: 24px; color: #dc2626; }
    .article-content h4 { font-size: 20px; color: #dc2626; }
    
    .article-content strong {
      font-weight: 700;
      color: #1f2937;
    }
    
    .article-content em {
      font-style: italic;
    }
    
    .article-content a {
      color: #dc2626;
      text-decoration: underline;
    }
    
    .article-content a:hover {
      color: #991b1b;
    }
    
    .back-link {
      margin-top: 50px;
      padding-top: 30px;
      border-top: 1px solid #e5e7eb;
    }
    
    .back-link a {
      color: #dc2626;
      text-decoration: none;
      font-weight: 600;
      font-size: 16px;
    }
    
    .back-link a:hover {
      text-decoration: underline;
    }
    
    footer {
      background-color: #1f2937;
      color: #ffffff;
      padding: 40px 20px;
      margin-top: 60px;
      text-align: center;
    }
    
    footer a {
      color: #dc2626;
      text-decoration: none;
      margin: 0 10px;
    }
    
    footer a:hover {
      text-decoration: underline;
    }
    
    @media (max-width: 768px) {
      .container {
        padding: 20px 15px;
      }
      
      h1 {
        font-size: 28px;
      }
      
      .article-content {
        font-size: 16px;
      }
    }
  </style>
  
  <!-- Google AdSense -->
  <script async src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=ca-pub-1059342231343027"
       crossorigin="anonymous"></script>
  
  <!-- Optional: Redirect to main app after a delay for users (not crawlers) -->
  <script>
    // Only redirect users with JavaScript enabled, not crawlers
    // Crawlers will see the full content below
    setTimeout(function() {
      // Don't redirect immediately - let crawlers index the content
      // Users can manually navigate if they want the interactive version
    }, 3000);
  </script>
</head>
<body>
  <header>
    <div class="header-content">
      <div style="display:flex; align-items:center; flex-wrap:wrap;">
        <a href="/home.html" class="logo">HBTinsights</a>
        <nav style="margin-left:16px;">
          <a href="/home.html">Home</a>
          <a href="/categories/economic.html">Economics</a>
          <a href="/categories/tech.html">Technology</a>
          <a href="/categories/entertainment.html">Entertainment</a>
          <a href="/categories/health.html">Health</a>
        </nav>
      </div>
      <nav>
        <a href="/about.html">About</a>
        <a href="/contact.html">Contact</a>
        <a href="/privacy.html">Privacy</a>
      </nav>
    </div>
  </header>
  
  <div class="container">
    <article>
      <div class="article-header">
        <span class="category-badge">${escapedCategory}</span>
        <h1>${escapedTitle}</h1>
        <div class="article-meta">
          <span>Published: ${publishDate}</span>
        </div>
      </div>
      
      ${post.image_url ? `<img src="${post.image_url}" alt="${escapedTitle}" class="article-image">` : ''}
      
      <div class="article-content">
        ${htmlContent}
      </div>
      
      <div class="back-link">
        <a href="/home.html">← Back to HBTinsights</a>
      </div>
    </article>
  </div>
  
  <footer>
    <div>
      <a href="/home.html">Home</a>
      <a href="/about.html">About Us</a>
      <a href="/contact.html">Contact</a>
      <a href="/privacy.html">Privacy Policy</a>
    </div>
    <p style="margin-top: 20px;">&copy; 2024 HBTinsights. All rights reserved.</p>
  </footer>
</body>
</html>`;
}

// Fetch posts from Supabase API
async function generatePosts() {
  try {
    const SUPABASE_URL = process.env.SUPABASE_URL || '';
    const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || '';
    
    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
      console.error('Error: SUPABASE_URL and SUPABASE_ANON_KEY environment variables are required');
      process.exit(1);
    }
    
    // Fetch all posts from Supabase
    const response = await fetch(`${SUPABASE_URL}/rest/v1/blog_posts?select=*&order=publish_date.desc`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (!response.ok) {
      throw new Error(`Failed to fetch posts: ${response.status} ${response.statusText}`);
    }
    
    const posts = await response.json();
    console.log(`Fetched ${posts.length} posts from Supabase`);
    
    // Create posts directory in web folder
    const webDir = path.join(__dirname, '..', 'web', 'posts');
    if (!fs.existsSync(webDir)) {
      fs.mkdirSync(webDir, { recursive: true });
    }
    
    // Generate HTML for each post
    for (const post of posts) {
      const html = generateStaticPost(post);
      const filePath = path.join(webDir, `${post.id}.html`);
      fs.writeFileSync(filePath, html);
      console.log(`Generated: ${post.id}.html - ${post.title.substring(0, 50)}...`);
    }
    
    // Generate index page linking to all posts
    generatePostsIndex(posts, webDir);

    // Generate category pages under web/categories
    generateCategoryPages(posts);
    
    console.log(`\n✓ Successfully generated ${posts.length} static post pages`);
    console.log(`✓ Files saved to: ${webDir}`);
    
  } catch (error) {
    console.error('Error generating static posts:', error);
    process.exit(1);
  }
}

function generatePostsIndex(posts, outputDir) {
  const indexHTML = `<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>All Posts - HBTinsights</title>
  <style>
    body { font-family: Arial, sans-serif; max-width: 1200px; margin: 50px auto; padding: 20px; }
    h1 { color: #dc2626; }
    .post-list { list-style: none; padding: 0; }
    .post-item { margin: 20px 0; padding: 15px; border-left: 4px solid #dc2626; background: #f9fafb; }
    .post-title { font-size: 18px; font-weight: bold; color: #1f2937; margin-bottom: 5px; }
    .post-meta { font-size: 14px; color: #6b7280; }
    .post-category { display: inline-block; padding: 4px 8px; background: #dc2626; color: white; font-size: 12px; border-radius: 4px; margin-right: 10px; }
  </style>
</head>
<body>
  <h1>HBTinsights - All Posts</h1>
  <p>Total: ${posts.length} articles</p>
  <ul class="post-list">
    ${posts.map(post => `
    <li class="post-item">
      <span class="post-category">${post.category}</span>
      <div class="post-title">${post.title}</div>
      <div class="post-meta">Published: ${new Date(post.publish_date).toLocaleDateString()}</div>
      <div class="post-meta">ID: ${post.id}</div>
    </li>
    `).join('')}
  </ul>
  <p><a href="/">← Back to HBTinsights</a></p>
</body>
</html>`;
  
  fs.writeFileSync(path.join(outputDir, 'index.html'), indexHTML);
  console.log('Generated posts index page');
}

function generateCategoryPages(posts) {
  const categories = ['economic', 'tech', 'entertainment', 'health'];
  const categoriesDir = path.join(__dirname, '..', 'web', 'categories');
  if (!fs.existsSync(categoriesDir)) {
    fs.mkdirSync(categoriesDir, { recursive: true });
  }

  for (const category of categories) {
    const filtered = posts.filter(p => (p.category || '').toLowerCase() === category);
    const titleCase = category.charAt(0).toUpperCase() + category.slice(1);

    const html = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${titleCase} Articles - HBTinsights</title>
  <meta name="description" content="${titleCase} articles and analysis from HBTinsights.">
  <link rel="canonical" href="https://hbtinsights.com/categories/${category}.html">
  <link rel="icon" type="image/png" href="/favicon.png">
  <style>
    * { box-sizing: border-box; }
    body { margin:0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif; color:#374151; background:#fafafa; }
    header { background:#000; color:#fff; padding:16px 0; position:sticky; top:0; z-index:10; }
    .nav { max-width:1200px; margin:0 auto; padding:0 20px; display:flex; align-items:center; justify-content:space-between; gap:20px; }
    .logo { background:#dc2626; color:#fff; padding:6px 10px; border-radius:4px; font-weight:700; text-decoration:none; }
    .nav a { color:#fff; text-decoration:none; margin-left:16px; }
    .container { max-width:1200px; margin: 30px auto; padding: 0 20px; }
    h1 { color:#dc2626; margin: 10px 0 20px; }
    .grid { display:grid; grid-template-columns: repeat(3, 1fr); gap: 18px; }
    @media (max-width: 1000px) { .grid { grid-template-columns: repeat(2, 1fr); } }
    @media (max-width: 640px) { .grid { grid-template-columns: 1fr; } }
    .card { background:#fff; border-radius:12px; overflow:hidden; box-shadow:0 2px 10px rgba(0,0,0,0.08); display:flex; flex-direction:column; }
    .thumb { width:100%; height: 220px; background:#e5e7eb; display:block; object-fit:cover; }
    .content { padding:16px; display:flex; flex-direction:column; gap:10px; }
    .title { color:#1f2937; font-size:18px; font-weight:700; text-decoration:none; line-height:1.35; }
    .meta { color:#6b7280; font-size:13px; }
    .badge { display:inline-block; background:#dc2626; color:#fff; border-radius:4px; padding:4px 8px; font-size:12px; font-weight:600; }
  </style>
</head>
<body>
  <header>
    <div class="nav">
      <div style="display:flex; align-items:center; flex-wrap:wrap;">
        <a class="logo" href="/home.html">HBTinsights</a>
        <nav style="margin-left:16px;">
          <a href="/home.html">Home</a>
          <a href="/categories/economic.html">Economics</a>
          <a href="/categories/tech.html">Technology</a>
          <a href="/categories/entertainment.html">Entertainment</a>
          <a href="/categories/health.html">Health</a>
        </nav>
      </div>
      <nav>
        <a href="/about.html">About</a>
        <a href="/contact.html">Contact</a>
        <a href="/privacy.html">Privacy</a>
      </nav>
    </div>
  </header>
  <div class="container">
    <div style="display:flex; align-items:center; gap:10px; margin-bottom:10px;">
      <span class="badge">${titleCase}</span>
    </div>
    <div class="grid">
      ${filtered.map(p => `
        <article class="card">
          ${p.image_url ? `<img class="thumb" src="${p.image_url}" alt="${p.title}">` : `<div class=\"thumb\"></div>`}
          <div class="content">
            <a class="title" href="/posts/${p.id}.html">${p.title}</a>
            <div class="meta">Published: ${new Date(p.publish_date).toLocaleDateString()}</div>
          </div>
        </article>
      `).join('')}
    </div>
    
  </div>
</body>
</html>`;

    fs.writeFileSync(path.join(categoriesDir, `${category}.html`), html);
    console.log(`Generated category page: ${category}.html (${filtered.length} posts)`);
  }
}

// Run the generator
generatePosts();

export { generatePosts };

