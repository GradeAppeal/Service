DROP TRIGGER IF EXISTS tr_on_update_cron ON PUBLIC."Professors";

CREATE TRIGGER tr_on_update_cron AFTER
UPDATE
    OF cron_job ON PUBLIC."Professors" FOR EACH ROW EXECUTE FUNCTION on_update_cron();