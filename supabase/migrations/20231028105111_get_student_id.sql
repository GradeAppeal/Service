CREATE
OR replace FUNCTION get_student_id(student_email text) RETURNS text AS $$
DECLARE
    student_id uuid;

BEGIN
    SELECT
        id
    FROM
        PUBLIC."Students"
    WHERE
        email = student_email INTO student_id;

RETURN student_id;

END;

$$ LANGUAGE plpgsql;