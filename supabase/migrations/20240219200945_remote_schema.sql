--drop function if exists "public"."delete_user"();
DROP FUNCTION IF EXISTS "public"."update_appeal_grader"(aid bigint, gid text);

ALTER TABLE
  "public"."Assignments" enable ROW LEVEL security;

ALTER TABLE
  "public"."Courses" enable ROW LEVEL security;

ALTER TABLE
  "public"."ProfessorCourse" enable ROW LEVEL security;

ALTER TABLE
  "public"."Professors" enable ROW LEVEL security;

ALTER TABLE
  "public"."StudentAppeal" enable ROW LEVEL security;

ALTER TABLE
  "public"."StudentCourse" enable ROW LEVEL security;

ALTER TABLE
  "public"."Students" enable ROW LEVEL security;

SET
  check_function_bodies = off;

CREATE
OR REPLACE FUNCTION PUBLIC .get_grader_courses(sid uuid) RETURNS TABLE(
  course_id bigint,
  course_prefix text,
  course_code bigint,
  course_name text,
  course_section text,
  course_semester text,
  course_year bigint,
  professor_first_name text,
  professor_last_name text,
  is_grader BOOLEAN
) LANGUAGE plpgsql AS $function$ BEGIN
  RETURN query
  SELECT
    C .id AS course_id,
    C .prefix AS course_prefix,
    C .code AS course_code,
    C .name AS course_name,
    C .section AS course_section,
    C .semester AS course_semester,
    C .year AS course_year,
    p.first_name AS professor_first_name,
    p.last_name AS professor_last_name,
    sc.is_grader
  FROM
    "Students" AS s
    INNER JOIN "StudentCourse" AS sc ON s.id = sc.student_id
    INNER JOIN "Courses" AS C ON sc.course_id = C .id
    INNER JOIN "ProfessorCourse" AS pc ON C .id = pc.course_id
    INNER JOIN "Professors" AS p ON pc.professor_id = p.id
  WHERE
    s.id = sid
    AND sc.is_grader = TRUE;

END;

$function$;

CREATE
OR REPLACE FUNCTION PUBLIC .get_student_appeals2(sid uuid) RETURNS TABLE(
  course_prefix text,
  course_code bigint,
  course_name text,
  course_section text,
  course_semester text,
  course_year bigint,
  professor_id uuid,
  professor_first_name text,
  professor_last_name text,
  assignment_id bigint,
  assignment_name text,
  appeal_id bigint,
  created_at TIMESTAMP WITH TIME ZONE,
  is_read BOOLEAN
) LANGUAGE plpgsql AS $function$ BEGIN
  RETURN query
  SELECT
    C .id AS course_id,
    C .prefix AS course_prefix,
    C .code AS course_code,
    C .name AS course_name,
    C .section AS course_section,
    C .semester AS course_semester,
    C .year AS course_year,
    p.first_name AS professor_first_name,
    p.last_name AS professor_last_name,
    sc.is_grader
  FROM
    "Students" AS s
    INNER JOIN "StudentCourse" AS sc ON s.id = sc.student_id
    INNER JOIN "Courses" AS C ON sc.course_id = C .id
    INNER JOIN "ProfessorCourse" AS pc ON C .id = pc.course_id
    INNER JOIN "Professors" AS p ON pc.professor_id = p.id
  WHERE
    s.id = sid
    AND s.is_grader = FALSE;

END;

$function$;

CREATE
OR REPLACE FUNCTION PUBLIC .mark_appeal_as_read(aid bigint) RETURNS VOID LANGUAGE plpgsql AS $function$ BEGIN
  UPDATE
    "Appeals"
  SET
    isread = TRUE
  WHERE
    id = aid;

END;

$function$;

CREATE
OR REPLACE FUNCTION PUBLIC .mark_appeal_as_unread(aid bigint) RETURNS VOID LANGUAGE plpgsql AS $function$ BEGIN
  UPDATE
    "Appeals"
  SET
    isread = FALSE
  WHERE
    id = aid;

END;

$function$;

CREATE
OR REPLACE FUNCTION PUBLIC .mark_message_as_read(p_message_id uuid) RETURNS VOID LANGUAGE plpgsql AS $function$ BEGIN
  UPDATE
    "Messages"
  SET
    isread = TRUE
  WHERE
    id = p_message_id;

END;

$function$;

CREATE
OR REPLACE FUNCTION PUBLIC .mark_messages_as_not_read() RETURNS VOID LANGUAGE plpgsql AS $function$BEGIN
UPDATE
  "Messages"
SET
  isread = FALSE;

END;

$function$;

CREATE
OR REPLACE FUNCTION PUBLIC .mark_messages_as_read2(mid bigint) RETURNS VOID LANGUAGE plpgsql AS $function$BEGIN
UPDATE
  "Appeals"
SET
  isread = TRUE
WHERE
  id = mid;

END;

$function$;

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
OR REPLACE FUNCTION PUBLIC .get_role(auth_email text) RETURNS text LANGUAGE plpgsql AS $function$
DECLARE
  user_role text;

BEGIN
  SELECT
    role
  FROM
    PUBLIC."Profiles"
  WHERE
    email = auth_email INTO user_role;

RETURN user_role;

END;

$function$;

