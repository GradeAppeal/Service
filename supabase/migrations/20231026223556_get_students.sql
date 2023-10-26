DROP FUNCTION IF EXISTS PUBLIC .get_students(cid bigint);

CREATE
OR replace FUNCTION PUBLIC .get_students (cid bigint) returns TABLE(
    id uuid,
    first_name text,
    last_name text,
    email text,
    is_grader BOOLEAN
) AS $$ BEGIN
    RETURN query
    SELECT
        s.id AS id,
        s.first_name AS first_name,
        s.last_name AS last_name,
        s.email AS email,
        sc.is_grader AS is_grader
    FROM
        "Students" AS s
        INNER JOIN "StudentCourse" AS sc ON s.id = sc.student_id
        INNER JOIN "Courses" AS C ON sc.course_id = C .id
    WHERE
        C .id = cid;

END;

$$ LANGUAGE plpgsql;