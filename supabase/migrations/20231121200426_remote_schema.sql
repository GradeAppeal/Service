drop trigger if exists "tr_on_new_appeal" on "public"."StudentAppeal";

drop trigger if exists "tr_sort_user" on "public"."Users";

alter table "public"."Messages" drop constraint "messages_recipient_id_fkey";

alter table "public"."Messages" drop constraint "messages_sender_id_fkey";

alter table "public"."Professors" drop constraint "profesors_id_fkey";

alter table "public"."Students" drop constraint "students_id_fkey";

drop function if exists "public"."delete_user"();

drop function if exists "public"."get_messages"(aid bigint);

drop function if exists "public"."get_user_info"(uid text);

drop function if exists "public"."get_user_name"(userid uuid);

drop function if exists "public"."insert_course"(prefix text, code bigint, name text, section text, semester text, year bigint);

drop function if exists "public"."on_new_appeal"();

drop function if exists "public"."sort_user"();

alter table "public"."Users" drop constraint "authorizedusers_pkey";

drop index if exists "public"."authorizedusers_pkey";

drop table "public"."Users";

create table "public"."Profiles" (
    "id" uuid not null default auth.uid(),
    "role" text not null default ''::text,
    "first_name" text default ''::text,
    "last_name" text default ''::text,
    "email" text not null
);


CREATE UNIQUE INDEX authorizedusers_pkey ON public."Profiles" USING btree (id);

alter table "public"."Profiles" add constraint "authorizedusers_pkey" PRIMARY KEY using index "authorizedusers_pkey";

