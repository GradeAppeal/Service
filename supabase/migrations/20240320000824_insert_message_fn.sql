DROP FUNCTION IF EXISTS PUBLIC .insert_message(
    appid bigint,
    sender_id text,
    recipient_id text,
    created_at TIMESTAMP WITH TIME ZONE,
    message_text text,
    from_grader BOOLEAN,
    sender_name text,
    recipient_name text,
    has_image BOOLEAN
);

CREATE
OR replace FUNCTION PUBLIC .insert_message(
    appid bigint,
    sender_id text,
    recipient_id text,
    created_at TIMESTAMP WITH TIME ZONE,
    message_text text,
    from_grader BOOLEAN,
    sender_name text,
    recipient_name text,
    has_image BOOLEAN
) returns bigint AS $$
DECLARE
    new_message_id bigint;

BEGIN
    INSERT INTO
        PUBLIC."Messages" (
            created_at,
            sender_id,
            recipient_id,
            appeal_id,
            message_text,
            from_grader,
            sender_name,
            recipient_name,
            has_image
        )
    VALUES
        (
            created_at,
            sender_id :: UUID,
            recipient_id :: UUID,
            appid,
            message_text,
            from_grader,
            sender_name,
            recipient_name,
            has_image
        ) RETURNING id INTO new_message_id;

RETURN new_message_id;

END;

$$ LANGUAGE plpgsql;