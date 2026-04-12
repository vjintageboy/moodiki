# 🧠 Mental Health Platform (Moodiki) - Project Overview

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue.svg)](https://flutter.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)](https://supabase.com/)
[![License](https://img.shields.io/badge/License-Private-red.svg)]()

> **A comprehensive mental health and wellness platform** connecting users with mental health experts, providing mood tracking, meditation resources, AI-powered chatbot support, and a supportive community forum.

---

## 📑 Table of Contents

1. [Project Overview](#-project-overview-1)
   - [What is Moodiki?](#what-is-moodiki)
   - [Key Features](#key-features)
   - [Target Audience](#target-audience)
2. [Architecture](#-architecture)
   - [System Architecture](#system-architecture)
   - [Technology Stack](#technology-stack)
   - [Data Flow](#data-flow)
   - [Authentication Flow](#authentication-flow)
3. [Database Schema](#-database-schema)
   - [Tables Overview](#tables-overview)
   - [Entity Relationships](#entity-relationships)
4. [Project Structure](#-project-structure)
   - [Directory Layout](#directory-layout)
   - [Key Modules](#key-modules)
5. [Features Documentation](#-features-documentation)
6. [User Roles & Permissions](#-user-roles--permissions)
7. [Core Services](#-core-services)
8. [Setup & Installation](#-setup--installation)
9. [Environment Configuration](#-environment-configuration)
10. [Development Guide](#-development-guide)
11. [API Integration](#-api-integration)
12. [Deployment](#-deployment)
13. [Troubleshooting](#-troubleshooting)
14. [Contributing](#-contributing)
15. [Resources](#-resources)

---

## 🎯 Project Overview

### What is Moodiki?

**Moodiki** (n04_app) is a Flutter-based mobile application designed to support mental health and wellness. The platform serves as a bridge between users seeking mental health support and certified professionals (experts), while also providing self-care tools like mood tracking, guided meditations, AI chatbot assistance, and a supportive community forum.

**Version:** 1.0.0+1  
**Platform:** iOS, Android, Web  
**Backend:** Supabase (PostgreSQL, Auth, Storage, Realtime)

### Key Features

#### 🔐 **1. Multi-Role Authentication System**
- User registration and login
- Expert registration with approval workflow
- Admin dashboard access
- Role-based access control (User, Expert, Admin)

#### 📊 **2. Mood Tracking & Analytics**
- Daily mood logging with 5-level mood scale
- Emotion factors and tags
- Historical mood trends and analytics
- Mood calendar visualization
- Streak tracking for daily engagement

#### 🧘 **3. Meditation Library**
- Curated guided meditation audio library
- Categories: Sleep, Anxiety, Mindfulness, Stress Relief, etc.
- Beginner, Intermediate, Advanced levels
- Audio player with progress tracking
- Ratings and reviews

#### 👨‍⚕️ **4. Expert Booking & Appointments**
- Browse certified mental health experts
- Filter by specialization (Anxiety, Depression, Stress, etc.)
- View expert profiles with credentials
- Book appointments (chat, video, audio sessions)
- MoMo payment integration
- Appointment management and rescheduling

#### 💬 **5. Real-time Chat System**
- 1-on-1 messaging between users and experts
- Appointment-based chat rooms
- Real-time message delivery via Supabase Realtime
- Message history and pinning

#### 🤖 **6. AI Mental Health Chatbot**
- Powered by Google Gemini AI
- 24/7 available mental health assistant
- Conversation history and context awareness
- Personalized responses based on user profile

#### 📰 **7. Community Forum**
- Share experiences and support each other
- Post creation with text and images
- Comments and threaded replies
- Like system
- Anonymous posting option
- Content moderation by admins

#### 🔔 **8. Notification System**
- In-app notifications
- Appointment reminders
- Expert approval notifications
- Message notifications

#### 🏆 **9. Streak & Gamification**
- Daily activity streak tracking
- Longest streak records
- Motivation for consistent engagement

#### 👑 **10. Admin Dashboard**
- User management (view, edit, delete, role assignment)
- Expert approval workflow (review credentials, approve/reject)
- Meditation content management (CRUD operations)
- Community post moderation
- Platform analytics and statistics

#### 🩺 **11. Expert Dashboard**
- View and manage appointments
- Schedule management with availability slots
- Client chat access
- Analytics (earnings, session stats, ratings)
- Profile and credential management

#### 👤 **12. User Profile Management**
- Edit profile information
- Avatar upload
- Preferences and goals
- View activity history
- Appointment and mood history

#### 🌍 **13. Internationalization (i18n)**
- Multi-language support (English, Vietnamese)
- Localized content and UI

### Target Audience

#### **Primary Users:**
- **Individuals** seeking mental health support
- **Students** dealing with academic stress
- **Professionals** managing work-life balance
- **Anyone** interested in mindfulness and wellness

#### **Experts:**
- Licensed therapists and counselors
- Psychologists
- Mental health professionals
- Wellness coaches

#### **Administrators:**
- Platform managers
- Content moderators
- Customer support team

---

## 🏗️ Architecture

### System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Mobile App                      │
│  (iOS, Android, Web) - Cross-platform UI with Flutter      │
└─────────────┬───────────────────────────────┬───────────────┘
              │                               │
              │                               │
    ┌─────────▼─────────┐         ┌──────────▼──────────┐
    │   Supabase        │         │   Node.js Backend   │
    │   Backend         │         │   (Payment Server)  │
    │                   │         │                     │
    │ • Auth            │         │ • MoMo Payment API  │
    │ • PostgreSQL DB   │         │ • Webhook Handler   │
    │ • Storage         │         └─────────────────────┘
    │ • Realtime        │
    │ • Row Level       │
    │   Security (RLS)  │
    └─────────┬─────────┘
              │
    ┌─────────▼─────────┐
    │  External APIs    │
    │                   │
    │ • Google Gemini   │
    │   (AI Chatbot)    │
    │ • MoMo Payment    │
    │   Gateway         │
    └───────────────────┘
```

### Technology Stack

#### **Frontend**
- **Framework:** Flutter 3.9.2 (Dart SDK)
- **State Management:** Provider pattern
- **Navigation:** go_router 16.3.0
- **UI Components:**
  - Material Design
  - Custom neumorphic designs
  - Google Fonts
  - Cupertino Icons

#### **Backend**
- **BaaS:** Supabase
  - PostgreSQL database
  - Authentication (JWT-based)
  - Storage (file uploads)
  - Realtime subscriptions
  - Row Level Security (RLS) policies
- **Payment Server:** Node.js + Express
  - MoMo payment integration
  - CORS support

#### **Key Dependencies**
```yaml
dependencies:
  flutter: sdk
  supabase_flutter: ^2.12.0       # Backend integration
  go_router: ^16.3.0              # Navigation
  provider: ^6.1.1                # State management
  google_generative_ai: ^0.4.7   # Gemini AI chatbot
  audioplayers: ^6.1.0            # Meditation audio
  table_calendar: ^3.1.2          # Appointment calendar
  image_picker: ^1.2.0            # Image uploads
  flutter_dotenv: ^5.2.1          # Environment variables
  google_fonts: ^6.2.1            # Typography
  intl: ^0.20.2                   # Internationalization
  crypto: ^3.0.3                  # MoMo signature
  url_launcher: ^6.3.0            # Open MoMo app
  http: ^1.2.0                    # HTTP requests
```

#### **External APIs**
- **Google Gemini AI:** Mental health chatbot
- **MoMo Payment Gateway:** Appointment payments

### Data Flow

#### **User Flow Example: Booking an Appointment**
```
1. User browses experts (lib/views/expert/expert_list_page.dart)
   └─> Fetches from `experts` + `users` tables (Supabase)

2. User selects expert → View details (expert_detail_page.dart)
   └─> Shows bio, specialization, rating, availability

3. User clicks "Book Appointment" → Booking page (booking_page.dart)
   └─> Selects date/time from expert's availability
   └─> Chooses call type (chat/video/audio)
   └─> Enters notes

4. User proceeds to payment (mock_payment_page.dart)
   └─> Calls Node.js backend (/momo/create)
   └─> Backend generates MoMo payment request
   └─> Returns payment URL

5. User completes payment → Returns to app
   └─> Creates appointment record in `appointments` table
   └─> Sends notification to expert
   └─> Creates chat room in `chat_rooms` table

6. Expert receives notification and can manage appointment
```

### Authentication Flow

```
┌─────────────────┐
│  User Opens App │
└────────┬────────┘
         │
         ▼
┌────────────────────────┐
│ Check Supabase Auth    │
│ auth.currentUser       │
└────────┬───────────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌────────┐  ┌──────────────────┐
│ Logged │  │ Not Authenticated │
│ In     │  └────────┬──────────┘
└───┬────┘           │
    │                ▼
    │         ┌──────────────┐
    │         │ Welcome Page │
    │         │ Login/Signup │
    │         └──────┬───────┘
    │                │
    │                ▼
    │         ┌─────────────────────┐
    │         │ Supabase Auth       │
    │         │ signInWithPassword  │
    │         │ or signUp           │
    │         └──────┬──────────────┘
    │                │
    │                ▼
    │         ┌──────────────────┐
    │         │ Fetch user role  │
    │         │ from users table │
    │         └──────┬───────────┘
    └────────────────┘
             │
             ▼
     ┌───────────────────┐
     │ Route based on    │
     │ User Role:        │
     │                   │
     │ • admin → Admin   │
     │   Dashboard       │
     │ • expert → Expert │
     │   Dashboard       │
     │ • user → Home     │
     │   Page            │
     └───────────────────┘
```

**Authentication Features:**
- Email/password authentication via Supabase Auth
- JWT token-based sessions
- Secure password hashing (handled by Supabase)
- Role verification from `users.role` column
- Protected routes based on user role

---

## 🗄️ Database Schema

### Tables Overview

The application uses **Supabase PostgreSQL** with **15 tables** total:

| Table Name | Purpose | Key Relationships |
|------------|---------|-------------------|
| `users` | User accounts and profiles | Links to `auth.users`, parent for `experts` |
| `experts` | Expert-specific data | Foreign key to `users(id)` |
| `expert_availability` | Expert schedule slots | Foreign key to `experts(id)` |
| `appointments` | Booking records | Links `users` and `experts` |
| `meditations` | Meditation content library | Standalone |
| `mood_entries` | User mood logs | Foreign key to `users(id)` |
| `posts` | Community forum posts | Foreign key to `users(id)` |
| `post_comments` | Post comments/replies | Foreign key to `posts(id)`, self-referencing |
| `post_likes` | Post like records | Foreign keys to `posts` and `users` |
| `chat_rooms` | Chat conversations | Optional link to `appointments` |
| `messages` | Chat messages | Foreign key to `chat_rooms(id)` and `users(id)` |
| `chat_participants` | Room membership | Foreign keys to `chat_rooms` and `users` |
| `ai_conversations` | AI chatbot conversation threads | Foreign key to `users(id)` |
| `ai_messages` | AI chat message history | Foreign key to `ai_conversations(id)` |
| `notifications` | User notifications | Foreign key to `users(id)` |

### Detailed Schema

#### **1. users** (Core user table)
```sql
CREATE TABLE public.users (
  id uuid PRIMARY KEY,                    -- Links to auth.users(id)
  email varchar UNIQUE NOT NULL,
  full_name varchar,
  avatar_url text,
  role varchar DEFAULT 'user',            -- 'user' | 'expert' | 'admin'
  streak_count integer DEFAULT 0,
  longest_streak integer DEFAULT 0,
  date_of_birth timestamp with time zone,
  gender varchar,
  goals text[],                           -- Array of user goals
  preferences jsonb,                      -- User preferences (JSON)
  last_login timestamp with time zone,
  total_activities integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  FOREIGN KEY (id) REFERENCES auth.users(id)
);
```

**Key Points:**
- `id` is the Supabase Auth user ID
- `role` determines access level (enum-like: user, expert, admin)
- `goals` and `preferences` store user-specific settings
- `streak_count` tracks daily engagement

#### **2. experts** (Expert profile extension)
```sql
CREATE TABLE public.experts (
  id uuid PRIMARY KEY,                    -- Same as users(id)
  bio text,
  specialization varchar,                 -- e.g., "Anxiety", "Depression"
  hourly_rate integer DEFAULT 0,          -- Price per session (VND)
  rating numeric DEFAULT 0.0,             -- Average rating (0-5)
  total_reviews integer DEFAULT 0,
  is_approved boolean DEFAULT false,      -- Admin approval status
  years_experience integer DEFAULT 0,
  license_number varchar,                 -- Professional license
  license_url text,                       -- Uploaded license document
  certificate_urls text[],                -- Multiple certificates
  education varchar,
  university varchar,
  graduation_year integer,
  title varchar,                          -- e.g., "Dr.", "Ms."
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  FOREIGN KEY (id) REFERENCES public.users(id)
);
```

**Key Points:**
- One-to-one relationship with `users`
- `is_approved` controls expert visibility (admin approval required)
- Stores professional credentials (licenses, certificates)

#### **3. expert_availability** (Expert schedule)
```sql
CREATE TABLE public.expert_availability (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  expert_id uuid NOT NULL,
  day_of_week integer CHECK (day_of_week >= 0 AND day_of_week <= 6), -- 0=Sunday
  start_time time without time zone NOT NULL,
  end_time time without time zone NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  FOREIGN KEY (expert_id) REFERENCES public.experts(id)
);
```

**Key Points:**
- Multiple slots per expert
- `day_of_week`: 0 (Sunday) to 6 (Saturday)
- Time slots define when expert is available

#### **4. appointments** (Bookings)
```sql
CREATE TABLE public.appointments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid,
  expert_id uuid,
  appointment_date timestamp with time zone NOT NULL,
  duration_minutes integer DEFAULT 60,
  call_type varchar DEFAULT 'chat',          -- 'chat' | 'video' | 'audio'
  status varchar DEFAULT 'pending',          -- 'pending' | 'confirmed' | 'cancelled' | 'completed'
  payment_status varchar DEFAULT 'unpaid',   -- 'unpaid' | 'paid' | 'refunded'
  payment_id varchar,                        -- MoMo transaction ID
  payment_trans_id varchar,
  expert_base_price integer,
  user_notes text,
  cancelled_at timestamp with time zone,
  cancelled_by uuid,
  cancelled_role varchar,                    -- 'user' | 'expert' | 'admin'
  cancellation_reason text,
  refund_status varchar DEFAULT 'none',
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  FOREIGN KEY (user_id) REFERENCES public.users(id),
  FOREIGN KEY (expert_id) REFERENCES public.experts(id)
);
```

**Key Points:**
- Links users and experts
- Payment tracking (MoMo integration)
- Cancellation details (who, when, why)
- Multiple call types (chat, video, audio)

#### **5. meditations** (Content library)
```sql
CREATE TABLE public.meditations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title varchar NOT NULL,
  description text,
  category varchar,                       -- e.g., "Sleep", "Anxiety"
  duration_minutes integer,
  audio_url text NOT NULL,                -- Supabase Storage URL
  thumbnail_url text,
  level varchar DEFAULT 'beginner',       -- 'beginner' | 'intermediate' | 'advanced'
  rating numeric DEFAULT 0.0,
  total_reviews integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);
```

#### **6. mood_entries** (Mood tracking)
```sql
CREATE TABLE public.mood_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid,
  mood_score integer CHECK (mood_score >= 1 AND mood_score <= 5), -- 1=Very Bad, 5=Very Good
  note text,
  emotion_factors text[],                 -- e.g., ["work", "family", "health"]
  tags text[],
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  FOREIGN KEY (user_id) REFERENCES public.users(id)
);
```

**Key Points:**
- Mood scale: 1 (very bad) to 5 (very good)
- `emotion_factors` and `tags` for categorization
- Used for analytics and trends

#### **7-9. Community Forum Tables**

```sql
-- Posts
CREATE TABLE public.posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id uuid,
  title varchar NOT NULL,
  content text NOT NULL,
  image_url text,
  category varchar DEFAULT 'community',
  is_anonymous boolean DEFAULT false,
  likes_count integer DEFAULT 0,
  comment_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  FOREIGN KEY (author_id) REFERENCES public.users(id)
);

-- Comments (with threading support)
CREATE TABLE public.post_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid,
  user_id uuid,
  content text NOT NULL,
  parent_comment_id uuid,                 -- For nested replies
  is_anonymous boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  FOREIGN KEY (post_id) REFERENCES public.posts(id),
  FOREIGN KEY (user_id) REFERENCES public.users(id),
  FOREIGN KEY (parent_comment_id) REFERENCES public.post_comments(id) ON DELETE CASCADE
);

-- Likes
CREATE TABLE public.post_likes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id uuid,
  user_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  FOREIGN KEY (post_id) REFERENCES public.posts(id),
  FOREIGN KEY (user_id) REFERENCES public.users(id)
);
```

#### **10-12. Chat System Tables**

```sql
-- Chat Rooms
CREATE TABLE public.chat_rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  appointment_id uuid,                    -- Optional: linked to appointment
  status varchar DEFAULT 'active',
  last_message text,
  last_message_time timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Messages
CREATE TABLE public.messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid,
  sender_id uuid,
  content text NOT NULL,
  type varchar DEFAULT 'text',            -- 'text' | 'image' | 'file'
  is_pinned boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  FOREIGN KEY (room_id) REFERENCES public.chat_rooms(id),
  FOREIGN KEY (sender_id) REFERENCES public.users(id)
);

-- Chat Participants (many-to-many)
CREATE TABLE public.chat_participants (
  room_id uuid NOT NULL,
  user_id uuid NOT NULL,
  PRIMARY KEY (room_id, user_id),
  FOREIGN KEY (room_id) REFERENCES public.chat_rooms(id),
  FOREIGN KEY (user_id) REFERENCES public.users(id)
);
```

#### **13-14. AI Chatbot Tables**

```sql
-- AI Conversations
CREATE TABLE public.ai_conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title varchar DEFAULT 'New conversation',
  last_message_preview text,
  is_archived boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- AI Messages
CREATE TABLE public.ai_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL,
  user_id uuid NOT NULL,
  role varchar NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content text NOT NULL,
  model_name varchar,                     -- e.g., "gemini-pro"
  metadata jsonb,
  prompt_tokens integer,
  completion_tokens integer,
  total_tokens integer,
  latency_ms integer,
  created_at timestamp with time zone DEFAULT now(),
  FOREIGN KEY (conversation_id) REFERENCES public.ai_conversations(id),
  FOREIGN KEY (user_id) REFERENCES public.users(id)
);
```

#### **15. notifications**

```sql
CREATE TABLE public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid,
  title text NOT NULL,
  message text NOT NULL,
  type varchar,                           -- 'appointment' | 'message' | 'system'
  is_read boolean DEFAULT false,
  metadata jsonb,                         -- Additional data
  created_at timestamp with time zone DEFAULT now(),
  FOREIGN KEY (user_id) REFERENCES public.users(id)
);
```

### Entity Relationships

```
users (1) ──────< (many) mood_entries
  │
  ├──── (1:1) ───> experts
  │                   │
  │                   └──< (1:many) expert_availability
  │                   │
  │                   └──< (1:many) appointments (as expert)
  │
  ├──< (1:many) appointments (as user)
  │
  ├──< (1:many) posts (as author)
  │       │
  │       └──< (1:many) post_comments
  │       │
  │       └──< (1:many) post_likes
  │
  ├──< (1:many) chat_participants
  │       │
  │       └──> (many:1) chat_rooms
  │               │
  │               └──< (1:many) messages
  │
  ├──< (1:many) ai_conversations
  │       │
  │       └──< (1:many) ai_messages
  │
  └──< (1:many) notifications
```

---

## 📂 Project Structure

### Directory Layout

```
DALN_S12025/
├── android/                        # Android platform code
├── ios/                            # iOS platform code
├── web/                            # Web platform code
├── macos/                          # macOS platform code
│
├── lib/                            # Main Flutter source code
│   ├── main.dart                   # App entry point
│   │
│   ├── core/                       # Core configurations
│   │   ├── config/
│   │   │   ├── gemini_config.dart  # AI config
│   │   │   └── gemini_config.example.dart
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_constants.dart
│   │   │   └── app_strings.dart
│   │   ├── providers/              # State management
│   │   │   ├── auth_provider.dart
│   │   │   ├── mood_provider.dart
│   │   │   └── chatbot_provider.dart
│   │   └── services/
│   │       └── localization_service.dart
│   │
│   ├── models/                     # Data models (13 files)
│   │   ├── app_user.dart
│   │   ├── expert.dart
│   │   ├── expert_user.dart
│   │   ├── appointment.dart
│   │   ├── availability.dart
│   │   ├── meditation.dart
│   │   ├── mood_entry.dart
│   │   ├── news_post.dart
│   │   ├── post_comment.dart
│   │   ├── chat_room.dart
│   │   ├── chat_message.dart
│   │   ├── streak.dart
│   │   └── user_profile.dart
│   │
│   ├── services/                   # Business logic services (10 files)
│   │   ├── supabase_service.dart   # Main database service
│   │   ├── appointment_service.dart
│   │   ├── availability_service.dart
│   │   ├── expert_user_service.dart
│   │   ├── chat_service.dart
│   │   ├── ai_chatbot_service.dart
│   │   ├── news_service.dart
│   │   ├── notification_service.dart
│   │   ├── momo_service.dart       # Payment integration
│   │   └── config_service.dart
│   │
│   ├── views/                      # UI screens (85+ files)
│   │   │
│   │   ├── auth/                   # Authentication screens
│   │   │   ├── welcome_page.dart
│   │   │   ├── login_page.dart
│   │   │   ├── signup_page.dart
│   │   │   ├── expert_signup_page.dart
│   │   │   └── expert_pending_approval_page.dart
│   │   │
│   │   ├── home/                   # Home dashboard
│   │   │   ├── home_page.dart
│   │   │   ├── new_home_page.dart
│   │   │   └── widgets/
│   │   │       ├── mood_quick_check.dart
│   │   │       ├── wellness_stats_card.dart
│   │   │       ├── quick_action_grid.dart
│   │   │       ├── featured_meditation_card.dart
│   │   │       └── neumorphic_card.dart
│   │   │
│   │   ├── mood/                   # Mood tracking
│   │   │   ├── mood_log_page.dart
│   │   │   ├── mood_history_page.dart
│   │   │   ├── mood_analytics_page.dart
│   │   │   ├── mood_entry_detail_page.dart
│   │   │   └── widgets/
│   │   │
│   │   ├── meditation/             # Meditation library
│   │   │   ├── meditation_library_page.dart
│   │   │   └── meditation_detail_page.dart
│   │   │
│   │   ├── expert/                 # Expert browsing
│   │   │   ├── expert_list_page.dart
│   │   │   ├── expert_detail_page.dart
│   │   │   └── widgets/
│   │   │
│   │   ├── appointment/            # Booking system
│   │   │   ├── booking_page.dart
│   │   │   ├── my_appointments_page.dart
│   │   │   ├── mock_payment_page.dart
│   │   │   └── widgets/
│   │   │       ├── duration_selector.dart
│   │   │       └── call_type_selector.dart
│   │   │
│   │   ├── chat/                   # Real-time messaging
│   │   │   ├── chat_list_page.dart
│   │   │   └── chat_detail_page.dart
│   │   │
│   │   ├── chatbot/                # AI chatbot
│   │   │   └── chatbot_page.dart
│   │   │
│   │   ├── news/                   # Community forum
│   │   │   ├── news_feed_page.dart
│   │   │   ├── post_detail_page.dart
│   │   │   ├── create_post_page.dart
│   │   │   └── news_manager_page.dart
│   │   │
│   │   ├── profile/                # User profile
│   │   │   ├── profile_page.dart
│   │   │   └── edit_profile_page.dart
│   │   │
│   │   ├── notification/
│   │   │   └── notifications_page.dart
│   │   │
│   │   ├── streak/
│   │   │   ├── streak_history_page.dart
│   │   │   └── streak_debug_page.dart
│   │   │
│   │   ├── admin/                  # Admin dashboard (7 files)
│   │   │   ├── admin_main_page.dart
│   │   │   ├── admin_dashboard_page.dart
│   │   │   ├── admin_user_management_page.dart
│   │   │   ├── admin_expert_management_page.dart
│   │   │   ├── meditation_management_page.dart
│   │   │   ├── add_meditation_page.dart
│   │   │   └── edit_meditation_page.dart
│   │   │
│   │   └── expert_dashboard/       # Expert dashboard (6 files)
│   │       ├── expert_main_page.dart
│   │       ├── expert_dashboard_page.dart
│   │       ├── appointments_page.dart
│   │       ├── appointment_detail_page.dart
│   │       ├── schedule_page.dart
│   │       └── analytics_page.dart
│   │
│   ├── l10n/                       # Localization
│   │   └── app_localizations.dart
│   │
│   ├── scripts/                    # Utility scripts
│   └── dummy_firebase.dart         # Legacy Firebase mock
│
├── backend/                        # Node.js payment server
│   ├── server.js                   # MoMo payment API
│   └── package.json
│
├── docs/                           # Documentation & migrations
│   ├── uc.drawio                   # Use case diagram
│   ├── chat_supabase_messaging_migration.sql
│   ├── ai_chatbot_conversation_messages_migration.sql
│   ├── post_comments_threaded_reply_migration.sql
│   ├── anonymous_news_migration.sql
│   └── appointments_cancelled_role_migration.sql
│
├── assets/                         # Static assets
│   └── images/
│       ├── logo.png
│       └── Logo-MoMo-Circle.webp
│
├── test/                           # Unit & widget tests
│
├── .env.example                    # Environment variables template
├── .gitignore
├── pubspec.yaml                    # Dependencies
├── supabase_schema.sql             # Database schema
├── l10n.yaml                       # Localization config
├── analysis_options.yaml           # Linter rules
└── README.md
```

### Key Modules

#### **Models** (`lib/models/`)
Data classes representing database entities:
- **app_user.dart:** User model + UserRole enum
- **expert.dart:** Expert profile with specialization, rating
- **appointment.dart:** Booking with payment info
- **meditation.dart:** Meditation content
- **mood_entry.dart:** Mood log entry
- **chat_room.dart, chat_message.dart:** Chat system
- **news_post.dart, post_comment.dart:** Community forum

#### **Services** (`lib/services/`)
Business logic layer:
- **supabase_service.dart:** Main database operations
- **appointment_service.dart:** Booking CRUD, availability checks
- **expert_user_service.dart:** Expert approval workflow
- **chat_service.dart:** Real-time messaging via Supabase Realtime
- **ai_chatbot_service.dart:** Gemini AI integration
- **momo_service.dart:** Payment processing
- **notification_service.dart:** Push notifications

#### **Providers** (`lib/core/providers/`)
State management using Provider pattern:
- **auth_provider.dart:** Auth state (user, role, login/logout)
- **mood_provider.dart:** Mood tracking state
- **chatbot_provider.dart:** AI conversation state

---

## 🎨 Features Documentation

### 1. Authentication & Authorization

**Screens:**
- `welcome_page.dart` - Onboarding
- `login_page.dart` - Email/password login
- `signup_page.dart` - User registration
- `expert_signup_page.dart` - Expert registration with credentials
- `expert_pending_approval_page.dart` - Waiting for admin approval

**Flow:**
1. User enters email/password
2. `AuthProvider` calls `Supabase.auth.signInWithPassword()`
3. On success, fetch user role from `users` table
4. Route to appropriate home screen based on role
5. Store auth token in secure storage

**Services:** `supabase_service.dart` (auth methods)

**Tables:** `users`, `experts`

**Key Features:**
- Email verification
- Password reset
- Role-based routing
- Expert credential upload during signup

---

### 2. Mood Tracking System

**Screens:**
- `mood_log_page.dart` - Log daily mood
- `mood_history_page.dart` - View past entries
- `mood_analytics_page.dart` - Trends and charts
- `mood_entry_detail_page.dart` - Single entry details

**Flow:**
1. User selects mood level (1-5)
2. Optionally adds emotion factors (work, family, health, etc.)
3. Adds tags and notes
4. Saves to `mood_entries` table
5. Automatically updates user's streak count

**Services:** `supabase_service.dart` (createMoodEntry, getMoodEntries)

**Tables:** `mood_entries`, `users` (streak_count)

**Key Features:**
- 5-level mood scale
- Emotion factor categorization
- Tag system for easy filtering
- Mood calendar visualization
- Analytics: average mood, trends, correlations

---

### 3. Meditation Library

**Screens:**
- `meditation_library_page.dart` - Browse meditations
- `meditation_detail_page.dart` - Audio player

**Flow:**
1. User browses meditations by category/level
2. Clicks meditation → Detail page
3. Streams audio from Supabase Storage
4. Audio player with play/pause, progress bar
5. Can rate after listening

**Services:** `supabase_service.dart` (getMeditations)

**Tables:** `meditations`

**Key Features:**
- Categories: Sleep, Anxiety, Mindfulness, Stress, Focus
- Levels: Beginner, Intermediate, Advanced
- Audio streaming
- Ratings and reviews
- Duration display

**Admin Management:**
- `meditation_management_page.dart` - CRUD operations
- `add_meditation_page.dart` - Upload new meditation
- `edit_meditation_page.dart` - Edit existing

---

### 4. Expert Booking & Appointments

**Screens:**
- `expert_list_page.dart` - Browse experts
- `expert_detail_page.dart` - Expert profile
- `booking_page.dart` - Select date/time/call type
- `mock_payment_page.dart` - MoMo payment
- `my_appointments_page.dart` - User's bookings

**Flow:**
1. User searches/filters experts by specialization
2. Views expert profile (bio, credentials, rating, availability)
3. Clicks "Book Appointment"
4. Selects date/time from expert's available slots
5. Chooses call type (chat/video/audio)
6. Enters notes for expert
7. Proceeds to payment
8. Backend generates MoMo payment URL
9. User completes payment
10. Appointment created in database
11. Notification sent to expert
12. Chat room created automatically

**Services:**
- `appointment_service.dart` - Booking logic
- `availability_service.dart` - Fetch expert slots
- `momo_service.dart` - Payment processing
- `chat_service.dart` - Create chat room

**Tables:** `appointments`, `experts`, `expert_availability`, `chat_rooms`

**Key Features:**
- Real-time availability checking
- Multiple call types (chat, video, audio)
- MoMo payment integration
- Automatic chat room creation
- Appointment cancellation with refund tracking

---

### 5. Real-time Chat System

**Screens:**
- `chat_list_page.dart` - List of conversations
- `chat_detail_page.dart` - Message thread

**Flow:**
1. Chat room created when appointment is booked
2. Both user and expert added as participants
3. Real-time message delivery via Supabase Realtime
4. Messages stored in `messages` table
5. Last message preview updated in `chat_rooms`

**Services:** `chat_service.dart`

**Tables:** `chat_rooms`, `messages`, `chat_participants`

**Key Features:**
- Real-time messaging (Supabase Realtime subscriptions)
- Typing indicators
- Message history
- Pin important messages
- Appointment-linked conversations

**Code Example:**
```dart
// Subscribe to real-time messages
_supabase
  .from('messages')
  .stream(primaryKey: ['id'])
  .eq('room_id', roomId)
  .listen((data) {
    // Update UI with new messages
  });
```

---

### 6. AI Mental Health Chatbot

**Screens:**
- `chatbot_page.dart` - AI conversation interface

**Flow:**
1. User sends message
2. `AIChatbotService` calls Google Gemini API
3. AI generates response using mental health system prompt
4. Conversation saved to `ai_conversations` and `ai_messages`
5. Context maintained across session

**Services:** `ai_chatbot_service.dart`

**Tables:** `ai_conversations`, `ai_messages`

**Key Features:**
- 24/7 availability
- Mental health-focused responses
- Conversation history
- Context awareness
- Token usage tracking

**Configuration:**
```dart
// lib/core/config/gemini_config.dart
class GeminiConfig {
  static const modelName = 'gemini-pro';
  static const temperature = 0.7;
  static const maxOutputTokens = 1024;
  static const systemPrompt = '''
    You are a compassionate mental health assistant...
  ''';
}
```

---

### 7. Community Forum

**Screens:**
- `news_feed_page.dart` - Post feed
- `post_detail_page.dart` - Single post with comments
- `create_post_page.dart` - Create new post
- `news_manager_page.dart` - Moderation (admin)

**Flow:**
1. User creates post (text + optional image)
2. Can choose anonymous posting
3. Other users can like, comment, reply to comments
4. Threaded comment support (parent_comment_id)
5. Admins can moderate/delete posts

**Services:** `news_service.dart`

**Tables:** `posts`, `post_comments`, `post_likes`

**Key Features:**
- Anonymous posting option
- Image uploads
- Like system
- Nested comments (replies)
- Categories
- Admin moderation

---

### 8. Notification System

**Screens:**
- `notifications_page.dart` - List notifications

**Flow:**
1. System events trigger notifications (appointment booked, expert approved, etc.)
2. Notification created in `notifications` table
3. User sees unread count badge
4. Can mark as read, delete

**Services:** `notification_service.dart`

**Tables:** `notifications`

**Notification Types:**
- `appointment` - Booking confirmations, reminders
- `message` - New chat messages
- `system` - Expert approval, general announcements

---

### 9. Streak & Gamification

**Screens:**
- `streak_history_page.dart` - Streak calendar
- `streak_debug_page.dart` - Debug/test streaks

**Flow:**
1. User logs mood → streak increments
2. Streak breaks if user misses a day
3. `longest_streak` updated if current streak exceeds it

**Services:** `supabase_service.dart` (recalculateStreak)

**Tables:** `users` (streak_count, longest_streak)

**Key Features:**
- Daily streak tracking
- Longest streak record
- Visual streak calendar
- Motivational messaging

---

### 10. Admin Dashboard

**Screens:**
- `admin_dashboard_page.dart` - Overview stats
- `admin_user_management_page.dart` - User CRUD
- `admin_expert_management_page.dart` - Expert approval
- `meditation_management_page.dart` - Content management

**Admin Capabilities:**
- View platform statistics (users, experts, appointments, etc.)
- Manage users (view, edit, delete, change role)
- Approve/reject expert applications
- Review expert credentials (licenses, certificates)
- CRUD meditations (add/edit/delete)
- Moderate community posts
- View analytics

**Services:** All services (admin has full access)

**Tables:** All tables (admin RLS policies allow full access)

---

### 11. Expert Dashboard

**Screens:**
- `expert_dashboard_page.dart` - Expert home
- `appointments_page.dart` - Manage bookings
- `appointment_detail_page.dart` - Appointment details
- `schedule_page.dart` - Set availability
- `analytics_page.dart` - Earnings, stats

**Expert Capabilities:**
- View upcoming/past appointments
- Manage availability schedule (add/edit/delete time slots)
- Chat with clients
- View analytics (total sessions, earnings, ratings)
- Update profile and credentials

**Services:**
- `appointment_service.dart`
- `availability_service.dart`
- `chat_service.dart`

**Tables:** `appointments`, `expert_availability`, `chat_rooms`

---

### 12. User Profile Management

**Screens:**
- `profile_page.dart` - View profile
- `edit_profile_page.dart` - Edit details

**Features:**
- Update full name, avatar, date of birth, gender
- Set goals and preferences
- View activity stats (appointments, mood entries, posts)
- View appointment history
- Change password

**Services:** `supabase_service.dart`

**Tables:** `users`

---

### 13. Internationalization (i18n)

**Supported Languages:**
- English (en)
- Vietnamese (vi)

**Implementation:**
- `flutter_localizations` package
- `l10n/` folder with translations
- `LocaleProvider` for language switching

**Usage:**
```dart
Text(AppLocalizations.of(context)!.welcomeMessage)
```

---

## 👤 User Roles & Permissions

### Role Hierarchy

```
┌─────────────┐
│    Admin    │  Full access to all features
└──────┬──────┘
       │
┌──────▼──────┐
│   Expert    │  Manage own appointments, schedule, chat
└──────┬──────┘
       │
┌──────▼──────┐
│    User     │  Book experts, track mood, use meditation, forum
└─────────────┘
```

### Permission Matrix

| Feature | User | Expert | Admin |
|---------|------|--------|-------|
| Mood Tracking | ✅ | ✅ | ✅ |
| Meditation Library | ✅ | ✅ | ✅ |
| AI Chatbot | ✅ | ✅ | ✅ |
| Community Forum (read/post) | ✅ | ✅ | ✅ |
| Browse Experts | ✅ | ✅ | ✅ |
| Book Appointments | ✅ | ❌ | ✅ (as user) |
| Chat with Booked Expert | ✅ | ✅ (with clients) | ✅ |
| View Own Appointments | ✅ | ✅ (as expert) | ✅ |
| Manage Expert Schedule | ❌ | ✅ | ✅ |
| Expert Analytics | ❌ | ✅ (own) | ✅ (all) |
| Approve Experts | ❌ | ❌ | ✅ |
| Manage Users | ❌ | ❌ | ✅ |
| CRUD Meditations | ❌ | ❌ | ✅ |
| Moderate Posts | ❌ | ❌ | ✅ |
| View Platform Analytics | ❌ | ❌ | ✅ |

### Row Level Security (RLS) Policies

**Example: Users can only read their own mood entries**
```sql
CREATE POLICY "Users can read own mood entries"
ON public.mood_entries
FOR SELECT
TO authenticated
USING (user_id = auth.uid());
```

**Example: Admins can read all data**
```sql
CREATE POLICY "Admins have full access"
ON public.mood_entries
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid() AND role = 'admin'
  )
);
```

---

## ⚙️ Core Services

### 1. SupabaseService (`supabase_service.dart`)

**Purpose:** Main database service handling all Supabase operations

**Key Methods:**
```dart
class SupabaseService {
  static final instance = SupabaseService._internal();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Auth
  User? get currentUser => _supabase.auth.currentUser;
  
  // Users
  Future<void> createUserProfile({required String id, required String email, ...});
  Future<AppUser?> getUserById(String userId);
  Future<String> getUserRole(String userId);
  
  // Mood Entries
  Future<void> createMoodEntry(MoodEntry entry);
  Stream<List<MoodEntry>> streamMoodEntries(String userId);
  Future<List<MoodEntry>> getMoodEntries(String userId);
  
  // Meditations
  Future<List<Meditation>> getAllMeditations();
  Stream<List<Meditation>> streamMeditations();
  
  // Experts
  Future<List<Map<String, dynamic>>> getApprovedExperts();
  Future<Map<String, dynamic>?> getExpertById(String expertId);
  
  // Streaks
  Future<void> recalculateStreak(String userId);
  Future<Streak?> getStreak(String userId);
}
```

---

### 2. AppointmentService (`appointment_service.dart`)

**Purpose:** Handle appointment booking, management, payment tracking

**Key Methods:**
```dart
class AppointmentService {
  // Create appointment
  Future<String?> createAppointment({
    required String userId,
    required String expertId,
    required DateTime appointmentDate,
    required int durationMinutes,
    required String callType,
    String? userNotes,
  });
  
  // Get user's appointments
  Future<List<Appointment>> getUserAppointments(String userId);
  
  // Get expert's appointments
  Future<List<Appointment>> getExpertAppointments(String expertId);
  
  // Cancel appointment
  Future<void> cancelAppointment({
    required String appointmentId,
    required String cancelledBy,
    required String cancelledRole,
    String? reason,
  });
  
  // Update status
  Future<void> updateAppointmentStatus(String id, String status);
  
  // Update payment status
  Future<void> updatePaymentStatus(String id, String paymentId, String transId);
}
```

---

### 3. ChatService (`chat_service.dart`)

**Purpose:** Real-time messaging between users and experts

**Key Methods:**
```dart
class ChatService {
  // Get or create chat room for appointment
  Future<String> getOrCreateChatRoom(String appointmentId, String userId, String expertId);
  
  // Stream messages (real-time)
  Stream<List<ChatMessage>> streamMessages(String roomId);
  
  // Send message
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
    String type = 'text',
  });
  
  // Get user's chat rooms
  Future<List<ChatRoom>> getUserChatRooms(String userId);
  
  // Mark messages as read
  Future<void> markAsRead(String roomId, String userId);
}
```

**Real-time Subscription Example:**
```dart
final messagesStream = _supabase
  .from('messages')
  .stream(primaryKey: ['id'])
  .eq('room_id', roomId)
  .order('created_at', ascending: true);
```

---

### 4. AIChatbotService (`ai_chatbot_service.dart`)

**Purpose:** Google Gemini AI integration for mental health chatbot

**Key Methods:**
```dart
class AIChatbotService {
  GenerativeModel? _model;
  
  // Initialize Gemini
  void _initializeGemini();
  
  // Get or create conversation
  Future<String?> getOrCreateLatestConversation({String? title});
  
  // Send message and get AI response
  Future<String?> sendMessage({
    required String conversationId,
    required String userMessage,
  });
  
  // Stream conversations
  Stream<List<Map<String, dynamic>>> streamConversations(String userId);
  
  // Stream messages in conversation
  Stream<List<Map<String, dynamic>>> streamMessages(String conversationId);
  
  // Archive conversation
  Future<void> archiveConversation(String conversationId);
}
```

**System Prompt:**
```dart
static const systemPrompt = '''
You are a compassionate and knowledgeable mental health assistant. 
Your role is to provide supportive, empathetic responses to users 
seeking mental health guidance. Always be non-judgmental, encourage 
professional help when needed, and never provide medical diagnoses.
''';
```

---

### 5. ExpertUserService (`expert_user_service.dart`)

**Purpose:** Expert registration, approval workflow, profile management

**Key Methods:**
```dart
class ExpertUserService {
  // Submit expert application
  Future<void> submitExpertApplication({
    required String userId,
    required String bio,
    required String specialization,
    required int hourlyRate,
    // ... credentials
  });
  
  // Get pending applications (admin)
  Future<List<ExpertUser>> getPendingExperts();
  
  // Approve expert
  Future<void> approveExpert(String expertId);
  
  // Reject expert
  Future<void> rejectExpert(String expertId, String reason);
  
  // Update expert profile
  Future<void> updateExpertProfile(String expertId, Map<String, dynamic> data);
  
  // Upload credentials
  Future<String> uploadLicenseDocument(String expertId, File file);
}
```

---

### 6. MomoService (`momo_service.dart`)

**Purpose:** MoMo payment integration for appointment bookings

**Implementation:**
```dart
class MomoService {
  // Generate payment URL
  Future<String?> createPayment({
    required double amount,
    required String orderId,
    required String orderInfo,
  }) async {
    // Call Node.js backend
    final response = await http.post(
      Uri.parse('$backendUrl/momo/create'),
      body: jsonEncode({'amount': amount}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['payUrl']; // MoMo payment URL
    }
    return null;
  }
  
  // Launch MoMo app
  Future<void> openMomoPayment(String payUrl) async {
    if (await canLaunchUrl(Uri.parse(payUrl))) {
      await launchUrl(Uri.parse(payUrl), mode: LaunchMode.externalApplication);
    }
  }
}
```

**Backend (Node.js):**
```javascript
// backend/server.js
app.post('/momo/create', async (req, res) => {
  const { amount } = req.body;
  
  const orderId = "MOMO" + Date.now();
  const requestId = orderId;
  
  // Generate signature
  const rawSignature = `accessKey=${accessKey}&amount=${amount}&...`;
  const signature = crypto
    .createHmac('sha256', secretKey)
    .update(rawSignature)
    .digest('hex');
  
  // Call MoMo API
  const response = await axios.post(momoEndpoint, {
    partnerCode, accessKey, requestId, amount, 
    orderId, orderInfo, redirectUrl, ipnUrl, 
    requestType, extraData, signature
  });
  
  res.json(response.data);
});
```

---

### 7. NotificationService (`notification_service.dart`)

**Purpose:** Send and manage in-app notifications

**Key Methods:**
```dart
class NotificationService {
  // Create notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    String? type,
    Map<String, dynamic>? metadata,
  });
  
  // Get user's notifications
  Future<List<Notification>> getNotifications(String userId);
  
  // Mark as read
  Future<void> markAsRead(String notificationId);
  
  // Delete notification
  Future<void> deleteNotification(String notificationId);
  
  // Get unread count
  Future<int> getUnreadCount(String userId);
}
```

---

### 8. AvailabilityService (`availability_service.dart`)

**Purpose:** Manage expert availability schedules

**Key Methods:**
```dart
class AvailabilityService {
  // Get expert's availability
  Future<List<Availability>> getExpertAvailability(String expertId);
  
  // Add availability slot
  Future<void> addAvailability({
    required String expertId,
    required int dayOfWeek,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  });
  
  // Update slot
  Future<void> updateAvailability(String id, Map<String, dynamic> data);
  
  // Delete slot
  Future<void> deleteAvailability(String id);
  
  // Check if slot is available
  Future<bool> isSlotAvailable(
    String expertId, 
    DateTime appointmentDate, 
    int durationMinutes
  );
}
```

---

### 9. NewsService (`news_service.dart`)

**Purpose:** Community forum posts, comments, likes

**Key Methods:**
```dart
class NewsService {
  // Posts
  Future<List<NewsPost>> getAllPosts({String? category});
  Future<void> createPost({
    required String authorId,
    required String title,
    required String content,
    String? imageUrl,
    bool isAnonymous = false,
  });
  Future<void> deletePost(String postId);
  
  // Comments
  Future<List<PostComment>> getPostComments(String postId);
  Future<void> addComment({
    required String postId,
    required String userId,
    required String content,
    String? parentCommentId,
  });
  
  // Likes
  Future<void> toggleLike(String postId, String userId);
  Future<bool> hasUserLiked(String postId, String userId);
}
```

---

### 10. ConfigService (`config_service.dart`)

**Purpose:** App configuration and constants

---

## 🚀 Setup & Installation

### Prerequisites

- **Flutter SDK:** 3.9.2 or higher ([Install](https://docs.flutter.dev/get-started/install))
- **Dart SDK:** Included with Flutter
- **Node.js:** 16+ (for payment backend)
- **Supabase Account:** [Sign up](https://supabase.com/)
- **Google Gemini API Key:** [Get key](https://aistudio.google.com/app/apikey)
- **MoMo Developer Account:** (for production payment)
- **IDE:** VS Code, Android Studio, or IntelliJ IDEA
- **Platform SDKs:**
  - Android: Android Studio + Android SDK
  - iOS: Xcode (macOS only)

### Installation Steps

#### 1. Clone Repository
```bash
git clone https://github.com/yourusername/DALN_S12025.git
cd DALN_S12025
```

#### 2. Install Flutter Dependencies
```bash
flutter pub get
```

#### 3. Setup Environment Variables

Create `.env` file from template:
```bash
cp .env.example .env
```

Edit `.env` and add your credentials:
```env
# Gemini AI API Key
GEMINI_API_KEY=your_gemini_api_key_here

# Supabase Configuration
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

#### 4. Setup Supabase

**A. Create Supabase Project**
1. Go to [Supabase Dashboard](https://app.supabase.com/)
2. Click "New Project"
3. Fill in project details
4. Copy the `URL` and `anon key` to your `.env` file

**B. Run Database Schema**
1. In Supabase Dashboard, go to SQL Editor
2. Copy contents of `supabase_schema.sql`
3. Execute the SQL script

**C. Enable Row Level Security (RLS)**
```sql
-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.experts ENABLE ROW LEVEL SECURITY;
-- ... (repeat for all tables)

-- Create policies (examples)
CREATE POLICY "Users can read own data"
ON public.users FOR SELECT TO authenticated
USING (id = auth.uid());

CREATE POLICY "Admins have full access"
ON public.users FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = auth.uid() AND role = 'admin'
  )
);
```

**D. Setup Storage Buckets**
1. Go to Storage in Supabase Dashboard
2. Create buckets:
   - `avatars` (public)
   - `meditation-audio` (public)
   - `meditation-thumbnails` (public)
   - `expert-documents` (private)

**E. Enable Realtime**
1. Go to Database → Replication
2. Enable replication for:
   - `messages`
   - `chat_rooms`
   - `notifications`

#### 5. Setup Gemini Config

Create `lib/core/config/gemini_config.dart` from example:
```bash
cp lib/core/config/gemini_config.example.dart lib/core/config/gemini_config.dart
```

Edit and add your API key:
```dart
class GeminiConfig {
  static const String apiKey = 'your_gemini_api_key';
  // ... rest of config
}
```

#### 6. Setup Payment Backend (Node.js)

**Install dependencies:**
```bash
cd backend
npm install
```

**Configure MoMo credentials** in `server.js`:
```javascript
const config = {
  partnerCode: "YOUR_PARTNER_CODE",
  accessKey: "YOUR_ACCESS_KEY",
  secretKey: "YOUR_SECRET_KEY",
  endpoint: "https://test-payment.momo.vn/v2/gateway/api/create"
};
```

**Run server:**
```bash
node server.js
# Server runs on http://localhost:3000
```

#### 7. Run Flutter App

**Check devices:**
```bash
flutter devices
```

**Run on connected device:**
```bash
flutter run
```

**Run in debug mode with hot reload:**
```bash
flutter run -d <device-id>
```

**Build for specific platform:**
```bash
# Android
flutter build apk

# iOS (requires macOS)
flutter build ios

# Web
flutter build web
```

### First Run Setup

#### Create Admin User

1. Run the app and register a new account
2. Go to Supabase Dashboard → Table Editor → `users`
3. Find your user record
4. Change `role` from `'user'` to `'admin'`
5. Restart the app
6. You now have admin access!

#### Seed Initial Data (Optional)

**Add sample meditations:**
```sql
INSERT INTO public.meditations (title, description, category, duration_minutes, audio_url, thumbnail_url, level) VALUES
('Morning Mindfulness', 'Start your day with calm', 'Mindfulness', 10, 'https://example.com/audio1.mp3', 'https://example.com/thumb1.jpg', 'beginner'),
('Sleep Meditation', 'Relax and drift to sleep', 'Sleep', 20, 'https://example.com/audio2.mp3', 'https://example.com/thumb2.jpg', 'beginner');
```

---

## 🔐 Environment Configuration

### Environment Variables

| Variable | Description | Required | Example |
|----------|-------------|----------|---------|
| `GEMINI_API_KEY` | Google Gemini AI API key | Yes | `AIzaSy...` |
| `SUPABASE_URL` | Supabase project URL | Yes | `https://xyz.supabase.co` |
| `SUPABASE_ANON_KEY` | Supabase anonymous key | Yes | `eyJhbGci...` |

### Configuration Files

#### `.env` (Root directory)
```env
GEMINI_API_KEY=your_actual_api_key_here
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your_actual_anon_key_here
```

#### `lib/core/config/gemini_config.dart`
```dart
class GeminiConfig {
  static const String apiKey = 'YOUR_GEMINI_API_KEY';
  static const String modelName = 'gemini-pro';
  static const double temperature = 0.7;
  static const int maxOutputTokens = 1024;
  
  static const String systemPrompt = '''
    You are a compassionate mental health assistant...
  ''';
  
  static bool get isConfigured => apiKey.isNotEmpty && apiKey != 'YOUR_API_KEY_HERE';
}
```

#### `backend/.env` (Node.js backend - optional)
```env
PORT=3000
MOMO_PARTNER_CODE=MOMO
MOMO_ACCESS_KEY=F8BBA842ECF85
MOMO_SECRET_KEY=K951B6PE1waDMi640xX08PD3vg6EkVlz
```

### Security Best Practices

1. **Never commit `.env` files** - Already in `.gitignore`
2. **Use environment-specific configs** - `.env.dev`, `.env.prod`
3. **Rotate API keys regularly**
4. **Enable RLS on all tables** in Supabase
5. **Use service role key only server-side** (not in Flutter app)
6. **Validate all user inputs** before database operations
7. **Implement rate limiting** for API calls
8. **Use HTTPS** for all external requests

---

## 💻 Development Guide

### Code Structure Conventions

#### Naming Conventions
- **Files:** `snake_case.dart` (e.g., `mood_log_page.dart`)
- **Classes:** `PascalCase` (e.g., `MoodLogPage`)
- **Variables:** `camelCase` (e.g., `userId`, `expertId`)
- **Constants:** `SCREAMING_SNAKE_CASE` or `camelCase` (e.g., `MAX_RETRIES`, `defaultTimeout`)
- **Private members:** Prefix with `_` (e.g., `_supabase`, `_initializeGemini()`)

#### File Organization
```
feature_name/
├── feature_page.dart          # Main screen
├── feature_detail_page.dart   # Detail/sub-screen
└── widgets/                   # Feature-specific widgets
    ├── feature_card.dart
    └── feature_list_item.dart
```

### Adding a New Feature

#### Example: Adding a "Journal" Feature

**Step 1: Create Model**
```dart
// lib/models/journal_entry.dart
class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  
  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
  });
  
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'content': content,
    };
  }
}
```

**Step 2: Create Database Table**
```sql
-- In Supabase SQL Editor
CREATE TABLE public.journal_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title varchar NOT NULL,
  content text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  FOREIGN KEY (user_id) REFERENCES public.users(id)
);

-- Enable RLS
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own journals"
ON public.journal_entries
FOR ALL TO authenticated
USING (user_id = auth.uid());
```

**Step 3: Create Service**
```dart
// lib/services/journal_service.dart
class JournalService {
  final _supabase = Supabase.instance.client;
  
  Future<void> createEntry(JournalEntry entry) async {
    await _supabase.from('journal_entries').insert(entry.toMap());
  }
  
  Future<List<JournalEntry>> getEntries(String userId) async {
    final data = await _supabase
      .from('journal_entries')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false);
    
    return data.map((e) => JournalEntry.fromMap(e)).toList();
  }
  
  Future<void> updateEntry(String id, Map<String, dynamic> updates) async {
    await _supabase.from('journal_entries').update(updates).eq('id', id);
  }
  
  Future<void> deleteEntry(String id) async {
    await _supabase.from('journal_entries').delete().eq('id', id);
  }
}
```

**Step 4: Create UI**
```dart
// lib/views/journal/journal_list_page.dart
class JournalListPage extends StatefulWidget {
  @override
  State<JournalListPage> createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  final _journalService = JournalService();
  List<JournalEntry> _entries = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadEntries();
  }
  
  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser!.id;
    _entries = await _journalService.getEntries(userId);
    setState(() => _isLoading = false);
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return CircularProgressIndicator();
    
    return Scaffold(
      appBar: AppBar(title: Text('My Journal')),
      body: ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          return ListTile(
            title: Text(entry.title),
            subtitle: Text(entry.content),
            onTap: () {
              // Navigate to detail page
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create page
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

**Step 5: Add Navigation**
```dart
// In your navigation/routing setup
routes: [
  GoRoute(
    path: '/journal',
    builder: (context, state) => JournalListPage(),
  ),
  // ... other routes
]
```

### Database Migrations

Store migration scripts in `docs/` folder:

```sql
-- docs/journal_feature_migration.sql
-- Migration: Add journal_entries table
-- Date: 2026-03-21
-- Author: Your Name

CREATE TABLE IF NOT EXISTS public.journal_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  title varchar NOT NULL,
  content text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE
);

ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "journal_user_policy"
ON public.journal_entries
FOR ALL TO authenticated
USING (user_id = auth.uid());

-- Rollback (if needed):
-- DROP TABLE IF EXISTS public.journal_entries CASCADE;
```

### Testing

#### Unit Tests
```dart
// test/services/journal_service_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JournalService', () {
    test('createEntry should insert into database', () async {
      // Test implementation
    });
    
    test('getEntries should return user entries', () async {
      // Test implementation
    });
  });
}
```

Run tests:
```bash
flutter test
```

#### Widget Tests
```dart
// test/views/journal_list_page_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('JournalListPage displays entries', (tester) async {
    // Test implementation
  });
}
```

### Common Patterns

#### 1. Provider Pattern (State Management)
```dart
class ExampleProvider with ChangeNotifier {
  List<Item> _items = [];
  
  List<Item> get items => _items;
  
  Future<void> loadItems() async {
    _items = await fetchItems();
    notifyListeners(); // Trigger UI rebuild
  }
}

// Usage in widget
Consumer<ExampleProvider>(
  builder: (context, provider, child) {
    return ListView(
      children: provider.items.map((item) => Text(item.name)).toList(),
    );
  },
)
```

#### 2. Stream-based Real-time Updates
```dart
StreamBuilder<List<Message>>(
  stream: _supabase
    .from('messages')
    .stream(primaryKey: ['id'])
    .eq('room_id', roomId),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final messages = snapshot.data!;
    return ListView(
      children: messages.map((msg) => MessageBubble(msg)).toList(),
    );
  },
)
```

#### 3. Error Handling
```dart
Future<void> fetchData() async {
  try {
    final data = await _supabase.from('table').select();
    // Process data
  } on PostgrestException catch (e) {
    // Handle database errors
    print('Database error: ${e.message}');
    showErrorSnackbar('Failed to load data');
  } catch (e) {
    // Handle other errors
    print('Unexpected error: $e');
    showErrorSnackbar('Something went wrong');
  }
}
```

### Code Quality

#### Linting
```bash
# Run linter
flutter analyze

# Auto-fix issues
dart fix --apply
```

#### Formatting
```bash
# Format all Dart files
dart format lib/

# Format specific file
dart format lib/services/example_service.dart
```

---

## 🌐 API Integration

### Supabase APIs

#### Authentication
```dart
// Sign Up
final response = await Supabase.instance.client.auth.signUp(
  email: email,
  password: password,
);

// Sign In
final response = await Supabase.instance.client.auth.signInWithPassword(
  email: email,
  password: password,
);

// Sign Out
await Supabase.instance.client.auth.signOut();

// Get current user
final user = Supabase.instance.client.auth.currentUser;
```

#### Database Operations
```dart
// Insert
await _supabase.from('table').insert({'column': 'value'});

// Select
final data = await _supabase.from('table').select();

// Update
await _supabase.from('table').update({'column': 'new_value'}).eq('id', id);

// Delete
await _supabase.from('table').delete().eq('id', id);

// Join tables
final data = await _supabase
  .from('experts')
  .select('*, users(full_name, avatar_url)')
  .eq('is_approved', true);
```

#### Storage (File Upload)
```dart
// Upload file
final file = File('/path/to/file.jpg');
final filePath = '${userId}/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';

await _supabase.storage
  .from('avatars')
  .upload(filePath, file);

// Get public URL
final publicUrl = _supabase.storage
  .from('avatars')
  .getPublicUrl(filePath);

// Delete file
await _supabase.storage.from('avatars').remove([filePath]);
```

#### Realtime Subscriptions
```dart
// Subscribe to table changes
final subscription = _supabase
  .from('messages')
  .stream(primaryKey: ['id'])
  .eq('room_id', roomId)
  .listen((data) {
    print('New messages: $data');
  });

// Cancel subscription
subscription.cancel();
```

### Google Gemini AI API

```dart
import 'package:google_generative_ai/google_generative_ai.dart';

// Initialize model
final model = GenerativeModel(
  model: 'gemini-pro',
  apiKey: GeminiConfig.apiKey,
  generationConfig: GenerationConfig(
    temperature: 0.7,
    maxOutputTokens: 1024,
  ),
  systemInstruction: Content.text('You are a mental health assistant...'),
);

// Generate response
final prompt = 'I feel anxious today';
final content = [Content.text(prompt)];
final response = await model.generateContent(content);

print(response.text);
```

### MoMo Payment API

**Flutter Side:**
```dart
// Call backend to create payment
final response = await http.post(
  Uri.parse('http://localhost:3000/momo/create'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'amount': 100000}), // VND
);

final data = jsonDecode(response.body);
final payUrl = data['payUrl'];

// Open MoMo app or web payment
await launchUrl(Uri.parse(payUrl), mode: LaunchMode.externalApplication);
```

**Backend (Node.js):**
```javascript
const crypto = require('crypto');
const axios = require('axios');

app.post('/momo/create', async (req, res) => {
  const { amount } = req.body;
  
  const orderId = "MOMO" + Date.now();
  const requestId = orderId;
  const orderInfo = `Payment for appointment`;
  
  // Generate signature
  const rawSignature = `accessKey=${accessKey}&amount=${amount}&...`;
  const signature = crypto
    .createHmac('sha256', secretKey)
    .update(rawSignature)
    .digest('hex');
  
  // Call MoMo API
  const momoResponse = await axios.post(momoEndpoint, {
    partnerCode, accessKey, requestId, amount,
    orderId, orderInfo, redirectUrl, ipnUrl,
    requestType, extraData, signature
  });
  
  res.json(momoResponse.data);
});
```

---

## 🚢 Deployment

### Flutter App Deployment

#### Android (Google Play Store)

1. **Generate keystore:**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

2. **Configure signing in `android/key.properties`:**
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

3. **Build release APK:**
```bash
flutter build apk --release
```

4. **Build App Bundle (recommended for Play Store):**
```bash
flutter build appbundle --release
```

5. **Upload to Play Console:**
- Go to [Google Play Console](https://play.google.com/console)
- Create app listing
- Upload `.aab` file
- Submit for review

#### iOS (App Store)

1. **Configure signing in Xcode:**
- Open `ios/Runner.xcworkspace` in Xcode
- Select "Runner" project → Signing & Capabilities
- Select your Apple Developer team
- Set Bundle Identifier

2. **Build for release:**
```bash
flutter build ios --release
```

3. **Archive and upload:**
- In Xcode: Product → Archive
- Upload to App Store Connect
- Submit for review

#### Web

1. **Build web app:**
```bash
flutter build web --release
```

2. **Deploy to hosting:**

**Firebase Hosting:**
```bash
firebase init hosting
firebase deploy
```

**Netlify:**
```bash
cd build/web
netlify deploy --prod
```

**Vercel:**
```bash
cd build/web
vercel --prod
```

### Supabase Configuration

**Production Setup:**
1. Create production Supabase project
2. Enable required extensions
3. Run schema migrations
4. Configure RLS policies
5. Set up storage buckets
6. Enable realtime for required tables
7. Configure email templates
8. Set up custom domain (optional)

### Backend Server Deployment

#### Deploy Node.js Backend (Railway, Render, etc.)

**Railway:**
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Deploy
railway up
```

**Render:**
1. Connect GitHub repository
2. Select `backend` folder
3. Set environment variables
4. Deploy

**Environment Variables for Production:**
```env
PORT=3000
MOMO_PARTNER_CODE=your_production_partner_code
MOMO_ACCESS_KEY=your_production_access_key
MOMO_SECRET_KEY=your_production_secret_key
MOMO_ENDPOINT=https://payment.momo.vn/v2/gateway/api/create
```

### CI/CD (Optional)

**GitHub Actions Example:**
```yaml
# .github/workflows/flutter.yml
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.9.2'
    
    - run: flutter pub get
    - run: flutter analyze
    - run: flutter test
    - run: flutter build apk --release
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Supabase Connection Failed

**Error:** `SocketException: Failed to connect to Supabase`

**Solution:**
- Check `.env` file has correct `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- Ensure `flutter_dotenv` is properly loaded in `main.dart`
- Verify Supabase project is active (not paused)
- Check internet connection

```dart
// Debug: Print environment variables
print('Supabase URL: ${dotenv.env['SUPABASE_URL']}');
print('Anon Key: ${dotenv.env['SUPABASE_ANON_KEY']}');
```

#### 2. Gemini API "API key not valid"

**Solution:**
- Verify API key in `lib/core/config/gemini_config.dart`
- Check API key is enabled in Google AI Studio
- Ensure no extra spaces or quotes

#### 3. RLS Policy Blocking Access

**Error:** `Row Level Security policy violation`

**Solution:**
- Check if user is authenticated: `Supabase.instance.client.auth.currentUser != null`
- Verify RLS policies allow the operation
- Temporarily disable RLS for debugging:
```sql
ALTER TABLE public.your_table DISABLE ROW LEVEL SECURITY;
```
- Re-enable after fixing policies

#### 4. Flutter Build Errors

**Error:** `Gradle build failed`

**Solution:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### 5. MoMo Payment Not Working

**Solution:**
- Check Node.js backend is running (`node backend/server.js`)
- Verify MoMo credentials in `backend/server.js`
- Check backend URL in `momo_service.dart`
- Use MoMo test credentials for development
- Check signature generation matches MoMo documentation

### Debug Mode

Enable verbose logging:
```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable logging
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: true, // Enable debug logs
  );
  
  runApp(MyApp());
}
```

### Useful Commands

```bash
# Check Flutter setup
flutter doctor -v

# Clean build cache
flutter clean

# Update dependencies
flutter pub upgrade

# Run with verbose logging
flutter run -v

# Build with debug symbols
flutter build apk --debug

# Check app size
flutter build apk --analyze-size
```

### FAQ

**Q: How do I reset the database?**
A: In Supabase Dashboard → SQL Editor, run:
```sql
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;
-- Then re-run supabase_schema.sql
```

**Q: How do I add a new admin?**
A: Update user role in Supabase:
```sql
UPDATE public.users SET role = 'admin' WHERE email = 'admin@example.com';
```

**Q: How do I debug Realtime subscriptions?**
A: Check in Supabase Dashboard → Database → Replication that tables are enabled.

**Q: App crashes on startup?**
A: Check logs:
```bash
flutter run --verbose
# or
adb logcat | grep flutter
```

---

## 🤝 Contributing

### Git Workflow

1. **Clone and create branch:**
```bash
git clone https://github.com/yourusername/DALN_S12025.git
cd DALN_S12025
git checkout -b feature/your-feature-name
```

2. **Make changes and commit:**
```bash
git add .
git commit -m "feat: add journal feature"
```

3. **Push and create PR:**
```bash
git push origin feature/your-feature-name
# Then create Pull Request on GitHub
```

### Commit Message Conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add journal feature
fix: resolve mood tracking bug
docs: update README
style: format code
refactor: simplify appointment service
test: add mood entry tests
chore: update dependencies
```

### Code Review Process

1. Create Pull Request
2. Ensure CI passes (if configured)
3. Request review from maintainers
4. Address feedback
5. Merge after approval

### Branch Naming

- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation
- `refactor/` - Code refactoring
- `test/` - Adding tests

---

## 📚 Resources

### Official Documentation

- **Flutter:** https://docs.flutter.dev/
- **Dart:** https://dart.dev/guides
- **Supabase:** https://supabase.com/docs
- **Google Gemini AI:** https://ai.google.dev/docs
- **MoMo Payment API:** https://developers.momo.vn/

### Packages Used

- **supabase_flutter:** https://pub.dev/packages/supabase_flutter
- **go_router:** https://pub.dev/packages/go_router
- **provider:** https://pub.dev/packages/provider
- **google_generative_ai:** https://pub.dev/packages/google_generative_ai
- **audioplayers:** https://pub.dev/packages/audioplayers
- **table_calendar:** https://pub.dev/packages/table_calendar
- **image_picker:** https://pub.dev/packages/image_picker
- **flutter_dotenv:** https://pub.dev/packages/flutter_dotenv

### Project-Specific Documentation

- **Database Schema:** `supabase_schema.sql`
- **Migration Scripts:** `docs/*.sql`
- **Use Case Diagram:** `docs/uc.drawio`
- **Admin Panel Prompt:** `~/.copilot/session-state/.../admin-panel-prompt.md`

### Community

- **Flutter Community:** https://flutter.dev/community
- **Supabase Discord:** https://discord.supabase.com/
- **Stack Overflow:** [flutter tag](https://stackoverflow.com/questions/tagged/flutter)

---

## 📄 License

This project is private and proprietary. All rights reserved.

---

## 👥 Team

**Project:** DALN_S12025  
**Course:** Data Analytics and Learning Networks (Spring 2025)  
**Platform Name:** Moodiki (n04_app)

---

## 🎉 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Google for Gemini AI
- MoMo for payment integration
- All contributors and testers

---

**Last Updated:** March 21, 2026  
**Version:** 1.0.0  
**Maintained by:** Development Team

---

*For questions or support, please contact the development team or create an issue in the repository.*
