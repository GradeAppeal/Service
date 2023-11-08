CREATE
OR replace FUNCTION get_grader_appeals(gid text, cid bigint) returns TABLE(
    professor_id uuid,
    professor_first_name text,
    professor_last_name text,
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
    is_open BOOLEAN
) AS $$ BEGIN
    RETURN query
    SELECT
        ci.professor_id AS professor_id,
        ci.professor_first_name AS professor_first_name,
        ci.professor_last_name AS professor_last_name,
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
        appeals.is_open AS is_open
    FROM
        PUBLIC."Students" AS s
        INNER JOIN PUBLIC."StudentCourse" AS sc ON s.id = sc.student_id
        INNER JOIN course_info AS ci ON sc.course_id = ci.course_id
        INNER JOIN PUBLIC."Assignments" AS assignments ON ci.course_id = assignments.course_id
        INNER JOIN PUBLIC."Appeals" AS appeals ON assignments.id = appeals.assignment_id
    WHERE
        sc.is_grader IS TRUE
        AND s.id = gid :: UUID
        AND appeals.is_open IS TRUE
        AND ci.course_id = cid
        AND appeals.grader_id = gid :: UUID;

-- todo: fetch on grader assign status
EXCEPTION
    WHEN OTHERS THEN RAISE 'select failed for graderID %, courseID %',
    gid,
    cid;

END;

$$ LANGUAGE plpgsql;

CREATE
OR replace FUNCTION get_all_grader_appeals(gid text) returns TABLE(
    professor_id uuid,
    professor_first_name text,
    professor_last_name text,
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
    is_open BOOLEAN
) AS $$ BEGIN
    RETURN query
    SELECT
        ci.professor_id AS professor_id,
        ci.professor_first_name AS professor_first_name,
        ci.professor_last_name AS professor_last_name,
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
        appeals.is_open AS is_open
    FROM
        PUBLIC."Students" AS s
        INNER JOIN PUBLIC."StudentCourse" AS sc ON s.id = sc.student_id
        INNER JOIN course_info AS ci ON sc.course_id = ci.course_id
        INNER JOIN PUBLIC."Assignments" AS assignments ON ci.course_id = assignments.course_id
        INNER JOIN PUBLIC."Appeals" AS appeals ON assignments.id = appeals.assignment_id
    WHERE
        sc.is_grader IS TRUE
        AND s.id = gid :: UUID
        AND appeals.is_open IS TRUE;

-- todo: fetch on grader assign status
EXCEPTION
    WHEN OTHERS THEN RAISE 'select failed for graderID %',
    gid;

END;

$$ LANGUAGE plpgsql;