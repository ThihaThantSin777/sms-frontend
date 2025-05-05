class ErrorResponse {
  final String status;
  final String message;

  ErrorResponse({required this.status, required this.message});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(status: json['status'] ?? 'error', message: json['message'] ?? 'Something went wrong');
  }
}
