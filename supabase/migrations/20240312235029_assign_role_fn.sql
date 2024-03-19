CREATE
OR REPLACE FUNCTION PUBLIC .assign_role() RETURNS TRIGGER AS $$
DECLARE
    role text;

first_name text;

last_name text;

is_verified BOOLEAN;

BEGIN
    -- get first name
    SELECT
        NEW .raw_user_meta_data ->> 'first_name' INTO first_name;

-- get last name
SELECT
    NEW .raw_user_meta_data ->> 'last_name' INTO last_name;

-- get verification status
IF NEW .confirmed_at IS NULL THEN is_verified := FALSE;

ELSE is_verified := TRUE;

END IF;

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
    "public"."Profiles" (
        id,
        role,
        first_name,
        last_name,
        email,
        is_verified
    )
VALUES
    (
        NEW .id,
        role,
        first_name,
        last_name,
        NEW .email,
        is_verified
    );

RETURN NEW;

END;

$$ LANGUAGE plpgsql SECURITY DEFINER;