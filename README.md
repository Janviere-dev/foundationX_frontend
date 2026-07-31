# FoundationX

FoundationX is a Flutter mobile learning app that helps students strengthen core academic foundations through curriculum-aligned subjects, AI-generated lessons, adaptive quizzes, progress tracking, and gamification (XP, levels, streaks, achievements).

**Repository:** https://github.com/Janviere-dev/foundationX_frontend

---

## Features

- **Authentication** — Email/password and Google Sign-In via Firebase Auth, with email verification and password reset
- **Onboarding** — Splash, intro slides, and complete-profile flow (school, grade, subjects, goals, date of birth, gender)
- **Live course catalog** — Subjects and topics loaded from the backend (`GET /api/courses/`)
- **AI-generated lessons** — On-demand lesson content from the learning agent (`POST /api/content/`), with caching, markdown rendering, checkpoint flip-cards, and further reading
- **Assessment quizzes** — Generate, take, submit, and review AI-backed quizzes (`/api/assessment/quizz`), including grading, reports, and quiz history
- **Progress & gamification** — XP, levels, streaks, achievements, and weekly stats
- **Profile & settings** — Account info, badges, notification toggle, dark mode
- **Navigation** — go_router with auth redirect guards (splash → onboarding/login → home)

---

## Tech Stack

| Layer | Technology |
|--------|------------|
| Framework | Flutter (Dart SDK ^3.12.2) |
| State management | Provider / ChangeNotifier |
| Routing | go_router |
| Auth | Firebase Auth, Google Sign-In |
| HTTP / API | http package |
| Local storage | SharedPreferences |
| Markdown | flutter_markdown_plus |
| Backend API | REST (courses, users, content, assessment) |

---

## Project Structure (high level)

```
lib/
├── core/
│   ├── config/          # API base URL (ApiConfig)
│   ├── models/          # Course, GeneratedLessonContent, quiz models, etc.
│   ├── providers/       # User, lesson, achievement, theme providers
│   ├── services/        # ContentService, CoursesService, QuizService
│   ├── theme/           # Colors, course visuals
│   └── widgets/         # Shared UI components
├── data/                # Local Math/English curriculum metadata
├── features/
│   ├── auth/            # Login, register, profile completion, AuthService
│   ├── assessment/      # Quiz setup, taking, grading, report, history
│   ├── home/            # Home, main navigation, subject grids
│   ├── lesson/          # Lesson detail + generated lesson body
│   ├── onboarding/      # Splash & onboarding slides
│   ├── profile/         # Profile, achievements, settings hooks
│   ├── subjects/        # Subjects list, course overview, subject detail
│   └── ...
├── router.dart          # go_router + auth guards
└── main.dart
```

---

## Prerequisites

- Flutter (stable channel recommended)
- Dart SDK compatible with ^3.12.2
- Firebase project with Authentication enabled (Email/Password + Google)
- Running FoundationX backend API (or configure API_BASE_URL)
- Android Studio / Xcode for device/emulator builds (as needed)

---

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/Janviere-dev/foundationX_frontend.git
cd foundationX_frontend
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Firebase

1. Create a Firebase project and enable Email/Password and Google sign-in.
2. Register your Android/iOS/Web apps and add FlutterFire config (firebase_options.dart).

### 4. API base URL

ApiConfig resolves the backend URL as follows:

| Environment | Default URL |
|-------------|-------------|
| Release | https://bodemurairi.me |
| Android emulator | http://10.0.2.2:8000 |
| Other (desktop/web/iOS sim) | http://localhost:8000 |

Override at build/run time:

```bash
flutter run --dart-define=API_BASE_URL=https://your-api.example.com
```

### 5. Run the app

```bash
flutter run
```

---

## Backend endpoints used

| Method | Path | Purpose |
|--------|------|---------|
| POST | /api/users/create_user | Ensure user exists after Firebase sign-in |
| GET | /api/users/me | Fetch profile |
| PUT | /api/users/extend_info | Complete / update onboarding profile |
| PATCH | /api/users/subjects | Join a subject |
| GET | /api/courses/ | Course catalog |
| POST | /api/content/ | Generate lesson content |
| POST | /api/assessment/quizz | Generate or resume quiz |
| POST | /api/assessment/quizz/submit | Submit answers |
| GET | /api/assessment/quizz/report/{id} | Graded report |
| GET | /api/assessment/quizz/progress | Quiz history / progress |

Authenticated routes expect: Authorization: Bearer <Firebase ID token>.

---

## Main user flows

1. First launch — Splash → Onboarding → Login / Register
2. Sign up — Firebase account → email verification (if needed) → complete profile → Welcome → Home
3. Learn — Pick subject → topics/lessons → AI-generated lesson → complete for XP
4. Quiz — Pick subject/topic → configure questions/difficulty → take quiz → grading → report
5. Progress — Level, streak, achievements, quiz history on Home / Profile

---

## Known limitations

- Local lesson metadata is richest for Mathematics and English; other catalog subjects rely more on live backend topics and generated content.
- Lesson generation and quiz grading are LLM-backed and can take several seconds.
- Offline lesson downloads are not fully implemented yet.
- Some profile actions (e.g. changing avatar) may still show "coming soon".

---

## Contributing

1. Create a feature branch from main.
2. Keep UI and API contracts consistent with lib/core/services/.
3. Open a pull request against main.

---

## License

Private / academic project — rights reserved by the FoundationX team unless otherwise stated.
