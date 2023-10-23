CREATE OR REPLACE FUNCTION public.assign_role() RETURNS TRIGGER AS $$ 
DECLARE role text;
first_name text;
last_name text;

BEGIN -- get first name
SELECT
    new.raw_user_meta_data ->> 'first_name' INTO first_name;

-- get last name
SELECT
    new.raw_user_meta_data ->> 'last_name' INTO last_name;

IF new.email NOT LIKE '%@calvin.edu' THEN RAISE EXCEPTION 'Please use a valid @calvin.edu email';

END IF;

IF new.email = 'al87@calvin.edu'
OR new.email = 'thv4@calvin.edu' THEN role := 'admin';

ELSIF new.email ~ '^[a-z]+\.[a-z]+@calvin.edu' THEN role := 'professor';

ELSIF new.email ~ '^[a-z]+[0-9]+@calvin.edu' THEN role := 'student';

ELSE RAISE EXCEPTION 'Please use a valid @calvin.edu email';

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
        new.id,
        role,
        first_name,
        last_name,
        new.email
    );

RETURN new;

END;

$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE trigger tr_on_auth_user_created
AFTER
INSERT
    ON auth.users FOR each ROW EXECUTE PROCEDURE public.assign_role ();