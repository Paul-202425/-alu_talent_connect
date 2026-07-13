import 'package:equatable/equatable.dart';

/// Lightweight auth session entity — separate from the full [UserProfile].
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;

  @override
  List<Object?> get props => [id, email, displayName];
}
