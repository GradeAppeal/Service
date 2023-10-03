create
or replace function get_course (cid bigint) returns setof "Courses" language plpgsql as $ $ begin return query
select
    *
from
    "Courses"
where
    id = cid;

end;

$ $;

create
or replace function get_assignments (cid bigint) returns setof "Assignments" language plpgsql as $ $ begin return query
select
    *
from
    "Assignments"
where
    course_id = cid;

end;

$ $;