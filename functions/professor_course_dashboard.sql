create
or replace function get_professor_courses (pid bigint) returns setof "Courses" language plpgsql as $ $ begin return query
select
    c.id,
    c.prefix,
    c.code,
    c.name,
    c.section,
    c.semester,
    c.year
from
    "Courses" as c
    inner join "ProfessorCourse" as pc on c.id = pc.course_id
    inner join "Professors" as p on pc.professor_id = p.id
where
    p.id = pid;

end;

$ $;