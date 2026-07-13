import 'package:equatable/equatable.dart';

/// UI state for login and register forms.
class AuthFormState extends Equatable {
  const AuthFormState({
    this.isLoading = false,
    this.errorMessage,
    this.isPasswordResetSent = false,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isPasswordResetSent;

  AuthFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isPasswordResetSent,
    bool clearPasswordReset = false,
  }) {
    return AuthFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isPasswordResetSent: clearPasswordReset
          ? false
          : (isPasswordResetSent ?? this.isPasswordResetSent),
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, isPasswordResetSent];
}
