import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/blog_post.dart';
import '../supabase_config.dart';

class BlogService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Fetch all blog posts
  static Future<List<BlogPost>> getAllPosts() async {
    try {
      final response = await _client
          .from('blog_posts')
          .select()
          .order('publish_date', ascending: false);

      return (response as List).map((json) => BlogPost.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  // Fetch posts by category
  static Future<List<BlogPost>> getPostsByCategory(
    BlogCategory category,
  ) async {
    try {
      final response = await _client
          .from('blog_posts')
          .select()
          .eq('category', category.name)
          .order('publish_date', ascending: false);

      return (response as List).map((json) => BlogPost.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching posts by category: $e');
      return [];
    }
  }

  // Create a new blog post
  static Future<BlogPost?> createPost({
    required String title,
    required String content,
    required BlogCategory category,
    Uint8List? imageBytes,
  }) async {
    try {
      String imageUrl = '';

      // Upload image if provided
      if (imageBytes != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploadResponse = await _client.storage
            .from('BlogBucket')
            .uploadBinary(fileName, imageBytes);

        if (uploadResponse.isNotEmpty) {
          imageUrl = _client.storage.from('BlogBucket').getPublicUrl(fileName);
        }
      }

      // Create post data
      final postData = {
        'title': title,
        'content': content,
        'category': category.name,
        'image_url': imageUrl,
        'publish_date': DateTime.now().toIso8601String(),
      };

      print('Creating post with data: $postData'); // Debug log

      final response = await _client
          .from('blog_posts')
          .insert(postData)
          .select()
          .single();

      print('Post created successfully: $response'); // Debug log
      return BlogPost.fromJson(response);
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  // Update an existing blog post
  static Future<BlogPost?> updatePost({
    required String id,
    required String title,
    required String content,
    required BlogCategory category,
    String? existingImageUrl,
    Uint8List? newImageBytes,
  }) async {
    try {
      String imageUrl = existingImageUrl ?? '';

      // Upload new image if provided
      if (newImageBytes != null) {
        // Delete old image if it exists and is not empty
        if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
          try {
            // Extract filename from URL
            final urlParts = existingImageUrl.split('/');
            final fileName = urlParts.last;

            // Delete the old image from storage
            await _client.storage.from('BlogBucket').remove([fileName]);
            print('Old image deleted: $fileName');
          } catch (e) {
            print('Error deleting old image: $e');
            // Continue with upload even if deletion fails
          }
        }

        // Upload new image
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploadResponse = await _client.storage
            .from('BlogBucket')
            .uploadBinary(fileName, newImageBytes);

        if (uploadResponse.isNotEmpty) {
          imageUrl = _client.storage.from('BlogBucket').getPublicUrl(fileName);
        }
      }

      // Update post data
      final updateData = {
        'title': title,
        'content': content,
        'category': category.name,
        'image_url': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('blog_posts')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return BlogPost.fromJson(response);
    } catch (e) {
      print('Error updating post: $e');
      return null;
    }
  }

  // Verify admin credentials
  static Future<bool> verifyAdminCredentials(String id, String password) async {
    try {
      await _client
          .from('creds')
          .select('id, pass')
          .eq('id', id)
          .eq('pass', password)
          .single();

      return true;
    } catch (e) {
      print('Error verifying admin credentials: $e');
      return false;
    }
  }

  // Delete an image from storage
  static Future<bool> deleteImageFromStorage(String fileName) async {
    try {
      await _client.storage.from('BlogBucket').remove([fileName]);
      return true;
    } catch (e) {
      print('Error deleting image from storage: $e');
      return false;
    }
  }

  // Delete a blog post
  static Future<bool> deletePost(String id) async {
    try {
      await _client.from('blog_posts').delete().eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }
}
