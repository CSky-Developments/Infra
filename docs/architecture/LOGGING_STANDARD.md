# Application Logging Standard

## Why does this exist?
To ensure uniform observability across all CSky services. Standardized logs make it significantly easier to debug cross-service issues, monitor system health, and retain historical data without cluttering the host.

## Rules

### 1. Persistent Log Storage
All application containers must write their log files to an internal directory (e.g., `/app/logs`) which **must be bind-mounted** to the host filesystem.
- **Docker Compose Mapping:** `- "../data/logs:/app/logs"`
- Because of our SGID permission standard, the folder must be manually pre-created on the host or Docker will auto-create it with restrictive permissions.

### 2. Standardized Log Format
Every service (whether Node.js, Spring Boot, or Python) must configure its logger to output in the exact same format:
`[YYYY-MM-DD HH:mm:ss] [LEVEL] [SERVICE_NAME] - Message`

**Example:**
`[2026-07-11 10:15:30] [INFO] [codehost-api] - Database connection established successfully.`

### 3. Startup Archival & Rotation
When a service restarts or boots up, it must not blindly append to a massive, endless log file.
- The active log file must be named `service.log`.
- **On Startup:** The application logger must archive the *previous* `service.log` by renaming it with the timestamp of when it was stopped/rotated (e.g., `service-2026-07-11_10-15-30.log`).
- **New Session:** A fresh `service.log` is created for the new running session.
- (Optional but recommended): Implement a max-file limit (e.g., keep the last 14 days or last 10 restarts) to prevent storage exhaustion.

### 4. Console & File Output
Applications should output logs to **both** the console (`stdout`/`stderr`) and the file system. 
- Console logs allow Docker (`docker compose logs`) to capture the stream.
- File logs provide the permanent, searchable archive.

### 5. Log Quality & Verbosity (No Spam)
Make sure only **useful** logs are recorded. 
- **Forbidden:** Repeated logging of the same event in a loop (e.g., "Checking database... OK" every 5 seconds). This is considered nonsense and is strictly forbidden.
- **Required:** Log only meaningful state changes, incoming requests (if relevant for auditing), warnings, and errors. If a background task runs on a timer, log its start and completion *only* if it performs actual work, or log nothing if it's just a passive heartbeat.

## Implementation Guide
- **Node.js:** Use `winston` and custom transport logic or `winston-daily-rotate-file` configured for startup rotation.
- **Java/Spring Boot:** Use `Logback` with a custom `TimeBasedRollingPolicy` or a `SizeAndTimeBasedRollingPolicy` combined with `OnStartupTriggeringPolicy`.
