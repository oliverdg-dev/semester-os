/// Status values shared by the database and the domain layer. Pure Dart, so
/// `domain/` code may import it. Stored by [Enum.name] in the database.
library;

/// Task progress. `inProgress` is set when the first session starts.
enum TaskStatus { incomplete, inProgress, completed }

/// Stored session states (ARCHITECTURE §7). "Missed" is derived from the
/// clock for planned sessions whose end has passed; it is never stored.
enum SessionStatus { planned, active, paused, completed, skipped }

/// Theme preference in Settings.
enum ThemePreference { system, light, dark }
