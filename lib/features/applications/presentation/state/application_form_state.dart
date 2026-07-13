import 'package:equatable/equatable.dart';

class ApplicationFormState extends Equatable {
  const ApplicationFormState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  ApplicationFormState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSuccess,
    bool clearSuccess = false,
  }) {
    return ApplicationFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: clearSuccess ? false : (isSuccess ?? this.isSuccess),
    );
  }

  @override
  List<Object?> get props => [isLoading, errorMessage, isSuccess];
}
