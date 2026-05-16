import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { level, topic, focusSkill, weakAreas, userGoal } = await req.json()
  const GEMINI_KEY = Deno.env.get('GEMINI_API_KEY')!

  const prompt = `You are an expert English teacher creating a lesson for a ${level} level student.

Lesson Topic: "${topic}"
Focus Skill: ${focusSkill}
Student's Weak Areas: ${weakAreas?.join(', ') || 'none identified yet'}
Student's Goal: ${userGoal || 'general fluency'}

Create a complete, engaging lesson. Return ONLY a JSON object with NO markdown, NO backticks, NO extra text:
{
  "grammar_explanation": "Clear, human explanation of the key grammar point. Use simple words. Include 3 real-life examples as sentences. End with one tip to remember it.",
  "vocabulary_list": [
    {"word": "", "definition": "", "example": "", "level": "${level}"}
  ],
  "reading_passage": "An engaging 150-200 word passage using the grammar and vocabulary. Make it feel like something real — a blog post, a story, a letter, not a textbook.",
  "reading_questions": [
    {"id": "r1", "question": "", "type": "mcq", "options": ["", "", "", ""], "answer": ""},
    {"id": "r2", "question": "", "type": "mcq", "options": ["", "", "", ""], "answer": ""},
    {"id": "r3", "question": "", "type": "open_ended", "answer_key": ""}
  ],
  "listening_transcript": "A realistic 100-120 word conversation or monologue that teaches by example. Make it sound like real speech, not a script.",
  "listening_exercises": [
    {"id": "l1", "sentence_with_blank": "The _____ was very interesting.", "answer": ""},
    {"id": "l2", "sentence_with_blank": "", "answer": ""},
    {"id": "l3", "sentence_with_blank": "", "answer": ""}
  ],
  "writing_prompt": "A clear, specific writing task (2-3 sentences explaining what to write). Make it real and relevant to everyday life.",
  "speaking_prompt": "A clear speaking task the student will record. Should feel like a natural conversation starter, not an exam prompt."
}`

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.7, maxOutputTokens: 3000 },
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
