DROP FUNCTION IF EXISTS PUBLIC .get_cid_from_message(appid bigint);

CREATE
OR replace FUNCTION PUBLIC .get_cid_from_message(appid bigint) returns bigint AS $$
DECLARE
    cid bigint;

BEGIN
    SELECT
        INTO cid C .id
    FROM
        PUBLIC."Courses" AS C
        INNER JOIN PUBLIC."Assignments" AS A ON C .id = A .course_id
        INNER JOIN PUBLIC."Appeals" AS app ON A .id = app.assignment_id
        INNER JOIN PUBLIC."Messages" AS m ON app.id = m.appeal_id
    WHERE
        m.appeal_id = appid;

RETURN cid;

END;

$$ LANGUAGE plpgsql;