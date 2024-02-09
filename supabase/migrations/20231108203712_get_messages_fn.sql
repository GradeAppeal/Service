DROP FUNCTION IF EXISTS PUBLIC .get_all_messages (aid bigint);

DROP FUNCTION IF EXISTS PUBLIC .get_student_messages (aid bigint, sid text, pid text);

CREATE
OR replace FUNCTION PUBLIC .get_student_messages (aid bigint, sid text, pid text) returns setof PUBLIC."Messages" AS $$ BEGIN
    RETURN query
    SELECT
        m.id AS message_id,
        m.created_at AS created_at,
        m.sender_id AS sender_id,
        m.recipient_id AS recipient_id,
        m.appeal_id AS appeal_id,
        m.message_text AS message_text,
        m.from_grader AS from_grader,
        m.sender_name AS sender_name,
        m.recipient_name AS recipient_name,
        m.is_read AS is_read
    FROM
        PUBLIC."Messages" AS m
    WHERE
        m.appeal_id = aid
        AND (
            (
                m.sender_id = sid :: uuid
                AND m.recipient_id = pid :: uuid
            )
            OR (
                m.sender_id = pid :: uuid
                AND m.recipient_id = sid :: uuid
            )
        )
    ORDER BY
        m.created_at;

END;

$$ LANGUAGE plpgsql;

CREATE
OR replace FUNCTION PUBLIC .get_all_messages (aid bigint) returns setof PUBLIC."Messages" AS $$ BEGIN
    RETURN query
    SELECT
        m.id AS message_id,
        m.created_at AS created_at,
        m.sender_id AS sender_id,
        m.recipient_id AS recipient_id,
        m.appeal_id AS appeal_id,
        m.message_text AS message_text,
        m.from_grader AS from_grader,
        m.sender_name AS sender_name,
        m.recipient_name AS recipient_name,
        m.is_read AS is_read
    FROM
        PUBLIC."Messages" AS m
    WHERE
        m.appeal_id = aid
    ORDER BY
        m.created_at;

END;

$$ LANGUAGE plpgsql;