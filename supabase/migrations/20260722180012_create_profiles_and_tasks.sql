/*
# VOLT — Create profiles and tasks tables

1. Purpose
   VOLT is a productivity app where each task consumes "Volts" (energy).
   Users have a daily Volt budget to prevent overload/burnout.

2. New Tables
   - `profiles`
     - `id` (uuid, PK, references auth.users) — one row per user
     - `daily_volt_limit` (int, default 100) — max Volts the user can plan per day
     - `created_at` (timestamptz)
   - `tasks`
     - `id` (uuid, PK)
     - `user_id` (uuid, FK → auth.users, defaults to auth.uid())
     - `title` (text, not null)
     - `description` (text, nullable)
     - `due_date` (date, not null) — the day the Volt is consumed
     - `volts` (int, not null, default 10) — energy cost (e.g. 10=low, 50=high)
     - `status` (text, not null, default 'todo') — 'todo' | 'in_progress' | 'done'
     - `created_at` (timestamptz)
     - `updated_at` (timestamptz)

3. Security (RLS)
   - Both tables enable RLS.
   - `profiles`: owner-scoped CRUD (authenticated, auth.uid() = id).
   - `tasks`: owner-scoped CRUD (authenticated, auth.uid() = user_id).
   - The `user_id` column defaults to auth.uid() so inserts that omit it still pass the WITH CHECK.

4. Indexes
   - `tasks_user_due_date_idx` for fetching a user's tasks on a given day.

5. Trigger
   - `handle_new_user`: auto-creates a `profiles` row when a new auth.users row is inserted.
*/

-- ── profiles ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  daily_volt_limit int NOT NULL DEFAULT 100 CHECK (daily_volt_limit > 0),
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_own_profile" ON profiles;
CREATE POLICY "select_own_profile" ON profiles FOR SELECT
  TO authenticated USING (auth.uid() = id);

DROP POLICY IF EXISTS "insert_own_profile" ON profiles;
CREATE POLICY "insert_own_profile" ON profiles FOR INSERT
  TO authenticated WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "update_own_profile" ON profiles;
CREATE POLICY "update_own_profile" ON profiles FOR UPDATE
  TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "delete_own_profile" ON profiles;
CREATE POLICY "delete_own_profile" ON profiles FOR DELETE
  TO authenticated USING (auth.uid() = id);

-- ── tasks ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES auth.users(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  due_date date NOT NULL,
  volts int NOT NULL DEFAULT 10 CHECK (volts >= 0),
  status text NOT NULL DEFAULT 'todo' CHECK (status IN ('todo','in_progress','done')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_own_tasks" ON tasks;
CREATE POLICY "select_own_tasks" ON tasks FOR SELECT
  TO authenticated USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "insert_own_tasks" ON tasks;
CREATE POLICY "insert_own_tasks" ON tasks FOR INSERT
  TO authenticated WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "update_own_tasks" ON tasks;
CREATE POLICY "update_own_tasks" ON tasks FOR UPDATE
  TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "delete_own_tasks" ON tasks;
CREATE POLICY "delete_own_tasks" ON tasks FOR DELETE
  TO authenticated USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS tasks_user_due_date_idx ON tasks(user_id, due_date);

-- ── updated_at trigger ────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tasks_set_updated_at ON tasks;
CREATE TRIGGER tasks_set_updated_at
  BEFORE UPDATE ON tasks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── auto-create profile on signup ─────────────────────────
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id) VALUES (NEW.id);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();