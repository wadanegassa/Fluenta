-- Add ON DELETE CASCADE to foreign keys referencing profiles

ALTER TABLE public.lesson_content DROP CONSTRAINT IF EXISTS lesson_content_user_id_fkey;
ALTER TABLE public.lesson_content ADD CONSTRAINT lesson_content_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.user_lesson_progress DROP CONSTRAINT IF EXISTS user_lesson_progress_user_id_fkey;
ALTER TABLE public.user_lesson_progress ADD CONSTRAINT user_lesson_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.placement_results DROP CONSTRAINT IF EXISTS placement_results_user_id_fkey;
ALTER TABLE public.placement_results ADD CONSTRAINT placement_results_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.writing_submissions DROP CONSTRAINT IF EXISTS writing_submissions_user_id_fkey;
ALTER TABLE public.writing_submissions ADD CONSTRAINT writing_submissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.speaking_submissions DROP CONSTRAINT IF EXISTS speaking_submissions_user_id_fkey;
ALTER TABLE public.speaking_submissions ADD CONSTRAINT speaking_submissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.community_messages DROP CONSTRAINT IF EXISTS community_messages_sender_id_fkey;
ALTER TABLE public.community_messages ADD CONSTRAINT community_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.direct_messages DROP CONSTRAINT IF EXISTS direct_messages_sender_id_fkey;
ALTER TABLE public.direct_messages ADD CONSTRAINT direct_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.direct_messages DROP CONSTRAINT IF EXISTS direct_messages_receiver_id_fkey;
ALTER TABLE public.direct_messages ADD CONSTRAINT direct_messages_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
