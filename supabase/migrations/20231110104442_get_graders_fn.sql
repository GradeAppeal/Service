DROP FUNCTION IF EXISTS PUBLIC.get_graders(cid);

CREATE
OR replace FUNCTION PUBLIC .get_graders(cid bigint) returns setof student_course_grader_info AS $$ BEGIN
    RETURN query
    SELECT
        *
    FROM
        student_course_grader_info
    WHERE
        course_id = cid
        AND is_grader IS TRUE;

END;

$$ LANGUAGE plpgsql;