CREATE
OR REPLACE FUNCTION PUBLIC .on_auth_verified() RETURNS TRIGGER AS $$ BEGIN
    UPDATE
        PUBLIC."Profiles" AS p
    SET
        is_verified = CASE
            WHEN NEW .confirmed_at IS NOT NULL THEN TRUE
            ELSE FALSE
        END
    WHERE
        NEW .id = p.id;

RETURN NEW;

END;

$$ LANGUAGE plpgsql SECURITY DEFINER;

-- CREATE TRIGGER tr_on_auth_user_verified AFTER
-- UPDATE 
--     OF confirmed_at ON auth.users FOR each ROW
--     WHEN (
--         OLD .confirmed_at IS NULL
--         AND NEW .confirmed_at IS NOT NULL
--     ) EXECUTE PROCEDURE PUBLIC .on_auth_verified ();