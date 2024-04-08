CREATE
OR REPLACE FUNCTION on_close_appeal() RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET
    search_path = PUBLIC AS $$
DECLARE
    assignment text;

student_name text;

student_email text;

course_code text;

course_prefix text;

course text;

BEGIN
    -- get assignment
    SELECT
        assignment_name INTO assignment
    FROM
        PUBLIC."Assignments"
    WHERE
        id = NEW .assignment_id;

-- get course (e.g. CS112)
SELECT
    C .code AS course_code,
    C .prefix AS course_prefix INTO course_code,
    course_prefix
FROM
    PUBLIC."Courses" AS C
    INNER JOIN PUBLIC."Assignments" AS A ON C .id = A .course_id
    INNER JOIN PUBLIC."Appeals" AS app ON A .id = app.assignment_id
WHERE
    app.id = NEW .id;

-- get student name and email
SELECT
    s.first_name AS student_name,
    s.email AS student_email INTO student_name,
    student_email
FROM
    PUBLIC."Students" AS s
    INNER JOIN PUBLIC."StudentAppeal" AS sa ON s.id = sa.student_id
    INNER JOIN PUBLIC."Appeals" AS app ON sa.appeal_id = app.id
WHERE
    app.id = NEW .id;

course := course_prefix || course_code :: text;

-- send email 
PERFORM net.http_post(
    -- URL of Edge function
    url := 'https://nsxdlyqbigoijypmnsqe.supabase.co/functions/v1/send-appeal-closed-email',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zeGRseXFiaWdvaWp5cG1uc3FlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTgwNjU2MzgsImV4cCI6MjAxMzY0MTYzOH0._1H9yDTwcKPdpGXnI_b2fcTtZb4q7HPhezuTHkT5s70"}' :: jsonb,
    BODY := format(
        '{"studentName": "%s", "studentEmail": "%s", "assignment": "%s", "course": "%s"}',
        student_name,
        student_email,
        assignment,
        course
    ) :: jsonb
) AS request_id;

RETURN NEW;

END;

$$;