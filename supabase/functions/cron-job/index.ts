Deno.serve(async (req) => {
  const { email, number_of_appeals, diget_type } = await req.json()
  
  console.log({email})
  console.log({number_of_appeals})
  console.log({digest_type})

  return new Response(JSON.stringify(data), { headers: { 'Content-Type': 'application/json' } })
})