import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");

const handler = async (req: Request): Promise<Response> => {
  // get data from pg_net
  // email: professor email
  // numAppeals: number of appeals received in the past month/week/day
  // timespan: 1 day, 7 days, 1 month depending on setting
  const {email, numAppeals, timeSpan} = await req.json()
  const debug = false;
  if (debug) console.log(`sending email to ${email} with ${numAppeals} appeal(s)`);

  let digestType: string;
  switch (timeSpan) {
    case "1 day": 
      digestType = 'day';
      break;
    case "7 days":
      digestType = 'week';
      break;
    case "1 month":
      digestType = 'month';
      break;
    default: 
      digestType = "";
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
      to: [email],
      subject: `GradeBoost: Appeals Digest`,
      html: `
        <div>You received ${numAppeals} appeal${Number(numAppeals) === 1 ? "" : "s"} over the past ${digestType}.</div>
        <div>Check your appeals on <a href="https://gradeboost.cs.calvin.edu/">GradeBoost</a>.</div>
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