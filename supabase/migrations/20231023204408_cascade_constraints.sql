ALTER TABLE
    IF EXISTS PUBLIC."Templates" DROP CONSTRAINT IF EXISTS Templates_professor_id_fkey,
ADD
    CONSTRAINT Templates_professor_id_fkey FOREIGN KEY (professor_id) REFERENCES "Professors" (id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE;

ALTER TABLE
    IF EXISTS PUBLIC."StudentCourse" DROP CONSTRAINT IF EXISTS StudentCourse_course_id_fkey,
ADD
    CONSTRAINT StudentCourse_course_id_fkey FOREIGN KEY (course_id) REFERENCES "Courses" (id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE;

ALTER TABLE
    IF EXISTS PUBLIC."StudentCourse" DROP CONSTRAINT IF EXISTS StudentCourse_student_id_fkey,
ADD
    CONSTRAINT StudentCourse_student_id_fkey FOREIGN KEY (course_id) REFERENCES "Courses" (id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE;

ALTER TABLE
    IF EXISTS PUBLIC."ProfessorCourse" DROP CONSTRAINT IF EXISTS ProfessorCourse_course_id_fkey,
ADD
    CONSTRAINT ProfessorCourse_course_id_fkey FOREIGN KEY (course_id) REFERENCES "Courses" (id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE;

ALTER TABLE
    IF EXISTS PUBLIC."ProfessorCourse" DROP CONSTRAINT IF EXISTS ProfessorCourse_professor_id_fkey,
ADD
    CONSTRAINT ProfessorCourse_professor_id_fkey FOREIGN KEY (professor_id) REFERENCES "Professors" (id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE;

ALTER TABLE
    IF EXISTS PUBLIC."Assignments" DROP CONSTRAINT IF EXISTS Assignments_course_id_fkey,
ADD
    CONSTRAINT Assignments_course_id_fkey FOREIGN KEY (course_id) REFERENCES "Courses" (id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE;

ALTER TABLE
    IF EXISTS PUBLIC."Appeals" DROP CONSTRAINT IF EXISTS Appeals_assignment_id_fkey,
ADD
    CONSTRAINT Appeals_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES "Assignments" (id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE;

ALTER TABLE
    IF EXISTS PUBLIC."StudentAppeal" DROP CONSTRAINT IF EXISTS StudentAppeal_appeal_id_fkey,
ADD
    CONSTRAINT StudentAppeal_appeal_id_fkey FOREIGN KEY (appeal_id) REFERENCES "Appeals" (id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE;

ALTER TABLE
    IF EXISTS PUBLIC."StudentAppeal" DROP CONSTRAINT IF EXISTS StudentAppeal_student_id_fkey,
ADD
    CONSTRAINT StudentAppeal_student_id_fkey FOREIGN KEY (student_id) REFERENCES "Students" (id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE;

ALTER TABLE
    IF EXISTS PUBLIC."Messages" DROP CONSTRAINT IF EXISTS Messages_appeal_id_fkey,
ADD
    CONSTRAINT Messages_appeal_id_fkey FOREIGN KEY (appeal_id) REFERENCES "Appeals" (id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE;

ALTER TABLE
    IF EXISTS PUBLIC."Messages" DROP CONSTRAINT IF EXISTS Messages_recipient_id_fkey,
ADD
    CONSTRAINT Messages_recipient_id_fkey FOREIGN KEY (recipient_id) REFERENCES "Users" (id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE;

ALTER TABLE
    IF EXISTS PUBLIC."Messages" DROP CONSTRAINT IF EXISTS Messages_sender_id_fkey,
ADD
    CONSTRAINT Messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES "Users" (id) ON
UPDATE
    CASCADE ON
DELETE
    CASCADE;