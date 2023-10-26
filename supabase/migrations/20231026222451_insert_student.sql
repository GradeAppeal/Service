CREATE
OR replace FUNCTION PUBLIC .insert_student(student_email text, cid bigint) RETURNS VOID AS $$
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

$$ LANGUAGE plpgsql;