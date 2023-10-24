-- get assignments
CREATE
OR REPLACE FUNCTION PUBLIC .get_assignments(cid bigint) RETURNS SETOF PUBLIC."Assignments" AS $$ BEGIN
    RETURN QUERY
    SELECT
        *
    FROM
        "Assignments"
    WHERE
        course_id = cid;

END;

$$ LANGUAGE plpgsql;

-- get list of courses
CREATE
OR REPLACE FUNCTION PUBLIC .get_course(cid bigint) RETURNS SETOF PUBLIC."Courses" AS $$ BEGIN
    RETURN query
    SELECT
        *
    FROM
        "Courses"
    WHERE
        id = cid;

END;

$$ LANGUAGE plpgsql;

-- get all messages
CREATE
OR REPLACE FUNCTION PUBLIC .get_messages(aid bigint) RETURNS SETOF PUBLIC."Messages" AS $$ BEGIN
    RETURN query
    SELECT
        *
    FROM
        "Messages" AS m
    WHERE
        m.appeal_id = aid
    ORDER BY
        created_at;

END;

$$ LANGUAGE plpgsql;

-- get appeals from Professors' point of view
CREATE
OR REPLACE FUNCTION PUBLIC .get_professor_appeals(pid uuid) RETURNS TABLE (
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
    created_at timestamptz,
    appeal_text text,
    appeal_grade bigint,
    is_open BOOLEAN
) AS $$ BEGIN
    RETURN QUERY
    SELECT
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
        app.grade AS appeal_grade,
        app.is_open AS is_open
    FROM
        "Professors" AS p
        INNER JOIN "ProfessorCourse" AS pc ON p.id = pc.professor_id
        INNER JOIN "Courses" AS C ON pc.course_id = C .id
        INNER JOIN "Assignments" AS A ON C .id = A .course_id
        INNER JOIN "Appeals" AS app ON A .id = app.assignment_id
        INNER JOIN "StudentAppeal" AS sa ON app.id = sa.appeal_id
        INNER JOIN "Students" AS s ON sa.student_id = s.id
    WHERE
        p.id = pid
    ORDER BY
        app.created_at DESC;

END;

$$ LANGUAGE plpgsql;

-- Get courses for Professors
CREATE
OR replace FUNCTION PUBLIC .get_professor_courses(pid uuid) returns SETOF PUBLIC."Courses" AS $$ BEGIN
    RETURN query
    SELECT
        C .id,
        C .prefix,
        C .code,
        C .name,
        C .section,
        C .semester,
        C .year
    FROM
        "Courses" AS C
        INNER JOIN "ProfessorCourse" AS pc ON C .id = pc.course_id
        INNER JOIN "Professors" AS p ON pc.professor_id = p.id
    WHERE
        p.id = pid;

END;

$$ LANGUAGE plpgsql;

-- Get appeal response templates
CREATE
OR replace FUNCTION PUBLIC .get_professor_templates(pid uuid) returns SETOF PUBLIC."Templates" AS $$ BEGIN
    RETURN query
    SELECT
        *
    FROM
        "Templates" AS t
    WHERE
        t.professor_id = pid;

END;

$$ LANGUAGE plpgsql;

-- Get appeals for Stduent view
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
    appeal_grade bigint,
    created_at TIMESTAMP WITH TIME ZONE,
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
        app.grade AS appeal_grade,
        app.created_at AS created_at,
        app.is_open AS is_open
    FROM
        "Students" AS s
        INNER JOIN "StudentAppeal" AS sa ON s.id = sa.student_id
        INNER JOIN "Appeals" AS app ON sa.appeal_id = app.id
        INNER JOIN "Assignments" AS A ON app.assignment_id = A .id
        INNER JOIN "Courses" AS C ON A .course_id = C .id
        INNER JOIN "ProfessorCourse" AS pc ON C .id = pc.course_id
        INNER JOIN "Professors" AS p ON pc.professor_id = p.id
    WHERE
        s.id = sid
    ORDER BY
        app.created_at DESC;

END;

$$ LANGUAGE plpgsql;

-- Get Students' courses
CREATE
OR replace FUNCTION PUBLIC .get_student_courses (sid uuid) returns TABLE(
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
        s.id = sid;

END;

$$ LANGUAGE plpgsql;

-- -- get Students
-- CREATE
-- OR replace FUNCTION PUBLIC .get_students (cid bigint) returns TABLE(
--     student_id uuid,
--     student_first_name text,
--     student_last_name text,
--     student_email text,
--     is_grader BOOLEAN
-- ) AS $$ BEGIN
--     RETURN query
--     SELECT
--         s.id AS student_id,
--         s.first_name AS student_first_name,
--         s.last_name AS student_last_name,
--         s.email AS student_email,
--         sc.is_grader AS is_grader
--     FROM
--         "Students" AS s
--         INNER JOIN "StudentCourse" AS sc ON s.id = sc.student_id
--         INNER JOIN "Courses" AS C ON sc.course_id = C .id
--     WHERE
--         C .id = cid;
-- END;
-- $$ LANGUAGE plpgsql;