DROP FUNCTION IF EXISTS PUBLIC .on_delete_grader();

CREATE
OR replace FUNCTION PUBLIC .on_delete_grader() returns TRIGGER AS $$ BEGIN
    UPDATE
        PUBLIC."Assignments"
    SET
        grader_id = NULL,
        grader_name = NULL
    WHERE
        course_id = OLD .course_id
        AND grader_id = OLD .student_id;

RETURN NEW;

END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_on_delete_grader AFTER
DELETE
    ON PUBLIC."StudentCourse" FOR each ROW
    WHEN (OLD .is_grader = TRUE) EXECUTE PROCEDURE PUBLIC .on_delete_grader();