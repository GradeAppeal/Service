CREATE OR REPLACE FUNCTION public.delete_user() RETURNS TRIGGER AS $$ 
begin
    DELETE FROM public."Users" as u
    WHERE u.id = old.id;
    RETURN old;
END;

$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE trigger tr_on_auth_user_deleted
AFTER
DELETE
    ON auth.users FOR each ROW EXECUTE PROCEDURE public.delete_user ();