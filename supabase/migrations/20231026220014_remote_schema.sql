set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.insert_assignment(cid bigint, assignment_name text)
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
DECLARE
    BEGIN
        INSERT INTO
            PUBLIC."Assignments" (course_id, assignment_name)
        VALUES
            (cid, assignment_name);

RETURN 1;

EXCEPTION
    WHEN OTHERS THEN RETURN 0;

END;

$function$
;

CREATE OR REPLACE FUNCTION public.insert_student(student_email text, cid bigint)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
    student_id uuid;

BEGIN
    SELECT
        id
    FROM
        PUBLIC."Students"
    WHERE
        email = student_email INTO student_id;

INSERT INTO
    "StudentCourse" (student_id, course_id, is_grader)
VALUES
    (sid, cid, FALSE);

RETURN TRUE;

EXCEPTION
    WHEN OTHERS THEN RETURN FALSE;

END;

$function$
;


