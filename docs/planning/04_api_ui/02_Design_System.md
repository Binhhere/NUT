# NUT — Design System

## Philosophy
Dark. Calm. Achievement-focused. Private. Safe.
NOT: clinical, aggressive, shame-based, gym-bro, gambling-like, crypto-like, overwhelming.

---

## Color palette

### Primary
| Token | Hex | Usage |
|---|---|---|
| background | #0D0D0D | App background |
| surface | #161616 | Bottom nav, app bar |
| card | #1E1E1E | Cards, containers |

### Accent — amber gold
| Token | Hex | Usage |
|---|---|---|
| accent | #F5A623 | Streak number, primary CTA, selected tab, milestone highlight |
| accentDark | #D4850A | Pressed/hover state |
| accentBg | #2A1F0A | Tinted container background |

> Rule: Do NOT overuse gold across the whole UI. Reserve it for the streak number and primary actions only.

### Text
| Token | Hex | Usage |
|---|---|---|
| textPrimary | #FFFFFF | Headings, primary content |
| textSecondary | #A0A0A0 | Subtitles, metadata |
| textMuted | #555555 | Disabled, placeholder |

### Semantic
| Token | Hex | Usage |
|---|---|---|
| success | #1D9E75 | Milestone unlocked, streak active |
| relapse | #E24B4A | Relapse reset — use sparingly, compassionate context only |
| premium | #7F77DD | Paywall and premium features only |

> Relapse red rule: Never use as full-screen danger state. Small semantic cue only.
> Premium purple rule: Only in paywall context. Nowhere else.

---

## Typography

| Role | Size | Weight | Color |
|---|---|---|---|
| Streak number | 72sp+ | 500–600 | #F5A623 |
| Screen title | 24sp | 500–600 | #FFFFFF |
| Body | 16sp | 400 | #FFFFFF |
| Caption | 13sp | 400 | #A0A0A0 |

Font: System default (Inter or Roboto). Clean, no decorative fonts.

---

## Spacing

| Token | Value |
|---|---|
| Screen horizontal padding | 20px |
| Card padding | 16–20px |
| Gap small | 8px |
| Gap medium | 16px |
| Gap large | 24px |

---

## Border radius

| Component | Radius |
|---|---|
| Button | 12px |
| Card | 16px |
| Badge / pill | 999px |

---

## Shared widgets (Flutter)

| Widget | Description |
|---|---|
| NutCard | Dark card with 16px radius, card color background |
| NutButton | Primary CTA — accent gold fill, 12px radius |
| NutGhostButton | Secondary — transparent, border only |
| NutPill | Badge/pill — 999px radius, various colors |
| NutStatCard | Stat display — number + label |
| NutSectionHeader | Section title with optional action |

---

## Screen-specific rules

### Home screen
- Streak number dominates — should feel like the whole screen is built around it
- Calm supportive message under streak number
- Primary action visible but not aggressive
- "Keep going" stronger than "Reset"
- Reset is secondary/destructive, never the main CTA

### Relapse screen
Approved copy only:
- "This does not erase your effort."
- "Take a breath. Start again with what you learned."
- "Every day you tried counts."
- "You know yourself better now."

Forbidden copy:
- "failed", "lost", "weak", "zero", "start over", "you broke it"

### Feed screen
- Text-first
- Progress card with username + streak day + content + createdAt + reactions
- No raw image upload (Google Play policy)

### Paywall screen
- Premium purple accent here only
- Annual plan anchored prominently
- Show savings: "$29.99/year = $2.50/month"
- Not manipulative. Not countdown timers. Not fake urgency.

---

## Version 2 design additions

### Ryan / Ryana visual style
- 4-koma manga line art
- Warm beige / white background (#FAF6F0 or pure white)
- Simple character, minimal detail
- Speech bubble: standard manga oval
- Character states (sprite list):
  - reading_book
  - studying_desk
  - napping
  - exercising
  - writing
  - looking_up (tap response)
  - comforting_hug
  - waving_goodbye
  - waving_hello (return)

### Dialog system colors
- Background: warm beige #FAF6F0
- Text: near-black #1A1A1A
- Speech bubble: white with thin border
- User choice buttons: 3 options, pill shape, light gray

### Contrast note
Version 2 uses warm light theme for Ryan scenes — opposite of main app dark theme. This contrast is intentional: Ryan's world feels different, warmer, more personal.
