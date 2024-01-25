ALTER TABLE
    PUBLIC."Profiles"
ADD
    constraint auth_uid_fk foreign key (id) references auth. "users" (id) ON
DELETE
    CASCADE;