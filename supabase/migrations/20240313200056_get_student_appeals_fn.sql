DROP FUNCTION IF EXISTS PUBLIC .get_student_appeals(sid uuid);

CREATE
OR replace FUNCTION PUBLIC .get_student_appeals(sid uuid) returns TABLE(
    course_prefix text,
    course_code bigint,
    course_name text,
    course_section text,
    course_semester text,
    course_year bigint,
    professor_id uuid,
    professor_first_name text,
    professor_last_name text,
    assignment_id bigint,
    assignment_name text,
    appeal_id bigint,
    created_at TIMESTAMP WITH TIME ZONE,
    is_read BOOLEAN,
    is_open BOOLEAN
) AS $$ BEGIN
    RETURN query
    SELECT
        C .prefix AS course_prefix,
        C .code AS course_code,
        C .name AS course_name,
        C .section AS course_section,
        C .semester AS course_semester,
        C .year AS course_year,
        p.id AS professor_id,
        p.first_name AS professor_first_name,
        p.last_name AS professor_last_name,
        A .id AS assignment_id,
        A .assignment_name AS assignment_name,
        app.id AS appeal_id,
        app.created_at AS created_at,
        msg.is_read AS is_read,
        app .is_open AS is_open
    FROM
        "Students" AS s
        INNER JOIN "StudentAppeal" AS sa ON s.id = sa.student_id
        INNER JOIN "Appeals" AS app ON sa.appeal_id = app.id
        INNER JOIN "Assignments" AS A ON app.assignment_id = A .id
        INNER JOIN "Courses" AS C ON A .course_id = C .id
        INNER JOIN "ProfessorCourse" AS pc ON C .id = pc.course_id
        INNER JOIN "Professors" AS p ON pc.professor_id = p.id
        LEFT JOIN (
            SELECT
                m.appeal_id,
                m.is_read
            FROM
                PUBLIC."Messages" AS m
                INNER JOIN (
                    SELECT
                        m.appeal_id,
                        MAX(m.created_at) AS max_created_at
                    FROM
                        PUBLIC."Messages" AS m
                    GROUP BY
                        m.appeal_id
                ) AS latest_msg ON m.appeal_id = latest_msg.appeal_id
                AND m.created_at = latest_msg.max_created_at
        ) AS msg ON app.id = msg.appeal_id
    WHERE
        s.id = sid
    ORDER BY
        app.created_at DESC;

END;

$$ LANGUAGE plpgsql;