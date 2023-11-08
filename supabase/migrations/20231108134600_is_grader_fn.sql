CREATE
OR replace FUNCTION PUBLIC .is_grader(sid text) returns BOOLEAN AS $$
DECLARE
    grader_status BOOLEAN;

BEGIN
    SELECT
        INTO grader_status EXISTS (
            SELECT
                1
            FROM
                "StudentCourse"
            WHERE
                student_id = sid :: UUID
                AND is_grader IS TRUE
        );

RETURN grader_status;

END;

$$ LANGUAGE plpgsql;