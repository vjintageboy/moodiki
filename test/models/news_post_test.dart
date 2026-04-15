import 'package:flutter_test/flutter_test.dart';
import 'package:n04_app/models/news_post.dart';
import 'package:n04_app/models/post_comment.dart';

void main() {
  group('NewsPost model', () {
    test('creates with required fields', () {
      final post = NewsPost(
        postId: 'post-1',
        authorId: 'user-1',
        authorName: 'Nguyen Van A',
        authorRole: 'user',
        title: 'Test Post',
        content: 'Test Content',
        category: PostCategory.mentalHealth,
      );

      expect(post.postId, 'post-1');
      expect(post.isAnonymous, isFalse);
      expect(post.likeCount, 0);
      expect(post.commentCount, 0);
      expect(post.createdAt, isA<DateTime>());
      expect(post.updatedAt, isNull);
    });

    test('isAnonymous defaults to false', () {
      final post = NewsPost(
        postId: 'p1',
        authorId: 'u1',
        authorName: 'A',
        authorRole: 'user',
        title: 'T',
        content: 'C',
        category: PostCategory.news,
      );
      expect(post.isAnonymous, isFalse);
    });

    test('fromMap detects anonymous post when author_id is null', () {
      final data = {
        'id': 'post-1',
        'author_id': null,
        'is_anonymous': true,
        'title': 'Anonymous Post',
        'content': 'Secret',
        'category': 'community',
        'comment_count': 0,
        'created_at': '2024-04-01T10:00:00.000',
      };

      final post = NewsPost.fromMap(data);
      expect(post.isAnonymous, isTrue);
      expect(post.authorName, 'Anonymous');
      expect(post.authorAvatarUrl, isNull);
    });

    test('fromMap parses joined user data', () {
      final data = {
        'id': 'post-1',
        'author_id': 'user-123',
        'is_anonymous': false,
        'title': 'Expert Post',
        'content': 'Content',
        'category': 'meditation',
        'comment_count': 5,
        'created_at': '2024-04-01T10:00:00.000',
        'users': {
          'full_name': 'Dr. Smith',
          'avatar_url': 'https://example.com/avatar.png',
          'role': 'expert',
        },
      };

      final post = NewsPost.fromMap(data);
      expect(post.authorName, 'Dr. Smith');
      expect(post.authorAvatarUrl, 'https://example.com/avatar.png');
      expect(post.authorRole, 'expert');
    });

    test('fromMap parses likedBy from post_likes join', () {
      final data = {
        'id': 'post-1',
        'author_id': 'u1',
        'is_anonymous': false,
        'title': 'T',
        'content': 'C',
        'category': 'news',
        'comment_count': 0,
        'created_at': '2024-04-01T10:00:00.000',
        'post_likes': [
          {'user_id': 'user-a'},
          {'user_id': 'user-b'},
          {'user_id': 'user-c'},
        ],
      };

      final post = NewsPost.fromMap(data);
      expect(post.likeCount, 3);
      expect(post.isLikedBy('user-a'), isTrue);
      expect(post.isLikedBy('user-b'), isTrue);
      expect(post.isLikedBy('not-a-user'), isFalse);
    });

    test('toMap produces correct keys', () {
      final post = NewsPost(
        postId: 'post-1',
        authorId: 'user-1',
        authorName: 'A',
        authorRole: 'user',
        title: 'Title',
        content: 'Content',
        category: PostCategory.tips,
        likedBy: ['u1', 'u2'],
        commentCount: 3,
      );

      final map = post.toMap();
      expect(map['author_id'], 'user-1');
      expect(map['title'], 'Title');
      expect(map['content'], 'Content');
      expect(map['category'], 'tips');
      expect(map['likes_count'], 2);
      expect(map['comment_count'], 3);
      expect(map['id'], 'post-1');
    });

    test('toMap handles empty authorId', () {
      final post = NewsPost(
        postId: '', // empty postId
        authorId: '',
        authorName: 'A',
        authorRole: 'user',
        title: 'T',
        content: 'C',
        category: PostCategory.community,
      );

      final map = post.toMap();
      expect(map['author_id'], isNull);
      expect(map.containsKey('id'), isFalse);
    });

    test('copyWith updates specified fields', () {
      final original = NewsPost(
        postId: 'p1',
        authorId: 'u1',
        authorName: 'A',
        authorRole: 'user',
        title: 'Old Title',
        content: 'Content',
        category: PostCategory.community,
      );

      final copied = original.copyWith(
        title: 'New Title',
        commentCount: 5,
      );

      expect(copied.title, 'New Title');
      expect(copied.commentCount, 5);
      expect(copied.postId, 'p1'); // unchanged
    });

    test('createdAt defaults to DateTime.now()', () {
      final post = NewsPost(
        postId: 'p1',
        authorId: 'u1',
        authorName: 'A',
        authorRole: 'user',
        title: 'T',
        content: 'C',
        category: PostCategory.wellness,
      );

      expect(post.createdAt.difference(DateTime.now()).inSeconds, lessThan(1));
    });

    test('category enum name mapping works', () {
      expect(PostCategory.mentalHealth.name, 'mentalHealth');
      expect(PostCategory.meditation.name, 'meditation');
      expect(PostCategory.wellness.name, 'wellness');
      expect(PostCategory.tips.name, 'tips');
      expect(PostCategory.community.name, 'community');
      expect(PostCategory.news.name, 'news');
    });

    test('fromMap handles unknown category gracefully', () {
      final data = {
        'id': 'p1',
        'author_id': 'u1',
        'is_anonymous': false,
        'title': 'T',
        'content': 'C',
        'category': 'nonexistent_category',
        'comment_count': 0,
        'created_at': '2024-04-01T10:00:00.000',
      };

      final post = NewsPost.fromMap(data);
      expect(post.category, PostCategory.community); // orElse fallback
    });
  });

  group('PostComment model', () {
    test('creates with required fields', () {
      final comment = PostComment(
        commentId: 'c1',
        postId: 'p1',
        userId: 'u1',
        userName: 'User One',
        content: 'Nice post!',
      );

      expect(comment.isAnonymous, isFalse);
      expect(comment.parentCommentId, isNull);
      expect(comment.userAvatarUrl, isNull);
      expect(comment.createdAt, isA<DateTime>());
    });

    test('toMap produces correct keys', () {
      final comment = PostComment(
        commentId: 'c1',
        postId: 'p1',
        userId: 'u1',
        userName: 'User',
        content: 'Comment text',
        parentCommentId: 'parent-1',
        isAnonymous: true,
      );

      final map = comment.toMap();
      expect(map['post_id'], 'p1');
      expect(map['user_id'], 'u1');
      expect(map['is_anonymous'], isTrue);
      expect(map['parent_comment_id'], 'parent-1');
      expect(map['content'], 'Comment text');
      expect(map['id'], 'c1');
    });

    test('toMap handles empty userId', () {
      final comment = PostComment(
        commentId: 'c1',
        postId: 'p1',
        userId: '',
        userName: 'User',
        content: 'Comment',
      );

      final map = comment.toMap();
      expect(map['user_id'], isNull);
    });

    test('fromMap detects anonymous comment', () {
      final data = {
        'id': 'c1',
        'post_id': 'p1',
        'user_id': null,
        'is_anonymous': true,
        'content': 'Anon comment',
        'created_at': '2024-04-01T10:00:00.000',
      };

      final comment = PostComment.fromMap(data);
      expect(comment.isAnonymous, isTrue);
      expect(comment.userName, 'Anonymous');
      expect(comment.userAvatarUrl, isNull);
      expect(comment.userRole, isNull);
    });

    test('fromMap parses joined user data', () {
      final data = {
        'id': 'c1',
        'post_id': 'p1',
        'user_id': 'u1',
        'is_anonymous': false,
        'content': 'Expert comment',
        'created_at': '2024-04-01T10:00:00.000',
        'users': {
          'full_name': 'Dr. Expert',
          'avatar_url': 'https://example.com/avatar.png',
          'role': 'expert',
        },
      };

      final comment = PostComment.fromMap(data);
      expect(comment.userName, 'Dr. Expert');
      expect(comment.userAvatarUrl, 'https://example.com/avatar.png');
      expect(comment.userRole, 'expert');
    });

    test('createdAt defaults to DateTime.now()', () {
      final comment = PostComment(
        commentId: 'c1',
        postId: 'p1',
        userId: 'u1',
        userName: 'User',
        content: 'Comment',
      );

      expect(comment.createdAt.difference(DateTime.now()).inSeconds, lessThan(1));
    });
  });
}
