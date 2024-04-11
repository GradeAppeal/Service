import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");

const handler = async (req: Request): Promise<Response> => {
  // get data from pg_net
  const { professor_email, number_of_appeals, digest_type } = await req.json();

  let schedule: string;
  switch (digest_type) {
    case "1 day":
      schedule = "Daily";
      break;
    case "1 month":
      schedule = "Monthly";
      break;
    case "7 days":
      schedule = "Weekly";
      break;
    default:
      schedule = "";
      break;
  }

  // send POST request to resend server
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${RESEND_API_KEY}`,
    },
    body: JSON.stringify({
      from: "GradeBoost Team <team@gradeboost.cs.calvin.edu>",
      to: [professor_email],
      subject: `${ssupchedule} Digest from GradeBoost`,
      html: `
        <div>You have received ${number_of_appeals}.</div>
        <div>Check your appeals on <a href="gradeboost.cs.calvin.edu">GradeBoost</a></div>
      `,
    }),
  });

  const data = await res.json();

  return new Response(JSON.stringify(data), {
    status: 200,
    headers: {
      "Content-Type": "application/json",
    },
  });
};

serve(handler);
