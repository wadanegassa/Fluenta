import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { level, prompt: speakingPrompt, transcription } = await req.json()
  const GEMINI_KEY = Deno.env.get('GEMINI_API_KEY')!

  const prompt = `You are an encouraging English speaking coach.

Student Level: ${level}
Speaking Prompt: "${speakingPrompt}"
What they said (transcribed): "${transcription}"

Evaluate and return ONLY JSON with NO markdown:
{
  "score": 0-100,
  "fluency_note": "One sentence on how smoothly they spoke",
  "grammar_errors": ["error 1", "error 2"],
  "corrected_version": "How a fluent speaker would say the same thing",
  "best_part": "The strongest part of their response",
  "next_focus": "One specific improvement to make"
}`

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=${GEMINI_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.4, maxOutputTokens: 800 },
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
