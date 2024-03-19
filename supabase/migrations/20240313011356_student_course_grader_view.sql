CREATE
OR replace VIEW student_course_grader_info AS
SELECT
    s.id AS student_id,
    s.first_name || ' ' || s.last_name AS student_name,
    s.email,
    sc.course_id,
    C .prefix || C .code || ' - ' || C .name AS course,
    sc.is_grader,
    s.is_verified
FROM
    "Students" AS s
    INNER JOIN "StudentCourse" AS sc ON s.id = sc.student_id
    INNER JOIN "Courses" AS C ON sc.course_id = C .id;