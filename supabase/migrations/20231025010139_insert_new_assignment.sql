CREATE
OR replace FUNCTION PUBLIC .insert_new_assignment(cid bigint, assignment_name text) RETURNS bigint AS $$
DECLARE
    BEGIN
        INSERT INTO
            PUBLIC."Assignments" (course_id, assignment_name)
        VALUES
            (cid, assignment_name);

RETURN 1;

EXCEPTION
    WHEN OTHERS THEN RETURN 0;

END;

$$ LANGUAGE plpgsql;