alter table "public"."Messages" add constraint "messages_recipient_id_fkey" FOREIGN KEY (recipient_id) REFERENCES "Profiles"(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."Messages" validate constraint "messages_recipient_id_fkey";

alter table "public"."Messages" add constraint "messages_sender_id_fkey" FOREIGN KEY (sender_id) REFERENCES "Profiles"(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."Messages" validate constraint "messages_sender_id_fkey";

alter table "public"."Professors" add constraint "profesors_id_fkey" FOREIGN KEY (id) REFERENCES "Profiles"(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."Professors" validate constraint "profesors_id_fkey";

alter table "public"."Students" add constraint "students_id_fkey" FOREIGN KEY (id) REFERENCES "Profiles"(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."Students" validate constraint "students_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.delete_profile()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$ 
begin
    DELETE FROM public."Profiles" as p
    WHERE p.id = old.id;
    RETURN old;
END;

$function$
;

CREATE OR REPLACE FUNCTION public.get_grader_appeals(gid text)
 RETURNS TABLE(professor_id uuid, professor_first_name text, professor_last_name text, course_prefix text, course_code bigint, course_name text, course_section text, course_semester text, course_year bigint, assignment_id bigint, assignment_name text, appeal_id bigint, created_at timestamp with time zone, is_open boolean)
 LANGUAGE plpgsql
AS $function$ BEGIN
    RETURN query
    SELECT
        ci.professor_id AS professor_id,
        ci.professor_first_name AS professor_first_name,
        ci.professor_last_name AS professor_last_name,
        ci.course_prefix AS course_prefix,
        ci.course_code AS course_code,
        ci.course_name AS course_name,
        ci.course_section AS course_section,
        ci.course_semester AS course_semester,
        ci.course_year AS course_year,
        assignments.id AS assignment_id,
        assignments.assignment_name AS assignment_name,
        appeals.id AS appeal_id,
        appeals.created_at AS created_at,
        appeals.is_open AS is_open
    FROM
        PUBLIC."Students" AS s
        INNER JOIN PUBLIC."StudentCourse" AS sc ON s.id = sc.student_id
        INNER JOIN course_info AS ci ON sc.course_id = ci.course_id
        INNER JOIN PUBLIC."Assignments" AS assignments ON ci.course_id = assignments.course_id
        INNER JOIN PUBLIC."Appeals" AS appeals ON assignments.id = appeals.assignment_id
    WHERE
        sc.is_grader IS TRUE
        AND s.id = gid :: UUID
        AND appeals.is_open IS TRUE;

-- todo: fetch on grader assign status
EXCEPTION
    WHEN OTHERS THEN RAISE 'select failed for graderID %.',
    gid;

END;

$function$
;

CREATE OR REPLACE FUNCTION public.get_profile_info(uid text)
 RETURNS SETOF "Profiles"
 LANGUAGE plpgsql
AS $function$ BEGIN
    RETURN query
    SELECT
        *
    FROM
        PUBLIC."Profiles"
    WHERE
        id = UID :: UUID;

EXCEPTION
    WHEN OTHERS THEN RAISE 'select user information failed for user with uid: %',
    UID;

END;

$function$
;

CREATE OR REPLACE FUNCTION public.get_profile_name(userid uuid)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
    username text;

BEGIN
    SELECT
        first_name || ' ' || last_name INTO username
    FROM
        PUBLIC."Profiles" AS p
    WHERE
        p.id = userId;

RETURN username;

END;

$function$
;

CREATE OR REPLACE FUNCTION public.insert_course(pid text, prefix text, code bigint, name text, section text, semester text, year bigint)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
 DECLARE
    new_course_id bigint;

 BEGIN
    INSERT INTO
        PUBLIC."Courses" (prefix, code, name, section, semester, year)
    VALUES
        (prefix, code, name, section, semester, year) 
        RETURNING id INTO new_course_id;
    
    INSERT INTO
        PUBLIC."ProfessorCourse" (professor_id, course_id)
    VALUES
        (pid :: uuid, new_course_id);
EXCEPTION
    WHEN OTHERS THEN RAISE 'insert failed for course % %. ',
    prefix,
    code;
  END;
$function$
;

CREATE OR REPLACE FUNCTION public.sort_profile()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  if new.role = 'student' then
    insert into public."Students"
    (
      id,
      first_name,
      last_name,
      email
    )
    values
    (
      new.id,
      new.first_name,
      new.last_name,
      new.email
    );
    return new;
  elsif new.role = 'professor' then
    insert into public."Professors"
    (
      id,
      first_name,
      last_name,
      email
    )
    values
    (
      new.id,
      new.first_name,
      new.last_name,
      new.email
    );
    return new;
  elsif new.role = 'admin' then
    insert into public."Admins"
    (
      id,
      first_name,
      last_name,
      email
    )
    values
    (
      new.id,
      new.first_name,
      new.last_name,
      new.email
    );
    return new;
  else
    raise exception 'Cannot recognize given type';
  end if;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.assign_role()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
    role text;

first_name text;

last_name text;

BEGIN
    -- get first name
    SELECT
        NEW .raw_user_meta_data ->> 'first_name' INTO first_name;

-- get last name
SELECT
    NEW .raw_user_meta_data ->> 'last_name' INTO last_name;

IF NEW .email NOT LIKE '%@calvin.edu' THEN RAISE
EXCEPTION
    'Please use a valid @calvin.edu email';

END IF;

IF NEW .email ~ '^[a-z]+\.[a-z]+@calvin.edu' THEN role := 'professor';

ELSIF NEW .email ~ '^[a-z]+[0-9]+@calvin.edu' THEN role := 'student';

ELSE RAISE
EXCEPTION
    'Please use a valid @calvin.edu email';

END IF;

INSERT INTO
    "public"."Profiles" (
        id,
        role,
        first_name,
        last_name,
        email
    )
VALUES
    (
        NEW .id,
        role,
        first_name,
        last_name,
        NEW .email
    );

RETURN NEW;

END;

$function$
;

CREATE OR REPLACE FUNCTION public.insert_appeal(aid bigint, sid text, cid bigint, created_at timestamp with time zone, appeal_text text)
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
DECLARE
    new_appeal_id bigint;

professor_id uuid;

BEGIN
    -- insert into Appeals table
    INSERT INTO
        PUBLIC."Appeals" (
            assignment_id,
            created_at,
            appeal_text,
            is_open,
            grader_id
        )
    VALUES
        (
            aid,
            created_at,
            appeal_text,
            TRUE,
            NULL
        ) RETURNING id INTO new_appeal_id;

INSERT INTO
    PUBLIC."StudentAppeal" (student_id, appeal_id)
VALUES
    (sid :: uuid, new_appeal_id);

SELECT
    p.id INTO professor_id
FROM
    PUBLIC."Professors" AS p
    INNER JOIN PUBLIC."ProfessorCourse" AS pc ON p.id = pc.professor_id
    INNER JOIN PUBLIC."Courses" AS C ON pc.course_id = C .id
WHERE
    C .id = cid;

INSERT INTO
    PUBLIC."Messages" (
        created_at,
        sender_id,
        recipient_id,
        appeal_id,
        message_text,
        from_grader
    )
VALUES
    (
        created_at,
        sid :: uuid,
        professor_id,
        new_appeal_id,
        appeal_text,
        FALSE
    );

RETURN new_appeal_id;

EXCEPTION
    WHEN OTHERS THEN RAISE 'insert failed for sender: %,recipient %,appeal_text: %,created_at: %, new_appeal_id: %',
    sid,
    professor_id,
    appeal_text,
    created_at,
    new_appeal_id;

END;

$function$
;

CREATE OR REPLACE FUNCTION public.is_student_user(student_email text)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
    is_user BOOLEAN;

BEGIN
    SELECT
        EXISTS(
            SELECT
                1
            FROM
                PUBLIC."Profiles" AS p
            WHERE
                p.email = student_email
        ) INTO is_user;

RETURN is_user;

END;

$function$
;

CREATE TRIGGER tr_sort_profile AFTER INSERT ON public."Profiles" FOR EACH ROW EXECUTE FUNCTION sort_profile();


