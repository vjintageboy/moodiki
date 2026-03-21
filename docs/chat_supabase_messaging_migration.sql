-- Chat Supabase migration for messaging MVP
-- Scope: appointment + direct chat, unread/read cursor, typing status, attachments metadata

-- 1) chat_rooms enhancements
ALTER TABLE public.chat_rooms
  ADD COLUMN IF NOT EXISTS room_type character varying DEFAULT 'appointment',
  ADD COLUMN IF NOT EXISTS direct_key text,
  ADD COLUMN IF NOT EXISTS created_by uuid;

CREATE INDEX IF NOT EXISTS idx_chat_rooms_appointment_id
  ON public.chat_rooms (appointment_id);

CREATE UNIQUE INDEX IF NOT EXISTS idx_chat_rooms_direct_key_unique
  ON public.chat_rooms (direct_key)
  WHERE direct_key IS NOT NULL;

-- 2) chat_participants enhancements
ALTER TABLE public.chat_participants
  ADD COLUMN IF NOT EXISTS unread_count integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_read_at timestamp with time zone,
  ADD COLUMN IF NOT EXISTS last_read_message_id uuid;

CREATE INDEX IF NOT EXISTS idx_chat_participants_user_id
  ON public.chat_participants (user_id);

-- 3) messages enhancements
ALTER TABLE public.messages
  ADD COLUMN IF NOT EXISTS attachment_url text,
  ADD COLUMN IF NOT EXISTS attachment_name text,
  ADD COLUMN IF NOT EXISTS attachment_size_bytes integer,
  ADD COLUMN IF NOT EXISTS delivered_at timestamp with time zone,
  ADD COLUMN IF NOT EXISTS read_at timestamp with time zone;

CREATE INDEX IF NOT EXISTS idx_messages_room_id_created_at
  ON public.messages (room_id, created_at DESC);

-- 4) typing table (ephemeral)
CREATE TABLE IF NOT EXISTS public.chat_typing (
  room_id uuid NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  is_typing boolean NOT NULL DEFAULT false,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  PRIMARY KEY (room_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_chat_typing_room_id
  ON public.chat_typing (room_id);

-- 5) Trigger helpers
CREATE OR REPLACE FUNCTION public.chat_on_message_insert()
RETURNS trigger AS $$
BEGIN
  UPDATE public.chat_rooms
  SET
    last_message = CASE
      WHEN NEW.type = 'text' THEN NEW.content
      WHEN NEW.type = 'image' THEN '[image]'
      WHEN NEW.type = 'file' THEN '[file]'
      ELSE '[message]'
    END,
    last_message_time = NEW.created_at,
    updated_at = timezone('utc'::text, now())
  WHERE id = NEW.room_id;

  UPDATE public.chat_participants
  SET unread_count = COALESCE(unread_count, 0) + 1
  WHERE room_id = NEW.room_id AND user_id <> NEW.sender_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_chat_on_message_insert ON public.messages;
CREATE TRIGGER trg_chat_on_message_insert
AFTER INSERT ON public.messages
FOR EACH ROW
EXECUTE FUNCTION public.chat_on_message_insert();

-- 6) Read helper
CREATE OR REPLACE FUNCTION public.chat_mark_room_read(p_room_id uuid, p_user_id uuid)
RETURNS void AS $$
DECLARE
  v_last_message_id uuid;
BEGIN
  SELECT id INTO v_last_message_id
  FROM public.messages
  WHERE room_id = p_room_id
  ORDER BY created_at DESC
  LIMIT 1;

  UPDATE public.chat_participants
  SET
    unread_count = 0,
    last_read_at = timezone('utc'::text, now()),
    last_read_message_id = v_last_message_id
  WHERE room_id = p_room_id AND user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7) Minimal RLS policies for chat tables
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_typing ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  CREATE POLICY chat_rooms_select_participant
    ON public.chat_rooms
    FOR SELECT
    USING (
      EXISTS (
        SELECT 1 FROM public.chat_participants cp
        WHERE cp.room_id = id AND cp.user_id = auth.uid()
      )
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY chat_rooms_insert_authenticated
    ON public.chat_rooms
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY chat_participants_select_own
    ON public.chat_participants
    FOR SELECT
    USING (user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY chat_participants_insert_authenticated
    ON public.chat_participants
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY messages_select_participant
    ON public.messages
    FOR SELECT
    USING (
      EXISTS (
        SELECT 1 FROM public.chat_participants cp
        WHERE cp.room_id = room_id AND cp.user_id = auth.uid()
      )
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY messages_insert_sender
    ON public.messages
    FOR INSERT
    WITH CHECK (
      sender_id = auth.uid() AND EXISTS (
        SELECT 1 FROM public.chat_participants cp
        WHERE cp.room_id = room_id AND cp.user_id = auth.uid()
      )
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY chat_typing_select_participant
    ON public.chat_typing
    FOR SELECT
    USING (
      EXISTS (
        SELECT 1 FROM public.chat_participants cp
        WHERE cp.room_id = room_id AND cp.user_id = auth.uid()
      )
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE POLICY chat_typing_upsert_self
    ON public.chat_typing
    FOR ALL
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
