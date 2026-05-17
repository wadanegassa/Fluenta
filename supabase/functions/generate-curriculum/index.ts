import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { levelId } = await req.json()
  const GEMINI_KEY = Deno.env.get('GEMINI_API_KEY')!
  const YOUTUBE_KEY = Deno.env.get('YOUTUBE_API_KEY')!
  const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
  const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  // 1. Generate Curriculum with Gemini
  const prompt = `Create a language learning curriculum for English level ${levelId}.
Return exactly 3 modules, each with 3 lessons.
IMPORTANT: Module 1 must be VERY EASY and foundational for ${levelId} level. Subsequent modules should increase in difficulty.
For each lesson, provide:
- A title
- A specific focus topic (grammar or vocabulary)
- A focus skill (one of: speaking, listening, reading, writing)

Return ONLY JSON:
[
  {
    "title": "Module 1: [Topic]",
    "description": "Module description",
    "lessons": [
      { "title": "Lesson 1: [Title]", "focus_topic": "Topic", "focus_skill": "skill" }
    ]
  }
]`

  const geminiResponse = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite:generateContent?key=${GEMINI_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.7, maxOutputTokens: 2000 },
      }),
    }
  )

  const geminiData = await geminiResponse.json()
  const text = geminiData.candidates[0].content.parts[0].text
  const curriculum = JSON.parse(text.replace(/```json|```/g, '').trim())

  const results = []

  // 2. Process each module and lesson
  for (let i = 0; i < curriculum.length; i++) {
    const mod = curriculum[i]
    
    // Insert Module
    const { data: moduleData, error: modError } = await supabase
      .from('modules')
      .insert({
        level_id: levelId,
        title: mod.title,
        description: mod.description,
        order_index: i
      })
      .select()
      .single()

    if (modError) continue

    for (let j = 0; j < mod.lessons.length; j++) {
      const les = mod.lessons[j]
      
      // 3. Search and Verify YouTube video for each lesson
      let youtubeId = ''
      let youtubeTitle = ''
      try {
        const searchQuery = `${les.focus_topic} English lesson for ${levelId} students official educational`;
        const ytRes = await fetch(
          `https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=5&q=${encodeURIComponent(searchQuery)}&type=video&key=${YOUTUBE_KEY}`
        )
        const ytData = await ytRes.json()
        
        if (ytData.items && ytData.items.length > 0) {
          const videoIds = ytData.items.map((item: any) => item.id.videoId).join(',')
          
          // Verify embeddable status using videos.list
          const verifyRes = await fetch(
            `https://www.googleapis.com/youtube/v3/videos?part=status,snippet&id=${videoIds}&key=${YOUTUBE_KEY}`
          )
          const verifyData = await verifyRes.json()
          
          if (verifyData.items && verifyData.items.length > 0) {
            // Find the first video that is strictly embeddable
            for (const video of verifyData.items) {
              if (video.status && video.status.embeddable === true && video.status.privacyStatus === 'public') {
                youtubeId = video.id
                youtubeTitle = video.snippet.title
                break
              }
            }
          }
        }
      } catch (e) {
        console.error('YouTube search or verification failed', e)
      }

      // Insert Lesson
      await supabase
        .from('lessons')
        .insert({
          module_id: moduleData.id,
          title: les.title,
          focus_topic: les.focus_topic,
          focus_skill: les.focus_skill,
          youtube_video_id: youtubeId,
          youtube_video_title: youtubeTitle,
          order_index: j
        })
    }
    results.push(moduleData)
  }

  return new Response(JSON.stringify({ success: true, modules: results }), {
    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
  })
})
