-- =====================================================
-- MIGRATION: Add supabase_uid column to users table
-- Run this if you already have the users table
-- =====================================================

-- Add supabase_uid column
ALTER TABLE users ADD COLUMN IF NOT EXISTS supabase_uid VARCHAR(255) UNIQUE;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_supabase_uid ON users(supabase_uid);

-- Remove UNIQUE constraint from phone if it's causing issues with OAuth users
-- (OAuth users might not have phone initially)
ALTER TABLE users ALTER COLUMN phone DROP NOT NULL;

-- Update: Allow empty string or null for phone
-- This is needed because Google OAuth doesn't provide phone number
