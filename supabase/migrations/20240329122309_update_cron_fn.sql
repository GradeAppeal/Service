DROP FUNCTION IF EXISTS PUBLIC .update_cron(pid text, cron text);

CREATE
OR replace FUNCTION PUBLIC .update_cron(pid text, cron text) returns VOID AS $$ BEGIN
    UPDATE
        PUBLIC."Professors"
    SET
        cron_job = cron
    WHERE
        id = pid :: UUID;

END;

$$ LANGUAGE plpgsql;