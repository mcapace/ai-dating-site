-- Project Jules Database Schema
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- USERS & PROFILES
-- ============================================

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    phone TEXT UNIQUE NOT NULL,
    status TEXT NOT NULL DEFAULT 'onboarding' CHECK (status IN ('onboarding', 'active', 'paused', 'banned')),
    subscription_tier TEXT NOT NULL DEFAULT 'free' CHECK (subscription_tier IN ('free', 'premium')),
    subscription_expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User profiles
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    first_name TEXT NOT NULL,
    birth_date DATE NOT NULL,
    gender TEXT NOT NULL CHECK (gender IN ('man', 'woman', 'nonbinary')),
    height_inches INTEGER,
    has_children BOOLEAN,
    wants_children TEXT CHECK (wants_children IN ('yes', 'no', 'someday', 'not_sure')),
    occupation TEXT,
    bio TEXT,
    ethnicity TEXT,
    religion TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id)
);

-- User photos
CREATE TABLE public.photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    position INTEGER NOT NULL DEFAULT 0,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User preferences (who they're looking for)
CREATE TABLE public.preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    interested_in TEXT[] NOT NULL DEFAULT '{}',
    min_age INTEGER NOT NULL DEFAULT 18,
    max_age INTEGER NOT NULL DEFAULT 99,
    min_height_inches INTEGER,
    max_height_inches INTEGER,
    max_distance_miles INTEGER DEFAULT 25,
    open_to_has_children BOOLEAN DEFAULT TRUE,
    open_to_wants_children BOOLEAN DEFAULT TRUE,
    dealbreakers TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id)
);

-- ============================================
-- LOCATIONS
-- ============================================

-- Cities
CREATE TABLE public.cities (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    state TEXT,
    country TEXT NOT NULL DEFAULT 'US',
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    timezone TEXT NOT NULL DEFAULT 'America/New_York',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Neighborhoods
CREATE TABLE public.neighborhoods (
    id TEXT PRIMARY KEY,
    city_id TEXT NOT NULL REFERENCES public.cities(id),
    name TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User neighborhoods (where they want to date)
CREATE TABLE public.user_neighborhoods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    neighborhood_id TEXT NOT NULL REFERENCES public.neighborhoods(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, neighborhood_id)
);

-- ============================================
-- VENUES
-- ============================================

CREATE TABLE public.venues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    neighborhood_id TEXT NOT NULL REFERENCES public.neighborhoods(id),
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    venue_type TEXT NOT NULL CHECK (venue_type IN ('restaurant', 'bar', 'coffee', 'activity', 'park')),
    vibe TEXT CHECK (vibe IN ('casual', 'upscale', 'trendy', 'cozy', 'lively')),
    price_range TEXT CHECK (price_range IN ('$', '$$', '$$$', '$$$$')),
    noise_level TEXT CHECK (noise_level IN ('quiet', 'moderate', 'loud')),
    photo_url TEXT,
    google_place_id TEXT,
    is_partner BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- MATCHING
-- ============================================

-- Matches (potential pairings identified by Jules)
CREATE TABLE public.matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user1_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    user2_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    compatibility_score DECIMAL(3, 2),
    jules_reasoning TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'pitched', 'accepted', 'declined', 'expired')),
    pitched_to_user1_at TIMESTAMPTZ,
    pitched_to_user2_at TIMESTAMPTZ,
    user1_response TEXT CHECK (user1_response IN ('accepted', 'declined')),
    user2_response TEXT CHECK (user2_response IN ('accepted', 'declined')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user1_id, user2_id)
);

-- Intros (active connections after both accept)
CREATE TABLE public.intros (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID NOT NULL REFERENCES public.matches(id) ON DELETE CASCADE,
    user1_id UUID NOT NULL REFERENCES public.users(id),
    user2_id UUID NOT NULL REFERENCES public.users(id),
    status TEXT NOT NULL DEFAULT 'spark_exchange' CHECK (status IN ('spark_exchange', 'scheduling', 'scheduled', 'completed', 'cancelled')),
    scheduled_at TIMESTAMPTZ,
    venue_id UUID REFERENCES public.venues(id),
    cancelled_by UUID REFERENCES public.users(id),
    cancellation_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(match_id)
);

-- Spark Exchange prompts
CREATE TABLE public.spark_prompts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category TEXT NOT NULL CHECK (category IN ('icebreaker', 'values', 'lifestyle', 'fun', 'deep')),
    prompt_text TEXT NOT NULL,
    allow_voice_note BOOLEAN NOT NULL DEFAULT TRUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Spark Exchange responses
CREATE TABLE public.spark_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    intro_id UUID NOT NULL REFERENCES public.intros(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id),
    prompt_id UUID NOT NULL REFERENCES public.spark_prompts(id),
    response_text TEXT,
    voice_note_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(intro_id, user_id, prompt_id)
);

