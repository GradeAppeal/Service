CREATE
OR REPLACE FUNCTION PUBLIC .get_course_roster(cid bigint) RETURNS TABLE(
    id uuid,
    first_name text,
    last_name text,
    email text,
    course_id bigint,
    course_prefix text,
    course_code bigint,
    course_name text,
    course_section text,
    course_semester text,
    course_year bigint,
    is_grader BOOLEAN,
    is_verified BOOLEAN
) AS $$ BEGIN
    RETURN query
    SELECT
        s.id AS id,
        s.first_name AS first_name,
        s.last_name AS last_name,
        s.email AS email,
        C .id AS course_id,
        C .prefix AS course_prefix,
        C .code AS course_code,
        C .name AS course_name,
        C .section AS course_section,
        C .semester AS course_semester,
        C .year AS course_year,
        sc.is_grader AS is_grader,
        s.is_verified AS is_verified
    FROM
        "Students" AS s
        INNER JOIN "StudentCourse" AS sc ON s.id = sc.student_id
        INNER JOIN "Courses" AS C ON sc.course_id = C .id
    WHERE
        C .id = cid;

END;

$$ LANGUAGE plpgsql SECURITY DEFINER;