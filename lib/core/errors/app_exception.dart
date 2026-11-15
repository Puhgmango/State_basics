/// Lớp cơ sở cho mọi ngoại lệ nghiệp vụ của ứng dụng.
///
/// Dùng `sealed` để trình biên dịch kiểm tra đầy đủ các trường hợp khi
/// `switch` và để phân biệt rõ lỗi nghiệp vụ với lỗi hệ thống.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Thông điệp thân thiện có thể hiển thị trực tiếp cho người dùng.
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Giá trị bộ đếm vượt ngoài khoảng cho phép.
final class CounterLimitException extends AppException {
  const CounterLimitException(super.message);
}

/// Dữ liệu đầu vào không hợp lệ (ví dụ bước nhảy ngoài danh sách).
final class InvalidInputException extends AppException {
  const InvalidInputException(super.message);
}

/// Giỏ hàng đã đầy.
final class CartLimitException extends AppException {
  const CartLimitException(super.message);
}
