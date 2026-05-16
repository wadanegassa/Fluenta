import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { level, lessonTopic, messages } = await req.json()
  const GEMINI_KEY = Deno.env.get('GEMINI_API_KEY')!

  const systemContext = `You are Lex, a friendly English tutor inside the Fluenta app.
The student is at ${level} level. Current lesson topic: "${lessonTopic}".
Rules: Keep responses short (3-5 sentences max). Always give a real example when explaining. Be encouraging. Use simple, clear language. Never be condescending.`

  const conversationHistory = messages.map((m: any) => ({
    role: m.role,
    parts: [{ text: m.content }],
  }))

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        system_instruction: { parts: [{ text: systemContext }] },
        contents: conversationHistory,
        generationConfig: { temperature: 0.8, maxOutputTokens: 500 },
      }),
    }
  )

  const data = await response.json()
  const text = data.candidates[0].content.parts[0].text

  return new Response(JSON.stringify({ reply: text }), {
    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
  })
})