-- User availability for scheduling
CREATE TABLE public.user_availability (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    intro_id UUID NOT NULL REFERENCES public.intros(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id),
    available_date DATE NOT NULL,
    time_slot TEXT NOT NULL CHECK (time_slot IN ('morning', 'afternoon', 'evening')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(intro_id, user_id, available_date, time_slot)
);

-- Date feedback
CREATE TABLE public.date_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    intro_id UUID NOT NULL REFERENCES public.intros(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id),
    rating TEXT NOT NULL CHECK (rating IN ('excellent', 'good', 'neutral', 'poor')),
    would_see_again BOOLEAN,
    feedback_text TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(intro_id, user_id)
);

-- ============================================
-- JULES AI CONVERSATIONS
-- ============================================

CREATE TABLE public.jules_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    context TEXT NOT NULL DEFAULT 'general' CHECK (context IN ('onboarding', 'general', 'match_pitch', 'scheduling', 'feedback')),
    related_intro_id UUID REFERENCES public.intros(id),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.jules_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES public.jules_conversations(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'jules', 'system')),
    content TEXT NOT NULL,
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'match_card', 'spark_prompt', 'schedule_request', 'quick_reply')),
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- JULES LEARNING SYSTEM
-- ============================================

-- Communication profile (how user likes to interact)
CREATE TABLE public.communication_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    preferred_message_length TEXT DEFAULT 'medium' CHECK (preferred_message_length IN ('short', 'medium', 'long')),
    emoji_usage TEXT DEFAULT 'moderate' CHECK (emoji_usage IN ('none', 'minimal', 'moderate', 'frequent')),
    humor_appreciation DECIMAL(3, 2) DEFAULT 0.5,
    directness_preference DECIMAL(3, 2) DEFAULT 0.5,
    relationship_stage TEXT DEFAULT 'new' CHECK (relationship_stage IN ('new', 'building', 'comfortable', 'close')),
    total_interactions INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id)
);

-- Learned preferences (what Jules learns about user's dating preferences)
CREATE TABLE public.learned_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    preference_key TEXT NOT NULL,
    preference_value TEXT NOT NULL,
    confidence DECIMAL(3, 2) NOT NULL DEFAULT 0.5,
    source TEXT NOT NULL CHECK (source IN ('explicit', 'inferred', 'feedback')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, category, preference_key)
);

-- ============================================
-- NOTIFICATIONS
-- ============================================

CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('new_match', 'spark_response', 'date_scheduled', 'date_reminder', 'feedback_request', 'system')),
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX idx_profiles_user_id ON public.profiles(user_id);
CREATE INDEX idx_photos_user_id ON public.photos(user_id);
CREATE INDEX idx_preferences_user_id ON public.preferences(user_id);
CREATE INDEX idx_user_neighborhoods_user_id ON public.user_neighborhoods(user_id);
CREATE INDEX idx_matches_user1 ON public.matches(user1_id);
CREATE INDEX idx_matches_user2 ON public.matches(user2_id);
CREATE INDEX idx_matches_status ON public.matches(status);
CREATE INDEX idx_intros_user1 ON public.intros(user1_id);
CREATE INDEX idx_intros_user2 ON public.intros(user2_id);
CREATE INDEX idx_intros_status ON public.intros(status);
CREATE INDEX idx_jules_conversations_user ON public.jules_conversations(user_id);
CREATE INDEX idx_jules_messages_conversation ON public.jules_messages(conversation_id);
CREATE INDEX idx_notifications_user ON public.notifications(user_id, is_read);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_neighborhoods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.intros ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.spark_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.date_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jules_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jules_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communication_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learned_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data
CREATE POLICY "Users can view own data" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own data" ON public.users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own photos" ON public.photos FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own photos" ON public.photos FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own preferences" ON public.preferences FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own preferences" ON public.preferences FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own neighborhoods" ON public.user_neighborhoods FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own neighborhoods" ON public.user_neighborhoods FOR ALL USING (auth.uid() = user_id);

-- Matches: users can see matches they're part of
CREATE POLICY "Users can view own matches" ON public.matches FOR SELECT USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Intros: users can see intros they're part of
CREATE POLICY "Users can view own intros" ON public.intros FOR SELECT USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Spark responses: users can see responses in their intros
CREATE POLICY "Users can view intro spark responses" ON public.spark_responses FOR SELECT
USING (EXISTS (SELECT 1 FROM public.intros WHERE id = intro_id AND (user1_id = auth.uid() OR user2_id = auth.uid())));
CREATE POLICY "Users can add own spark responses" ON public.spark_responses FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Jules conversations and messages
CREATE POLICY "Users can view own conversations" ON public.jules_conversations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own conversations" ON public.jules_conversations FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own messages" ON public.jules_messages FOR SELECT
USING (EXISTS (SELECT 1 FROM public.jules_conversations WHERE id = conversation_id AND user_id = auth.uid()));
CREATE POLICY "Users can add messages to own conversations" ON public.jules_messages FOR INSERT
WITH CHECK (EXISTS (SELECT 1 FROM public.jules_conversations WHERE id = conversation_id AND user_id = auth.uid()));

