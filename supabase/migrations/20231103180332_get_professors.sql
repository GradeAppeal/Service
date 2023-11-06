CREATE
OR replace FUNCTION PUBLIC .get_professors() returns setof PUBLIC."Professors" AS $$ BEGIN
    RETURN query
    SELECT
        *
    FROM
        PUBLIC."Professors";

EXCEPTION
    WHEN OTHERS THEN RAISE 'select Professors failed';

END;

$$ LANGUAGE plpgsql;