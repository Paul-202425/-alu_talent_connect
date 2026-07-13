// Auth feature — handles user sign-in, sign-up, and session management.
//
// Layers:
// - data         → Firebase Auth datasource + repository implementation
// - domain       → Auth repository contract + user session entity
// - presentation → Riverpod providers, login/register screens
