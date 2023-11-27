DROP FUNCTION IF EXISTS PUBLIC .update_appeal_open_status (aid bigint);

CREATE
OR replace FUNCTION PUBLIC .update_appeal_open_status (aid bigint) returns bigint AS $$ BEGIN
    UPDATE
        PUBLIC."Appeals"
    SET
        is_open = NOT is_open,
        last_modified = now()
    WHERE
        id = aid;

RETURN aid;

END;

$$ LANGUAGE plpgsql;