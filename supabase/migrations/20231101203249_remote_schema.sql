drop trigger if exists "tr_on_new_appeal" on "public"."StudentAppeal";

alter table "public"."Templates" drop constraint "templates_professor_id_fkey";

drop function if exists "public"."insert_appeal"(aid bigint, sid uuid, cid bigint, created_at timestamp with time zone, appeal_text text);

alter table "public"."Templates" drop constraint "Templates_pkey";

drop index if exists "public"."Templates_pkey";

alter table "public"."Appeals" drop column "grade";

alter table "public"."Templates" drop column "temp_description";

alter table "public"."Templates" add column "id" bigint not null;

CREATE UNIQUE INDEX "Templates_pkey" ON public."Templates" USING btree (id);

alter table "public"."Templates" add constraint "Templates_pkey" PRIMARY KEY using index "Templates_pkey";

alter table "public"."Templates" add constraint "Templates_professor_id_fkey" FOREIGN KEY (professor_id) REFERENCES "Professors"(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."Templates" validate constraint "Templates_professor_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.insert_appeal(aid bigint, sid text, cid bigint, created_at timestamp with time zone, appeal_text text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    new_appeal_id bigint;

BEGIN
    -- insert into Appeals table
    INSERT INTO
        PUBLIC."Appeals" (
            created_at,
            assignment_id,
            appeal_text,
            is_open,
            grader_id
        )
    VALUES
        (
            created_at,
            aid,
            appeal_text,
            TRUE,
            NULL
        ) RETURNING id INTO new_appeal_id;

-- insert into join table
INSERT INTO
    PUBLIC."StudentAppeal" (student_id, appeal_id)
VALUES
    (sid, new_appeal_id);

EXCEPTION
    WHEN OTHERS THEN RAISE info 'insert failed for %',
    now();

END;

$function$
;

CREATE TRIGGER tr_on_new_appeal AFTER INSERT ON public."StudentAppeal" FOR EACH ROW EXECUTE FUNCTION on_new_appeal();
ALTER TABLE "public"."StudentAppeal" DISABLE TRIGGER "tr_on_new_appeal";


