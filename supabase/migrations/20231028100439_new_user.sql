CREATE
OR REPLACE FUNCTION PUBLIC .assign_role() RETURNS TRIGGER AS $$
DECLARE
    role text;

first_name text;

last_name text;

BEGIN
    -- get first name
    SELECT
        NEW .raw_user_meta_data ->> 'first_name' INTO first_name;

-- get last name
SELECT
    NEW .raw_user_meta_data ->> 'last_name' INTO last_name;

IF NEW .email NOT LIKE '%@calvin.edu' THEN RAISE
EXCEPTION
    'Please use a valid @calvin.edu email';

END IF;

IF NEW .email ~ '^[a-z]+\.[a-z]+@calvin.edu' THEN role := 'professor';

ELSIF NEW .email ~ '^[a-z]+[0-9]+@calvin.edu' THEN role := 'student';

ELSE RAISE
EXCEPTION
    'Please use a valid @calvin.edu email';

END IF;

INSERT INTO
    "public"."Users" (
        id,
        role,
        first_name,
        last_name,
        email
    )
VALUES
    (
        NEW .id,
        role,
        first_name,
        last_name,
        NEW .email
    );

RETURN NEW;

END;

$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE
OR replace TRIGGER tr_on_auth_user_created AFTER
INSERT
    ON auth.users FOR each ROW EXECUTE PROCEDURE PUBLIC .assign_role ();