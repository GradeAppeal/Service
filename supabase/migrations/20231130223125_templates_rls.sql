-- Enable RLS on PUBLIC. "Messages"
ALTER TABLE
    PUBLIC."Templates" enable ROW LEVEL security;

/* 
 *  Only professors are able to INSERT, UPDATE, SELECT, DELETE templates
 */
CREATE policy "Only professors can CRUD templates" ON PUBLIC."Templates" FOR ALL TO authenticated USING (auth.uid() = professor_id);