-- Notifications
CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);

-- Communication profiles
CREATE POLICY "Users can view own comm profile" ON public.communication_profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own comm profile" ON public.communication_profiles FOR ALL USING (auth.uid() = user_id);

-- Learned preferences
CREATE POLICY "Users can view own learned prefs" ON public.learned_preferences FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own learned prefs" ON public.learned_preferences FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- SEED DATA
-- ============================================

-- NYC City
INSERT INTO public.cities (id, name, state, country, is_active, timezone) VALUES
('nyc', 'New York City', 'NY', 'US', TRUE, 'America/New_York');

-- NYC Neighborhoods
INSERT INTO public.neighborhoods (id, city_id, name, is_active) VALUES
-- Manhattan Downtown
('tribeca', 'nyc', 'Tribeca', TRUE),
('soho', 'nyc', 'SoHo', TRUE),
('west_village', 'nyc', 'West Village', TRUE),
('east_village', 'nyc', 'East Village', TRUE),
('lower_east_side', 'nyc', 'Lower East Side', TRUE),
('financial_district', 'nyc', 'Financial District', TRUE),
('chelsea', 'nyc', 'Chelsea', TRUE),
('greenwich_village', 'nyc', 'Greenwich Village', TRUE),
-- Manhattan Midtown
('midtown_east', 'nyc', 'Midtown East', TRUE),
('midtown_west', 'nyc', 'Midtown West', TRUE),
('hells_kitchen', 'nyc', 'Hell''s Kitchen', TRUE),
('gramercy', 'nyc', 'Gramercy', TRUE),
('flatiron', 'nyc', 'Flatiron', TRUE),
('murray_hill', 'nyc', 'Murray Hill', TRUE),
-- Manhattan Uptown
('upper_east_side', 'nyc', 'Upper East Side', TRUE),
('upper_west_side', 'nyc', 'Upper West Side', TRUE),
('harlem', 'nyc', 'Harlem', TRUE),
('morningside_heights', 'nyc', 'Morningside Heights', TRUE),
-- Brooklyn
('williamsburg', 'nyc', 'Williamsburg', TRUE),
('dumbo', 'nyc', 'DUMBO', TRUE),
('brooklyn_heights', 'nyc', 'Brooklyn Heights', TRUE),
('cobble_hill', 'nyc', 'Cobble Hill', TRUE),
('park_slope', 'nyc', 'Park Slope', TRUE),
('fort_greene', 'nyc', 'Fort Greene', TRUE),
('greenpoint', 'nyc', 'Greenpoint', TRUE),
('bushwick', 'nyc', 'Bushwick', TRUE),
('prospect_heights', 'nyc', 'Prospect Heights', TRUE),
-- Other
('astoria', 'nyc', 'Astoria', TRUE),
('long_island_city', 'nyc', 'Long Island City', TRUE),
('jersey_city', 'nyc', 'Jersey City', TRUE),
('hoboken', 'nyc', 'Hoboken', TRUE);

-- Spark Exchange Prompts
INSERT INTO public.spark_prompts (category, prompt_text, allow_voice_note) VALUES
-- Icebreakers
('icebreaker', 'What''s something you''re weirdly passionate about?', TRUE),
('icebreaker', 'What''s the best meal you''ve had recently?', TRUE),
('icebreaker', 'What''s your go-to karaoke song?', TRUE),
('icebreaker', 'What''s the last thing that made you laugh out loud?', TRUE),
-- Values
('values', 'What does a perfect Sunday look like for you?', TRUE),
('values', 'What''s something you''re proud of that has nothing to do with work?', TRUE),
('values', 'What''s a belief you held strongly that you''ve since changed your mind about?', TRUE),
-- Lifestyle
('lifestyle', 'What''s your go-to comfort food?', FALSE),
('lifestyle', 'Are you a morning person or a night owl?', FALSE),
('lifestyle', 'What''s your ideal vacation: adventure, relaxation, or culture?', TRUE),
-- Fun
('fun', 'What''s your most unpopular opinion?', TRUE),
('fun', 'If you could have dinner with anyone, dead or alive, who would it be?', TRUE),
('fun', 'What''s a skill you wish you had?', TRUE),
-- Deep
('deep', 'What''s something you''re working on improving about yourself?', TRUE),
('deep', 'What does love mean to you?', TRUE),
('deep', 'What''s a question you wish people would ask you more often?', TRUE);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_preferences_updated_at BEFORE UPDATE ON public.preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON public.matches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_intros_updated_at BEFORE UPDATE ON public.intros FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_jules_conversations_updated_at BEFORE UPDATE ON public.jules_conversations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_communication_profiles_updated_at BEFORE UPDATE ON public.communication_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_learned_preferences_updated_at BEFORE UPDATE ON public.learned_preferences FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_venues_updated_at BEFORE UPDATE ON public.venues FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
