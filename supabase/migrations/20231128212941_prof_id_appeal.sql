ALTER TABLE
    PUBLIC."Appeals"
ADD
    column "professor_id" uuid;

ALTER TABLE
    PUBLIC."Appeals"
ADD
    CONSTRAINT fk_appeals_professors FOREIGN KEY (professor_id) REFERENCES PUBLIC."Professors" (id);

;