-- Add admin role to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_admin boolean DEFAULT false;

-- Create an admin view policy (optional, to let admins view all profiles if not already possible)
-- Or just rely on the Edge Function's service role key for all admin operations.
