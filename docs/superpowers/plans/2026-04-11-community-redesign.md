# Community Feed Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign `NewsFeedPage` theo chủ đề "Organic Sanctuary" — glass header, pill chips, ambient shadow cards — giữ nguyên toàn bộ logic.

**Architecture:** Refactor in-place trên `lib/views/news/news_feed_page.dart`. Xóa bottom sheet filter và author filter UI. Thay AppBar Material bằng glass header dùng `BackdropFilter`. Post card dùng `Stack` với avatar lệch trái.

**Tech Stack:** Flutter, `google_fonts` (PlusJakartaSans + Manrope), `dart:ui` (ImageFilter), Supabase Realtime (không đổi).

---

## File thay đổi

| File | Loại |
|---|---|
| `lib/views/news/news_feed_page.dart` | Modify — UI overhaul, giữ logic |

---

## Task 1: Imports, color constants, Scaffold base

**Files:**
- Modify: `lib/views/news/news_feed_page.dart`

- [ ] **Step 1: Thêm imports cần thiết**

Thêm vào đầu file, ngay sau các import hiện có:

```dart
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
```

- [ ] **Step 2: Thêm color constants dưới cùng của file (sau class)**

```dart
// Organic Sanctuary color palette
const _kSurface = Color(0xFFDDFFE2);
const _kPrimary = Color(0xFF006B1B);
const _kOnPrimary = Color(0xFFD1FFC8);
const _kOnSurface = Color(0xFF0B361D);
const _kOnSurfaceVariant = Color(0xFF3B6447);
const _kSurfaceContainerLowest = Color(0xFFFFFFFF);
const _kSurfaceContainerHighest = Color(0xFFACECBB);
const _kPrimaryContainer = Color(0xFF76FB7A);
const _kSecondaryContainer = Color(0xFF86FAAC);
const _kOnSecondaryContainer = Color(0xFF005F32);
const _kTertiaryContainer = Color(0xFF11EAFF);
const _kOnTertiaryContainer = Color(0xFF005159);
const _kSurfaceContainerHigh = Color(0xFFB5F0C2);
const _kSurfaceContainer = Color(0xFFBEF5CA);
```

- [ ] **Step 3: Cập nhật `Scaffold` trong `build()`**

