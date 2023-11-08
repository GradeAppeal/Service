DROP FUNCTION IF EXISTS PUBLIC .insert_course(
    prefix CHARACTER VARYING,
    code bigint,
    name CHARACTER VARYING,
    section CHARACTER VARYING,
    semester CHARACTER VARYING,
    year bigint
);

CREATE
OR replace FUNCTION PUBLIC .insert_course(
    prefix text,
    code bigint,
    name text,
    section text,
    semester text,
    year bigint
) returns VOID AS $$ BEGIN
    INSERT INTO
        PUBLIC."Courses" (prefix, code, name, section, semester, year)
    VALUES
        (prefix, code, name, section, semester, year);

END;

$$ LANGUAGE plpgsql;