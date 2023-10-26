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
 RETURNS void
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
    PUBLIC."StudentCourse" (student_id, course_id, is_grader)
VALUES
    (student_id, cid, FALSE);

RETURN;

EXCEPTION
    WHEN OTHERS THEN -- Log the error message, timestamp, and any other relevant information.
    -- Re-throw the exception so that the caller is aware of the error.
    RAISE
EXCEPTION
    'Error occurred: %',
    SQLERRM;

END;

$function$
;

CREATE TRIGGER tr_on_new_appeal AFTER INSERT ON public."StudentAppeal" FOR EACH ROW EXECUTE FUNCTION on_new_appeal();


