CREATE
OR replace FUNCTION PUBLIC .sort_user () returns TRIGGER LANGUAGE plpgsql AS $$ BEGIN
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

$$;

CREATE
OR replace TRIGGER tr_sort_user after
INSERT
  ON PUBLIC."Users" FOR each ROW EXECUTE FUNCTION sort_user ();