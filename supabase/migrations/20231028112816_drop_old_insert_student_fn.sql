DROP FUNCTION IF EXISTS PUBLIC .get_messages (aid bigint);

CREATE
OR replace FUNCTION PUBLIC .get_messages (aid bigint) returns TABLE (
    id bigint,
    created_at timestamptz,
    sender_id UUID,
    recipient_id UUID,
    appeal_id bigint,
    message_text text,
    from_grader BOOLEAN,
    sender_name text,
    recipient_name text
) AS $$
DECLARE
    message_sender_id UUID;

sender_name text;

message_recipient_id UUID;

recipient_name text;

BEGIN
    SELECT
        m.sender_id
    FROM
        PUBLIC."Messages" AS m
    WHERE
        m.appeal_id = aid
    LIMIT
        1 INTO message_sender_id;

RAISE
EXCEPTION
    WHEN OTHERS
SELECT
    m.recipient_id
FROM
    PUBLIC."Messages" AS m
WHERE
    m.appeal_id = aid
LIMIT
    1 INTO message_recipient_id;

SELECT
    first_name || ' ' || last_name
FROM
    PUBLIC."Users"
WHERE
    id = message_sender_id INTO sender_name;

SELECT
    first_name || ' ' || last_name
FROM
    PUBLIC."Users"
WHERE
    id = message_recipient_id INTO recipient_name;

RETURN query
SELECT
    m.id AS id,
    m.created_at AS created_at,
    m.sender_id AS sender_id,
    m.recipient_id AS recipient_id,
    m.appeal_id AS appeal_id,
    m.message_text AS message_text,
    m.from_grader AS from_grader,
    sender_name,
    recipient_name
FROM
    PUBLIC."Messages" AS m
WHERE
    m.appeal_id = aid;

END;

$$ LANGUAGE plpgsql;