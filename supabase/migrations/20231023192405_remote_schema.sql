alter table "public"."Templates" drop constraint "template_pkey";

drop index if exists "public"."template_pkey";

alter table "public"."Templates" drop column "id";

CREATE UNIQUE INDEX "Templates_pkey" ON public."Templates" USING btree (professor_id);

alter table "public"."Templates" add constraint "Templates_pkey" PRIMARY KEY using index "Templates_pkey";


