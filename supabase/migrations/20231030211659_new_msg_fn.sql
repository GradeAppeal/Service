DROP FUNCTION IF EXISTS PUBLIC .get_messages (aid bigint);

CREATE
OR replace FUNCTION PUBLIC .get_messages (aid bigint) returns setof "Messages" AS $$
DECLARE
    BEGIN
        RETURN query
        SELECT
            *
        FROM
            PUBLIC."Messages" AS m
        WHERE
            m.appeal_id = aid;

END;

$$ LANGUAGE plpgsql;