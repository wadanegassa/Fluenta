import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { answers } = await req.json()
  const GEMINI_KEY = Deno.env.get('GEMINI_API_KEY')!

  const prompt = `You are a professional CEFR English assessor. Grade this complete placement exam and determine the student's overall level.
Below is the list of questions, their types, the correct answers (for multiple choice), and the student's answers:

${JSON.stringify(answers, null, 2)}

Instructions:
1. Review the MCQ grammar/vocabulary questions and calculate their exact correctness percentage.
2. Carefully analyze the open-ended writing and polite speaking/conversation replies to assess their grammatical fluency, complexity, sentence structure, and vocabulary choice.
3. Based on the overall average performance and complexity of their written/spoken output, decide their final CEFR level (A1, A2, B1, B2, C1, or C2).
4. Provide a short, highly encouraging feedback paragraph explaining their performance and explaining their diagnostic level.

Return ONLY a raw JSON object with no markdown formatting, no backticks, and no extra text:
{
  "estimated_level": "A1|A2|B1|B2|C1|C2",
  "score": 85, // out of 100
  "feedback": "A beautiful feedback paragraph outlining their strengths and areas of growth..."
}`

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=${GEMINI_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.2, maxOutputTokens: 1000 },
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
