DROP FUNCTION IF EXISTS PUBLIC .get_cron(pid text);

CREATE
OR replace FUNCTION PUBLIC .get_cron(pid text) returns text AS $$
DECLARE
    cron_schedule text;

BEGIN
    SELECT
        cron_job INTO cron_schedule
    FROM
        PUBLIC."Professors"
    WHERE
        id = pid :: UUID;

RETURN cron_schedule;

END;

$$ LANGUAGE plpgsql