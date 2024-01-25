DROP FUNCTION IF EXISTS PUBLIC .update_template(pid uuid, temp_name text, new_temp_text text);

CREATE
OR replace FUNCTION PUBLIC .update_template(
    tid bigint,
    pid uuid,
    tname text,
    new_temp_text text
) returns VOID AS $$ BEGIN
    UPDATE
        PUBLIC."Templates"
    SET
        temp_text = new_temp_text,
        temp_name = tname
    WHERE
        professor_id = pid
        AND id = tid;

END;

$$ LANGUAGE plpgsql;