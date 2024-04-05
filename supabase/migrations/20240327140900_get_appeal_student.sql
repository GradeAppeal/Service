DROP FUNCTION IF EXISTS PUBLIC .get_appeal_student(appid bigint);

CREATE
OR replace FUNCTION PUBLIC .get_appeal_student(appid bigint) returns TABLE(id uuid, first_name text, last_name text) AS $$ BEGIN
    RETURN query
    SELECT
        s.id AS id,
        s.first_name AS first_name,
        s.last_name AS last_name
    FROM
        PUBLIC."Students" AS s
        INNER JOIN PUBLIC."StudentAppeal" AS sa ON s.id = sa.student_id
    WHERE
        sa.appeal_id = appid;

END;

$$ LANGUAGE plpgsql;