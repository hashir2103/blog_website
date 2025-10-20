enum BlogCategory { economic, tech, newArrivals, health }

extension BlogCategoryExtension on BlogCategory {
  String get displayName {
    switch (this) {
      case BlogCategory.economic:
        return 'Economic';
      case BlogCategory.tech:
        return 'Technology';
      case BlogCategory.newArrivals:
        return 'Entertainment';
      case BlogCategory.health:
        return 'Health';
    }
  }
}

class BlogPost {
  final String id;
  final String title;
  final String content;
  final BlogCategory category;
  final String imageUrl;
  final DateTime publishDate;

  const BlogPost({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrl,
    required this.publishDate,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    BlogCategory parseCategory(dynamic raw) {
      final asString = raw is String ? raw : null;
      if (asString == null) return BlogCategory.tech;
      return BlogCategory.values.firstWhere(
        (e) => e.name == asString,
        orElse: () => BlogCategory.tech,
      );
    }

    DateTime parsePublishDate(dynamic raw) {
      if (raw is DateTime) return raw;
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      return DateTime.now();
    }

    return BlogPost(
      id: json['id'] as String,
      title: (json['title'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      category: parseCategory(json['category']),
      imageUrl: (json['image_url'] as String?) ?? '',
      publishDate: parsePublishDate(json['publish_date']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'category': category.name,
    'image_url': imageUrl,
    'publish_date': publishDate.toIso8601String(),
  };

  // For creating new posts (without ID)
  Map<String, dynamic> toJsonForInsert() => {
    'title': title,
    'content': content,
    'category': category.name,
    'image_url': imageUrl,
    'publish_date': publishDate.toIso8601String(),
  };
}
