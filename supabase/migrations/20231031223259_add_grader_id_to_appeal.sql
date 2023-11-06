ALTER TABLE
    PUBLIC."Appeals"
ADD
    COLUMN grader_id uuid NULL;

ALTER TABLE
    PUBLIC."Appeals"
ADD
    constraint appeals_grader_id_fkey foreign key (grader_id) references PUBLIC."Students" (id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE;