/// Thrown when a remote data source operation fails.
class ServerException implements Exception {
  const ServerException([this.message = 'Server error occurred']);

  final String message;
}

/// Thrown when a cache/local data source operation fails.
class CacheException implements Exception {
  const CacheException([this.message = 'Cache error occurred']);

  final String message;
}

/// Thrown when Firebase Auth returns an error.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}
