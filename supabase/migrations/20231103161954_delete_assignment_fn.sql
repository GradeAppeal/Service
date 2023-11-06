CREATE
OR replace FUNCTION PUBLIC .delete_assignment(aid bigint) returns VOID AS $$ BEGIN
    DELETE FROM
        PUBLIC."Assignments"
    WHERE
        id = aid;

EXCEPTION
    WHEN OTHERS THEN RAISE 'delete assignment failed for assignment id %.',
    aid;

END;

$$ LANGUAGE plpgsql;