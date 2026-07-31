# FoundationX

FoundationX is a mobile learning companion for secondary-school (K-12) students, built with
[Flutter](https://flutter.dev). Students browse subjects, work through lessons, take quizzes, and
track progress through XP, streaks, and unlockable achievements.

- **Demo video:** https://youtu.be/YxZQu0emJAs 
- **Backend repo:** https://github.com/Janviere-dev/foundationX_backend
- **Backend API docs (Swagger UI):** https://bodemurairi.me/docs
- **Firebase console:** https://console.firebase.google.com/u/1/project/foundationx-c3b2e/overview

## Features

- **Authentication**: email/password and Google sign-in via Firebase Auth, mandatory email
  verification, password reset, and a guided complete-profile wizard (school, grade, subjects).
- **Subjects & Lessons**: browse subjects, work through lessons with unlock/progress logic.
- **Quizzes**: scored quizzes with a timer, tied into XP and achievement rewards.
- **Progress**: real per-subject and overall completion tracking, plus a recent-activity feed.
- **Achievements**: unlockable badges, automatically triggering an in-app notification.
- **Notifications**: persisted notification list with read/unread state and a mute toggle.
- **Settings**: dark mode, notification, and sound-effect preferences, persisted locally.
- **AI-generated lessons & quizzes** *(backend ready, client integration in progress)*: A
  FastAPI service generates lesson content and quiz questions based on the Rwandan curriculum, and grades
  submitted quiz answers. The service is functional and independently documented via Swagger UI.

## Tech stack

| Layer | Technology |
|---|---|
| Client framework | [Flutter](https://docs.flutter.dev) (Dart) |
| State management | [`provider`](https://pub.dev/packages/provider) (`ChangeNotifier`) |
| Navigation | [`go_router`](https://pub.dev/packages/go_router), with an auth-aware redirect guard |
| Auth & database | [Firebase Authentication](https://firebase.google.com/docs/auth) + [Cloud Firestore](https://firebase.google.com/docs/firestore) |
| Local persistence | [`shared_preferences`](https://pub.dev/packages/shared_preferences) |
| AI backend | [FastAPI](https://fastapi.tiangolo.com). See [foundationX_backend](https://github.com/Janviere-dev/foundationX_backend) |
| RAG / retrieval | [Qdrant](https://qdrant.tech) vector search + [Haystack](https://haystack.deepset.ai) pipeline over OCR'd course PDFs |
| LLM agents | Google ADK `LlmAgent`s via [LiteLLM](https://docs.litellm.ai) → Gemini (OpenRouter-paid and free-tier fallback paths) |
| Backend datastores | MongoDB (lessons, quiz reports) · Redis (quiz session + content cache) |
| Object storage | Cloudflare R2 (S3-compatible), holding the ingested source course PDFs |
| Backend reverse proxy | [Traefik](https://doc.traefik.io/traefik/), with automatic Let's Encrypt TLS, in Docker Compose |

## Project structure

```
lib/
├── core/
│   ├── constants/
│   ├── models/
│   ├── providers/
│   ├── theme/
│   └── widgets/
├── data/
├── features/
│   ├── auth/
│   ├── chat/
│   ├── home/
│   ├── lesson/
│   ├── notifications/
│   ├── onboarding/
│   ├── profile/
│   ├── progress/
│   ├── quiz/
│   ├── settings/
│   └── subjects/
├── firebase_options.dart
├── main.dart
└── router.dart
```

Each feature owns its own screens, its own provider and models and they all live under `core/`.

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- A configured Firebase project with Authentication (Email/Password + Google) and Cloud Firestore
  enabled
- `flutterfire configure` run against that project to (re)generate `lib/firebase_options.dart`,
  if you're pointing at your own Firebase project instead of the one already checked in

### Setup

```bash
git clone https://github.com/Janviere-dev/foundationX_frontend.git
cd foundationX_frontend
flutter pub get
flutter run
```

### Running tests

```bash
flutter analyze
flutter test
```

## Backend API (foundationX_backend)

The AI backend lives in its own repository and its own stack (Python). Its two route
groups, both documented interactively at https://bodemurairi.me/docs:

| Route | Method | Purpose |
|---|---|---|
| `/api/content/` | `POST` | Generate AI lesson content for a subject/grade, grounded via Qdrant RAG retrieval |
| `/api/content/{content_id}` | `GET` | Fetch a previously generated, saved lesson |
| `/api/content/{content_id}/complete` | `PATCH` | Mark a lesson complete |
| `/api/assessment/quizz` | `POST` | Generate quiz questions (returns `409` with the existing quiz if one is already in progress) |
| `/api/assessment/quizz/submit` | `POST` | Submit answers; grading runs asynchronously as a background task |
| `/api/assessment/quizz/report/{quizz_id}` | `GET` | Poll for the graded report once background grading finishes |

See that repository's `core/config.py` for the full list of required environment variables
(Qdrant Cloud, MongoDB, Redis, Cloudflare R2, and Gemini/OpenRouter credentials).

## Architecture notes

- **State management:** every cross-cutting provider (`UserProvider`, `AuthProvider`,
  `ThemeProvider`, `LessonProvider`, `QuizProvider`, `AchievementProvider`,
  `NotificationProvider`) is constructed once in `AppProviders.providers()` and supplied through a
  single `MultiProvider` in `main.dart`. Providers that depend on another provider read it via
  `context.read` inside their own `create` callback, relying on `MultiProvider`'s ordered
  construction.
- **Routing & auth guarding:** `router.dart`'s `redirect` callback is registered as `go_router`'s
  `refreshListenable` against `AuthProvider`, so any auth-status change (login, logout, email
  verified, profile completed) automatically re-evaluates where the user should be.
- **Achievements → notifications:** `NotificationProvider` optionally takes an `AchievementProvider`
  reference and listens for newly-unlocked achievements, creating a notification for each.
- **Local vs. cloud persistence:** account and cross-device data (profile, subjects) live in
  Firestore; device-local preferences (theme, notification settings, onboarding-seen flag,
  cached notification list) live in `SharedPreferences`.

## Known gaps
- **Backend now has real unit tests** (endpoint, repository-retrieval, and storage tests.
- **`UserProvider` has no streak-update method.** `UserModel.streak` exists but nothing currently
  increments it on lesson/quiz completion.
- **`home_screen.dart` has a hardcoded notification badge count** in one spot. IT should read from
  `NotificationProvider.unreadCount` instead.