Thay thế toàn bộ `return Scaffold(...)` cũ bằng:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: _kSurface,
    extendBodyBehindAppBar: true,
    appBar: _buildGlassAppBar(),
    body: Column(
      children: [
        // Spacer cho glass header (SafeArea top + 72px header)
        SizedBox(height: MediaQuery.of(context).padding.top + 72),
        _buildFilterBar(),
        Expanded(child: _buildPostFeed()),
      ],
    ),
  );
}
```

- [ ] **Step 4: Tách post feed thành method riêng**

Thêm method `_buildPostFeed()` — di chuyển nội dung `StreamBuilder` hiện có ra khỏi `build()`:

```dart
Widget _buildPostFeed() {
  return StreamBuilder<List<NewsPost>>(
    stream: _newsService.streamPosts(category: _selectedCategory),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Không thể tải bài viết',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _kOnSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: _kOnSurfaceVariant),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _selectedCategory = null),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: _kOnPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator(color: _kPrimary));
      }

      final posts = snapshot.data!;
      final sortedPosts = _sortPosts(posts);

      if (sortedPosts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article_outlined, size: 80, color: _kSurfaceContainerHighest),
              const SizedBox(height: 16),
              const Text(
                'Chưa có bài viết nào',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _kOnSurface,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hãy là người đầu tiên chia sẻ!',
                style: TextStyle(color: _kOnSurfaceVariant),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => setState(() {}),
        color: _kPrimary,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 120),
          itemCount: sortedPosts.length,
          itemBuilder: (context, index) => _buildPostCard(sortedPosts[index]),
        ),
      );
    },
  );
}
```

- [ ] **Step 5: Xóa `AuthorFilter` khỏi state và `_filterPostsByAuthor` call**

Xóa dòng:
```dart
AuthorFilter _authorFilter = AuthorFilter.all;
```

Và trong `_buildPostFeed()`, xóa dòng `_filterPostsByAuthor(posts)` — dùng trực tiếp `posts` rồi sort:
```dart
final sortedPosts = _sortPosts(posts);  // không còn _filterPostsByAuthor
```

(Giữ `AuthorFilter` enum và `_filterPostsByAuthor` method trong file — không xóa, chỉ bỏ usage để tránh break.)

- [ ] **Step 6: Verify analyze**

```bash
cd /Users/nicotine/moodiki && flutter analyze lib/views/news/news_feed_page.dart
```

Expected: Có thể có warning về unused methods (`_buildFilterButton`, `_showFilterSheet`, v.v.) — bình thường, sẽ xóa ở Task 5.

- [ ] **Step 7: Commit**

```bash
git add lib/views/news/news_feed_page.dart
git commit -m "refactor(community): scaffold base + imports for Organic Sanctuary redesign"
```

---

## Task 2: Glass AppBar

**Files:**
- Modify: `lib/views/news/news_feed_page.dart`

- [ ] **Step 1: Thêm method `_buildGlassAppBar()`**

```dart
PreferredSizeWidget _buildGlassAppBar() {
  final user = SupabaseService.instance.currentUser;
  return PreferredSize(
    preferredSize: const Size.fromHeight(72),
    child: ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: _kSurface.withOpacity(0.80),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 72,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Avatar user hiện tại
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _kPrimaryContainer,
                      backgroundImage: (user?.userMetadata?['avatar_url'] as String?)?.isNotEmpty == true
                          ? NetworkImage(user!.userMetadata!['avatar_url'] as String)
                          : null,
                      child: (user?.userMetadata?['avatar_url'] as String?)?.isNotEmpty != true
                          ? Icon(Icons.person, size: 20, color: _kPrimary)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cộng đồng',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _kOnSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.search, color: _kOnSurface),
                      onPressed: () {}, // placeholder — search chưa có feature
                      splashRadius: 22,
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: _kOnSurface),
                      onPressed: () {}, // placeholder
                      splashRadius: 22,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: _kOnSurface),
                      onPressed: () async {
                        final changed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreatePostPage(),
                          ),
                        );
                        if (changed == true && mounted) setState(() {});
                      },
                      splashRadius: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
```

- [ ] **Step 2: Xóa `AppBar` cũ**

Trong `build()`, xóa block `appBar: AppBar(...)` cũ (đã được thay bằng `appBar: _buildGlassAppBar()` ở Task 1).

- [ ] **Step 3: Verify analyze**

```bash
cd /Users/nicotine/moodiki && flutter analyze lib/views/news/news_feed_page.dart
```

Expected: Không có error mới.

- [ ] **Step 4: Commit**

```bash
git add lib/views/news/news_feed_page.dart
git commit -m "feat(community): glass header with BackdropFilter blur"
```

---

## Task 3: Filter Bar — Pill Chips + Sort Menu

**Files:**
- Modify: `lib/views/news/news_feed_page.dart`

- [ ] **Step 1: Thêm GlobalKey cho sort button vào state**

Trong class `_NewsFeedPageState`, thêm:

```dart
final _sortButtonKey = GlobalKey();
```

- [ ] **Step 2: Thêm method `_buildFilterBar()`**

```dart
Widget _buildFilterBar() {
  return Container(
    color: _kSurface,
    padding: const EdgeInsets.fromLTRB(16, 8, 4, 12),
    child: Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPillChip('Tất cả', null),
                const SizedBox(width: 8),
                ...PostCategory.values.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildPillChip(cat.categoryDisplayName, cat),
                )),
              ],
            ),
          ),
        ),
        IconButton(
          key: _sortButtonKey,
          icon: const Icon(Icons.tune, color: _kOnSurfaceVariant),
          onPressed: _showSortMenu,
          splashRadius: 22,
          tooltip: 'Sắp xếp',
        ),
      ],
    ),
  );
}
```

- [ ] **Step 3: Thêm method `_buildPillChip()`**

```dart
Widget _buildPillChip(String label, PostCategory? category) {
  final isSelected = _selectedCategory == category;
  return GestureDetector(
    onTap: () => setState(() => _selectedCategory = category),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? _kPrimary : _kSurfaceContainerHighest,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected ? _kOnPrimary : _kOnSurfaceVariant,
        ),
      ),
    ),
  );
}
```

- [ ] **Step 4: Thêm `_showSortMenu()` và `_sortMenuItem()`**

```dart
void _showSortMenu() {
  final RenderBox button =
      _sortButtonKey.currentContext!.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(Offset.zero, ancestor: overlay),
      button.localToGlobal(
        button.size.bottomRight(Offset.zero),
        ancestor: overlay,
      ),
    ),
    Offset.zero & overlay.size,
  );

  showMenu<SortBy>(
    context: context,
    position: position,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
    items: [
      _sortMenuItem('Mới nhất', SortBy.latest),
      _sortMenuItem('Hot nhất', SortBy.hot),
      _sortMenuItem('Nhiều like nhất', SortBy.mostLiked),
      _sortMenuItem('Nhiều bình luận nhất', SortBy.mostDiscussed),
    ],
  ).then((value) {
    if (value != null && mounted) setState(() => _sortBy = value);
  });
}

