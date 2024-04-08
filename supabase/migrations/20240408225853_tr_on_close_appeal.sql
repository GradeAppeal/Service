DROP TRIGGER IF EXISTS tr_on_close_appeal ON PUBLIC."Appeals";

CREATE TRIGGER tr_on_close_appeal AFTER
UPDATE
    OF is_open ON PUBLIC."Appeals" FOR EACH ROW
    WHEN (NEW .is_open = FALSE) EXECUTE FUNCTION on_close_appeal();