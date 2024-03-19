DROP FUNCTION IF EXISTS PUBLIC .update_assignment_grader(aid bigint, gid text, gname text);

CREATE
OR replace FUNCTION PUBLIC .update_assignment_grader(aid bigint, gid text, gname text) returns VOID AS $$ BEGIN
    UPDATE
        PUBLIC."Assignments"
    SET
        grader_id = gid :: uuid,
        grader_name = gname
    WHERE
        id = aid;

END;

$$ LANGUAGE plpgsql;

-- DROP FUNCTION IF EXISTS PUBLIC .on_update_assignment_grader();
CREATE
OR replace FUNCTION PUBLIC .on_update_assignment_grader() returns TRIGGER AS $$ BEGIN
    UPDATE
        PUBLIC."Appeals"
    SET
        grader_id = NEW .grader_id,
        grader_name = NEW .grader_name
    WHERE
        assignment_id = NEW .id;

RETURN NEW;

END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_on_update_assignment_grader AFTER
UPDATE
    OF grader_id ON PUBLIC."Assignments" FOR each ROW EXECUTE PROCEDURE PUBLIC .on_update_assignment_grader();