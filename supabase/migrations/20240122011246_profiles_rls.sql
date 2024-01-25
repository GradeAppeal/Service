ALTER TABLE
    PUBLIC."Profiles" enable ROW LEVEL security;

CREATE policy "Public profiles are viewable only by authenticated users" ON PUBLIC."Profiles" FOR
SELECT
    TO authenticated USING (TRUE);