DROP FUNCTION IF EXISTS on_update_cron();

CREATE
OR replace FUNCTION on_update_cron() returns TRIGGER AS $$
DECLARE
    job_name text;

jid bigint;

digest_type text;

BEGIN
    job_name := NEW .first_name || '-' || NEW .last_name || '-Digest';

CASE
    WHEN NEW .cron_job LIKE '% % * * *' THEN digest_type := '1 day';

WHEN NEW .cron_job LIKE '% % % * *' THEN digest_type := '1 month';

WHEN NEW .cron_job LIKE '% % * * %' THEN digest_type := '7 days';

ELSE RAISE
EXCEPTION
    'Unknown cron job pattern: %',
    NEW .cron_job;

END CASE
;

SELECT
    jobid INTO jid
FROM
    cron.job
WHERE
    jobname = job_name;

IF NOT FOUND THEN RAISE
EXCEPTION
    'No job found with name: %',
    job_name;

END IF;

SELECT
    cron.alter_job(jid :: bigint, NEW .cron_job);

RETURN NEW;

END;

$$ LANGUAGE plpgsql;