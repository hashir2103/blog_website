-- Insert sample blog posts
INSERT INTO public.blog_posts (title, content, category, image_url, publish_date) VALUES
(
    'Getting Started with Flutter',
    'Flutter is Google''s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase. In this comprehensive guide, we''ll explore the fundamentals of Flutter development, including widgets, state management, and best practices.',
    'tech',
    '',
    NOW() - INTERVAL '2 days'
),
(
    'The Future of Mobile Development',
    'Mobile development is evolving rapidly with new frameworks, tools, and technologies emerging constantly. This article explores the latest trends and what developers need to know to stay ahead in the mobile development landscape.',
    'tech',
    '',
    NOW() - INTERVAL '1 day'
),
(
    'Economic Impact of Technology',
    'Technology continues to reshape the global economy, creating new opportunities while disrupting traditional industries. We examine the economic implications of digital transformation and its effects on various sectors.',
    'economic',
    '',
    NOW() - INTERVAL '3 days'
),
(
    'New Features in Flutter 3.0',
    'Flutter 3.0 brings exciting new features including improved performance, better web support, and enhanced developer tools. Learn about the key updates and how they can benefit your development workflow.',
    'newArrivals',
    '',
    NOW() - INTERVAL '4 hours'
),
(
    'Building Responsive UIs',
    'Creating responsive user interfaces that work seamlessly across different screen sizes and devices is crucial for modern app development. This guide covers best practices and techniques for building adaptive UIs.',
    'tech',
    '',
    NOW() - INTERVAL '6 hours'
);
