CREATE
or replace function get_student_courses(sid bigint) returns table (
    course_id bigint,
    course_prefix varchar,
    course_code bigint,
    course_name varchar,
    course_section varchar,
    course_semester varchar,
    course_year bigint,
    professor_name text,
    is_grader boolean
) language plpgsql as $ $ begin return query
select
    c.id,
    c.prefix,
    c.code,
    c.name,
    c.section,
    c.semester,
    c.year,
    p.first_name || ' ' || p.last_name as professor_name,
    sc.is_grader
from
    "Students" as s
    inner join "StudentCourse" as sc on s.id = sc.student_id
    inner join "Courses" as c on sc.course_id = c.id
    inner join "ProfessorCourse" as pc on c.id = pc.course_id
    inner join "Professors" as p on pc.professor_id = p.id
where
    s.id = sid;

end;

$ $;