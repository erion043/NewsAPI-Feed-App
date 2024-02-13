class ApiResponse<T> {
  final T data;
  final bool error;
  final String errorMessage;

  ApiResponse({
    required this.data,
    this.error = false,
    this.errorMessage = "noError",
  });
}
