import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { difficulty, excludedIds } = await req.json()
  const GEMINI_KEY = Deno.env.get('GEMINI_API_KEY')!

  const prompt = `Generate a unique English proficiency multiple-choice question.
Difficulty Level: ${difficulty}/10 (1 is basic greetings, 10 is complex academic nuance).
The question should test either reading, listening (conceptual), writing (grammar), or vocabulary.

Return ONLY JSON:
{
  "id": "${Math.random().toString(36).substring(7)}",
  "skill": "reading|listening|writing|vocabulary",
  "text": "The question text",
  "options": ["A", "B", "C", "D"],
  "correct_answer": "The exact string of the correct option"
}`

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=${GEMINI_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.9, maxOutputTokens: 500 },
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
