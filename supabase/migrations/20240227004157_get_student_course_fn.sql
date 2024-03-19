DROP FUNCTION IF EXISTS PUBLIC .get_student_course(sid text, cid bigint);

CREATE
OR replace FUNCTION PUBLIC .get_student_course(sid text, cid bigint) returns TABLE(
    course_id bigint,
    course_prefix text,
    course_code bigint,
    course_name text,
    course_section text,
    course_semester text,
    course_year bigint,
    professor_first_name text,
    professor_last_name text,
    is_grader BOOLEAN
) AS $$ BEGIN
    RETURN query
    SELECT
        C .id AS course_id,
        C .prefix AS course_prefix,
        C .code AS course_code,
        C .name AS course_name,
        C .section AS course_section,
        C .semester AS course_semester,
        C .year AS course_year,
        p.first_name AS professor_first_name,
        p.last_name AS professor_last_name,
        sc.is_grader
    FROM
        "Students" AS s
        INNER JOIN "StudentCourse" AS sc ON s.id = sc.student_id
        INNER JOIN "Courses" AS C ON sc.course_id = C .id
        INNER JOIN "ProfessorCourse" AS pc ON C .id = pc.course_id
        INNER JOIN "Professors" AS p ON pc.professor_id = p.id
    WHERE
        s.id = sid :: UUID
        AND C .id = cid
        AND sc.is_grader = FALSE;

END;

$$ LANGUAGE plpgsql;