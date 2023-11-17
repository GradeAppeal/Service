DROP FUNCTION IF EXISTS PUBLIC .insert_template(pid text, temp_name text, temp_text text);

DROP FUNCTION IF EXISTS PUBLIC .delete_template(tid bigint);

-- insert template
CREATE
OR replace FUNCTION PUBLIC .insert_template(pid text, temp_name text, temp_text text) returns VOID AS $$ BEGIN
    INSERT INTO
        PUBLIC."Templates" (professor_id, temp_name, temp_text)
    VALUES
        (pid :: uuid, temp_name, temp_text);

END;

$$ LANGUAGE plpgsql;

-- delete template
CREATE
OR replace FUNCTION PUBLIC .delete_template(tid bigint) returns VOID AS $$ BEGIN
    DELETE FROM
        PUBLIC."Templates"
    WHERE
        id = tid;

END;

$$ LANGUAGE plpgsql;