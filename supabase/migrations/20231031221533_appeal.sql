CREATE
OR replace FUNCTION PUBLIC .insert_appeal_1(
    aid bigint,
    sid uuid,
    cid bigint,
    created_at TIMESTAMP WITH TIME ZONE,
    appeal_text text
) RETURNS VOID AS $$
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

END;

$$ LANGUAGE plpgsql;