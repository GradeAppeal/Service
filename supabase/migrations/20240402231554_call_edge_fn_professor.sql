DROP PROCEDURE IF EXISTS proc_invoke_digest_email(
    email text,
    number_of_appeals text,
    digest_type text
);

CREATE
OR replace PROCEDURE proc_invoke_digest_email(
    pid uuid,
    email text,
    digest_type text
) LANGUAGE plpgsql security definer
SET
    search_path = PUBLIC AS $$
DECLARE
    number_of_appeals text;

BEGIN
    -- get number of appeals whenever sending the email
    SELECT
        COUNT(*) :: text INTO number_of_appeals
    FROM
        PUBLIC."Appeals"
    WHERE
        created_at >= CURRENT_TIMESTAMP - digest_type :: INTERVAL
        AND professor_id = pid;

-- send email
PERFORM net.http_post(
    -- URL of Edge function
    url := 'https://nsxdlyqbigoijypmnsqe.supabase.co/functions/v1/send-professor-digest-email',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5zeGRseXFiaWdvaWp5cG1uc3FlIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTgwNjU2MzgsImV4cCI6MjAxMzY0MTYzOH0._1H9yDTwcKPdpGXnI_b2fcTtZb4q7HPhezuTHkT5s70"}' :: jsonb,
    BODY := format(
        '{"email": "%s", "numAppeals": "%s", "timeSpan": "%s"}',
        email,
        number_of_appeals,
        digest_type
    ) :: jsonb
);

END;

$$;