DROP FUNCTION IF EXISTS PUBLIC .update_appeal_grader (gid text);

CREATE
OR replace FUNCTION PUBLIC .update_appeal_grader (aid bigint, gid text) returns text AS $$ BEGIN
    UPDATE
        PUBLIC."Appeals"
    SET
        grader_id = gid :: UUID
    WHERE
        id = aid;

RETURN gid;

END;

$$ LANGUAGE plpgsql;