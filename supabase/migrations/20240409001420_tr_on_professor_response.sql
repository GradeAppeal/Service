CREATE
OR REPLACE FUNCTION check_sender_is_professor(pid text) RETURNS BOOLEAN LANGUAGE plpgsql AS $$
DECLARE
    is_professor BOOLEAN;

BEGIN
    SELECT
        EXISTS (
            SELECT
                1
            FROM
                PUBLIC."Professors" AS p
            WHERE
                p.id = pid :: UUID
        ) INTO is_professor;

RETURN is_professor;

END;

$$;

DROP TRIGGER IF EXISTS tr_on_professor_response ON PUBLIC."Messages";

CREATE TRIGGER tr_on_professor_response AFTER
INSERT
    ON PUBLIC."Messages" FOR EACH ROW
    WHEN (
        check_sender_is_professor(NEW .sender_id :: text)
    ) EXECUTE FUNCTION on_professor_response();