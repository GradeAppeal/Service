-- insert new appeal
CREATE
OR REPLACE FUNCTION PUBLIC .insert_new_appeal(
    aid bigint,
    sid uuid,
    cid bigint,
    created_at TIMESTAMP WITH TIME ZONE,
    appeal_text text,
    student_grade bigint
) RETURNS bigint AS $$
DECLARE
    new_appeal_id bigint;

BEGIN
    -- insert into Appeals table
    INSERT INTO
        PUBLIC."Appeals" (
            assignment_id,
            created_at,
            appeal_text,
            is_open,
            grade
        )
    VALUES
        (
            aid,
            created_at,
            appeal_text,
            TRUE,
            student_grade
        ) RETURNING id INTO new_appeal_id;

-- insert into join table
INSERT INTO
    PUBLIC."StudentAppeal" (student_id, appeal_id)
VALUES
    (sid, new_appeal_id);

RETURN 1;

EXCEPTION
    WHEN OTHERS THEN RETURN 0;

END;

$$ LANGUAGE plpgsql;

CREATE
OR REPLACE FUNCTION PUBLIC .on_new_appeal() RETURNS TRIGGER AS $$
DECLARE
    student_id uuid;

professor_id uuid;

BEGIN
    -- get sender (i.e. Student) id
    SELECT
        sa.student_id
    FROM
        PUBLIC."StudentAppeal" AS sa
    WHERE
        sa .id = NEW .id INTO student_id;

-- get recipient (i.e. Professor) id
SELECT
    p.id
FROM
    "Courses" AS C
    INNER JOIN "ProfessorCourse" AS pc ON C .id = pc.course_id
    INNER JOIN "Professors" AS p ON pc.professor_id = p.id
WHERE
    C .id = cid INTO professor_id;

-- insert into messages
INSERT INTO
    "Messages" (
        sender_id,
        recipient_id,
        appeal_id,
        created_at,
        message_text,
        from_grader
    )
VALUES
    (
        student_id,
        professor_id,
        NEW .id,
        NEW .created_at,
        NEW .appeal_text,
        FALSE
    );

RETURN NEW;

END;

$$ LANGUAGE plpgsql SECURITY DEFINER;

-- trigger after filling join table
CREATE TRIGGER tr_on_new_appeal AFTER
INSERT
    ON PUBLIC."StudentAppeal" FOR each ROW EXECUTE PROCEDURE PUBLIC .on_new_appeal ();