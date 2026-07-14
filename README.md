# GymApp

Flutter iOS gym management app with a .NET backend. Built for personal use — track exercises, create training routines, and manage workouts on your iPhone.

## Architecture

```
gym_app/                  Flutter frontend (iOS)
├── lib/
│   ├── config/           Constants, router, theme
│   ├── data/             API client, models, repositories
│   ├── domain/           Entities, enums
│   ├── presentation/     Screens, widgets, Riverpod providers
│   └── main.dart
└── test/                 Unit & widget tests

GymAPI/                   .NET 10 backend (separate repo)
├── src/Api/              Controllers, middleware
├── src/Application/      DTOs, use cases, services
├── src/Domain/           Entities, enums
└── src/Infrastructure/   EF Core, PostgreSQL
```

**Stack:** Flutter 3.x · Dart 3.12 · Riverpod · GoRouter · Dio · PostgreSQL 16 · .NET 10 · Docker

## Prerequisites

- **Flutter** — `flutter --version` (requires Dart SDK 3.12+)
- **Xcode** — for iOS builds and simulator
- **Docker** — for the backend and database
- **iPhone** — for on-device testing (optional)

## Backend Setup

The API runs via Docker Compose. From the `GymAPI` directory:

```bash
cd /path/to/GymAPI
docker compose up -d
```

This starts:

| Service    | Container          | Port       | URL              |
|------------|--------------------|------------|------------------|
| API        | `gymapi-api`       | 5200 → 8080 | `http://localhost:5200` |
| PostgreSQL | `gymapi-postgres`  | 5433 → 5432 | `localhost:5433` |

Verify the API is running:

```bash
curl http://localhost:5200/health
```

### Database

Migrations run automatically on first API startup. To seed test data, register a user and create exercises/trainings via the API (see [Seeding](#seeding-test-data)).

## Flutter Setup

```bash
cd gym_app
flutter pub get
flutter analyze
flutter test
```

### Run on iOS Simulator

```bash
open -a Simulator
flutter run
```

### Run on iPhone

1. Connect your iPhone via USB
2. Open `ios/Runner.xcworkspace` in Xcode
3. Set your **Signing Team** (Personal Team or Apple Developer)
4. Select your iPhone as the build target
5. Press **Run** (or use `flutter run` from the terminal)

> **Note:** The app defaults to `http://localhost:5200`. For on-device testing, pass your Mac's IP at run time:
> ```bash
> flutter run --dart-define=API_BASE_URL=http://<YOUR_MAC_IP>:5200
> ```

### Build for Release

```bash
./scripts/build_release.sh
```

Or manually:

```bash
flutter build ios --release --no-codesign
```

Then archive from Xcode for TestFlight/App Store deployment.

## Test User

```
Email:    test@test.com
Password: password12345
```

## Seeding Test Data

After registering, use `curl` or the Swagger UI at `http://localhost:5200/swagger` to create exercises and trainings. The API expects:

- **Integer enums** (1-indexed): `muscleGroups: [1, 5]` = `[Chest, Triceps]`
- **Required fields**: `name`, `description`, `muscleGroups`, `equipments`, `difficultyLevel`

### Muscle Groups

| Value | Name        |
|-------|-------------|
| 1     | Chest       |
| 2     | Back        |
| 3     | Shoulders   |
| 4     | Biceps      |
| 5     | Triceps     |
| 6     | Forearms    |
| 7     | Core        |
| 8     | Quadriceps  |
| 9     | Hamstrings  |
| 10    | Glutes      |
| 11    | Calves      |
| 12    | FullBody    |

### Equipment

| Value | Name           |
|-------|----------------|
| 1     | Barbell        |
| 2     | Dumbbell       |
| 3     | Kettlebell     |
| 4     | Machine        |
| 5     | Cable          |
| 6     | ResistanceBand |
| 7     | PullUpBar      |
| 8     | Bench          |
| 9     | SmithMachine   |
| 10    | Bodyweight     |
| 11    | MedicineBall   |
| 12    | FoamRoller     |

### Difficulty Levels

| Value | Name          |
|-------|---------------|
| 1     | Beginner      |
| 2     | Intermediate  |
| 3     | Advanced      |

## Running Tests

```bash
flutter test                  # All tests
flutter test --coverage      # With coverage report
```

## Environment Variables

Backend environment is configured via `docker-compose.yml` or a `.env` file in the `GymAPI` root:

| Variable                    | Default                                        | Description                |
|-----------------------------|-------------------------------------------------|----------------------------|
| `POSTGRES_DB`               | `gym_exercises_dev`                             | Database name              |
| `POSTGRES_USER`             | `postgres`                                      | Database user              |
| `POSTGRES_PASSWORD`         | `postgres`                                      | Database password          |
| `POSTGRES_PORT`             | `5433`                                          | External PostgreSQL port   |
| `API_PORT`                  | `5200`                                          | External API port          |
| `JWT_SECRET_KEY`            | `your-super-secret-key-at-least-32-characters-long` | JWT signing key       |

## Project Structure

| Layer           | Responsibility                          |
|-----------------|-----------------------------------------|
| `config/`       | API URLs, GoRouter routes, FlexColorScheme theme |
| `data/`         | Dio client with JWT interceptor, JSON models, repository implementations |
| `domain/`       | Entities, enums, domain logic           |
| `presentation/` | Screens, reusable widgets, Riverpod providers |
| `test/`         | Unit tests (repositories, providers) and widget tests (screens, widgets) |
