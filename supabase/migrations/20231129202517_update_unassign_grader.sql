DROP FUNCTION IF EXISTS PUBLIC .update_unassign_appeal_grader(aid bigint);

CREATE
OR replace FUNCTION PUBLIC .update_unassign_appeal_grader(aid bigint) returns VOID AS $$ BEGIN
    UPDATE
        PUBLIC."Appeals"
    SET
        grader_id = NULL,
        grader_name = NULL
    WHERE
        id = aid;

END;

$$ LANGUAGE plpgsql;