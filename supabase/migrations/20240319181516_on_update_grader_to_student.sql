CREATE TRIGGER tr_on_update_grader_to_student AFTER
UPDATE
    ON PUBLIC."StudentCourse" FOR each ROW
    WHEN (
        OLD .is_grader = TRUE
        AND NEW .is_grader = FALSE
    ) EXECUTE PROCEDURE PUBLIC .on_delete_grader();