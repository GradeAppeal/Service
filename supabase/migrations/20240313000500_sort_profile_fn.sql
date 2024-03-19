CREATE
OR REPLACE FUNCTION PUBLIC .sort_profile() RETURNS TRIGGER AS $$ BEGIN
    IF NEW .role = 'student' THEN
    INSERT INTO
        PUBLIC."Students" (
            id,
            first_name,
            last_name,
            email,
            is_verified
        )
    VALUES
        (
            NEW .id,
            NEW .first_name,
            NEW .last_name,
            NEW .email,
            NEW .is_verified
        );

RETURN NEW;

ELSIF NEW .role = 'professor' THEN
INSERT INTO
    PUBLIC."Professors" (
        id,
        first_name,
        last_name,
        email,
        is_verified
    )
VALUES
    (
        NEW .id,
        NEW .first_name,
        NEW .last_name,
        NEW .email,
        NEW .is_verified
    );

RETURN NEW;

ELSE RAISE
EXCEPTION
    'Cannot recognize given type';

END IF;

END;

$$ LANGUAGE plpgsql;