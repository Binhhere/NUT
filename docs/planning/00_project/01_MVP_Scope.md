# NUT — MVP Scope

## Version 1 MVP (ship target: 4 weeks)

### Core features — must have

| Feature | Description |
|---|---|
| Streak counter | Days / hours / minutes since last reset. Persisted locally + Supabase |
| Relapse reset | Compassionate reset flow. Animation + supportive copy. NOT shame-based |
| Lifetime clean days | Total days clean across all streaks |
| Milestone badges | 7 / 30 / 90 / 365 days. Locked/unlocked state |
| Daily notification | One gentle morning reminder |
| Home screen widget | Shows streak count on home screen |
| Community feed | Text-first. Post with streak badge. 1–3 photos/day optional |
| Onboarding | Username + reason selection. Optional. No forced test |
| Auth | Supabase email auth |

### Premium features — behind paywall

| Feature | Price |
|---|---|
| Journal | Daily entry, 1–2 lines minimum |
| Relapse pattern analytics | Which day/time user typically relapses |
| Advanced stats | Longest streak, average streak, total relapses |
| Custom notification time | — |
| Home screen widget | — |

### Pricing
- Monthly: $4.99/month
- Annual: $29.99/year (anchor this prominently)
- Trial: 5–7 days free

### OUT OF SCOPE for Version 1
- Ryan / Ryana companion character
- Visual novel / dialog system
- Environment / map feature
- AI language processing
- Moderation system
- Multi-language (i18n foundation only)
- iOS build
- Web version

---

## Version 2 MVP (after Version 1 has traction)

### Companion system — Ryan / Ryana

**Character design:**
- Style: 4-koma manga, hand-drawn, simple line art
- Background: white or light warm beige (manga paper feel)
- Character states: reading, studying, napping, exercising, writing
- Speech bubbles: standard manga style
- User input: 3 options at bottom — Yes / No / Write your own

**Core loop:**

| Trigger | Response |
|---|---|
| Morning open | Ryan sends a letter — daily quote (like Vietnamese desk calendar) |
| Any time open | Ryan is busy — reading, studying, napping. Does not notice user |
| Tap character 5 times | Ryan looks up: "Need something?" Then returns to work |
| User relapse — first time | Ryan comforts gently |
| User relapse — repeated | Ryan hugs user, says it's okay |
| User relapse — 10+ days streak | Ryan leaves. Letter: "I have things to do. Come back in 21 days." |
| User reaches 21 days after Ryan left | Ryan returns |
| User rarely relapses | Occasional science note: "Research says once a week is healthy for prostate. No streak penalty." |

**Task / goal system:**
- User sets a goal: task name + deadline (days)
- Success: "We're proud of you"
- Failure: compassionate message from Ryan

**Technical implementation:**
- Assets: PNG sprite sheets, static backgrounds, character layers
- Dialog: JSON script files, template strings with variable substitution
- No AI, no dynamic generation
- Flutter widget stack — no game engine needed
- Rule engine: simple state machine based on streak data

**Philosophy:**
The app is a quiet space. Ryan is busy with his own life. User is not the center of attention. The app does not demand anything. This is the anti-pattern to every other app.

**Community feed — revised for V2:**
- Text-first, progress card-first
- No raw photo feed (Google Play policy risk)
- Share streak milestone cards instead
- Simple reactions, no comments initially
