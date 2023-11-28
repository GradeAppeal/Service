DROP FUNCTION IF EXISTS PUBLIC .update_appeal_grader(aid bigint, gid text, gname text);

CREATE
OR replace FUNCTION PUBLIC .update_appeal_grader(aid bigint, gid text, gname text) returns uuid AS $$ BEGIN
    UPDATE
        PUBLIC."Appeals"
    SET
        grader_id = gid :: UUID,
        grader_name = gname
    WHERE
        id = aid;

RETURN gid;

END;

$$ LANGUAGE plpgsql;