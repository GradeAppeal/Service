DROP TRIGGER IF EXISTS tr_on_schedule_cron ON PUBLIC."Professors";

CREATE TRIGGER tr_on_schedule_cron AFTER
UPDATE
    OF is_verified ON PUBLIC."Professors" FOR EACH ROW EXECUTE FUNCTION on_schedule_cron();