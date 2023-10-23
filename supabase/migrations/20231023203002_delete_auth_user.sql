CREATE
OR REPLACE FUNCTION PUBLIC .delete_user() RETURNS TRIGGER AS $$ BEGIN
    DELETE FROM
        PUBLIC."Users" AS u
    WHERE
        u.id = OLD .id;

RETURN OLD;

END;

$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER tr_on_auth_user_deleted AFTER
DELETE
    ON auth.users FOR each ROW EXECUTE PROCEDURE PUBLIC .delete_user ();