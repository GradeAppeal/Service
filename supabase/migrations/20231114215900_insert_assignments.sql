DROP FUNCTION IF EXISTS PUBLIC .insert_assignment(cid bigint, assignment_name text);

DROP FUNCTION IF EXISTS PUBLIC .insert_new_assignment(cid bigint, assignment_name text);

CREATE
OR replace FUNCTION PUBLIC .insert_assignment(cid bigint, assignment_name text) returns VOID AS $$ BEGIN
    INSERT INTO
        PUBLIC."Assignments" (course_id, assignment_name)
    VALUES
        (cid, assignment_name);

END;

$$ LANGUAGE plpgsql;