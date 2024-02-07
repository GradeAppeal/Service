-- enable rls
ALTER TABLE
  PUBLIC."Appeals" enable ROW LEVEL security;

-- -- 3. Create Policy
-- CREATE policy "students can view appeals" ON PUBLIC."Appeals" FOR
-- UPDATE
--   TO authenticated USING (auth.uid() = student_id);