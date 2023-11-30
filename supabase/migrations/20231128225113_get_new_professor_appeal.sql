DROP FUNCTION IF EXISTS PUBLIC .get_new_professor_appeal(aid bigint);

-- get appeals from Professors' point of view
CREATE
OR REPLACE FUNCTION PUBLIC .get_new_professor_appeal(aid bigint) RETURNS TABLE(
    course_id bigint,
    course_prefix text,
    course_code bigint,
    course_name text,
    course_section text,
    course_semester text,
    course_year bigint,
    student_id uuid,
    student_first_name text,
    student_last_name text,
    assignment_id bigint,
    assignment_name text,
    appeal_id bigint,
    created_at TIMESTAMP WITH TIME ZONE,
    appeal_text text,
    is_open BOOLEAN,
    grader_id UUID,
    grader_name text
) AS $$ BEGIN
    RETURN QUERY
    SELECT
        C .id AS course_id,
        C .prefix AS course_prefix,
        C .code AS course_code,
        C .name AS course_name,
        C .section AS course_section,
        C .semester AS course_semester,
        C .year AS course_year,
        s.id AS student_id,
        s.first_name AS student_first_name,
        s.last_name AS student_last_name,
        A .id AS assignment_id,
        A .assignment_name AS assignment_name,
        app.id AS appeal_id,
        app.created_at AS created_at,
        app.appeal_text AS appeal_text,
        app.is_open AS is_open,
        app.grader_id AS grader_id,
        app.grader_name AS grader_name
    FROM
        "Professors" AS p
        INNER JOIN "ProfessorCourse" AS pc ON p.id = pc.professor_id
        INNER JOIN "Courses" AS C ON pc.course_id = C .id
        INNER JOIN "Assignments" AS A ON C .id = A .course_id
        INNER JOIN "Appeals" AS app ON A .id = app.assignment_id
        INNER JOIN "StudentAppeal" AS sa ON app.id = sa.appeal_id
        INNER JOIN "Students" AS s ON sa.student_id = s.id
    WHERE
        app.id = aid
    ORDER BY
        app.created_at DESC;

END;

$$ LANGUAGE plpgsql;