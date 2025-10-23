import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Last updated: ${DateTime.now().year}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 32),

              _buildSection(
                'Introduction',
                'HBTinsights ("we", "our", or "us") operates hbtinsights.com, a news and insights blog website. This Privacy Policy explains how we collect, use, and protect information when you visit our website.',
              ),

              _buildSection(
                'Information We Collect',
                'HBTinsights is a blog/news website. We do NOT collect personal information from readers. You can browse and read our articles without creating an account or providing any personal data. We only collect standard technical information through cookies and advertising partners as described below.',
              ),

              _buildSection(
                'Cookies and Tracking',
                'We use cookies to enhance your browsing experience. Cookies are small text files stored on your device. Our website uses cookies for:\n\n• Displaying personalized advertisements (Google AdSense)\n• Analyzing website traffic and usage patterns\n• Improving website functionality\n\nYou can disable cookies in your browser settings, but this may affect website functionality and ad display.',
              ),

              _buildSection(
                'Google AdSense and Advertising',
                'We use Google AdSense to display advertisements on our website. Google AdSense uses cookies and web beacons to:\n\n• Serve ads based on your prior visits to our website and other sites\n• Measure ad performance and engagement\n• Provide targeted advertising\n\nGoogle may collect data such as your IP address, browser type, pages visited, and time spent on pages. You can opt out of personalized advertising by visiting: https://www.google.com/settings/ads',
              ),

              _buildSection(
                'Third-Party Services',
                'Our website is hosted on GitHub Pages and uses Supabase for content management. These services may collect technical data such as:\n\n• IP addresses\n• Browser type and version\n• Device information\n• Pages visited and time stamps\n\nWe do not share any personal information with third parties because we do not collect it from readers.',
              ),

              _buildSection(
                'Admin Area',
                'Our website has an admin login area for authorized personnel to manage blog content. Admin login credentials are securely stored and encrypted. This area is not accessible to regular website visitors.',
              ),

              _buildSection(
                'Children\'s Privacy',
                'Our website is a general news/blog site suitable for all ages. We do not knowingly collect any personal information from anyone, including children under 13.',
              ),

              _buildSection(
                'Your Rights',
                'Since we do not collect personal information from readers, there is no personal data to access, modify, or delete. If you have concerns about cookies or advertising, you can:\n\n• Clear your browser cookies\n• Use ad-blocking software\n• Opt out of personalized ads through Google Ad Settings',
              ),

              _buildSection(
                'Changes to This Policy',
                'We may update this Privacy Policy from time to time. Changes will be posted on this page with an updated revision date. Continued use of our website after changes constitutes acceptance of the updated policy.',
              ),

              _buildSection(
                'Contact Us',
                'If you have any questions about this Privacy Policy, please contact us at: hashirtahir2103@gmail.com',
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
