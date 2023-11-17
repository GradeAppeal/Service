DROP FUNCTION IF EXISTS PUBLIC .delete_course(cid bigint);

CREATE
OR replace FUNCTION PUBLIC .delete_course(cid bigint, pid text) returns VOID AS $$ BEGIN
    DELETE FROM
        PUBLIC."Courses"
    WHERE
        id = cid;

DELETE FROM
    PUBLIC."ProfessorCourse"
WHERE
    course_id = cid
    AND professor_id = pid :: UUID;

EXCEPTION
    WHEN OTHERS THEN RAISE 'delete failed for courseID %.',
    cid;

END;

$$ LANGUAGE plpgsql;