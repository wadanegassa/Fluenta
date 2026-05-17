-- Add youtube_video_title column to lessons table so the AI can generate
-- a matching transcript based on the actual video content
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS youtube_video_title TEXT;
