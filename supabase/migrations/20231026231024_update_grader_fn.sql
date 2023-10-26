CREATE
OR replace FUNCTION update_grader(sid uuid, cid bigint) returns setof PUBLIC."StudentCourse" AS $$
DECLARE
    grader_status BOOLEAN;

BEGIN
    UPDATE
        PUBLIC."StudentCourse"
    SET
        is_grader = NOT is_grader
    WHERE
        student_id = sid
        AND course_id = cid;

RETURN query
SELECT
    *
FROM
    PUBLIC."StudentCourse"
WHERE
    student_id = sid
    AND course_Id = cid;

END;

$$ LANGUAGE plpgsql;