create
or replace function get_professor_appeals(pid bigint) returns table (
    prefix varchar,
    code bigint,
    course_name varchar,
    course_section varchar,
    course_semester varchar,
    course_year bigint,
    student_id bigint,
    student_name text,
    assignment_id bigint,
    appeal_id bigint,
    created_at timestamptz,
    appeal_text varchar,
    is_open boolean
) language plpgsql as $ $ begin return query
select
    c.prefix,
    c.code,
    c.name,
    c.section,
    c.semester,
    c.year,
    s.id as student_id,
    s.first_name || ' ' || s.last_name as student_name,
    a.id as assignment_id,
    app.id as appeal_id,
    app.created_at as created_at,
    app.appeal_text as appeal_text,
    app.is_open as is_open
from
    "Professors" as p
    inner join "ProfessorCourse" as pc on p.id = pc.professor_id
    inner join "Courses" as c on pc.course_id = c.id
    inner join "Assignments" as a on c.id = a.course_id
    inner join "Appeals" as app on a.id = app.assignment_id
    inner join "StudentAppeal" as sa on app.id = sa.appeal_id
    inner join "Students" as s on sa.student_id = s.id
where
    p.id = pid;

end;

$ $;

create
or replace function get_student_grade (aid bigint, sid bigint) returns bigint AS $ $ begin return (
    select
        grade
    from
        "Grades"
    where
        assignment_id = aid
        and student_id = sid
);

end;

$ $ language plpgsql;