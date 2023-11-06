alter table "public"."Admins" drop constraint "admins_email_key";

alter table "public"."Admins" drop constraint "admins_id_fkey";

drop function if exists "public"."insert_student"(student_email text, cid bigint);

alter table "public"."Admins" drop constraint "admins_pkey";

drop index if exists "public"."admins_email_key";

drop index if exists "public"."admins_pkey";

drop table "public"."Admins";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.insert_appeal(aid bigint, sid uuid, cid bigint, created_at timestamp with time zone, appeal_text text)
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
DECLARE
    new_appeal_id bigint;

BEGIN
    -- insert into Appeals table
    INSERT INTO
        PUBLIC."Appeals" (
            assignment_id,
            created_at,
            appeal_text,
            is_open,
            grade
        )
    VALUES
        (
            aid,
            created_at,
            appeal_text,
            TRUE,
            student_grade
        ) RETURNING id INTO new_appeal_id;

-- insert into join table
INSERT INTO
    PUBLIC."StudentAppeal" (student_id, appeal_id)
VALUES
    (sid, new_appeal_id);

RETURN 1;

EXCEPTION 
    WHEN OTHERS THEN RAISE info 'insert failed for %',
    now();
RETURN 0;


END;

$function$
;


