CREATE
OR replace FUNCTION PUBLIC .insert_student(sid uuid, cid bigint) returns bigint AS $$ BEGIN
    INSERT INTO
        PUBLIC."StudentCourse" (student_id, course_id)
    VALUES
        (sid, cid);

RETURN 1;

EXCEPTION
    WHEN OTHERS THEN RETURN 0;

END;

$$ LANGUAGE plpgsql;