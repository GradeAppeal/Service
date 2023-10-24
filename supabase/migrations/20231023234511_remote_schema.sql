create table "public"."Admins" (
    "id" uuid not null,
    "first_name" text,
    "last_name" text,
    "email" text not null
);


CREATE UNIQUE INDEX admins_email_key ON public."Admins" USING btree (email);

CREATE UNIQUE INDEX admins_pkey ON public."Admins" USING btree (id);

alter table "public"."Admins" add constraint "admins_pkey" PRIMARY KEY using index "admins_pkey";

alter table "public"."Admins" add constraint "admins_email_key" UNIQUE using index "admins_email_key";

alter table "public"."Admins" add constraint "admins_id_fkey" FOREIGN KEY (id) REFERENCES "Users"(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."Admins" validate constraint "admins_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.assign_role()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$ 
DECLARE role text;
first_name text;
last_name text;

BEGIN -- get first name
SELECT
    new.raw_user_meta_data ->> 'first_name' INTO first_name;

-- get last name
SELECT
    new.raw_user_meta_data ->> 'last_name' INTO last_name;

IF new.email NOT LIKE '%@calvin.edu' THEN RAISE EXCEPTION 'Please use a valid @calvin.edu email';

END IF;

IF new.email = 'al87@calvin.edu'
OR new.email = 'thv4@calvin.edu' THEN role := 'admin';

ELSIF new.email ~ '^[a-z]+\.[a-z]+@calvin.edu' THEN role := 'professor';

ELSIF new.email ~ '^[a-z]+[0-9]+@calvin.edu' THEN role := 'student';

ELSE RAISE EXCEPTION 'Please use a valid @calvin.edu email';

END IF;

INSERT INTO
    "public"."Users" (
        id,
        role,
        first_name,
        last_name,
        email
    )
VALUES
    (
        new.id,
        role,
        first_name,
        last_name,
        new.email
    );

RETURN new;

END;

$function$
;

CREATE OR REPLACE FUNCTION public.delete_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$ 
begin
    DELETE FROM public."Users" as u
    WHERE u.id = old.id;
    RETURN old;
END;

$function$
;

CREATE OR REPLACE FUNCTION public.sort_user()
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


