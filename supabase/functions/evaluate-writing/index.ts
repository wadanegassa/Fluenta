import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { level, prompt: writingPrompt, userText } = await req.json()
  const GEMINI_KEY = Deno.env.get('GEMINI_API_KEY')!

  const prompt = `You are a kind, encouraging English writing teacher.

Student Level: ${level}
Writing Prompt: "${writingPrompt}"
Student's Response: "${userText}"

Evaluate this writing and return ONLY JSON with NO markdown:
{
  "score": 0-100,
  "corrected_text": "The corrected version of their text with all errors fixed naturally",
  "feedback": "2-3 sentences of specific, human feedback. Be warm and direct. Name exactly what was good and exactly what to fix.",
  "strengths": "One specific thing they did well",
  "main_error": "The single most important thing to improve, with a clear example of how",
  "error_count": 0
}`

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=${GEMINI_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.4, maxOutputTokens: 1000 },
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
