-- PROFILES
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  native_language TEXT,
  goal TEXT,
  level TEXT DEFAULT 'unassigned',
  placement_score INTEGER,
  avatar_url TEXT,
  streak_days INTEGER DEFAULT 0,
  last_active DATE,
  reading_avg INTEGER DEFAULT 0,
  writing_avg INTEGER DEFAULT 0,
  listening_avg INTEGER DEFAULT 0,
  speaking_avg INTEGER DEFAULT 0,
  total_lessons_mastered INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- LEVELS
CREATE TABLE public.levels (
  id TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  description TEXT,
  color TEXT,
  total_modules INTEGER DEFAULT 0
);

INSERT INTO public.levels VALUES
  ('A1', 'Beginner', 'You are just starting your English journey.', '#3B5BA5', 3),
  ('A2', 'Elementary', 'You know the basics and are building confidence.', '#2E8B72', 3),
  ('B1', 'Intermediate', 'You can handle everyday conversations.', '#7B4EA6', 3),
  ('B2', 'Upper Intermediate', 'You are becoming fluent and comfortable.', '#D4633A', 3),
  ('C1', 'Advanced', 'You speak with clarity, nuance, and fluency.', '#E8A020', 3);

-- MODULES
CREATE TABLE public.modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  level_id TEXT REFERENCES public.levels(id),
  title TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  order_index INTEGER NOT NULL,
  total_lessons INTEGER DEFAULT 5
);

-- LESSONS
CREATE TABLE public.lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID REFERENCES public.modules(id),
  title TEXT NOT NULL,
  focus_topic TEXT NOT NULL,
  focus_skill TEXT,
  youtube_video_id TEXT,
  order_index INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- LESSON CONTENT (AI-generated, cached)
CREATE TABLE public.lesson_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID REFERENCES public.lessons(id),
  user_id UUID REFERENCES public.profiles(id),
  grammar_explanation TEXT,
  vocabulary_list JSONB,
  reading_passage TEXT,
  reading_questions JSONB,
  listening_transcript TEXT,
  listening_exercises JSONB,
  writing_prompt TEXT,
  speaking_prompt TEXT,
  generated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(lesson_id, user_id)
);

-- USER LESSON PROGRESS
CREATE TABLE public.user_lesson_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id),
  lesson_id UUID REFERENCES public.lessons(id),
  is_unlocked BOOLEAN DEFAULT FALSE,
  is_mastered BOOLEAN DEFAULT FALSE,
  mastery_score INTEGER DEFAULT 0,
  attempts INTEGER DEFAULT 0,
  reading_score INTEGER DEFAULT 0,
  writing_score INTEGER DEFAULT 0,
  listening_score INTEGER DEFAULT 0,
  speaking_score INTEGER DEFAULT 0,
  last_attempt_at TIMESTAMPTZ,
  mastered_at TIMESTAMPTZ,
  UNIQUE(user_id, lesson_id)
);

-- PLACEMENT TEST QUESTIONS
CREATE TABLE public.placement_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  skill TEXT NOT NULL,
  question_text TEXT NOT NULL,
  question_type TEXT NOT NULL,
  options JSONB,
  correct_answer TEXT,
  difficulty_score INTEGER,
  level_target TEXT
);

-- PLACEMENT RESULTS
CREATE TABLE public.placement_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id),
  answers JSONB,
  final_level TEXT,
  total_score INTEGER,
  taken_at TIMESTAMPTZ DEFAULT NOW()
);

-- WRITING SUBMISSIONS
CREATE TABLE public.writing_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id),
  lesson_id UUID REFERENCES public.lessons(id),
  user_text TEXT NOT NULL,
  gemini_feedback TEXT,
  corrected_text TEXT,
  score INTEGER,
  submitted_at TIMESTAMPTZ DEFAULT NOW()
);

-- SPEAKING SUBMISSIONS
CREATE TABLE public.speaking_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id),
  lesson_id UUID REFERENCES public.lessons(id),
  audio_url TEXT,
  transcription TEXT,
  gemini_feedback TEXT,
  score INTEGER,
  submitted_at TIMESTAMPTZ DEFAULT NOW()
);

-- COMMUNITY ROOMS
CREATE TABLE public.community_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  is_public BOOLEAN DEFAULT TRUE,
  member_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO public.community_rooms (name, description, icon) VALUES
  ('Free Talk', 'Just talk. Any topic. Any level.', '💬'),
  ('Grammar Help', 'Ask grammar questions. Get clear answers.', '📖'),
  ('Speaking Practice', 'Share recordings. Get peer feedback.', '🎙️'),
  ('Vocabulary Corner', 'Share and learn new words daily.', '🔤'),
  ('Lesson Help', 'Stuck on a lesson? Ask here.', '💡');

-- COMMUNITY MESSAGES
CREATE TABLE public.community_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id UUID REFERENCES public.community_rooms(id),
  sender_id UUID REFERENCES public.profiles(id),
  content TEXT NOT NULL,
  reply_to UUID REFERENCES public.community_messages(id),
  is_deleted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- DIRECT MESSAGES
CREATE TABLE public.direct_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID REFERENCES public.profiles(id),
  receiver_id UUID REFERENCES public.profiles(id),
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS POLICIES
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.writing_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.speaking_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.direct_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Own profile" ON public.profiles FOR ALL USING (auth.uid() = id);
CREATE POLICY "Own progress" ON public.user_lesson_progress FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Own lesson content" ON public.lesson_content FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Own writing" ON public.writing_submissions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Own speaking" ON public.speaking_submissions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Read community messages" ON public.community_messages FOR SELECT TO authenticated USING (TRUE);
CREATE POLICY "Send community messages" ON public.community_messages FOR INSERT TO authenticated WITH CHECK (auth.uid() = sender_id);
CREATE POLICY "DM participants only" ON public.direct_messages FOR ALL USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
