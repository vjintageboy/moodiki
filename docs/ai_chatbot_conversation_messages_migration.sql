-- AI Chatbot: conversation + messages architecture
-- Run in Supabase SQL Editor

-- 1) Conversations
CREATE TABLE IF NOT EXISTS public.ai_conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users(id),
  title varchar DEFAULT 'New conversation',
  last_message_preview text,
  is_archived boolean DEFAULT false,
  created_at timestamptz DEFAULT timezone('utc', now()),
  updated_at timestamptz DEFAULT timezone('utc', now())
);

-- 2) Messages
CREATE TABLE IF NOT EXISTS public.ai_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES public.ai_conversations(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.users(id),
  role varchar NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content text NOT NULL,
  model_name varchar,
  metadata jsonb,
  prompt_tokens int,
  completion_tokens int,
  total_tokens int,
  latency_ms int,
  created_at timestamptz DEFAULT timezone('utc', now())
);

-- 3) Indexes for performance
CREATE INDEX IF NOT EXISTS idx_ai_conversations_user_updated
ON public.ai_conversations(user_id, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_ai_messages_conversation_created
ON public.ai_messages(conversation_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_ai_messages_user_created
ON public.ai_messages(user_id, created_at DESC);

-- 4) RLS policies (owner can only access own conversations/messages)
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_messages ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY ai_conversations_select_own ON public.ai_conversations
    FOR SELECT USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY ai_conversations_insert_own ON public.ai_conversations
    FOR INSERT WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY ai_conversations_update_own ON public.ai_conversations
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY ai_messages_select_own ON public.ai_messages
    FOR SELECT USING (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY ai_messages_insert_own ON public.ai_messages
    FOR INSERT WITH CHECK (auth.uid() = user_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- 5) Trigger to auto-update ai_conversations.updated_at
CREATE OR REPLACE FUNCTION public.update_ai_conversation_timestamp()
RETURNS trigger AS $$
BEGIN
  UPDATE public.ai_conversations
  SET updated_at = timezone('utc', now()),
      last_message_preview = LEFT(NEW.content, 120)
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_ai_message_touch_conversation ON public.ai_messages;
CREATE TRIGGER trg_ai_message_touch_conversation
AFTER INSERT ON public.ai_messages
FOR EACH ROW EXECUTE FUNCTION public.update_ai_conversation_timestamp();
