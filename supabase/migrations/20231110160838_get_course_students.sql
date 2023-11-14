CREATE
OR replace FUNCTION get_course_students(cid bigint) returns setof student_course_grader_info AS $$ BEGIN
    RETURN query
    SELECT
        *
    FROM
        student_course_grader_info
    WHERE
        course_id = cid;

END;

$$ LANGUAGE plpgsql;