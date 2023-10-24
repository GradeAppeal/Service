-- get Students
CREATE
OR replace FUNCTION PUBLIC .get_students (cid bigint) returns TABLE(
    student_id uuid,
    student_first_name text,
    student_last_name text,
    student_email text,
    is_grader BOOLEAN
) AS $$ BEGIN
    RETURN query
    SELECT
        s.id AS student_id,
        s.first_name AS student_first_name,
        s.last_name AS student_last_name,
        s.email AS student_email,
        sc.is_grader AS is_grader
    FROM
        "Students" AS s
        INNER JOIN "StudentCourse" AS sc ON s.id = sc.student_id
        INNER JOIN "Courses" AS C ON sc.course_id = C .id
    WHERE
        C .id = cid;

END;

$$ LANGUAGE plpgsql;