CREATE
OR REPLACE FUNCTION PUBLIC .get_student_courses(sid uuid) RETURNS TABLE(
  course_id bigint,
  course_prefix text,
  course_code bigint,
  course_name text,
  course_section text,
  course_semester text,
  course_year bigint,
  professor_first_name text,
  professor_last_name text,
  is_grader BOOLEAN
) LANGUAGE plpgsql AS $function$ BEGIN
  RETURN query
  SELECT
    C .id AS course_id,
    C .prefix AS course_prefix,
    C .code AS course_code,
    C .name AS course_name,
    C .section AS course_section,
    C .semester AS course_semester,
    C .year AS course_year,
    p.first_name AS professor_first_name,
    p.last_name AS professor_last_name,
    sc.is_grader
  FROM
    "Students" AS s
    INNER JOIN "StudentCourse" AS sc ON s.id = sc.student_id
    INNER JOIN "Courses" AS C ON sc.course_id = C .id
    INNER JOIN "ProfessorCourse" AS pc ON C .id = pc.course_id
    INNER JOIN "Professors" AS p ON pc.professor_id = p.id
  WHERE
    s.id = sid
    AND sc.is_grader = FALSE;

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
OR REPLACE FUNCTION PUBLIC .insert_template(pid text, temp_name text, temp_text text) RETURNS VOID LANGUAGE plpgsql AS $function$ BEGIN
  INSERT INTO
    PUBLIC."Templates" (professor_id, temp_name, temp_text)
  VALUES
    (pid :: uuid, temp_name, temp_text);

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

CREATE policy "Enable delete for professors" ON "public"."Appeals" AS permissive FOR
DELETE
  TO PUBLIC USING ((auth.uid() = professor_id));

CREATE policy "Enable insert for student users only" ON "public"."Appeals" AS permissive FOR
INSERT
  TO authenticated WITH CHECK (
    (
      auth.uid() IN (
        SELECT
          "Students" .id
        FROM
          "Students"
      )
    )
  );

CREATE policy "Enable read access for all GradeBoost users" ON "public"."Appeals" AS permissive FOR
SELECT
  TO authenticated USING (TRUE);

CREATE policy "Enable update for professors" ON "public"."Appeals" AS permissive FOR
UPDATE
  TO authenticated USING ((auth.uid() = professor_id)) WITH CHECK ((auth.uid() = professor_id));

CREATE policy "Enable delete for users based on user_id" ON "public"."Assignments" AS permissive FOR
DELETE
  TO PUBLIC USING (
    (
      auth.uid() IN (
        SELECT
          "Professors" .id
        FROM
          "Professors"
      )
    )
  );

CREATE policy "Enable insert for professor users only" ON "public"."Assignments" AS permissive FOR
INSERT
  TO authenticated WITH CHECK (
    (
      auth.uid() IN (
        SELECT
          "Professors" .id
        FROM
          "Professors"
      )
    )
  );

CREATE policy "Enable read access for all users" ON "public"."Assignments" AS permissive FOR
SELECT
  TO authenticated USING (TRUE);

CREATE policy "Enable full CRUD for Professors" ON "public"."Courses" AS permissive FOR
INSERT
  TO authenticated WITH CHECK (
    (
      auth.uid() IN (
        SELECT
          "Professors" .id
        FROM
          "Professors"
      )
    )
  );

CREATE policy "Enable read access for all users" ON "public"."Courses" AS permissive FOR
SELECT
  TO PUBLIC USING (TRUE);

CREATE policy "Enable read access for authenticated users" ON "public"."Messages" AS permissive FOR
SELECT
  TO authenticated USING (TRUE);

CREATE policy "Enable update on messages" ON "public"."Messages" AS permissive FOR
UPDATE
  TO authenticated USING (
    (
      (sender_id = auth.uid())
      OR (recipient_id = auth.uid())
    )
  ) WITH CHECK (
    (
      (sender_id = auth.uid())
      OR (recipient_id = auth.uid())
    )
  );

CREATE policy "Enable full CRUD access for all professor users" ON "public"."ProfessorCourse" AS permissive FOR ALL TO authenticated USING ((auth.uid() = professor_id)) WITH CHECK ((auth.uid() = professor_id));

CREATE policy "Enable read access for student users" ON "public"."ProfessorCourse" AS permissive FOR
SELECT
  TO authenticated USING (
    (
      auth.uid() IN (
        SELECT
          "Students" .id
        FROM
          "Students"
      )
    )
  );

CREATE policy "Enable read access for all users" ON "public"."Professors" AS permissive FOR
SELECT
  TO authenticated USING (TRUE);

CREATE policy "Enable insert for students only" ON "public"."StudentAppeal" AS permissive FOR
INSERT
  TO authenticated WITH CHECK (
    (
      auth.uid() IN (
        SELECT
          "Students" .id
        FROM
          "Students"
      )
    )
  );

CREATE policy "Enable read access for all authenticated users" ON "public"."StudentAppeal" AS permissive FOR
SELECT
  TO authenticated USING (TRUE);

CREATE policy "Enable read access for all users" ON "public"."StudentCourse" AS permissive FOR
SELECT
  TO authenticated USING (TRUE);

CREATE policy "enable full CRUD for professors" ON "public"."StudentCourse" AS permissive FOR ALL TO PUBLIC USING (
  (
    auth.uid() IN (
      SELECT
        "Professors" .id
      FROM
        "Professors"
    )
  )
) WITH CHECK (
  (
    auth.uid() IN (
      SELECT
        "Professors" .id
      FROM
        "Professors"
    )
  )
);

CREATE policy "Enable read access for all users" ON "public"."Students" AS permissive FOR
SELECT
  TO authenticated USING (TRUE);

CREATE policy "Enable update for users based on email" ON "public"."Templates" AS permissive FOR
UPDATE
  TO PUBLIC USING ((auth.uid() = professor_id)) WITH CHECK ((auth.uid() = professor_id));