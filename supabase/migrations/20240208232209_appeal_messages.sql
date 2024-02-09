ALTER TABLE
    PUBLIC."Appeals" DROP COLUMN IF EXISTS isread;

-- Add the is_read column to the Messages table with a default value of FALSE
ALTER TABLE
    PUBLIC."Messages"
ADD
    COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT FALSE;

-- Update existing rows to set is_read to TRUE
UPDATE
    PUBLIC."Messages"
SET
    is_read = TRUE;

-- Alter the column to set the default value to FALSE
ALTER TABLE
    PUBLIC."Messages"
ALTER COLUMN
    is_read
SET
    DEFAULT FALSE;

DROP FUNCTION IF EXISTS PUBLIC .update_messages_read(aid bigint);

CREATE
OR replace FUNCTION PUBLIC .update_messages_read(aid bigint) returns VOID AS $$ BEGIN
    UPDATE
        PUBLIC."Messages"
    SET
        is_read = TRUE
    WHERE
        appeal_id = aid
        AND is_read = FALSE;

END;

$$ LANGUAGE plpgsql;