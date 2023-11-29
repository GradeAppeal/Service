DROP FUNCTION IF EXISTS PUBLIC .get_course_professor(cid bigint);

CREATE
OR replace FUNCTION PUBLIC .get_course_professor(cid bigint) returns uuid AS $$
DECLARE
    course_professor_id uuid;

BEGIN
    SELECT
        INTO course_professor_id professor_id
    FROM
        PUBLIC."ProfessorCourse" AS pc
    WHERE
        pc.course_id = cid;

RETURN course_professor_id;

END;

$$ LANGUAGE plpgsql;