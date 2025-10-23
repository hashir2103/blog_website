import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:typed_data';
import '../models/blog_post.dart';
import '../services/blog_service.dart';
import 'privacy_policy_page.dart';
import 'contact_page.dart';

class BlogHomePage extends StatefulWidget {
  const BlogHomePage({super.key});

  @override
  State<BlogHomePage> createState() => _BlogHomePageState();
}

class _BlogHomePageState extends State<BlogHomePage> {
  int _selectedIndex = 0;
  bool _isEditMode = false;
  bool _isAdminAuthenticated = false;
  List<BlogPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await BlogService.getAllPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading posts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.white),
          tooltip: 'Menu',
          onSelected: (value) {
            if (value == 'privacy') {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
              );
            } else if (value == 'contact') {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ContactPage()),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'privacy',
              child: Row(
                children: [
                  Icon(Icons.privacy_tip, size: 20),
                  SizedBox(width: 12),
                  Text('Privacy Policy'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'contact',
              child: Row(
                children: [
                  Icon(Icons.contact_mail, size: 20),
                  SizedBox(width: 12),
                  Text('Contact Us'),
                ],
              ),
            ),
          ],
        ),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = MediaQuery.of(context).size.width < 600;
            return Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 6 : 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isMobile ? 'HBT' : 'HBTinsights',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 16 : 18,
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 20),
                // Navigation tabs
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTabButton(isMobile ? 'Econ' : 'Economics', 0, isMobile),
                        SizedBox(width: isMobile ? 8 : 16),
                        _buildTabButton(isMobile ? 'Tech' : 'Technology', 1, isMobile),
                        SizedBox(width: isMobile ? 8 : 16),
                        _buildTabButton(isMobile ? 'Ent' : 'Entertainment', 2, isMobile),
                        SizedBox(width: isMobile ? 8 : 16),
                        _buildTabButton('Health', 3, isMobile),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          if (_isAdminAuthenticated)
            IconButton(
              onPressed: () async {
                await BlogService.logoutAdmin();
                setState(() {
                  _isAdminAuthenticated = false;
                  _isEditMode = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Logout',
            ),
          IconButton(
            onPressed: () {
              if (_isAdminAuthenticated) {
                setState(() {
                  _isEditMode = !_isEditMode;
                });
              } else {
                _showAdminAuthDialog();
              }
            },
            icon: Icon(
              _isEditMode ? Icons.edit_off : Icons.person,
              color: _isEditMode ? Colors.orange : Colors.white,
            ),
            tooltip: _isAdminAuthenticated
                ? (_isEditMode ? 'Exit Edit Mode' : 'Edit Website')
                : 'Admin Login',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // AdSense Banner Section
                  _buildAdBanner(),

                  // Blog Posts Grid Section
                  _buildBlogPostsGrid(),
                ],
              ),
            ),
      floatingActionButton: _isEditMode && _isAdminAuthenticated
          ? FloatingActionButton(
              onPressed: _showCreatePostDialog,
              backgroundColor: Colors.red,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildAdBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.of(context).size.width < 600;
        // TODO: Replace with actual AdSense ad unit after site approval
        // AdSense script is already added in web/index.html
        return Container(
          height: isMobile ? 80 : 120,
          margin: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              'Advertisement Space',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButton(String text, int index, [bool isMobile = false]) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 4 : 8,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.red : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBlogPostsGrid() {
    final filteredPosts = _getFilteredPosts(_posts);

    if (filteredPosts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'No posts found for this category',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine number of columns based on screen width
        int crossAxisCount;
        double mainAxisExtent;
        
        if (constraints.maxWidth < 600) {
          // Mobile: 1 column
          crossAxisCount = 1;
          mainAxisExtent = 500;
        } else if (constraints.maxWidth < 1000) {
          // Tablet: 2 columns  
          crossAxisCount = 2;
          mainAxisExtent = 580;
        } else {
          // Desktop: 3 columns
          crossAxisCount = 3;
          mainAxisExtent = 600;
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: mainAxisExtent,
            ),
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              return _buildBlogPostCard(filteredPosts[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildBlogPostCard(BlogPost post) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.of(context).size.width < 600;
        final imageHeight = isMobile ? 200.0 : 300.0;
        final titleFontSize = isMobile ? 16.0 : 18.0;
        final contentFontSize = isMobile ? 13.0 : 14.0;
        final cardPadding = isMobile ? 12.0 : 16.0;
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Stack(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => BlogPostDetailPage(
                            post: post,
                            currentTabIndex: _selectedIndex,
                          ),
                        ),
                      )
                      .then((returnedTabIndex) {
                        // Update the selected tab if a different one was selected
                        if (returnedTabIndex != null &&
                            returnedTabIndex != _selectedIndex) {
                          setState(() {
                            _selectedIndex = returnedTabIndex;
                          });
                        }
                      });
                },
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    Container(
                      height: imageHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: post.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              child: Image.network(
                                post.imageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                    ),

                    // Content
                    Padding(
                      padding: EdgeInsets.all(cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Category Badge
                          SizedBox(height: isMobile ? 8 : 12),

                          // Title
                          Text(
                            post.title,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // Content Preview
                          RichText(
                            text: _parseMarkdownToTextSpan(
                              post.content,
                              TextStyle(
                                fontSize: contentFontSize,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 12),

                          // Publish Date
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: isMobile ? 12 : 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _formatDate(post.publishDate),
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : 12,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_isEditMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () => _showEditDialog(post),
                      icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showAdminAuthDialog() {
    final idController = TextEditingController();
    final passwordController = TextEditingController();
    bool _isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width > 600 
                ? MediaQuery.of(context).size.width * 0.4 
                : MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Admin Authentication',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Email Field
                Text(
                  'Email Address',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: idController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter admin email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),

                // Password Field
                Text(
                  'Password',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (idController.text.trim().isEmpty ||
                                passwordController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter both email and password',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            setDialogState(() {
                              _isLoading = true;
                            });

                            final isValid =
                                await BlogService.loginAdmin(
                                  idController.text.trim(),
                                  passwordController.text.trim(),
                                );

                            setDialogState(() {
                              _isLoading = false;
                            });

                            if (isValid) {
                              Navigator.of(context).pop();
                              setState(() {
                                _isAdminAuthenticated = true;
                                _isEditMode = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Admin authentication successful!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Invalid credentials. Please try again.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Login',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BlogPost post) {
    final titleController = TextEditingController(text: post.title);
    final contentController = TextEditingController(text: post.content);
    BlogCategory selectedCategory = post.category;
    Uint8List? selectedImageBytes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width > 600 
                ? MediaQuery.of(context).size.width * 0.7
                : MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.85,
            padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Edit Post',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field
                        Text(
                          'Title',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: 'Enter post title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),

                        // Category Dropdown
                        Text(
                          'Category',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<BlogCategory>(
                              value: selectedCategory,
                              isExpanded: true,
                              items: BlogCategory.values.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category.displayName,
                                    style: TextStyle(
                                      color: _getCategoryColor(category),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setDialogState(() {
                                    selectedCategory = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Content Field
                        Text(
                          'Content',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: contentController,
                          maxLines: 15, // Increased from 8 to 15 lines
                          decoration: InputDecoration(
                            hintText:
                                'Enter post content (use **text** for bold)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            alignLabelWithHint: true,
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),

                        // Image Upload Section
                        Text(
                          'Image',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: InkWell(
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 800,
                                maxHeight: 600,
                                imageQuality: 85,
                              );

                              if (image != null) {
                                final bytes = await image.readAsBytes();
                                setDialogState(() {
                                  selectedImageBytes = bytes;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: selectedImageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      selectedImageBytes!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cloud_upload_outlined,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Tap to upload image',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'or drag and drop',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey.shade500,
                                            ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    // Delete Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Show confirmation dialog
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Post'),
                              content: const Text(
                                'Are you sure you want to delete this post? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true) {
                            Navigator.of(context).pop(); // Close edit dialog
                            _deletePost(post);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Delete Post',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Save Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _savePost(
                            post,
                            titleController.text,
                            contentController.text,
                            selectedCategory,
                            selectedImageBytes,
                          );
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deletePost(BlogPost post) async {
    try {
      // Delete image from storage if it exists
      if (post.imageUrl.isNotEmpty) {
        try {
          final urlParts = post.imageUrl.split('/');
          final fileName = urlParts.last;
          await BlogService.deleteImageFromStorage(fileName);
          print('Image deleted from storage: $fileName');
        } catch (e) {
          print('Error deleting image from storage: $e');
          // Continue with post deletion even if image deletion fails
        }
      }

      // Delete post from database
      final success = await BlogService.deletePost(post.id);

      if (success) {
        await _loadPosts(); // Refresh the posts list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post "${post.title}" deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete post. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _savePost(
    BlogPost originalPost,
    String newTitle,
    String newContent,
    BlogCategory newCategory,
    Uint8List? newImageBytes,
  ) async {
    try {
      final updatedPost = await BlogService.updatePost(
        id: originalPost.id,
        title: newTitle,
        content: newContent,
        category: newCategory,
        existingImageUrl: originalPost.imageUrl,
        newImageBytes: newImageBytes,
      );

      if (updatedPost != null) {
        await _loadPosts(); // Refresh the posts list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post "${newTitle}" updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update post. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<BlogPost> _getFilteredPosts(List<BlogPost> allPosts) {
    switch (_selectedIndex) {
      case 0: // Economic
        return allPosts
            .where((post) => post.category == BlogCategory.economic)
            .toList();
      case 1: // Technology
        return allPosts
            .where((post) => post.category == BlogCategory.tech)
            .toList();
      case 2: // Entertainment
        return allPosts
            .where((post) => post.category == BlogCategory.entertainment)
            .toList();
      case 3: // Health
        return allPosts
            .where((post) => post.category == BlogCategory.health)
            .toList();
      default:
        return allPosts;
    }
  }

  Color _getCategoryColor(BlogCategory category) {
    switch (category) {
      case BlogCategory.economic:
        return Colors.orange;
      case BlogCategory.tech:
        return Colors.blue;
      case BlogCategory.entertainment:
        return Colors.purple;
      case BlogCategory.health:
        return Colors.green;
    }
  }

  // Helper method to get category from tab index
  BlogCategory _getCategoryFromIndex(int index) {
    switch (index) {
      case 0: // Economic
        return BlogCategory.economic;
      case 1: // Technology
        return BlogCategory.tech;
      case 2: // Entertainment
        return BlogCategory.entertainment;
      case 3: // Health
        return BlogCategory.health;
      default:
        return BlogCategory.economic;
    }
  }

  // Helper method to parse markdown and create TextSpan
  TextSpan _parseMarkdownToTextSpan(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');

    int lastIndex = 0;
    for (final Match match in boldRegex.allMatches(text)) {
      // Add text before the bold part
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      // Add the bold text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    return TextSpan(children: spans);
  }

  void _showCreatePostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    // Set default category based on current tab
    BlogCategory selectedCategory = _getCategoryFromIndex(_selectedIndex);
    Uint8List? selectedImageBytes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width > 600 
                ? MediaQuery.of(context).size.width * 0.7
                : MediaQuery.of(context).size.width * 0.95,
            height: MediaQuery.of(context).size.height * 0.85,
            padding: EdgeInsets.all(MediaQuery.of(context).size.width > 600 ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Create New Post',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Field
                        Text(
                          'Title',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: 'Enter post title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),

                        // Category Dropdown
                        Text(
                          'Category',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<BlogCategory>(
                              value: selectedCategory,
                              isExpanded: true,
                              items: BlogCategory.values.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(
                                    category.displayName,
                                    style: TextStyle(
                                      color: _getCategoryColor(category),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setDialogState(() {
                                    selectedCategory = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Content Field
                        Text(
                          'Content',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: contentController,
                          maxLines: 15, // Increased from 8 to 15 lines
                          decoration: InputDecoration(
                            hintText:
                                'Enter post content (use **text** for bold)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            alignLabelWithHint: true,
                          ),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),

                        // Image Upload Section
                        Text(
                          'Image',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade50,
                          ),
                          child: InkWell(
                            onTap: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 800,
                                maxHeight: 600,
                                imageQuality: 85,
                              );

                              if (image != null) {
                                final bytes = await image.readAsBytes();
                                setDialogState(() {
                                  selectedImageBytes = bytes;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: selectedImageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      selectedImageBytes!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cloud_upload_outlined,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Tap to upload image',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'or drag and drop',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.grey.shade500,
                                            ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Create Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty ||
                          contentController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all required fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final newPost = await BlogService.createPost(
                        title: titleController.text.trim(),
                        content: contentController.text.trim(),
                        category: selectedCategory,
                        imageBytes: selectedImageBytes,
                      );

                      if (newPost != null) {
                        Navigator.of(context).pop();
                        await _loadPosts(); // Refresh the posts list
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Post "${newPost.title}" created successfully!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Failed to create post. Please try again.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Create Post',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BlogPostDetailPage extends StatefulWidget {
  final BlogPost post;
  final int currentTabIndex;

  const BlogPostDetailPage({
    super.key,
    required this.post,
    required this.currentTabIndex,
  });

  @override
  State<BlogPostDetailPage> createState() => _BlogPostDetailPageState();
}

class _BlogPostDetailPageState extends State<BlogPostDetailPage> {
  bool _isContentLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load content after initial render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isContentLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = MediaQuery.of(context).size.width < 600;
            return Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 6 : 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'HBT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 16 : 18,
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 20),
                // Navigation tabs
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTabButton(isMobile ? 'Econ' : 'Economics', 0, isMobile),
                        SizedBox(width: isMobile ? 8 : 16),
                        _buildTabButton(isMobile ? 'Tech' : 'Technology', 1, isMobile),
                        SizedBox(width: isMobile ? 8 : 16),
                        _buildTabButton(isMobile ? 'Ent' : 'Entertainment', 2, isMobile),
                        SizedBox(width: isMobile ? 8 : 16),
                        _buildTabButton('Health', 3, isMobile),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: _isContentLoaded
          ? CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 12 : 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Image and Ad Layout (Responsive)
                      if (widget.post.imageUrl.isNotEmpty)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = MediaQuery.of(context).size.width < 800;
                            
                            if (isMobile) {
                              // Mobile: Stack vertically
                              return Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.network(
                                        widget.post.imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            height: 250,
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 250,
                                            color: Colors.grey.shade300,
                                            child: const Center(
                                              child: Icon(Icons.image, size: 60, color: Colors.grey),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 150,
                                    margin: const EdgeInsets.only(bottom: 32),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.ads_click, size: 32, color: Colors.grey.shade600),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Advertisement',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              // Desktop: Side by side
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 32),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        height: 400,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.15),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.network(
                                            widget.post.imageUrl,
                                            width: double.infinity,
                                            height: 400,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                height: 400,
                                                color: Colors.grey.shade200,
                                                child: const Center(
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                height: 400,
                                                color: Colors.grey.shade300,
                                                child: const Center(
                                                  child: Icon(Icons.image, size: 60, color: Colors.grey),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: 400,
                                        margin: const EdgeInsets.only(left: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.ads_click, size: 32, color: Colors.grey.shade600),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Advertisement',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '300x400',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),

                      // Title
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = MediaQuery.of(context).size.width < 600;
                          return Text(
                            widget.post.title,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              height: 1.2,
                              fontSize: isMobile ? 24 : 28,
                              letterSpacing: -0.5,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Publish Date
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = MediaQuery.of(context).size.width < 600;
                          return Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: isMobile ? 16 : 18,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Published on ${_formatDate(widget.post.publishDate)}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                    fontSize: isMobile ? 13 : 14,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: MediaQuery.of(context).size.width < 600 ? 24 : 32),

                      // Content
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = MediaQuery.of(context).size.width < 600;
                          return Container(
                            padding: EdgeInsets.all(isMobile ? 16 : 20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: MarkdownBody(
                              data: widget.post.content,
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  color: Colors.black87,
                                  height: 1.8,
                                  fontSize: isMobile ? 15 : 16,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                                strong: TextStyle(
                                  color: Colors.black87,
                                  height: 1.8,
                                  fontSize: isMobile ? 15 : 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                                h1: TextStyle(
                                  color: Colors.black87,
                                  fontSize: isMobile ? 22 : 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                                h2: TextStyle(
                                  color: Colors.black87,
                                  fontSize: isMobile ? 19 : 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                                h3: TextStyle(
                                  color: Colors.black87,
                                  fontSize: isMobile ? 17 : 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              selectable: true,
                            ),
                          );
                        },
                      ),
                    ]),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
    );
  }

  Widget _buildTabButton(String text, int index, [bool isMobile = false]) {
    final isSelected = _getCategoryFromIndex(index) == widget.post.category;
    return GestureDetector(
      onTap: () {
        // Navigate back to home page with selected category
        Navigator.of(context).pop(index);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 4 : 8,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.red : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  BlogCategory _getCategoryFromIndex(int index) {
    switch (index) {
      case 0:
        return BlogCategory.economic;
      case 1:
        return BlogCategory.tech;
      case 2:
        return BlogCategory.entertainment;
      case 3:
        return BlogCategory.health;
      default:
        return BlogCategory.economic;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
