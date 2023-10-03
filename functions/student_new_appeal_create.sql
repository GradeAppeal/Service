create
or replace function insert_new_appeal (
    aid bigint,
    sid bigint,
    cid bigint,
    created_at timestamptz,
    appeal_text varchar
) returns void language plpgsql as $ $ declare new_appeal_id bigint;

student_user_id bigint;

professor_user_id bigint;

begin -- get student user id
select
    user_id
from
    "Students"
where
    id = sid into student_user_id;

-- insert into Appeals table
insert into
    "Appeals" (
        assignment_id,
        created_at,
        appeal_text,
        is_open
    )
values
    (
        aid,
        created_at,
        appeal_text,
        true
    ) returning id into new_appeal_id;

-- get professor
select
    into professor_user_id p.user_id
from
    "Courses" as c
    inner join "ProfessorCourse" as pc on c.id = pc.course_id
    inner join "Professors" as p on pc.professor_id = p.id
where
    c.id = cid;

--insert into studentAppeal join table
insert into
    "StudentAppeal" (student_id, appeal_id)
values
    (sid, new_appeal_id);

-- insert into messages
insert into
    "Messages" (
        sender_id,
        recipient_id,
        appeal_id,
        created_at,
        message_text,
        from_grader
    )
values
    (
        student_user_id,
        professor_user_id,
        new_appeal_id,
        created_at,
        appeal_text,
        false
    );

end;

$ $;