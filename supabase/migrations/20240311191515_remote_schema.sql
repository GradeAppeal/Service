-- drop function if exists "public"."delete_user"();
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
OR REPLACE FUNCTION PUBLIC .get_all_messages(aid bigint) RETURNS TABLE(
  message_id bigint,
  created_at TIMESTAMP WITH TIME ZONE,
  sender_id uuid,
  recipient_id uuid,
  appeal_id bigint,
  message_text text,
  from_grader BOOLEAN,
  sender_name text,
  recipient_name text,
  is_read BOOLEAN,
  has_image BOOLEAN
) LANGUAGE plpgsql AS $function$ BEGIN
  RETURN query
  SELECT
    m.id AS message_id,
    m.created_at AS created_at,
    m.sender_id AS sender_id,
    m.recipient_id AS recipient_id,
    m.appeal_id AS appeal_id,
    m.message_text AS message_text,
    m.from_grader AS from_grader,
    m.sender_name AS sender_name,
    m.recipient_name AS recipient_name,
    m.is_read AS is_read,
    m.has_image AS has_image
  FROM
    PUBLIC."Messages" AS m
  WHERE
    m.appeal_id = aid
  ORDER BY
    m.created_at;

END;

$function$;

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
OR REPLACE FUNCTION PUBLIC .get_student_messages(aid bigint, sid text, pid text) RETURNS TABLE(
  message_id bigint,
  created_at TIMESTAMP WITH TIME ZONE,
  sender_id uuid,
  recipient_id uuid,
  appeal_id bigint,
  message_text text,
  from_grader BOOLEAN,
  sender_name text,
  recipient_name text,
  is_read BOOLEAN,
  has_image BOOLEAN
) LANGUAGE plpgsql AS $function$ BEGIN
  RETURN query
  SELECT
    m.id AS message_id,
    m.created_at AS created_at,
    m.sender_id AS sender_id,
    m.recipient_id AS recipient_id,
    m.appeal_id AS appeal_id,
    m.message_text AS message_text,
    m.from_grader AS from_grader,
    m.sender_name AS sender_name,
    m.recipient_name AS recipient_name,
    m.is_read AS is_read,
    m.has_image AS has_image
  FROM
    PUBLIC."Messages" AS m
  WHERE
    m.appeal_id = aid
    AND (
      (
        m.sender_id = sid :: uuid
        AND m.recipient_id = pid :: uuid
      )
      OR (
        m.sender_id = pid :: uuid
        AND m.recipient_id = sid :: uuid
      )
    )
  ORDER BY
    m.created_at;

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
OR REPLACE FUNCTION PUBLIC .insert_message(
  appid bigint,
  sender_id text,
  recipient_id text,
  created_at TIMESTAMP WITH TIME ZONE,
  message_text text,
  from_grader BOOLEAN,
  sender_name text,
  recipient_name text,
  has_image BOOLEAN
) RETURNS bigint LANGUAGE plpgsql AS $function$
DECLARE
  new_message_id bigint;

BEGIN
  INSERT INTO
    PUBLIC."Messages" (
      created_at,
      sender_id,
      recipient_id,
      appeal_id,
      message_text,
      from_grader,
      sender_name,
      recipient_name,
      has_image
    )
  VALUES
    (
      created_at,
      sender_id :: UUID,
      recipient_id :: UUID,
      appid,
      message_text,
      from_grader,
      sender_name,
      recipient_name,
      has_image
    ) RETURNING id INTO new_message_id;

RETURN new_message_id;

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