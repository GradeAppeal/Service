CREATE
OR REPLACE FUNCTION PUBLIC .on_profile_verified() RETURNS TRIGGER AS $$ BEGIN
    IF NEW .role = 'student' THEN
    UPDATE
        PUBLIC."Students" AS s
    SET
        is_verified = NEW .is_verified
    WHERE
        NEW .id = s.id;

ELSIF NEW .role = 'professor' THEN
UPDATE
    PUBLIC."Professors" AS p
SET
    is_verified = NEW .is_verified
WHERE
    NEW .id = p.id;

END IF;

RETURN NEW;

END;

$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER tr_on_profile_verified AFTER
UPDATE
    OF is_verified ON PUBLIC."Profiles" FOR each ROW
    WHEN (
        OLD .is_verified = FALSE
        AND NEW .is_verified IS TRUE
    ) EXECUTE PROCEDURE PUBLIC .on_profile_verified ();