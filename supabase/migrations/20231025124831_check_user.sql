-- CHECK IF student account EXISTS 
CREATE
OR replace FUNCTION PUBLIC .is_student_user(student_email text) RETURNS BOOLEAN AS $$
DECLARE
    is_user BOOLEAN;

BEGIN
    SELECT
        EXISTS(
            SELECT
                1
            FROM
                PUBLIC."Users" AS u
            WHERE
                u.email = student_email
        ) INTO is_user;

RETURN is_user;

END;

$$ LANGUAGE plpgsql;