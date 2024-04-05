ALTER TABLE
    PUBLIC."Professors"
ADD
    COLUMN cron_job TEXT;

-- fill existing COLUMNS;
UPDATE
    PUBLIC."Professors"
SET
    cron_job = '0 8 * * 1'
WHERE
    cron_job IS NULL
    AND is_verified = TRUE;

-- set default value to be 8 AM on Mondays
ALTER TABLE
    PUBLIC."Professors"
ALTER COLUMN
    cron_job
SET
    DEFAULT '0 8 * * 1'