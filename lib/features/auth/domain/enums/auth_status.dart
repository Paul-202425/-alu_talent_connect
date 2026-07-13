/// High-level auth status derived from the Firebase session stream.
enum AuthStatus {
  /// Firebase is restoring a persisted session on app launch.
  loading,

  /// No active session — user must sign in or register.
  unauthenticated,

  /// Valid session exists.
  authenticated,
}
