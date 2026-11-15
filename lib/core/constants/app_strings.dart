/// Tập trung các chuỗi hiển thị để tránh "magic string" rải rác trong UI.
abstract final class AppStrings {
  static const String appTitle = 'Quản lý trạng thái trong Flutter';

  static const String counterTitle = '1. setState & cập nhật giao diện';
  static const String lifecycleTitle = '2. Vòng đời State';
  static const String sharedTitle = '3. Giới hạn của state cục bộ';

  static const String counterSubtitle =
      'Thay đổi state → build() chạy lại → UI mới';
  static const String lifecycleSubtitle =
      'initState, didUpdateWidget, build, dispose...';
  static const String sharedSubtitle =
      'Chia sẻ state giữa các widget: prop drilling';

  static const String unexpectedError = 'Đã xảy ra lỗi không mong muốn.';
}
