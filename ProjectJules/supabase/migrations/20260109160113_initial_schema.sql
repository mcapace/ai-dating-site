-- Project Jules Database Schema
-- Run this in Supabase SQL Editor

-- Enable UUID extension
DROP EXTENSION IF EXISTS "uuid-ossp";
CREATE EXTENSION "uuid-ossp" WITH SCHEMA public;

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

-- User profiles (extended user information)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    first_name TEXT,
    last_name TEXT,
    date_of_birth DATE,
    bio TEXT,
    gender TEXT,
    occupation TEXT,
    education TEXT,
    height_inches INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User preferences
CREATE TABLE public.user_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    age_min INTEGER DEFAULT 18,
    age_max INTEGER DEFAULT 99,
    max_distance INTEGER DEFAULT 50, -- in miles
    gender_preference TEXT[], -- array of preferred genders
    interests TEXT[], -- array of interest tags
    deal_breakers TEXT[], -- array of deal breaker tags
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User photos
CREATE TABLE public.user_photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    url TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    display_order INTEGER DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- LOCATIONS
-- ============================================

-- Neighborhoods
CREATE TABLE public.neighborhoods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    city TEXT NOT NULL,
    name TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(city, name)
);

-- User neighborhoods (many-to-many)
CREATE TABLE public.user_neighborhoods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    neighborhood_id UUID REFERENCES public.neighborhoods(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, neighborhood_id)
);

-- Venues
CREATE TABLE public.venues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    neighborhood_id UUID REFERENCES public.neighborhoods(id) ON DELETE CASCADE,
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    venue_type TEXT, -- restaurant, bar, cafe, etc.
    price_range TEXT, -- $, $$, $$$, $$$$
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- MATCHING & INTROS
-- ============================================

-- Matches
CREATE TABLE public.matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user1_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    user2_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'matched', 'declined', 'expired')),
    matched_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user1_id, user2_id),
    CHECK (user1_id != user2_id)
);

-- Intros (when Jules introduces two users)
CREATE TABLE public.intros (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE NOT NULL,
    jules_message TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Spark Exchange (initial interest exchange)
CREATE TABLE public.spark_exchanges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE NOT NULL,
    from_user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    to_user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    spark_type TEXT NOT NULL CHECK (spark_type IN ('like', 'super_like', 'pass')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(match_id, from_user_id, to_user_id)
);

-- ============================================
-- DATES & FEEDBACK
-- ============================================

-- Scheduled dates
CREATE TABLE public.scheduled_dates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE NOT NULL,
    venue_id UUID REFERENCES public.venues(id) ON DELETE SET NULL,
    scheduled_date TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')),
    user1_confirmed BOOLEAN DEFAULT FALSE,
    user2_confirmed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Date feedback
CREATE TABLE public.date_feedback (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    scheduled_date_id UUID REFERENCES public.scheduled_dates(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback_text TEXT,
    would_meet_again BOOLEAN,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(scheduled_date_id, user_id)
);

-- ============================================
-- JULES AI CONVERSATIONS
-- ============================================

-- Jules conversations (AI conversation history)
CREATE TABLE public.jules_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    conversation_type TEXT NOT NULL CHECK (conversation_type IN ('onboarding', 'match_intro', 'date_planning', 'feedback')),
    context JSONB, -- flexible context storage
    messages JSONB NOT NULL, -- array of messages
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- LEARNING SYSTEM
-- ============================================

-- User learning system (for improving matches)
CREATE TABLE public.user_learning (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    interaction_type TEXT NOT NULL CHECK (interaction_type IN ('swipe', 'match', 'date', 'feedback')),
    interaction_data JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX idx_users_phone ON public.users(phone);
CREATE INDEX idx_users_status ON public.users(status);
CREATE INDEX idx_user_profiles_user ON public.user_profiles(user_id);
CREATE INDEX idx_matches_user1 ON public.matches(user1_id);
CREATE INDEX idx_matches_user2 ON public.matches(user2_id);
CREATE INDEX idx_matches_status ON public.matches(status);
CREATE INDEX idx_user_photos_user ON public.user_photos(user_id);
CREATE INDEX idx_user_neighborhoods_user ON public.user_neighborhoods(user_id);
CREATE INDEX idx_spark_exchanges_match ON public.spark_exchanges(match_id);
CREATE INDEX idx_scheduled_dates_match ON public.scheduled_dates(match_id);
CREATE INDEX idx_jules_conversations_user ON public.jules_conversations(user_id);
CREATE INDEX idx_user_learning_user ON public.user_learning(user_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_neighborhoods ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.intros ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.spark_exchanges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scheduled_dates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.date_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jules_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_learning ENABLE ROW LEVEL SECURITY;

-- Users: Users can read/update their own profile
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- User profiles: Users can manage their own profile
CREATE POLICY "Users can manage own profile" ON public.user_profiles
    FOR ALL USING (auth.uid() = user_id);

-- User preferences: Users can manage their own preferences
CREATE POLICY "Users can manage own preferences" ON public.user_preferences
    FOR ALL USING (auth.uid() = user_id);

-- User photos: Users can manage their own photos
CREATE POLICY "Users can manage own photos" ON public.user_photos
    FOR ALL USING (auth.uid() = user_id);

-- User neighborhoods: Users can manage their own neighborhoods
CREATE POLICY "Users can manage own neighborhoods" ON public.user_neighborhoods
    FOR ALL USING (auth.uid() = user_id);

-- Matches: Users can view matches they're part of
CREATE POLICY "Users can view own matches" ON public.matches
    FOR SELECT USING (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "Users can create matches" ON public.matches
    FOR INSERT WITH CHECK (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "Users can update own matches" ON public.matches
    FOR UPDATE USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Intros: Users can view intros for their matches
CREATE POLICY "Users can view own intros" ON public.intros
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.matches
            WHERE matches.id = intros.match_id
            AND (matches.user1_id = auth.uid() OR matches.user2_id = auth.uid())
        )
    );

-- Spark exchanges: Users can view/create their own spark exchanges
CREATE POLICY "Users can manage own sparks" ON public.spark_exchanges
    FOR ALL USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);

-- Scheduled dates: Users can view/manage dates they're part of
CREATE POLICY "Users can manage own dates" ON public.scheduled_dates
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.matches
            WHERE matches.id = scheduled_dates.match_id
            AND (matches.user1_id = auth.uid() OR matches.user2_id = auth.uid())
        )
    );

-- Date feedback: Users can create/view their own feedback
CREATE POLICY "Users can manage own feedback" ON public.date_feedback
    FOR ALL USING (auth.uid() = user_id);

-- Jules conversations: Users can manage their own conversations
CREATE POLICY "Users can manage own conversations" ON public.jules_conversations
    FOR ALL USING (auth.uid() = user_id);

-- User learning: Users can view their own learning data
CREATE POLICY "Users can view own learning" ON public.user_learning
    FOR SELECT USING (auth.uid() = user_id);

-- Public read access for neighborhoods and venues (for discovery)
CREATE POLICY "Anyone can view neighborhoods" ON public.neighborhoods
    FOR SELECT USING (true);

CREATE POLICY "Anyone can view venues" ON public.venues
    FOR SELECT USING (true);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON public.user_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_scheduled_dates_updated_at BEFORE UPDATE ON public.scheduled_dates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_jules_conversations_updated_at BEFORE UPDATE ON public.jules_conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

