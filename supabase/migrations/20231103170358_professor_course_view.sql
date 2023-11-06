CREATE
OR replace VIEW course_info AS
SELECT
    p.id AS professor_id,
    p.first_name AS professor_first_name,
    p.last_name AS professor_last_name,
    C .id AS course_id,
    C .prefix AS course_prefix,
    C .code AS course_code,
    C .name AS course_name,
    C .section AS course_section,
    C.semester AS course_semester,
    C .year AS course_year
FROM
    "Professors" AS p
    INNER JOIN "ProfessorCourse" AS pc ON p.id = pc.professor_id
    INNER JOIN "Courses" AS C ON pc.course_id = C .id;