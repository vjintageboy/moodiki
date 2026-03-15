-- Run this in Supabase SQL Editor to persist anonymous post/comment settings.
-- Safe to run multiple times.

ALTER TABLE public.posts
ADD COLUMN IF NOT EXISTS is_anonymous boolean DEFAULT false;

ALTER TABLE public.post_comments
ADD COLUMN IF NOT EXISTS is_anonymous boolean DEFAULT false;

-- Optional backfill (if you used fallback mode with null IDs for anonymous data)
-- UPDATE public.posts SET is_anonymous = true WHERE author_id IS NULL;
-- UPDATE public.post_comments SET is_anonymous = true WHERE user_id IS NULL;
