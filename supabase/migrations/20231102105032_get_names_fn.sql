CREATE
OR replace FUNCTION PUBLIC .get_user_name(userId UUID) returns text AS $$
DECLARE
    username text;

BEGIN
    SELECT
        first_name || ' ' || last_name INTO username
    FROM
        PUBLIC."Users" AS u
    WHERE
        u.id = userId;

RETURN username;

END;

$$ LANGUAGE plpgsql;