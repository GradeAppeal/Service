ALTER TABLE
    "public"."Admins" DROP CONSTRAINT "admins_email_key";

ALTER TABLE
    "public"."Admins" DROP CONSTRAINT "admins_id_fkey";

ALTER TABLE
    "public"."Admins" DROP CONSTRAINT "admins_pkey";

ALTER TABLE
    "public"."Templates" DROP CONSTRAINT "template_pkey";

DROP INDEX IF EXISTS "public"."admins_email_key";

DROP INDEX IF EXISTS "public"."admins_pkey";

DROP INDEX IF EXISTS "public"."template_pkey";

DROP TABLE "public"."Admins";

ALTER TABLE
    "public"."Templates"
ADD
    COLUMN "id" bigint generated BY DEFAULT AS identity NOT NULL;

CREATE UNIQUE INDEX template_pkey ON PUBLIC."Templates" USING btree (id);

ALTER TABLE
    "public"."Templates"
ADD
    CONSTRAINT "template_pkey" PRIMARY KEY USING INDEX "template_pkey";