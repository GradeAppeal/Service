-- Enable RLS on PUBLIC. "Messages"
ALTER TABLE
    PUBLIC."Messages" enable ROW LEVEL security;

/* users should only be able to view interactions in which they are either a sender or recipient
 *  professor-student // student-professor
 *  professor-grader // grader-professor
 */
CREATE policy "Users can only view interactions in which they are either a sender or recipient" ON PUBLIC."Messages" FOR
SELECT
    TO authenticated USING (
        auth.uid() = recipient_id
        OR auth.uid() = sender_id
    );

/* users can send messages (INSERT to PUBLIC. "Messages") if they are the sender
 *  professor-student // student-professor
 *  professor-grader // grader-professor
 */
CREATE policy "Users can interact by sending messages" ON PUBLIC."Messages" FOR
INSERT
    WITH CHECK (auth.uid() = sender_id);