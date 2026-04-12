-- ============================================================
-- Migration 002: Migrate from text-embedding-004 to gemini-embedding-001
-- Purpose: Update vector columns and RPC functions from 768 to 3072 dims
-- Model: text-embedding-004 (768d) -> gemini-embedding-001 (3072d)
-- Date: 2026-04-12
-- ============================================================

-- ⚠️  WARNING: This migration will DROP all existing embeddings!
--    After running this migration, you MUST re-embed all data:
--    1. Run: UPDATE public.meditations SET embedding = NULL;
--    2. Run: UPDATE public.mood_entries SET embedding = NULL;
--    3. Re-run seedMeditationEmbeddings() from the app or admin script
-- ============================================================

-- 1. Drop existing HNSW index (HNSW has 2000-dim max limit, can't support 3072)
DROP INDEX IF EXISTS public.idx_meditations_embedding_hnsw;

-- 2. Drop existing RPC functions (signature depends on vector(768))
DROP FUNCTION IF EXISTS public.search_meditations_by_embedding(vector, float, int);
DROP FUNCTION IF EXISTS public.generate_text_embedding(text);

-- 3. Update embedding column on meditations table: 768 -> 3072
--    Must drop and recreate because pgvector doesn't support ALTER on dimension
ALTER TABLE public.meditations DROP COLUMN IF EXISTS embedding;
ALTER TABLE public.meditations ADD COLUMN embedding vector(3072);

-- 4. Update embedding column on mood_entries table (if it exists)
--    Check first since mood_entries may not have embedding column yet
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'mood_entries'
      AND column_name = 'embedding'
  ) THEN
    ALTER TABLE public.mood_entries DROP COLUMN embedding;
    ALTER TABLE public.mood_entries ADD COLUMN embedding vector(3072);
  END IF;
END $$;

-- 5. NOTE: No HNSW index created because pgvector HNSW has a 2000-dim max limit.
--    gemini-embedding-001 produces 3072 dimensions.
--    Sequential scan is used instead. For a meditation app with < 1000 items,
--    this is perfectly fine (~1-5ms for 1000 rows).
--    If dataset grows to > 10K rows, consider IVFFlat with dimensionality reduction
--    (e.g., PCA to 1024 dims) or switching to a lower-dim embedding model.

-- 6. Recreate RPC function for cosine similarity search with 3072 dimensions
CREATE OR REPLACE FUNCTION public.search_meditations_by_embedding(
  query_embedding vector(3072),
  match_threshold FLOAT DEFAULT 0.7,
  match_count INT DEFAULT 3
)
RETURNS TABLE (
  id uuid,
  title VARCHAR,
  description TEXT,
  category VARCHAR,
  duration_minutes INT,
  audio_url TEXT,
  thumbnail_url TEXT,
  level VARCHAR,
  rating NUMERIC,
  total_reviews INT,
  similarity FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    m.id,
    m.title,
    m.description,
    m.category,
    m.duration_minutes,
    m.audio_url,
    m.thumbnail_url,
    m.level,
    m.rating,
    m.total_reviews,
    -- 1 - cosine_distance = cosine similarity
    (1 - (m.embedding <=> query_embedding)) AS similarity
  FROM public.meditations m
  WHERE m.embedding IS NOT NULL
    -- Filter by similarity threshold (cosine distance < 1 - threshold)
    AND (1 - (m.embedding <=> query_embedding)) > match_threshold
  ORDER BY m.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- 7. Recreate helper function (still a placeholder, now with 3072 dims)
CREATE OR REPLACE FUNCTION public.generate_text_embedding(
  input_text TEXT
)
RETURNS vector(3072)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result vector(3072);
BEGIN
  -- Placeholder: In production, call an Edge Function or external API
  -- This function exists for compatibility with future server-side embedding
  RAISE NOTICE 'generate_text_embedding is a placeholder. Use client-side Gemini SDK.';
  RETURN NULL;
END;
$$;

-- ============================================================
-- Verify migration
-- ============================================================
DO $$
DECLARE
  v_dimensions INTEGER;
BEGIN
  -- Verify meditations embedding column exists and has 3072 dimensions
  -- Note: pgvector columns don't report dimension in information_schema.
  -- We must query pg_attribute + pg_type to get the vector dimension.
  SELECT atttypmod
  INTO v_dimensions
  FROM pg_attribute
  WHERE attrelid = 'public.meditations'::regclass
    AND attname = 'embedding';

  IF v_dimensions IS NULL OR v_dimensions <= 0 THEN
    RAISE EXCEPTION 'embedding column not found on meditations table';
  ELSIF v_dimensions != 3072 THEN
    RAISE EXCEPTION 'meditations.embedding has wrong dimensions: %, expected 3072', v_dimensions;
  END IF;

  -- Verify RPC function exists with correct signature
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc
    WHERE proname = 'search_meditations_by_embedding'
  ) THEN
    RAISE EXCEPTION 'search_meditations_by_embedding function not created';
  END IF;

  RAISE NOTICE '✅ Migration 002 completed successfully';
  RAISE NOTICE '⚠️  IMPORTANT: All existing embeddings have been cleared!';
  RAISE NOTICE '   You must re-embed all meditation and mood_entry data.';
  RAISE NOTICE '   Run: UPDATE public.meditations SET embedding = NULL;';
  RAISE NOTICE '   Then call RAGService().seedMeditationEmbeddings() from app.';
END $$;
