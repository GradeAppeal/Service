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
            );

RETURN 1;

EXCEPTION
    WHEN OTHERS THEN RETURN 0;

END;

$$ LANGUAGE plpgsql;