CREATE
OR replace FUNCTION PUBLIC .get_user_info(UID text) returns setof PUBLIC."Users" AS $$ BEGIN
    RETURN query
    SELECT
        *
    FROM
        PUBLIC."Users"
    WHERE
        id = UID :: UUID;

EXCEPTION
    WHEN OTHERS THEN RAISE 'select user information failed for user with uid: %',
    UID;

END;

$$ LANGUAGE plpgsql;