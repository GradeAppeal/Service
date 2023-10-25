-- CHECK IF student account EXISTS 
CREATE
OR replace FUNCTION PUBLIC .is_user(student_email text) RETURNS BOOLEAN AS $$
DECLARE
    user_exists BOOLEAN;

BEGIN
    SELECT
        EXISTS(
            SELECT
                1
            FROM
                PUBLIC."Users"
            WHERE
                email = student_email;

) INTO user_exists;

RETURN user_exists;

END;

$$ LANGUAGE plpgsql;

-- INSERT
--     student TO course CREATE
--     OR replace FUNCTION PUBLIC .insert_student_to_course(student_email text, cid bigint) RETURNS bigint AS $$
-- DECLARE
--     student_id uuid;
-- BEGIN
--     SELECT
--         id
--     FROM
--         PUBLIC."Students"
--     WHERE
--         email = student_email INTO student_id;
-- INSERT INTO
--     PUBLIC."StudentCourse" (student_id, course_id, is_grader)
-- VALUES
--     (student_id, cid, FALSE);
-- RETURN 1;
-- EXCEPTION
--     WHEN OTHERS RETURN 0;
-- END;
-- $$ LANGUAGE plpgsql;