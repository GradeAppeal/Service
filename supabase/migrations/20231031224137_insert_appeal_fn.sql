CREATE
OR replace FUNCTION PUBLIC .insert_appeal_2(
    aid bigint,
    sid text,
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
            created_at,
            assignment_id,
            appeal_text,
            is_open,
            grader_id
        )
    VALUES
        (
            created_at,
            aid,
            appeal_text,
            TRUE,
            NULL
        ) RETURNING id INTO new_appeal_id;

-- insert into join table
INSERT INTO
    PUBLIC."StudentAppeal" (student_id, appeal_id)
VALUES
    (sid :: UUID, new_appeal_id);

END;

$$ LANGUAGE plpgsql;