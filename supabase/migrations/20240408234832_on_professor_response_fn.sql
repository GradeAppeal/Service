CREATE
OR replace FUNCTION on_professor_response() returns TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET
    search_path = PUBLIC AS $$
DECLARE
    professor_fname text;

professor_lname text;

professor_name text;

student_name text;

student_email text;

assignment text;

course_prefix text;

course_code bigint;

course text;

BEGIN
    -- get assignment
    SELECT
        assignment_name INTO assignment
    FROM
        PUBLIC."Assignments" AS A
        INNER JOIN PUBLIC."Appeals" AS app ON A .id = app.assignment_id
        INNER JOIN PUBLIC."Messages" AS m ON app.id = m.appeal_id
    WHERE
        m.id = NEW .id;

-- get student recipient (can be student or grader)
SELECT
    s.first_name AS student_name,
    s.email AS student_email INTO student_name,
    student_email
FROM
    PUBLIC."Students" AS s
    INNER JOIN PUBLIC."Messages" AS m ON s.id = m.recipient_id
WHERE
    m.id = NEW .id;

-- get professor name 
SELECT
    p.first_name AS professor_fname,
    p.last_name AS professor_lname INTO professor_fname,
    professor_lname
FROM
    PUBLIC."Professors" AS p
    INNER JOIN PUBLIC."Messages" AS m ON p.id = m.sender_id
WHERE
    m.id = NEW .id;

professor_name := professor_fname || ' ' || professor_lname;

-- get course (e.g. CS112)
SELECT
    C .code AS course_code,
    C .prefix AS course_prefix INTO course_code,
    course_prefix
FROM
    PUBLIC."Courses" AS C
    INNER JOIN PUBLIC."Assignments" AS A ON C .id = A .course_id
    INNER JOIN PUBLIC."Appeals" AS app ON A .id = app.assignment_id
    INNER JOIN PUBLIC."Messages" AS m ON app.id = m.appeal_id
WHERE
    m.id = NEW .id;

course := course_prefix || course_code :: text;

-- send email 
PERFORM net.http_post(
    -- URL of Edge function
    url := 'https://nsxdlyqbigoijypmnsqe.supabase.co/functions/v1/send-professor-response-notification',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zeGRseXFiaWdvaWp5cG1uc3FlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTgwNjU2MzgsImV4cCI6MjAxMzY0MTYzOH0._1H9yDTwcKPdpGXnI_b2fcTtZb4q7HPhezuTHkT5s70"}' :: jsonb,
    BODY := format(
        '{"professorName": "%s", "studentName": "%s", "studentEmail": "%s", "assignment": "%s", "course": "%s"}',
        professor_name,
        student_name,
        student_email,
        assignment,
        course
    ) :: jsonb
) AS request_id;

RETURN NEW;

END;

$$;