# NUT — Database Architecture (Supabase / PostgreSQL)

## Tables

### users
| Column | Type | Notes |
|---|---|---|
| id | uuid | Primary key, from Supabase auth |
| username | text | Display name |
| reason | text | Onboarding reason selection |
| created_at | timestamptz | — |

### streaks
| Column | Type | Notes |
|---|---|---|
| id | uuid | Primary key |
| user_id | uuid | FK → users.id |
| start_date | timestamptz | When current streak started |
| end_date | timestamptz | Null if active |
| is_active | boolean | Only one active per user |
| relapse_count | integer | Total relapses |
| lifetime_clean_days | integer | Calculated across all streaks |
| created_at | timestamptz | — |

### feed_posts
| Column | Type | Notes |
|---|---|---|
| id | uuid | Primary key |
| user_id | uuid | FK → users.id |
| content | text | Post text |
| streak_day | integer | Streak day at time of post |
| reaction_count | integer | Default 0 |
| created_at | timestamptz | — |

### badges
| Column | Type | Notes |
|---|---|---|
| id | uuid | Primary key |
| user_id | uuid | FK → users.id |
| badge_type | text | "7d", "30d", "90d", "365d" |
| unlocked_at | timestamptz | — |

### journal_entries (premium)
| Column | Type | Notes |
|---|---|---|
| id | uuid | Primary key |
| user_id | uuid | FK → users.id |
| content | text | — |
| mood | text | Optional |
| created_at | timestamptz | — |

## RLS (Row Level Security)
All tables: users can only read/write their own rows.
Feed posts: readable by all authenticated users, writable by owner only.

## Local persistence (shared_preferences)
- onboarding_complete: bool
- username: string
- reason: string
- streak_start_date: string (ISO8601)
- last_relapse_date: string
- lifetime_clean_days: int
