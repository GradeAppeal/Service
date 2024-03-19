DROP FUNCTION IF EXISTS PUBLIC .is_student(sid text);

CREATE
OR replace FUNCTION PUBLIC .is_student(sid text) RETURNs BOOLEAN AS $$
DECLARE
    student_status BOOLEAN;

BEGIN
    SELECT
        INTO student_status EXISTS(
            SELECT
                1
            FROM
                PUBLIC."Students" AS s
            WHERE
                s.id = sid :: UUID
        );

RETURN student_status;

END;

$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS PUBLIC .is_professor(pid text);

CREATE
OR replace FUNCTION PUBLIC .is_professor(pid text) RETURNs BOOLEAN AS $$
DECLARE
    professor_status BOOLEAN;

BEGIN
    SELECT
        INTO professor_status EXISTS(
            SELECT
                1
            FROM
                PUBLIC."Professors" AS p
            WHERE
                p.id = pid :: UUID
        );

RETURN professor_status;

END;

$$ LANGUAGE plpgsql;