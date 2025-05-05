class BaseResponse<T> {
  final String status;
  final String message;
  final T? data;

  BaseResponse({required this.status, required this.message, this.data});

  factory BaseResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJsonT) {
    return BaseResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  bool get isSuccess => status == 'success';
}
