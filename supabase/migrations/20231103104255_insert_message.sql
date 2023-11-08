DROP FUNCTION IF EXISTS PUBLIC .insert_messages(
    appid bigint,
    sender_id text,
    recipient_id text,
    created_at TIMESTAMP WITH TIME ZONE,
    message_text text,
    from_grader BOOLEAN
);

CREATE
OR replace FUNCTION PUBLIC .insert_message(
    appid bigint,
    sender_id text,
    recipient_id text,
    created_at TIMESTAMP WITH TIME ZONE,
    message_text text,
    from_grader BOOLEAN
) returns VOID AS $$
DECLARE
    BEGIN
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
                sender_id :: UUID,
                recipient_id :: UUID,
                appid,
                message_text,
                from_grader
            );

-- EXCEPTION
--     WHEN OTHERS THEN RAISE 'insert failed for sender % and recipient %.',
--     sender_id,
--     recipient_id;
END;

$$ LANGUAGE plpgsql;