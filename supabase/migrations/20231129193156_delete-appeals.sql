DROP FUNCTION IF EXISTS PUBLIC .delete_appeal(aid bigint);

-- function to delete appeal
CREATE
OR replace FUNCTION PUBLIC .delete_appeal(aid bigint) returns VOID AS $$ BEGIN
    DELETE FROM
        PUBLIC."Appeals" AS app
    WHERE
        app.id = aid;

END;

$$ LANGUAGE plpgsql;

-- function to delete appeal
CREATE
OR replace FUNCTION PUBLIC .after_delete_appeal() returns TRIGGER AS $$ BEGIN
    DELETE FROM
        PUBLIC."Messages" AS m
    WHERE
        m.appeal_id = NEW .id;

RETURN NEW;

END;

$$ LANGUAGE plpgsql;

-- trigger on appeals table
DROP TRIGGER IF EXISTS "tr_on_delete_appeal" ON PUBLIC."Appeals";

CREATE TRIGGER tr_on_delete_appeal after
DELETE
    ON PUBLIC."Appeals" FOR each ROW EXECUTE FUNCTION after_delete_appeal();