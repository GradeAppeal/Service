CREATE OR REPLACE FUNCTION get_cron_schedule_type(cron_schedule text)
    RETURNS text
    AS $$
DECLARE
    cron_schedule_type text;
BEGIN
    SELECT
        CASE WHEN cron_schedule LIKE '% % * * *' THEN
            '1 day'
        WHEN cron_schedule LIKE '% % % * *' THEN
            '1 month'
        WHEN cron_schedule LIKE '% % * * %' THEN
            '7 days'
        WHEN cron_schedule LIKE '* * * * *' THEN
            '1 minute'
        ELSE
            'unknown'
        END INTO cron_schedule_type;
    RETURN cron_schedule_type;
END;
$$
LANGUAGE plpgsql;