PopupMenuItem<SortBy> _sortMenuItem(String label, SortBy value) {
  return PopupMenuItem<SortBy>(
    value: value,
    child: Row(
      children: [
        if (_sortBy == value)
          const Icon(Icons.check, size: 18, color: _kPrimary)
        else
          const SizedBox(width: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: _kOnSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 5: Thêm extension `categoryDisplayName` lên `PostCategory`**

`PostCategory` đã có `categoryDisplayName` trên `NewsPost`, nhưng filter chip cần getter trực tiếp trên enum. Thêm extension sau phần color constants:

```dart
extension _PostCategoryDisplay on PostCategory {
  String get categoryDisplayName {
    switch (this) {
      case PostCategory.mentalHealth:
        return 'Sức khỏe';
      case PostCategory.meditation:
        return 'Thiền';
      case PostCategory.wellness:
        return 'Wellness';
      case PostCategory.tips:
        return 'Mẹo';
      case PostCategory.community:
        return 'Cộng đồng';
      case PostCategory.news:
        return 'Tin tức';
    }
  }
}
```

- [ ] **Step 6: Verify analyze**

```bash
cd /Users/nicotine/moodiki && flutter analyze lib/views/news/news_feed_page.dart
```

Expected: Không có error.

- [ ] **Step 7: Commit**

```bash
git add lib/views/news/news_feed_page.dart
git commit -m "feat(community): pill chip filter bar + sort menu"
```

---

## Task 4: Post Card Redesign

**Files:**
- Modify: `lib/views/news/news_feed_page.dart`

- [ ] **Step 1: Cập nhật `_getCategoryColor()`**

Thay thế method cũ bằng:

```dart
Color _getCategoryColor(PostCategory category) {
  switch (category) {
    case PostCategory.mentalHealth:
      return _kOnSecondaryContainer;
    case PostCategory.meditation:
      return const Color(0xFF7B3FC4); // purple tint
    case PostCategory.wellness:
      return _kPrimary;
    case PostCategory.tips:
      return _kOnSecondaryContainer;
    case PostCategory.community:
      return _kOnTertiaryContainer;
    case PostCategory.news:
      return _kOnSurfaceVariant;
  }
}

Color _getCategoryBgColor(PostCategory category) {
  switch (category) {
    case PostCategory.mentalHealth:
      return _kSecondaryContainer;
    case PostCategory.meditation:
      return const Color(0xFFE9D5FF); // purple-100
    case PostCategory.wellness:
      return _kPrimaryContainer;
    case PostCategory.tips:
      return _kSecondaryContainer;
    case PostCategory.community:
      return _kTertiaryContainer;
    case PostCategory.news:
      return _kSurfaceContainerHigh;
  }
}
```

- [ ] **Step 2: Thêm helper `_buildAvatarWidget()`**

```dart
Widget _buildAvatarWidget(NewsPost post) {
  final isAnon = post.authorName == 'Anonymous';
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: _kSurface, width: 4),
    ),
    child: CircleAvatar(
      radius: 24,
      backgroundColor: isAnon ? _kSurfaceContainerHighest : _kPrimaryContainer,
      backgroundImage: !isAnon &&
              post.authorAvatarUrl != null &&
              post.authorAvatarUrl!.isNotEmpty
          ? (_isBase64(post.authorAvatarUrl!)
                  ? MemoryImage(base64Decode(post.authorAvatarUrl!))
                  : NetworkImage(post.authorAvatarUrl!))
              as ImageProvider
          : null,
      child: isAnon
          ? const Icon(Icons.visibility_off, size: 20, color: _kOnSurfaceVariant)
          : (post.authorAvatarUrl == null || post.authorAvatarUrl!.isEmpty
              ? Text(
                  post.authorName[0].toUpperCase(),
                  style: const TextStyle(
                    color: _kPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null),
    ),
  );
}
```

- [ ] **Step 3: Thêm helper `_buildCategoryBadge()`**

```dart
Widget _buildCategoryBadge(NewsPost post) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _getCategoryBgColor(post.category),
      borderRadius: BorderRadius.circular(9999),
    ),
    child: Text(
      post.categoryDisplayName.toUpperCase(),
      style: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: _getCategoryColor(post.category),
        letterSpacing: 0.5,
      ),
    ),
  );
}
```

- [ ] **Step 4: Rewrite `_buildPostCardContent()`**

Thay thế toàn bộ method cũ bằng:

```dart
Widget _buildPostCardContent(NewsPost post, bool isLiked, int likeCount) {
  return GestureDetector(
    onTap: () async {
      final changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
      );
      if (changed == true && mounted) setState(() {});
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kOnSurface.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main content — left padding 44 to clear avatar
          Padding(
            padding: const EdgeInsets.only(left: 44, right: 16, top: 20, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  post.authorName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: _kOnSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (post.authorRole == 'expert') ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _kPrimaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Expert',
                                    style: GoogleFonts.manrope(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _kPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatTime(post.createdAt),
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: _kOnSurfaceVariant.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryBadge(post),
                    if (post.authorId == currentUserId)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: _kOnSurfaceVariant,
                          size: 20,
                        ),
                        onSelected: (value) => _handlePostAction(value, post),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Chỉnh sửa'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Xóa', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  post.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _kOnSurface,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 6),

                // Content preview
                Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: _kOnSurfaceVariant,
                    height: 1.5,
                  ),
                ),

                // Image
                if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        post.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: _kSurfaceContainerHighest,
                          child: const Icon(Icons.broken_image,
                              size: 48, color: _kOnSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Divider
                Container(height: 1, color: _kSurfaceContainer),

                // Action bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      // Like
                      InkWell(
                        onTap: () => _handleLikeTap(post, isLiked, likeCount),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked
                                    ? Colors.red
                                    : _kOnSurfaceVariant,
                                size: 22,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$likeCount',
                                style: GoogleFonts.manrope(
                                  color: _kOnSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Comment
                      Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline,
                              color: _kPrimary, size: 20),
                          const SizedBox(width: 6),
                          StreamBuilder<int>(
                            stream:
                                _newsService.streamCommentCount(post.postId),
                            builder: (context, snapshot) {
                              final count =
                                  snapshot.data ?? post.commentCount;
                              return Text(
                                '$count',
                                style: GoogleFonts.manrope(
                                  color: _kOnSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Share
                      Icon(Icons.share_outlined,
                          color: _kOnSurfaceVariant, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Asymmetric avatar — lệch -8px ra ngoài bên trái
          Positioned(
            left: -8,
            top: 20,
            child: _buildAvatarWidget(post),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 5: Thêm helper `_handleLikeTap()` để tách logic like ra khỏi card**

```dart
void _handleLikeTap(NewsPost post, bool currentlyLiked, int currentCount) async {
  if (post.postId.isEmpty) return;
  if (_likeUpdating.contains(post.postId)) return;

  final nextLiked = !currentlyLiked;
  final nextCount = nextLiked
      ? currentCount + 1
      : (currentCount - 1 < 0 ? 0 : currentCount - 1);

  setState(() {
    _likeUpdating.add(post.postId);
    _likeState[post.postId] = nextLiked;
    _likeCountState[post.postId] = nextCount;
  });

  try {
    await _newsService.toggleLike(post.postId, currentUserId);
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _likeState[post.postId] = currentlyLiked;
      _likeCountState[post.postId] = currentCount;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) setState(() => _likeUpdating.remove(post.postId));
  }
}
```

- [ ] **Step 6: Cập nhật `_buildPostCard()` để dùng `_handleLikeTap` — xóa GestureDetector wrap cũ**

`_buildPostCard()` hiện tại wrap `_buildPostCardContent()` bằng `GestureDetector` riêng. Nhưng `_buildPostCardContent` mới đã tự có `GestureDetector` bên trong. Sửa `_buildPostCard()` thành:

```dart
Widget _buildPostCard(NewsPost post) {
  if (post.postId.isEmpty) {
    return _buildPostCardContent(post, post.isLikedBy(currentUserId), post.likeCount);
  }

  _syncLikeOverridesIfServerCaughtUp(post);
  final isLiked = _likeState[post.postId] ?? post.isLikedBy(currentUserId);
  final likeCount = _likeCountState[post.postId] ?? post.likeCount;

  return _buildPostCardContent(post, isLiked, likeCount);
}
```

- [ ] **Step 7: Verify analyze**

```bash
cd /Users/nicotine/moodiki && flutter analyze lib/views/news/news_feed_page.dart
```

Expected: Không có error.

- [ ] **Step 8: Commit**

```bash
git add lib/views/news/news_feed_page.dart
git commit -m "feat(community): Organic Sanctuary post card with asymmetric avatar"
```

---

## Task 5: Cleanup — Xóa methods cũ

**Files:**
- Modify: `lib/views/news/news_feed_page.dart`

- [ ] **Step 1: Xóa các methods không còn dùng**

Xóa hoàn toàn các methods sau khỏi class:
- `_buildFilterButton()`
- `_showFilterSheet()`
- `_buildSortFilter()`
- `_buildAuthorFilter()`
- `_buildCategoryFilter()`
- `_buildCategoryChip(String label, PostCategory? category)` — cái cũ (method mới là `_buildPillChip`)

Giữ lại:
- `AuthorFilter` enum — giữ nguyên (không xóa)
- `_filterPostsByAuthor()` — giữ nguyên (không xóa)
- `_sortPosts()` — giữ nguyên
- Tất cả optimistic like methods

- [ ] **Step 2: Xóa import không dùng**

Nếu `import 'package:flutter/foundation.dart'` không còn dùng sau khi xóa `kDebugMode` hay `debugPrint` (kiểm tra xem `debugPrint` còn ở đâu không), xóa import đó.

- [ ] **Step 3: Final analyze**

```bash
cd /Users/nicotine/moodiki && flutter analyze lib/views/news/news_feed_page.dart
```

Expected: Không có warning hay error.

- [ ] **Step 4: Chạy thử trên thiết bị/simulator**

```bash
cd /Users/nicotine/moodiki && flutter run
```

Kiểm tra thủ công:
- Header glass blur hiển thị đúng
- Chip filter chuyển màu khi tap
- Sort menu mở đúng vị trí
- Post card có avatar lệch sang trái
- Like/unlike hoạt động (optimistic)
- Navigate sang PostDetailPage khi tap card
- Navigate sang CreatePostPage khi tap `+`

- [ ] **Step 5: Final commit**

```bash
git add lib/views/news/news_feed_page.dart
git commit -m "feat(community): complete Organic Sanctuary redesign - cleanup"
```
