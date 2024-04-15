DROP FUNCTION IF EXISTS PUBLIC .insert_assignment(cid bigint, assignment_name text);

CREATE
OR replace FUNCTION PUBLIC .insert_assignment(
    cid bigint,
    assignment_name text,
    gid text DEFAULT NULL,
    gname text DEFAULT NULL
) returns VOID AS $$ BEGIN
    INSERT INTO
        PUBLIC."Assignments" (
            course_id,
            assignment_name,
            grader_id,
            grader_name
        )
    VALUES
        (cid, assignment_name, gid :: UUID, gname);

END;

$$ LANGUAGE plpgsql;