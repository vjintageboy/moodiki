# Community Feed Redesign — Organic Sanctuary

**Date:** 2026-04-11  
**Scope:** `lib/views/news/news_feed_page.dart` (refactor in-place, UI only)  
**Approach:** Phương án A — Refactor in-place, giữ nguyên toàn bộ logic

---

## 1. Tổng quan

Thiết kế lại phần Cộng đồng theo chủ đề **"Organic Sanctuary"** từ `stitch/` — premium, editorial, không border line, dùng tonal surface hierarchy thay thế.

Không thay đổi:
- Logic sort (latest / hot / mostLiked / mostDiscussed)
- Logic filter category
- Optimistic like/unlike
- StreamBuilder posts
- Navigation đến PostDetailPage / CreatePostPage
- Edit/delete post của chính mình

Loại bỏ:
- Author filter (All / My Posts / Expert / Anonymous) — bỏ hẳn khỏi UI
- Bottom sheet filter — thay bằng inline sort menu

---

## 2. Design System

### Colors (từ stitch/DESIGN.md)
| Token | Hex | Dùng cho |
|---|---|---|
| `primary` | `#006b1b` | Active chip, icon chat |
| `surface` | `#ddffe2` | Scaffold background |
| `surface-container-lowest` | `#ffffff` | Card background |
| `surface-container-highest` | `#acecbb` | Inactive chip background |
| `on-surface` | `#0b361d` | Text chính, tiêu đề |
| `on-surface-variant` | `#3b6447` | Text phụ, metadata |
| `on-primary` | `#d1ffc8` | Text trên active chip |
| `secondary-container` | `#86faac` | Badge Tips |
| `tertiary-container` | `#11eaff` | Badge Hỏi đáp |

**Quy tắc:**
- Không dùng `#000000` — dùng `on-surface (#0b361d)`
- Không dùng border 1px solid để phân cách — dùng color shift
- Ambient shadow: `0px 12px 32px rgba(11,54,29,0.06)` thay vì standard drop shadow

### Typography
- **Headlines / Title card:** `Plus Jakarta Sans`, extrabold/bold — via `google_fonts`
- **Body / Labels / Meta:** `Manrope` — via `google_fonts`

### Border Radius
- Card: `24px`
- Chip: `full` (9999px)
- Image trong card: `12px`
- Badge category: `full`

---

## 3. Header (Glass AppBar)

Thay `AppBar` Material bằng custom header trong `Stack`:

```
Stack
└── Positioned(top: 0) → ClipRect → BackdropFilter(blur: 20)
    └── Container(color: surface.withOpacity(0.80))
        └── SafeArea → Row
            ├── CircleAvatar (current user, 40px) + "Cộng đồng" (Plus Jakarta Sans, extrabold)
            └── Row: IconButton(search) + IconButton(notifications) + IconButton(add)
```

- Fixed ở top, z-index cao nhất
- Body có `padding-top` đủ để tránh header che nội dung (SafeArea + header height ~72px)
- Màu icon: `on-surface (#0b361d)`
- Tap `add` → điều hướng đến `CreatePostPage` (giữ nguyên logic)

---

## 4. Filter Bar

Nằm ngay dưới header, trong phần body (không fixed):

```
Row
├── Expanded → SingleChildScrollView(horizontal)
│   └── Row: [Chip "Tất cả"] [Chip cat1] [Chip cat2] ...
└── IconButton(Icons.tune) → _showSortMenu()
```

**Chip:**
- Active: `primary (#006b1b)` bg, `on-primary (#d1ffc8)` text, borderRadius full, padding `h:20 v:10`
- Inactive: `surface-container-highest (#acecbb)` bg, `on-surface-variant (#3b6447)` text, no border

**Sort menu:**
- `showMenu()` anchored tại vị trí icon `tune`
- 4 items: Mới nhất, Hot nhất, Nhiều like nhất, Nhiều bình luận nhất
- Item đang chọn hiển thị icon check màu `primary`

**Author filter:** Bỏ hoàn toàn.

---

## 5. Post Card

Mỗi bài post render bằng `_buildPostCardContent()` — layout thống nhất full-width:

```
Container(margin: h:16 v:12, decoration: rounded-24 + ambient-shadow)
└── Column
    ├── Padding(all: 20) → Row [Header]
    │   ├── Stack: asymmetric avatar (-12px left offset) + border circle
    │   ├── Column: authorName (Plus Jakarta Sans bold) + time (Manrope sm)
    │   └── CategoryBadge (pill, 10px uppercase)
    │   └── (nếu own post) PopupMenuButton ...
    ├── Padding(h:20) → title (Plus Jakarta Sans extrabold, 20px)
    ├── Padding(h:20, top:6) → content (Manrope, 14px, maxLines:3)
    ├── (nếu có ảnh) ClipRRect(12px) → Image.network (aspect 16:9)
    └── Padding(all:16, top:12) → Divider(color: surface-container) → ActionBar
        ├── LikeButton (heart icon + count)
        ├── SizedBox(24)
        ├── CommentCount (bubble icon + StreamBuilder count)
        └── Spacer + ShareIcon
```

**Asymmetric avatar:**
- `Stack` với `Positioned`: avatar 48px được wrap bởi `Container` có border `4px surface (#ddffe2)`
- Toàn bộ header row có `padding-left: 24` để bù cho phần avatar lệch ra ngoài

**Category badge colors:**
- `mentalHealth` → `secondary-container` bg
- `meditation` → purple tint
- `wellness` → `primary-container` bg
- `tips` → `secondary-container` bg
- `community` → `tertiary-container` bg
- `news` → `surface-container-high` bg

---

## 6. Empty / Error / Loading States

Giữ nguyên logic nhưng cập nhật màu sắc:
- Loading: `CircularProgressIndicator(color: primary)`
- Error icon: `Colors.red.shade300` (giữ nguyên)
- Empty state icon: `on-surface-variant` thay vì `grey.shade300`

---

## 7. Những thứ KHÔNG thay đổi

- `SortBy` enum và `_sortPosts()`
- `PostCategory` enum — giữ nguyên; `_getCategoryColor()` **cập nhật màu** trả về theo palette Organic Sanctuary (giữ switch-case, đổi Color values)
- `AuthorFilter` enum giữ trong code (xóa UI nhưng không xóa enum để tránh break)
- `_buildFilterButton()` → xóa hàm này
- `_showFilterSheet()` → xóa hàm này
- `_buildSortFilter()`, `_buildAuthorFilter()`, `_buildCategoryFilter()` → xóa, thay bằng inline widget mới
- Tất cả optimistic like logic
- `_handlePostAction()`, `_editPost()`, `_deletePost()`
- `_isBase64()`, `_syncLikeOverridesIfServerCaughtUp()`

---

## 8. Dependencies cần thêm

`google_fonts` đã có trong `pubspec.yaml` (dùng cho AppTheme). Không cần thêm package mới.

---

## 9. Files thay đổi

| File | Thay đổi |
|---|---|
| `lib/views/news/news_feed_page.dart` | Refactor toàn bộ UI, giữ logic |
