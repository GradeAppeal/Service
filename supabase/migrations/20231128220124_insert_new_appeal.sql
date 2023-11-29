DROP FUNCTION IF EXISTS PUBLIC .insert_appeal(
    aid bigint,
    sid text,
    cid bigint,
    created_at TIMESTAMP WITH TIME ZONE,
    appeal_text text
);

CREATE
OR replace FUNCTION PUBLIC .insert_appeal(
    aid bigint,
    sid text,
    cid bigint,
    created_at TIMESTAMP WITH TIME ZONE,
    appeal_text text,
    pid text
) returns bigint AS $$
DECLARE
    new_appeal_id bigint;

professor_id uuid;

BEGIN
    -- insert into Appeals table
    INSERT INTO
        PUBLIC."Appeals" (
            assignment_id,
            created_at,
            appeal_text,
            is_open,
            grader_id,
            professor_id
        )
    VALUES
        (
            aid,
            created_at,
            appeal_text,
            TRUE,
            NULL,
            pid :: UUID
        ) RETURNING id INTO new_appeal_id;

INSERT INTO
    PUBLIC."StudentAppeal" (student_id, appeal_id)
VALUES
    (sid :: uuid, new_appeal_id);

SELECT
    p.id INTO professor_id
FROM
    PUBLIC."Professors" AS p
    INNER JOIN PUBLIC."ProfessorCourse" AS pc ON p.id = pc.professor_id
    INNER JOIN PUBLIC."Courses" AS C ON pc.course_id = C .id
WHERE
    C .id = cid;

INSERT INTO
    PUBLIC."Messages" (
        created_at,
        sender_id,
        recipient_id,
        appeal_id,
        message_text,
        from_grader
    )
VALUES
    (
        created_at,
        sid :: uuid,
        professor_id,
        new_appeal_id,
        appeal_text,
        FALSE
    );

RETURN new_appeal_id;

END;

$$ LANGUAGE plpgsql;