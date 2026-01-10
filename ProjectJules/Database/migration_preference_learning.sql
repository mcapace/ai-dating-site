-- Project Jules: Preference Learning Migration
-- Run this in Supabase SQL Editor after the base schema

-- ============================================
-- PREFERENCE LEARNING TABLES
-- ============================================

-- Match signals: Every yes/no teaches Jules something
CREATE TABLE IF NOT EXISTS public.match_signals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    match_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    action TEXT NOT NULL CHECK (action IN ('accepted', 'declined', 'expired', 'super_liked', 'second_date', 'no_second_date')),
    match_profile JSONB NOT NULL,
    time_to_decide INTEGER,
    asked_jules_first BOOLEAN DEFAULT FALSE,
    priority_pass_used BOOLEAN DEFAULT FALSE,
    source TEXT NOT NULL CHECK (source IN ('match_presentation', 'spark_exchange', 'post_date', 'conversation')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Preference patterns: Aggregated learning from signals
CREATE TABLE IF NOT EXISTS public.preference_patterns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    category TEXT NOT NULL CHECK (category IN ('physical', 'demographics', 'lifestyle', 'personality', 'logistics')),
    attribute TEXT NOT NULL,
    value TEXT NOT NULL,
    yes_count INTEGER DEFAULT 0,
    no_count INTEGER DEFAULT 0,
    total_exposures INTEGER DEFAULT 0,
    acceptance_rate DOUBLE PRECISION DEFAULT 0,
    strength TEXT DEFAULT 'emerging' CHECK (strength IN ('emerging', 'developing', 'established', 'strong')),
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT,
    UNIQUE(user_id, attribute, value)
);

-- Taste profiles: Comprehensive user preference summary
CREATE TABLE IF NOT EXISTS public.taste_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
    height_preference JSONB,
    body_type_patterns JSONB DEFAULT '{}',
    style_preferences JSONB DEFAULT '{}',
    age_pattern_min INTEGER,
    age_pattern_max INTEGER,
    ethnicity_patterns JSONB DEFAULT '{}',
    religion_patterns JSONB DEFAULT '{}',
    occupation_patterns JSONB DEFAULT '{}',
    education_patterns JSONB DEFAULT '{}',
    kids_preference_observed TEXT,
    interest_affinities JSONB DEFAULT '{}',
    bio_keyword_affinities JSONB DEFAULT '{}',
    decides_quickly_on TEXT[] DEFAULT '{}',
    needs_time_on TEXT[] DEFAULT '{}',
    dealbreakers TEXT[] DEFAULT '{}',
    super_attractions TEXT[] DEFAULT '{}',
    last_exploratory_match TIMESTAMPTZ,
    exploratory_success_rate DOUBLE PRECISION DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Exploratory matches: Testing outside user's type
CREATE TABLE IF NOT EXISTS public.exploratory_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID REFERENCES public.matches(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    hypothesis TEXT NOT NULL,
    differing_attributes TEXT[] DEFAULT '{}',
    outcome TEXT CHECK (outcome IN ('accepted', 'declined', 'super_liked', 'second_date')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- TOKENS & CREDITS
-- ============================================

-- User tokens: Priority passes and date credits
CREATE TABLE IF NOT EXISTS public.user_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE UNIQUE,
    priority_passes INTEGER DEFAULT 0,
    date_credits INTEGER DEFAULT 0,
    last_refreshed TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Priority pass usage tracking
CREATE TABLE IF NOT EXISTS public.priority_pass_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    to_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    used_at TIMESTAMPTZ DEFAULT NOW(),
    resulted_in_match BOOLEAN DEFAULT FALSE
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX IF NOT EXISTS idx_match_signals_user ON public.match_signals(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_match_signals_match_user ON public.match_signals(match_user_id);
CREATE INDEX IF NOT EXISTS idx_preference_patterns_user ON public.preference_patterns(user_id, attribute);
CREATE INDEX IF NOT EXISTS idx_preference_patterns_strength ON public.preference_patterns(user_id, strength, acceptance_rate DESC);
CREATE INDEX IF NOT EXISTS idx_taste_profiles_user ON public.taste_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_exploratory_matches_user ON public.exploratory_matches(user_id);
CREATE INDEX IF NOT EXISTS idx_user_tokens_user ON public.user_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_priority_pass_usage_from ON public.priority_pass_usage(from_user_id);
CREATE INDEX IF NOT EXISTS idx_priority_pass_usage_to ON public.priority_pass_usage(to_user_id);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.match_signals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.preference_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.taste_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exploratory_matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.priority_pass_usage ENABLE ROW LEVEL SECURITY;

-- Match signals: Users can view and insert their own
CREATE POLICY "Users can view own signals" ON public.match_signals
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own signals" ON public.match_signals
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Preference patterns: Users can view their own
CREATE POLICY "Users can view own patterns" ON public.preference_patterns
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can manage patterns" ON public.preference_patterns
    FOR ALL USING (auth.uid() = user_id);

-- Taste profiles: Users can view their own
CREATE POLICY "Users can view own taste profile" ON public.taste_profiles
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "System can manage taste profiles" ON public.taste_profiles
    FOR ALL USING (auth.uid() = user_id);

-- Exploratory matches: Users can view their own
CREATE POLICY "Users can view own exploratory matches" ON public.exploratory_matches
    FOR SELECT USING (auth.uid() = user_id);

-- User tokens: Users can view their own
CREATE POLICY "Users can view own tokens" ON public.user_tokens
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own tokens" ON public.user_tokens
    FOR UPDATE USING (auth.uid() = user_id);

-- Priority pass usage: Users can view their own
CREATE POLICY "Users can view own pass usage" ON public.priority_pass_usage
    FOR SELECT USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);
CREATE POLICY "Users can insert own pass usage" ON public.priority_pass_usage
    FOR INSERT WITH CHECK (auth.uid() = from_user_id);

-- ============================================
-- TRIGGERS
-- ============================================

-- Auto-update updated_at for taste_profiles
CREATE TRIGGER update_taste_profiles_updated_at
    BEFORE UPDATE ON public.taste_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-update updated_at for user_tokens
CREATE TRIGGER update_user_tokens_updated_at
    BEFORE UPDATE ON public.user_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- UPDATE USERS TABLE FOR NEW SUBSCRIPTION TIERS
-- ============================================

-- Update subscription_tier check constraint to include new tiers
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_subscription_tier_check;
ALTER TABLE public.users ADD CONSTRAINT users_subscription_tier_check
    CHECK (subscription_tier IN ('explorer', 'member', 'unlimited', 'free', 'premium'));

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Function to initialize user tokens on signup
CREATE OR REPLACE FUNCTION initialize_user_tokens()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_tokens (user_id, priority_passes, date_credits)
    VALUES (NEW.id, 0, 0);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to create tokens row when user is created
DROP TRIGGER IF EXISTS create_user_tokens ON public.users;
CREATE TRIGGER create_user_tokens
    AFTER INSERT ON public.users
    FOR EACH ROW EXECUTE FUNCTION initialize_user_tokens();

-- Function to refresh monthly tokens based on subscription
CREATE OR REPLACE FUNCTION refresh_monthly_tokens(p_user_id UUID)
RETURNS void AS $$
DECLARE
    v_tier TEXT;
BEGIN
    SELECT subscription_tier INTO v_tier FROM public.users WHERE id = p_user_id;

    UPDATE public.user_tokens
    SET
        priority_passes = CASE
            WHEN v_tier = 'member' THEN 1
            WHEN v_tier = 'unlimited' THEN 3
            ELSE 0
        END,
        last_refreshed = NOW(),
        updated_at = NOW()
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;
