DROP FUNCTION PUBLIC .delete_student(sid uuid, cid bigint);

CREATE
OR replace FUNCTION PUBLIC .delete_student(sid uuid, cid bigint) RETURNS setof PUBLIC."StudentCourse" AS $$ BEGIN
    RETURN query
    DELETE FROM
        PUBLIC."StudentCourse"
    WHERE
        student_id = sid
        AND course_id = cid RETURNING *;

END;

$$ LANGUAGE plpgsql;