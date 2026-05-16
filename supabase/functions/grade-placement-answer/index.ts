import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { question, userAnswer } = await req.json()
  const GEMINI_KEY = Deno.env.get('GEMINI_API_KEY')!

  const prompt = `Grade this open-ended English writing response.
Question: "${question}"
Response: "${userAnswer}"
Return ONLY JSON: {"estimated_level": "A1|A2|B1|B2|C1", "score": 0-10}`

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.2, maxOutputTokens: 100 },
      }),
    }
  )

  const data = await response.json()
  const text = data.candidates[0].content.parts[0].text
  const clean = text.replace(/```json|```/g, '').trim()

  return new Response(clean, {
    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
  })
})
