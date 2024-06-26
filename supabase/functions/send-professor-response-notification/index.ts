import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");

const handler = async (req: Request): Promise<Response> => {
  // get data from pg_net
  const { professorName, studentName, studentEmail, assignment, course } =
    await req.json();

  // send POST request to resend server
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${RESEND_API_KEY}`,
    },
    body: JSON.stringify({
      from: "GradeBoost Team <team@gradeboost.cs.calvin.edu>",
      to: [studentEmail],
      subject: "Appeal Update: Professor Response",
      html: `
        <div>
          Hello ${studentName},
          <p>Professor ${professorName} left a response for ${course}: ${assignment}.</p>
          <p>Please make sure to check the interaction history for your appeal</p>
        </div>
        <br>
        <div>
        Best, 
        </div>
        <div>
        GradeBoost Team
        </div>
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
