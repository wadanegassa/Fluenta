# 🎙️ Voce

Welcome to **Voce** (formerly Fluenta), an elite, AI-first conversational language learning platform designed to revolutionize the way individuals master English. By moving away from rigid, one-size-fits-all worksheets, Voce dynamically generates custom-tailored curricula based on every user's unique goals, native language, and live proficiency diagnostics.

---

## 🌟 The Vision

Language learning should be natural, highly communicative, and interactive. Voce is built for serious learners who want to achieve high CEFR verbal performance and natural speaking flow. Our design focuses on clean aesthetics, responsive interactions, and premium animations—positioning the application as an elite consumer tech product.

---

## 🚀 Core Features & Architecture

### 🎯 1. Adaptive Placement & CEFR Progression
* **Adaptive Diagnostics**: Evaluates starting grammar, reading comprehension, and active vocabulary to assign a precise CEFR base (A1 to C1).
* **Live Roadmaps**: Generates localized module trees mapped dynamically to student goals (e.g., Business, Academic, Travel).

### 🧠 2. Four-Pillar AI Lesson Generation (Lex)
Every lesson challenges you across all four primary language quadrants simultaneously:
* **Reading**: Leveled technical prose passages with comprehension assessments.
* **Listening**: Interactive educational videos integrated with video players and fill-in-the-blank transcripts.
* **Writing**: Open-ended paragraph prompts graded in real-time by a custom Supabase Edge Function utilizing Gemini 1.5 Pro.
* **Speaking**: Audio prompts leveraging Speech-to-Text grading engines to score verbal accuracy and pronunciation flow.
* **Lex (Socratic Tutor)**: A Socratic chat overlay companion that asks guiding questions and provides prompts rather than giving answers.

### 💬 3. Unified Real-Time Social Lounges
* **Multi-channel Lobbies**: Public classrooms grouped by topic (e.g., "Grammar Help", "Free Talk") running on real-time Supabase WebSockets.
* **1-on-1 Direct Messaging (DMs)**: Dual-mode chat parameters allowing students to instantly launch secure private conversation channels from peer profiles.
* **Peer Roster**: Tabbed student browser decorated with beautiful active CEFR badge tags (A1-C2) showing the live expertise of your study circle.

### 🔒 4. Absolute Section Locks & SnackBar Indicators
* **Perfect Lockouts**: Lesson sections are rigidly locked until all previous exercises are completed.
* **Interactive SnackBar Guidance**: Directs users with step-by-step instructions on precisely which question is blank to prevent skips and visual friction.

---

## ⚡ Newly Implemented Features & Polish

We have recently completed a comprehensive architectural overhaul, bringing the app to a production-ready, ultra-premium standard:

* **Live Streak & Stats Refreshes**: Rewrote the progress pipeline to auto-invalidate the Riverpod profile provider. The absolute millisecond a lesson is completed, your **Day Streak** and **Lessons Done** counters refresh live across the dashboard and profile tabs.
* **Automatic Offline Caching**: Added an `OfflineCacheService` backed by device `SharedPreferences`. The app automatically caches loaded grammar and reading packages, seamlessly falling back to local files during connection drops, complete with a glassmorphic **"⚡ OFFLINE" Appbar badge**.
* **Beautiful Screen Entries**: Overhauled the splash and walkthrough systems:
  * **Interactive Splash Screen**: Animated glowing voice pulse visualizer bars cycling smoothly in a custom sine-wave alongside an Outfit brandmark and linear loading progress track.
  * **Premium Onboarding Slides**: Multi-layered glassmorphic sphere cards pulsing with a subtle breathing effect over real-time color-shifting backdrop glows.
* **Double-Keyboard Overlay Fix**: Corrected writing input bars by removing redundant viewInsets padding, letting native scaffold resize and preventing input fields from overlapping the keyboard.
* **Premium Settings Suite**: Built a fully functioning preferences deck supporting notification toggles, sound effects, **localized language selector dialogue sheets**, draggable Terms & Services modals, and system hardware diagnostics (About Phone).

---

