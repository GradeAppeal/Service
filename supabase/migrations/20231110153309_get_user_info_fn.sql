CREATE
OR replace FUNCTION PUBLIC .get_student(sid text) RETURNS setof PUBLIC."Students" AS $$ BEGIN
    RETURN query
    SELECT
        *
    FROM
        PUBLIC."Students"
    WHERE
        id = sid :: UUID;

END;

$$ LANGUAGE plpgsql;

CREATE
OR replace FUNCTION PUBLIC .get_professor(pid text) RETURNS setof PUBLIC."Professors" AS $$ BEGIN
    RETURN query
    SELECT
        *
    FROM
        PUBLIC."Professors"
    WHERE
        id = pid :: UUID;

END;

$$ LANGUAGE plpgsql;