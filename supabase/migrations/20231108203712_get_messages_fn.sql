DROP FUNCTION IF EXISTS PUBLIC .get_messages (aid bigint);

CREATE
OR replace FUNCTION PUBLIC .get_messages (aid bigint) returns TABLE (
    message_id bigint,
    created_at timestamptz,
    sender_id uuid,
    recipient_id uuid,
    appeal_id bigint,
    message_text text,
    from_grader BOOLEAN,
    sender_name text,
    recipient_name text
) AS $$
DECLARE
    message_sender_id uuid;

sender_name text;

message_recipient_id uuid;

recipient_name text;

BEGIN
    --     SELECT
    --         m.sender_id
    --     FROM
    --         PUBLIC."Messages" AS m
    --     WHERE
    --         m.appeal_id = aid INTO message_sender_id;
    -- SELECT
    --     m.recipient_id
    -- FROM
    --     PUBLIC."Messages" AS m
    -- WHERE
    --     m.appeal_id = aid INTO message_recipient_id;
    -- SELECT
    --     first_name || ' ' || last_name
    -- FROM
    --     PUBLIC."Users"
    -- WHERE
    --     id = message_sender_id INTO sender_name;
    -- SELECT
    --     first_name || ' ' || last_name
    -- FROM
    --     PUBLIC."Users"
    -- WHERE
    --     id = message_recipient_id INTO recipient_name;
    RETURN query
    SELECT
        m.id AS message_id,
        m.created_at AS created_at,
        m.sender_id AS sender_id,
        m.recipient_id AS recipient_id,
        m.appeal_id AS appeal_id,
        m.message_text AS message_text,
        m.from_grader AS from_grader,
        (
            SELECT
                u.first_name || ' ' || u.last_name
            FROM
                PUBLIC."Users" AS u
            WHERE
                u.id = m.sender_id
        ) AS sender_name,
        (
            SELECT
                u.first_name || ' ' || u.last_name
            FROM
                PUBLIC."Users" AS u
            WHERE
                u.id = m.recipient_id
        ) AS recipient_name
    FROM
        PUBLIC."Messages" AS m
    WHERE
        m.appeal_id = aid;

END;

$$ LANGUAGE plpgsql;