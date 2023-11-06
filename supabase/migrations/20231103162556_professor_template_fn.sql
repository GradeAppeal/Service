-- insert template
CREATE
OR replace FUNCTION PUBLIC .insert_template(pid text, temp_name text, temp_text text) returns VOID AS $$ BEGIN
    INSERT INTO
        PUBLIC."Templates" (professor_id, temp_name, temp_text)
    VALUES
        (pid :: uuid, temp_name, temp_text);

EXCEPTION
    WHEN OTHERS THEN RAISE 'insert failed for template %: %.',
    temp_name,
    temp_text;

END;

$$ LANGUAGE plpgsql;

-- delete template
CREATE
OR replace FUNCTION PUBLIC .delete_template(tid bigint) returns VOID AS $$ BEGIN
    DELETE FROM
        PUBLIC."Templates"
    WHERE
        id = tid;

EXCEPTION
    WHEN OTHERS THEN RAISE 'delete failed for templateID %.',
    tid;

END;

$$ LANGUAGE plpgsql;