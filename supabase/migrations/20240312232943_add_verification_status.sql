-- Add a new column to the Profiles table
ALTER TABLE
    PUBLIC."Profiles"
ADD
    COLUMN is_verified BOOLEAN;

-- Update the newly added column based on the condition
UPDATE
    PUBLIC."Profiles" AS p
SET
    is_verified = CASE
        WHEN u.confirmed_at IS NOT NULL THEN TRUE
        ELSE FALSE
    END
FROM
    AUTH. "users" AS u
WHERE
    u.id = p.id;

-- Add a new column to the Students table
ALTER TABLE
    PUBLIC."Students"
ADD
    COLUMN is_verified BOOLEAN;

-- Update the newly added column based on the value from the Profiles table
UPDATE
    PUBLIC."Students" AS s
SET
    is_verified = p.is_verified
FROM
    PUBLIC."Profiles" AS p
WHERE
    s.id = p.id;

-- Add a new column to the Professors table
ALTER TABLE
    PUBLIC."Professors"
ADD
    COLUMN is_verified BOOLEAN;

-- Update the newly added column based on the value from the Profiles table
UPDATE
    PUBLIC."Professors" AS prof
SET
    is_verified = p.is_verified
FROM
    PUBLIC."Profiles" AS p
WHERE
    prof.id = p.id;