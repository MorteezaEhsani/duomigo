-- Create enum type for prompt types
CREATE TYPE prompt_type AS ENUM (
    'listenThenSpeak',
    'readThenSpeak',
    'speakingSample',
    'speakAboutPhoto'
);

-- Create prompts table
CREATE TABLE public.prompts (
    id TEXT PRIMARY KEY,
    type prompt_type NOT NULL,
    text TEXT,
    image_url TEXT,
    prep_seconds INT DEFAULT 20,
    min_seconds INT DEFAULT 30,
    max_seconds INT DEFAULT 90,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create attempts table
CREATE TABLE public.attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    prompt_id TEXT REFERENCES public.prompts(id),
    prep_sec INT,
    speak_sec INT,
    audio_path TEXT,
    transcript TEXT,
    metrics JSONB,
    rubric JSONB,
    overall INT,
    cefr TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.prompts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attempts ENABLE ROW LEVEL SECURITY;

-- RLS Policies for prompts table
-- Anyone can select prompts
CREATE POLICY "Allow public read access to prompts" ON public.prompts
    FOR SELECT
    USING (true);

-- RLS Policies for attempts table
-- Users can only see their own attempts
CREATE POLICY "Users can view own attempts" ON public.attempts
    FOR SELECT
    USING (auth.uid() = user_id);

-- Users can only insert their own attempts
CREATE POLICY "Users can insert own attempts" ON public.attempts
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can only update their own attempts
CREATE POLICY "Users can update own attempts" ON public.attempts
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Seed data for prompts
INSERT INTO public.prompts (id, type, text, image_url, prep_seconds, min_seconds, max_seconds) VALUES
    ('listen-1', 'listenThenSpeak', 'Listen to the audio and repeat what you hear. Focus on pronunciation and intonation.', NULL, 20, 30, 60),
    ('read-1', 'readThenSpeak', 'Read the following passage aloud: "The quick brown fox jumps over the lazy dog. This pangram contains all letters of the alphabet and is commonly used for typing practice."', NULL, 30, 45, 90),
    ('sample-1', 'speakingSample', 'Describe your favorite hobby and explain why you enjoy it. Include details about when you started, what equipment or materials you need, and what benefits it brings to your life.', NULL, 30, 60, 90),
    ('photo-1', 'speakAboutPhoto', 'Look at this image and describe what you see. Talk about the setting, the people or objects present, and what might be happening.', 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4', 20, 45, 90);