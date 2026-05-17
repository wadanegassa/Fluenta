import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const GEMINI_KEY = Deno.env.get('GEMINI_API_KEY')!

  const prompt = `Create a comprehensive English proficiency placement exam containing exactly 10 questions.
The test must range from basic (A1) to advanced (C1) and assess grammar, vocabulary, writing, and polite conversation/speaking.
DO NOT include any listening questions.

Question Formats:
- 5 Multiple Choice Questions (MCQ) for grammar and vocabulary.
- 3 Writing Questions (open-ended short paragraphs, e.g. "Describe your day yesterday in 2 sentences").
- 2 Speaking/Conversation Questions (open-ended polite conversation prompt, e.g. "How would you politely interrupt someone to ask a question?").

For each question, provide:
1. "id": A unique short identifier (e.g. "pq1", "pq2").
2. "type": The question type ("mcq", "writing", or "speaking").
3. "skill": The specific focus ("grammar", "vocabulary", "writing", or "speaking").
4. "concept": A brief, engaging explanation of what this question tests (e.g., "Tests modal verbs for polite requests"). This will be shown to the student as the concept/idea before they answer.
5. "text": The question text itself.
6. "options": A list of 4 options (only if type is "mcq", empty array otherwise).
7. "correct_answer": The correct choice string (only if type is "mcq", empty string otherwise).

Return ONLY a raw JSON array of 10 question objects with no markdown formatting, no backticks, and no extra text:
[
  {
    "id": "pq1",
    "type": "mcq",
    "skill": "grammar",
    "concept": "...",
    "text": "...",
    "options": ["...", "...", "...", "..."],
    "correct_answer": "..."
  }
]`

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=${GEMINI_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.7, maxOutputTokens: 2500 },
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
