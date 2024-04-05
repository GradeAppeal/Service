DROP FUNCTION IF EXISTS on_schedule_cron();

CREATE
OR replace FUNCTION on_schedule_cron() returns TRIGGER AS $$
DECLARE
    job_name text;

digest_type text;

-- only schedule cron job if the professor is verified
BEGIN
    IF NEW .is_verified = TRUE THEN job_name := NEW .first_name || '-' || NEW .last_name || '-Digest';

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
    cron.schedule(
        job_name,
        NEW .cron_job,
        format(
            'CALL proc_invoke_digest_email(%L, %L, %L)',
            NEW .id,
            NEW .email,
            digest_type
        )
    );

END IF;

RETURN NEW;

END;

$$ LANGUAGE plpgsql;