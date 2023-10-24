CREATE
OR replace FUNCTION PUBLIC .get_role(auth_email text) RETURNS text AS $$
DECLARE
    user_role text;

BEGIN
    SELECT
        role
    FROM
        PUBLIC."Users"
    WHERE
        email = auth_email INTO user_role;

RETURN user_role;

END;

$$ LANGUAGE plpgsql;