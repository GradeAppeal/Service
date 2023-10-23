create or replace function public.sort_user () returns trigger language plpgsql as $$
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
$$;

create or replace trigger tr_sort_user
after insert on public."Users" for each row
execute function sort_user ();