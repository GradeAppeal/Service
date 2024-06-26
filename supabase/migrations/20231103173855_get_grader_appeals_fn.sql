DROP FUNCTION IF EXISTS PUBLIC .get_grader_appeals(gid text, cid bigint);

CREATE
OR replace FUNCTION get_grader_appeals(gid text, cid bigint) returns TABLE(
    professor_id uuid,
    professor_first_name text,
    professor_last_name text,
    course_id bigint,
    course_prefix text,
    course_code bigint,
    course_name text,
    course_section text,
    course_semester text,
    course_year bigint,
    assignment_id bigint,
    assignment_name text,
    appeal_id bigint,
    created_at timestamptz,
    is_open BOOLEAN,
    is_read BOOLEAN
) AS $$ BEGIN
    RETURN query
    SELECT
        ci.professor_id AS professor_id,
        ci.professor_first_name AS professor_first_name,
        ci.professor_last_name AS professor_last_name,
        ci.course_id AS course_id,
        ci.course_prefix AS course_prefix,
        ci.course_code AS course_code,
        ci.course_name AS course_name,
        ci.course_section AS course_section,
        ci.course_semester AS course_semester,
        ci.course_year AS course_year,
        assignments.id AS assignment_id,
        assignments.assignment_name AS assignment_name,
        appeals.id AS appeal_id,
        appeals.created_at AS created_at,
        appeals.is_open AS is_open,
        msg.is_read AS is_read
    FROM
        PUBLIC."Students" AS s
        INNER JOIN PUBLIC."StudentCourse" AS sc ON s.id = sc.student_id
        INNER JOIN course_info AS ci ON sc.course_id = ci.course_id
        INNER JOIN PUBLIC."Assignments" AS assignments ON ci.course_id = assignments.course_id
        INNER JOIN PUBLIC."Appeals" AS appeals ON assignments.id = appeals.assignment_id
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
        ) AS msg ON appeals.id = msg.appeal_id
    WHERE
        sc.is_grader IS TRUE
        AND s.id = gid :: UUID
        AND appeals.is_open IS TRUE
        AND ci.course_id = cid
        AND appeals.grader_id = gid :: UUID;

END;

$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS PUBLIC .get_all_grader_appeals(gid text);

CREATE
OR replace FUNCTION get_all_grader_appeals(gid text) returns TABLE(
    professor_id uuid,
    professor_first_name text,
    professor_last_name text,
    course_id bigint,
    course_prefix text,
    course_code bigint,
    course_name text,
    course_section text,
    course_semester text,
    course_year bigint,
    assignment_id bigint,
    assignment_name text,
    appeal_id bigint,
    created_at timestamptz,
    is_open BOOLEAN,
    is_read BOOLEAN
) AS $$ BEGIN
    RETURN query
    SELECT
        ci.professor_id AS professor_id,
        ci.professor_first_name AS professor_first_name,
        ci.professor_last_name AS professor_last_name,
        ci.course_id AS course_id,
        ci.course_prefix AS course_prefix,
        ci.course_code AS course_code,
        ci.course_name AS course_name,
        ci.course_section AS course_section,
        ci.course_semester AS course_semester,
        ci.course_year AS course_year,
        assignments.id AS assignment_id,
        assignments.assignment_name AS assignment_name,
        appeals.id AS appeal_id,
        appeals.created_at AS created_at,
        appeals.is_open AS is_open,
        msg.is_read AS is_read
    FROM
        PUBLIC."Students" AS s
        INNER JOIN PUBLIC."StudentCourse" AS sc ON s.id = sc.student_id
        INNER JOIN course_info AS ci ON sc.course_id = ci.course_id
        INNER JOIN PUBLIC."Assignments" AS assignments ON ci.course_id = assignments.course_id
        INNER JOIN PUBLIC."Appeals" AS appeals ON assignments.id = appeals.assignment_id
        LEFT JOIN (
            SELECT
                m.appeal_id,
                m.is_read,
                m.recipient_id AS recipient_id,
                m.sender_id AS sender_id
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
        ) AS msg ON appeals.id = msg.appeal_id
    WHERE
        sc.is_grader IS TRUE
        AND s.id = gid :: UUID
        AND appeals.is_open IS TRUE
        AND appeals.grader_id = gid :: UUID
        AND (
            msg.recipient_id = gid :: UUID
            OR msg.sender_id = gid :: UUID
        );

END;

$$ LANGUAGE plpgsql;