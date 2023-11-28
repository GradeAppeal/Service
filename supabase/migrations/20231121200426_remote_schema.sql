DROP TRIGGER IF EXISTS "tr_on_new_appeal" ON "public"."StudentAppeal";

DROP TRIGGER IF EXISTS "tr_sort_user" ON "public"."Users";

ALTER TABLE
    "public"."Messages" DROP constraint "messages_recipient_id_fkey";

ALTER TABLE
    "public"."Messages" DROP constraint "messages_sender_id_fkey";

ALTER TABLE
    "public"."Professors" DROP constraint "profesors_id_fkey";

ALTER TABLE
    "public"."Students" DROP constraint "students_id_fkey";

--drop function if exists "public"."delete_user"();
DROP FUNCTION IF EXISTS "public"."get_messages"(aid bigint);

DROP FUNCTION IF EXISTS "public"."get_user_info"(UID text);

DROP FUNCTION IF EXISTS "public"."get_user_name"(userid uuid);

DROP FUNCTION IF EXISTS "public"."insert_course"(
    prefix text,
    code bigint,
    NAME text,
    section text,
    semester text,
    YEAR bigint
);

DROP FUNCTION IF EXISTS "public"."on_new_appeal"();

DROP FUNCTION IF EXISTS "public"."sort_user"();

ALTER TABLE
    "public"."Users" DROP constraint "authorizedusers_pkey";

DROP INDEX IF EXISTS "public"."authorizedusers_pkey";

DROP TABLE "public"."Users";

CREATE TABLE "public"."Profiles" (
    "id" uuid NOT NULL DEFAULT auth.uid(),
    "role" text NOT NULL DEFAULT '' :: text,
    "first_name" text DEFAULT '' :: text,
    "last_name" text DEFAULT '' :: text,
    "email" text NOT NULL
);

CREATE UNIQUE INDEX authorizedusers_pkey ON PUBLIC."Profiles" USING btree (id);

ALTER TABLE
    "public"."Profiles"
ADD
    constraint "authorizedusers_pkey" PRIMARY KEY USING INDEX "authorizedusers_pkey";

ALTER TABLE
    "public"."Messages"
ADD
    constraint "messages_recipient_id_fkey" FOREIGN KEY (recipient_id) REFERENCES "Profiles"(id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE NOT valid;

ALTER TABLE
    "public"."Messages" VALIDATE constraint "messages_recipient_id_fkey";

ALTER TABLE
    "public"."Messages"
ADD
    constraint "messages_sender_id_fkey" FOREIGN KEY (sender_id) REFERENCES "Profiles"(id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE NOT valid;

ALTER TABLE
    "public"."Messages" VALIDATE constraint "messages_sender_id_fkey";

ALTER TABLE
    "public"."Professors"
ADD
    constraint "profesors_id_fkey" FOREIGN KEY (id) REFERENCES "Profiles"(id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE NOT valid;

ALTER TABLE
    "public"."Professors" VALIDATE constraint "profesors_id_fkey";

ALTER TABLE
    "public"."Students"
ADD
    constraint "students_id_fkey" FOREIGN KEY (id) REFERENCES "Profiles"(id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE NOT valid;

ALTER TABLE
    "public"."Students" VALIDATE constraint "students_id_fkey";

SET
    check_function_bodies = off;

CREATE
OR REPLACE FUNCTION PUBLIC .delete_profile() RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $function$ BEGIN
    DELETE FROM
        PUBLIC."Profiles" AS p
    WHERE
        p.id = OLD .id;

RETURN OLD;

END;

$function$;

CREATE
OR REPLACE FUNCTION PUBLIC .get_grader_appeals(gid text) RETURNS TABLE(
    professor_id uuid,
    professor_first_name text,
    professor_last_name text,
    course_prefix text,
    course_code bigint,
    course_name text,
    course_section text,
    course_semester text,
    course_year bigint,
    assignment_id bigint,
    assignment_name text,
    appeal_id bigint,
    created_at TIMESTAMP WITH TIME ZONE,
    is_open BOOLEAN
) LANGUAGE plpgsql AS $function$ BEGIN
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

$function$;

CREATE
OR REPLACE FUNCTION PUBLIC .get_profile_info(UID text) RETURNS SETOF "Profiles" LANGUAGE plpgsql AS $function$ BEGIN
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

$function$;

CREATE
OR REPLACE FUNCTION PUBLIC .get_profile_name(userid uuid) RETURNS text LANGUAGE plpgsql AS $function$
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

$function$;

CREATE
OR REPLACE FUNCTION PUBLIC .insert_course(
    pid text,
    prefix text,
    code bigint,
    NAME text,
    section text,
    semester text,
    YEAR bigint
) RETURNS VOID LANGUAGE plpgsql AS $function$
DECLARE
    new_course_id bigint;

BEGIN
    INSERT INTO
        PUBLIC."Courses" (prefix, code, NAME, section, semester, YEAR)
    VALUES
        (prefix, code, NAME, section, semester, YEAR) RETURNING id INTO new_course_id;

INSERT INTO
    PUBLIC."ProfessorCourse" (professor_id, course_id)
VALUES
    (pid :: uuid, new_course_id);

EXCEPTION
    WHEN OTHERS THEN RAISE 'insert failed for course % %. ',
    prefix,
    code;

END;

$function$;

CREATE
OR REPLACE FUNCTION PUBLIC .sort_profile() RETURNS TRIGGER LANGUAGE plpgsql AS $function$ BEGIN
    IF NEW .role = 'student' THEN
    INSERT INTO
        PUBLIC."Students" (
            id,
            first_name,
            last_name,
            email
        )
    VALUES
        (
            NEW .id,
            NEW .first_name,
            NEW .last_name,
            NEW .email
        );

RETURN NEW;

ELSIF NEW .role = 'professor' THEN
INSERT INTO
    PUBLIC."Professors" (
        id,
        first_name,
        last_name,
        email
    )
VALUES
    (
        NEW .id,
        NEW .first_name,
        NEW .last_name,
        NEW .email
    );

RETURN NEW;

ELSIF NEW .role = 'admin' THEN
INSERT INTO
    PUBLIC."Admins" (
        id,
        first_name,
        last_name,
        email
    )
VALUES
    (
        NEW .id,
        NEW .first_name,
        NEW .last_name,
        NEW .email
    );

RETURN NEW;

ELSE RAISE
EXCEPTION
    'Cannot recognize given type';

END IF;

END;

$function$;

CREATE
OR REPLACE FUNCTION PUBLIC .assign_role() RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $function$
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

$function$;

DROP FUNCTION IF EXISTS PUBLIC .insert_appeal(
    aid bigint,
    sid text,
    cid bigint,
    created_at TIMESTAMP WITH TIME ZONE,
    appeal_text text
);

CREATE
OR REPLACE FUNCTION PUBLIC .insert_appeal(
    aid bigint,
    sid text,
    cid bigint,
    created_at TIMESTAMP WITH TIME ZONE,
    appeal_text text
) RETURNS bigint LANGUAGE plpgsql AS $function$
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

$function$;

CREATE
OR REPLACE FUNCTION PUBLIC .is_student_user(student_email text) RETURNS BOOLEAN LANGUAGE plpgsql AS $function$
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

$function$;

CREATE TRIGGER tr_sort_profile AFTER
INSERT
    ON PUBLIC."Profiles" FOR EACH ROW EXECUTE FUNCTION sort_profile();